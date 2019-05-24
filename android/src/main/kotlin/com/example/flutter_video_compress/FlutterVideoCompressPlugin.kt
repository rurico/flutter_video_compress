package com.example.flutter_video_compress

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Environment
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File
import org.json.JSONObject
import nl.bravobit.ffmpeg.ExecuteBinaryResponseHandler
import nl.bravobit.ffmpeg.FFmpeg
import nl.bravobit.ffmpeg.FFtask
import java.io.ByteArrayOutputStream
import java.lang.Integer.parseInt
import java.lang.Long.parseLong
import java.io.IOException
import java.lang.Exception


class FlutterVideoCompressPlugin : MethodCallHandler {
    private val channelName = "flutter_video_compress"
    private var stopCommand = false
    private var ffTask: FFtask? = null

    companion object {
        private lateinit var reg: Registrar

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_video_compress")
            channel.setMethodCallHandler(FlutterVideoCompressPlugin())
            reg = registrar
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getThumbnail" -> {
                val path = call.argument<String>("path")!!
                val quality = call.argument<Int>("quality")!!
                val position = call.argument<Long>("position")!!
                getThumbnail(path, quality, position, result)
            }
            "getThumbnailWithFile" -> {
                val path = call.argument<String>("path")!!
                val quality = call.argument<Int>("quality")!!
                val position = call.argument<Long>("position")!!
                getThumbnailWithFile(path, quality, position, result)
            }
            "getMediaInfo" -> {
                val path = call.argument<String>("path")!!
                getMediaInfo(path, result)
            }
            "startCompress" -> {
                val path = call.argument<String>("path")!!
                val quality = call.argument<Int>("quality")!!
                val deleteOrigin = call.argument<Boolean>("deleteOrigin")!!
                startCompress(path, quality, deleteOrigin, result)
            }
            "stopCompress" -> {
                stopCompress()
                result.success("")
            }
            else -> result.notImplemented()
        }
    }

    private fun getBitmap(path: String, position: Long, result: Result): Bitmap {
        var bitmap: Bitmap? = null
        val retriever = MediaMetadataRetriever()

        try {
            retriever.setDataSource(path)
            bitmap = retriever.getFrameAtTime(position, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
        } catch (ex: IllegalArgumentException) {
            result.error(channelName, "Assume this is a corrupt video file", null)
        } catch (ex: RuntimeException) {
            result.error(channelName, "Assume this is a corrupt video file", null)
        } finally {
            try {
                retriever.release()
            } catch (ex: RuntimeException) {
                result.error(channelName, "Ignore failures while cleaning up", null)
            }
        }

        if (bitmap == null) result.success(emptyArray<Int>())

        val width = bitmap!!.width
        val height = bitmap.height
        val max = Math.max(width, height)
        if (max > 512) {
            val scale = 512f / max
            val w = Math.round(scale * width)
            val h = Math.round(scale * height)
            bitmap = Bitmap.createScaledBitmap(bitmap, w, h, true)
        }

        return bitmap!!
    }

    private fun getThumbnail(path: String, quality: Int, position: Long, result: Result) {
        val bmp = getBitmap(path, position, result)

        val stream = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.JPEG, quality, stream)
        val byteArray = stream.toByteArray()
        bmp.recycle()
        result.success(byteArray.toList().toByteArray())
    }

    private fun getThumbnailWithFile(path: String, quality: Int, position: Long, result: Result) {
        val bmp = getBitmap(path, position, result)

        val dir = reg.context().getExternalFilesDir("flutter_video_compress")

        if (!dir.exists()) dir.mkdirs()

        val file = File(dir, path.substring(path.lastIndexOf('/'), path.lastIndexOf('.')) + ".jpg")
        deleteExists(file)

        val stream = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.JPEG, quality, stream)
        val byteArray = stream.toByteArray()

        try {
            file.createNewFile()
            file.writeBytes(byteArray)
        } catch (e: IOException) {
            e.printStackTrace()
        }

        bmp.recycle()

        result.success(file.absolutePath)
    }

    private fun getMediaInfo(path: String, result: Result) {
        result.success(getMediaInfoJson(path).toString())
    }

    private fun getMediaInfoJson(path: String): JSONObject {
        val file = File(path)
        val retriever = MediaMetadataRetriever()

        retriever.setDataSource(reg.context(), Uri.fromFile(file))

        val durationStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
        val title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE) ?: ""
        val author = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_AUTHOR) ?: ""
        val widthStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
        val heightStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
        val duration = parseLong(durationStr)
        val width = parseLong(widthStr)
        val height = parseLong(heightStr)
        val filesize = file.length()

        val json = JSONObject()

        retriever.release()

        json.put("path", path)
        json.put("title", title)
        json.put("author", author)
        json.put("width", width)
        json.put("height", height)
        json.put("duration", duration)
        json.put("filesize", filesize)

        return json
    }

    private fun timeStrToTimestamp(time: String): Long {
        val timeArr = time.split(":")
        val hour = parseInt(timeArr[0])
        val min = parseInt(timeArr[1])
        val secArr = timeArr[2].split(".")
        val sec = parseInt(secArr[0])
        val mSec = parseInt(secArr[1])

        val timeStamp = (hour * 3600 + min * 60 + sec) * 1000 + mSec
        return timeStamp.toLong()
    }

    private fun deleteExists(file: File) {
        if (file.exists()) {
            file.delete()
        }
    }

    private fun startCompress(path: String, quality: Int, deleteOrigin: Boolean, result: Result) {
        val ffmpeg = FFmpeg.getInstance(reg.context())

        if (!ffmpeg.isSupported) {
            return result.error(channelName, "FlutterVideoCompress Error", "ffmpeg is supported this platform")
        }

        val dir = reg.context().getExternalFilesDir("flutter_video_compress")

        if (!dir.exists()) dir.mkdirs()

        val file = File(dir, path.substring(path.lastIndexOf("/")))
        deleteExists(file)

        val crf = 28 - quality * 3

        val cmd = arrayOf("-i", path, "-vcodec", "h264", "-crf", "$crf", "-acodec", "aac", file.absolutePath)

        this.ffTask = ffmpeg.execute(cmd, object : ExecuteBinaryResponseHandler() {
            override fun onProgress(message: String) {
                if ("Duration" in message) {
                    val reg = Regex("""Duration: ((\d{2}:){2}\d{2}\.\d{2}).*""")
                    val totalTimeStr = message.replace(reg, "$1")
                    val totalTime = timeStrToTimestamp(totalTimeStr.trim())
                    MethodChannel(Companion.reg.messenger(), channelName).invokeMethod("updateProgressTotalTime", totalTime)
                }

                if ("frame=" in message) {
                    try {
                        val reg = Regex("""frame.*time=((\d{2}:){2}\d{2}\.\d{2}).*""")
                        val totalTimeStr = message.replace(reg, "$1")
                        var time = timeStrToTimestamp(totalTimeStr.trim())
                        MethodChannel(Companion.reg.messenger(), channelName).invokeMethod("updateProgressTime", time)
                    } catch (e: Exception) {
                        print(e.stackTrace)
                    }
                }

                MethodChannel(reg.messenger(), channelName).invokeMethod("updateProgress", message)

                if (stopCommand) {
                    print("FlutterVideoCompress: Video compression has stopped")
                    ffTask?.killRunningProcess()
                    stopCommand = false
                    val json = getMediaInfoJson(path)
                    json.put("isCancel", true)
                    result.success(json.toString())
                }
            }

            override fun onFinish() {
                val json = getMediaInfoJson(file.absolutePath)
                json.put("isCancel", false)
                result.success(json.toString())
                if (deleteOrigin) {
                    File(path).delete()
                }
            }
        })
    }

    private fun stopCompress() {
        if (ffTask != null && !ffTask!!.isProcessCompleted) {
            stopCommand = true
        }
    }
}

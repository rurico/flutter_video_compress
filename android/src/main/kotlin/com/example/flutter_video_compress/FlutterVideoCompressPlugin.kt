package com.example.flutter_video_compress

import android.annotation.TargetApi
import android.graphics.Bitmap
import android.media.MediaPlayer
import android.media.ThumbnailUtils
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import nl.bravobit.ffmpeg.ExecuteBinaryResponseHandler
import nl.bravobit.ffmpeg.FFmpeg
import nl.bravobit.ffmpeg.FFtask
import java.io.ByteArrayOutputStream
import java.io.File


class FlutterVideoCompressPlugin : MethodCallHandler {
    private val channelName = "flutter_video_compress"
    private var ffTask: FFtask? = null
    private var stopCommand = false

    companion object {
        private lateinit var reg: Registrar
        private lateinit var ffmpeg: FFmpeg
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_video_compress")
            channel.setMethodCallHandler(FlutterVideoCompressPlugin())
            reg = registrar
            ffmpeg = FFmpeg.getInstance(reg.context())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getThumbnail" -> {
                val path = call.argument<String>("path")!!
                val quality = call.argument<Int>("quality")!!
                getThumbnail(path, quality, result)
            }
            "startCompress" -> {
                val path = call.argument<String>("path")!!
                val deleteOrigin = call.argument<Boolean>("deleteOrigin")!!
                startCompress(path, deleteOrigin, result)
            }
            "stopCompress" -> {
                stopCompress(result)
            }
            "getVideoDuration" -> {
                val path = call.argument<String>("path")!!
                getVideoDuration(path, result)
            }
            else -> result.notImplemented()
        }
    }

    @TargetApi(Build.VERSION_CODES.FROYO)
    private fun getThumbnail(path: String, quality: Int, result: Result) {
        val bmp = ThumbnailUtils.createVideoThumbnail(path, MediaStore.Images.Thumbnails.MINI_KIND)
        val stream = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.JPEG, quality, stream)
        val byteArray = stream.toByteArray()
        bmp.recycle()
        result.success(byteArray.asList().toByteArray())
    }

    private fun startCompress(path: String, deleteOrigin: Boolean, result: Result) {
        if (!ffmpeg.isSupported) {
            return result.error(channelName, "FlutterVideoCompress Error", "ffmpeg is supported this platform")
        }
        val lastIndex = path.lastIndexOf("/")
        val folder = path.substring(0, lastIndex) + "/flutter_video_compress"
        val folderFile = File(folder)

        if (!folderFile.exists()) {
            File(folder).mkdirs()
        }

        val newPath = folder + path.substring(lastIndex)

        val cmd = arrayOf("-i", path, "-vcodec", "h264", "-crf", "28", "-acodec", "aac", newPath)

        if (this.ffTask == null) this.ffTask = ffmpeg.execute(cmd, object : ExecuteBinaryResponseHandler() {
            override fun onFinish() {
                if (stopCommand) {
                    return result.success("")
                }
                result.success(newPath)
                if (deleteOrigin) {
                    File(path).delete()
                }
                ffTask = null
                stopCommand = false
            }
        }) else {
            result.error(channelName, "FlutterVideoCompress Error", "compress video is already Running")
        }

    }

    private fun stopCompress(result: Result) {
        if (this.ffTask == null) {
            return result.error(channelName, "FlutterVideoCompress Error", "you don't have any thing compress")
        }
        ffmpeg.killRunningProcesses(this.ffTask)
        this.ffTask = null

        stopCommand = true
        print("FlutterVideoCompress: Video compression has stopped")
        result.success("")
    }

    private fun getVideoDuration(path: String, result: Result) {
        val mp = MediaPlayer.create(reg.context(), Uri.fromFile(File(path)))
        mp.release()
        result.success(mp.duration)
    }
}

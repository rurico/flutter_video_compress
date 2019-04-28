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
import java.io.ByteArrayOutputStream
import java.io.File


class FlutterVideoCompressPlugin : MethodCallHandler {
    private val channelName = "flutter_video_compress"
    private var NOT_LOAD = true

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
                getThumbnail(path, quality, result)
            }
            "compressVideo" -> {
                val path = call.argument<String>("path")!!
                val deleteOrigin = call.argument<Boolean>("deleteOrigin")!!
                compressVideo(path, deleteOrigin, result)
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

    private fun getVideoDuration(path: String, result: Result) {
        val mp = MediaPlayer.create(reg.context(), Uri.fromFile(File(path)))
        mp.release()
        result.success(mp.duration)
    }

    fun compressVideo(path: String, deleteOrigin: Boolean, result: Result) {
        val ffmpeg = FFmpeg.getInstance(reg.context())

        if (!ffmpeg.isSupported) {
            throw Exception("ffmpeg is supported")
        }
        val lastIndex = path.lastIndexOf("/")
        val folder = path.substring(0, lastIndex) + "/flutter_video_compress"
        val folderFile = File(folder);

        if (!folderFile.exists()) {
            File(folder).mkdirs()
        }

        val newPath = folder + path.substring(lastIndex)

        val cmd = arrayOf("-i", path, "-vcodec", "h264", "-crf", "28", "-acodec", "aac", newPath)

        ffmpeg.execute(cmd, object : ExecuteBinaryResponseHandler() {
            override fun onFinish() {
                result.success(newPath)
                if (deleteOrigin) {
                    File(path).delete()
                }

            }
        })

    }
}

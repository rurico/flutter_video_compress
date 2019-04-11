package com.example.flutter_video_compress

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.media.MediaPlayer
import android.media.ThumbnailUtils
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.text.TextUtils
import android.util.Log
import com.qiniu.pili.droid.shortvideo.PLShortVideoTranscoder
import com.qiniu.pili.droid.shortvideo.PLVideoSaveListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.ByteArrayOutputStream
import com.qiniu.pili.droid.shortvideo.PLErrorCode.ERROR_LOW_MEMORY
import com.qiniu.pili.droid.shortvideo.PLErrorCode.ERROR_SRC_DST_SAME_FILE_PATH
import com.qiniu.pili.droid.shortvideo.PLErrorCode.ERROR_NO_VIDEO_TRACK
import kotlin.math.log
import java.io.File
import android.os.Environment

class FlutterVideoCompressPlugin: MethodCallHandler {
  private val channelName = "flutter_video_compress"
  private val ENCODING_BITRATE_LEVEL_ARRAY = intArrayOf(320 * 480, 480 * 854, 544 * 960)

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

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    fun compressVideo(path: String, deleteOrigin: Boolean, result: Result) {
        if (TextUtils.isEmpty(path)) {
            return
        }

        val lastIndex = path.lastIndexOf("/")
        val newPath = path.substring(0, lastIndex) + "/flutter_video_compress" + path.substring(lastIndex)

        val mShortVideoTransCoder = PLShortVideoTranscoder(reg.context(), path, newPath)
        mShortVideoTransCoder.setMaxFrameRate(16)
        val mediaRetriever = MediaMetadataRetriever()
        mediaRetriever.setDataSource(path)
        val height = mediaRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
        val width = mediaRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
        val transCodingBitrateLevel = 1
        val ratio = Integer.parseInt(width) / 720

        mShortVideoTransCoder.transcode(720, Integer.parseInt(height) / ratio, getEncodingBitrateLevel(transCodingBitrateLevel), object : PLVideoSaveListener {
            override fun onSaveVideoSuccess(s: String) {
                if (deleteOrigin) {
                    File(path).delete()
                }
                result.success(newPath)
            }

            override fun onSaveVideoFailed(errorCode: Int) {
                result.error(channelName, errorCode.toString(), errorCode.toString())
            }

            override fun onSaveVideoCanceled() {
            }

            override fun onProgressUpdate(percentage: Float) {

            }
        })
    }

    private fun getEncodingBitrateLevel(position: Int): Int {
        return ENCODING_BITRATE_LEVEL_ARRAY[position]
    }
}

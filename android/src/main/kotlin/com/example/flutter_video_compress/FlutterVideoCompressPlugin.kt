package com.example.flutter_video_compress

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


class FlutterVideoCompressPlugin : MethodCallHandler {

    private val channelName = "flutter_video_compress"
    private val utility = Utility(channelName)
    private var ffmpegCommander: FFmpegCommander? = null

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
        initFfmpegCommanderIfNeeded()
        when (call.method) {
            "getThumbnail" -> {
                val path = call.argument<String>("path")!!
                val quality = call.argument<Int>("quality")!!
                val position = call.argument<Long>("position")!!
                ThumbnailUtility(channelName).getThumbnail(path, quality, position, result)
            }
            "getThumbnailWithFile" -> {
                val path = call.argument<String>("path")!!
                val quality = call.argument<Int>("quality")!!
                val position = call.argument<Long>("position")!!
                ThumbnailUtility(channelName).getThumbnailWithFile(reg.context(), path, quality,
                        position, result)
            }
            "getMediaInfo" -> {
                val path = call.argument<String>("path")!!
                result.success(utility.getMediaInfoJson(reg.context(), path).toString())
            }
            "startCompress" -> {
                val path = call.argument<String>("path")!!
                val quality = call.argument<Int>("quality")!!
                val deleteOrigin = call.argument<Boolean>("deleteOrigin")!!

                ffmpegCommander?.startCompress(path, quality, deleteOrigin, result, reg.messenger())
            }
            "stopCompress" -> {
                ffmpegCommander?.stopCompress()
                result.success("")
            }
            "convertVideoToGif" -> {
                val path = call.argument<String>("path")!!
                val startTime = call.argument<Long>("startTime")!!
                val endTime = call.argument<Long>("endTime")!!
                val duration = call.argument<Long>("duration")!!

                ffmpegCommander?.convertVideoToGif(path, startTime, endTime, duration, result,
                        reg.messenger())
            }
            else -> result.notImplemented()
        }
    }

    private fun initFfmpegCommanderIfNeeded() {
        if (ffmpegCommander == null) {
            ffmpegCommander = FFmpegCommander(reg.context(), channelName)
        }
    }
}


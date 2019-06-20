package com.example.flutter_video_compress

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import nl.bravobit.ffmpeg.ExecuteBinaryResponseHandler
import nl.bravobit.ffmpeg.FFmpeg
import nl.bravobit.ffmpeg.FFtask
import java.io.File

class FFmpegCommander(private val context: Context, private val channelName: String) {
    private var stopCommand = false
    private var ffTask: FFtask? = null
    private val utility = Utility(channelName)
    private var totalTime: Long = 0


    fun startCompress(path: String, quality: Int, deleteOrigin: Boolean,
                      result: MethodChannel.Result, messenger: BinaryMessenger) {
        val ffmpeg = FFmpeg.getInstance(context)

        if (!ffmpeg.isSupported) {
            return result.error(channelName, "FlutterVideoCompress Error",
                    "ffmpeg is supported this platform")
        }

        val dir = context.getExternalFilesDir("flutter_video_compress")

        if (dir != null && !dir.exists()) dir.mkdirs()

        val file = File(dir, path.substring(path.lastIndexOf("/")))
        utility.deleteFile(file)

        val cmd = if (quality > 0) {
            arrayOf("-i", path, "-vcodec", "h264", "-crf", "28", "-b:v", "1000k", "-acodec", "aac",
                    "-preset", "ultrafast",
                    "-vf", utility.getScaleByQuality(quality),
                    file.absolutePath)
        } else {
            arrayOf("-i", path, "-vcodec", "h264", "-crf", "28", "-b:v", "1000k", "-acodec", "aac",
                    "-preset", "ultrafast",
                    file.absolutePath)
        }

        this.ffTask = ffmpeg.execute(cmd, object : ExecuteBinaryResponseHandler() {
            override fun onProgress(message: String) {
                notifyProgress(message, messenger)

                if (stopCommand) {
                    print("FlutterVideoCompress: Video compression has stopped")
                    stopCommand = false
                    val json = utility.getMediaInfoJson(context, path)
                    json.put("isCancel", true)
                    result.success(json.toString())
                    totalTime = 0
                    ffTask?.killRunningProcess()
                }
            }

            override fun onFinish() {
                val json = utility.getMediaInfoJson(context, file.absolutePath)
                json.put("isCancel", false)
                result.success(json.toString())
                if (deleteOrigin) {
                    File(path).delete()
                }
                totalTime = 0
            }
        })
    }


    fun convertVideoToGif(path: String, startTime: Long = 0, endTime: Long, duration: Long,
                          result: MethodChannel.Result, messenger: BinaryMessenger) {
        var gifDuration = 0L
        if (endTime > 0) {
            if (startTime > endTime) {
                result.error(channelName, "FlutterVideoCompress Error",
                        "startTime should be greater than startTime")
            } else {
                gifDuration = (endTime - startTime)
            }
        } else {
            gifDuration = duration
        }

        val ffmpeg = FFmpeg.getInstance(context)

        if (!ffmpeg.isSupported) {
            return result.error(channelName, "FlutterVideoCompress Error",
                    "ffmpeg is not supported this platform")
        }

        val dir = context.getExternalFilesDir("flutter_video_compress")

        if (dir != null && !dir.exists()) dir.mkdirs()


        val file = File(dir, utility.getFileNameWithGifExtension(path))
        utility.deleteFile(file)

        val cmd = arrayOf("-i", path, "-ss", startTime.toString(), "-t", gifDuration.toString(),
                "-vf", "scale=640:-2", "-r", "15", file.absolutePath)

        this.ffTask = ffmpeg.execute(cmd, object : ExecuteBinaryResponseHandler() {
            override fun onProgress(message: String) {
                notifyProgress(message, messenger)
            }

            override fun onFinish() {
                result.success(file.absolutePath)
            }
        })
    }

    private fun notifyProgress(message: String, messenger: BinaryMessenger) {
        if ("Duration" in message) {
            val reg = Regex("""Duration: ((\d{2}:){2}\d{2}\.\d{2}).*""")
            val totalTimeStr = message.replace(reg, "$1")
            totalTime = utility.timeStrToTimestamp(totalTimeStr.trim())
        }

        if ("frame=" in message) {
            try {
                val reg = Regex("""frame.*time=((\d{2}:){2}\d{2}\.\d{2}).*""")
                val totalTimeStr = message.replace(reg, "$1")
                val time = utility.timeStrToTimestamp(totalTimeStr.trim())
                MethodChannel(messenger, channelName)
                        .invokeMethod("updateProgress", ((time / totalTime) * 100).toString())
            } catch (e: Exception) {
                print(e.stackTrace)
            }
        }

        MethodChannel(messenger, channelName).invokeMethod("updateProgress", message)
    }

    fun stopCompress() {
        if (ffTask != null && !ffTask!!.isProcessCompleted) {
            stopCommand = true
        }
    }
}
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



    fun compressVideo(path: String, quality: VideoQuality, deleteOrigin: Boolean,
                      startTime: Int?, duration: Int? = null, includeAudio: Boolean?,
                      frameRate: Int?, result: MethodChannel.Result,
                      messenger: BinaryMessenger) {

        val ffmpeg = FFmpeg.getInstance(context)

        if (!ffmpeg.isSupported) {
            return result.error(channelName, "FlutterVideoCompress Error",
                    "ffmpeg isn't supported this platform")
        }

        val dir = context.getExternalFilesDir("flutter_video_compress")

        if (dir != null && !dir.exists()) dir.mkdirs()

        val file = File(dir, path.substring(path.lastIndexOf("/")))
        utility.deleteFile(file)

        val cmdArray = mutableListOf("-i", path, "-vcodec", "h264", "-crf", "28", "-movflags", "use_metadata_tags")
//        if (quality.notDefault()) {
            val mediaInfoJson = utility.getMediaInfoJson(context, path)
            val orientation = mediaInfoJson.getInt("orientation")

            cmdArray.add("-vf")
            val scale = quality.getScaleString()
            if (utility.isLandscapeImage(orientation)) {
                cmdArray.add("scale=$scale:-2")
            } else {
                cmdArray.add("scale=-2:$scale")
            }
//        }

        // Add high bitrate for the highest quality
//        if (quality.isHighQuality()) {
            cmdArray.addAll(listOf("-preset", "ultrafast", "-b:v", "1000k"))
//        }

        if (startTime != null) {
            cmdArray.add("-ss")
            cmdArray.add(startTime.toString())

            if (duration != null) {
                cmdArray.add("-t")
                cmdArray.add(duration.toString())
            }
        }

        if (includeAudio != null && !includeAudio) {
            cmdArray.add("-an")
        }

        if (frameRate != null) {
            cmdArray.add("-r")
            cmdArray.add(frameRate.toString())
        }

        cmdArray.add(file.absolutePath)

        this.ffTask = ffmpeg.execute(cmdArray.toTypedArray(),
                object : ExecuteBinaryResponseHandler() {
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

    private fun isLandscapeImage(orientation: Int) = orientation != 90 && orientation != 270


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

    fun cancelCompression() {
        if (ffTask != null && !ffTask!!.isProcessCompleted) {
            stopCommand = true
        }
    }
}
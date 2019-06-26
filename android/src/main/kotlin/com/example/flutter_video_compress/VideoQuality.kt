package com.example.flutter_video_compress

enum class VideoQuality(val value : Int) {
    DefaultQuality(0),
    LowQuality(1),
    MediumQuality(2),
    HighestQuality(3);

    companion object {
        fun from(findValue: Int): VideoQuality = values().first { it.value == findValue }
    }

    fun getScaleString(): String = when (this) {
        DefaultQuality, LowQuality -> "192"
        MediumQuality -> "480"
        HighestQuality -> "1280"
    }

    fun notDefault(): Boolean = this != DefaultQuality

    fun isHighQuality(): Boolean = this == HighestQuality
}
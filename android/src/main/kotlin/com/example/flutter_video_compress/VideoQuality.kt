package com.example.flutter_video_compress

enum class VideoQuality(val value : Int) {
    DEFAULT_QUALITY(-1),
    RES_128(0),
    RES_320(1),
    RES_360(2),
    RES_640(3),
    RES_1080(4);

    companion object {
        fun from(findValue: Int): VideoQuality = values().first { it.value == findValue }
    }

    fun getScaleString(): String = when (this) {
        RES_128 -> "128"
        RES_320 -> "320"
        RES_640 -> "640"
        RES_1080 -> "1080"
        else -> "320"
    }

    fun notDefault(): Boolean = this != DEFAULT_QUALITY

    fun isHighQuality(): Boolean = this == RES_1080
}
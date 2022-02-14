#!/usr/local/bin/liquidsoap

set("log.stdout",true)
set("log.level",3)

# Harbor HTTP server settings
set("harbor.bind_addr","0.0.0.0")

# Audio settings

set("frame.audio.samplerate",44100)
set("frame.audio.channels",2)
set("audio.converter.samplerate.libsamplerate.quality","fast")

# Define Input
safe_blank = blank(id="safe_blank")

live = input.harbor("live",
                    port=8000,
                    user="source",
                    password=getenv("SOURCE_PASSWORD"))

source = fallback(id="fallback_prod",
                    track_sensitive=false,
                    [live, safe_blank])

# Define Output

aac_lofi = %ffmpeg(format="mpegts",
                    codec="aac",
                    channels=2,
                    ar=44100,
                    b="32k")

aac_midfi = %ffmpeg(format="mpegts",
                    codec="aac",
                    channels=2,
                    ar=44100,
                    b="96k")

aac_hifi = %ffmpeg(format="mpegts",
                    codec="aac",
                    channels=2,
                    ar=44100,
                    b="192k")

streams_info = [("aac_lofi",(40000,"mp4a.40.29","ts")),
                ("aac_midfi",(110000,"mp4a.40.2","ts")),
                ("aac_hifi",(220000,"mp4a.40.2","ts"))]
                
streams = [("aac_lofi",aac_lofi), 
            ("aac_midfi", aac_midfi), 
            ("aac_hifi", aac_hifi)]
                
def segment_name(~position,~extname,stream_name) =
    timestamp = int_of_float(gettimeofday())
    duration = 2
    "#{stream_name}_#{duration}_#{timestamp}_#{position}.#{extname}"
end             

output.file.hls(playlist="live.m3u8",
                segment_duration=2.0,
                segments=5,
                segments_overhead=5,
                segment_name=segment_name,
                streams_info=streams_info,
                persist=true,
                persist_at="/usr/share/liquidsoap/state.config",
                "/hls",
                streams,
                source)
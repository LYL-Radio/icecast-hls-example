settings.log.stdout := true
settings.log.level := 3

# Harbor HTTP server settings
settings.harbor.bind_addrs := ["0.0.0.0"]

# Audio settings
settings.frame.audio.channels := 2
settings.frame.audio.samplerate := 44100
settings.audio.converter.samplerate.libsamplerate.quality := "fast"

# Define Input
safe_blank = blank(id="safe_blank")

live = input.harbor("live", port=8000, user="source", password="hackme")

source = fallback(id="fallback_prod", track_sensitive=false, [live, safe_blank])

# Define Output

aac_lofi =
  %ffmpeg(format = "mpegts", %audio(codec = "aac", channels = 2, ar = 44100))

aac_midfi =
  %ffmpeg(
    format = "mpegts",
    %audio(codec = "aac", channels = 2, ar = 44100, b = "96k")
  )

aac_hifi =
  %ffmpeg(
    format = "mpegts",
    %audio(codec = "aac", channels = 2, ar = 44100, b = "192k")
  )

streams =
  [("aac_lofi", aac_lofi), ("aac_midfi", aac_midfi), ("aac_hifi", aac_hifi)]

def segment_name(~position, ~extname, stream_name) =
  timestamp = int_of_float(time())
  duration = 2
  "#{stream_name}_#{duration}_#{timestamp}_#{position}.#{extname}"
end

output.file.hls(
  playlist="live.m3u8",
  segment_duration=2.0,
  segments=5,
  segments_overhead=5,
  segment_name=segment_name,
  perm=422,
  dir_perm=0o755,
  persist_at="/usr/share/liquidsoap/state.config",
  "/tmp/hls",
  streams,
  source
)

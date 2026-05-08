extends AudioStreamPlayer
class_name Soundtrack

@onready var playback: AudioStreamPlaybackInteractive = self.get_stream_playback()

enum Track {Layer1, Layer2, Layer3}

func set_track(track: Track) -> void:
    playback.switch_to_clip_by_name(Track.find_key(track))

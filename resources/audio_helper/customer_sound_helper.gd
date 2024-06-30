@static_unload
class_name CustomerSoundHelper
extends Object

const PITCH_PATH_DIC := {
	Customer.Pitch.LOWEST : "pitch_lowest/",
	Customer.Pitch.LOW : "pitch_low/",
	Customer.Pitch.NORMAL : "pitch_normal/",
	Customer.Pitch.HIGH : "pitch_high/"
}

const SOUND_TYPE_PATH := {
	Customer.SoundType.ANGRY : "res://audio/customer/angry/",
	Customer.SoundType.HAPPY : "res://audio/customer/happy/",
	Customer.SoundType.SATISFIED : "res://audio/customer/satisfied/",
	Customer.SoundType.WAIT: "res://audio/customer/wait/"
}

static func get_sound_stream_path(sound_type: Customer.SoundType, pitch: Customer.Pitch) -> String:
	return get_sound_stream_dir(sound_type, pitch) + get_sound_stream_name(sound_type, pitch)
	

static func get_sound_stream_dir(sound_type: Customer.SoundType, pitch: Customer.Pitch) -> String:
	return SOUND_TYPE_PATH[sound_type]
	

static func get_sound_stream_name(sound_type: Customer.SoundType, pitch: Customer.Pitch) -> String:
	var dir = SOUND_TYPE_PATH[sound_type]
	var pitch_path = PITCH_PATH_DIC[pitch]
	return dir.get_slice("/", dir.count("/")-1) + "-" + pitch_path.substr(0, pitch_path.length() - 1) + ".tres"
	


class AnimaleseHelper:
	const SAVE_FILE_DIRECTORY := "res://audio/customer/animalese/phrases/"
	const SAVE_FILE_NAME_PREFIX := "phrase-"
	const SAVE_FILE_SUFFIX := ".tres"
	
	const INFO_FILE_PATH := "res://audio/customer/animalese/animalese_info.tres"
	
	static func get_playlist_path(pitch: Customer.Pitch, index: int) -> String:
		return get_playlist_dir(pitch) + get_playlist_name(index)
		
	
	static func get_playlist_dir(pitch: Customer.Pitch) -> String:
		return SAVE_FILE_DIRECTORY + PITCH_PATH_DIC[pitch]
		
	
	static func get_playlist_name(index: int) -> String:
		return SAVE_FILE_NAME_PREFIX + str(index) + SAVE_FILE_SUFFIX

@static_unload
class_name CustomerVoiceProvider
extends Object

static var animalese_info :
	get():
		if animalese_info == null:
			animalese_info = load(CustomerSoundHelper.AnimaleseHelper.INFO_FILE_PATH)
		return animalese_info


static func get_random_pitch() -> Customer.Pitch:
	return Customer.Pitch.values().pick_random()
	

static func get_random_phrase() -> AudioStreamPlaylist:
	return get_random_phrase_by_pitch(get_random_pitch())
	

static func get_random_phrase_by_pitch(pitch: Customer.Pitch) -> AudioStreamPlaylist:
	var num := randi_range(0, animalese_info.phrases_per_pitch[pitch])
	var path: String = CustomerSoundHelper.AnimaleseHelper.get_playlist_path(pitch, num)
	return load(path)
	

static func get_voice_dic(pitch: Customer.Pitch) -> Dictionary:
	var dic = {}
	for sound_type in Customer.SoundType.values():
		if sound_type == Customer.SoundType.SPEAK: continue
		dic[sound_type] = load(CustomerSoundHelper.get_sound_stream_path(sound_type, pitch))
		
	return dic

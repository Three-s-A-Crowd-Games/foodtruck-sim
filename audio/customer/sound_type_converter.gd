@tool
@static_unload
class_name SoundTypeConverter
extends EditorScript

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	parse_mp3s_to_rng_stream()

static func parse_mp3s_to_rng_stream() -> void:
	for pitch: Customer.Pitch in CustomerSoundHelper.PITCH_PATH_DIC.keys():
		for sound_type: Customer.SoundType in CustomerSoundHelper.SOUND_TYPE_PATH.keys():
			var dir := get_resource_dir(sound_type, pitch)
			var file_names := DirAccess.get_files_at(dir)
			var error := DirAccess.get_open_error()
			if error != OK:
				print_rich("[color=red]Failde to open dir: ", dir, ". Error code: ", error, "[/color]")
				continue
			var rng_stream := AudioStreamRandomizer.new()
			var count = 0
			for i: int in file_names.size():
				if not file_names[i].ends_with(".mp3"):
					continue
				var mp3: AudioStreamMP3 = load(dir + file_names[i])
				rng_stream.add_stream(count, mp3)
				count += 1
			var file_path := CustomerSoundHelper.get_sound_stream_path(sound_type, pitch)
			print("added ", count, " streams for ", file_path)
			error = ResourceSaver.save(rng_stream, file_path)
			if error == OK:
				print_rich("[color=green]Successfully saved ", file_path, "[/color]")
			else:
				print_rich("[color=red]Failde to save file: ", file_path, ". Error code: ", error, "[/color]")
	

static func get_resource_dir(sound_type: Customer.SoundType, pitch: Customer.Pitch) -> String:
	return CustomerSoundHelper.SOUND_TYPE_PATH[sound_type] + CustomerSoundHelper.PITCH_PATH_DIC[pitch]

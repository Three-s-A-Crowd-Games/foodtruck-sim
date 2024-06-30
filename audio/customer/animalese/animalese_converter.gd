@tool
@static_unload
class_name AnimaleseConverter
extends EditorScript

const INPUT_FILE_PATH := "res://audio/customer/animalese/input_files/conversations.txt"
const INPUT_FILE_TYPE := ".txt"

const AUDIO_FILE_DIRECTORY := "res://audio/customer/animalese/audio_files/"
const AUDIO_FILE_PRESUFFIX := "-Letter"
const AUDIO_FILE_SUFFIX := ".mp3"

const S := 115
const H := 104
const SPACE := 32
const IGNORE_CHARACTERS: Array[String] = ["'"]
static var ignore_characters_as_int = IGNORE_CHARACTERS.map(func(x:String): return x.to_utf8_buffer()[0])

const SORT_FILES_BY_CHARACTER_AMOUNT := true

static var phrase_input_sizes: Array
static var phrase_output_sizes: Array
static var phrases_saved: int = 0
static var animalese_info: AnimaleseInfo = AnimaleseInfo.new()

func _run() -> void:
	translate_input_file_into_all_pitches()
	
	print("phrase_input_sizes","\n",phrase_input_sizes)
	prints("Maximum input size =", phrase_input_sizes.max())
	prints("Minimum input size =", phrase_input_sizes.min())
	print("phrase_output_sizes","\n",phrase_output_sizes)
	prints("Maximum output size =", phrase_output_sizes.max())
	prints("Minimum output size =", phrase_output_sizes.min())
	

static func translate_input_file_into_all_pitches() -> void:
	for pitch: Customer.Pitch in CustomerSoundHelper.PITCH_PATH_DIC.keys():
		translate_input_file(INPUT_FILE_PATH, pitch)
		animalese_info.phrases_per_pitch[pitch] = phrases_saved
		phrases_saved = 0
	var error := ResourceSaver.save(animalese_info, CustomerSoundHelper.AnimaleseHelper.INFO_FILE_PATH)
	if error != OK:
		print_rich("[color=red]Failed to save animalese info resource. Error code: ", error, "[/color]")
	else:
		phrases_saved += 1
		print_rich("[color=green]Successfully saved animalese info resource[/color]")
	

static func translate_input_file(file_path: String, pitch: Customer.Pitch) -> void:
	if not file_path.ends_with(INPUT_FILE_TYPE):
		print_rich("[color=yellow]Refuse to load file ", file_path, " because it doesn't conform to the required file ending: ", INPUT_FILE_TYPE, "[/color]")
	var text = load_text(file_path)
	if not text or text.is_empty():
		print_rich("[color=red]Abort translation. Input String is empty.")
		return
	var data := parse_text_to_file_paths(text, pitch)
	var lists := create_all_playlists(data)
	save_playlists(pitch, lists)
	

static func load_text(file_path: String) -> String:
	var file_access := FileAccess.open(file_path, FileAccess.READ)
	var error := FileAccess.get_open_error()
	if error != OK:
		print_rich("[color=red]Failed to open file ", file_path, ". Error code: ", error)
		return ""
	var content = file_access.get_as_text()
	return content
	

static func parse_text_to_file_paths(text: String, pitch: Customer.Pitch) -> Array[PackedStringArray]:
	text = text.to_lower()
	var phrases := text.split("\n")
	#ignore last input because .txt seem to always have an empty line at the end 
	if phrases[-1].is_empty():
		print_rich("[color=yellow]ignoring last input line because it's empty[/color]")
		phrases.resize(phrases.size()-1)
	print(phrases.size(), " input phrases")
	
	var data: Array[PackedStringArray]
	data.resize(phrases.size())
	for i: int in phrases.size():
		var chars := phrases[i].to_utf8_buffer()
		if not chars or chars.size() == 0:
			continue
		phrase_input_sizes.append(chars.size())
		for j: int in chars.size():
			var path: String = get_audio_file_dir(pitch)
			#skip double characters
			if j > 1 and chars[j] == chars[j-1]:
				continue
			#normal letters
			elif chars[j] > 96 and chars[j] < 123:
				#detect sh
				if j < chars.size()-1 and chars[j] == S and chars[j+1] == H:
					path += "27-Letter"
				elif j > 0 and chars[j] == H and chars[j-1] == S:
					continue
				else:
					var num := str(chars[j] - 96)
					if num.length() == 1: num = "0"+num
					path += num + AUDIO_FILE_PRESUFFIX
			#don't add pauses add the beginning or end
			elif j==0 or j==chars.size()-1:
				continue
			#space charachters
			elif chars[j] == SPACE:
				path = AUDIO_FILE_DIRECTORY + "29-space"
			#everything else is interpreted as a pause
			else:
				path = AUDIO_FILE_DIRECTORY + "30-break"
			data[i].append(path + AUDIO_FILE_SUFFIX)
	return data
	

static func create_all_playlists(data: Array[PackedStringArray]) -> Array[AudioStreamPlaylist]:
	var all_playlists: Array[AudioStreamPlaylist]
	for paths: PackedStringArray in data:
		if not paths or paths.size() == 0:
			continue
		all_playlists.append(create_playlist(paths))
	return all_playlists
	

static func create_playlist(file_paths: PackedStringArray) -> AudioStreamPlaylist:
	var list := AudioStreamPlaylist.new()
	list.stream_count = min(file_paths.size(), AudioStreamPlaylist.MAX_STREAMS)
	phrase_output_sizes.append(list.stream_count)
	for i: int in list.stream_count:
		var stream = load(file_paths[i])
		list.set_list_stream(i, stream)
	list.loop = false
	list.fade_time = 0
	return list
	

static func save_playlists(pitch: Customer.Pitch, lists: Array[AudioStreamPlaylist]) -> void:
	if SORT_FILES_BY_CHARACTER_AMOUNT:
		lists.sort_custom(func(a,b): return a.stream_count < b.stream_count)
	var directory := CustomerSoundHelper.AnimaleseHelper.get_playlist_dir(pitch)
	if DirAccess.dir_exists_absolute(directory):
		DirAccess.remove_absolute(directory)
	DirAccess.make_dir_recursive_absolute(directory)
	for i: int in lists.size():
		var file_name := CustomerSoundHelper.AnimaleseHelper.get_playlist_path(pitch, i)
		var error := ResourceSaver.save(lists[i], file_name)
		if error != OK:
			print_rich("[color=red]Failed to save: ", lists[i], " as ", file_name, ". Error code: ", error, "[/color]")
		else:
			phrases_saved += 1
			print_rich("[color=green]Successfully saved", file_name, "[/color]")
	

static func get_audio_file_dir(pitch: Customer.Pitch) -> String:
	return AUDIO_FILE_DIRECTORY + CustomerSoundHelper.PITCH_PATH_DIC[pitch]
	

static func dummy_test() -> void:
	var list := AudioStreamPlaylist.new()
	var stream = load("res://audio/edited/01-Letter.wav")
	list.stream_count = 1
	print(stream is AudioStreamWAV)
	list.set_list_stream(0, stream)
	print(list.get_list_stream(0))
	ResourceSaver.save(list, "res://audio/phrase-x.tres")
	

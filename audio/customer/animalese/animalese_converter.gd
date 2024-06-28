@tool
extends EditorScript
#extends Node

const TEXT_FILE_PATH := "res://audio/customer/animalese/animalese_input3.txt"

const FILE_PREFIX := "res://audio/customer/animalese/audio_files/"
const FILE_PRESUFFIX := "-Letter"
const FILE_SUFFIX := ".wav"

const SAVE_FILE_PREFIX := "res://audio/customer/animalese/phrases/phrase-"
const SAVE_FILE_SUFFIX := ".tres"

const S := 115
const H := 104
const SPACE := 32

var phrase_input_sizes: Array
var phrase_output_sizes: Array

func _run() -> void:
	translate_text_to_animalese()
	print("phrase_input_sizes","\n",phrase_input_sizes)
	prints("Maximum input size =", phrase_input_sizes.max())
	prints("Minimum input size =", phrase_input_sizes.min())
	print("phrase_output_sizes","\n",phrase_output_sizes)
	prints("Maximum output size =", phrase_output_sizes.max())
	prints("Minimum output size =", phrase_output_sizes.min())

func translate_text_to_animalese() -> void:
	print("parsing file: ", TEXT_FILE_PATH)
	var text = load_text()
	var data = parse_text(text)
	var lists = create_all_playlists(data)
	save_playlists(lists)

func load_text() -> String:
	var file = FileAccess.open(TEXT_FILE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	return content

func parse_text(text: String) -> Array[PackedStringArray]:
	text = text.to_lower()
	var phrases := text.split("\n")
	#ignore last input because .txt seem to always have an empty line at the end 
	if phrases[-1].is_empty():
		print("ignoring last input line because it's empty")
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
			var path := FILE_PREFIX
			#skip double characters
			if j > 1 and chars[j] == chars[j-1]:
				continue
			#detect sh
			elif j < chars.size()-1 and chars[j] == S and chars[j+1]:
				path += "27-Letter"
				j += 1
			#normal letters
			elif chars[j] > 96 and chars[j] < 123:
				var num := str(chars[j] - 96)
				if num.length() == 1: num = "0"+num
				path += num + FILE_PRESUFFIX
			#space charachters
			elif chars[j] == SPACE:
				path += "29-space"
			#everything else is interpreted as a pause
			else:
				if j==0 or j==chars.size()-1:
					continue
				path += "30-break"
			data[i].append(path + FILE_SUFFIX)
	return data

func create_all_playlists(data: Array[PackedStringArray]) -> Array[AudioStreamPlaylist]:
	var all_playlists: Array[AudioStreamPlaylist]
	for paths: PackedStringArray in data:
		if not paths or paths.size() == 0:
			continue
		all_playlists.append(create_playlist(paths))
	return all_playlists

func create_playlist(file_paths: PackedStringArray) -> AudioStreamPlaylist:
	var list := AudioStreamPlaylist.new()
	list.stream_count = min(file_paths.size(), AudioStreamPlaylist.MAX_STREAMS)
	phrase_output_sizes.append(list.stream_count)
	for i: int in list.stream_count:
		var stream = load(file_paths[i])
		list.set_list_stream(i, stream)
	list.loop = false
	list.fade_time = 0
	return list

func save_playlists(lists: Array[AudioStreamPlaylist]) -> bool:
	var success = true
	for i: int in lists.size():
		var file_name := SAVE_FILE_PREFIX+str(i)+SAVE_FILE_SUFFIX
		var fail := bool(ResourceSaver.save(lists[i], file_name))
		if fail:
			prints("failed to save:", lists[i], "as", file_name)
			success = false
		else:
			prints("successfully saved", file_name)
		
	return success

func dummy_test() -> void:
	var list := AudioStreamPlaylist.new()
	var stream = load("res://audio/edited/01-Letter.wav")
	list.stream_count = 1
	print(stream is AudioStreamWAV)
	list.set_list_stream(0, stream)
	print(list.get_list_stream(0))
	ResourceSaver.save(list, "res://audio/phrase-x.tres")

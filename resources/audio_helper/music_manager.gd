@static_unload
class_name MusicManager
extends Object

enum MusicGenre{
	JAZZ,
	LATIN,
	ROCK_SOFT,
	ROCK_HARD,
	UNCLASSIFIED
}

const GENRE_PATH_DIC = {
	MusicGenre.JAZZ : "res://audio/music/jazz/",
	MusicGenre.LATIN : "res://audio/music/latin/",
	MusicGenre.ROCK_SOFT : "res://audio/music/rock_soft/",
	MusicGenre.ROCK_HARD : "res://audio/music/rock_hard/",
	MusicGenre.UNCLASSIFIED : "res://audio/music/unclassifie/d"
}

const PLAYLIST_SAVE_PATH := "res://audio/music/playlist.tres"

static var selected_genres: Array[MusicGenre] = [MusicGenre.JAZZ]


static func create_playlist() -> void:
	var playlist := AudioStreamRandomizer.new()
	var count: int = 0
	for genre: MusicGenre in selected_genres:
		if not DirAccess.dir_exists_absolute(GENRE_PATH_DIC[genre]):
			push_warning("Specified directory '", GENRE_PATH_DIC[genre], "' does not exist. Please check the specified path.")
			continue
		var file_names = DirAccess.get_files_at(GENRE_PATH_DIC[genre])
		var err := DirAccess.get_open_error()
		if err != OK:
			push_error("Can't to open directory: ", GENRE_PATH_DIC[genre], ". Failed with error code: ", err, ".")
			return
		if file_names.size() == 0:
			push_warning("Tryed to add songs of the genre '", MusicGenre.keys()[genre],"' to the playlist. But no files were available at the given target directory: ", GENRE_PATH_DIC[genre], ".")
			continue
		for name: String in file_names:
			if not name.ends_with(".mp3"): continue
			playlist.add_stream(count, load(GENRE_PATH_DIC[genre] + name))
			count += 1
	
	var err := ResourceSaver.save(playlist, PLAYLIST_SAVE_PATH)
	if err != OK:
		push_error("Can't save playlist as: ", PLAYLIST_SAVE_PATH, ". Failed with error code: ", err, ".")

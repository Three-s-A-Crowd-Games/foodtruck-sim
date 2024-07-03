extends VBoxContainer

enum MusciGenres{
	JAZZ,
	LATIN,
	ROCK_SOFT,
	ROCK_HARD,
	UNCLASSIFIED
}

static var selected_genres: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	var id_main = AudioServer.get_bus_index("Master")
	var id_sfx = AudioServer.get_bus_index("SFX")
	var id_ambience = AudioServer.get_bus_index("Ambience")
	var id_music = AudioServer.get_bus_index("Music")
	var id_dialog = AudioServer.get_bus_index("Voicelines")
	
#region Volume
	$"categories/sound-volume/sound-volume/slider/main-volume/main-volume/hbox/HScrollBar".value_changed.connect(
		func(x):
			AudioServer.set_bus_volume_db(id_main, linear_to_db(x))
	)
	$"categories/sound-volume/sound-volume/slider/sfx-volume/sfx-volume/hbox/HScrollBar".value_changed.connect(
		func(x):
			AudioServer.set_bus_volume_db(id_sfx, linear_to_db(x))
	)
	$"categories/sound-volume/sound-volume/slider/ambience-volume/ambience-volume/hbox/HScrollBar".value_changed.connect(
		func(x):
			AudioServer.set_bus_volume_db(id_ambience, linear_to_db(x))
	)
	$"categories/sound-volume/sound-volume/slider/music-volume/music-volume/hbox/HScrollBar".value_changed.connect(
		func(x):
			AudioServer.set_bus_volume_db(id_music, linear_to_db(x))
	)
	$"categories/sound-volume/sound-volume/slider/dialogue-volume/dialogue-volume/hbox/HScrollBar".value_changed.connect(
		func(x):
			AudioServer.set_bus_volume_db(id_dialog, linear_to_db(x))
	)
#endregion
	
#region Genres
	$"categories/music-genre/music-genre/checkboxes/jazz-check".toggled.connect(
		func(x):
			if x: selected_genres.append(MusciGenres.JAZZ)
			else: selected_genres.erase(MusciGenres.JAZZ)
	)
	$"categories/music-genre/music-genre/checkboxes/latin-check".toggled.connect(
		func(x):
			if x: selected_genres.append(MusciGenres.LATIN)
			else: selected_genres.erase(MusciGenres.LATIN)
	)
	$"categories/music-genre/music-genre/checkboxes/rock-soft-check".toggled.connect(
		func(x):
			if x: selected_genres.append(MusciGenres.ROCK_SOFT)
			else: selected_genres.erase(MusciGenres.ROCK_SOFT)
	)
	$"categories/music-genre/music-genre/checkboxes/rock-hard-check".toggled.connect(
		func(x):
			if x: selected_genres.append(MusciGenres.ROCK_HARD)
			else: selected_genres.erase(MusciGenres.ROCK_HARD)
	)
	$"categories/music-genre/music-genre/checkboxes/unclassified-check".toggled.connect(
		func(x):
			if x: selected_genres.append(MusciGenres.UNCLASSIFIED)
			else: selected_genres.erase(MusciGenres.UNCLASSIFIED)
	)
#endregion
	
#region Radio Effect
	$"categories/music-genre/music-genre/checkbuttons/HBoxContainer/vintage-effect-button".toggled.connect(
		func(x):
			AudioServer.set_bus_effect_enabled(id_music, 0, x)
	)
#endregion
	

extends MenuBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var id_main = AudioServer.get_bus_index("Master")
	var id_sfx = AudioServer.get_bus_index("SFX")
	var id_ambience = AudioServer.get_bus_index("Ambience")
	var id_music = AudioServer.get_bus_index("Music")
	var id_dialog = AudioServer.get_bus_index("Voicelines")
	
#region Volume
	
	$"options-menu/categories/sound-volume/sound-volume/slider/main-volume/main-volume/hbox/HScrollBar".value = db_to_linear(AudioServer.get_bus_volume_db(id_main))
	$"options-menu/categories/sound-volume/sound-volume/slider/main-volume/main-volume/hbox/HScrollBar".value_changed.connect(
		func(x):
			AudioServer.set_bus_volume_db(id_main, linear_to_db(x))
	)
	$"options-menu/categories/sound-volume/sound-volume/slider/sfx-volume/sfx-volume/hbox/HScrollBar".value = db_to_linear(AudioServer.get_bus_volume_db(id_sfx))
	$"options-menu/categories/sound-volume/sound-volume/slider/sfx-volume/sfx-volume/hbox/HScrollBar".value_changed.connect(
		func(x):
			AudioServer.set_bus_volume_db(id_sfx, linear_to_db(x))
	)
	$"options-menu/categories/sound-volume/sound-volume/slider/ambience-volume/ambience-volume/hbox/HScrollBar".value = db_to_linear(AudioServer.get_bus_volume_db(id_ambience))
	$"options-menu/categories/sound-volume/sound-volume/slider/ambience-volume/ambience-volume/hbox/HScrollBar".value_changed.connect(
		func(x):
			AudioServer.set_bus_volume_db(id_ambience, linear_to_db(x))
	)
	$"options-menu/categories/sound-volume/sound-volume/slider/music-volume/music-volume/hbox/HScrollBar".value = db_to_linear(AudioServer.get_bus_volume_db(id_music))
	$"options-menu/categories/sound-volume/sound-volume/slider/music-volume/music-volume/hbox/HScrollBar".value_changed.connect(
		func(x):
			AudioServer.set_bus_volume_db(id_music, linear_to_db(x))
	)
	$"options-menu/categories/sound-volume/sound-volume/slider/dialogue-volume/dialogue-volume/hbox/HScrollBar".value = db_to_linear(AudioServer.get_bus_volume_db(id_dialog))
	$"options-menu/categories/sound-volume/sound-volume/slider/dialogue-volume/dialogue-volume/hbox/HScrollBar".value_changed.connect(
		func(x):
			AudioServer.set_bus_volume_db(id_dialog, linear_to_db(x))
	)
#endregion
	
#region Genres
	$"options-menu/categories/music-genre/music-genre/checkboxes/jazz-check".button_pressed = MusicManager.selected_genres.has(MusicManager.MusicGenre.JAZZ)
	$"options-menu/categories/music-genre/music-genre/checkboxes/jazz-check".toggled.connect(
		func(x):
			if x: MusicManager.selected_genres.append(MusicManager.MusicGenre.JAZZ)
			else: MusicManager.selected_genres.erase(MusicManager.MusicGenre.JAZZ)
	)
	$"options-menu/categories/music-genre/music-genre/checkboxes/latin-check".button_pressed = MusicManager.selected_genres.has(MusicManager.MusicGenre.LATIN)
	$"options-menu/categories/music-genre/music-genre/checkboxes/latin-check".toggled.connect(
		func(x):
			if x: MusicManager.selected_genres.append(MusicManager.MusicGenre.LATIN)
			else: MusicManager.selected_genres.erase(MusicManager.MusicGenre.LATIN)
	)
	$"options-menu/categories/music-genre/music-genre/checkboxes/rock-soft-check".button_pressed = MusicManager.selected_genres.has(MusicManager.MusicGenre.ROCK_SOFT)
	$"options-menu/categories/music-genre/music-genre/checkboxes/rock-soft-check".toggled.connect(
		func(x):
			if x: MusicManager.selected_genres.append(MusicManager.MusicGenre.ROCK_SOFT)
			else: MusicManager.selected_genres.erase(MusicManager.MusicGenre.ROCK_SOFT)
	)
	$"options-menu/categories/music-genre/music-genre/checkboxes/rock-hard-check".button_pressed = MusicManager.selected_genres.has(MusicManager.MusicGenre.ROCK_HARD)
	$"options-menu/categories/music-genre/music-genre/checkboxes/rock-hard-check".toggled.connect(
		func(x):
			if x: MusicManager.selected_genres.append(MusicManager.MusicGenre.ROCK_HARD)
			else: MusicManager.selected_genres.erase(MusicManager.MusicGenre.ROCK_HARD)
	)
	$"options-menu/categories/music-genre/music-genre/checkboxes/unclassified-check".button_pressed = MusicManager.selected_genres.has(MusicManager.MusicGenre.UNCLASSIFIED)
	$"options-menu/categories/music-genre/music-genre/checkboxes/unclassified-check".toggled.connect(
		func(x):
			if x: MusicManager.selected_genres.append(MusicManager.MusicGenre.UNCLASSIFIED)
			else: MusicManager.selected_genres.erase(MusicManager.MusicGenre.UNCLASSIFIED)
	)
#endregion
	
#region Radio Effect
	$"options-menu/categories/music-genre/music-genre/checkbuttons/HBoxContainer/vintage-effect-button".button_pressed = AudioServer.is_bus_effect_enabled(id_music, 0)
	$"options-menu/categories/music-genre/music-genre/checkbuttons/HBoxContainer/vintage-effect-button".toggled.connect(
		func(x):
			AudioServer.set_bus_effect_enabled(id_music, 0, x)
	)
#endregion
	
#region Back Button
	$"options-menu/back-button".pressed.connect(scene_switch_requested.emit.bind(MainMenuStage.SceneType.MAIN))
#endregion
	

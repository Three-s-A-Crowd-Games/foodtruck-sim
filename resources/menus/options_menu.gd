extends MenuBase

const SLIDER_SOUND: AudioStream = preload("res://audio/sfx/menu/scroll_002.mp3")
const CHECKBOX_ON_SOUND: AudioStream = preload("res://audio/sfx/menu/checkbox_on.mp3")
const CHECKBOX_OFF_SOUND: AudioStream = preload("res://audio/sfx/menu/checkbox_off.mp3")
const SWITCH_ON_SOUND: AudioStream = preload("res://audio/sfx/menu/switch_on.mp3")
const SWITCH_OFF_SOUND: AudioStream = preload("res://audio/sfx/menu/switch_off.mp3")

@onready var id_main = AudioServer.get_bus_index(&"Master")
@onready var id_sfx = AudioServer.get_bus_index(&"SFX")
@onready var id_ambience = AudioServer.get_bus_index(&"Ambience")
@onready var id_music = AudioServer.get_bus_index(&"Music")
@onready var id_dialog = AudioServer.get_bus_index(&"Voicelines")

func _on_volume_slider_value_changed(value: float, bus_idx: int) -> void:
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	sfx_player.stream = SLIDER_SOUND
	sfx_player.play()
	

func _on_music_genre_check_box_toggled(value: bool, genre: MusicManager.MusicGenre) -> void:
	if value:
		MusicManager.selected_genres.append(genre)
		sfx_player.stream = CHECKBOX_ON_SOUND
	else:
		MusicManager.selected_genres.erase(genre)
		sfx_player.stream = CHECKBOX_OFF_SOUND
	sfx_player.play()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#region Volume
	$"options-menu/categories/sound-volume/sound-volume/slider/main-volume/main-volume/hbox/HScrollBar".value = db_to_linear(AudioServer.get_bus_volume_db(id_main))
	$"options-menu/categories/sound-volume/sound-volume/slider/main-volume/main-volume/hbox/HScrollBar".value_changed.connect(_on_volume_slider_value_changed.bind(id_main))
	$"options-menu/categories/sound-volume/sound-volume/slider/sfx-volume/sfx-volume/hbox/HScrollBar".value = db_to_linear(AudioServer.get_bus_volume_db(id_sfx))
	$"options-menu/categories/sound-volume/sound-volume/slider/sfx-volume/sfx-volume/hbox/HScrollBar".value_changed.connect(_on_volume_slider_value_changed.bind(id_sfx))
	$"options-menu/categories/sound-volume/sound-volume/slider/ambience-volume/ambience-volume/hbox/HScrollBar".value = db_to_linear(AudioServer.get_bus_volume_db(id_ambience))
	$"options-menu/categories/sound-volume/sound-volume/slider/ambience-volume/ambience-volume/hbox/HScrollBar".value_changed.connect(_on_volume_slider_value_changed.bind(id_ambience))
	$"options-menu/categories/sound-volume/sound-volume/slider/music-volume/music-volume/hbox/HScrollBar".value = db_to_linear(AudioServer.get_bus_volume_db(id_music))
	$"options-menu/categories/sound-volume/sound-volume/slider/music-volume/music-volume/hbox/HScrollBar".value_changed.connect(_on_volume_slider_value_changed.bind(id_music))
	$"options-menu/categories/sound-volume/sound-volume/slider/dialogue-volume/dialogue-volume/hbox/HScrollBar".value = db_to_linear(AudioServer.get_bus_volume_db(id_dialog))
	$"options-menu/categories/sound-volume/sound-volume/slider/dialogue-volume/dialogue-volume/hbox/HScrollBar".value_changed.connect(_on_volume_slider_value_changed.bind(id_dialog))
#endregion
	
#region Genres
	$"options-menu/categories/music-genre/music-genre/checkboxes/jazz-check".button_pressed = MusicManager.selected_genres.has(MusicManager.MusicGenre.JAZZ)
	$"options-menu/categories/music-genre/music-genre/checkboxes/jazz-check".toggled.connect(_on_music_genre_check_box_toggled.bind(MusicManager.MusicGenre.JAZZ))
	$"options-menu/categories/music-genre/music-genre/checkboxes/latin-check".button_pressed = MusicManager.selected_genres.has(MusicManager.MusicGenre.LATIN)
	$"options-menu/categories/music-genre/music-genre/checkboxes/latin-check".toggled.connect(_on_music_genre_check_box_toggled.bind(MusicManager.MusicGenre.LATIN))
	$"options-menu/categories/music-genre/music-genre/checkboxes/rock-soft-check".button_pressed = MusicManager.selected_genres.has(MusicManager.MusicGenre.ROCK_SOFT)
	$"options-menu/categories/music-genre/music-genre/checkboxes/rock-soft-check".toggled.connect(_on_music_genre_check_box_toggled.bind(MusicManager.MusicGenre.ROCK_SOFT))
	$"options-menu/categories/music-genre/music-genre/checkboxes/rock-hard-check".button_pressed = MusicManager.selected_genres.has(MusicManager.MusicGenre.ROCK_HARD)
	$"options-menu/categories/music-genre/music-genre/checkboxes/rock-hard-check".toggled.connect(_on_music_genre_check_box_toggled.bind(MusicManager.MusicGenre.ROCK_HARD))
	$"options-menu/categories/music-genre/music-genre/checkboxes/unclassified-check".button_pressed = MusicManager.selected_genres.has(MusicManager.MusicGenre.UNCLASSIFIED)
	$"options-menu/categories/music-genre/music-genre/checkboxes/unclassified-check".toggled.connect(_on_music_genre_check_box_toggled.bind(MusicManager.MusicGenre.UNCLASSIFIED))
#endregion
	
#region Radio Effect
	$"options-menu/categories/music-genre/music-genre/checkbuttons/HBoxContainer/vintage-effect-button".button_pressed = AudioServer.is_bus_effect_enabled(id_music, 0)
	$"options-menu/categories/music-genre/music-genre/checkbuttons/HBoxContainer/vintage-effect-button".toggled.connect(
		func(x):
			AudioServer.set_bus_effect_enabled(id_music, 0, x)
			if x: sfx_player.stream = SWITCH_ON_SOUND
			else: sfx_player.stream = SWITCH_OFF_SOUND
			sfx_player.play()
	)
#endregion
	
#region Back Button
	$"options-menu/back-button".pressed.connect(_request_scene_switch.bind(MainMenuStage.SceneType.MAIN))
#endregion
	

extends PopupPanel


onready var master_volume: Slider = find_node("MasterVolume")
onready var sfx_volume: Slider = find_node("SFXVolume")
onready var music_volume: Slider = find_node("MusicVolume")
onready var screen_darken: ColorRect = get_tree().current_scene.find_node("ScreenDarken")


func update_widgets() -> void:
	master_volume.value = Globals.master_volume
	sfx_volume.value = Globals.sfx_volume
	music_volume.value = Globals.music_volume


func _on_OptionsWindow_about_to_show() -> void:
	screen_darken.visible = true
	update_widgets()


func _on_OptionsWindow_popup_hide() -> void:
	screen_darken.visible = false


func _on_MasterVolume_value_changed(value) -> void:
	Globals.master_volume = value


func _on_SFXVolume_value_changed(value) -> void:
	Globals.sfx_volume = value


func _on_MusicVolume_value_changed(value) -> void:
	Globals.music_volume = value


func _on_ResumeButton_pressed() -> void:
	visible = false


func _ready() -> void:
	visible = false

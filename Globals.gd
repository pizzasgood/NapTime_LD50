extends Node


var master_volume: float setget set_master_volume
var sfx_volume: float setget set_sfx_volume
var music_volume: float setget set_music_volume


func _ready() -> void:
	restore_defaults()


func restore_defaults() -> void:
	self.master_volume = 1.0
	self.sfx_volume = 1.0
	self.music_volume = 1.0


func set_volume_by_bus(name: String, volume_percent: float) -> void:
	var idx := AudioServer.get_bus_index(name)
	var db: float = -60.0 * (1.0 - volume_percent)
	AudioServer.set_bus_volume_db(idx, db)
	AudioServer.set_bus_mute(idx, false if volume_percent > 0 else true)


func set_master_volume(value: float) -> void:
	master_volume = value
	set_volume_by_bus("Master", value)


func set_sfx_volume(value: float) -> void:
	sfx_volume = value
	set_volume_by_bus("SFX", value)


func set_music_volume(value: float) -> void:
	music_volume = value
	set_volume_by_bus("Music", value)

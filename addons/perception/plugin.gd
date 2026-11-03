@tool
## Registers the perception autoloads while the plugin is enabled.
extends EditorPlugin

const NOISE_BUS_NAME := "NoiseBus3D"
const NOISE_BUS_RELATIVE_PATH := "src/3d/noise/noise_bus_3d.gd"

# ---[ EditorPlugin Methods ]---


func _enter_tree() -> void:
	_register_autoloads()


func _enable_plugin() -> void:
	_register_autoloads()


func _disable_plugin() -> void:
	_unregister_autoloads()

# ---[ Private Methods ]---


func _register_autoloads() -> void:
	var setting := "autoload/%s" % NOISE_BUS_NAME
	if not ProjectSettings.has_setting(setting):
		add_autoload_singleton(NOISE_BUS_NAME, _get_noise_bus_path())


func _unregister_autoloads() -> void:
	var setting := "autoload/%s" % NOISE_BUS_NAME
	if not ProjectSettings.has_setting(setting):
		return

	var path := str(ProjectSettings.get_setting(setting)).trim_prefix("*")
	if path == _get_noise_bus_path():
		remove_autoload_singleton(NOISE_BUS_NAME)


func _get_noise_bus_path() -> String:
	return get_script().resource_path.get_base_dir().path_join(NOISE_BUS_RELATIVE_PATH)

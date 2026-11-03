@tool

## Convex shape that represents a 2D vision cone pointing along the local +Y axis.
@icon("../../../icons/VisionConeShape2D.svg")
class_name VisionConeShape2D
extends ConvexPolygonShape2D

# ---[ Inspector Properties ]---

## Maximum vision distance.
@export_range(1.0, 100.0, 0.1) var length: float = 16.0:
	set(value):
		length = value
		_update_points()

## Field of view in degrees, limited to a maximum of 180.
@export_range(10.0, 180.0, 1.0, "radians_as_degrees") var fov: float = deg_to_rad(100.0):
	set(value):
		fov = clampf(value, deg_to_rad(10.0), PI)
		_update_points()

## Number of segments used to approximate the rounded far edge.
@export_range(1, 64, 1) var sector_segments: int = 16:
	set(value):
		sector_segments = clampi(value, 1, 64)
		_update_points()

# ---[ Node Methods ]---


func _init() -> void:
	_update_points()


func _validate_property(property: Dictionary) -> void:
	if property.name == &"points":
		property.usage &= ~PROPERTY_USAGE_EDITOR

# ---[ Private Methods ]---


func _update_points() -> void:
	var sector_points := PackedVector2Array([Vector2.ZERO])

	for index in sector_segments + 1:
		var angle := -fov * 0.5 + fov * float(index) / float(sector_segments)
		sector_points.append(Vector2(sin(angle), cos(angle)) * length)

	points = sector_points

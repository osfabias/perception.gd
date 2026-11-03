@tool

## Convex shape that represents a vision cone.
@icon("../../../icons/VisionConeShape3D.svg")
class_name VisionConeShape3D
extends ConvexPolygonShape3D

# ---[ Inspector Properties ]---

## Maximum vision distance.
@export_range(1.0, 100.0, 0.1) var length: float = 16.0:
	set(value):
		length = value
		_update_points()

## Horizontal field of view in degrees, limited to a maximum of 180.
@export_range(10.0, 180.0, 1.0, "radians_as_degrees") var fov: float = deg_to_rad(100.0):
	set(value):
		fov = clampf(value, deg_to_rad(10.0), PI)
		_update_points()

## Vertical field of view in meters.
@export_range(1.0, 20.0, 0.25, "suffix:m") var height: float = 4.0:
	set(value):
		height = value
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
	var d := length
	var half_h := height * 0.5
	var sector_points := PackedVector3Array([Vector3(0.0, -half_h, 0.0)])

	for index in sector_segments + 1:
		var angle := -fov * 0.5 + fov * float(index) / float(sector_segments)
		sector_points.append(Vector3(sin(angle) * d, -half_h, cos(angle) * d))

	for index in sector_segments + 1:
		var angle := -fov * 0.5 + fov * float(index) / float(sector_segments)
		sector_points.append(Vector3(sin(angle) * d, half_h, cos(angle) * d))

	sector_points.append(Vector3(0.0, half_h, 0.0))
	points = sector_points

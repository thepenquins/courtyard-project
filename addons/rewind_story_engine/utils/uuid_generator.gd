@tool
class_name UUIDGenerator
extends RefCounted


const BYTE_MASK: int = 0b11111111

var _rng := RandomNumberGenerator.new()


func _init(seed: int = -1) -> void:
	if seed == -1:
		randomize()
		seed = randi()
	
	_rng.seed = seed


func uuidbin():
	return [
		_rng.randi() & BYTE_MASK, _rng.randi() & BYTE_MASK, _rng.randi() & BYTE_MASK, _rng.randi() & BYTE_MASK,
		_rng.randi() & BYTE_MASK, _rng.randi() & BYTE_MASK, ((_rng.randi() & BYTE_MASK) & 0x0f) | 0x40, _rng.randi() & BYTE_MASK,
		((_rng.randi() & BYTE_MASK) & 0x3f) | 0x80, _rng.randi() & BYTE_MASK, _rng.randi() & BYTE_MASK, _rng.randi() & BYTE_MASK,
		_rng.randi() & BYTE_MASK, _rng.randi() & BYTE_MASK, _rng.randi() & BYTE_MASK, _rng.randi() & BYTE_MASK,
	  ]

  
func v4():
	var b = uuidbin()

	return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
		# low
		b[0], b[1], b[2], b[3],
		# mid
		b[4], b[5],
		# hi
		b[6], b[7],
		# clock
		b[8], b[9],
		# clock
		b[10], b[11], b[12], b[13], b[14], b[15]
	]

class_name VneFrameInfo
extends RefCounted


var frame: VneFrame
var index: int
var new: bool


func _init(frame: VneFrame, index: int, new: bool) -> void:
	self.frame = frame
	self.index = index
	self.new = new

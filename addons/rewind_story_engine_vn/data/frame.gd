class_name VneFrame
extends RSEBaseData


var characters: Array[VneCharacterFrame]
var location: VneLocationFrame
var music: VneMusicFrame
var bgs: VneBgsFrame
var sfx: Array[VneSfxFrame]
var vfx: Array[VneVfxFrame]
var transition_in: VneTransitionResource
var transition_out: VneTransitionResource


var character_frames_by_resource: Dictionary[VneCharacterResource, VneCharacterFrame]
var sfx_frames_by_resource: Dictionary[VneSfxResource, VneSfxFrame]
var vfx_frames_by_resource: Dictionary[VneVfxResource, VneVfxFrame]

var character_resources: Array:
	get:
		return _get_resources_from_frames_data(characters)

var sfx_resources: Array:
	get:
		return _get_resources_from_frames_data(sfx)

var vfx_resources: Array:
	get:
		return _get_resources_from_frames_data(vfx)


func _get_resources_from_frames_data(frames_data: Array) -> Array:
	var array: Array
	for frame_data: VneBaseFrameData in frames_data:
		array.append(frame_data.resource)
	return array


func _init(uuid: String = "", name: String = "") -> void:
	super(uuid, name)
	location = VneLocationFrame.new()
	music = VneMusicFrame.new()
	bgs = VneBgsFrame.new()


func get_string_data() -> PackedStringArray:
	var array = super()
	
	if characters.size() != 0:
		for character_f in characters:
			array.append_array(character_f.get_string_data())
	
	array.append("")
	
	array.append_array(location.get_string_data() if location else [""])
	array.append_array(music.get_string_data() if music else [""])
	array.append_array(bgs.get_string_data() if bgs else [""])
	
	array.append("")
	
	if sfx.size() != 0:
		for sfx_f in sfx:
			array.append_array(sfx_f.get_string_data())
	
	array.append("")
	
	if vfx.size() != 0:
		for vfx_f in vfx:
			array.append_array(vfx_f.get_string_data())
	
	array.append("")
	
	array.append(transition_in.uuid if transition_in else "")
	array.append(transition_out.uuid if transition_out else "")
	
	return array


func fill_data(file: FileAccess) -> void:
	super(file)

	var line := file.get_line()
	while line != "":
		var character_f = VneCharacterFrame.new()
		character_f.fill_data(line, file)
		characters.append(character_f)
		character_frames_by_resource[character_f.character] = character_f
		line = file.get_line()
	
	location = VneLocationFrame.new()
	location.fill_data(file.get_line(), file)
	
	music = VneMusicFrame.new()
	music.fill_data(file.get_line(), file)
	
	bgs = VneBgsFrame.new()
	bgs.fill_data(file.get_line(), file)
	
	file.get_line()
	
	line = file.get_line()
	while line != "":
		var sfx_f = VneSfxFrame.new()
		sfx_f.fill_data(line, file)
		sfx.append(sfx_f)
		sfx_frames_by_resource[sfx_f.sfx] = sfx_f
		line = file.get_line()
	
	line = file.get_line()
	while line != "":
		var vfx_f = VneVfxFrame.new()
		vfx_f.fill_data(line, file)
		vfx.append(vfx_f)
		vfx_frames_by_resource[vfx_f.vfx] = vfx_f
		line = file.get_line()
	
	transition_in = VNE.visual_novel.get_resource_by_uuid(file.get_line())
	transition_out = VNE.visual_novel.get_resource_by_uuid(file.get_line())


func copy_from(frame: VneFrame) -> void:
	copy_characters_from(frame)
	copy_location_from(frame)
	copy_music_from(frame)
	copy_bgs_from(frame)
	copy_sfx_from(frame)
	copy_vfx_from(frame)
	
	transition_in = frame.transition_in
	transition_out = frame.transition_out


func copy_characters_from(frame: VneFrame) -> void:
	characters.clear()
	
	for character_f in frame.characters:
		var new_character_f = VneCharacterFrame.new()
		new_character_f.copy_from(character_f)
		characters.append(new_character_f)
	
	character_frames_by_resource.clear()
	for character_f in characters:
		character_frames_by_resource[character_f.character] = character_f


func copy_location_from(frame: VneFrame) -> void:
	if frame.location:
		if not location:
			location = VneLocationFrame.new()
		location.copy_from(frame.location)
	else:
		location = null


func copy_music_from(frame: VneFrame) -> void:
	if frame.music:
		if not music:
			music = VneMusicFrame.new()
		music.copy_from(frame.music) 
	else:
		music = null


func copy_bgs_from(frame: VneFrame) -> void:
	if frame.bgs:
		if not bgs:
			bgs = VneBgsFrame.new()
		bgs.copy_from(frame.bgs)
	else:
		bgs = null


func copy_sfx_from(frame: VneFrame) -> void:
	sfx.clear()
	
	for sfx_f in frame.sfx:
		var new_sfx_f = VneSfxFrame.new()
		new_sfx_f.copy_from(sfx_f)
		sfx.append(new_sfx_f)
	
	sfx_frames_by_resource.clear()
	for sfx_f in sfx:
		sfx_frames_by_resource[sfx_f.sfx] = sfx_f


func copy_vfx_from(frame: VneFrame) -> void:
	vfx.clear()
	
	for vfx_f in frame.vfx:
		var new_vfx_f = VneVfxFrame.new()
		new_vfx_f.copy_from(vfx_f)
		vfx.append(new_vfx_f)
	
	vfx_frames_by_resource.clear()
	for vfx_f in vfx:
		vfx_frames_by_resource[vfx_f.vfx] = vfx_f


func clear() -> void:
	characters = []
	location = null
	music = null
	bgs = null
	sfx = []
	vfx = []
	transition_in = null
	transition_out = null
	
	character_frames_by_resource.clear()
	sfx_frames_by_resource.clear()
	vfx_frames_by_resource.clear()


#region utils
func add_character(character: VneCharacterResource) -> void:
	var character_f = VneCharacterFrame.new()
	character_f.resource = character
	characters.append(character_f)
	character_frames_by_resource[character] = character_f


func remove_character(character: VneCharacterResource) -> void:
	var character_f = character_frames_by_resource[character]
	characters.erase(character_f)
	character_frames_by_resource.erase(character)


func add_sfx(sfx_res: VneSfxResource) -> void:
	var sfx_f = VneSfxFrame.new()
	sfx_f.resource = sfx_res
	sfx.append(sfx_f)
	sfx_frames_by_resource[sfx_res] = sfx_f


func remove_sfx(sfx_res: VneSfxResource) -> void:
	var sfx_f = sfx_frames_by_resource[sfx_res]
	sfx.erase(sfx_f)
	sfx_frames_by_resource.erase(sfx_res)


func add_vfx(vfx_res: VneVfxResource) -> void:
	var vfx_f = VneVfxFrame.new()
	vfx_f.resource = vfx_res
	vfx.append(vfx_f)
	vfx_frames_by_resource[vfx_res] = vfx_f


func remove_vfx(vfx_res: VneVfxResource) -> void:
	var vfx_f = vfx_frames_by_resource[vfx_res]
	vfx.erase(vfx_f)
	vfx_frames_by_resource.erase(vfx_res)


func get_frame_data_by_resource(resource: VneResource) -> VneBaseFrameData:
	if resource == null:
		return null

	if resource is VneCharacterResource and character_frames_by_resource.has(resource):
		return character_frames_by_resource[resource as VneCharacterResource]

	if resource is VneSfxResource and sfx_frames_by_resource.has(resource):
		return sfx_frames_by_resource[resource as VneSfxResource]

	if resource is VneVfxResource and vfx_frames_by_resource.has(resource):
		return vfx_frames_by_resource[resource as VneVfxResource]

	if resource is VneLocationResource and location and location.resource == resource:
		return location

	if resource is VneMusicResource and music and music.resource == resource:
		return music

	if resource is VneBgsResource and bgs and bgs.resource == resource:
		return bgs

	return null
#endregion

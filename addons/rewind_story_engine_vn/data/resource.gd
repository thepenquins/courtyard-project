class_name VneResource
extends RSEBaseData


const FILE_EXTENSION: String = "vnr"

const TYPE_CHARACTER = "character"
const TYPE_LOCATION = "location"
const TYPE_MUSIC = "music"
const TYPE_BGS = "bgs"
const TYPE_SFX = "sfx"
const TYPE_VFX = "vfx"
const TYPE_TRANSITION = "transition"

var path_to_file: String
var _type: String


func _init(uuid: String, name: String = "unnamed") -> void:
	super(uuid, name)
	self._extension = FILE_EXTENSION
	_setting_type()


func _setting_type() -> void:
	pass


func get_string_data() -> PackedStringArray:
	var array = super()
	array.append(path_to_file)
	array.append(_type)
	return array


func fill_data(file: FileAccess) -> void:
	super(file)
	path_to_file = file.get_line() 
	_type = file.get_line() 


func load_casted_resource() -> VneResource:
	var casted_resource: VneResource
	
	match _type:
		TYPE_CHARACTER:
			casted_resource = VneCharacterResource.new(uuid)
		TYPE_LOCATION:
			casted_resource = VneLocationResource.new(uuid)
		TYPE_MUSIC:
			casted_resource = VneMusicResource.new(uuid)
		TYPE_BGS:
			casted_resource = VneBgsResource.new(uuid)
		TYPE_SFX:
			casted_resource = VneSfxResource.new(uuid)
		TYPE_VFX:
			casted_resource = VneVfxResource.new(uuid)
		TYPE_TRANSITION:
			casted_resource = VneTransitionResource.new(uuid)
		
	casted_resource.load_data(path_to_data_file_full)
	
	return casted_resource

class_name IndieBlueprintNameGenerator extends RefCounted

var repository: NameRepository
var names_bag: ShuffleBag
var surnames_bag: ShuffleBag


func _init(_repository: NameRepository) -> void:
	repository = _repository
	
	if repository.use_shuffle_bag:
		names_bag = ShuffleBag.new(repository.names)
		surnames_bag = ShuffleBag.new(repository.surnames)
	

func generate() -> String:
	var result: String = ""
	
	if repository.names.size():
		result += generate_name()
		
	if repository.surnames.size():
		result += " %s" % generate_surname()
	
	return result


func generate_name() -> String:
	if repository.names.size():
		return names_bag.random() if repository.use_shuffle_bag else repository.names.pick_random() 
		
	return ""


func generate_surname() -> String:
	if repository.surnames.size():
		return surnames_bag.random() if repository.use_shuffle_bag else repository.surnames.pick_random() 
		
	return ""
	
	
func change_repository(new_repository: NameRepository) -> IndieBlueprintNameGenerator:
	repository = new_repository
	names_bag = ShuffleBag.new(repository.names)
	surnames_bag = ShuffleBag.new(repository.surnames)
	
	return self
	
	

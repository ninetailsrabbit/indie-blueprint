class_name NameRepository extends Resource

enum Category {
	Male,
	Female,
	NoGender,
}


@export var id: StringName
@export var use_shuffle_bag: bool = true
@export var region: StringName = &"en"
@export var gender: Category = Category.NoGender
@export var names: Array[String] = []
@export var surnames: Array[String] = []

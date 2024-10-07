class_name ContentWarning extends Resource

@export var can_be_skipped: bool = false
@export_group("Time")
@export var time_on_screen: float = 5.0
@export var time_to_display_content_warning: float = 2.0
@export var time_to_hide_content_warning: float = 2.0
@export_group("Original text")
@export var title:String = ""
@export var subtitle:String = ""
@export var description:String = ""
@export var secondary_description:String = ""
@export_group("Translation keys")
@export var title_translation_key:String = ""
@export var subtitle_translation_key:String = ""
@export var description_translation_key:String = ""
@export var secondary_description_translation_key:String = ""

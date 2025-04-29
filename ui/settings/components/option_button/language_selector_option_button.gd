class_name LanguageSelector extends OptionButton

@export_enum(
IndieBlueprintGameSettings.CurrentLanguageSetting, 
IndieBlueprintGameSettings.SubtitlesLanguageSetting, 
IndieBlueprintGameSettings.VoicesLanguageSetting
) var setting_related = IndieBlueprintGameSettings.CurrentLanguageSetting
## Ues the original name or native speakers of the language. If disabled, its English name will be used.
@export var use_native_name: bool = true


var languages_included: Array[IndieBlueprintLocalization.Language] = [
	IndieBlueprintLocalization.english(),
	IndieBlueprintLocalization.spanish(),
	IndieBlueprintLocalization.portuguese(),
	IndieBlueprintLocalization.italian(),
	IndieBlueprintLocalization.german(),
	IndieBlueprintLocalization.french(),
	IndieBlueprintLocalization.russian()
]

var language_by_option_button_id: Dictionary = {}

func _ready() -> void:
	item_selected.connect(on_language_selected)
	
	var id: int = 0
	
	for language_included in languages_included:
		add_item(language_included.native_name if use_native_name else language_included.english_name, id)
		
		if language_included.iso_code == IndieBlueprintSettingsManager.get_localization_section(setting_related):
			select(item_count - 1)
			
		language_by_option_button_id[id] = language_included
		id += 1


func on_language_selected(idx) -> void:
	var selected_language = language_by_option_button_id[get_item_id(idx)]
	IndieBlueprintSettingsManager.update_localization_section(setting_related, selected_language.iso_code)
	TranslationServer.set_locale(selected_language.iso_code)

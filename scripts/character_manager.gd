extends Node

## CharacterManager Singleton
## Manages available playable cat characters and tracks selected character
## Autoloaded as "CharacterManager"

# Preload Character script
const CharacterScript = preload("res://scripts/character.gd")

## All available characters
var all_characters: Array = []

## Currently selected character (defaults to first character)
var selected_character = null

## Default character ID
var default_character_id: String = ""

func _ready():
	# Wait for DataLoader to finish loading
	call_deferred("_initialize_characters")

## Initialize characters from JSON data
func _initialize_characters():
	all_characters.clear()

	# Load default character ID
	default_character_id = DataLoader.get_default_character()

	# Load characters from JSON
	var characters_json = DataLoader.get_characters()

	for character_data in characters_json:
		var character = CharacterScript.new()
		character.character_id = character_data.get("character_id", "")
		character.character_name = character_data.get("character_name", "")
		character.description = character_data.get("description", "")
		character.flavor_text = character_data.get("flavor_text", "")
		character.texture_path = character_data.get("texture_path", "")
		character.starting_weapon_id = character_data.get("starting_weapon_id", "")
		character.base_health = character_data.get("base_health", 100.0)
		character.base_speed = character_data.get("base_speed", 5.0)

		# Load texture
		if character.texture_path != "":
			character.texture = load(character.texture_path)

		all_characters.append(character)

	# Set default selected character
	if not default_character_id.is_empty():
		selected_character = get_character_by_id(default_character_id)

	if selected_character == null and all_characters.size() > 0:
		selected_character = all_characters[0]

	print("CharacterManager initialized with ", all_characters.size(), " characters")
	if selected_character:
		print("Default character: ", selected_character.character_name)

## Get character by ID
func get_character_by_id(char_id: String):
	for character in all_characters:
		if character.character_id == char_id:
			return character
	return null

## Set the selected character
func select_character(char_id: String) -> bool:
	var character = get_character_by_id(char_id)
	if character:
		selected_character = character
		print("Selected character: ", character.character_name)
		return true
	return false

## Get the currently selected character
func get_selected_character():
	return selected_character

## Get all characters
func get_all_characters() -> Array:
	return all_characters

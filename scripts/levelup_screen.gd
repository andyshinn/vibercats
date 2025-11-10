extends Control

## Level-up screen for powerup selection
## Shows 3-4 powerup options with Skip, Banish, and Reroll

@onready var powerup_container: HBoxContainer = $Panel/MarginContainer/VBoxContainer/PowerupContainer
@onready var level_label: Label = $Panel/MarginContainer/VBoxContainer/LevelLabel
@onready var skip_button: Button = $Panel/MarginContainer/VBoxContainer/MetaOptions/SkipButton
@onready var reroll_button: Button = $Panel/MarginContainer/VBoxContainer/MetaOptions/RerollButton

var powerup_choice_scene: PackedScene = preload("res://scenes/ui/powerup_choice.tscn")
var current_powerups: Array[Powerup] = []
var current_weapons: Array[Weapon] = []
var rerolls_remaining: int = 3
var is_weapon_selection: bool = false

signal powerup_chosen(powerup: Powerup)
signal weapon_chosen(weapon: Weapon)
signal screen_closed()

func _ready():
	visible = false
	skip_button.pressed.connect(_on_skip_pressed)
	reroll_button.pressed.connect(_on_reroll_pressed)

func _input(_event: InputEvent):
	# Debug: Press E to close level-up screen
	if visible and Input.is_action_just_pressed("debug_close_levelup"):
		print("DEBUG: Closing level-up screen with E key")
		close_screen()

func show_levelup(level: int):
	# Check if this is a weapon unlock level
	if WeaponManager.should_offer_weapon_selection(level):
		show_weapon_selection(level)
	else:
		show_powerup_selection(level)

func show_powerup_selection(level: int):
	is_weapon_selection = false
	level_label.text = "Level " + str(level) + " - Choose a Powerup!"
	current_powerups = PowerupManager.get_random_powerups(3)
	display_powerups()
	visible = true
	get_tree().paused = true

func show_weapon_selection(level: int):
	is_weapon_selection = true
	level_label.text = "Level " + str(level) + " - Choose a Weapon!"

	# Get player's owned weapons (we'll get this from the player later)
	var owned_weapon_ids: Array[String] = []
	var player = get_tree().get_first_node_in_group("players")
	if player and player.has_method("get_owned_weapon_ids"):
		owned_weapon_ids = player.get_owned_weapon_ids()

	current_weapons = WeaponManager.get_random_weapon_choices(3, owned_weapon_ids)
	display_weapons()
	visible = true
	get_tree().paused = true

func display_powerups():
	# Clear existing powerup choices
	for child in powerup_container.get_children():
		child.queue_free()

	# Create new powerup choice buttons
	for powerup in current_powerups:
		if not powerup_choice_scene:
			push_error("Powerup choice scene not found!")
			continue

		var choice = powerup_choice_scene.instantiate()
		powerup_container.add_child(choice)

		# Set powerup data
		if choice.has_method("set_powerup"):
			choice.set_powerup(powerup)

		# Connect selection signal
		if choice.has_signal("selected"):
			choice.selected.connect(_on_powerup_selected.bind(powerup))

		# Connect banish signal
		if choice.has_signal("banished"):
			choice.banished.connect(_on_powerup_banished.bind(powerup))

	# Update reroll button
	reroll_button.text = "Reroll (" + str(rerolls_remaining) + ")"
	reroll_button.disabled = rerolls_remaining <= 0

func display_weapons():
	# Clear existing choices
	for child in powerup_container.get_children():
		child.queue_free()

	# Create weapon choice buttons (reuse powerup_choice UI for now)
	for weapon in current_weapons:
		if not powerup_choice_scene:
			push_error("Powerup choice scene not found!")
			continue

		var choice = powerup_choice_scene.instantiate()
		powerup_container.add_child(choice)

		# Set weapon data (temporarily use powerup display format)
		if choice.has_method("set_weapon"):
			choice.set_weapon(weapon)
		elif choice.has_method("set_powerup_generic"):
			choice.set_powerup_generic(weapon.weapon_name, weapon.description, Color.ORANGE_RED)

		# Connect selection signal
		if choice.has_signal("selected"):
			choice.selected.connect(_on_weapon_selected.bind(weapon))

	# Hide banish button for weapons, disable reroll
	reroll_button.text = "Reroll"
	reroll_button.disabled = true

func _on_powerup_selected(powerup: Powerup):
	PowerupManager.equip_powerup(powerup)
	powerup_chosen.emit(powerup)
	close_screen()

func _on_weapon_selected(weapon: Weapon):
	# Notify player to equip the weapon
	weapon_chosen.emit(weapon)
	close_screen()

func _on_powerup_banished(powerup: Powerup):
	PowerupManager.banish_powerup(powerup)

	# Remove from current display
	current_powerups = current_powerups.filter(func(p): return p.powerup_id != powerup.powerup_id)

	# Get a new powerup to replace it
	var new_powerups = PowerupManager.get_random_powerups(1)
	if new_powerups.size() > 0:
		current_powerups.append(new_powerups[0])

	display_powerups()

func _on_skip_pressed():
	close_screen()

func _on_reroll_pressed():
	if rerolls_remaining > 0:
		rerolls_remaining -= 1
		current_powerups = PowerupManager.get_random_powerups(3)
		display_powerups()

func close_screen():
	visible = false
	get_tree().paused = false
	screen_closed.emit()

func reset():
	rerolls_remaining = 3

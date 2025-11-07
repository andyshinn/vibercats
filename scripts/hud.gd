extends CanvasLayer

## HUD for Viber Cats
## Displays health bar, hunger bar (XP), and level

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var hunger_bar: ProgressBar = $MarginContainer/VBoxContainer/HungerBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel

var player: Player = null

func _ready():
	# Connect to PlayerStats signals
	if PlayerStats:
		PlayerStats.xp_changed.connect(_on_xp_changed)
		PlayerStats.level_up.connect(_on_level_up)

	# Find player
	call_deferred("_find_player")

	# Initialize UI
	_on_level_up(PlayerStats.current_level)
	_on_xp_changed(PlayerStats.current_xp, PlayerStats.xp_to_next_level)

func _find_player():
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]

		# Connect to player health signals
		if player.has_signal("health_changed"):
			player.health_changed.connect(_on_health_changed)

		# Initialize health bar
		_on_health_changed(player.current_health, player.max_health)

func _on_health_changed(current: float, maximum: float):
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current

func _on_xp_changed(current_xp: int, xp_to_next: int):
	if hunger_bar:
		hunger_bar.max_value = xp_to_next
		hunger_bar.value = current_xp

func _on_level_up(new_level: int):
	if level_label:
		level_label.text = "Level: " + str(new_level)

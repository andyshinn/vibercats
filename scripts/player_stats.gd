extends Node

## Player Stats Autoload Singleton
## Tracks player level, XP, and hunger bar progression

signal xp_changed(current_xp: int, xp_to_next_level: int)
signal level_up(new_level: int)

var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 10

# XP curve - each level requires more XP
@export var xp_multiplier: float = 1.5

func _ready():
	pass

func add_xp(amount: int):
	current_xp += amount
	xp_changed.emit(current_xp, xp_to_next_level)

	# Check for level up
	while current_xp >= xp_to_next_level:
		level_up_player()

func level_up_player():
	current_xp -= xp_to_next_level
	current_level += 1

	# Calculate next level XP requirement
	xp_to_next_level = int(xp_to_next_level * xp_multiplier)

	level_up.emit(current_level)

	# Pause game and show level-up screen
	get_tree().paused = true
	show_levelup_screen()

func show_levelup_screen():
	# Find and show the level-up screen
	var levelup_screen = get_tree().get_first_node_in_group("levelup_screen")
	if levelup_screen and levelup_screen.has_method("show_levelup"):
		levelup_screen.show_levelup(current_level)
	else:
		# Fallback: unpause game if no level-up screen found
		print("Level up! Now level: ", current_level)
		get_tree().paused = false

func reset_stats():
	current_level = 1
	current_xp = 0
	xp_to_next_level = 10

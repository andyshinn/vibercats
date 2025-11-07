extends PanelContainer

## Individual powerup choice display
## Shows powerup info and allows selection or banishing

@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var rarity_label: Label = $MarginContainer/VBoxContainer/RarityLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var select_button: Button = $MarginContainer/VBoxContainer/SelectButton
@onready var banish_button: Button = $MarginContainer/VBoxContainer/BanishButton

var powerup: Powerup

signal selected()
signal banished()

func _ready():
	select_button.pressed.connect(_on_select_pressed)
	banish_button.pressed.connect(_on_banish_pressed)

func set_powerup(p: Powerup):
	powerup = p

	if name_label:
		name_label.text = powerup.powerup_name

	if rarity_label:
		rarity_label.text = powerup.get_rarity_name()
		rarity_label.add_theme_color_override("font_color", powerup.get_rarity_color())

	if description_label:
		description_label.text = powerup.description

	# Style panel based on rarity
	var style = get_theme_stylebox("panel", "PanelContainer").duplicate()
	if style is StyleBoxFlat:
		style.border_color = powerup.get_rarity_color()
		style.border_width_left = 3
		style.border_width_right = 3
		style.border_width_top = 3
		style.border_width_bottom = 3
	add_theme_stylebox_override("panel", style)

func _on_select_pressed():
	selected.emit()

func _on_banish_pressed():
	banished.emit()

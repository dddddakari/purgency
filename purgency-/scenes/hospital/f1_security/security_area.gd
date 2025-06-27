extends Node2D

@onready var lebron        : CharacterBody2D   = $Lebron
@onready var hitbox_area   : Area2D            = $Lebron/enemy_hitbox        # adjust if different
@onready var detect_area   : Area2D            = $Lebron/detection_area      # adjust if different
@onready var hitbox_shape  : CollisionShape2D  = hitbox_area.get_node("CollisionShape2D")
@onready var detect_shape  : CollisionShape2D  = detect_area.get_node("CollisionShape2D")

# Path to the DialoguePlayer that emits `start_combat`
@export_node_path("CanvasLayer") var dialogue_player_path : NodePath = "SecurityDialogue"
   # tweak as needed
var dialogue_player : CanvasLayer

var lebron_hostile := false         # starts friendly

func _ready() -> void:
	# Apply initial state (friendly)
	_refresh_combat_state()

	# Hook up the dialogue signal (if the node exists)
	if dialogue_player_path != NodePath():
		dialogue_player = get_node_or_null(dialogue_player_path)
		if dialogue_player and dialogue_player.has_signal("start_combat"):
			dialogue_player.start_combat.connect(_on_start_combat)
		else:
			push_warning("DialoguePlayer not found or signal missing at %s" % dialogue_player_path)

# ----------------------------------------------------
# Public helper so other scripts can flip hostility
func set_lebron_hostile(state: bool) -> void:
	if lebron_hostile == state:
		return                     # no change
	lebron_hostile = state
	_refresh_combat_state()

# ----------------------------------------------------
# PRIVATE ------------------------------------------------
func _refresh_combat_state() -> void:
	hitbox_area.monitoring  = lebron_hostile
	detect_area.monitoring  = lebron_hostile
	hitbox_shape.disabled   = !lebron_hostile
	detect_shape.disabled   = !lebron_hostile
	# (Optional) change animation, sprite, or music here

func _on_start_combat() -> void:
	# Dialogue has requested combat – make Lebron hostile
	set_lebron_hostile(true)

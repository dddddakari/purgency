# QuestManager.gd - Create this as an AutoLoad (only if it no worky on your machine Maxim)
extends Node

# Dictionary to store quest items
var quest_items: Dictionary = {}

# Signal for when quest items are added/removed
signal quest_item_added(item_name: String)
signal quest_item_removed(item_name: String)

func add_quest_item(item_name: String) -> void:
	quest_items[item_name] = true
	quest_item_added.emit(item_name)
	print("Quest item added: ", item_name)

func remove_quest_item(item_name: String) -> void:
	if quest_items.has(item_name):
		quest_items.erase(item_name)
		quest_item_removed.emit(item_name)
		print("Quest item removed: ", item_name)

func has_quest_item(item_name: String) -> bool:
	return quest_items.has(item_name)

func get_all_quest_items() -> Array:
	return quest_items.keys()

func clear_all_quest_items() -> void:
	quest_items.clear()
	print("All quest items cleared")

# Save/Load functionality (optional)
func save_quest_data() -> Dictionary:
	return {"quest_items": quest_items}

func load_quest_data(data: Dictionary) -> void:
	if data.has("quest_items"):
		quest_items = data["quest_items"]
		
signal quest_progress(method: String)  # "good" or "bad"

func complete_quest_good():
	quest_progress.emit("good")
	GameState.good_points += 1

func complete_quest_bad():
	quest_progress.emit("bad")
	GameState.bad_points += 1

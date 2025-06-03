# Inventory.gd
extends Node

var inventory := []

func add_item(item):
	inventory.append(item)

func remove_item(item):
	inventory.erase(item)

func get_inventory():
	return inventory

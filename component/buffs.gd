#var upgrades_old = [
	#["hp", "Health", "+5 health", Rect2(16,64,16,16)],
	#["armor", "Armor", "+1 Armor", Rect2(32,64,16,16)],
	#["move_speed", "Move Speed", "+10% Move speed", Rect2(48,64,16,16)],
	#["damage", "Damage", "+5 Damage", Rect2(64,64,16,16)],
	#["cooldown", "CD", "-10% cooldown", Rect2(80,64,16,16)],
	#["proj_speed","Projectile speed", "+10% Projectile speed", Rect2(96,64,16,16)],
#]

var player_stats = ["health", "dodge", "speed", "damage", "cooldown", "proj_speed", "amount","pierce", "freeze", "sight"]

var elements = {
	"XI": {
		"description": "brutality. +50% bullet damage, -70% elemental",
	},
	"LAMBDA": {
		"description": "elemental. +70% elemental damage, all bullet damage is 1. inflict a lightning strike on every shot",
		},
	"THETA": {
		"description": "demolition. all bullet damage -50% and converted to explosions, explosion range +50%. all elemental attacks cause explosions with half their damage"
	},
}

var upgrades = {
	"freeze": [
		{
			"name": "woah",
			"description": "enemies have a chance to freeze",
			"sprite":7,
			"stats": {"freeze": 20},
			"id": "freeze"
		},
		{
			"name": "opa",
			"description": "+1 exp orb from a frozen enemy",
			"sprite":7,
			"id": "freeze_xp_boost"
		},
		{
			"name": "bam bam",
			"description": "frozen enemies explode on death",
			"sprite":7,
			"id": "freeze_explode"
		},
		{
			"name": "yay",
			"description": "on freeze do 10 damage",
			"sprite":7,
			"stats": {"freeze": 30},
			"id": "freeze_ultimate"
		},
	],
	"sight": [
		{
			"name": "eye spy",
			"description": "attack enemies in your viscinity",
			"sprite":10,
			"stats": {"sight": 64},
		},
		{
			"name": "soaker (bonus track)",
			"description": "sight affects pickup range",
			"sprite":10,
			"stats": {"sight": 16},
			"id": "sight_affects_pickup"
		},
		{
			"name": "fent",
			"description": "eyeballs diluted",
			"sprite":10,
			"stats": {"sight": 32},
		},
		{
			"name": "damn",
			"description": "sight affected by cooldown now",
			"sprite":10,
			"stats": {"freeze": 20},
			"id": "cooldown_affects_sight"
		},
	],
	"hp": [
		{
			"name": "max hp",
			"sprite": 0,
			"stats": {"health": +1},
		},
		{
			"name": "tank",
			"sprite": 0,
			"stats": {"health": +2, "speed": -10}
		},
		{
			"name": "whats 9+10",
			"description": "every 5 levels get 1 max hp",
			"sprite": 0,
			"id": "level_affects_health"
		},
		{
			"name": "0xDEADBEEF",
			"description": "every XP orb has a 1/200 chance to heal you",
			"sprite": 0,
			"id": "xp_chance_to_heal"
		},
	],

	"move_speed": [
		{
			"name": "starter",
			"sprite": 2,
			"stats": {"speed": 30},
		},
		{
			"name": "AAAAAAH HELP ME",
			"sprite": 2,
			"stats": {"speed": 50, "cooldown": 20}
		},
		{
			"name": "well now its not that",
			"description": "move speed also affects cooldown",
			"sprite": 2,
			"id": "cooldown_affected_by_move_speed"
		},
		{
			"name": "FUCK YEAH",
			"description": "every 50 move speed get 1 amount",
			"sprite": 2,
			"id": "amount_affected_by_move_speed"
		},
	],
	"damage": [
		{
			"name": "starter",
			"sprite": 3,
			"stats": {"damage": 5}
		},
		{
			"name": "yuh",
			"description": "+2 damage per level",
			"sprite": 3,
			"id": "level_affects_damage"
		},
		{
			"name": "HEEEEELP!!! HELP MEEEEEE",
			"description": "on hit +20% damage and move speed for 20s",
			"sprite": 3,
			"id": "onhit_damage"
		},
		{
			"name": "RAHHHHHHHHH",
			"description": "+1 amount every 50 move speed",
			"sprite": 3,
			"id": "damage_affected_by_move_speed"
		},
	],
	"cooldown": [
		{
			"name": "starter",
			"sprite": 5,
			"stats": {"cooldown": 20}
		},
		{
			"name": "now this is going somewhere",
			"sprite": 5,
			"stats": {"amount":1,"damage":-5}
		},
		{
			"name": "piercing",
			"sprite": 5,
			"stats": {"pierce":2}
		},
		{
			"name": "TAKYON",
			"description": "get +1 pierce & amount every 10 levels",
			"sprite": 5,
			"id": "level_affects_amount_pierce"
		},
	],
}
func convert_for_player() -> Dictionary:
	var output := {}
	for key in player_stats:
		output[key] = 0
	return output
	
func print_all_ids():
	for upgrade in upgrades:
		for x in upgrades[upgrade]:
			if x.has("stats"): print(x["description"])

func stats_from_upgrades(_upgrades : Array) -> Dictionary:
	var returned = {}
	for upgrade in _upgrades:
		if upgrade.has("stats"):
			for x in upgrade["stats"]:
				if returned.has(x):
					returned[x] += upgrade["stats"][x]
				else:
					returned[x] = upgrade["stats"][x]
		
	return returned 
func convert_for_wheel():
	return upgrades

func convert_for_bonuses() -> Dictionary:
	var output := {}
	for key in player_stats:
		output[key] = {}
	return output

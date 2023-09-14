extends Node

var rng = RandomNumberGenerator.new()

var opponent: Dictionary # will hold all relavant info from the parent scene
var player: Dictionary # will hold all relavant info from the parent scene

var o: CharacterBody2D # Opponent Node
var p: CharacterBody2D # Player Node

var winner
var loser

var round = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Start of battle:
## Assign all relevant info to opponent and player dictionaries
### Stats, Name, Hats, Health, 
## Load dialog options for player (called choices in playtest)
### These dialog options come from the singleton bc (battle_constants.gd)
### In this script we will dyanmically create two pools of each dialog option from bc for each combatant
### this way they don't speak the same insults to eachother

# After dialog option is chosen
## Determine round initiative (WIT + CHA), if tied random
## Calculate outcome
### In initiative order resolve the dialogs
#### Apply damage or buffs 
#### maybe into a state object then send up to UI in a function that will play it out in an animation similar to the test animtaion set now
### Check for winner, if so end round early and conclude battle

## Resolve round
### Set cooldowns for any HATs or CHA options used
### refresh cooldowns that were already set from previous round to make available again
### Adjust hat order if any HAT abilities were used, send up to UI

## Conclude battle
### If player won award hat, send up to UI
### If player lost send NPC to next room
### Clear any state to null for player, oppponent, p, o, round, winner, loser, etc
### Remove battle UI and set camera back to normal

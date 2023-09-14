extends Node


# Create dictionaries and arrays of dialog for insult, charisma and hat pools. 
## Each dialog option needs a short form and a long form

# Create Hat state dictionaries that provide:  HAT ability, CHA option, etc
## HAT abilities will either target self and buff or do damage or a combination of the two
### stats: { self: boolean, stats_array: [{DEF: 3}, {CHA: -1}]} damage: {self: boolean, amount: func(combatant): return damage calcuate dmg based on rng and combatant stats?}

player_models <- [
	""
	"models/player/scout.mdl"
	"models/player/sniper.mdl"
	"models/player/soldier.mdl"
	"models/player/demo.mdl"
	"models/player/medic.mdl"
	"models/player/heavy.mdl"
	"models/player/pyro.mdl"
	"models/player/spy.mdl"
	"models/player/engineer.mdl"
]

foreach (model in player_models)
	PrecacheModel(model)

class freeze extends CharacterTrait
{
	revive_marker = reviveMarker()
	revive_model = null

	function OnDeath(attacker, params)
	{
		revive_model = reviveMarker.spawnReviveMarker(player, player.GetMaxHealth() * 0.5)
		revive_model.SetModel(player_models[player.GetPlayerClass()])
		revive_model.SetTeam(player.GetTeam())
	}
}
characterTraitsClasses.push(freeze)
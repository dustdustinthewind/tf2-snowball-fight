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

REVIVE_LENGTH <- 250

class freeze extends CharacterTrait
{
	revive_marker = reviveMarker()
	revive = null

	function OnDeath(attacker, params)
	{
		revive = reviveMarker.spawnReviveMarker(player, player.GetMaxHealth())
		revive.SetModel(player_models[player.GetPlayerClass()])
		SetPropInt(revive, "m_nSkin", revive.GetTeam() - 2)
		set_origin(revive, revive.GetOrigin() - Vector(0, 0, 40))
		revive.SetVelocity(player.GetVelocity() * 0.5)
		//if (!debug)
			SetPropInt(player, "m_Shared.m_nPlayerState", 3) // Force player to be in the dying state so that they don't respawn
	}

	function OnFrameTickAlive()
	{
		revive()
		stop_reviving()
	}

	function OnFrameTickAliveOrDead()
	{
		if (IsPlayerAlive(player) || !revive) return

		try {
			revive.StopSound("Medic.AutoCallerAnnounce")
		} catch (exception){

		}
	}

	revive_location = null

	function revive()
	{
		if (!player.button_down(IN_ATTACK3)) return

		if (!revive_location) revive_location = player.GetOrigin()

		local trace = fire_trace
		(
			player.EyePosition(),
			player.EyePosition() + player.EyeAngles().Forward() * REVIVE_LENGTH,
			-1,
			player,
			function(entity) { return TRACE_STOP },
			true
		)

		if (!("enthit" in trace) || trace.enthit.GetClassname() != "entity_revive_marker" || trace.enthit.GetTeam() != player.GetTeam()) return

		set_origin(player, revive_location)
		damage_victim(trace.enthit, player, -1, trace.endpos)

		local revivee = GetPropEntity(trace.enthit, "m_hOwner")
		if (trace.enthit.GetHealth() >= revivee.GetMaxHealth())
		{
			local snowball_count

			revivee.ForceRegenerateAndRespawn()
			revivee.SetHealth(revivee.GetMaxHealth() * 0.5)
			SetPropInt(revivee, "m_Shared.m_nPlayerState", 0)
		}
	}

	function stop_reviving()
	{
		if (!player.button_up(IN_ATTACK3)) return

		revive_location = null
	}
}

characterTraitsClasses.push(freeze)
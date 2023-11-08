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

	frozen_location = null
	frozen_angles = null
	first_frame_after_death = false
	dead = false

	function OnDeath(attacker, params)
	{
		frozen_location = player.GetOrigin()
		frozen_angles = player.GetAbsAngles()

		first_frame_after_death = true
		dead = true

		/*revive = reviveMarker.spawnReviveMarker(player, player.GetMaxHealth())
		revive.SetModel(player_models[player.GetPlayerClass()])
		SetPropInt(revive, "m_nSkin", revive.GetTeam() - 2)
		set_origin(revive, revive.GetOrigin() - Vector(0, 0, 40))
		revive.SetVelocity(player.GetVelocity() * 0.5)
		//if (!debug)
			SetPropInt(player, "m_Shared.m_nPlayerState", 3) // Force player to be in the dying state so that they don't respawn*/
	}

	function OnFrameTickAlive()
	{
		if (is_player_frozen(player)) return
		revive()
		stop_reviving()
	}

	function OnFrameTickAliveOrDead()
	{
		if (dead && player.GetVelocity().Length() < 10)
			player.RemoveCustomAttribute("move speed bonus")

		if (!first_frame_after_death) return

		GetPropEntity(player, "m_hRagdoll").Kill()
		player.ForceRegenerateAndRespawn()
		player.SetHealth(-player.GetMaxHealth())
		player.AddCustomAttribute("move speed bonus", 0.01, -1)
		player.AddCond(15)
		player.SetForcedTauntCam(1)
		SetPropInt(player, "movetype", 5)
		//player.AddCond(87)
		set_origin(player, frozen_location)

		first_frame_after_death = false
	}

	/*function OnFrameTickAliveOrDead()
	{
		if (IsPlayerAlive(player) || !revive) return

		try {
			revive.StopSound("Medic.AutoCallerAnnounce")
		} catch (exception){

		}
	}*/

	reviving = false

	function revive()
	{
		if (!GetPropBool(player, "m_bUsingActionSlot") || !player.IsOnGround()) return

		local trace = fire_trace
		(
			player.EyePosition(),
			player.EyePosition() + player.EyeAngles().Forward() * REVIVE_LENGTH,
			-1,
			player,
			function(entity) { return TRACE_STOP },
			true
		)

		if (!("enthit" in trace)
		 || !trace.enthit.IsPlayer()
		 || !is_player_frozen(trace.enthit)
	   /*|| trace.enthit.GetTeam() != player.GetTeam()*/)
	   		return

		reviving = true
		damage_victim(trace.enthit, player, -1, trace.endpos)

		if (trace.enthit.GetHealth() >= 0)
		{
			revive_player(trace.enthit)
		}
	}

	function revive_player(revivee)
	{
		damage_victim(revivee, revivee, -revivee.GetMaxHealth() * 0.5, revivee.GetOrigin())
	}

	function stop_reviving()
	{
		if (!reviving || GetPropBool(player, "m_bUsingActionSlot")) return

		SetPropInt(player, "movetype", 1)
		reviving = false
	}
}

::is_player_frozen <- function(player)
{
	return player.GetHealth() < 0
}

characterTraitsClasses.push(freeze)
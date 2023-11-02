local arrayReviveMarkers = []

local tReviveMarkerData = {
	fTimeSinceLastHeal = 0.0
	iPreviousHealth = 1
}

// Fill our array of revive markers with clones of our data table, for each possible player in the server
for ( local i = 0; i < MaxClients(); i++) {
	arrayReviveMarkers.append(clone tReviveMarkerData)
}

class reviveMarker {

	// This is the function you'll want to call to spawn the revive marker, the hPlayer paramater is the player handle.
	// iReviveHealth is OPTIONAL, and allows you to specify the exact amount of health is needed to revive a player. If unset or set to -1, the game handles it instead (this can be a problem because the health increases with each death in a round!)
	function spawnReviveMarker(hPlayer, iReviveHealth = -1) {
		local hReviveMarker = SpawnEntityFromTable("entity_revive_marker", {
			origin = hPlayer.GetOrigin() + Vector(0, 0, 50)
			angles = hPlayer.GetAbsAngles()
		})

		hReviveMarker.ValidateScriptScope();

		NetProps.SetPropEntity(hReviveMarker, "m_hOwner", hPlayer)
		NetProps.SetPropInt(hReviveMarker, "m_iTeamNum", hPlayer.GetTeam())
		if (iReviveHealth != -1) {
			NetProps.SetPropInt(hReviveMarker, "m_iMaxHealth", iReviveHealth)
		}
		hReviveMarker.SetBodygroup(1, hPlayer.GetPlayerClass() - 1)

		local scopeReviveMarker = hReviveMarker.GetScriptScope()

		scopeReviveMarker.reviveMarkerThink <- reviveMarkerThink;
		scopeReviveMarker.playerBeingRevived <- playerBeingRevived

		AddThinkToEnt(hReviveMarker, "reviveMarkerThink")
		return hReviveMarker
	}

	// Think function for our revive marker
	function reviveMarkerThink() {
		local hReviveMarker = self;
		local hPlayer = NetProps.GetPropEntity(hReviveMarker, "m_hOwner");
		local iPlayerIndex = hPlayer.entindex();

		if (playerBeingRevived(hReviveMarker, iPlayerIndex)) {
			// TODO: I don't think this causes any weird things to happen, but more testing may be needed
			// I'm pretty sure that the only check for a specific state (at the time of this code being used) only checks if the player is not in the dying state (if they aren't, they'll respawn)
			// But its possible that there's something i missed
			NetProps.SetPropInt(hPlayer, "m_Shared.m_nPlayerState", 3) // Force player to be in the dying state so that they don't respawn
		}

		local iPlayerLifeState = NetProps.GetPropInt( hPlayer, "m_lifeState" )

		// If our player is not dead, destroy the revive marker.
		if ( iPlayerLifeState == 0 ) {
			NetProps.SetPropInt(hPlayer, "m_Shared.m_nPlayerState", 0) // Put player back in alive state, otherwise weird things happen
			hReviveMarker.Destroy();
		}

		// We want to think every tick
		return 0;
	}

	function playerBeingRevived(hReviveMarker, iPlayerIndex) {
		if (arrayReviveMarkers[iPlayerIndex].iPreviousHealth != NetProps.GetPropInt(hReviveMarker, "m_iHealth")) {
			arrayReviveMarkers[iPlayerIndex].iPreviousHealth =  NetProps.GetPropInt(hReviveMarker, "m_iHealth"); // Set the previous health to our current health for the next time around
			arrayReviveMarkers[iPlayerIndex].fTimeSinceLastHeal = 0.0; // Reset the time since last heal
		}
		else {
			arrayReviveMarkers[iPlayerIndex].fTimeSinceLastHeal += FrameTime(); // Add this tick to the time since last healed
		}

		if (arrayReviveMarkers[iPlayerIndex].fTimeSinceLastHeal >= 2.0) {
			return false;
		}

		return true;
	}
}
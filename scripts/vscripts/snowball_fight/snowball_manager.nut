// track all snowballs rolling around on the ground and give them to players who collide with them

::snowballs <- []

MAX_SNOWBALLS <- 36

AddListener("tick_frame", 0, function()
{
	remove_extra_snowballs()
	// remove snowballs after time alive? (need to track time then)
	//player_pickup_snowball()
})

function remove_extra_snowballs()
{
	while (snowballs.len() > MAX_SNOWBALLS)
		snowballs.remove(0).Kill()
}

next_frame_check_for_win <- false

AddListener("tick_frame", 1, function()
{
	if (!next_frame_check_for_win) return

	local red_dead = true
	local blu_dead = true

	foreach(red in red_players)
		if (!is_player_frozen(red))
		{
			red_dead = false
			break
		}

	foreach(blu in blu_players)
		if(!is_player_frozen(blu))
		{
			blu_dead = false
			break
		}

	// tie?
	if (red_dead && blu_dead)
		EndRound(TF_TEAM_UNASSIGNED)
	else if (red_dead)
		EndRound(TF_TEAM_BLUE)
	else if (blu_dead)
		EndRound(TF_TEAM_RED)

	next_frame_check_for_win = false
})

// if everyone on a team is frozen, end round
AddListener("death", 1, function(attacker, victim, params)
{
	next_frame_check_for_win = true
})

isRoundOver <- false
// stolen from vsh/_gamemode/round_logic.nut
function EndRound(winner)
{
    if (isRoundOver)
        return;

    /*if (!IsAnyBossAlive() && IsRoundSetup())
        winner = TF_TEAM_UNASSIGNED;*/

    local roundWin = Entities.FindByClassname(null, "game_round_win");
    if (roundWin == null)
    {
        roundWin = SpawnEntityFromTable("game_round_win",
        {
            win_reason = "0",
            force_map_reset = "1", //not having
            TeamNum = "0",         //these 3 lines
            switch_teams = "0"     //causes the crash when trying to fire game_round_win
        });
    }
    EntFireByHandle(roundWin, "SetTeam", "" + winner, 0, null, null);
    EntFireByHandle(roundWin, "RoundWin", "", 0, null, null);

    /*DoEntFire("vsh_round_end*", "Trigger", "", 0, null, null);
    if (winner == TF_TEAM_MERCS)
        DoEntFire("vsh_mercs_win*", "Trigger", "", 0, null, null);
    else
        DoEntFire("vsh_boss_win*", "Trigger", "", 0, null, null);*/
    FireListeners("round_end", winner);
    isRoundOver = true;
    SetPersistentVar("last_round_winner", winner)
}
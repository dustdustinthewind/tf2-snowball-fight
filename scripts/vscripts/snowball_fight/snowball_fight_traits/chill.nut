class chill extends CharacterTrait
{

    function OnApply()
    {
        last_frame_hp = player.GetMaxHealth()
    }

    function OnFrameTickAlive()
    {
		// frozen, wait for revive
		if (is_player_frozen(player)) return

        regen_health()

        slow_down()
    }

    last_regen = 0
    REGEN_COOLDOWN = 1
    regen_amount = 2

    function regen_health()
    {
        if (Time() < last_regen + REGEN_COOLDOWN
			|| player.GetHealth() == player.GetMaxHealth()
			|| player.GetPlayerClass() == 5 /*medic*/)
				return

        last_regen = Time()
        player.SetHealth(player.GetHealth() + regen_amount)
    }

    last_frame_hp = 0

    function slow_down()
    {
        if (player.GetHealth() == last_frame_hp) return

        local hp_percentage = max(0.6, 1.0*player.GetHealth() / player.GetMaxHealth())
        player.AddCustomAttribute("move speed bonus", hp_percentage, -1)

		// indicate we've slowed
		if (hp_percentage < 0.9)
			player.AddCond(15)
		else
			player.RemoveCond(15)

        last_frame_hp = player.GetHealth()
    }
}

characterTraitsClasses.push(chill)
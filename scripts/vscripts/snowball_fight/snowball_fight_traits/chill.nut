class chill extends CharacterTrait
{

    function OnApply()
    {
        last_frame_hp = player.GetMaxHealth()
        player.AddCustomAttribute("SET BONUS: health regen set bonus", 10, -1)
    }

    function OnFrameTickAlive()
    {
        regen_health()

        slow_down()
    }

    last_regen = 0
    REGEN_COOLDOWN = 1
    regen_amount = 2

    function regen_health()
    {
        if (Time() < last_regen + REGEN_COOLDOWN || player.GetHealth() == player.GetMaxHealth()) return

        last_regen = Time()
        player.SetHealth(player.GetHealth() + regen_amount)
    }

    last_frame_hp = 0

    function slow_down()
    {
        if (player.GetHealth() == last_frame_hp) return

        local hp_percentage = max(0.6, 1.0*player.GetHealth() / player.GetMaxHealth())
        player.AddCustomAttribute("move speed bonus", hp_percentage, -1)

        last_frame_hp = player.GetHealth()
    }
}

characterTraitsClasses.push(chill)
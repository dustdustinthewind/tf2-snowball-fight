::baseball_projectile_model <- "models/weapons/w_models/w_baseball.mdl"

PrecacheModel(baseball_projectile_model)

class snowball extends hsdm_trait
{
    function OnApply()
    {
        local melee = player.GetWeaponBySlot(2)
        player.Weapon_Switch(melee)
        SetPropFloat(melee, "m_flNextPrimaryAttack", Time() + 9999)
        SetPropFloat(melee, "m_flNextSecondaryAttack", Time() + 9999)
        player.AddCond(TF_COND_CANNOT_SWITCH_FROM_MELEE)
    }
    
    function OnFrameTickAlive()
    {
        push_snowball()
        charge_snowball()
        release_snowball()
    }

    first_frame_after_throw = false

    function push_snowball()
    {
        if (!first_frame_after_throw) return
        first_frame_after_throw = false
        snowball_projectile.ApplyAbsVelocityImpulse(player.EyeAngles().Forward() * 1000)
    }

    charge_time = 0
    MAX_CHARGE = 2


    function charge_snowball()
    {
        if (!player.button_down(IN_ATTACK)) return

        charge_time += FrameTime()

        // animation of pulling snowball back
    }

    snowball_projectile = null

    function release_snowball()
    {
        if (!player.button_released(IN_ATTACK)) return

        snowball_projectile = Entities.CreateByClassname("tf_projectile_flare")
        
        snowball_projectile.SetModel(baseball_projectile_model)
        SetPropInt(snowball_projectile, "movecollide", 1)
        //SetPropInt(snowball_projectile, "m_iProjectileType", 26)
        snowball_projectile.SetCollisionGroup(13)
        snowball_projectile.SetMoveType(5, 1)
        set_origin(snowball_projectile, player.EyePosition())
        snowball_projectile.SetAbsAngles(player.EyeAngles())
        snowball_projectile.SetTeam(player.GetTeam())
        snowball_projectile.SetOwner(player)
        first_frame_after_throw = true

        //player.EmitSound("throw_snowball")
        //can_fire_next = Time() + SNOWBALL_COOLDOWN
    }
}

characterTraitsClasses.push(snowball)
::baseball_projectile_model <- "models/weapons/w_models/w_baseball.mdl"

PrecacheModel(baseball_projectile_model)

BASE_DAMAGE <- 80.0

class snowball extends hsdm_trait
{
    weapon = null

    snowballs = []
    snowball_dmg = []

    function OnApply()
    {
        weapon = player.GetWeaponBySlot(2)
        player.Weapon_Switch(weapon)
        SetPropFloat(weapon, "m_flNextPrimaryAttack", Time() + 9999)
        SetPropFloat(weapon, "m_flNextSecondaryAttack", Time() + 9999)
        if (!debug)
            player.AddCond(TF_COND_CANNOT_SWITCH_FROM_MELEE)
    }
    
    function OnFrameTickAlive()
    {
        // throwing snowball
        push_snowball()
        charge_snowball()
        release_snowball()

        // collision
        snowball_collide_with_player()
    }

    first_frame_after_throw = false

    function push_snowball()
    {
        if (!first_frame_after_throw) return
        
        first_frame_after_throw = false
        snowball_projectile.ApplyAbsVelocityImpulse
        (
            (player.EyeAngles() + QAngle(-4, 0.64, 0)).Forward()
            * 1666
            * max(0.5, charge_time)
        )
        
        snowballs.push(snowball_projectile)
        snowball_dmg.push(max(BASE_DAMAGE, BASE_DAMAGE*charge_time))
        snowball_projectile = null
        charge_time = 0
        last_charge_time = 0
    }

    charge_time = 0
    last_charge_time = 0
    MAX_CHARGE = 2

    function charge_snowball()
    {
        if (!player.button_down(IN_ATTACK)) return

        charge_time += FrameTime()
        charge_time = min(charge_time, MAX_CHARGE)
        if (charge_time - last_charge_time > 0.1)
        {
            player.AddCustomAttribute("move speed penalty", clamp(0.1, 1, 1.0/charge_time/MAX_CHARGE), -1)
            last_charge_time = charge_time
        }    

        // animation of pulling snowball back
    }

    snowball_projectile = null

    function release_snowball()
    {
        if (!player.button_released(IN_ATTACK)) return

        snowball_projectile = Entities.CreateByClassname("tf_projectile_stun_ball")
        //Entities.DispatchSpawn(snowball_projectile)

        snowball_projectile.SetModel(baseball_projectile_model)
        SetPropInt(snowball_projectile, "movecollide", 1)
        SetPropEntity(snowball_projectile, "m_hEffectEntity", player)
        snowball_projectile.SetCollisionGroup(13)
        snowball_projectile.SetMoveType(5, 1)
        //snowball_projectile.SetSolid(3)
        set_origin(snowball_projectile, player.EyePosition() - player.GetLeftVector() * -10)
        snowball_projectile.SetTeam(player.GetTeam())
        snowball_projectile.SetOwner(player)

        first_frame_after_throw = true

        player.RemoveCustomAttribute("move speed penalty")

        //player.EmitSound("throw_snowball")
        //can_fire_next = Time() + SNOWBALL_COOLDOWN
    }

    function snowball_collide_with_player()
    {
        local to_destroy = []
        for (local i = 0; i < snowballs.len(); i++)
        {
            local player = player

            local trace = fire_trace_hull
            (
                snowballs[i].GetOrigin(),
                snowballs[i].GetOrigin(),
                1107296257,
                snowballs[i],
                snowballs[i].GetBoundingMins() * 2,
                snowballs[i].GetBoundingMaxs() * 2,
                function(entity)
                {
                    if (entity != player)
                        return TRACE_STOP
                    return TRACE_CONTINUE
                },
                false
            )
            
            if ("enthit" in trace)
            {
                if (trace.enthit.GetClassname() == "player" && trace.enthit.GetTeam() != player.GetTeam())
                {
                    slow_and_damage(trace.enthit, player, snowball_dmg[i], snowballs[i].GetOrigin())
                    to_destroy.push(snowballs[i])
                    snowball_dmg.remove(i)
                }
                snowballs.remove(i)
            }
        }

        foreach (snowball in to_destroy)
            snowball.Destroy()
    }
}

slow_and_damage <- function(victim, player, damage, origin)
{
    victim.TakeDamageCustom
    (
        player,
        player,
        null,
        Vector(0,0,0),
        origin,
        damage,
        32768,
        22
    )
}

characterTraitsClasses.push(snowball)
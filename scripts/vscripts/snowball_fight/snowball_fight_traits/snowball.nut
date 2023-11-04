::baseball_projectile_model <- "models/weapons/w_models/w_baseball.mdl"

PrecacheModel(baseball_projectile_model)

WEAK_CHARGE <- 0.5
FULL_CHARGE <- 1.75
MAX_CHARGE <- 2

WEAK_HIT_DMG <- 1.0 / 2.5
REG_HIT_DMG  <- 1.0 / 1.5
FULL_HIT_DMG_BONUS <- 25

SNOWBALL_COOLDOWN <- 0.8

class snowball extends CharacterTrait
{
    weapon = null

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
    }

    function OnFrameTickAliveOrDead()
    {
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
            ((player.EyeAngles() + QAngle(-4, 0.64, 0)).Forward()
            * 1024
            * max(0.5, last_charge_time))
            + (player.GetVelocity() * 0.5)
        )
    }

    charge_time = 0.0
    last_charge_time = 0

    function charge_snowball()
    {
        if (!player.button_down(IN_ATTACK) || !can_fire) return

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
    can_fire = true
	can_fire_next = 0

    function release_snowball()
    {
        if (Time() < can_fire_next || !player.button_released(IN_ATTACK) || !can_fire) return

        snowball_projectile = Entities.CreateByClassname("tf_projectile_stun_ball")
        //Entities.DispatchSpawn(snowball_projectile) doing this makes it act like sandman ball, how to remove properties?

        snowball_projectile.SetModel(baseball_projectile_model)
        SetPropInt(snowball_projectile, "movecollide", 1)
        SetPropEntity(snowball_projectile, "m_hEffectEntity", player)
        snowball_projectile.SetCollisionGroup(13)
        snowball_projectile.SetMoveType(5, 1)
        //snowball_projectile.SetSolid(3) bounces off players (maybe for demo stickyballs)
        set_origin(snowball_projectile, player.EyePosition() - player.GetLeftVector() * -10)
		snowball_projectile.ApplyLocalAngularVelocityImpulse(Vector(RandomInt(-1000, 1000), RandomInt(-1000, 1000), RandomInt(-1000, 1000)))
        snowball_projectile.SetTeam(player.GetTeam())
        snowball_projectile.SetOwner(player)

        first_frame_after_throw = true
        can_fire = false

        player.RemoveCustomAttribute("move speed penalty")

        //player.EmitSound("throw_snowball")
        can_fire_next = Time() + SNOWBALL_COOLDOWN
    }

    function snowball_collide_with_player()
    {
        if (!snowball_projectile) return

        local player = player

        local trace = fire_trace_hull
        (
            snowball_projectile.GetOrigin(),
            snowball_projectile.GetOrigin(),
            1107296257,
            snowball_projectile,
            snowball_projectile.GetBoundingMins() * 2,
            snowball_projectile.GetBoundingMaxs() * 2,
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
			local to_manager = true
            if (trace.enthit.GetClassname() == "player" && trace.enthit.GetTeam() != player.GetTeam())
            {
				local damage = last_charge_time < WEAK_CHARGE
								? WEAK_HIT_DMG
								: REG_HIT_DMG

				local dmg_bonus = last_charge_time >= FULL_CHARGE ? FULL_HIT_DMG_BONUS : 0

                damage_victim
                (
                    trace.enthit,
                    player,
                    (damage * trace.enthit.GetMaxHealth()) + dmg_bonus,
                    snowball_projectile.GetOrigin()
                )
                snowball_projectile.Destroy()
				to_manager = false
            }

			if (to_manager)
				snowballs.push(snowball_projectile)
            snowball_hit_something()
        }
        else if (!first_frame_after_throw && snowball_projectile.GetVelocity().Length() < 10)
        {
			snowballs.push(snowball_projectile)
            snowball_hit_something()
        }
    }

    function snowball_hit_something()
    {
        snowball_projectile = null
        can_fire = true
        charge_time = 0.0
        last_charge_time = 0
    }
}

damage_victim <- function(victim, player, damage, origin)
{	victim.SetHealth(victim.GetHealth() - damage + 1)
    victim.TakeDamageCustom
    (
        player,
        player,
        null,
        Vector(0,0,0),
        origin,
        0.2,
        32768,
        22
    )
}

characterTraitsClasses.push(snowball)
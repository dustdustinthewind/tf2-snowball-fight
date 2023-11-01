// todo find link
::CBaseAnimating.look_at <- function(meseeks)
{
	local to_look = meseeks - this.GetOrigin()
	to_look.Norm()
	this.SetAbsAngles(VectorAngles(to_look))
}

// TF2Maps discord
// https://discord.com/channels/217585440457228290/1039243316920844428/1149256041155002440
::VectorAngles <- function(forward)
{
    local yaw, pitch
    if ( forward.y == 0.0 && forward.x == 0.0 )
    {
        yaw = 0.0
        if (forward.z > 0.0)
            pitch = 270.0
        else
            pitch = 90.0
    }
    else
    {
        yaw = (atan2(forward.y, forward.x) * 180.0 / Constants.Math.Pi)
        if (yaw < 0.0)
            yaw += 360.0
        pitch = (atan2(-forward.z, forward.Length2D()) * 180.0 / Constants.Math.Pi)
        if (pitch < 0.0)
            pitch += 360.0
    }

    return QAngle(pitch, yaw, 0.0)
}

::stop_thinking <- function(entity)
{
	AddThinkToEnt(entity, null)
}

::lerp <- function(to, from, smooth)
{
	return from + (to - from) * smooth
}

::clamp <- function(min, max, value)
{
	return (min > value) ? min : (value > max ? max : value)
}

::min <- function(v1, v2)
{
	return v1 < v2 ? v1 : v2
}

::max <- function(v1, v2)
{
	return v1 > v2 ? v1 : v2
}

::set_origin <- function(entity, origin)
{
    local frame = NetProps.GetPropInt(entity, "m_ubInterpolationFrame");
    entity.SetOrigin(origin);
    NetProps.SetPropInt(entity, "m_ubInterpolationFrame", frame);
}

Include("/util/trace_helpers.nut")
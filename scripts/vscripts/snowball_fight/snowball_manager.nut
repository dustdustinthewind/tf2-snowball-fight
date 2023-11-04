// track all snowballs rolling around on the ground and give them to players who collide with them

::snowballs <- []

MAX_SNOWBALLS <- 36

AddListener("tick_frame", 0, function()
{
	remove_extra_snowballs()
	// remove snowballs after time alive? (need to track time then)
	player_pickup_snowball()
})

function remove_extra_snowballs()
{
	while (snowballs.len() > MAX_SNOWBALLS)
		snowballs.remove(0).Kill()
}

// could be performance expensive
function player_pickup_snowball()
{
	foreach (index, snowball in snowballs)
	{
		printl("hello")
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
			if (trace.enthit.GetClassname() == "player" && trace.enthit.GetTeam() != player.GetTeam())
			{
				snowballs.remove(index).Kill()
				// give snowball to player
			}
		}
	}
}
// track all snowballs rolling around on the ground and give them to players who collide with them

::snowballs <- []

MAX_SNOWBALLS <- 36

AddListener("tick_frame", 0, function()
{
	remove_extra_snowballs()
	// remove snowballs after time alive? (need to track time then)
	player_pickup_snowball(
})

function remove_extra_snowballs()
{
	while (snowballs.len() > MAX_SNOWBALLS)
		snowballs.remove(0).Kill()
}

// could be performance expensive
function player_pickup_snowball()
{

}
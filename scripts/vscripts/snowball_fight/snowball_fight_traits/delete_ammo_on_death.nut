characterTraitsClasses.push(class extends CharacterTrait
{
	function OnDeath(attacker, params)
	{
		local ammo_pack = null
		while (ammo_pack = Entities.FindByClassname(ammo_pack, "tf_ammo_pack"))
			if (ammo_pack.GetOwner() == player)
			{
				// vote to kill the imposter
				ammo_pack.Kill()

				// todo: drop snowball(s)
				break
			}
	}
})
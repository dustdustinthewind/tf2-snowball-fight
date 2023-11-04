weapons_and_traits <- [
	"snowball.nut"
	"chill.nut"
	"freeze.nut"

	"delete_ammo_on_death.nut"
]

foreach (file in weapons_and_traits)
	Include("snowball_fight_traits/" + file)
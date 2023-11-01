weapons_and_traits <- [
	"hsdm_trait.nut"

	"snowball.nut"
	"chill.nut"
]

foreach (file in weapons_and_traits)
	Include("snowball_fight_traits/" + file)
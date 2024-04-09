/area/oscar_outpost
	name = "Oscar Outpost"
	icon_state = "green"
	ceiling = CEILING_METAL

/area/oscar_outpost/base
	name = "Oscar Outpost Staging Area"
	icon_state = "north"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	outside = FALSE

/area/oscar_outpost/outside
	name = "Unused"
	icon_state = "green"
	ceiling = CEILING_NONE

	requires_power = TRUE
	always_unpowered = TRUE
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	outside = TRUE

/area/oscar_outpost/outside/north
	name = "Oscar Outpost North"
	icon_state = "north"

/area/oscar_outpost/outside/west
	name = "Oscar Outpost West"
	icon_state = "west"

/area/oscar_outpost/outside/east
	name = "Oscar Outpost East"
	icon_state = "east"

/area/oscar_outpost/outside/northeast
	name = "Oscar Outpost Northeast"
	icon_state = "east"

/area/oscar_outpost/outside/northwest
	name = "Oscar Outpost Northwest"
	icon_state = "west"

/area/oscar_outpost/outside/south
	name = "Oscar Outpost South"
	icon_state = "south"

/area/oscar_outpost/outside/underground
	name = "Oscar Outpost Underground"
	icon_state = "south"
	ceiling = CEILING_DEEP_UNDERGROUND

/area/oscar_outpost/outside/rock
	name = "Enclosed Area"
	icon_state = "transparent"
	ceiling = CEILING_DEEP_UNDERGROUND

/area/oscar_outpost/outside/road
	name = "Oscar Outpost Roadway"
	icon_state = "south"

/area/oscar_outpost/village
	name = "Oscar Outpost Northern Village"
	icon_state = "green"
	ceiling = CEILING_METAL
	outside = TRUE

/area/oscar_outpost/village/south
	name = "Oscar Outpost Southern Village"
	icon_state = "green"
	ceiling = CEILING_METAL

/area/oscar_outpost/village/east
	name = "Oscar Outpost Eastern Village"
	icon_state = "green"
	ceiling = CEILING_METAL

/area/oscar_outpost/village/central
	name = "Oscar Outpost Eastern Village"
	icon_state = "green"
	ceiling = CEILING_METAL

/area/oscar_outpost/village/fairgrounds
	name = "Oscar Outpost Fairgrounds"
	icon_state = "green"
	ceiling = CEILING_NONE

/area/oscar_outpost/village/abandonedbase
	name = "Oscar Outpost Base Zeta"
	icon_state = "green"
	ceiling = CEILING_UNDERGROUND_METAL
	outside = FALSE

/area/oscar_outpost/village/abandonedbase/tadlandingzone
	name = "Oscar Outpost Base Zeta Landing Zone"
	icon_state = "green"
	ceiling = CEILING_NONE
	outside = TRUE

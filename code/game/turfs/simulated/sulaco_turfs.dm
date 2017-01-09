//Sulaco walls. They use wall instead of shuttle code so they overlap and we can do fun stuff to them without using unsimulated shuttle things.
/turf/simulated/wall/sulaco
	name = "spaceship hull"
	desc = "A huge chunk of metal used to separate rooms on spaceships from the cold void of space."
	icon = 'icons/turf/walls.dmi'
	icon_state = "sulaco0"
	hull = 0 //Can't be deconstructed

	damage_cap = 8000 //As tough as R_walls.
	max_temperature = 28000 //K, walls will take damage if they're next to a fire hotter than this
	walltype = "sulaco" //Changes all the sprites and icons.
/*
	attackby(obj/item/W as obj, mob/user as mob) //Can't be dismantled, thermited, etc. Can be xeno-acided still.
		user << "This wall is much too tough for you to do anything to with [W]."
		return
*/

/turf/simulated/wall/sulaco/ex_act(severity)
	switch(severity)
		if(1.0)
			src.ChangeTurf(/turf/simulated/floor/plating)
		if(2.0)
			if(prob(75))
				take_damage(rand(100, 250))
			else
				dismantle_wall(1,1)
		if(3.0)
			take_damage(rand(0, 250))
	return

/turf/simulated/wall/sulaco/hull
	name = "outer hull"
	desc = "A reinforced outer hull, probably to prevent breaches"
	hull = 1

	damage_cap = 20000 // Tougher than a reinforced wall
	max_temperature = 50000 // Nearly impossible to melt
	walltype = "sulaco"

/turf/simulated/wall/sulaco/unmeltable

	ex_act(severity) //Should make it indestructable
		return

	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		return

	attackby() //This should fix everything else. No cables, etc
		return

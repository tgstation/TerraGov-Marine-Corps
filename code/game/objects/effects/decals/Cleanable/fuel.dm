/obj/effect/decal/cleanable/liquid_fuel
	//Liquid fuel is used for things that used to rely on volatile fuels or phoron being contained to a couple tiles.
	icon = 'icons/effects/effects.dmi'
	icon_state = "fuel"
	layer = ABOVE_TURF_LAYER
	anchored = 1
	var/amount = 1 //Basically moles.

/obj/effect/decal/cleanable/liquid_fuel/Initialize(turf/newLoc, amt = 1, nologs = 0)
	if(!nologs)
		log_game("[amt] units of liquid fuel have spilled in [AREACOORD(newLoc.loc)].")
		message_admins("[amt] units of liquid fuel have spilled in [ADMIN_VERBOSEJMP(newLoc.loc)].")
	amount = amt

	//Be absorbed by any other liquid fuel in the tile.
	for(var/obj/effect/decal/cleanable/liquid_fuel/other in newLoc)
		if(other != src)
			src.amount += other.amount
			qdel(other)

	Spread()
	. = ..()

/obj/effect/decal/cleanable/liquid_fuel/proc/Spread()
	//Allows liquid fuels to sometimes flow into other tiles.
	if(amount < 5.0) 
		return
	var/turf/S = loc
	if(!istype(S)) 
		return
	for(var/d in cardinal)
		if(rand(25))
			var/turf/target = get_step(src,d)
			var/turf/origin = get_turf(src)
			if(origin.CanPass(null, target) && target.CanPass(null, origin))
				if(!locate(/obj/effect/decal/cleanable/liquid_fuel) in target)
					new/obj/effect/decal/cleanable/liquid_fuel(target, amount * 0.25, 1)
					amount *= 0.75

/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel
	icon_state = "mustard"
	anchored = 0

/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel/Initialize(newLoc, amt = 1, d = 0)
	setDir(d) //Setting this direction means you won't get torched by your own flamethrower.
	. = ..()

/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel/Spread()
	//The spread for flamethrower fuel is much more precise, to create a wide fire pattern.
	if(amount < 0.1) 
		return
	var/turf/S = loc
	if(!istype(S)) 
		return

	for(var/d in list(turn(dir,90),turn(dir,-90), dir))
		var/turf/O = get_step(S,d)
		if(locate(/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel) in O)
			continue
		if(O.CanPass(null, S) && S.CanPass(null, O))
			new/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel(O, amount * 0.25, 1)

	amount *= 0.25

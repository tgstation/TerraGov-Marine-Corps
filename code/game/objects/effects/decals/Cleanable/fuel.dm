/obj/effect/decal/cleanable/liquid_fuel
	//Liquid fuel is used for things that used to rely on volatile fuels or phoron being contained to a couple tiles.
	icon = 'icons/effects/effects.dmi'
	icon_state = "fuel"
	layer = ABOVE_TURF_LAYER
	anchored = TRUE
	var/amount = 1 //Basically moles.
	var/spread_fail_chance = 75 //percent


/obj/effect/decal/cleanable/liquid_fuel/Initialize(mapload, amt = 1, logs = TRUE, newDir = 0)
	..()
	if(logs)
		log_game("[amt] units of liquid fuel have spilled in [AREACOORD(loc.loc)].")
		message_admins("[amt] units of liquid fuel have spilled in [ADMIN_VERBOSEJMP(loc.loc)].")
	amount = amt
	setDir(newDir)
	return INITIALIZE_HINT_LATELOAD


/obj/effect/decal/cleanable/liquid_fuel/LateInitialize()
	. = ..()
	for(var/obj/effect/decal/cleanable/liquid_fuel/other in loc)
		if(other == src || other.type != type)
			continue
		amount += other.amount
		qdel(other)
	fuel_spread()


/obj/effect/decal/cleanable/liquid_fuel/proc/fuel_spread()
	//Allows liquid fuels to sometimes flow into other tiles.
	if(amount < 5) 
		return
	var/turf/S = get_turf(src)
	var/spread_dirs = (dir == 0) ? CARDINAL_DIRS : list(turn(dir,90), turn(dir,-90), dir)
	var/successful_spread = 0
	var/slice_per_transfer = round(1 / (length(spread_dirs) + 1), 0.01)
	for(var/D in spread_dirs)
		if(spread_fail_chance)
			continue
		var/turf/T = get_step(S, D)
		if(locate(type) in T)
			continue
		if(!S.CanPass(null, T) || !T.CanPass(null, S))
			continue
		new type(T, amount * slice_per_transfer, FALSE, D)
		successful_spread++
	amount *= max(0, 1 - (successful_spread * slice_per_transfer))


/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel
	icon_state = "mustard"
	spread_fail_chance = 0 //percent
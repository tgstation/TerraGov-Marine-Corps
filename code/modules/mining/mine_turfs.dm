/**********************Mineral deposits**************************/


/turf/simulated/mineral //wall piece
	name = "Rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	oxygen = 20
	nitrogen = 80
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = T20C
	var/mineral/mineral
	var/mined_ore = 0
	var/last_act = 0
	var/next_rock = 0
	has_resources = 1

/turf/simulated/mineral/New()

	MineralSpread()

	spawn(2)
		var/list/step_overlays = list("s" = NORTH, "n" = SOUTH, "w" = EAST, "e" = WEST)
		for(var/direction in step_overlays)
			var/turf/turf_to_check = get_step(src,step_overlays[direction])

			if(istype(turf_to_check,/turf/simulated/floor/plating/airless/asteroid))
				var/turf/simulated/floor/plating/airless/asteroid/T = turf_to_check
				T.updateMineralOverlays()

			else if(istype(turf_to_check,/turf/space) || istype(turf_to_check,/turf/simulated/floor) || istype(turf_to_check,/turf/unsimulated/floor))
				turf_to_check.overlays += image('icons/turf/walls.dmi', "rock_side_[direction]", 2.99) //Really high since it's an overhead turf and it shouldn't collide with anything else

/turf/simulated/mineral/ex_act(severity)
	switch(severity)
		if(2.0)
			if (prob(70))
				mined_ore = 1 //some of the stuff gets blown up
				GetDrilled()
		if(1.0)
			mined_ore = 2 //some of the stuff gets blown up
			GetDrilled()

/turf/simulated/mineral/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/weapon/pickaxe)) && (!H.hand))
			attackby(H.l_hand,H)
		else if((istype(H.r_hand,/obj/item/weapon/pickaxe)) && H.hand)
			attackby(H.r_hand,H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/weapon/pickaxe))
			attackby(R.module_active,R)

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)

/turf/simulated/mineral/proc/MineralSpread()
	if(mineral && mineral.spread)
		for(var/trydir in cardinal)
			if(prob(mineral.spread_chance))
				var/turf/simulated/mineral/random/target_turf = get_step(src, trydir)
				if(istype(target_turf) && !target_turf.mineral)
					target_turf.mineral = mineral
					target_turf.UpdateMineral()
					target_turf.MineralSpread()


/turf/simulated/mineral/proc/UpdateMineral()
	if(!mineral)
		name = "\improper Rock"
		icon_state = "rock"
		return
	name = "\improper [mineral.display_name] deposit"
	overlays.Cut()
	overlays += "rock_[mineral.name]"

//Not even going to touch this pile of spaghetti
/turf/simulated/mineral/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		var/obj/item/weapon/pickaxe/P = W
		if(last_act + P.digspeed > world.time)//prevents message spam
			return
		last_act = world.time

		playsound(user, P.drill_sound, 25, 1)

		user << "\red You start [P.drill_verb]."

		if(do_after(user,P.digspeed))
			user << "\blue You finish [P.drill_verb] the rock."

			//drop some rocks
			next_rock += P.excavation_amount * 10
			while(next_rock > 100)
				next_rock -= 100
				new /obj/item/weapon/ore(src)

	else
		return attack_hand(user)

/turf/simulated/mineral/proc/DropMineral()
	if(!mineral)
		return

	var/obj/item/weapon/ore/O = new mineral.ore (src)
	return O

/turf/simulated/mineral/proc/GetDrilled(var/artifact_fail = 0)
	//var/destroyed = 0 //used for breaking strange rocks
	if (mineral && mineral.result_amount)

		//if the turf has already been excavated, some of it's ore has been removed
		for (var/i = 1 to mineral.result_amount - mined_ore)
			DropMineral()

	var/list/step_overlays = list("n" = NORTH, "s" = SOUTH, "e" = EAST, "w" = WEST)

	//Add some rubble,  you did just clear out a big chunk of rock.
	var/turf/simulated/floor/plating/airless/asteroid/N = ChangeTurf(/turf/simulated/floor/plating/airless/asteroid)
	N.overlay_detail = "asteroid[rand(0,9)]"

	// Kill and update the space overlays around us.
	for(var/direction in step_overlays)
		var/turf/space/T = get_step(src, step_overlays[direction])
		if(istype(T))
			T.overlays.Cut()
			for(var/next_direction in step_overlays)
				if(istype(get_step(T, step_overlays[next_direction]),/turf/simulated/mineral))
					T.overlays += image('icons/turf/walls.dmi', "rock_side_[next_direction]")

	// Update the
	N.updateMineralOverlays(1)

	if(rand(1,500) == 1)
		visible_message("<span class='notice'>An old dusty crate was buried within!</span>")
		new /obj/structure/closet/crate/secure/loot(src)


/turf/simulated/mineral/random
	name = "Mineral deposit"
	var/mineralSpawnChanceList = list("Uranium" = 5, "Platinum" = 5, "Iron" = 35, "Coal" = 35, "Diamond" = 1, "Gold" = 5, "Silver" = 5, "Phoron" = 10)
	var/mineralChance = 10  //means 10% chance of this plot changing to a mineral deposit

/turf/simulated/mineral/random/New()
	if (prob(mineralChance) && !mineral)
		var/mineral_name = pickweight(mineralSpawnChanceList) //temp mineral name

		if(!name_to_mineral)
			SetupMinerals()

		if (mineral_name && mineral_name in name_to_mineral)
			mineral = name_to_mineral[mineral_name]
			UpdateMineral()

	. = ..()

/turf/simulated/mineral/random/high_chance
	mineralChance = 25
	mineralSpawnChanceList = list("Uranium" = 10, "Platinum" = 10, "Iron" = 20, "Coal" = 20, "Diamond" = 2, "Gold" = 10, "Silver" = 10, "Phoron" = 20)


/**********************Asteroid**************************/


/turf/simulated/floor/plating/airless/asteroid //floor piece
	name = "asteroid"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	oxygen = 20
	nitrogen = 80
//	temperature = T0C
	temperature = T20C //<---This should be fixed later.
	icon_plating = "asteroid"
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug
	var/overlay_detail
	has_resources = 1

/turf/simulated/floor/plating/airless/asteroid/New()

	if(prob(20))
		overlay_detail = "asteroid[rand(0,9)]"

/turf/simulated/floor/plating/airless/asteroid/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				gets_dug()
		if(1.0)
			gets_dug()
	return

/turf/simulated/floor/plating/airless/asteroid/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(!W || !user)
		return 0

	var/list/usable_tools = list(
		/obj/item/weapon/shovel,
		/obj/item/weapon/pickaxe/diamonddrill,
		/obj/item/weapon/pickaxe/drill,
		/obj/item/weapon/pickaxe/borgdrill
		)

	var/valid_tool
	for(var/valid_type in usable_tools)
		if(istype(W,valid_type))
			valid_tool = 1
			break

	if(valid_tool)
		if (dug)
			user << "\red This area has already been dug"
			return

		var/turf/T = user.loc
		if (!(istype(T)))
			return

		user << "\red You start digging."
		playsound(user.loc, 'sound/effects/rustle1.ogg', 25, 1)

		if(!do_after(user,40)) return

		user << "\blue You dug a hole."
		gets_dug()

	else if(istype(W,/obj/item/weapon/storage/bag/ore))
		var/obj/item/weapon/storage/bag/ore/S = W
		if(S.collection_mode)
			for(var/obj/item/weapon/ore/O in contents)
				O.attackby(W,user)
				return
	else
		return ..(W,user)


/turf/simulated/floor/plating/airless/asteroid/proc/gets_dug()

	if(dug)
		return

	for(var/i=0;i<(rand(3)+2);i++)
		new/obj/item/weapon/ore/glass(src)

	dug = 1
	icon_plating = "asteroid_dug"
	icon_state = "asteroid_dug"
	return

/turf/simulated/floor/plating/airless/asteroid/proc/updateMineralOverlays(var/update_neighbors)

	overlays.Cut()

	var/list/step_overlays = list("n" = NORTH, "s" = SOUTH, "e" = EAST, "w" = WEST)
	for(var/direction in step_overlays)

		if(istype(get_step(src, step_overlays[direction]), /turf/space))
			overlays += image('icons/turf/floors.dmi', "asteroid_edge_[direction]")

		if(istype(get_step(src, step_overlays[direction]), /turf/simulated/mineral))
			overlays += image('icons/turf/walls.dmi', "rock_side_[direction]")

	if(overlay_detail) overlays += overlay_detail

	if(update_neighbors)
		var/list/all_step_directions = list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST)
		for(var/direction in all_step_directions)
			var/turf/simulated/floor/plating/airless/asteroid/A
			if(istype(get_step(src, direction), /turf/simulated/floor/plating/airless/asteroid))
				A = get_step(src, direction)
				A.updateMineralOverlays()

/turf/simulated/floor/plating/airless/asteroid/Entered(atom/movable/M as mob|obj)
	..()
	return

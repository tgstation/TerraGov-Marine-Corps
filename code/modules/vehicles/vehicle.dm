/obj/vehicle
	name = "vehicle"
	icon = 'icons/obj/vehicles.dmi'
	layer = ABOVE_MOB_LAYER //so it sits above objects including mobs
	density = TRUE
	anchored = TRUE
	animate_movement = FORWARD_STEPS
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL
	resistance_flags = XENO_DAMAGEABLE

	var/on = FALSE
	max_integrity = 100
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = FALSE	//Maint panel
	var/locked = TRUE
	var/stat = 0
	var/powered = FALSE		//set if vehicle is powered and should use fuel when moving
	var/move_delay = 1	//set this to limit the speed of the vehicle
	var/buckling_y = 0
	var/move_sounds
	var/change_dir_sounds
	var/vehicle_flags = NONE

	var/obj/item/cell/cell
	var/charge_use = 5	//set this to adjust the amount of power the vehicle uses per move
	///Temporary additional delay for the next move
	var/next_move_slowdown = 0

//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/Initialize()
	. = ..()
	return INITIALIZE_HINT_NORMAL


/obj/vehicle/LateInitialize(mapload)
	. = ..()
	reset_glide_size()


/obj/vehicle/relaymove(mob/user, direction)
	if(user.incapacitated())
		return FALSE

	if(direction in GLOB.diagonals)
		return FALSE

	if(world.time < last_move_time + move_delay + next_move_slowdown)
		return
	next_move_slowdown = 0
	if(powered)
		if(!on)
			to_chat(user, span_warning("Turn on the engine first."))
			return FALSE
		if(cell && cell.charge < charge_use)
			turn_off()
			return FALSE

	if(vehicle_flags & VEHICLE_MUST_TURN && dir != direction)
		last_move_time = world.time
		setDir(direction)
		if(LAZYLEN(change_dir_sounds))
			playsound(src, pick(change_dir_sounds), 25, TRUE)
		return TRUE

	. = Move(get_step(src, direction))
	if(. && LAZYLEN(move_sounds))
		playsound(src, pick(move_sounds), 25, TRUE)


/obj/vehicle/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		if(locked)
			return

		open = !open
		update_icon()
		to_chat(user, span_notice("Maintenance panel is now [open ? "opened" : "closed"]."))

	else if(iscrowbar(I) && cell && open)
		remove_cell(user)

	else if(istype(I, /obj/item/cell) && !cell && open)
		insert_cell(I, user)

	else if(iswelder(I))
		if(user.do_actions)
			to_chat(user, span_notice("You are too busy doing something else"))
			return
		var/obj/item/tool/weldingtool/WT = I
		if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s internals.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s internals.</span>")
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("engineer")
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
				return FALSE

		if(!WT.remove_fuel(1, user))
			return

		if(obj_integrity >= max_integrity)
			to_chat(user, span_notice("[src] does not need repairs."))
			return
		playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)

		user.visible_message(span_notice("[user] starts to repair [src]."),span_notice("You start to repair [src]"))
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
			return
		playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)

		repair_damage(50)
		user.visible_message(span_notice("[user] repairs [src]."), span_notice("You repair [src]."))


/obj/vehicle/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
		if(EXPLODE_HEAVY)
			take_damage(rand(5, 10) * fire_dam_coeff)
		if(EXPLODE_LIGHT)
			if(prob(50))
				take_damage(rand(1, 5) * fire_dam_coeff)
				take_damage(rand(1, 5) * brute_dam_coeff)

/obj/vehicle/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	new /obj/effect/overlay/temp/emp_sparks (loc)
	if(on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if(was_on)
			turn_on()

//-------------------------------------------
// Vehicle procs
//-------------------------------------------
/obj/vehicle/proc/turn_on()
	if(stat)
		return FALSE
	if(powered && cell.charge < charge_use)
		return FALSE
	on = TRUE
	update_icon()
	return TRUE

/obj/vehicle/proc/turn_off()
	on = FALSE
	set_light(0)
	update_icon()


/obj/vehicle/deconstruct(disassembled = TRUE)
	if(!disassembled)
		visible_message(span_danger("[src] blows apart!"))

	new /obj/item/stack/rods(loc)
	new /obj/item/stack/rods(loc)
	new /obj/item/stack/cable_coil/cut(loc)

	if(cell)
		cell.forceMove(loc)
		cell.update_icon()
		set_cell(null)

	for(var/m in buckled_mobs)
		var/mob/living/passenger = m
		passenger.apply_effects(5, 5)
		unbuckle_mob(m)

	new /obj/effect/spawner/gibspawner/robot(loc)
	new /obj/effect/decal/cleanable/blood/oil(loc)

	return ..()

/obj/vehicle/proc/powercheck()
	if(!cell && !powered)
		return

	if(!cell && powered)
		turn_off()
		return

	if(cell.charge < charge_use)
		turn_off()
		return

	if(cell && powered)
		turn_on()
		return


///Wrapper to guarantee powercells are properly nulled and avoid hard deletes.
/obj/vehicle/proc/set_cell(obj/item/cell/new_cell)
	if(cell)
		UnregisterSignal(cell, COMSIG_PARENT_QDELETING)
	cell = new_cell
	if(cell)
		RegisterSignal(cell, COMSIG_PARENT_QDELETING, .proc/on_cell_deletion)


///Called by the deletion of the referenced powercell.
/obj/vehicle/proc/on_cell_deletion(obj/item/cell/source, force)
	SIGNAL_HANDLER
	set_cell(null)


/obj/vehicle/proc/insert_cell(obj/item/cell/C, mob/living/carbon/human/H)
	if(cell)
		return
	if(!istype(C))
		return

	H.transferItemToLoc(C, src)
	set_cell(C)
	powercheck()
	to_chat(usr, span_notice("You install [C] in [src]."))

/obj/vehicle/proc/remove_cell(mob/living/carbon/human/H)
	if(!cell)
		return

	to_chat(usr, span_notice("You remove [cell] from [src]."))
	cell.forceMove(get_turf(H))
	H.put_in_hands(cell)
	set_cell(null)
	powercheck()

/obj/vehicle/proc/RunOver(mob/living/carbon/human/H)
	return		//write specifics for different vehicles

/obj/vehicle/post_buckle_mob(mob/buckling_mob)
	. = ..()
	buckling_mob.pixel_y = buckling_y
	buckling_mob.old_y = buckling_y

/obj/vehicle/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
	buckled_mob.pixel_y = initial(buckled_mob.pixel_y)
	buckled_mob.old_y = initial(buckled_mob.pixel_y)

//-------------------------------------------------------
// Stat update procs
//-------------------------------------------------------
/obj/vehicle/proc/update_stats()
	return

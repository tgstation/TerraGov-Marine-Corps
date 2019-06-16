/obj/vehicle
	name = "vehicle"
	icon = 'icons/obj/vehicles.dmi'
	layer = ABOVE_MOB_LAYER //so it sits above objects including mobs
	density = TRUE
	anchored = TRUE
	animate_movement = FORWARD_STEPS
	luminosity = 2
	can_buckle = TRUE

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

	var/obj/item/cell/cell
	var/charge_use = 5	//set this to adjust the amount of power the vehicle uses per move

//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/New()
	..()
	//spawn the cell you want in each vehicle

/obj/vehicle/relaymove(mob/user, direction)
	if(user.incapacitated())
		return
	if(world.time > last_move_time + move_delay)
		if(on && powered && cell && cell.charge < charge_use)
			turn_off()
		else if(!on && powered)
			to_chat(user, "<span class='warning'>Turn on the engine first.</span>")
		else
			. = step(src, direction)

/obj/vehicle/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		if(locked)
			return

		open = !open
		update_icon()
		to_chat(user, "<span class='notice'>Maintenance panel is now [open ? "opened" : "closed"].</span>")
	
	else if(iscrowbar(I) && cell && open)
		remove_cell(user)

	else if(istype(I, /obj/item/cell) && !cell && open)
		insert_cell(I, user)

	else if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.remove_fuel(1, user))
			return

		if(obj_integrity >= max_integrity)
			to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
			return

		user.visible_message("<span class='notice'>[user] starts to repair [src].</span>","<span class='notice'>You start to repair [src]</span>")
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
			return

		obj_integrity = min(max_integrity, obj_integrity + 10)
		user.visible_message("<span class='notice'>[user] repairs [src].</span>","<span class='notice'>You repair [src].</span>")
		
	else if(I.force)
		switch(I.damtype)
			if("fire")
				obj_integrity -= I.force * fire_dam_coeff
			if("brute")
				obj_integrity -= I.force * brute_dam_coeff
		playsound(loc, "smash.ogg", 25, 1)
		user.visible_message("<span class='danger'>[user] hits [src] with [I].</span>","<span class='danger'>You hit [src] with [I].</span>")
		healthcheck()


/obj/vehicle/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.a_intent == INTENT_HARM)
		M.animation_attack_on(src)
		playsound(loc, "alien_claw_metal", 25, 1)
		M.flick_attack_overlay(src, "slash")
		obj_integrity -= 15
		playsound(src.loc, "alien_claw_metal", 25, 1)
		M.visible_message("<span class='danger'>[M] slashes [src].</span>","<span class='danger'>You slash [src].</span>", null, 5)
		healthcheck()
	else
		attack_hand(M)

/obj/vehicle/attack_animal(var/mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		return
	obj_integrity -= M.melee_damage_upper
	src.visible_message("<span class='danger'>[M] has [M.attacktext] [src]!</span>")
	log_combat(M, src, "attacked")
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()

/obj/vehicle/bullet_act(var/obj/item/projectile/Proj)
	obj_integrity -= Proj.damage
	..()
	healthcheck()
	return TRUE

/obj/vehicle/ex_act(severity)
	switch(severity)
		if(1.0)
			explode()
			return
		if(2.0)
			obj_integrity -= rand(5,10)*fire_dam_coeff
			obj_integrity -= rand(10,20)*brute_dam_coeff
			healthcheck()
			return
		if(3.0)
			if (prob(50))
				obj_integrity -= rand(1,5)*fire_dam_coeff
				obj_integrity -= rand(1,5)*brute_dam_coeff
				healthcheck()
				return
	return

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
	SetLuminosity(initial(luminosity))
	update_icon()
	return TRUE

/obj/vehicle/proc/turn_off()
	on = FALSE
	SetLuminosity(0)
	update_icon()

/obj/vehicle/proc/Emag(mob/user as mob)
	ENABLE_BITFIELD(obj_flags, EMAGGED)

	if(locked)
		locked = FALSE
		to_chat(user, "<span class='warning'>You bypass [src]'s controls.</span>")

/obj/vehicle/proc/explode()
	src.visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)

	if(cell)
		cell.forceMove(Tsec)
		cell.update_icon()
		cell = null

	if(buckled_mob)
		buckled_mob.apply_effects(5, 5)
		unbuckle()

	new /obj/effect/spawner/gibspawner/robot(Tsec)
	new /obj/effect/decal/cleanable/blood/oil(src.loc)

	qdel(src)

/obj/vehicle/proc/healthcheck()
	if(obj_integrity <= 0)
		explode()

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

/obj/vehicle/proc/insert_cell(var/obj/item/cell/C, var/mob/living/carbon/human/H)
	if(cell)
		return
	if(!istype(C))
		return

	H.transferItemToLoc(C, src)
	cell = C
	powercheck()
	to_chat(usr, "<span class='notice'>You install [C] in [src].</span>")

/obj/vehicle/proc/remove_cell(var/mob/living/carbon/human/H)
	if(!cell)
		return

	to_chat(usr, "<span class='notice'>You remove [cell] from [src].</span>")
	cell.forceMove(get_turf(H))
	H.put_in_hands(cell)
	cell = null
	powercheck()

/obj/vehicle/proc/RunOver(var/mob/living/carbon/human/H)
	return		//write specifics for different vehicles


/obj/vehicle/afterbuckle(mob/M)
	. = ..()
	if(. && buckled_mob == M)
		M.pixel_y = buckling_y
		M.old_y = buckling_y
	else
		M.pixel_x = initial(buckled_mob.pixel_x)
		M.pixel_y = initial(buckled_mob.pixel_y)
		M.old_y = initial(buckled_mob.pixel_y)

/obj/vehicle/Destroy()
	SetLuminosity(0)
	. = ..()

//-------------------------------------------------------
// Stat update procs
//-------------------------------------------------------
/obj/vehicle/proc/update_stats()
	return

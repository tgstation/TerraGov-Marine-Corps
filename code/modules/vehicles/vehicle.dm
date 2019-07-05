/obj/vehicle
	name = "vehicle"
	icon = 'icons/obj/vehicles.dmi'
	layer = ABOVE_MOB_LAYER //so it sits above objects including mobs
	density = TRUE
	anchored = TRUE
	animate_movement = FORWARD_STEPS
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
	var/demolish_on_ram = FALSE //Do we crash into walls and destroy them?
	var/lastsound = 0 //Last time we played an engine noise

//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/New()
	..()
	//spawn the cell you want in each vehicle

/obj/vehicle/proc/take_damage(amount)
	if(amount <= 0)
		return FALSE
	obj_integrity -= amount
	healthcheck()

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

/obj/vehicle/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.a_intent == INTENT_HARM)
		M.animation_attack_on(src)
		playsound(loc, "alien_claw_metal", 25, 1)
		M.flick_attack_overlay(src, "slash")
		take_damage(15)
		playsound(src.loc, "alien_claw_metal", 25, 1)
		M.visible_message("<span class='danger'>[M] slashes [src].</span>","<span class='danger'>You slash [src].</span>", null, 5)
		healthcheck()
	else
		attack_hand(M)

/obj/vehicle/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		return
	take_damage(M.melee_damage_upper)
	src.visible_message("<span class='danger'>[M] has [M.attacktext] [src]!</span>")
	log_combat(M, src, "attacked")
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()

/obj/vehicle/bullet_act(obj/item/projectile/Proj)
	take_damage(Proj.damage)
	..()
	return TRUE

/obj/vehicle/ex_act(severity)
	switch(severity)
		if(1.0)
			explode()
			return
		if(2.0)
			take_damage(rand(5,10)*fire_dam_coeff)
			take_damage(rand(10,20)*brute_dam_coeff)
			return
		if(3.0)
			if (prob(50))
				take_damage(rand(1,5)*fire_dam_coeff)
				take_damage(rand(1,5)*brute_dam_coeff)
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
	update_icon()
	return TRUE

/obj/vehicle/proc/turn_off()
	on = FALSE
	set_light(0)
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

/obj/vehicle/proc/insert_cell(obj/item/cell/C, mob/living/carbon/human/H)
	if(cell)
		return
	if(!istype(C))
		return

	H.transferItemToLoc(C, src)
	cell = C
	powercheck()
	to_chat(usr, "<span class='notice'>You install [C] in [src].</span>")

/obj/vehicle/proc/remove_cell(mob/living/carbon/human/H)
	if(!cell)
		return

	to_chat(usr, "<span class='notice'>You remove [cell] from [src].</span>")
	cell.forceMove(get_turf(H))
	H.put_in_hands(cell)
	cell = null
	powercheck()

/obj/vehicle/proc/RunOver(mob/living/carbon/human/H)
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

//-------------------------------------------------------
// Stat update procs
//-------------------------------------------------------
/obj/vehicle/proc/update_stats()
	return

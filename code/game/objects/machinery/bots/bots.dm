// AI (i.e. game AI, not the AI player) controlled bots

/obj/machinery/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER
	use_power = FALSE
	var/obj/item/card/id/botcard			// the ID card that the bot "holds"
	var/on = TRUE
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = FALSE //Maint panel
	var/locked = TRUE


/obj/machinery/bot/proc/turn_on()
	if(machine_stat)
		return FALSE
	on = TRUE
	set_light(initial(luminosity))
	return TRUE

/obj/machinery/bot/proc/turn_off()
	on = FALSE
	set_light(0)

/obj/machinery/bot/proc/explode()
	qdel(src)

/obj/machinery/bot/proc/healthcheck()
	if(obj_integrity <= 0)
		explode()

/obj/machinery/bot/proc/Emag(mob/user as mob)
	if(locked)
		locked = FALSE
		ENABLE_BITFIELD(obj_flags, EMAGGED)
		to_chat(user, "<span class='warning'>You short out [src]'s maintenance hatch lock.</span>")
		log_game("[key_name(user)] emagged [src]'s maintenance hatch lock.")
		message_admins("[ADMIN_TPMONTY(user)] emagged [src]'s maintenance hatch lock.")
	if(!locked && open)
		ENABLE_BITFIELD(obj_flags, EMAGGED)
		log_game("[key_name(user)] emagged [src]'s inner circuits.")
		message_admins("[ADMIN_TPMONTY(user)] emagged [src]'s inner circuits.")

/obj/machinery/bot/examine(mob/user)
	..()
	if(obj_integrity < max_integrity)
		if(obj_integrity > max_integrity/3)
			to_chat(user, "<span class='warning'>[src]'s parts look loose.</span>")
		else
			to_chat(user, "<span class='danger'>[src]'s parts look very loose!</span>")

/obj/machinery/bot/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		return
	obj_integrity -= M.melee_damage_upper
	visible_message("<span class='danger'>[M] has [M.attacktext] [src]!</span>")
	log_combat(M, src, "attacked")
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()

/obj/machinery/bot/attack_alien(mob/living/carbon/xenomorph/M)
	M.animation_attack_on(src)
	obj_integrity -= rand(15, 30)
	if(obj_integrity <= 0)
		M.visible_message("<span class='danger'>\The [M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
	else
		M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
		"<span class='danger'>You slash [src]!</span>", null, 5)
	playsound(loc, "alien_claw_metal", 25, 1)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()

/obj/machinery/bot/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		if(locked)
			return
		open = !open
		to_chat(user, "<span class='notice'>Maintenance panel is now [src.open ? "opened" : "closed"].</span>")

	else if(iswelder(I))
		if(obj_integrity >= max_integrity)
			to_chat(user, "<span class='notice'>[src] does not need a repair.</span>")
			return

		if(!open)
			to_chat(user, "<span class='notice'>Unable to repair with the maintenance panel closed.</span>")
			return

		obj_integrity = min(max_integrity, obj_integrity + 10)
		user.visible_message("<span class='warning'> [user] repairs [src]!</span>","<span class='notice'> You repair [src]!</span>")

	else if(istype(I, /obj/item/card/emag) && !CHECK_BITFIELD(obj_flags, EMAGGED))
		Emag(user)

	else if(I.force && I.damtype)
		switch(I.damtype)
			if("fire")
				obj_integrity -= I.force * fire_dam_coeff
			if("brute")
				obj_integrity -= I.force * brute_dam_coeff
		healthcheck()

/obj/machinery/bot/bullet_act(obj/item/projectile/Proj)
	obj_integrity -= Proj.ammo.damage
	..()
	healthcheck()
	return TRUE

/obj/machinery/bot/ex_act(severity)
	switch(severity)
		if(1)
			explode()
		if(2)
			obj_integrity -= rand(5, 10)*fire_dam_coeff
			obj_integrity -= rand(10, 20)*brute_dam_coeff
			healthcheck()
		if(3)
			if(prob(50))
				obj_integrity -= rand(1, 5)*fire_dam_coeff
				obj_integrity -= rand(1, 5)*brute_dam_coeff
				healthcheck()

/obj/machinery/bot/emp_act(severity)
	var/was_on = on
	machine_stat |= EMPED
	new /obj/effect/overlay/temp/emp_sparks (loc)
	if(on)
		turn_off()
	spawn(severity*300)
		machine_stat &= ~EMPED
		if(was_on)
			turn_on()

/obj/machinery/bot/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machinery/bot/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(.)
		return
	if(!istype(user))
		return

	if(user.species.can_shred(user))
		src.obj_integrity -= rand(15,30)*brute_dam_coeff
		src.visible_message("<span class ='danger'>[user] has slashed [src]!</span>")
		playsound(src.loc, 'sound/weapons/slice.ogg', 25, 1)
		if(prob(10))
			new /obj/effect/decal/cleanable/blood/oil(src.loc)
		healthcheck()

/******************************************************************/
// Navigation procs
// Used for A-star pathfinding


// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(obj/item/card/id/ID)
	var/L[] = new()

	for(var/d in GLOB.cardinals)
		var/turf/T = get_step(src, d)
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L

// Returns true if a link between A and B is blocked
// Movement through doors allowed if ID has access
/proc/LinkBlockedWithAccess(turf/A, turf/B, obj/item/card/id/ID)

	if(A == null || B == null)
		return TRUE
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlockedWithAccess(A,iStep, ID) && !LinkBlockedWithAccess(iStep,B,ID))
			return FALSE

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlockedWithAccess(A,pStep,ID) && !LinkBlockedWithAccess(pStep,B,ID))
			return FALSE
		return TRUE

	if(DirBlockedWithAccess(A,adir, ID))
		return TRUE

	if(DirBlockedWithAccess(B,rdir, ID))
		return TRUE

	for(var/obj/O in B)
		if(O.density && !istype(O, /obj/machinery/door) && !(O.flags_atom & ON_BORDER))
			return TRUE

	return FALSE

// Returns true if direction is blocked from loc
// Checks doors against access with given ID
/proc/DirBlockedWithAccess(turf/loc, dir, obj/item/card/id/ID)
	for(var/obj/structure/window/D in loc)
		if(!D.density)
			continue
		if(D.dir == SOUTHWEST)
			return TRUE
		if(D.dir == dir)
			return TRUE

	for(var/obj/machinery/door/D in loc)
		if(!D.density)
			continue
		if(istype(D, /obj/machinery/door/window))
			if( dir & D.dir )
				return !D.check_access(ID)

			//if((dir & SOUTH) && (D.dir & (EAST|WEST)))		return !D.check_access(ID)
			//if((dir & EAST ) && (D.dir & (NORTH|SOUTH)))	return !D.check_access(ID)
		else return !D.check_access(ID)	// it's a real, air blocking door
	return FALSE

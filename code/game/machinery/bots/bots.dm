// AI (i.e. game AI, not the AI player) controlled bots

/obj/machinery/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER
	luminosity = 3
	use_power = FALSE
	var/obj/item/card/id/botcard			// the ID card that the bot "holds"
	var/on = TRUE
	var/health = 0 //do not forget to set health for your bot!
	var/maxhealth = 0
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = FALSE //Maint panel
	var/locked = TRUE
	//var/emagged = 0 //Urist: Moving that var to the general /bot tree as it's used by most bots


/obj/machinery/bot/proc/turn_on()
	if(stat)
		return FALSE
	on = TRUE
	SetLuminosity(initial(luminosity))
	return TRUE

/obj/machinery/bot/proc/turn_off()
	on = FALSE
	SetLuminosity(0)

/obj/machinery/bot/proc/explode()
	qdel(src)

/obj/machinery/bot/proc/healthcheck()
	if(health <= 0)
		explode()

/obj/machinery/bot/Destroy()
	SetLuminosity(0)
	. = ..()

/obj/machinery/bot/proc/Emag(mob/user as mob)
	if(locked)
		locked = FALSE
		emagged = 1
		to_chat(user, "<span class='warning'>You short out [src]'s maintenance hatch lock.</span>")
		log_and_message_admins("emagged [src]'s maintenance hatch lock")
	if(!locked && open)
		emagged = 2
		log_and_message_admins("emagged [src]'s inner circuits")

/obj/machinery/bot/examine(mob/user)
	..()
	if(health < maxhealth)
		if(health > maxhealth/3)
			to_chat(user, "<span class='warning'>[src]'s parts look loose.</span>")
		else
			to_chat(user, "<span class='danger'>[src]'s parts look very loose!</span>")

/obj/machinery/bot/attack_animal(var/mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		return
	health -= M.melee_damage_upper
	visible_message("\red <B>[M] has [M.attacktext] [src]!</B>")
	log_combat(M, src, "attacked")
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()

/obj/machinery/bot/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	health -= rand(15, 30)
	if(health <= 0)
		M.visible_message("<span class='danger'>\The [M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
	else
		M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
		"<span class='danger'>You slash [src]!</span>", null, 5)
	playsound(loc, "alien_claw_metal", 25, 1)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()

/obj/machinery/bot/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/tool/screwdriver))
		if(!locked)
			open = !open
			to_chat(user, "<span class='notice'>Maintenance panel is now [src.open ? "opened" : "closed"].</span>")
	else if(istype(W, /obj/item/tool/weldingtool))
		if(health < maxhealth)
			if(open)
				health = min(maxhealth, health+10)
				user.visible_message("\red [user] repairs [src]!","\blue You repair [src]!")
			else
				to_chat(user, "<span class='notice'>Unable to repair with the maintenance panel closed.</span>")
		else
			to_chat(user, "<span class='notice'>[src] does not need a repair.</span>")
	else if (istype(W, /obj/item/card/emag) && emagged < 2)
		Emag(user)
	else
		if(hasvar(W,"force") && hasvar(W,"damtype"))
			switch(W.damtype)
				if("fire")
					src.health -= W.force * fire_dam_coeff
				if("brute")
					src.health -= W.force * brute_dam_coeff
			..()
			healthcheck()
		else
			..()

/obj/machinery/bot/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.ammo.damage
	..()
	healthcheck()
	return TRUE

/obj/machinery/bot/ex_act(severity)
	switch(severity)
		if(1)
			explode()
		if(2)
			health -= rand(5, 10)*fire_dam_coeff
			health -= rand(10, 20)*brute_dam_coeff
			healthcheck()
		if(3)
			if(prob(50))
				health -= rand(1, 5)*fire_dam_coeff
				health -= rand(1, 5)*brute_dam_coeff
				healthcheck()

/obj/machinery/bot/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	new /obj/effect/overlay/temp/emp_sparks (loc)
	if(on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if(was_on)
			turn_on()

/obj/machinery/bot/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machinery/bot/attack_hand(var/mob/living/carbon/human/user)

	if(!istype(user))
		return ..()

	if(user.species.can_shred(user))
		src.health -= rand(15,30)*brute_dam_coeff
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
/turf/proc/CardinalTurfsWithAccess(var/obj/item/card/id/ID)
	var/L[] = new()

	for(var/d in cardinal)
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
/proc/DirBlockedWithAccess(turf/loc,var/dir,var/obj/item/card/id/ID)
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


/*
* effect/alien
*/
/obj/effect/alien
	name = "alien thing"
	desc = "theres something alien about this"
	icon = 'icons/Xeno/Effects.dmi'
	hit_sound = "alien_resin_break"
	anchored = TRUE
	max_integrity = 1
	resistance_flags = UNACIDABLE
	obj_flags = CAN_BE_HIT
	var/on_fire = FALSE
	var/ignore_weed_destruction = FALSE //Set this to true if this object isn't destroyed when the weeds under it is.


/obj/effect/alien/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(user.a_intent == INTENT_HARM) //Already handled at the parent level.
		return

	if(obj_flags & CAN_BE_HIT)
		return I.attack_obj(src, user)


/obj/effect/alien/Crossed(atom/movable/O)
	. = ..()
	if(!QDELETED(src) && istype(O, /obj/vehicle/multitile/hitbox/cm_armored))
		tank_collision(O)

/obj/effect/alien/flamer_fire_act()
	take_damage(50, BURN, "fire")

/obj/effect/alien/ex_act(severity)
	switch(severity)
		if(1)
			take_damage(500)
		if(2)
			take_damage((rand(140, 300)))
		if(3)
			take_damage((rand(50, 100)))

/obj/effect/alien/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		take_damage(rand(2, 20) * 0.1)

/*
* Resin
*/
/obj/effect/alien/resin
	name = "resin"
	desc = "Looks like some kind of slimy growth."
	icon_state = "Resin1"
	max_integrity = 200
	resistance_flags = XENO_DAMAGEABLE


/obj/effect/alien/resin/attack_hand(mob/living/user)
	to_chat(usr, "<span class='warning'>You scrape ineffectively at \the [src].</span>")
	return TRUE


/obj/effect/alien/resin/sticky
	name = "sticky resin"
	desc = "A layer of disgusting sticky slime."
	icon_state = "sticky"
	density = FALSE
	opacity = FALSE
	max_integrity = 36
	layer = RESIN_STRUCTURE_LAYER
	hit_sound = "alien_resin_move"
	var/slow_amt = 8

	ignore_weed_destruction = TRUE


/obj/effect/alien/resin/sticky/Crossed(atom/movable/AM)
	. = ..()
	if(!ishuman(AM))
		return

	var/mob/living/carbon/human/H = AM

	if(H.lying)
		return

	H.next_move_slowdown += slow_amt


// Praetorian Sticky Resin spit uses this.
/obj/effect/alien/resin/sticky/thin
	name = "thin sticky resin"
	desc = "A thin layer of disgusting sticky slime."
	max_integrity = 6
	slow_amt = 4

	ignore_weed_destruction = FALSE


//Carrier trap
/obj/effect/alien/resin/trap
	desc = "It looks like a hiding hole."
	name = "resin hole"
	icon_state = "trap0"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 5
	layer = RESIN_STRUCTURE_LAYER
	var/obj/item/clothing/mask/facehugger/hugger = null
	var/mob/living/linked_carrier //The carrier that placed us.

/obj/effect/alien/resin/trap/Initialize(mapload, mob/living/builder)
	. = ..()
	if(builder)
		linked_carrier = builder

/obj/effect/alien/resin/trap/examine(mob/user)
	. = ..()
	if(isxeno(user))
		to_chat(user, "A hole for a little one to hide in ambush.")
		if(hugger)
			to_chat(user, "There's a little one inside.")
		else
			to_chat(user, "It's empty.")


/obj/effect/alien/resin/trap/flamer_fire_act()
	if(hugger)
		hugger.forceMove(loc)
		hugger.Die()
		hugger = null
		icon_state = "trap0"
	..()

/obj/effect/alien/resin/trap/fire_act()
	if(hugger)
		hugger.forceMove(loc)
		hugger.Die()
		hugger = null
		icon_state = "trap0"
	..()

/obj/effect/alien/resin/trap/HasProximity(atom/movable/AM)
	if(!iscarbon(AM) || !hugger)
		return
	var/mob/living/carbon/C = AM
	if(C.can_be_facehugged(hugger))
		playsound(src, "alien_resin_break", 25)
		C.visible_message("<span class='warning'>[C] trips on [src]!</span>",\
						"<span class='danger'>You trip on [src]!</span>")
		C.Knockdown(40)
		if(!QDELETED(linked_carrier) && linked_carrier.stat == CONSCIOUS && linked_carrier.z == z)
			var/area/A = get_area(src)
			if(A)
				to_chat(linked_carrier, "<span class='xenoannounce'>You sense one of your traps at [A.name] has been triggered!</span>")
		drop_hugger()

/obj/effect/alien/resin/trap/proc/drop_hugger()
	hugger.forceMove(loc)
	hugger.stasis = FALSE
	addtimer(CALLBACK(hugger, /obj/item/clothing/mask/facehugger.proc/fast_activate), 1.5 SECONDS)
	icon_state = "trap0"
	visible_message("<span class='warning'>[hugger] gets out of [src]!</span>")
	hugger = null

/obj/effect/alien/resin/trap/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.a_intent != INTENT_HARM)
		if(M.xeno_caste.caste_flags & CASTE_CAN_HOLD_FACEHUGGERS)
			if(!hugger)
				to_chat(M, "<span class='warning'>[src] is empty.</span>")
			else
				icon_state = "trap0"
				M.put_in_active_hand(hugger)
				hugger.GoActive(TRUE)
				hugger = null
				to_chat(M, "<span class='xenonotice'>We remove the facehugger from [src].</span>")
		return
	..()

/obj/effect/alien/resin/trap/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/clothing/mask/facehugger) && isxeno(user))
		var/obj/item/clothing/mask/facehugger/FH = I
		if(hugger)
			to_chat(user, "<span class='warning'>There is already a facehugger in [src].</span>")
			return

		if(FH.stat == DEAD)
			to_chat(user, "<span class='warning'>You can't put a dead facehugger in [src].</span>")
			return

		user.transferItemToLoc(FH, src)
		FH.GoIdle(TRUE)
		hugger = FH
		icon_state = "trap1"
		to_chat(user, "<span class='xenonotice'>You place a facehugger in [src].</span>")


/obj/effect/alien/resin/trap/Crossed(atom/A)
	if(iscarbon(A))
		HasProximity(A)

/obj/effect/alien/resin/trap/Destroy()
	if(hugger && loc)
		drop_hugger()
	return ..()



//Resin Doors
/obj/structure/mineral_door/resin
	name = "resin door"
	mineralType = "resin"
	icon = 'icons/Xeno/Effects.dmi'
	hardness = 1.5
	layer = RESIN_STRUCTURE_LAYER
	max_integrity = 80
	var/close_delay = 100

	tiles_with = list(/turf/closed, /obj/structure/mineral_door/resin)

/obj/structure/mineral_door/resin/Initialize()
	. = ..()

	relativewall()
	relativewall_neighbours()
	if(!locate(/obj/effect/alien/weeds) in loc)
		new /obj/effect/alien/weeds(loc)

/obj/structure/mineral_door/resin/proc/thicken()
	var/oldloc = loc
	qdel(src)
	new /obj/structure/mineral_door/resin/thick(oldloc)
	return TRUE

/obj/structure/mineral_door/resin/attack_paw(mob/living/carbon/monkey/user)
	if(user.a_intent == INTENT_HARM)
		user.visible_message("<span class='xenowarning'>\The [user] claws at \the [src].</span>", \
		"<span class='xenowarning'>You claw at \the [src].</span>")
		playsound(loc, "alien_resin_break", 25)
		take_damage(rand(40, 60))
	else
		return TryToSwitchState(user)

/obj/structure/mineral_door/resin/attack_larva(mob/living/carbon/xenomorph/larva/M)
	var/turf/cur_loc = M.loc
	if(!istype(cur_loc))
		return FALSE
	TryToSwitchState(M)
	return TRUE

//clicking on resin doors attacks them, or opens them without harm intent
/obj/structure/mineral_door/resin/attack_alien(mob/living/carbon/xenomorph/M)
	var/turf/cur_loc = M.loc
	if(!istype(cur_loc))
		return FALSE //Some basic logic here
	if(M.a_intent != INTENT_HARM)
		TryToSwitchState(M)
		return TRUE

	M.visible_message("<span class='warning'>\The [M] digs into \the [src] and begins ripping it down.</span>", \
	"<span class='warning'>We dig into \the [src] and begin ripping it down.</span>", null, 5)
	playsound(src, "alien_resin_break", 25)
	if(do_after(M, 80, FALSE, src, BUSY_ICON_HOSTILE))
		M.visible_message("<span class='danger'>[M] rips down \the [src]!</span>", \
		"<span class='danger'>We rip down \the [src]!</span>", null, 5)
		qdel(src)

/obj/structure/mineral_door/resin/flamer_fire_act()
	take_damage(50, BURN, "fire")

/turf/closed/wall/resin/fire_act()
	take_damage(50, BURN, "fire")

/obj/structure/mineral_door/resin/TryToSwitchState(atom/user)
	if(isxeno(user))
		return ..()

/obj/structure/mineral_door/resin/Open()
	if(state || !loc)
		return //already open
	isSwitchingStates = TRUE
	playsound(loc, "alien_resin_move", 25)
	flick("[mineralType]opening",src)
	sleep(10)
	density = FALSE
	opacity = FALSE
	state = 1
	update_icon()
	isSwitchingStates = 0

	spawn(close_delay)
		if(!isSwitchingStates && state == 1)
			Close()

/obj/structure/mineral_door/resin/Close()
	if(!state || !loc)
		return //already closed
	//Can't close if someone is blocking it
	for(var/turf/turf in locs)
		if(locate(/mob/living) in turf)
			spawn (close_delay)
				Close()
			return
	isSwitchingStates = TRUE
	playsound(loc, "alien_resin_move", 25)
	flick("[mineralType]closing",src)
	sleep(10)
	density = TRUE
	opacity = TRUE
	state = 0
	update_icon()
	isSwitchingStates = 0
	for(var/turf/turf in locs)
		if(locate(/mob/living) in turf)
			Open()
			return

/obj/structure/mineral_door/resin/Dismantle(devastated = 0)
	qdel(src)

/obj/structure/mineral_door/resin/CheckHardness()
	playsound(loc, "alien_resin_move", 25)
	..()

/obj/structure/mineral_door/resin/Destroy()
	relativewall_neighbours()
	var/turf/U = loc
	spawn(0)
		var/turf/T
		for(var/i in GLOB.cardinals)
			T = get_step(U, i)
			if(!istype(T))
				continue
			for(var/obj/structure/mineral_door/resin/R in T)
				R.check_resin_support()
	return ..()


//do we still have something next to us to support us?
/obj/structure/mineral_door/resin/proc/check_resin_support()
	var/turf/T
	for(var/i in GLOB.cardinals)
		T = get_step(src, i)
		if(T.density)
			. = TRUE
			break
		if(locate(/obj/structure/mineral_door/resin) in T)
			. = TRUE
			break
	if(!.)
		visible_message("<span class = 'notice'>[src] collapses from the lack of support.</span>")
		qdel(src)



/obj/structure/mineral_door/resin/thick
	name = "thick resin door"
	max_integrity = 160
	hardness = 2.0

/obj/structure/mineral_door/resin/thick/thicken()
	return FALSE

/*
* Egg
*/

/obj/effect/alien/egg
	desc = "It looks like a weird egg"
	name = "egg"
	icon_state = "Egg Growing"
	density = FALSE
	flags_atom = CRITICAL_ATOM
	max_integrity = 80
	var/obj/item/clothing/mask/facehugger/hugger = null
	var/hugger_type = /obj/item/clothing/mask/facehugger/stasis
	var/list/egg_triggers = list()
	var/status = EGG_GROWING
	var/hivenumber = XENO_HIVE_NORMAL

/obj/effect/alien/egg/Initialize()
	. = ..()
	if(hugger_type)
		hugger = new hugger_type(src)
		hugger.hivenumber = hivenumber
		if(!hugger.stasis)
			hugger.GoIdle(TRUE)
	addtimer(CALLBACK(src, .proc/Grow), rand(EGG_MIN_GROWTH_TIME, EGG_MAX_GROWTH_TIME))

/obj/effect/alien/egg/Destroy()
	QDEL_LIST(egg_triggers)
	return ..()

/obj/effect/alien/egg/proc/transfer_to_hive(new_hivenumber)
	if(hivenumber == new_hivenumber)
		return
	hivenumber = new_hivenumber
	if(hugger)
		hugger.hivenumber = new_hivenumber

/obj/effect/alien/egg/proc/Grow()
	if(status == EGG_GROWING)
		update_status(EGG_GROWN)
		deploy_egg_triggers()

/obj/effect/alien/egg/proc/deploy_egg_triggers()
	QDEL_LIST(egg_triggers)
	for(var/i in 1 to 8)
		var/x_coords = list(-1,-1,-1,0,0,1,1,1)
		var/y_coords = list(1,0,-1,1,-1,1,0,-1)
		var/turf/target_turf = locate(x+x_coords[i],y+y_coords[i], z)
		if(target_turf)
			egg_triggers += new /obj/effect/egg_trigger(target_turf, src)

/obj/effect/alien/egg/ex_act(severity)
	Burst(TRUE)//any explosion destroys the egg.

/obj/effect/alien/egg/attack_alien(mob/living/carbon/xenomorph/M)

	if(!istype(M))
		return attack_hand(M)

	if(!issamexenohive(M))
		M.do_attack_animation(src, ATTACK_EFFECT_SMASH)
		M.visible_message("<span class='xenowarning'>[M] crushes \the [src]","<span class='xenowarning'>We crush \the [src]")
		Burst(TRUE)
		return

	switch(status)
		if(EGG_BURST, EGG_DESTROYED)
			if(M.xeno_caste.can_hold_eggs)
				M.visible_message("<span class='xenonotice'>\The [M] clears the hatched egg.</span>", \
				"<span class='xenonotice'>We clear the hatched egg.</span>")
				playsound(src.loc, "alien_resin_break", 25)
				M.plasma_stored++
				qdel(src)
		if(EGG_GROWING)
			to_chat(M, "<span class='xenowarning'>The child is not developed yet.</span>")
		if(EGG_GROWN)
			to_chat(M, "<span class='xenonotice'>We retrieve the child.</span>")
			Burst(FALSE)

/obj/effect/alien/egg/proc/Burst(kill = TRUE) //drops and kills the hugger if any is remaining
	if(kill)
		if(status != EGG_DESTROYED)
			QDEL_NULL(hugger)
			QDEL_LIST(egg_triggers)
			update_status(EGG_DESTROYED)
			flick("Egg Exploding", src)
			playsound(src.loc, "sound/effects/alien_egg_burst.ogg", 25)
	else
		if(status in list(EGG_GROWN, EGG_GROWING))
			update_status(EGG_BURSTING)
			QDEL_LIST(egg_triggers)
			flick("Egg Opening", src)
			playsound(src.loc, "sound/effects/alien_egg_move.ogg", 25)
			addtimer(CALLBACK(src, .proc/unleash_hugger), 1 SECONDS)

/obj/effect/alien/egg/proc/unleash_hugger()
	if(status != EGG_DESTROYED && hugger)
		status = EGG_BURST
		hugger.forceMove(loc)
		hugger.fast_activate(TRUE)
		hugger = null

/obj/effect/alien/egg/proc/update_status(new_stat)
	if(new_stat)
		status = new_stat
		update_icon()

/obj/effect/alien/egg/update_icon()
	overlays.Cut()
	if(hivenumber != XENO_HIVE_NORMAL && GLOB.hive_datums[hivenumber])
		var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
		color = hive.color
	else
		color = null
	switch(status)
		if(EGG_DESTROYED)
			icon_state = "Egg Exploded"
			return
		if(EGG_BURSTING || EGG_BURST)
			icon_state = "Egg Opened"
		if(EGG_GROWING)
			icon_state = "Egg Growing"
		if(EGG_GROWN)
			icon_state = "Egg"
	if(on_fire)
		overlays += "alienegg_fire"

/obj/effect/alien/egg/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/F = I
		if(F.stat == DEAD)
			to_chat(user, "<span class='xenowarning'>This child is dead.</span>")
			return

		if(status == EGG_DESTROYED)
			to_chat(user, "<span class='xenowarning'>This egg is no longer usable.</span>")
			return

		if(hugger)
			to_chat(user, "<span class='xenowarning'>This one is occupied with a child.</span>")
			return

		visible_message("<span class='xenowarning'>[user] slides [F] back into [src].</span>","<span class='xenonotice'>You place the child back in to [src].</span>")
		user.transferItemToLoc(F, src)
		F.GoIdle(TRUE)
		hugger = F
		update_status(EGG_GROWN)
		deploy_egg_triggers()


/obj/effect/alien/egg/deconstruct(disassembled = TRUE)
	Burst(TRUE)
	return ..()

/obj/effect/alien/egg/flamer_fire_act() // gotta kill the egg + hugger
	Burst(TRUE)

/obj/effect/alien/egg/fire_act()
	Burst(TRUE)

/obj/effect/alien/egg/HasProximity(atom/movable/AM)
	if((status != EGG_GROWN) || QDELETED(hugger) || !iscarbon(AM))
		return FALSE
	var/mob/living/carbon/C = AM
	if(!C.can_be_facehugged(hugger))
		return FALSE
	Burst(FALSE)
	return TRUE

//The invisible traps around the egg to tell it there's a mob right next to it.
/obj/effect/egg_trigger
	name = "egg trigger"
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	mouse_opacity = 0
	invisibility = INVISIBILITY_MAXIMUM
	var/obj/effect/alien/egg/linked_egg

/obj/effect/egg_trigger/Initialize(mapload, obj/effect/alien/egg/source_egg)
	. = ..()
	linked_egg = source_egg


/obj/effect/egg_trigger/Crossed(atom/A)
	if(!linked_egg) //something went very wrong
		qdel(src)
	else if(get_dist(src, linked_egg) != 1 || !isturf(linked_egg.loc)) //something went wrong
		loc = linked_egg
	else if(iscarbon(A))
		var/mob/living/carbon/C = A
		linked_egg.HasProximity(C)




/*
TUNNEL
*/


/obj/structure/tunnel
	name = "tunnel"
	desc = "A tunnel entrance. Looks like it was dug by some kind of clawed beast."
	icon = 'icons/Xeno/effects.dmi'
	icon_state = "hole"

	density = FALSE
	opacity = FALSE
	anchored = TRUE
	resistance_flags = UNACIDABLE
	layer = RESIN_STRUCTURE_LAYER

	var/tunnel_desc = "" //description added by the hivelord.

	max_integrity = 140
	var/mob/living/carbon/xenomorph/hivelord/creator = null
	var/obj/structure/tunnel/other = null
	var/id = null //For mapping

/obj/structure/tunnel/Initialize()
	. = ..()
	GLOB.xeno_tunnels += src


/obj/structure/tunnel/Destroy()
	GLOB.xeno_tunnels -= src
	if(creator)
		creator.tunnels -= src
	if(other)
		other.other = null
		qdel(other)
	return ..()

/obj/structure/tunnel/examine(mob/user)
	..()
	if(!isxeno(user) && !isobserver(user))
		return

	if(!other)
		to_chat(user, "<span class='warning'>It does not seem to lead anywhere.</span>")
	else
		var/area/A = get_area(other)
		to_chat(user, "<span class='info'>It seems to lead to <b>[A.name]</b>.</span>")
		if(tunnel_desc)
			to_chat(user, "<span class='info'>The Hivelord scent reads: \'[tunnel_desc]\'</span>")

/obj/structure/tunnel/deconstruct(disassembled = TRUE)
	visible_message("<span class='danger'>[src] suddenly collapses!</span>")
	if(isturf(other?.loc))
		visible_message("<span class='danger'>[other] suddenly collapses!</span>")
		QDEL_NULL(other)
	return ..()

/obj/structure/tunnel/ex_act(severity)
	switch(severity)
		if(1)
			take_damage(210)
		if(2)
			take_damage(140)
		if(3)
			take_damage(70)

/obj/structure/tunnel/attackby(obj/item/I, mob/user, params)
	if(!isxeno(user))
		return ..()
	attack_alien(user)

/obj/structure/tunnel/attack_alien(mob/living/carbon/xenomorph/M)
	if(!istype(M) || M.stat || M.lying)
		return

	if(M.a_intent == INTENT_HARM && M == creator)
		to_chat(M, "<span class='xenowarning'>We begin filling in our tunnel...</span>")
		if(do_after(M, HIVELORD_TUNNEL_DISMANTLE_TIME, FALSE, src, BUSY_ICON_BUILD))
			deconstruct(FALSE)
		return

	//Prevents using tunnels by the queen to bypass the fog.
	if(SSticker?.mode && SSticker.mode.flags_round_type & MODE_FOG_ACTIVATED)
		if(!M.hive.living_xeno_ruler)
			to_chat(M, "<span class='xenowarning'>There is no ruler. We must choose one first.</span>")
			return FALSE
		else if(isxenoqueen(M))
			to_chat(M, "<span class='xenowarning'>There is no reason to leave the safety of the caves yet.</span>")
			return FALSE

	if(M.anchored)
		to_chat(M, "<span class='xenowarning'>We can't climb through a tunnel while immobile.</span>")
		return FALSE

	if(!other || !isturf(other.loc))
		to_chat(M, "<span class='warning'>\The [src] doesn't seem to lead anywhere.</span>")
		return

	if(LAZYLEN(M.stomach_contents))
		to_chat(M, "<span class='warning'>We must spit out the host inside of us first.</span>")
		return

	var/distance = get_dist( get_turf(src), get_turf(other) )
	var/tunnel_time = CLAMP(distance, HIVELORD_TUNNEL_MIN_TRAVEL_TIME, HIVELORD_TUNNEL_SMALL_MAX_TRAVEL_TIME)
	var/area/A = get_area(other)

	if(M.mob_size == MOB_SIZE_BIG) //Big xenos take longer
		tunnel_time = CLAMP(distance * 1.5, HIVELORD_TUNNEL_MIN_TRAVEL_TIME, HIVELORD_TUNNEL_LARGE_MAX_TRAVEL_TIME)
		M.visible_message("<span class='xenonotice'>[M] begins heaving their huge bulk down into \the [src].</span>", \
		"<span class='xenonotice'>We begin heaving our monstrous bulk into \the [src] to <b>[A.name] (X: [A.x], Y: [A.y])</b>.</span>")
	else
		M.visible_message("<span class='xenonotice'>\The [M] begins crawling down into \the [src].</span>", \
		"<span class='xenonotice'>We begin crawling down into \the [src] to <b>[A.name] (X: [A.x], Y: [A.y])</b>.</span>")

	if(isxenolarva(M)) //Larva can zip through near-instantly, they are wormlike after all
		tunnel_time = 5

	if(do_after(M, tunnel_time, FALSE, src, BUSY_ICON_GENERIC))
		if(other && isturf(other.loc)) //Make sure the end tunnel is still there
			M.forceMove(other.loc)
			M.visible_message("<span class='xenonotice'>\The [M] pops out of \the [src].</span>", \
			"<span class='xenonotice'>We pop out through the other side!</span>")
		else
			to_chat(M, "<span class='warning'>\The [src] ended unexpectedly, so we return back up.</span>")
	else
		to_chat(M, "<span class='warning'>Our crawling was interrupted!</span>")

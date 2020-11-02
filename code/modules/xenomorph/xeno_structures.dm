/obj/structure/resin
	hit_sound = "alien_resin_break"
	layer = RESIN_STRUCTURE_LAYER
	resistance_flags = UNACIDABLE


/obj/structure/resin/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(210)
		if(EXPLODE_HEAVY)
			take_damage(140)
		if(EXPLODE_LIGHT)
			take_damage(70)

/obj/structure/resin/attack_hand(mob/living/user)
	to_chat(user, "<span class='warning'>You scrape ineffectively at \the [src].</span>")
	return TRUE

/obj/structure/resin/flamer_fire_act()
	take_damage(10, BURN, "fire")

/obj/structure/resin/fire_act()
	take_damage(10, BURN, "fire")


/obj/structure/resin/silo
	icon = 'icons/Xeno/resin_silo.dmi'
	icon_state = "brown_silo"
	name = "resin silo"
	desc = "A slimy, oozy resin bed filled with foul-looking egg-like ...things."
	bound_width = 96
	bound_height = 96
	max_integrity = 400
	var/turf/center_turf
	var/datum/hive_status/associated_hive
	var/silo_area
	var/list/corpses = list()


/obj/structure/resin/silo/Initialize()
	. = ..()

	var/static/number = 1
	name = "[name] [number]"
	number++

	GLOB.xeno_resin_silos += src
	center_turf = get_step(src, NORTHEAST)
	if(!istype(center_turf))
		center_turf = loc
	return INITIALIZE_HINT_LATELOAD


/obj/structure/resin/silo/LateInitialize()
	. = ..()
	if(!locate(/obj/effect/alien/weeds) in center_turf)
		new /obj/effect/alien/weeds/node(center_turf)
	associated_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(associated_hive)
		RegisterSignal(associated_hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), .proc/is_burrowed_larva_host)
	silo_area = get_area(src)


/obj/structure/resin/silo/Destroy()
	GLOB.xeno_resin_silos -= src
	if(associated_hive)
		UnregisterSignal(associated_hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))
		associated_hive.xeno_message("<span class='xenoannounce'>A resin silo has been destroyed at [silo_area]!</span>", 2, TRUE)
		associated_hive = null
	return ..()


/obj/structure/resin/silo/examine(mob/user)
	. = ..()
	var/current_integrity = (obj_integrity / max_integrity) * 100
	switch(current_integrity)
		if(0 to 20)
			to_chat(user, "<span class='warning'>It's barely holding, there's leaking oozes all around, and most eggs are broken. Yet it is not inert.</span>")
		if(20 to 40)
			to_chat(user, "<span class='warning'>It looks severely damaged, its movements slow.</span>")
		if(40 to 60)
			to_chat(user, "<span class='warning'>It's quite beat up, but it seems alive.</span>")
		if(60 to 80)
			to_chat(user, "<span class='warning'>It's slightly damaged, but still seems healthy.</span>")
		if(80 to 100)
			to_chat(user, "<span class='info'>It appears in good shape, pulsating healthiy.</span>")


/obj/structure/resin/silo/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos)
	SIGNAL_HANDLER
	if(associated_hive)
		silos += src

//*******************
//Corpse recyclinging
//*******************
/obj/structure/resin/silo/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!isxeno(user))
		return

	else if(!istype(I, /obj/item/grab))
		return

	if(!istype(I, /obj/item/grab))
		return

	var/obj/item/grab/G = I

	var/mob/M
	if(ismob(G.grabbed_thing))
		M = G.grabbed_thing

	if(!M)
		return

	var/mob/living/carbon/victim = M //Xenos already got a larva from this corpse
	if(!victim.chestburst == 0)
		to_chat(user, "<span class='notice'>[M] has already been used to incubate a sister!</span>")
		return

	if(victim.stat == DEAD)
		to_chat(user, "<span class='notice'>[M] is still alive!</span>")
		return

	else if(!(ishuman(M) || !ismonkey(M))) //humans and monkeys only for now
		to_chat(user, "<span class='notice'>[src] is compatible with humanoid anatomies only!</span>")
		return

	visible_message("[user] starts putting [M] into [src].", 3)

	if(!do_after(user, 10, FALSE, M, BUSY_ICON_DANGER) || QDELETED(src))
		return

	if(!M || !G)
		return

	M.forceMove(src)
	corpses += M

//add larva points, somehow
//datum/job/xenomorph = LARVA_POINTS_REGULAR //from what I can tell this is 3 points out of the 10 needed for a xeno

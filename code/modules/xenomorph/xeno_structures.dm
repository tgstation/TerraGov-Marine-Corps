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
	for(var/i in contents)
		var/atom/movable/AM = i
		AM.forceMove(get_step(center_turf, pick(CARDINAL_ALL_DIRS)))
	playsound(loc,'sound/effects/alien_egg_burst.ogg', 75)
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
	if(!isxeno(user)) //only xenos can deposit corpses
		return

	if(!istype(I, /obj/item/grab))
		return

	var/obj/item/grab/G = I
	if(!iscarbon(G.grabbed_thing))
		return
	var/mob/living/carbon/victim = G.grabbed_thing
	if(!(ishuman(victim) || ismonkey(victim))) //humans and monkeys only for now
		to_chat(user, "<span class='notice'>[src] can only process humanoid anatomies!</span>")
		return

	if(victim.chestburst)
		to_chat(user, "<span class='notice'>[victim] has already been exhausted to incubate a sister!</span>")
		return

	if(issynth(victim))
		to_chat(user, "<span class='notice'>[victim] has no useful biomass for us.</span>")
		return

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		if(check_tod(H))
			to_chat(user, "<span class='notice'>[H] still has some signs of life. We should headbite it to finish it off.</span>")
			return

	visible_message("[user] starts putting [victim] into [src].", 3)

	if(!do_after(user, 20, FALSE, victim, BUSY_ICON_DANGER) || QDELETED(src))
		return

	victim.chestburst = 2 //So you can't reuse corpses if the silo is destroyed
	victim.update_burst()
	victim.forceMove(src)

	if(prob(5)) //5% chance to play
		shake(4 SECONDS)
	else
		playsound(loc, 'sound/effects/blobattack.ogg', 25)

	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.add_job_points(1.75) //4 corpses per burrowed; 7 points per larva

	log_combat(victim, user, "was consumed by a resin silo")
	log_game("[key_name(victim)] was consumed by a resin silo at [AREACOORD(victim.loc)].")

	GLOB.round_statistics.xeno_silo_corpses++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_silo_corpses")

/obj/structure/resin/silo/proc/shake(duration)
	var/offset = prob(50) ? -2 : 2
	var/old_pixel_x = pixel_x
	var/shake_sound = rand(1, 100) == 1 ? 'sound/machines/blender.ogg' : 'sound/machines/juicer.ogg'
	playsound(src, shake_sound, 25, TRUE)
	animate(src, pixel_x = pixel_x + offset, time = 2, loop = -1) //start shaking
	addtimer(CALLBACK(src, .proc/stop_shake, old_pixel_x), duration)

/obj/structure/resin/silo/proc/stop_shake(old_px)
	animate(src)
	pixel_x = old_px

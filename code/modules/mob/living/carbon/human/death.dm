/mob/living/carbon/human/gib()

	var/is_a_synth = issynth(src)
	for(var/datum/limb/E in limbs)
		if(istype(E, /datum/limb/chest))
			continue
		if(istype(E, /datum/limb/groin) && is_a_synth)
			continue
		// Only make the limb drop if it's not too damaged
		if(prob(100 - E.get_damage()))
			// Override the current limb status
			E.droplimb()


	if(is_a_synth)
		spawn_gibs()
		return
	..()





/mob/living/carbon/human/gib_animation()
	new /atom/movable/effect/overlay/temp/gib_animation(loc, 0, src, species ? species.gibbed_anim : "gibbed-h")

/mob/living/carbon/human/spawn_gibs()
	if(species)
		hgibs(loc, species.flesh_color, species.blood_color)
	else
		hgibs(loc)



/mob/living/carbon/human/spawn_dust_remains()
	if(species)
		new species.remains_type(loc)
	else
		new /atom/movable/effect/decal/cleanable/ash(loc)


/mob/living/carbon/human/dust_animation()
	new /atom/movable/effect/overlay/temp/dust_animation(loc, 0, src, "dust-h")


/mob/living/carbon/human/death(gibbing, deathmessage, silent, special_death_message)
	if(stat == DEAD)
		return ..()
	if(species.death_message)
		deathmessage = species.death_message
	if(!silent && species.death_sound)
		playsound(loc, species.death_sound, 50, TRUE)
	return ..()


/mob/living/carbon/human/on_death()
	if(pulledby)
		pulledby.stop_pulling()

	//Handle species-specific deaths.
	species.handle_death(src)

	remove_typing_indicator()

	if(SSticker && SSticker.current_state == GAME_STATE_PLAYING) //game has started, to ignore the map placed corpses.
		GLOB.round_statistics.total_human_deaths++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "total_human_deaths")

	GLOB.dead_human_list += src
	GLOB.alive_human_list -= src
	LAZYREMOVE(GLOB.alive_human_list_faction[faction], src)
	LAZYREMOVE(GLOB.humans_by_zlevel["[z]"], src)
	UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)

	hud_list[HEART_STATUS_HUD].icon_state = "beating_heart"

	return ..()


/mob/living/carbon/human/proc/makeSkeleton()
	if(f_style)
		f_style = "Shaved"
	if(h_style)
		h_style = "Bald"
	update_hair(0)

	status_flags |= DISFIGURED
	update_body(0)
	name = get_visible_name()
	return

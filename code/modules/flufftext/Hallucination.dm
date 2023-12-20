#define HAL_LINES_FILE "hallucinations.json"

GLOBAL_LIST_INIT(hallucination_list, list(
	/datum/hallucination/sounds = 100,
	/datum/hallucination/chat = 50,
	/datum/hallucination/battle = 20,
	/datum/hallucination/xeno_attack = 8,
))


/mob/living/carbon/proc/handle_hallucinations()
	if(!hallucination)
		return

	hallucination = max(0, hallucination - 2) // Life ticks happen every 2 seconds

	if(world.time < next_hallucination)
		return

	var/halpick = pickweight(GLOB.hallucination_list)
	new halpick(src, FALSE)

	next_hallucination = world.time + rand(10 SECONDS, 60 SECONDS)

/mob/living/carbon/proc/set_screwyhud(hud_type)
	hal_screwyhud = hud_type
	handle_healths_hud_updates()

/datum/hallucination
	var/natural = TRUE
	var/mob/living/carbon/target

/datum/hallucination/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	target = C
	natural = !forced

/datum/hallucination/Destroy()
	target = null
	return ..()

//Returns a random turf in a ring around the target mob, useful for sound hallucinations
/datum/hallucination/proc/random_far_turf()
	var/x_based = prob(50)
	var/first_offset = pick(-8,-7,-6,-5,5,6,7,8)
	var/second_offset = rand(-8,8)
	var/x_off
	var/y_off
	if(x_based)
		x_off = first_offset
		y_off = second_offset
	else
		y_off = first_offset
		x_off = second_offset
	var/turf/T = locate(target.x + x_off, target.y + y_off, target.z)
	return T


//Returns a random turf at the edge of a mobs vision
/datum/hallucination/proc/random_visible_edge_turf()
	// var/edge_range = target.client.view
	var/x_based = prob(50)
	var/first_offset = pick(-8,-7,-6,-5,5,6,7,8)
	var/second_offset = rand(-8,8)
	var/x_off
	var/y_off
	if(x_based)
		x_off = first_offset
		y_off = second_offset
	else
		y_off = first_offset
		x_off = second_offset
	var/turf/T = locate(target.x + x_off, target.y + y_off, target.z)
	return T

/obj/effect/hallucination
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	var/mob/living/carbon/target = null

/obj/effect/hallucination/simple
	icon = 'icons/Xeno/castes/runner.dmi'
	icon_state = "Runner Walking"
	var/px = 0
	var/py = 0
	var/col_mod = null
	var/image/current_image = null
	var/image_layer = MOB_LAYER
	var/active = TRUE //qdelery

/obj/effect/hallucination/simple/Initialize(mapload, mob/living/carbon/T)
	. = ..()
	if(!target)
		return INITIALIZE_HINT_QDEL
	target = T
	current_image = GetImage()
	if(target.client)
		target.client.images |= current_image

/obj/effect/hallucination/simple/proc/GetImage()
	var/image/I = image(icon,src,icon_state,image_layer,dir=src.dir)
	I.pixel_x = px
	I.pixel_y = py
	if(col_mod)
		I.color = col_mod
	return I

/obj/effect/hallucination/simple/proc/Show(update=1)
	if(active)
		if(target.client)
			target.client.images.Remove(current_image)
		if(update)
			current_image = GetImage()
		if(target.client)
			target.client.images |= current_image

/obj/effect/hallucination/simple/update_icon(new_state,new_icon,new_px=0,new_py=0)
	icon_state = new_state
	if(new_icon)
		icon = new_icon
	else
		icon = initial(icon)
	px = new_px
	py = new_py
	Show()

/obj/effect/hallucination/simple/Moved(atom/OldLoc, Dir)
	Show()

/obj/effect/hallucination/simple/Destroy()
	if(target?.client)
		target.client.images.Remove(current_image)
	active = FALSE
	return ..()

/obj/effect/hallucination/simple/xeno
	name = "Mature Runner"
	desc = "A small red alien that looks like it could run fairly quickly..."
	icon = 'icons/Xeno/castes/runner.dmi'
	icon_state = "Runner Walking"

/obj/effect/hallucination/simple/xeno/Initialize(mapload, mob/living/carbon/T)
	. = ..()
	name = "Mature Runner ([rand(100, 999)])"

/obj/effect/hallucination/simple/xeno/throw_impact(atom/hit_atom, speed)
	. = ..()
	if(!.)
		return
	if(hit_atom == target && target.stat != DEAD)
		target.Paralyze(3 SECONDS, TRUE, TRUE)
		target.visible_message(span_danger("[target] flails around wildly."),span_xenowarning("\The [src] pounces at [target]!"))

/datum/hallucination/xeno_attack
	//Xeno crawls from nearby vent,jumps at you, and goes back in
	var/obj/machinery/atmospherics/components/unary/vent_pump/pump = null
	var/obj/effect/hallucination/simple/xeno/xeno = null

/datum/hallucination/xeno_attack/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in orange(3, target))
		if(!U.welded)
			pump = U
			break
	if(pump)
		xeno = new(pump.loc, target)
		playsound(src, get_sfx("alien_ventpass"), 35, 1)
		sleep(1 SECONDS)
		xeno.throw_at(target, 7, 1, xeno, FALSE, TRUE)
		sleep(1 SECONDS)
		xeno.throw_at(pump.loc, 7, 1, xeno, FALSE, TRUE)
		sleep(1 SECONDS)
		to_chat(target, span_notice("[xeno.name] begins climbing into the ventilation system..."))
		sleep(1.5 SECONDS)
		to_chat(target, span_notice("[xeno.name] scrambles into the ventilation ducts!"))
		playsound(src, get_sfx("alien_ventpass"), 35, 1)
		qdel(xeno)
	qdel(src)

/datum/hallucination/battle

/datum/hallucination/battle/New(mob/living/carbon/C, forced = TRUE, battle_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!battle_type)
		battle_type = pick("xeno")
	switch(battle_type)
		if("xeno")
			var/hits = 0
			for(var/i in 1 to rand(5, 10))
				target.playsound_local(source, get_sfx("alien_claw_flesh"), 25, TRUE)
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))
				if(hits >= 4 && prob(70))
					target.playsound_local(source, get_sfx(pick("male_scream", "female_scream")), 35, TRUE)
					break
	qdel(src)

/datum/hallucination/chat

/datum/hallucination/chat/New(mob/living/carbon/C, forced = TRUE, force_radio, specific_message)
	set waitfor = FALSE
	..()
	var/target_name = target.real_name
	var/speak_messages = list(
		"[pick_list_replacements(HAL_LINES_FILE, "suspicion")]",
		"[pick_list_replacements(HAL_LINES_FILE, "conversation")]",
		"[pick_list_replacements(HAL_LINES_FILE, "greetings")]",
		"[pick_list_replacements(HAL_LINES_FILE, "getout")]",
		"[pick_list_replacements(HAL_LINES_FILE, "weird")]",
		"[pick_list_replacements(HAL_LINES_FILE, "didyouhearthat")]",
		"[pick_list_replacements(HAL_LINES_FILE, "nuke")]",
		"[pick_list_replacements(HAL_LINES_FILE, "doubt")]",
		"[pick_list_replacements(HAL_LINES_FILE, "aggressive")]",
		"[pick_list_replacements(HAL_LINES_FILE, "help")]",
		"[pick_list_replacements(HAL_LINES_FILE, "escape")]"
	)
	var/radio_messages = list( // only a subset, because not everything makes sense over radio
		"[pick_list_replacements(HAL_LINES_FILE, "didyouhearthat")]",
		"[pick_list_replacements(HAL_LINES_FILE, "nuke")]",
		"[pick_list_replacements(HAL_LINES_FILE, "doubt")]",
		"[pick_list_replacements(HAL_LINES_FILE, "help")]",
		"[pick_list_replacements(HAL_LINES_FILE, "escape")]"
	)

	var/mob/living/carbon/person = null
	var/datum/language/understood_language = target.get_random_understood_language()
	for(var/mob/living/carbon/H in view(target))
		if(H == target)
			continue
		if(!person)
			person = H
		else
			if(get_dist(target, H) < get_dist(target,person))
				person = H
	if(person && !force_radio) //Basic talk
		var/chosen = specific_message
		if(!chosen)
			chosen = capitalize(pick(speak_messages))
		chosen = replacetext(chosen, "%TARGETNAME%", target_name)
		if(copytext(chosen, 1, 9) == "#stutter") // 9 = #stutter length
			chosen = stutter(copytext(chosen, 9))
		if(copytext(chosen, 1, 6) == "#slur") // 6 = #slur length
			chosen = slur(copytext(chosen, 6))

		var/image/speech_overlay = image('icons/mob/talk.dmi', person, "default0", layer = ABOVE_MOB_LAYER)
		var/message = target.compose_message(person, understood_language, chosen, null, list(person.speech_span), face_name = TRUE)
		to_chat(target, message)
		if(target.client)
			target.client.images |= speech_overlay
			sleep(3 SECONDS)
			target.client.images.Remove(speech_overlay)
	else // Radio talk
		var/chosen = specific_message
		if(!chosen)
			chosen = capitalize(pick(radio_messages))
		chosen = replacetext(chosen, "%TARGETNAME%", target_name)
		var/list/humans = list()
		for(var/mob/living/carbon/human/H in GLOB.alive_human_list)
			if(H == target)
				continue
			humans += H
		if(!length(humans))
			qdel(src)
			return
		person = pick(humans)
		var/message = target.compose_message(person,understood_language,chosen,"[FREQ_COMMON]",list(person.speech_span),face_name = TRUE)
		to_chat(target, message)
	qdel(src)

/datum/hallucination/sounds

/datum/hallucination/sounds/New(mob/living/carbon/C, forced = TRUE, sound_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!sound_type)
		sound_type = pick("airlock pry", "hugged", "glass step", "grill hit", "weed placed", "gunshots")
	//Strange audio
	switch(sound_type)
		if("airlock pry")
			target.playsound_local(source,'sound/effects/metal_creaking.ogg', 35, TRUE)
		if("glass step")
			for(var/i in 1 to rand(1, 2))
				target.playsound_local(source,'sound/effects/glass_step.ogg', 35, TRUE)
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 2))
		if("grill hit")
			for(var/i in 1 to rand(5, 10))
				target.playsound_local(source,'sound/effects/grillehit.ogg', 35, TRUE)
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))
		if("apc sparks")
			target.playsound_local(source, get_sfx("sparks"), 35, TRUE)
		if("hugged")
			target.playsound_local(source, 'sound/effects/alien_egg_move.ogg', 35, TRUE)
			sleep(1 SECONDS)
			target.playsound_local(source, get_sfx("[pick("male", "female")]_hugged"), 35, TRUE)
		if("weed placed")
			target.playsound_local(source, get_sfx("alien_resin_build"), 35, TRUE)
		if("gunshots")
			target.playsound_local(source, get_sfx("alien_resin_build"), 35, TRUE)
			for(var/i in 1 to rand(5, 10))
				target.playsound_local(source, get_sfx("ballistic_hit"), 35, TRUE)
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))

	qdel(src)

/datum/hallucination/death

/datum/hallucination/death/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	target.set_screwyhud(SCREWYHUD_DEAD)
	target.Sleeping(30 SECONDS)
	if(prob(50))
		var/mob/fakemob
		var/list/dead_people = list()
		for(var/mob/dead/observer/G in GLOB.player_list)
			dead_people += G
		if(LAZYLEN(dead_people))
			fakemob = pick(dead_people)
		else
			fakemob = target //ever been so lonely you had to haunt yourself?
		if(fakemob)
			sleep(rand(20, 50))
			to_chat(target, span_deadsay("<b>DEAD: [fakemob.name]</b> says, \"[pick("rip","why did i just drop dead?","hey [target.real_name]","git gud","you too?","did we get the [pick("nuke", "blue disk", "red disk", "green disk", "yellow disk")]?","i[prob(50)?" fucking":""] hate [pick("runners", "queens", "shrikes", "xenos", "this", "myself", "admins", "you")]")]\""))
	sleep(rand(7 SECONDS, 9 SECONDS))
	target.set_screwyhud(SCREWYHUD_NONE)
	target.SetSleeping(0)
	qdel(src)

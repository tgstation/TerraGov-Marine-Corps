/mob/living/carbon/Life()

	set invisibility = 0
	set background = 1

	if(notransform || stat == DEAD) //If we're dead or set to notransform don't bother processing life
		return

	if((life_tick % CARBON_BREATH_DELAY == 0) || failed_last_breath) //First, resolve location and get a breath
		breathe() //Only try to take a breath every 2 ticks, unless suffocating

	else if(isobj(loc))//Still give containing object the chance to interact
		var/obj/location_as_object = loc
		location_as_object.handle_internal_lifeform(src)

	. = ..()

	handle_fire() //Check if we're on fire

/mob/living/carbon/handle_regular_hud_updates()
	. = ..()
	if(.)
		return FALSE

	handle_healths_hud_updates()
	return TRUE


/mob/living/carbon/proc/handle_healths_hud_updates()
	if(hud_used?.healths)
		switch(round(health * 100 / maxHealth))
			if(100 to INFINITY)
				hud_used.healths.icon_state = "health0"
			if(75 to 99)
				hud_used.healths.icon_state = "health1"
			if(50 to 74)
				hud_used.healths.icon_state = "health2"
			if(25 to 49)
				hud_used.healths.icon_state = "health3"
			if(10 to 24)
				hud_used.healths.icon_state = "health4"
			if(0 to 9)
				hud_used.healths.icon_state = "health5"
			else
				hud_used.healths.icon_state = "health6"

///gives humans oxy when dragged by a xeno, called on COMSIG_MOVABLE_PULL_MOVED
/mob/living/carbon/human/proc/oncritdrag()
	SIGNAL_HANDLER
	if(isxeno(pulledby))
		adjustOxyLoss(HUMAN_CRITDRAG_OXYLOSS) //take oxy damage per tile dragged

/mob/living/carbon/update_stat()
	. = ..()
	if(.)
		return

	if(status_flags & GODMODE)
		return

	if(stat == DEAD)
		return

	if(health <= get_death_threshold())
		if(gib_chance && prob(gib_chance + 0.5 * (get_death_threshold() - health)))
			gib()
			return TRUE
		death()
		return

	if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || getOxyLoss() > CARBON_KO_OXYLOSS || health < get_crit_threshold())
		if(stat == UNCONSCIOUS)
			return
		set_stat(UNCONSCIOUS)
	else if(stat == UNCONSCIOUS)
		set_stat(CONSCIOUS)


/mob/living/carbon/handle_status_effects()
	. = ..()
	var/pwr = (stat || resting) ? 1 : 0
	var/restingpwr = 3 + 12 * pwr

	//Dizziness
	if(dizziness)
		dizzy(-restingpwr)

	if(drowsyness)
		adjustDrowsyness(-restingpwr)
		blur_eyes(2)
		if(prob(5))
			Sleeping(20)
			Unconscious(10 SECONDS)

	if(jitteriness)
		do_jitter_animation(jitteriness)
		jitter(-restingpwr)

	if(hallucination >= 20) // hallucinations require stacking before triggering
		handle_hallucinations()



	if(staminaloss > -max_stamina_buffer)
		handle_staminaloss()

	if(IsSleeping())
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			H.speech_problem_flag = 1
		handle_dreams()
		if(mind)
			if((mind.active && client != null) || immune_to_ssd) //This also checks whether a client is connected, if not, sleep is not reduced.
				AdjustSleeping(-20)
		if(!isxeno(src))
			if(prob(2) && health && !hallucination)
				emote("snore")

	if(drunkenness)
		drunkenness = max(drunkenness - (drunkenness * 0.03), 0)
		if(drunkenness >= 6)
			if(prob(25))
				slurring += 2
			jitter(-3)

		if(drunkenness >= 11 && slurring < 5)
			slurring += 1.2

		if(drunkenness >= 41)
			if(prob(25))
				AdjustConfused(40)
			if(dizziness < 450) // To avoid giving the player overly dizzy too
				dizzy(8)

		if(drunkenness >= 51)
			if(prob(5))
				AdjustConfused(10 SECONDS)
				vomit()
			if(dizziness < 600)
				dizzy(12)

		if(drunkenness >= 61)
			if(prob(25))
				blur_eyes(3)

		if(drunkenness >= 71)
			blur_eyes(4)

		if(drunkenness >= 81)
			adjustToxLoss(0.2)
			if(prob(10) && !stat)
				to_chat(src, span_warning("Maybe you should lie down for a bit..."))
				adjustDrowsyness(5)

		if(drunkenness >= 91)
			adjustBrainLoss(0.2, TRUE)
			if(prob(15 && !stat))
				to_chat(src, span_warning("Just a quick nap..."))
				Sleeping(80 SECONDS)

		if(drunkenness >=101) //Let's be honest, you should be dead by now
			adjustToxLoss(4)

	switch(drunkenness) //painkilling effects
		if(51 to 71)
			reagent_shock_modifier += PAIN_REDUCTION_LIGHT
		if(71 to 81)
			reagent_shock_modifier += PAIN_REDUCTION_MEDIUM
		if(81 to INFINITY)
			reagent_shock_modifier += PAIN_REDUCTION_HEAVY

	handle_stagger()
	handle_disabilities()

/mob/living/carbon/proc/breathe()
	if(!need_breathe())
		return

	if(pulledby && pulledby.grab_state >= GRAB_KILL)
		Losebreath(3)

	if(health < get_crit_threshold() && !reagents.has_reagent(/datum/reagent/medicine/inaprovaline))
		Losebreath(1, TRUE)
	else
		adjust_Losebreath(-1, TRUE)

	if(!losebreath)
		. = get_breath_from_internal()
		if(!.)
			. = get_breath_from_environment()

	handle_breath(.)

/mob/living/carbon/proc/get_breath_from_internal()
	if(!internal)
		return FALSE
	if(istype(buckled,/obj/machinery/optable))
		var/obj/machinery/optable/O = buckled
		if(O.anes_tank)
			return O.anes_tank.return_air()
	if(!contents.Find(internal))
		internal = null
	if(!wear_mask || !(wear_mask.flags_inventory & ALLOWINTERNALS))
		internal = null
	if(internal)
		hud_used.internals.icon_state = "internal1"
		return internal.return_air()
	else if(hud_used?.internals)
		hud_used.internals.icon_state = "internal0"
	return FALSE

/mob/living/carbon/proc/get_breath_from_environment()
	if(isturf(loc))
		var/turf/T = loc
		. = T.return_air()

	else if(istype(loc, /atom/movable))
		var/atom/movable/container = loc
		. = container.handle_internal_lifeform(src)

	if(istype(wear_mask) && .)
		. = wear_mask.filter_air(.)

/mob/living/carbon/proc/handle_breath(list/air_info)
	if(!air_info || suiciding)
		if(suiciding)
			adjustOxyLoss(2, TRUE)
		else if(health > get_crit_threshold())
			adjustOxyLoss(CARBON_MAX_OXYLOSS, TRUE)
		else
			adjustOxyLoss(CARBON_CRIT_MAX_OXYLOSS, TRUE)

		failed_last_breath = TRUE
		oxygen_alert = TRUE
		return FALSE
	return TRUE


/mob/living/carbon/proc/handle_impaired_vision()
	//Eyes
	if(eye_blind)
		adjust_blindness(-1)
	if(eye_blurry)			//blurry eyes heal slowly
		adjust_blurriness(-1)
		update_eye_blur()

/mob/living/carbon/proc/handle_impaired_hearing()
	//Ears
	if(ear_damage < 100)
		adjust_ear_damage(-0.05, -1)	// having ear damage impairs the recovery of ear_deaf


/mob/living/carbon/proc/handle_disabilities()
	handle_impaired_vision()
	handle_impaired_hearing()

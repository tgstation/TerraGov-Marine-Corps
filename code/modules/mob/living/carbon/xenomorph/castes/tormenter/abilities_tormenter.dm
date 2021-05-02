/datum/action/xeno_action/activable/nightfall
	name = "Nightfall"
	action_icon_state = "nightfall"
	mechanics_text = "Shut down all electrical lights for 5 seconds"
	cooldown_timer = 1 MINUTES
	plasma_cost = 100
	var/range = 7
	var/duration = 5 SECONDS

/datum/action/xeno_action/activable/nightfall/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>We gather enough mental strength to shut down lights again.</span>")
	return ..()

/datum/action/xeno_action/activable/nightfall/use_ability()
	playsound(target,'sound/magic/nightfall.ogg', 50, 1)

	for(var/atom/light AS in GLOB.lights)
		light.turn_light(null, FALSE, duration, TRUE, TRUE, get_turf(owner), range)

	succeed_activate()
	add_cooldown()

/datum/action/xeno_action/activable/deception
	name = "Deception"
	action_icon_state = "nightfall"
	mechanics_text = "Creates mirror image of yourself. They'll attack if you are in harm intent, retreat if you are in help intent"
	cooldown_timer = 1 MINUTES
	plasma_cost = 100
	/// How long till the illusion disapear 
	var/base_life_time = 10 SECONDS

/datum/action/xeno_action/activable/deception/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	var/clone_number = 1
	var/life_time = base_life_time
	switch(X.upgrade)
		if(XENO_UPGRADE_ONE)
			clone_number = 2
			life_time += 5
		if(XENO_UPGRADE_TWO)
			clone_number = 3
			life_time += 10
		if(XENO_UPGRADE_THREE)
			clone_number = 4
			life_time += 15
	var/mob/living/simple_animal/hostile/illusion/mirror_image
	for(var/i in 1 to clone_number)
		mirror_image = new(get_turf(X))
		mirror_image.copy_appearance(X, life_time)
		mirror_image.retreat_distance = (X.a_intent == INTENT_HELP) ? INFINITY : 0
		mirror_image.handle_automated_movement()
		mirror_image.handle_automated_action()

/datum/action/xeno_action/activable/deception/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>We gather enough mental strength to create clones of ourself.</span>")
	return ..()

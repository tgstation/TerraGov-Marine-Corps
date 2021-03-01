/datum/action/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	mechanics_text = "Teleport back to your core."

/datum/action/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)

/datum/action/xeno_action/activable/nightfall
	name = "Nightfall"
	action_icon_state = "nightfall"
	mechanics_text = "Shut down all light for 5 seconds"
	cooldown_timer = 2 MINUTES
	plasma_cost = 100
	var/range = 10
	var/duration = 5 SECONDS

/datum/action/xeno_action/activable/nightfall/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>We gather enough mental strength to shut down lights again.</span>")
	return ..()

/datum/action/xeno_action/activable/nightfall/use_ability(atom/target)
	playsound(owner,'sound/magic/nightfall.ogg', 40, 1)
	playsound(target,'sound/magic/nightfall.ogg', 50, 1)

	for(var/atom/light AS in GLOB.lights)
		light.turn_light(null, FALSE, duration, TRUE, TRUE, target, range)

	succeed_activate()
	add_cooldown()

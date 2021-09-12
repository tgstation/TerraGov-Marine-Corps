/datum/action/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	mechanics_text = "Teleport back to your core."

/datum/action/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)

/datum/action/xeno_action/activable/secrete_resin/ranged/slow
	base_wait = 1.5 SECONDS
	max_range = 4

/datum/action/xeno_action/change_form
	name = "Change form"
	action_icon_state = "manifest"
	mechanics_text = "Change from your incorporal form to your physical on and vice-versa."

/datum/action/xeno_action/change_form/action_activate()
	var/mob/living/carbon/xenomorph/xenomorph_owner = owner
	xenomorph_owner.change_form()

/datum/action/xeno_action/lay_minion_egg
	name = "Lay Minion Egg"
	action_icon_state = "lay_egg"
	plasma_cost = 200
	cooldown_timer = 3 MINUTES
	keybind_signal = COMSIG_XENOABILITY_LAY_EGG

/datum/action/xeno_action/lay_minion_egg/action_activate()
	var/mob/living/carbon/xenomorph/xeno = owner
	var/turf/current_turf = get_turf(owner)

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf
	if(!alien_weeds)
		to_chat(owner, span_warning("Our eggs wouldn't grow well enough here. Lay them on resin."))
		return FALSE

	if(!do_after(owner, 3 SECONDS, FALSE, alien_weeds))
		return FALSE

	if(!current_turf.check_alien_construction(owner) || !current_turf.check_disallow_alien_fortification(owner))
		return FALSE

	owner.visible_message(span_xenowarning("\The [owner] has laid an egg!"), \
		span_xenowarning("We have laid an egg!"))

	new /obj/effect/alien/egg/minion(current_turf, xeno.hivenumber)
	playsound(owner.loc, 'sound/effects/splat.ogg', 25)

	succeed_activate()
	add_cooldown()

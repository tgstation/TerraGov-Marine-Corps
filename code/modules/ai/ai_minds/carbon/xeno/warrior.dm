/datum/ai_mind/carbon/xeno/warrior
	var/datum/action/xeno_action/activable/punch/punch = new
	var/datum/action/xeno_action/activable/fling/fling = new
	var/datum/action/xeno_action/toggle_agility/toggle_agility = new

/datum/ai_mind/carbon/xeno/warrior/New()
	..()
	punch.owner = mob_parent
	fling.owner = mob_parent
	toggle_agility.owner = mob_parent

/datum/ai_mind/carbon/xeno/warrior/do_process()
	var/mob/living/carbon/xenomorph/mob2 = mob_parent
	if(istype(atom_to_walk_to, /mob/living/carbon/human))
		var/mob/living/carbon/human/atom2 = atom_to_walk_to
		if(mob2.agility && get_dist(mob_parent, atom2) < 3)
			toggle_agility.action_activate()
		else
			if(mob2.agility && get_dist(atom_to_walk_to, mob_parent) > 3) //Toggle agility to four legs to catch up to target
				toggle_agility.action_activate()

		if(punch.can_use_ability(atom2, override_flags = XACT_IGNORE_SELECTED_ABILITY))
			punch.use_ability(atom2)

		if(fling.can_use_ability(atom2, override_flags = XACT_IGNORE_SELECTED_ABILITY))
			fling.use_ability(atom2)

		return REASON_REFRESH_TARGET

	if(mob2.agility)
		toggle_agility.action_activate()

	return ..()

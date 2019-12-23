/datum/ai_mind/carbon/xeno/defender
	var/datum/action/xeno_action/activable/tail_sweep/tail_sweep = new
	var/datum/action/xeno_action/activable/headbutt/headbutt = new
	var/datum/action/xeno_action/toggle_crest_defense/toggle_crest_defense = new

/datum/ai_mind/carbon/xeno/defender/New()
	..()
	tail_sweep.owner = mob_parent
	headbutt.owner = mob_parent
	toggle_crest_defense.owner = mob_parent

/datum/ai_mind/carbon/xeno/defender/do_process()
	var/mob/living/carbon/xenomorph/defender/mob2 = mob_parent
	if(istype(atom_to_walk_to, /mob/living/carbon/human))
		if(!mob2.crest_defense && get_dist(atom_to_walk_to, mob_parent) < 3)
			toggle_crest_defense.action_activate()
		else
			if(mob2.crest_defense && get_dist(atom_to_walk_to, mob_parent) > 3) //Toggle crest to catch up to target
				toggle_crest_defense.action_activate()

		if(get_dist(atom_to_walk_to, mob_parent) < 2 && tail_sweep.can_use_ability(override_flags = XACT_IGNORE_SELECTED_ABILITY))
			tail_sweep.use_ability()

		if(headbutt.can_use_ability(atom_to_walk_to, override_flags = XACT_IGNORE_SELECTED_ABILITY))
			headbutt.use_ability(atom_to_walk_to)

		return REASON_REFRESH_TARGET

	if(mob2.crest_defense)
		toggle_crest_defense.action_activate()

	return ..()

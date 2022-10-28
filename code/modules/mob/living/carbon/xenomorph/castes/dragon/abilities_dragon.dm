/obj/flamer_fire/resin
	burnflags = BURN_HUMANS|BURN_SNOW
	color = "purple"

/datum/action/xeno_action/activable/tail_stab
	name = "Tail Stab"
	// action_icon_state = "todo"
	mechanics_text = "Stab your victim with your flaming tail"
	use_state_flags = XACT_USE_STAGGERED
	plasma_cost = 100
	cooldown_timer = 7 SECONDS
	var/list/tail_sounds = list(
		
	)

/datum/action/xeno_action/activable/can_use_ability(atom/target, silent = FALSE, override_flags)
	if(owner.do_actions)
		return FALSE

	if(!line_of_sight(owner, target, 2))
		if(!silent)
			to_chat(span_notice("You can't reach the target from here!"))
		return FALSE

/datum/action/xeno_action/activable/use_ability(/mob/living/carbon/human/target)
	

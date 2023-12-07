/mob/living/carbon/xenomorph/crusher
	caste_base_type = /mob/living/carbon/xenomorph/crusher
	name = "Crusher"
	desc = "A huge alien with an enormous armored head crest."
	icon = 'icons/Xeno/castes/crusher.dmi'
	icon_state = "Crusher Walking"
	bubble_icon = "alienleft"
	health = 300
	maxHealth = 300
	plasma_stored = 200
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_NORMAL
	drag_delay = 6 //pulling a big dead xeno is hard
	mob_size = MOB_SIZE_BIG
	buckle_flags = CAN_BUCKLE

	pixel_x = -16
	pixel_y = -3
	old_x = -16
	old_y = -3


/mob/living/carbon/xenomorph/crusher/handle_special_state()
	if(is_charging >= CHARGE_ON)
		icon_state = "[xeno_caste.caste_name][is_a_rouny ? " rouny" : ""] Charging"
		return TRUE
	return FALSE


/mob/living/carbon/xenomorph/crusher/handle_special_wound_states(severity)
	. = ..()
	if(is_charging >= CHARGE_ON)
		return "crusher_wounded_charging_[severity]"

/mob/living/carbon/xenomorph/crusher/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	if(!force)//crushers should be overriden by runners
		return FALSE
	return ..()

/mob/living/carbon/xenomorph/crusher/grabbed_self_attack()
	if(!isxeno(pulling))
		return NONE
	var/mob/living/carbon/xenomorph/grabbed = pulling
	if(stat == CONSCIOUS && grabbed.xeno_caste.can_flags & CASTE_CAN_RIDE_CRUSHER)
		//If you dragged them to you and you're aggressively grabbing try to fireman carry them
		INVOKE_ASYNC(src, PROC_REF(carry_xeno), grabbed)
		return COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK
	return NONE

/mob/living/carbon/xenomorph/crusher/proc/carry_xeno(mob/living/carbon/target, forced = FALSE)
	if(incapacitated(restrained_flags = RESTRAINED_NECKGRAB))
		if(forced)
			to_chat(target, span_xenowarning("You cannot mount [src]"))
			return
		to_chat(src, span_xenowarning("[target] cannot mount you!"))
		return
	visible_message(span_notice("[forced ? "[target] starts to mount on [src]" : "[src] starts hoisting [target] onto [p_their()] back..."]"),
	span_notice("[forced ? "[target] starts to mount on your back" : "You start to lift [target] onto your back..."]"))
	if(!do_after(forced ? target : src, 5 SECONDS, NONE, forced ? src : target, target_display = BUSY_ICON_HOSTILE))
		visible_message(span_warning("[forced ? "[target] fails to mount on [src]" : "[src] fails to carry [target]!"]"))
		return
	//Second check to make sure they're still valid to be carried
	if(incapacitated(restrained_flags = RESTRAINED_NECKGRAB))
		return
	buckle_mob(target, TRUE, TRUE, 90, 1, 0)

/mob/living/carbon/xenomorph/crusher/resisted_against(datum/source)
	user_unbuckle_mob(source, source)

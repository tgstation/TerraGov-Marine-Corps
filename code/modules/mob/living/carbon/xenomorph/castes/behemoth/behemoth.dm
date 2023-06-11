/mob/living/carbon/xenomorph/behemoth
	caste_base_type = /mob/living/carbon/xenomorph/behemoth
	name = "Behemoth"
	desc = "A resilient and equally ferocious monster that commands the earth itself."
	icon = 'icons/Xeno/3x3_Xenos.dmi'
	icon_state = "Behemoth Walking"
	bubble_icon = "alienleft"
	health = 625
	maxHealth = 625
	plasma_stored = 175
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	drag_delay = 6
	mob_size = MOB_SIZE_BIG
	buckle_flags = CAN_BUCKLE
	max_buckled_mobs = 2

	pixel_x = -28.5
	old_x = -28.5


// ***************************************
// *********** Overrides
// ***************************************
/mob/living/carbon/xenomorph/behemoth/Initialize(mapload, footstep_type)
	footstep_type = FOOTSTEP_XENO_HEAVY
	return ..()

/mob/living/carbon/xenomorph/behemoth/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	if(!force)
		return FALSE
	return ..()

/mob/living/carbon/xenomorph/behemoth/grabbed_self_attack()
	if(!isxeno(pulling))
		return NONE
	var/mob/living/carbon/xenomorph/grabbed = pulling
	if(stat == CONSCIOUS && grabbed.xeno_caste.can_flags & CASTE_CAN_RIDE_CRUSHER)
		INVOKE_ASYNC(src, PROC_REF(carry_xeno), grabbed)
		return COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK
	return NONE

/mob/living/carbon/xenomorph/behemoth/proc/carry_xeno(mob/living/carbon/target, forced = FALSE)
	if(incapacitated(restrained_flags = RESTRAINED_NECKGRAB))
		if(forced)
			to_chat(target, span_xenowarning("You cannot mount [src]"))
			return
		to_chat(src, span_xenowarning("[target] cannot mount you!"))
		return
	visible_message(span_notice("[forced ? "[target] starts to mount on [src]" : "[src] starts hoisting [target] onto [p_their()] back..."]"),
	span_notice("[forced ? "[target] starts to mount on your back" : "You start to lift [target] onto your back..."]"))
	if(!do_mob(forced ? target : src, forced ? src : target, 5 SECONDS, target_display = BUSY_ICON_HOSTILE))
		visible_message(span_warning("[forced ? "[target] fails to mount on [src]" : "[src] fails to carry [target]!"]"))
		return
	//Second check to make sure they're still valid to be carried
	if(incapacitated(restrained_flags = RESTRAINED_NECKGRAB))
		return
	buckle_mob(target, TRUE, TRUE, 90, 0, 1)

/mob/living/carbon/xenomorph/behemoth/resisted_against(datum/source)
	user_unbuckle_mob(source, source)

/mob/living/carbon/xenomorph/behemoth/primordial/Stat()
	. = ..()
	if(statpanel("Game") && xeno_caste.wrath_max > 0)
		stat("Wrath:", "[wrath_stored] / [xeno_caste.wrath_max]")

/mob/living/carbon/xenomorph/crusher
	caste_base_type = /mob/living/carbon/xenomorph/crusher
	name = "Crusher"
	desc = "A huge alien with an enormous armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Crusher Walking"
	health = 300
	maxHealth = 300
	plasma_stored = 200
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	drag_delay = 6 //pulling a big dead xeno is hard
	mob_size = MOB_SIZE_BIG
	buckle_flags = CAN_BUCKLE

	pixel_x = -16
	pixel_y = -3
	old_x = -16
	old_y = -3

/mob/living/carbon/xenomorph/crusher/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/creature/crusher)
	RegisterSignal(src, COMSIG_GRAB_SELF_ATTACK, .proc/grabbed_self_attack)


/mob/living/carbon/xenomorph/crusher/ex_act(severity)

	flash_act()

	if(severity == EXPLODE_DEVASTATE)
		adjustBruteLoss(rand(200, 300), updating_health = TRUE)


/mob/living/carbon/xenomorph/crusher/handle_special_state()
	if(is_charging >= CHARGE_ON)
		icon_state = "Crusher Charging"
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

/mob/living/carbon/xenomorph/crusher/proc/grabbed_self_attack()
	SIGNAL_HANDLER
	var/mob/living/grabbed = pulling
	if(!istype(grabbed))
		return NONE
	if(stat == CONSCIOUS && isxenorunner(grabbed))
		//If you dragged them to you and you're aggressively grabbing try to fireman carry them
		INVOKE_ASYNC(src, .proc/carry_runner, grabbed)
		return COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK
	return NONE

/mob/living/carbon/xenomorph/crusher/proc/carry_runner(mob/living/carbon/target)
	if(!isxenorunner(target) || incapacitated(restrained_flags = RESTRAINED_NECKGRAB))
		to_chat(src, span_warning("You can't fireman carry [target]!"))
		return
	visible_message(span_notice("[src] starts hoisting [target] onto [p_their()] back..."),
	span_notice("You start to lift [target] onto your back..."))
	if(!do_mob(src, target, 5 SECONDS, target_display = BUSY_ICON_HOSTILE))
		visible_message(span_warning("[src] fails to carry [target]!"))
		return
	//Second check to make sure they're still valid to be carried
	if(incapacitated(restrained_flags = RESTRAINED_NECKGRAB))
		return
	buckle_mob(target, TRUE, TRUE, 90, 1, 0)

/mob/living/carbon/xenomorph/crusher/resisted_against(datum/source)
	user_unbuckle_mob(source, source)

/obj/item/implant/jump_mod
	name = "fortified ankles"
	desc = "This augmentation enhances the users ability to jump with graphene fibre reinforcements and nanogel joint fluid capsules. Hold jump to jump higher."
	implant_flags = BENEFICIAL_IMPLANT
	w_class = WEIGHT_CLASS_NORMAL
	allowed_limbs = list(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)

/obj/item/implant/jump_mod/implant(mob/living/carbon/human/target, mob/living/user)
	. = ..()
	if(!.)
		return
	var/flag_to_check = part.body_part == FOOT_RIGHT ? FOOT_LEFT : FOOT_RIGHT
	for(var/datum/limb/limb AS in target.limbs)
		if(limb.body_part != flag_to_check)
			continue
		if(!(locate(type) in limb.implants)) //you need two
			return
		RegisterSignal(target, COMSIG_LIVING_SET_JUMP_COMPONENT, PROC_REF(modify_jump))
		RegisterSignal(target, COMSIG_ELEMENT_JUMP_STARTED, PROC_REF(handle_jump))
		target.set_jump_component()
		to_chat(implant_owner, "You can now jump further and higher by holding the jump key for a charged jump!")

/obj/item/implant/jump_mod/unimplant()
	if(!implant_owner)
		return ..()
	UnregisterSignal(implant_owner, list(COMSIG_LIVING_SET_JUMP_COMPONENT, COMSIG_ELEMENT_JUMP_STARTED, COMSIG_ELEMENT_JUMP_ENDED))
	implant_owner.set_jump_component()
	return ..()

///Modifiers the owners jump component on implant and whenever it is updated
/obj/item/implant/jump_mod/proc/modify_jump(mob/living/source, list/arg_list)
	SIGNAL_HANDLER
	arg_list[6] |= JUMP_CHARGEABLE
	return TRUE

///speedboost mid jump
/obj/item/implant/jump_mod/proc/handle_jump(mob/living/mover, jump_height, jump_duration)
	SIGNAL_HANDLER
	RegisterSignal(mover, COMSIG_ELEMENT_JUMP_ENDED, PROC_REF(end_jump))
	// we subtract any slowdown maluses such as armour.
	//This creates a smoother, more consistant jump regardless of your slowdown
	var/speed_boost = 1
	for(var/i in mover.movespeed_modification)
		if(i == MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED)
			continue
		var/list/move_speed_mod = mover.movespeed_modification[i]
		if(move_speed_mod[MOVESPEED_DATA_INDEX_MULTIPLICATIVE_SLOWDOWN] < 0)
			continue
		speed_boost += move_speed_mod[MOVESPEED_DATA_INDEX_MULTIPLICATIVE_SLOWDOWN]
	mover.add_movespeed_modifier(type, priority = 1, multiplicative_slowdown = (-speed_boost))

///speedboost mid jump
/obj/item/implant/jump_mod/proc/end_jump(mob/living/mover)
	SIGNAL_HANDLER
	UnregisterSignal(mover, COMSIG_ELEMENT_JUMP_ENDED)
	mover.remove_movespeed_modifier(type)

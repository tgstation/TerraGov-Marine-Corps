/obj/item/implant/jump_mod
	name = "fortified ankles"
	desc = "This augmentation enhances the users ability to jump with graphene fibre reinforcements and nanogel join fluid capsules. Hold jump to jump higher."
	implant_flags = BENEFICIAL_IMPLANT
	w_class = WEIGHT_CLASS_NORMAL
	allowed_limbs = list(BODY_ZONE_PRECISE_GROIN) //there should only be one, but its technically a leg mod. fuck.

/obj/item/implant/jump_mod/implant(mob/living/carbon/human/target, mob/living/user)
	. = ..()
	if(!.)
		return
	RegisterSignal(target, COMSIG_LIVING_SET_JUMP_COMPONENT, PROC_REF(modify_jump))
	RegisterSignal(target, COMSIG_ELEMENT_JUMP_STARTED, PROC_REF(handle_jump))
	target.set_jump_component()

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
	mover.add_movespeed_modifier(type, priority = 1, multiplicative_slowdown = -0.8)

///speedboost mid jump
/obj/item/implant/jump_mod/proc/end_jump(mob/living/mover)
	SIGNAL_HANDLER
	UnregisterSignal(mover, COMSIG_ELEMENT_JUMP_ENDED)
	mover.remove_movespeed_modifier(type)

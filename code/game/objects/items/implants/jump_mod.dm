/obj/item/implant/jump_mod
	name = "fortified ankled"
	desc = "desc here."
	implant_flags = BENEFICIAL_IMPLANT
	w_class = WEIGHT_CLASS_NORMAL
	allowed_limbs = list(BODY_ZONE_PRECISE_GROIN) //there should only be one, but its technically a leg mod. fuck.

/obj/item/implant/jump_mod/implant(mob/living/carbon/human/target, mob/living/user)
	. = ..()
	if(!.)
		return
	RegisterSignal(target, COMSIG_LIVING_SET_JUMP_COMPONENT, PROC_REF(modify_jump))
	target.set_jump_component()

/obj/item/implant/jump_mod/unimplant()
	if(!implant_owner)
		return ..()
	UnregisterSignal(implant_owner, COMSIG_LIVING_SET_JUMP_COMPONENT)
	implant_owner.set_jump_component()
	return ..()

///Modifiers the owners jump component on implant and whenever it is updated
/obj/item/implant/jump_mod/proc/modify_jump(mob/living/source, list/arg_list)
	SIGNAL_HANDLER
	arg_list[6] |= JUMP_CHARGEABLE
	return TRUE

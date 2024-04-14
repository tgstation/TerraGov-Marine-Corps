/obj/item/implant/jump_mod
	name = "fortified ankled"
	desc = "desc here."
	//icon_state = "imp_spinal"
	implant_flags = BENEFICIAL_IMPLANT
	w_class = WEIGHT_CLASS_NORMAL
	allowed_limbs = list(BODY_ZONE_PRECISE_GROIN) //there should only be one, but its technically a leg mod. fuck.
	cooldown_time = 5 SECONDS

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
	return ..()

/obj/item/implant/jump_mod/proc/modify_jump(mob/living/source, list/arg_list)
	SIGNAL_HANDLER
	//list(duration, cooldown, cost, height, sound, flags, jump_pass_flags)
	arg_list[1] *= 1.5
	arg_list[4] *= 1.5
	arg_list[7] |= (PASS_MOB|PASS_DEFENSIVE_STRUCTURE)
	return TRUE

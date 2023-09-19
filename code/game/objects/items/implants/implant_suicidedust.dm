///Implant meant for admin ERTs that will dust a body upon death.
///In order to prevent Marines from looting things they should not ever have
/obj/item/implant/suicide_dust
	name = "self-dusting implant"
	flags_implant = NONE

/obj/item/implant/suicide_dust/implant(mob/living/carbon/human/target, mob/living/user)
	. = ..()
	RegisterSignal(implant_owner, COMSIG_MOB_DEATH, PROC_REF(on_death))

/obj/item/implant/suicide_dust/unimplant()
	if(implant_owner)
		UnregisterSignal(implant_owner, COMSIG_MOB_DEATH)
	return ..()

/obj/item/implant/suicide_dust/proc/on_death()
	SIGNAL_HANDLER
	INVOKE_ASYNC(implant_owner, TYPE_PROC_REF(/mob, dust))

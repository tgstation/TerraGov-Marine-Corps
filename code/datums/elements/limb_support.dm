/datum/element/limb_support
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	var/limbs_to_support = FULL_BODY

/datum/element/limb_support/Attach(datum/target, limbflags)
	. = ..()
	if(limbflags)
		limbs_to_support = limbflags

	RegisterSignal(target, COMSIG_ITEM_EQUIPPED_TO_SLOT, PROC_REF(equipped))
	RegisterSignals(target, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), PROC_REF(dropped))

/datum/element/limb_support/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ITEM_EQUIPPED_TO_SLOT, COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED))

/datum/element/limb_support/proc/equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(!ishuman(equipper))
		return
	RegisterSignal(equipper, COMSIG_HUMAN_LIMB_FRACTURED, PROC_REF(fuckibrokemyleg))
	fuckibrokemyleg(equipper, null, FALSE) // manually called when equipped to stabilize limbs

///stops stabilizing limbs when dropped
/datum/element/limb_support/proc/dropped(datum/source, mob/equipper)
	SIGNAL_HANDLER
	fuckibrokemyleg(equipper, null, TRUE) // manually called when dropped to remove stabilization of limbs
	UnregisterSignal(equipper, COMSIG_HUMAN_LIMB_FRACTURED)

///stabilizes a limb when broken
/datum/element/limb_support/proc/fuckibrokemyleg(datum/owner, datum/limb/fractured_limb, dropped = FALSE)
	SIGNAL_HANDLER
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/injured_mob = owner
	var/obj/item/clothing/worn_suit = injured_mob.wear_suit

	for(var/datum/limb/limb in injured_mob.limbs)
		if(!(limbs_to_support & limb.body_part))
			continue

		if(dropped && (limb.limb_status & LIMB_STABILIZED))
			limb.limb_status &= ~LIMB_STABILIZED
			to_chat(injured_mob, span_danger("You feel the pressure from [worn_suit] about your [limb.display_name] release, leaving it unsupported."))
			playsound(worn_suit, 'sound/machines/hiss.ogg', 15, 0, 1)
			continue

		if(!dropped && ((limb.limb_status & LIMB_BROKEN) && !(limb.limb_status & LIMB_STABILIZED)))
			limb.limb_status |= LIMB_STABILIZED
			playsound(worn_suit, 'sound/voice/b18/fracture.ogg', 15, 0, 1)
			to_chat(injured_mob, span_notice("<b>You feel [worn_suit] constrict about your [limb.display_name], stabilizing it.</b>"))
			playsound(worn_suit, 'sound/machines/hydraulics_1.ogg', 15, 0, 1)

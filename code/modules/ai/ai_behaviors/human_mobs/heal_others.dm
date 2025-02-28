///Tries to heal another mob
/datum/ai_behavior/human/proc/try_heal_other(mob/living/carbon/human/patient)
	if(patient.InCritical())
		crit_heal(patient)

///Handles a friendly in crit
/datum/ai_behavior/human/proc/crit_heal(mob/living/carbon/human/patient)
	var/obj/item/heal_item

	for(var/obj/item/stored_item AS in mob_inventory.oxy_list)
		if(!stored_item.ai_should_use(patient, mob_parent))
			continue
		heal_item = stored_item
		break

	if(!heal_item)
		return FALSE
	heal_item.ai_use(patient, mob_parent)
	return TRUE

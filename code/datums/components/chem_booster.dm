/**
	Chem booster component

	This component stores virilyth and uses it to increase REM.

	Parameters
	*

*/

/datum/component/chem_booster
	///Amount of substance that the suit can store
	var/reagent_storage
	var/obj/item/healthanalyzer/integrated/analyzer

	var/mob/living/carbon/wearer

/datum/component/chem_booster/Initialize(reagent_storage_amount)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

	analyzer = new

	if(!isnull(reagent_storage_amount))
		reagent_storage = reagent_storage_amount



/datum/component/chem_booster/Destroy(force, silent)
	QDEL_NULL(analyzer)
	wearer = null
	return ..()

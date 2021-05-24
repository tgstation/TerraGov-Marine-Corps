


/datum/component/deployable
	var/deployed = FALSE
	var/deploy_type = /obj/machinery/deployable
	var/obj/item/parent

/datum/component/deployable/Initialize(obj/item/_parent)
	if(!_parent.flags_item & IS_DEPLOYABLE)
		return COMPONENT_INCOMPATIBLE
	

/datum/component/deployable/deploy(mob/user)
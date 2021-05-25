


/datum/component/deployable
	var/deployed = FALSE
	var/deploy_type = /obj/machinery/deployable
	var/obj/item/attached_item

/datum/component/deployable/Initialize(obj/item/_parent)
	. = ..()
	if(!_parent.flags_item & IS_DEPLOYABLE)
		return COMPONENT_INCOMPATIBLE
	attached_item = _parent

/datum/component/deployable/deploy(mob/user)
	var/step = get_step(user, user.dir)
	if(!ishuman(user)) 
		return
	if(attached_item.check_blocked_turf(step))
		to_chat(user, "<span class='warning'>There is insufficient room to deploy [attached_item]!</span>")
		return
	if(!do_after(user, attached_item.deploy_time, TRUE, attached_item, BUSY_ICON_BUILD))
		return
	to_chat(user, "<span class='notice'>You deploy [attached_item].</span>")
	
	user.temporarilyRemoveItemFromInventory(attached_item)
	var/obj/machinery/deployable/deploying = new deploy_type(step)
	deploying.deploy(attached_item, user.dir)
	deployed = TRUE

/datum/component/deployable/un_deploy(mob/user, /obj/machinery/deployable/deployed)
	to_chat(user, "<span class='notice'>You begin disassembling [attached_item].</span>")
	if(!do_after(user, attached_item.deploy_time, TRUE, attached_item, BUSY_ICON_BUILD))
		return
	user.visible_message("<span class='notice'> [user] disassembles [attached_item]! </span>","<span class='notice'> You disassemble [attached_item]!</span>")

	user.unset_interaction()
	attached_item.deploy_integrity = deployed.obj_integrity

	user.put_in_active_hand(attached_item)
	deployed = FALSE

/obj/item/proc/is_deployed()
	var/datum/component/deployable/component = GetComponent(/datum/component/deployable/)
	if(!component)
		return FALSE
	return component.deployed
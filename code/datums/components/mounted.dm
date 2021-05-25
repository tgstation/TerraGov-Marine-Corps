


/datum/component/deployable_item
	var/deployed
	var/obj/item/parent_item
	var/obj/machinery/deployable/deployed_machine

/datum/component/deployable_item/Initialize(machine_type, deploy_time, )
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	parent_item = parent
	if(!parent_item.flags_item & IS_DEPLOYABLE)
		return COMPONENT_INCOMPATIBLE
	deployed_machine = new deployed_machine(parent_item)
	RegisterSignal(parent_item, COMSIG_ITEM_DEPLOY, .proc/deploy)
	RegisterSignal(parent_item, COMSIG_IS_DEPLOYED, .proc/is_deployed)

/datum/component/deployable_item/proc/deploy(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, "<span class='notice'>you start deploying the [source]</span>")
	INVOKE_ASYNC(src, .proc/finish_deploy, source, user)

/datum/component/deployable_item/proc/finish_deploy(datum/source, mob/user)
	var/turf/here = get_step(user, user.dir)
	if(!ishuman(user)) 
		return
	if(parent_item.check_blocked_turf(here))
		to_chat(user, "<span class='warning'>There is insufficient room to deploy [parent_item]!</span>")
		return
	if(!do_after(user, parent_item.deploy_time, TRUE, parent_item, BUSY_ICON_BUILD))
		return
	
	deployed_machine.forceMove(here)
	deployed_machine.deploy(parent_item, user.dir)
	user.temporarilyRemoveItemFromInventory(parent_item)
	parent_item.forceMove(deployed_machine)

	deployed = TRUE

	RegisterSignal(parent_item, COMSIG_ATOM_UPDATE_ICON, .proc/update_machine_icon_state)
	RegisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY, .proc/undeploy, user)


/datum/component/deployable_item/proc/undeploy(mob/user)
	SIGNAL_HANDLER
	to_chat(user, "<span class='notice'>You begin disassembling [parent_item].</span>")
	INVOKE_ASYNC(src, .proc/finish_undeploy, user)

/datum/component/deployable_item/proc/finish_undeploy(mob/user)
	if(!do_after(user, parent_item.deploy_time, TRUE, parent_item, BUSY_ICON_BUILD))
		return
	user.visible_message("<span class='notice'> [user] disassembles [parent_item]! </span>","<span class='notice'> You disassemble [parent_item]!</span>")

	user.unset_interaction()
	parent_item.deploy_integrity = deployed_machine.obj_integrity

	user.put_in_active_hand(parent)
	deployed = FALSE

	UnregisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY)
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_ICON)

/datum/component/deployable_item/proc/is_deployed()
	return deployed

/datum/component/deployable_item/proc/update_machine_icon_state()
	deployed_machine.update_icon_state()

/obj/item/proc/is_deployed()
	return SEND_SIGNAL(src, COMSIG_IS_DEPLOYED)

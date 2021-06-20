


/datum/component/deployable_item
	var/deployed = FALSE
	var/deploy_time
	var/obj/item/parent_item
	var/obj/machinery/deployable/deployed_machine

/datum/component/deployable_item/Initialize(_deploy_time, deploy_type)
	. = ..()
	deploy_time = _deploy_time
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	
	parent_item = parent

	if(!(parent_item.flags_item & IS_DEPLOYABLE))
		return COMPONENT_INCOMPATIBLE
	
	deploy_time = _deploy_time
	deployed_machine = deploy_type
	
	
	deployed_machine = new deployed_machine(parent_item)
	deployed_machine.set_stats(parent_item)
	RegisterSignal(parent_item, COMSIG_ITEM_DEPLOY, .proc/deploy)
	RegisterSignal(parent_item, COMSIG_IS_DEPLOYED, .proc/is_deployed)
	RegisterSignal(parent_item, COMSIG_DEPLOYABLE_SET_DEPLOYED, .proc/set_deploy)

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
	if(!do_after(user, deploy_time, TRUE, parent_item, BUSY_ICON_BUILD))
		return

	deployed_machine.forceMove(here)
	deployed_machine.setDir(user.dir)

	user.temporarilyRemoveItemFromInventory(parent_item)
	parent_item.forceMove(deployed_machine)

	deployed = TRUE

	RegisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY, .proc/undeploy)


/datum/component/deployable_item/proc/undeploy(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, "<span class='notice'>You begin disassembling [parent_item].</span>")
	INVOKE_ASYNC(src, .proc/finish_undeploy, source, user)

/datum/component/deployable_item/proc/finish_undeploy(datum/source, mob/user)
	if(!do_after(user, deploy_time, TRUE, deployed_machine, BUSY_ICON_BUILD))
		return
	user.visible_message("<span class='notice'> [user] disassembles [parent_item]! </span>","<span class='notice'> You disassemble [parent_item]!</span>")

	user.unset_interaction()
	user.put_in_hands(parent)

	deployed = FALSE

	UnregisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY)

	deployed_machine.forceMove(parent_item)

/datum/component/deployable_item/proc/set_deploy(datum/source, _deployed)
	SIGNAL_HANDLER
	deployed = _deployed

/datum/component/deployable_item/proc/is_deployed()
	SIGNAL_HANDLER
	return deployed

/obj/item/proc/is_deployed()
	return SEND_SIGNAL(src, COMSIG_IS_DEPLOYED)





/datum/component/deployable_item/mounted_gun

/datum/component/deployable_item/mounted_gun/finish_deploy(datum/source, mob/user)
	. = ..()
	parent_item.UnregisterSignal(user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDRAG, COMSIG_KB_RAILATTACHMENT, COMSIG_KB_UNDERRAILATTACHMENT, COMSIG_KB_UNLOADGUN, COMSIG_KB_FIREMODE))

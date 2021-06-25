/datum/component/deployable_item
	///Time it takes for the parent to be deployed/undeployed
	var/deploy_time = 0

	var/wrench_dissasemble = FALSE

	///Machine that parent is deployed into and out of
	var/obj/machinery/deployable/deployed_machine

/datum/component/deployable_item/Initialize(deploy_type, _deploy_time)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	deploy_time = _deploy_time
	deployed_machine = deploy_type

	deployed_machine = new deploy_type(parent, parent)
	RegisterSignal(parent, COMSIG_ITEM_DEPLOY, .proc/deploy)

///Wrapper for proc/finish_deploy
/datum/component/deployable_item/proc/deploy(datum/source, mob/user, location, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/finish_deploy, source, user, location, direction)

///Handles the conversion of item into machine
/datum/component/deployable_item/proc/finish_deploy(datum/source, mob/user, location, direction)
	var/new_direction
	var/obj/item/parent_item = parent
	if(user)
		if(!ishuman(user)) 
			return
		var/turf/here = get_step(user, user.dir)
		if(parent_item.check_blocked_turf(here))
			to_chat(user, "<span class='warning'>There is insufficient room to deploy [parent_item]!</span>")
			return
		new_direction = user.dir
		to_chat(user, "<span class='notice'>You start deploying the [parent_item].</span>")
		if(!do_after(user, deploy_time, TRUE, parent_item, BUSY_ICON_BUILD))
			return

		deployed_machine.forceMove(here)
		user.temporarilyRemoveItemFromInventory(parent_item)

		parent_item.UnregisterSignal(user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDRAG, COMSIG_KB_RAILATTACHMENT, COMSIG_KB_UNDERRAILATTACHMENT, COMSIG_KB_UNLOADGUN, COMSIG_KB_FIREMODE))
	else
		if(!location || !direction)
			CRASH("/datum/component/deployable_item/deploy has been called from [source] without a user and therefore is missing the required vars of either 'location' or 'direction'")
		
		new_direction = direction
		deployed_machine.forceMove(location)

	deployed_machine.setDir(new_direction)
	deployed_machine.update_icon_state()
	parent_item.forceMove(deployed_machine)

	ENABLE_BITFIELD(parent_item.flags_item, IS_DEPLOYED)

	RegisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY, .proc/undeploy)

///Wrapper for proc/finish_undeploy
/datum/component/deployable_item/proc/undeploy(datum/source, mob/user, location)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/finish_undeploy, source, user, location)

/datum/component/deployable_item/proc/finish_undeploy(datum/source, mob/user, location)
	var/obj/item/parent_item = parent
	if(user)
		if(!ishuman(user))
			return
		to_chat(user, "<span class = 'notice'>You start disassembling the [parent_item]</span>")
		if(!do_after(user, deploy_time, TRUE, deployed_machine, BUSY_ICON_BUILD))
			return
		user.unset_interaction()
		user.put_in_hands(parent_item)
	else
		if(!location)
			CRASH("/datum/component/deployable_item/undeploy has been called from [source] without a user and therefore is missing the required var of 'location'")

		parent_item.forceMove(get_turf(location))
	DISABLE_BITFIELD(parent_item.flags_item, IS_DEPLOYED)
	UnregisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY)
	deployed_machine.forceMove(parent_item)
	parent_item.update_icon_state()
	SEND_SIGNAL(deployed_machine, COMSIG_PARENT_QDELETING)





/datum/component/deployable_item
	///Time it takes for the parent to be deployed/undeployed
	var/deploy_time = 0

	var/wrench_dissasemble = FALSE

	///Machine that parent is deployed into and out of
	var/obj/machinery/deployable/deployed_machine

/datum/component/deployable_item/Initialize(deploy_type, _deploy_time, _wrench_dissasemble)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	deploy_time = _deploy_time
	deployed_machine = deploy_type
	wrench_dissasemble = _wrench_dissasemble

	
	deployed_machine = new deployed_machine(parent, parent)
	RegisterSignal(parent, COMSIG_ITEM_DEPLOY, .proc/deploy)

///Wrapper for proc/finish_deploy
/datum/component/deployable_item/proc/deploy(datum/source, mob/user, location, direction)
	SIGNAL_HANDLER
	if(user)
		to_chat(user, "<span class='notice'>you start deploying the [source]</span>")
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
		if(!do_after(user, deploy_time, TRUE, parent_item, BUSY_ICON_BUILD))
			return

		deployed_machine.forceMove(here)
		user.temporarilyRemoveItemFromInventory(parent_item)
	else
		if(!location || !direction)
			CRASH("/datum/component/deployable_item/deploy has been called from [source] without a user and therefore is missing the required vars of either 'location' or 'direction'")
		
		new_direction = direction
		deployed_machine.forceMove(location)

	deployed_machine.setDir(new_direction)
	parent_item.forceMove(deployed_machine)

	parent_item.flags_item |= IS_DEPLOYED

	RegisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY, .proc/undeploy)

///Wrapper for proc/finish_undeploy
/datum/component/deployable_item/proc/undeploy(datum/source, mob/user, using_wrench)
	SIGNAL_HANDLER
	to_chat(user, "<span class='notice'>You begin disassembling [parent].</span>")
	INVOKE_ASYNC(src, .proc/finish_undeploy, source, user, using_wrench)

///Transfers the machine into the item
/datum/component/deployable_item/proc/finish_undeploy(datum/source, mob/user, using_wrench)
	var/obj/item/parent_item = parent
	if(!using_wrench && wrench_dissasemble)
		return
	if(!do_after(user, deploy_time, TRUE, deployed_machine, BUSY_ICON_BUILD))
		return
	user.visible_message("<span class='notice'> [user] disassembles [parent_item]! </span>","<span class='notice'> You disassemble [parent]!</span>")

	user.unset_interaction()
	user.put_in_hands(parent_item)

	parent_item.flags_item &= -IS_DEPLOYED

	UnregisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY)

	deployed_machine.forceMove(parent)
	SEND_SIGNAL(deployed_machine, COMSIG_PARENT_QDELETING)


/datum/component/deployable_item/mounted_gun

///Unregisters for safety
/datum/component/deployable_item/mounted_gun/finish_deploy(datum/source, mob/user)
	. = ..()
	if(user)
		parent.UnregisterSignal(user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDRAG, COMSIG_KB_RAILATTACHMENT, COMSIG_KB_UNDERRAILATTACHMENT, COMSIG_KB_UNLOADGUN, COMSIG_KB_FIREMODE))

GLOBAL_LIST_EMPTY(deployable_items)

/datum/element/deployable_item
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	///Time it takes for the parent to be deployed.
	var/deploy_time = 0
	///Time it takes for the parent to be undeployed.
	var/undeploy_time = 0
	///Typepath that the item deploys into. Can be anything but an item so far. The preffered type is /obj/machinery/deployable since it was built for this.
	var/obj/deploy_type

/datum/element/deployable_item/Attach(datum/target, _deploy_type, _deploy_time, _undeploy_time)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	deploy_type = _deploy_type
	deploy_time = _deploy_time
	undeploy_time = _undeploy_time

	var/obj/item/attached_item = target
	LAZYADD(GLOB.deployable_items[attached_item.type], attached_item)
	if(CHECK_BITFIELD(attached_item.flags_item, DEPLOY_ON_INITIALIZE))
		finish_deploy(attached_item, null, attached_item.loc, attached_item.dir)

	RegisterSignal(attached_item, COMSIG_ITEM_EQUIPPED, PROC_REF(register_for_deploy_signal))

/datum/element/deployable_item/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_EQUIPPED)
	LAZYREMOVE(GLOB.deployable_items[source.type], source)

///Register click signals to be ready for deploying
/datum/element/deployable_item/proc/register_for_deploy_signal(obj/item/item_equipped, mob/user, slot)
	SIGNAL_HANDLER
	if(slot != SLOT_L_HAND && slot != SLOT_R_HAND)
		return
	RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, PROC_REF(deploy), TRUE) //You can hold more than one deployable item at once
	RegisterSignal(item_equipped, COMSIG_ITEM_UNEQUIPPED, PROC_REF(unregister_signals))

///Unregister and stop waiting for click to deploy
/datum/element/deployable_item/proc/unregister_signals(obj/item/item_unequipped, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)
	UnregisterSignal(item_unequipped, COMSIG_ITEM_UNEQUIPPED)

///Wrapper for proc/finish_deploy
/datum/element/deployable_item/proc/deploy(mob/user, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	if(!isturf(location))
		return
	if(ISDIAGONALDIR(get_dir(user,location)))
		return
	var/obj/item/item_in_active_hand = user.get_active_held_item()
	if(!(item_in_active_hand) || !(item_in_active_hand in GLOB.deployable_items[item_in_active_hand.type]))
		return
	var/list/modifiers = params2list(params)
	if(!modifiers["ctrl"] || modifiers["right"] || get_turf(user) == location || !(user.Adjacent(object)) || !location)
		return
	INVOKE_ASYNC(src, PROC_REF(finish_deploy), item_in_active_hand, user, location)
	return COMSIG_KB_ACTIVATED

///Handles the conversion of item into machine. Source is the Item to be deployed, user is who is deploying. If user is null, a direction must be set.
/datum/element/deployable_item/proc/finish_deploy(obj/item/item_to_deploy, mob/user, turf/location, direction)

	var/direction_to_deploy
	var/obj/deployed_machine

	if(user)
		if(!ishuman(user) || CHECK_BITFIELD(item_to_deploy.flags_item, NODROP))
			return

		if(LinkBlocked(get_turf(user), location))
			location.balloon_alert(user, "No room to deploy")
			return
		if(user.do_actions)
			user.balloon_alert(user, "You are already doing something!")
			return
		user.balloon_alert(user, "You start deploying...")
		user.setDir(get_dir(user, location)) //Face towards deploy location for ease of deploy.
		var/newdir = user.dir //Save direction before the doafter for ease of deploy
		if(!do_after(user, deploy_time, TRUE, item_to_deploy, BUSY_ICON_BUILD))
			return
		if(LinkBlocked(get_turf(user), location))
			location.balloon_alert(user, "No room to deploy")
			return
		user.temporarilyRemoveItemFromInventory(item_to_deploy)

		item_to_deploy.UnregisterSignal(user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDRAG, COMSIG_KB_RAILATTACHMENT, COMSIG_KB_UNDERRAILATTACHMENT, COMSIG_KB_UNLOADGUN, COMSIG_KB_FIREMODE,  COMSIG_MOB_CLICK_RIGHT)) //This unregisters Signals related to guns, its for safety

		direction_to_deploy = newdir

	else
		if(!direction)
			CRASH("[item_to_deploy] attempted to deploy itself as a null user without the arg direction")
		direction_to_deploy = direction

	deployed_machine = new deploy_type(location,item_to_deploy, user)//Creates new structure or machine at 'deploy' location and passes on 'item_to_deploy'
	deployed_machine.setDir(direction_to_deploy)


	deployed_machine.max_integrity = item_to_deploy.max_integrity //Syncs new machine or structure integrity with that of the item.
	deployed_machine.obj_integrity = item_to_deploy.obj_integrity

	deployed_machine.update_icon_state()

	if(user)
		item_to_deploy.balloon_alert(user, "Deployed!")
		user.transferItemToLoc(item_to_deploy, deployed_machine, TRUE)
	else
		item_to_deploy.forceMove(deployed_machine)

	item_to_deploy.toggle_deployment_flag(TRUE)
	RegisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY, PROC_REF(undeploy))

///Wrapper for proc/finish_undeploy
/datum/element/deployable_item/proc/undeploy(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(finish_undeploy), source, user)

//Handles the conversion of Machine into Item. 'source' should be the Machine. User is the one undeploying. It can be undeployed without a user, if so, the var 'location' is required. If 'source' is not /obj/machinery/deployable then 'undeploying' should be the item to be undeployed from the machine.
/datum/element/deployable_item/proc/finish_undeploy(datum/source, mob/user)
	var/obj/deployed_machine = source //The machinethat is undeploying should be the the one sending the Signal
	var/obj/item/undeployed_item  = deployed_machine.get_internal_item() //Item the machine is undeploying

	if(!user)
		CRASH("[source] has sent the signal COMSIG_ITEM_UNDEPLOY to [undeployed_item] without the arg 'user'")
	if(!ishuman(user))
		return
	var/obj/machinery/deployable/mounted/sentry/sentry
	if(istype(deployed_machine, /obj/machinery/deployable/mounted/sentry))
		sentry = deployed_machine
	sentry?.set_on(FALSE)
	user.balloon_alert(user, "You start disassembling [undeployed_item]")
	if(!do_after(user, deploy_time, TRUE, deployed_machine, BUSY_ICON_BUILD))
		sentry?.set_on(TRUE)
		return

	undeployed_item.toggle_deployment_flag()

	user.unset_interaction()

	if((get_dist(deployed_machine, user) > 1) || deployed_machine.z != user.z)
		undeployed_item.forceMove(get_turf(deployed_machine))
	else
		user.put_in_hands(undeployed_item)

	undeployed_item.max_integrity = deployed_machine.max_integrity
	undeployed_item.obj_integrity = deployed_machine.obj_integrity

	deployed_machine.clear_internal_item()

	QDEL_NULL(deployed_machine)
	undeployed_item.update_icon_state()

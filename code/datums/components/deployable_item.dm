
/datum/component/deployable_item
	///Time it takes for the parent to be deployed.
	var/deploy_time = 0
	///Time it takes for the parent to be undeployed.
	var/undeploy_time = 0
	///Typepath that the item deploys into. Can be anything but an item so far. The preffered type is /obj/machinery/deployable since it was built for this.
	var/obj/deploy_type
	///Any extra checks required when trying to deploy this item
	var/datum/callback/deploy_check_callback
	///Helps to determine if the item should be deployable in areas like the tad and alamo
	var/restricted_deployment

/datum/component/deployable_item/Initialize(_deploy_type, _deploy_time, _undeploy_time, _deploy_check_callback, _restricted_deployment = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	deploy_type = _deploy_type
	deploy_time = _deploy_time
	undeploy_time = _undeploy_time
	deploy_check_callback = _deploy_check_callback
	restricted_deployment = _restricted_deployment

	var/obj/item/attached_item = parent
	if(CHECK_BITFIELD(attached_item.item_flags, DEPLOY_ON_INITIALIZE))
		finish_deploy(attached_item, null, attached_item.loc, attached_item.dir)

/datum/component/deployable_item/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(register_for_deploy_signal))
	RegisterSignal(parent, COMSIG_ITEM_DEPLOY, PROC_REF(self_deploy))

/datum/component/deployable_item/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DEPLOY)

///Register click signals to be ready for deploying
/datum/component/deployable_item/proc/register_for_deploy_signal(obj/item/item_equipped, mob/user, slot)
	SIGNAL_HANDLER
	if(slot != SLOT_L_HAND && slot != SLOT_R_HAND)
		return
	RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, PROC_REF(deploy))
	RegisterSignal(item_equipped, COMSIG_ITEM_UNEQUIPPED, PROC_REF(unregister_signals))

///Unregister and stop waiting for click to deploy
/datum/component/deployable_item/proc/unregister_signals(obj/item/item_unequipped, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)
	UnregisterSignal(item_unequipped, COMSIG_ITEM_UNEQUIPPED)

///Wrapper for objects deploying themselves
/datum/component/deployable_item/proc/self_deploy(obj/source, mob/user, turf/location)
	SIGNAL_HANDLER
	if(!isturf(location))
		return
	if(deploy_check_callback && !deploy_check_callback.Invoke(user, location))
		return
	INVOKE_ASYNC(src, PROC_REF(finish_deploy), parent, user, location)

///Wrapper for proc/finish_deploy
/datum/component/deployable_item/proc/deploy(mob/user, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	if(!isturf(location))
		return
	if(ISDIAGONALDIR(get_dir(user,location)))
		return
	if(parent != user.get_active_held_item())
		return
	var/list/modifiers = params2list(params)
	if(!modifiers["ctrl"] || modifiers["right"] || get_turf(user) == location || !(user.Adjacent(object)) || !location)
		return
	if(deploy_check_callback && !deploy_check_callback.Invoke(user, location))
		return
	INVOKE_ASYNC(src, PROC_REF(finish_deploy), parent, user, location)
	return COMSIG_KB_ACTIVATED

///Handles the conversion of item into machine. Source is the Item to be deployed, user is who is deploying. If user is null, a direction must be set.
/datum/component/deployable_item/proc/finish_deploy(obj/item/item_to_deploy, mob/user, turf/location, direction)

	var/direction_to_deploy
	var/obj/deployed_machine

	if(user && item_to_deploy.loc == user) //somethings can be deployed remotely
		if(!ishuman(user) || HAS_TRAIT(item_to_deploy, TRAIT_NODROP))
			return

		if(restricted_deployment)
			var/area/area = get_area(location)
			var/turf/open/placement_loc = location
			if(!placement_loc.allow_construction || area.area_flags & NO_CONSTRUCTION) // long ass series of checks to prevent things like deployable shields on alamo
				user.balloon_alert(user, "unsuitable area!")
				return

		if(LinkBlocked(get_turf(user), location))
			location.balloon_alert(user, "no room here!")
			return
		var/newdir = get_dir(user, location)
		if(deploy_type.atom_flags & ON_BORDER)
			for(var/obj/object in location)
				if(!object.density)
					continue
				if(!(object.atom_flags & ON_BORDER))
					continue
				if(object.dir != newdir)
					continue
				location.balloon_alert(user, "no room here!")
				return
		if(user.do_actions)
			user.balloon_alert(user, "busy!")
			return
		user.balloon_alert(user, "deploying...")
		user.setDir(newdir) //Face towards deploy location for ease of deploy.
		if(!do_after(user, deploy_time, NONE, item_to_deploy, BUSY_ICON_BUILD))
			return
		if(LinkBlocked(get_turf(user), location))
			location.balloon_alert(user, "no room here!")
			return
		user.temporarilyRemoveItemFromInventory(item_to_deploy)

		item_to_deploy.UnregisterSignal(user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDRAG, COMSIG_KB_RAILATTACHMENT, COMSIG_KB_MUZZLEATTACHMENT, COMSIG_KB_UNDERRAILATTACHMENT, COMSIG_KB_UNLOADGUN, COMSIG_KB_AUTOEJECT, COMSIG_MOB_CLICK_RIGHT)) //This unregisters Signals related to guns, its for safety

		direction_to_deploy = newdir

	else
		direction_to_deploy = direction || item_to_deploy.dir

	deployed_machine = new deploy_type(location,item_to_deploy, user)//Creates new structure or machine at 'deploy' location and passes on 'item_to_deploy'
	deployed_machine.setDir(direction_to_deploy)


	deployed_machine.max_integrity = item_to_deploy.max_integrity //Syncs new machine or structure integrity with that of the item.
	deployed_machine.obj_integrity = item_to_deploy.obj_integrity

	if(item_to_deploy?.reagents?.total_volume)
		item_to_deploy.reagents.trans_to(deployed_machine, item_to_deploy.reagents.total_volume)

	deployed_machine.update_appearance()

	if(user && item_to_deploy.loc == user)
		item_to_deploy.balloon_alert(user, "deployed!")
		user.transferItemToLoc(item_to_deploy, deployed_machine, TRUE)
		if(user.client.prefs.toggles_gameplay & AUTO_INTERACT_DEPLOYABLES)
			deployed_machine.interact(user)
	else
		item_to_deploy.forceMove(deployed_machine)

	item_to_deploy.toggle_deployment_flag(TRUE)
	RegisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY, PROC_REF(undeploy))
	RegisterSignal(item_to_deploy, COMSIG_MOVABLE_MOVED, PROC_REF(on_item_move))

///Qdels the deployed object if the internal item is somehow removed
/datum/component/deployable_item/proc/on_item_move(obj/item/source, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER
	if(source.loc == old_loc)
		return
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	qdel(old_loc)

///Wrapper for proc/finish_undeploy
/datum/component/deployable_item/proc/undeploy(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(finish_undeploy), source, user)

//Handles the conversion of Machine into Item. 'source' should be the Machine. User is the one undeploying. It can be undeployed without a user, if so, the var 'location' is required. If 'source' is not /obj/machinery/deployable then 'undeploying' should be the item to be undeployed from the machine.
/datum/component/deployable_item/proc/finish_undeploy(datum/source, mob/user)
	var/obj/deployed_machine = source //The machinethat is undeploying should be the the one sending the Signal
	var/obj/item/undeployed_item = deployed_machine.get_internal_item() //Item the machine is undeploying

	if(!undeployed_item)
		CRASH("[src] is missing its internal item.")

	if(!user)
		CRASH("[source] has sent the signal COMSIG_ITEM_UNDEPLOY to [undeployed_item] without the arg 'user'")
	if(!ishuman(user))
		return
	var/obj/machinery/deployable/mounted/sentry/sentry
	if(istype(deployed_machine, /obj/machinery/deployable/mounted/sentry))
		sentry = deployed_machine
	sentry?.set_on(FALSE)
	user.balloon_alert(user, "disassembling...")
	if(!do_after(user, undeploy_time, NONE, deployed_machine, BUSY_ICON_BUILD))
		sentry?.set_on(TRUE)
		return

	deployed_machine.post_disassemble(user)
	undeployed_item.toggle_deployment_flag()

	user.unset_interaction()

	UnregisterSignal(undeployed_item, COMSIG_MOVABLE_MOVED)
	if((get_dist(deployed_machine, user) > 1) || deployed_machine.z != user.z)
		undeployed_item.forceMove(get_turf(deployed_machine))
	else
		user.put_in_hands(undeployed_item)

	undeployed_item.max_integrity = deployed_machine.max_integrity
	undeployed_item.obj_integrity = deployed_machine.obj_integrity

	if(deployed_machine?.reagents?.total_volume)
		deployed_machine.reagents.trans_to(undeployed_item, deployed_machine.reagents.total_volume)

	deployed_machine.clear_internal_item()

	QDEL_NULL(deployed_machine)
	undeployed_item.update_appearance()

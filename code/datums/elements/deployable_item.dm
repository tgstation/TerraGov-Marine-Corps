/datum/element/deployable_item
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	///Time it takes for the parent to be deployed.
	var/deploy_time = 0
	///Time it takes for the parent to be undeployed.
	var/undeploy_time = 0
	///Typath that the item deploys into. Can be anything but an item so far. The preffered type is /obj/machinery/deployable since it was built for this.
	var/obj/deploy_type

/datum/element/deployable_item/Attach(datum/target, _deploy_type, _deploy_time, _undeploy_time)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	deploy_type = _deploy_type
	deploy_time = _deploy_time
	undeploy_time = _undeploy_time

	var/obj/item/attached_item = target
	if(CHECK_BITFIELD(attached_item.flags_item, DEPLOY_ON_INITIALIZE))
		finish_deploy(attached_item, null, attached_item.loc, attached_item.dir)

	RegisterSignal(attached_item, COMSIG_CLICK_CTRL, .proc/deploy)


/datum/element/deployable_item/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_CLICK_CTRL)

///Wrapper for proc/finish_deploy
/datum/element/deployable_item/proc/deploy(datum/source, mob/user, location, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/finish_deploy, source, user, location, direction)
	return COMSIG_KB_ACTIVATED


///Handles the conversion of item into machine. Source is the Item to be deployed, user is who is deploying. If user is null then 'location' and 'direction' are required for deployment.
/datum/element/deployable_item/proc/finish_deploy(datum/source, mob/user, location, direction)
	var/obj/item/attached_item = source
	var/obj/deployed_machine
	var/deploy_location
	var/new_direction
	if(user)
		if(!ishuman(user))
			return

		deploy_location = get_step(user, user.dir)
		if(attached_item.check_blocked_turf(deploy_location))
			user.balloon_alert(user, "There is insufficient room to deploy [attached_item]!")
			return
		if(user.do_actions)
			user.balloon_alert(user, "You are already doing something!")
			return
		new_direction = user.dir
		user.balloon_alert(user, "You start deploying...")
		if(!do_after(user, deploy_time, TRUE, attached_item, BUSY_ICON_BUILD))
			return

		user.temporarilyRemoveItemFromInventory(attached_item)

		attached_item.UnregisterSignal(user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDRAG, COMSIG_KB_RAILATTACHMENT, COMSIG_KB_UNDERRAILATTACHMENT, COMSIG_KB_UNLOADGUN, COMSIG_KB_FIREMODE,  COMSIG_MOB_CLICK_RIGHT)) //This unregisters Signals related to guns, its for safety
	else
		deploy_location = location
		new_direction = direction

	deployed_machine = new deploy_type(deploy_location, attached_item, user) //Creates new structure or machine at 'deploy' location and passes on 'attached_item'
	deployed_machine.setDir(new_direction)

	deployed_machine.max_integrity = attached_item.max_integrity //Syncs new machine or structure integrity with that of the item.
	deployed_machine.obj_integrity = attached_item.obj_integrity

	deployed_machine.update_icon_state()

	attached_item.forceMove(deployed_machine) //Moves the Item into the machine or structure
	if(user)
		attached_item.balloon_alert(user, "Deployed!")

	ENABLE_BITFIELD(attached_item.flags_item, IS_DEPLOYED)

	UnregisterSignal(attached_item, COMSIG_CLICK_CTRL)
	RegisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY, .proc/undeploy)

///Wrapper for proc/finish_undeploy
/datum/element/deployable_item/proc/undeploy(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/finish_undeploy, source, user)

//Handles the conversion of Machine into Item. 'source' should be the Machine. User is the one undeploying. It can be undeployed without a user, if so, the var 'location' is required. If 'source' is not /obj/machinery/deployable then 'undeploying' should be the item to be undeployed from the machine.
/datum/element/deployable_item/proc/finish_undeploy(datum/source, mob/user)
	var/obj/machinery/deployable/deployed_machine = source //The machinethat is undeploying should be the the one sending the Signal
	var/obj/item/attached_item  = deployed_machine.internal_item //Item the machine is undeploying

	if(!user)
		CRASH("[source] has sent the signal COMSIG_ITEM_UNDEPLOY to [attached_item] without the arg 'user'")
	if(!ishuman(user))
		return
	var/obj/machinery/deployable/mounted/sentry/sentry
	if(istype(deployed_machine, /obj/machinery/deployable/mounted/sentry))
		sentry = deployed_machine
	sentry?.set_on(FALSE)
	user.balloon_alert(user, "You start disassembling [attached_item]")
	if(!do_after(user, deploy_time, TRUE, deployed_machine, BUSY_ICON_BUILD))
		sentry?.set_on(TRUE)
		return

	DISABLE_BITFIELD(attached_item.flags_item, IS_DEPLOYED)

	user.unset_interaction()
	user.put_in_hands(attached_item)

	UnregisterSignal(deployed_machine, COMSIG_CLICK_CTRL)

	attached_item.max_integrity = deployed_machine.max_integrity
	attached_item.obj_integrity = deployed_machine.obj_integrity

	deployed_machine.internal_item = null

	QDEL_NULL(deployed_machine)
	attached_item.update_icon_state()
	RegisterSignal(attached_item, COMSIG_CLICK_CTRL, .proc/deploy)

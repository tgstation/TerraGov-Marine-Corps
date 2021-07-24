/datum/element/deployable_item
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	///Time it takes for the parent to be deployed/undeployed
	var/deploy_time = 0
	///Typath that the item deploys into. Can be anything but an item so far. The preffered type is /obj/machinery/deployable since it was built for this.
	var/obj/deploy_type

/datum/element/deployable_item/Attach(datum/target, _deploy_type, _deploy_time)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	deploy_type = _deploy_type
	deploy_time = _deploy_time

	var/obj/item/attached_item = target
	if(CHECK_BITFIELD(attached_item.flags_item, DEPLOY_ON_INITIALIZE))
		finish_deploy(attached_item, null, attached_item.loc, attached_item.dir)
		return

	RegisterSignal(attached_item, COMSIG_ITEM_UNIQUE_ACTION, .proc/deploy)

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
			to_chat(user, "<span class='warning'>There is insufficient room to deploy [attached_item]!</span>")
			return
		new_direction = user.dir
		to_chat(user, "<span class='notice'>You start deploying the [attached_item].</span>")
		if(!do_after(user, deploy_time, TRUE, attached_item, BUSY_ICON_BUILD))
			return

		user.temporarilyRemoveItemFromInventory(attached_item)

		attached_item.UnregisterSignal(user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDRAG, COMSIG_KB_RAILATTACHMENT, COMSIG_KB_UNDERRAILATTACHMENT, COMSIG_KB_UNLOADGUN, COMSIG_KB_FIREMODE)) //This unregisters Signals related to guns, its for safety

	else
		deploy_location = location
		new_direction = direction

	deployed_machine = new deploy_type(deploy_location, attached_item) //Creates new structure or machine at 'deploy' location and passes on 'attached_item'
	deployed_machine.setDir(new_direction)

	deployed_machine.max_integrity = attached_item.max_integrity //Syncs new machine or structure integrity with that of the item.
	deployed_machine.obj_integrity = attached_item.obj_integrity

	deployed_machine.update_icon_state()

	attached_item.forceMove(deployed_machine) //Moves the Item into the machine or structure

	ENABLE_BITFIELD(attached_item.flags_item, IS_DEPLOYED)

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
	to_chat(user, "<span class='notice'>You start disassembling the [attached_item]</span>")
	if(!do_after(user, deploy_time, TRUE, deployed_machine, BUSY_ICON_BUILD))
		return
	user.unset_interaction()
	user.put_in_hands(attached_item)

	DISABLE_BITFIELD(attached_item.flags_item, IS_DEPLOYED)
	UnregisterSignal(deployed_machine, COMSIG_ITEM_UNIQUE_ACTION)

	attached_item.max_integrity = deployed_machine.max_integrity
	attached_item.obj_integrity = deployed_machine.obj_integrity

	deployed_machine.internal_item = null

	QDEL_NULL(deployed_machine)
	attached_item.update_icon_state()

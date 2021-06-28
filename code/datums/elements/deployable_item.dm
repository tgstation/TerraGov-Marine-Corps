/datum/element/deployable_item
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 3

	///Time it takes for the parent to be deployed/undeployed
	var/deploy_time = 0
	///Typath that the item deploys into. Can be anything but an item so far. The preffered type is /obj/machinery/deployable since it was built for this.
	var/obj/deploy_type

/datum/element/deployable_item/Attach(datum/target, _deploy_type, _deploy_time)
	. = ..()
	if(!isitem(target))
		CRASH("[src] was attempted to be attached to [target] of type [target.type], [target] should be a /obj/item in order for this element to function with it.")
	deploy_type = _deploy_type
	deploy_time = _deploy_time

	RegisterSignal(target, COMSIG_ITEM_DEPLOY, .proc/deploy)

///Wrapper for proc/finish_deploy
/datum/element/deployable_item/proc/deploy(datum/source, mob/user, location, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/finish_deploy, source, user, location, direction)

///Handles the conversion of item into machine. Source is the Item to be deployed, user is who is deploying. If !null then 'location' and 'direction' are required for deployment.
/datum/element/deployable_item/proc/finish_deploy(datum/source, mob/user, location, direction)
	var/obj/item/attached_item = source
	var/obj/deployed_machine
	var/deploy_location
	var/new_direction
	if(user) //If there is a 'mob/user' the location and direction of the deploying object will be based off of the user.
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
		if(!location || !direction) //If there is no user, both 'location' and 'direction' are required for deploying the object.
			CRASH("/datum/component/deployable_item/deploy has been called from [source] without a user and therefore is missing the required vars of either 'location' or 'direction'")
		
		new_direction = direction

	deployed_machine = new deploy_type(deploy_location, attached_item) //Creates new structure or machine at 'deploy' location and passes on 'attached_item'
	deployed_machine.setDir(new_direction)

	deployed_machine.max_integrity = attached_item.max_integrity //Syncs new machine or structure integrity with that of the item.
	deployed_machine.obj_integrity = attached_item.obj_integrity

	attached_item.forceMove(deployed_machine) //Moves the Item into the machine or structure

	if(istype(deployed_machine, /obj/machinery/deployable)) //If it is a /obj/machinery/deployable, it calls the extra proc on_deploy()
		var/obj/machinery/deployable/_deployed_machine = deployed_machine
		_deployed_machine.on_deploy()

	ENABLE_BITFIELD(attached_item.flags_item, IS_DEPLOYED)

	RegisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY, .proc/undeploy)

///Wrapper for proc/finish_undeploy
/datum/element/deployable_item/proc/undeploy(datum/source, mob/user, location, obj/item/undeploying)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/finish_undeploy, source, user, location, undeploying)

//Handles the conversion of Machine into Item. 'source' should be the Machine. User is the one undeploying. It can be undeployed without a user, if so, the var 'location' is required. If 'source' is not /obj/machinery/deployable then 'undeploying' should be the item to be undeployed from the machine.
/datum/element/deployable_item/proc/finish_undeploy(datum/source, mob/user, location, undeploying)
	var/obj/deployed_machine = source //The machine/structure that is undeploying should be the the one sending the Signal
	var/obj/item/attached_item //Item the machine/structure is undeploying
	if(istype(deployed_machine, /obj/machinery/deployable)) //If the machine/structure is of type, '/obj/machinery/deployable' then it already has a saved var of the deploying/undeploying item. If it isn't the source should send along the undeploying item
		var/obj/machinery/deployable/_deployed_machine
		attached_item = _deployed_machine.internal_item
	else if(!undeploying)
		CRASH("[src] has called proc/undeploy from [source]. [source] is not of the type '/obj/machinery/deployable' and the argument 'undeploying' is null. Therefore proc/undeploy cannot determin what is undeploying.")

	else
		attached_item = undeploying

	if(user)
		if(!ishuman(user))
			return
		to_chat(user, "<span class = 'notice'>You start disassembling the [attached_item]</span>")
		if(!do_after(user, deploy_time, TRUE, deployed_machine, BUSY_ICON_BUILD))
			return
		user.unset_interaction()
		user.put_in_hands(attached_item)
	else
		if(!location)
			CRASH("/datum/element/deployable_item/proc/undeploy has been called from [source] without a user and therefore is missing the required var of 'location'")

		attached_item.forceMove(location)
	DISABLE_BITFIELD(attached_item.flags_item, IS_DEPLOYED)
	UnregisterSignal(deployed_machine, COMSIG_ITEM_UNDEPLOY)

	attached_item.max_integrity = deployed_machine.max_integrity
	attached_item.obj_integrity = deployed_machine.obj_integrity

	if(istype(deployed_machine, /obj/machinery/deployable))
		var/obj/machinery/deployable/_deployed_machine = deployed_machine
		_deployed_machine.on_undeploy()
	qdel(deployed_machine)
	attached_item.update_icon_state()




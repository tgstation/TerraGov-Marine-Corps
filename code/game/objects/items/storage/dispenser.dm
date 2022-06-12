
/obj/machinery/deployable/dispenser
	name = "TX-9000 Provisions Dispenser"
	desc = "The TX-9000 also known as \"Dispenser\" is a machine capable of holding a big amount of items on it, while also healing nearby humans. Your allies will often ask you to lay down one of those."
	///list of human mobs we're currently affecting in our area.
	var/list/mob/living/carbon/human/affecting_list

/obj/machinery/deployable/dispenser/Initialize(mapload, _internal_item, deployer)
	. = ..()
	INVOKE_ASYNC(src, .proc/afterinitialize)

/obj/machinery/deployable/dispenser/proc/afterinitialize()
	setDir(REVERSE_DIR(dir))
	flick("dispenser_deploy", src)
	addtimer(CALLBACK(.proc/deploy), 4.2 SECONDS)

/obj/machinery/deployable/dispenser/proc/deploy()
	affecting_list = list()
	for(var/mob/living/carbon/human/human in view(2, src))
		if(!(human.species.species_flags & ROBOTIC_LIMBS)) // can only affect robots
			continue
		RegisterSignal(human, COMSIG_PARENT_QDELETING, .proc/on_affecting_qdel)
		affecting_list[human] = beam(human, "blood_light")
		human.playsound_local(get_turf(src), 'sound/machines/dispenser/dispenser_heal.ogg', 50)
	for(var/turf/turfs AS in RANGE_TURFS(2, src))
		RegisterSignal(turfs, COMSIG_ATOM_ENTERED, .proc/entered_tiles)
	START_PROCESSING(SSobj, src)

///cleans human from affecting_list when it gets qdeletted
/obj/item/storage/backpack/dispenser/proc/on_affecting_qdel(datum/source)
	SIGNAL_HANDLER
	affecting_list -= source

/obj/item/storage/backpack/dispenser
	name = "TX-9000 Provisions Dispenser"
	desc = "The TX-9000 also known as \"Dispenser\" is a machine capable of holding a big amount of items on it, while also healing nearby humans. Your allies will often ask you to lay down one of those."
	icon = 'icons/obj/items/storage/storage_48.dmi'
	icon_state = "dispenser"
	flags_equip_slot = ITEM_SLOT_BACK
	max_w_class = 6
	max_storage_space = 63


/obj/item/storage/backpack/dispenser/open(mob/user)
	if(loc == user)
		return FALSE
	return ..()

/obj/item/storage/backpack/dispenser/attack_hand(mob/living/user)
	if(!CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		return ..()
	open(user)

/obj/item/storage/backpack/dispenser/MouseDrop(obj/over_object)
	if(!CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		return ..()
	if(over_object == usr && ishuman(over_object))
		open(over_object)

/obj/item/storage/backpack/dispenser/attack_self(mob/user)
	if(!ishuman(user) || CHECK_BITFIELD(flags_item, NODROP))
		return ..()
	var/deploy_location = get_step(user, user.dir)
	if(check_blocked_turf(deploy_location))
		user.balloon_alert(user, "There is insufficient room to deploy [src]!")
		return
	if(user.do_actions)
		user.balloon_alert(user, "You are already doing something!")
		return
	user.balloon_alert(user, "You start deploying...")

	user.temporarilyRemoveItemFromInventory(src)

	forceMove(deploy_location)
	density = TRUE
	anchored = TRUE
	dir = REVERSE_DIR(user.dir)
	icon_state = "dispenser_deployed"
	balloon_alert_to_viewers("Deploying...")
	flick("dispenser_deploy", src)
	ENABLE_BITFIELD(flags_item, IS_DEPLOYING)

	addtimer(CALLBACK(src, .proc/deploy), 4.2 SECONDS)



/obj/item/storage/backpack/dispenser/CtrlClick(mob/user)
	if(!CHECK_BITFIELD(flags_item, IS_DEPLOYED) || CHECK_BITFIELD(flags_item, IS_DEPLOYING))
		return ..()
	if(!can_interact(user))
		return
	balloon_alert_to_viewers("Undeploying...")

	icon_state = "dispenser"
	flick("dispenser_undeploy", src)
	ENABLE_BITFIELD(flags_item, IS_DEPLOYING)
	for(var/turf/turfs AS in RANGE_TURFS(2, src))
		UnregisterSignal(turfs, COMSIG_ATOM_ENTERED)
	for(var/mob/living/carbon/human/affecting AS in affecting_list)
		qdel(affecting_list[affecting])
		UnregisterSignal(affecting, COMSIG_PARENT_QDELETING)
	affecting_list = null
	STOP_PROCESSING(SSobj, src)
	addtimer(CALLBACK(src, .proc/undeploy), 4.2 SECONDS)

//finishes undeploying the dispenser
/obj/item/storage/backpack/dispenser/proc/undeploy()
	if(!CHECK_BITFIELD(flags_item, IS_DEPLOYING))
		return
	density = FALSE
	anchored = FALSE
	DISABLE_BITFIELD(flags_item, IS_DEPLOYED)
	DISABLE_BITFIELD(flags_item, IS_DEPLOYING)

/obj/item/storage/backpack/dispenser/process()
	for(var/mob/living/carbon/human/affecting AS in affecting_list)
		if(!line_of_sight(src, affecting, 2))
			qdel(affecting_list[affecting])
			affecting_list -= affecting
			UnregisterSignal(affecting, COMSIG_PARENT_QDELETING)
			continue
		affecting.heal_overall_damage(1, 1, TRUE)

///runs when something moves into a tile nearby us, if its a robotic human and is in line of sight, add it to affecting_list
/obj/item/storage/backpack/dispenser/proc/entered_tiles(datum/source, mob/living/carbon/human/entering)
	if(!ishuman(entering) || !(entering.species.species_flags & ROBOTIC_LIMBS)) // can only affect robots
		return
	if(entering in affecting_list)
		return
	if(!line_of_sight(src, entering))
		return

	RegisterSignal(entering, COMSIG_PARENT_QDELETING, .proc/on_affecting_qdel)
	entering.playsound_local(get_turf(src), 'sound/machines/dispenser/dispenser_heal.ogg', 50)
	affecting_list[entering] = beam(entering, "blood_light")


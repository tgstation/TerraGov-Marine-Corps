//drones that can be deployed and undeployed
/obj/item/deployable_vehicle
	name = "\improper UV-L Iguana"
	desc = "An Iguana B-type drone, ready to be deployed."
	icon = 'icons/obj/unmanned_vehicles.dmi'
	icon_state = "light_uv_folded"
	w_class = WEIGHT_CLASS_NORMAL
	slowdown = 0.3
	flags_item = IS_DEPLOYABLE
	///The vehicle this deploys into
	var/deployable_item = /obj/vehicle/unmanned/deployable
	///The equipped turret
	var/stored_turret_type
	///Ammo remaining in stored turret
	var/stored_ammo
	///Time to deploy
	var/deploy_time = 1 SECONDS
	///Time to undeploy
	var/undeploy_time = 1 SECONDS

/obj/item/deployable_vehicle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, deploy_time, undeploy_time)

/obj/vehicle/unmanned/deployable
	name = "UV-L Iguana"
	desc = "A small remote-controllable vehicle, usually owned by the TGMC and other major armies. This one is configured to be foldable for portability."
	///Whether this item can be deployed or undeployed
	var/flags_item = IS_DEPLOYABLE
	///What it deploys into. typecast version of internal_item
	var/obj/item/deployable_vehicle/internal_item

/obj/vehicle/unmanned/deployable/Initialize(mapload, _internal_item, deployer)
	if(!internal_item && !_internal_item)
		return INITIALIZE_HINT_QDEL
	internal_item = _internal_item
	spawn_equipped_type = internal_item.stored_turret_type
	. = ..()
	current_rounds = internal_item.stored_ammo

/obj/vehicle/unmanned/deployable/get_internal_item()
	return internal_item

/obj/vehicle/unmanned/deployable/clear_internal_item()
	internal_item = null

/obj/vehicle/unmanned/deployable/Destroy()
	if(internal_item)
		QDEL_NULL(internal_item)
	return ..()

/obj/vehicle/unmanned/deployable/MouseDrop(over_object, src_location, over_location)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(over_object != user || !in_range(src, user) || user.incapacitated() || user.lying_angle)
		return
	disassemble(user)

///Dissassembles the device
/obj/vehicle/unmanned/deployable/proc/disassemble(mob/user)
	if(CHECK_BITFIELD(internal_item.flags_item, DEPLOYED_NO_PICKUP))
		balloon_alert(user, "cannot be disassembled")
		return
	if(turret_path)
		internal_item.stored_turret_type = turret_path
		internal_item.stored_ammo = current_rounds
	SEND_SIGNAL(src, COMSIG_ITEM_UNDEPLOY, user)

//drones that can be deployed and undeployed
/obj/item/deployable_vehicle
	name = "\improper UV-L Iguana"
	desc = "An Iguana B-type drone, ready to be deployed."
	icon = 'icons/obj/unmanned_vehicles.dmi'
	icon_state = "light_uv_folded"
	w_class = WEIGHT_CLASS_NORMAL
	slowdown = 0.3
	item_flags = IS_DEPLOYABLE
	max_integrity = IGUANA_MAX_INTEGRITY
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
	var/item_flags = IS_DEPLOYABLE
	///What it deploys into. typecast version of internal_item
	var/obj/item/deployable_vehicle/internal_item

/obj/vehicle/unmanned/deployable/Initialize(mapload, _internal_item, mob/deployer)
	if(!internal_item && !_internal_item)
		return INITIALIZE_HINT_QDEL
	internal_item = _internal_item
	spawn_equipped_type = internal_item.stored_turret_type
	if(ishuman(deployer))
		var/mob/living/carbon/human/human_deployer = deployer
		iff_signal = human_deployer?.wear_id?.iff_signal
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

/obj/vehicle/unmanned/deployable/disassemble(mob/user)
	var/obj/item/deployable_vehicle/current_internal_item = get_internal_item()
	. = ..()
	if(!.)
		return
	if(turret_path)
		current_internal_item?.stored_turret_type = turret_path
		current_internal_item?.stored_ammo = current_rounds

/obj/item/deployable_vehicle/tiny
	name = "\improper UV-T Skink"
	desc = "A Skink B-type drone, ready to be deployed."
	icon_state = "tiny_uv_folded"
	max_integrity = 50
	w_class = WEIGHT_CLASS_SMALL
	deployable_item = /obj/vehicle/unmanned/deployable/tiny

/obj/vehicle/unmanned/deployable/tiny
	name = "UV-T Skink"
	icon_state = "tiny_uv"
	layer = BELOW_TABLE_LAYER
	move_delay = 1.5
	hud_possible = list(MACHINE_HEALTH_HUD)
	atom_flags = NONE
	soft_armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 25, BIO = 100, FIRE = 25, ACID = 25)
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER|PASS_MOB
	pass_flags = PASS_LOW_STRUCTURE|PASS_GRILLE|PASS_MOB
	turret_pattern = NO_PATTERN
	unmanned_flags = GIVE_NIGHT_VISION
	trigger_gargoyle = FALSE
	allow_explosives = FALSE

/obj/structure/closet/crate/uvt_crate
	name = "\improper UV-T Skink Crate"
	desc = "A crate containing a scouting drone and a controller."
	icon = 'icons/obj/structures/crates.dmi'
	icon_state = "closed_weapons"
	icon_opened = "open_weapons"
	icon_closed = "closed_weapons"

/obj/structure/closet/crate/uvt_crate/PopulateContents()
	new /obj/item/deployable_vehicle/tiny(src)
	new /obj/item/unmanned_vehicle_remote(src)

/obj/vehicle/unmanned/deployable/tiny/on_remote_toggle(datum/source, is_on, mob/user)
	. = ..()
	if(is_on)
		playsound(src, 'sound/machines/chime.ogg', 30)
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30)

/obj/item/deployable_vehicle/tiny/martian
	name = "Seraphim's Eye Probe"
	desc = "A ready to deploy probe, with the antennae folded in."
	icon_state = "martian_uv_folded"
	max_integrity = 100
	deployable_item = /obj/vehicle/unmanned/deployable/tiny/martian

/obj/vehicle/unmanned/deployable/tiny/martian
	name = "Seraphim's Eye"
	desc = "A fast martian probe, unarmed but perfect for scouting. Capable of cloaking when not in motion."
	icon_state = "martian_uv"
	layer = VEHICLE_LAYER
	allow_pass_flags = HOVERING|PASSABLE|PASS_WALKOVER
	pass_flags = HOVERING|PASS_GRILLE
	faction = FACTION_SOM
	iff_signal = SOM_IFF
	///Whether the probe is cloaked or not
	var/cloaked = FALSE
	///Time it takes to activate cloak
	var/cloak_time = 2 SECONDS
	///Last world.time the probe moved and tried to uncloak.
	var/last_uncloak_move = 0
	///Time since the last uncloak move, used to determine when to cloak.
	var/cloak_wait_elapsed = 0

/obj/vehicle/unmanned/deployable/tiny/martian/Initialize(mapload, _internal_item, mob/deployer)
	. = ..()
	add_filter("shadow", 2, drop_shadow_filter(0, -8, 1))
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

///Cloaks the probe and stops processing until it moves again.
/obj/vehicle/unmanned/deployable/tiny/martian/proc/begin_cloaking()
	cloaked = TRUE
	playsound(src, 'sound/effects/pred_cloakon.ogg', 10, TRUE)
	become_warped_invisible(30)
	STOP_PROCESSING(SSobj, src)

/obj/vehicle/unmanned/deployable/tiny/martian/process()
	cloak_wait_elapsed = world.time - last_uncloak_move
	if(cloak_wait_elapsed < cloak_time)
		return
	begin_cloaking()

///Moving will disable the cloak and reset the cloak timer.
/obj/vehicle/unmanned/deployable/tiny/martian/proc/on_move()
	SIGNAL_HANDLER
	if(cloaked)
		cloaked = FALSE
		stop_warped_invisible()
		playsound(src, 'sound/effects/pred_cloakoff.ogg', 30, TRUE)
	last_uncloak_move = world.time
	cloak_wait_elapsed = 0
	START_PROCESSING(SSobj, src)

/obj/vehicle/unmanned/deployable/tiny/martian/disassemble(mob/user)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	return ..()

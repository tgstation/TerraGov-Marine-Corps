
#define DROPSHIP_WEAPON "dropship_weapon"
#define DROPSHIP_CREW_WEAPON "dropship_crew_weapon"
#define DROPSHIP_ELECTRONICS "dropship_electronics"
#define DROPSHIP_FUEL_EQP "dropship_fuel_equipment"
#define DROPSHIP_COMPUTER "dropship_computer"


//the bases onto which you attach dropship equipments.

/obj/effect/attach_point
	name = "equipment attach point"
	desc = "A place where heavy equipment can be installed with a powerloader."
	anchored = TRUE
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "equip_base"
	layer = ABOVE_OBJ_LAYER
	dir = NORTH
	var/base_category //what kind of equipment this base accepts.
	var/ship_tag //used to associate the base to a dropship.
	/// offset in pixels when equipment is attached
	var/equipment_offset_x = 0
	///y offset in pixels when attached
	var/equipment_offset_y = 0
	///The actual equipment installed on the attach point
	var/obj/structure/dropship_equipment/installed_equipment

/obj/effect/attach_point/Destroy()
	QDEL_NULL(installed_equipment)
	return ..()

/obj/effect/attach_point/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/powerloader_clamp))
		return
	var/obj/item/powerloader_clamp/clamp = I
	if(!istype(clamp.loaded, /obj/structure/dropship_equipment))
		return TRUE

	var/obj/structure/dropship_equipment/loaded_equipment = clamp.loaded
	if(loaded_equipment.equip_category != base_category)
		to_chat(user, span_warning("[loaded_equipment] doesn't fit on [src]."))
		return TRUE
	if(installed_equipment)
		return TRUE
	playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
	if(!do_after(user, 7 SECONDS, FALSE, src))
		return TRUE
	if(installed_equipment || clamp.loaded != loaded_equipment)
		return TRUE
	to_chat(user, span_notice("You install [loaded_equipment] on [src]."))
	loaded_equipment.forceMove(loc)
	clamp.loaded = null
	playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
	clamp.update_icon()
	installed_equipment = loaded_equipment
	loaded_equipment.ship_base = src

	for(var/obj/docking_port/mobile/marine_dropship/S in SSshuttle.dropships)
		if(S.id == ship_tag)
			loaded_equipment.linked_shuttle = S
			S.equipments += loaded_equipment
			break

	loaded_equipment.pixel_x = equipment_offset_x
	loaded_equipment.pixel_y = equipment_offset_y

	loaded_equipment.update_equipment()
	return TRUE


/obj/effect/attach_point/weapon
	name = "weapon system attach point"
	icon_state = "equip_base_front"
	base_category = DROPSHIP_WEAPON

/obj/effect/attach_point/weapon/dropship1
	ship_tag = SHUTTLE_ALAMO

/obj/effect/attach_point/weapon/dropship2
	ship_tag = SHUTTLE_NORMANDY

/obj/effect/attach_point/weapon/dropship3
	ship_tag = SHUTTLE_TRIUMPH

/obj/effect/attach_point/weapon/cas
	ship_tag = SHUTTLE_CAS_DOCK
	icon = 'icons/Marine/casship.dmi'
	icon_state = "15"

/obj/effect/attach_point/weapon/minidropship
	ship_tag = SHUTTLE_TADPOLE
	pixel_y = 32

/obj/effect/attach_point/crew_weapon
	name = "rear attach point"
	base_category = DROPSHIP_CREW_WEAPON

/obj/effect/attach_point/crew_weapon/dropship1
	ship_tag = SHUTTLE_ALAMO

/obj/effect/attach_point/crew_weapon/dropship2
	ship_tag = SHUTTLE_NORMANDY

/obj/effect/attach_point/crew_weapon/minidropship
	ship_tag = SHUTTLE_TADPOLE

/obj/effect/attach_point/crew_weapon/dropship1
	ship_tag = SHUTTLE_ALAMO

/obj/effect/attach_point/crew_weapon/dropship3
	ship_tag = SHUTTLE_ALAMO

/obj/effect/attach_point/electronics
	name = "electronic system attach point"
	base_category = DROPSHIP_ELECTRONICS
	icon_state = "equip_base_front"

/obj/effect/attach_point/electronics/dropship1
	ship_tag = SHUTTLE_ALAMO

/obj/effect/attach_point/electronics/dropship2
	ship_tag = SHUTTLE_NORMANDY

/obj/effect/attach_point/electronics/dropship3
	ship_tag = SHUTTLE_TRIUMPH


/obj/effect/attach_point/fuel
	name = "engine system attach point"
	icon = 'icons/Marine/mainship_props64.dmi'
	icon_state = "fuel_base"
	base_category = DROPSHIP_FUEL_EQP

/obj/effect/attach_point/fuel/dropship1
	ship_tag = SHUTTLE_ALAMO

/obj/effect/attach_point/fuel/dropship2
	ship_tag = SHUTTLE_NORMANDY

/obj/effect/attach_point/fuel/dropship3
	ship_tag = SHUTTLE_TRIUMPH


/obj/effect/attach_point/computer
	base_category = DROPSHIP_COMPUTER

/obj/effect/attach_point/computer/dropship1
	ship_tag = SHUTTLE_ALAMO

/obj/effect/attach_point/computer/dropship2
	ship_tag = SHUTTLE_NORMANDY



//////////////////////////////////////////////////////////////////////////////////////////////////////////////::

//Actual dropship equipments

/obj/structure/dropship_equipment
	density = TRUE
	anchored = TRUE
	icon = 'icons/Marine/mainship_props.dmi'
	climbable = TRUE
	layer = ABOVE_OBJ_LAYER //so they always appear above attach points when installed
	resistance_flags = XENO_DAMAGEABLE
	coverage = 20
	///on what kind of base this can be installed.
	var/equip_category
	///the ship base the equipment is currently installed on.
	var/obj/effect/attach_point/ship_base
	///whether it uses ammo
	var/dropship_equipment_flags = NONE
	///the ammo currently equipped.
	var/obj/structure/ship_ammo/ammo_equipped
	///whether the equipment is a weapon usable for dropship bombardment.
	///the weapons console of the dropship we're installed on. Not used by CAS planes
	var/obj/machinery/computer/dropship_weapons/linked_console
	///whether they get a button when shown on the shuttle console's equipment list.
	var/obj/docking_port/mobile/marine_dropship/linked_shuttle
	///used by the dropship console code when this equipment is selected
	var/screen_mode = 0
	///how many points it costs to build this with the fabricator, set to 0 if unbuildable.
	var/point_cost = 0
	///what kind of ammo this uses if any
	var/ammo_type_used

/obj/structure/dropship_equipment/Destroy()
	QDEL_NULL(ammo_equipped)
	if(linked_shuttle)
		linked_shuttle.equipments -= src
		linked_shuttle = null
	if(ship_base)
		ship_base.installed_equipment = null
		ship_base = null
	if(linked_console)
		if(linked_console?.selected_equipment == src)
			linked_console.selected_equipment = null
		linked_console = null
	ammo_type_used = null
	return ..()

/obj/structure/dropship_equipment/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/powerloader_clamp))
		return
	var/obj/item/powerloader_clamp/clamp = I
	if(clamp.loaded)
		if((!(dropship_equipment_flags & IS_NOT_REMOVABLE) && !ship_base) || !(dropship_equipment_flags & USES_AMMO) || ammo_equipped || !istype(clamp.loaded, /obj/structure/ship_ammo))
			return FALSE
		var/obj/structure/ship_ammo/clamp_ammo = clamp.loaded
		if(istype(type, clamp_ammo.equipment_type) || clamp_ammo.ammo_type != ammo_type_used) //Incompatible ammo
			to_chat(user, span_warning("[clamp_ammo] doesn't fit in [src]."))
			return FALSE
		playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
		if(!do_after(user, 30, FALSE, src, BUSY_ICON_BUILD))
			return FALSE
		if(ammo_equipped || clamp.loaded != clamp_ammo || !LAZYLEN(clamp.linked_powerloader?.buckled_mobs) || clamp.linked_powerloader.buckled_mobs[1] != user)
			return FALSE
		clamp_ammo.forceMove(src)
		clamp.loaded = null
		playsound(src, 'sound/machines/hydraulics_2.ogg', 40, 1)
		clamp.update_icon()
		to_chat(user, span_notice("You load [clamp_ammo] into [src]."))
		ammo_equipped = clamp_ammo
		update_equipment()
		return TRUE //refilled dropship ammo
	else if((dropship_equipment_flags & USES_AMMO) && ammo_equipped)
		playsound(src, 'sound/machines/hydraulics_2.ogg', 40, 1)
		if(!do_after(user, 30, FALSE, src, BUSY_ICON_BUILD))
			return FALSE
		if(!ammo_equipped || !LAZYLEN(clamp.linked_powerloader?.buckled_mobs) || clamp.linked_powerloader.buckled_mobs[1] != user)
			return FALSE
		playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
		if(!ammo_equipped.ammo_count)
			ammo_equipped.loc = null
			to_chat(user, span_notice("You've discarded the empty [ammo_equipped.name] in [src]."))
			qdel(ammo_equipped)
		else
			ammo_equipped.forceMove(clamp.linked_powerloader)
			clamp.loaded = ammo_equipped
			clamp.update_icon()
			to_chat(user, span_notice("You've removed [ammo_equipped] from [src] and loaded it into [clamp]."))
		ammo_equipped = null
		update_icon()
		return TRUE //emptied or removed dropship ammo
	else if(dropship_equipment_flags & IS_NOT_REMOVABLE)
		to_chat(user, span_notice("You cannot remove [src]!"))
		return FALSE
	else if(!current_acid)
		playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
		var/duration_time = ship_base ? 70 : 10 //uninstalling equipment takes more time
		if(!do_after(user, duration_time, FALSE, src, BUSY_ICON_BUILD))
			return FALSE
		if(clamp.loaded || !LAZYLEN(clamp.linked_powerloader?.buckled_mobs) || clamp.linked_powerloader.buckled_mobs[1] != user)
			return FALSE
		forceMove(clamp.linked_powerloader)
		clamp.loaded = src
		SEND_SIGNAL(src, COMSIG_DROPSHIP_EQUIPMENT_UNEQUIPPED)
		playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
		clamp.update_icon()
		to_chat(user, span_notice("You've [ship_base ? "uninstalled" : "grabbed"] [clamp.loaded] with [clamp]."))
		if(ship_base)
			ship_base.installed_equipment = null
			ship_base = null
			if(linked_shuttle)
				linked_shuttle.equipments -= src
				linked_shuttle = null
				if(linked_console?.selected_equipment == src)
					linked_console.selected_equipment = null
		update_equipment()
		return TRUE //removed or uninstalled equipment
	to_chat(user, span_notice("You cannot touch [src] with the [clamp] due to the acid on [src]."))
	return TRUE

/obj/structure/dropship_equipment/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	on_launch()

/obj/structure/dropship_equipment/proc/update_equipment()
	return

///things to do when the shuttle this equipment is attached to is about to launch.
/obj/structure/dropship_equipment/proc/on_launch()
	return

///things to do when the shuttle this equipment is attached to land.
/obj/structure/dropship_equipment/proc/on_arrival()
	return

/obj/structure/dropship_equipment/proc/equipment_interact(mob/user)
	if(dropship_equipment_flags & IS_INTERACTABLE)
		if(linked_console.selected_equipment)
			return
		linked_console.selected_equipment = src
		to_chat(user, span_notice("You select [src]."))

//////////////////////////////////// flare launcher //////////////////////////////////////
/obj/structure/dropship_equipment/flare_launcher
	equip_category = DROPSHIP_WEAPON
	name = "flare launcher system"
	desc = "A system that deploys flares stronger than the inputted flares. Fits on the weapon attach points of dropships. You need a powerloader to lift it."
	icon_state = "flare_system"
	dropship_equipment_flags = IS_INTERACTABLE
	point_cost = 150
	///cooldown for deployment
	COOLDOWN_DECLARE(deploy_cooldown)
	///amount of loaded flares
	var/stored_amount = 4
	///max capacity of flares in system
	var/max_amount = 4

/obj/structure/dropship_equipment/flare_launcher/equipment_interact(mob/user)
	if(!COOLDOWN_CHECK(src, deploy_cooldown)) //prevents spamming deployment
		user.balloon_alert(user, "[src] is busy.")
		return
	if(stored_amount <= 0) //check for inserted flares
		user.balloon_alert(user, "No flares remaining.")
		return
	deploy_flare()
	user.balloon_alert(user, "You deploy [src], remaining flares [stored_amount].")
	COOLDOWN_START(src, deploy_cooldown, 5 SECONDS)

/obj/structure/dropship_equipment/flare_launcher/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/explosive/grenade/flare) && stored_amount < max_amount)
		stored_amount++
		user.balloon_alert(user, "You insert a flare, remaining flares [stored_amount].")
		qdel(I)

/obj/structure/dropship_equipment/flare_launcher/update_equipment()
	. = ..()
	if(ship_base)
		setDir(ship_base.dir)
	else
		setDir(initial(dir))
	update_icon()

/obj/structure/dropship_equipment/flare_launcher/update_icon_state()
	. = ..()
	if(ship_base)
		icon_state = "flare_system_installed"
	else
		icon_state = "flare_system"

///gets target and deploy the flare launcher
/obj/structure/dropship_equipment/flare_launcher/proc/deploy_flare()
	playsound(loc, 'sound/weapons/guns/fire/tank_smokelauncher.ogg', 40, 1)
	var/turf/target = get_ranged_target_turf(src, dir, 10)
	var/obj/item/explosive/grenade/flare/strongerflare/flare_to_launch = new(loc)
	flare_to_launch.turn_on()
	flare_to_launch.throw_at(target, 10, 2)
	stored_amount--

//////////////////////////////////// turret holders //////////////////////////////////////

/obj/structure/dropship_equipment/sentry_holder
	equip_category = DROPSHIP_WEAPON
	name = "sentry deployment system"
	desc = "A box that deploys a sentry turret. Fits on the weapon attach points of dropships. You need a powerloader to lift it."
	icon_state = "sentry_system"
	dropship_equipment_flags = IS_INTERACTABLE
	point_cost = 500
	var/deployment_cooldown
	var/obj/machinery/deployable/mounted/sentry/deployed_turret
	var/sentry_type = /obj/item/weapon/gun/sentry/big_sentry/dropship

/obj/structure/dropship_equipment/sentry_holder/Initialize()
	. = ..()
	if(!deployed_turret)
		var/obj/new_gun = new sentry_type(src)
		deployed_turret = new_gun.loc
		RegisterSignal(deployed_turret, COMSIG_OBJ_DECONSTRUCT, .proc/clean_refs)

///This cleans the deployed_turret ref when the sentry is destroyed.
/obj/structure/dropship_equipment/sentry_holder/proc/clean_refs(atom/source, disassembled)
	SIGNAL_HANDLER
	UnregisterSignal(deployed_turret, COMSIG_OBJ_DECONSTRUCT)
	deployed_turret = null
	dropship_equipment_flags &= ~IS_NOT_REMOVABLE

/obj/structure/dropship_equipment/sentry_holder/examine(mob/user)
	. = ..()
	if(!deployed_turret)
		. += "Its turret is missing."

/obj/structure/dropship_equipment/sentry_holder/on_launch()
	undeploy_sentry()

/obj/structure/dropship_equipment/sentry_holder/equipment_interact(mob/user)
	if(!deployed_turret)
		to_chat(user, span_warning("[src] is unresponsive."))
		return
	if(deployment_cooldown > world.time)
		to_chat(user, span_warning("[src] is busy."))
		return //prevents spamming deployment/undeployment
	if(deployed_turret.loc == src) //not deployed
		if(is_reserved_level(z))
			to_chat(user, span_warning("[src] can't deploy mid-flight."))
		else
			to_chat(user, span_notice("You deploy [src]."))
			deploy_sentry()
	else
		to_chat(user, span_notice("You retract [src]."))
		undeploy_sentry()


/obj/structure/dropship_equipment/sentry_holder/update_equipment()
	if(ship_base)
		setDir(ship_base.dir)
		icon_state = "sentry_system_installed"
		if(deployed_turret)
			deployed_turret.setDir(dir)
			if(linked_shuttle && deployed_turret.camera)
				if(linked_shuttle.id == SHUTTLE_ALAMO)
					deployed_turret.camera.network.Add("dropship1") //accessible via the dropship camera console
				else
					deployed_turret.camera.network.Add("dropship2")
			switch(dir)
				if(SOUTH)
					deployed_turret.pixel_y = 8
				if(NORTH)
					deployed_turret.pixel_y = -8
				if(EAST)
					deployed_turret.pixel_x = -8
				if(WEST)
					deployed_turret.pixel_x = 8
	else
		setDir(initial(dir))
		if(deployed_turret)
			if(deployed_turret.camera)
				if(deployed_turret.camera.network.Find("dropship1"))
					deployed_turret.camera.network.Remove("dropship1")
				else if(deployed_turret.camera.network.Find("dropship2"))
					deployed_turret.camera.network.Remove("dropship2")
			icon_state = "sentry_system"
			deployed_turret.pixel_y = 0
			deployed_turret.pixel_x = 0
			deployed_turret.loc = src
			deployed_turret.setDir(dir)
			deployed_turret.set_on(FALSE)
		else
			icon_state = "sentry_system_destroyed"

/obj/structure/dropship_equipment/sentry_holder/proc/deploy_sentry()
	if(!deployed_turret)
		return
	setDir(ship_base.dir)
	deployed_turret.setDir(dir)
	playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
	deployment_cooldown = world.time + 50
	deployed_turret.set_on(TRUE)
	deployed_turret.update_icon()
	deployed_turret.loc = get_step(src, dir)
	icon_state = "sentry_system_deployed"
	dropship_equipment_flags |= IS_NOT_REMOVABLE
	deployed_turret.update_minimap_icon()

/obj/structure/dropship_equipment/sentry_holder/proc/undeploy_sentry()
	if(!deployed_turret)
		return
	playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
	deployment_cooldown = world.time + 50
	SSminimaps.remove_marker(deployed_turret)
	deployed_turret.loc = src
	deployed_turret.set_on(FALSE)
	deployed_turret.update_icon()
	icon_state = "sentry_system_installed"
	dropship_equipment_flags &= ~IS_NOT_REMOVABLE

/obj/structure/dropship_equipment/sentry_holder/rebel
	sentry_type = /obj/item/weapon/gun/sentry/big_sentry/dropship/rebel


/obj/structure/dropship_equipment/mg_holder
	name = "machinegun deployment system"
	desc = "A box that deploys a modified M56D crewserved machine gun. Fits on the crewserved weapon attach points of dropships. You need a powerloader to lift it."
	equip_category = DROPSHIP_CREW_WEAPON
	icon_state = "mg_system"
	point_cost = 300
	///machine type for the internal gun and for checking if the gun is deployed
	var/obj/machinery/deployable/mounted/deployed_mg

/obj/structure/dropship_equipment/mg_holder/Initialize()
	. = ..()
	if(deployed_mg)
		return
	var/obj/item/weapon/gun/tl102/hsg_nest/new_gun = new(src)
	deployed_mg = new_gun.loc //new_gun.loc, since it deploys on new(), is located within the deployed_mg. Therefore new_gun.loc = deployed_mg.

/obj/structure/dropship_equipment/mg_holder/examine(mob/user)
	. = ..()
	if(!deployed_mg)
		. += "Its machine gun is missing."

/obj/structure/dropship_equipment/mg_holder/update_equipment()
	if(!deployed_mg)
		return
	if(ship_base)
		deployed_mg.loc = loc
	else
		deployed_mg.loc = src
	update_icon()

/obj/structure/dropship_equipment/mg_holder/update_icon_state()
	if(ship_base)
		icon_state = "mg_system_deployed"
	else
		icon_state = "mg_system"

/obj/structure/dropship_equipment/mg_holder/Destroy()
	if(deployed_mg)
		QDEL_NULL(deployed_mg)
	return ..()

/obj/structure/dropship_equipment/minigun_holder
	name = "minigun deployment system"
	desc = "A box that deploys a modified MG-2005 crewserved minigun. Fits on the crewserved weapon attach points of dropships. You need a powerloader to lift it."
	equip_category = DROPSHIP_CREW_WEAPON
	icon_state = "minigun_system"
	point_cost = 0 //this removes it from the fabricator
	///machine type for the internal gun and for checking if the gun is deployed
	var/obj/machinery/deployable/mounted/deployed_minigun

/obj/structure/dropship_equipment/minigun_holder/Initialize()
	. = ..()
	if(deployed_minigun)
		return
	var/obj/item/weapon/gun/minigun_nest/new_gun = new(src)
	deployed_minigun = new_gun.loc //new_gun.loc, since it deploys on new(), is located within the deployed_minigun. Therefore new_gun.loc = deployed_minigun.

/obj/structure/dropship_equipment/minigun_holder/examine(mob/user)
	. = ..()
	if(!deployed_minigun)
		. += "Its minigun is missing."

/obj/structure/dropship_equipment/minigun_holder/update_equipment()
	if(!deployed_minigun)
		return
	if(ship_base)
		deployed_minigun.loc = loc
	else
		deployed_minigun.loc = src
	update_icon()

/obj/structure/dropship_equipment/minigun_holder/update_icon_state()
	if(ship_base)
		icon_state = "mg_system_deployed"
	else
		icon_state = "minigun_system"

/obj/structure/dropship_equipment/minigun_holder/Destroy()
	if(deployed_minigun)
		QDEL_NULL(deployed_minigun)
	return ..()

/obj/structure/dropship_equipment/dualcannon_holder
	name = "dualcannon deployment system"
	desc = "A box that deploys a modified ATR-22 crewserved dualcannon. Fits on the crewserved weapon attach points of dropships. You need a powerloader to lift it."
	equip_category = DROPSHIP_CREW_WEAPON
	icon_state = "ac_system"
	point_cost = 0 //this removes it from the fabricator
	///machine type for the internal gun and for checking if the gun is deployed
	var/obj/machinery/deployable/mounted/deployed_dualcannon

/obj/structure/dropship_equipment/dualcannon_holder/Initialize()
	. = ..()
	if(deployed_dualcannon)
		return
	var/obj/item/weapon/gun/dual_cannon/new_gun = new(src)
	deployed_dualcannon = new_gun.loc //new_gun.loc, since it deploys on new(), is located within the deployed_dualcannon. Therefore new_gun.loc = deployed_dualcannon.

/obj/structure/dropship_equipment/dualcannon_holder/examine(mob/user)
	. = ..()
	if(!deployed_dualcannon)
		. += "Its dualcannon is missing."

/obj/structure/dropship_equipment/dualcannon_holder/update_equipment()
	if(!deployed_dualcannon)
		return
	if(ship_base)
		deployed_dualcannon.loc = loc
	else
		deployed_dualcannon.loc = src
	update_icon()

/obj/structure/dropship_equipment/dualcannon_holder/update_icon_state()
	if(ship_base)
		icon_state = "mg_system_deployed"
	else
		icon_state = "ac_system"

/obj/structure/dropship_equipment/dualcannon_holder/Destroy()
	if(deployed_dualcannon)
		QDEL_NULL(deployed_dualcannon)
	return ..()

/obj/structure/dropship_equipment/heavylaser_holder
	name = "heavy laser deployment system"
	desc = "A box that deploys a modified TE-9001 crewserved heavylaser. Fits on the crewserved weapon attach points of dropships. You need a powerloader to lift it."
	equip_category = DROPSHIP_CREW_WEAPON
	icon_state = "hl_system"
	point_cost = 0 //this removes it from the fabricator
	///machine type for the internal gun and for checking if the gun is deployed
	var/obj/machinery/deployable/mounted/deployed_heavylaser

/obj/structure/dropship_equipment/heavylaser_holder/Initialize()
	. = ..()
	if(deployed_heavylaser)
		return
	var/obj/item/weapon/gun/heavy_laser/new_gun = new(src)
	deployed_heavylaser = new_gun.loc //new_gun.loc, since it deploys on new(), is located within the deployed_heavylaser. Therefore new_gun.loc = deployed_heavylaser.

/obj/structure/dropship_equipment/heavylaser_holder/examine(mob/user)
	. = ..()
	if(!deployed_heavylaser)
		. += "Its heavy laser is missing."

/obj/structure/dropship_equipment/heavylaser_holder/update_equipment()
	if(!deployed_heavylaser)
		return
	if(ship_base)
		deployed_heavylaser.loc = loc
	else
		deployed_heavylaser.loc = src
	update_icon()

/obj/structure/dropship_equipment/heavylaser_holder/update_icon_state()
	if(ship_base)
		icon_state = "mg_system_deployed"
	else
		icon_state = "hl_system"

/obj/structure/dropship_equipment/heavylaser_holder/Destroy()
	if(deployed_heavylaser)
		QDEL_NULL(deployed_heavylaser)
	return ..()

/obj/structure/dropship_equipment/heavy_rr_holder
	name = "heavy recoilless rifle deployment system"
	desc = "A box that deploys a modified RR-15 crewserved recoilless rifle. Fits on the crewserved weapon attach points of dropships. You need a powerloader to lift it."
	equip_category = DROPSHIP_CREW_WEAPON
	icon_state = "rr_system"
	point_cost = 0 //this removes it from the fabricator
	///machine type for the internal gun and for checking if the gun is deployed
	var/obj/machinery/deployable/mounted/deployed_heavyrr

/obj/structure/dropship_equipment/heavy_rr_holder/Initialize()
	. = ..()
	if(deployed_heavyrr)
		return
	var/obj/item/weapon/gun/launcher/rocket/heavy_rr/new_gun = new(src)
	deployed_heavyrr = new_gun.loc //new_gun.loc, since it deploys on new(), is located within the deployed_heavyrr. Therefore new_gun.loc = deployed_heavyrr.

/obj/structure/dropship_equipment/heavy_rr_holder/examine(mob/user)
	. = ..()
	if(!deployed_heavyrr)
		. += "Its recoilless rifle is missing."

/obj/structure/dropship_equipment/heavy_rr_holder/update_equipment()
	if(!deployed_heavyrr)
		return
	if(ship_base)
		deployed_heavyrr.loc = loc
	else
		deployed_heavyrr.loc = src
	update_icon()

/obj/structure/dropship_equipment/heavy_rr_holder/update_icon_state()
	if(ship_base)
		icon_state = "mg_system_deployed"
	else
		icon_state = "rr_system"

/obj/structure/dropship_equipment/heavy_rr_holder/Destroy()
	if(deployed_heavyrr)
		QDEL_NULL(deployed_heavyrr)
	return ..()

/obj/structure/dropship_equipment/mortar_holder
	name = "mortar deployment system"
	desc = "A box that deploys a TA-55DB mortar. Fits on the crewserved weapon attach points of dropships. You need a powerloader to lift it."
	equip_category = DROPSHIP_CREW_WEAPON
	icon_state = "mortar_system"
	point_cost = 300
	///machine type for the internal gun and for checking if the gun is deployed
	var/obj/machinery/deployable/mortar/double/deployed_mortar

/obj/structure/dropship_equipment/mortar_holder/Initialize()
	. = ..()
	if(deployed_mortar)
		return
	var/obj/item/mortar_kit/double/new_gun = new(src)
	deployed_mortar = new_gun.loc //new_gun.loc, since it deploys on new(), is located within the deployed_mortar. Therefore new_gun.loc = deployed_mg.

/obj/structure/dropship_equipment/mortar_holder/examine(mob/user)
	. = ..()
	if(!deployed_mortar)
		. += "Its mortar is missing."

/obj/structure/dropship_equipment/mortar_holder/update_equipment()
	if(!deployed_mortar)
		return
	if(ship_base)
		deployed_mortar.loc = loc
	else
		deployed_mortar.loc = src
	update_icon()

/obj/structure/dropship_equipment/mortar_holder/update_icon_state()
	if(ship_base)
		icon_state = "mg_system_deployed"
	else
		icon_state = "mg_system"

/obj/structure/dropship_equipment/mortar_holder/Destroy()
	if(deployed_mortar)
		QDEL_NULL(deployed_mortar)
	return ..()
////////////////////////////////// FUEL EQUIPMENT /////////////////////////////////

/obj/structure/dropship_equipment/fuel
	icon = 'icons/Marine/mainship_props64.dmi'
	equip_category = DROPSHIP_FUEL_EQP


/obj/structure/dropship_equipment/fuel/update_equipment()
	if(ship_base)
		pixel_x = ship_base.pixel_x
		pixel_y = ship_base.pixel_y
		icon_state = "[initial(icon_state)]_installed"
	else
		pixel_x = initial(pixel_x)
		pixel_y = initial(pixel_y)
		bound_width = initial(bound_width)
		bound_height = initial(bound_height)
		icon_state = initial(icon_state)


///////////////////////////////////// ELECTRONICS /////////////////////////////////////////

/obj/structure/dropship_equipment/electronics
	equip_category = DROPSHIP_ELECTRONICS

/obj/structure/dropship_equipment/electronics/spotlights
	name = "spotlight"
	icon_state = "spotlights"
	desc = "A set of highpowered spotlights to illuminate large areas. Fits on electronics attach points of dropships. Moving this will require a powerloader."
	dropship_equipment_flags = IS_INTERACTABLE
	point_cost = 300
	var/spotlights_cooldown
	var/brightness = 11

/obj/structure/dropship_equipment/electronics/spotlights/equipment_interact(mob/user)
	if(spotlights_cooldown > world.time)
		to_chat(user, span_warning("[src] is busy."))
		return //prevents spamming deployment/undeployment
	if(luminosity != brightness)
		set_light(brightness, brightness)
		icon_state = "spotlights_on"
		to_chat(user, span_notice("You turn on [src]."))
	else
		set_light(0)
		icon_state = "spotlights_off"
		to_chat(user, span_notice("You turn off [src]."))
	spotlights_cooldown = world.time + 50

/obj/structure/dropship_equipment/electronics/spotlights/update_equipment()
	. = ..()
	if(ship_base)
		if(luminosity != brightness)
			icon_state = "spotlights_off"
		else
			icon_state = "spotlights_on"
	else
		icon_state = "spotlights"
		if(luminosity)
			set_light(0)

/obj/structure/dropship_equipment/electronics/spotlights/on_launch()
	set_light(0)

/obj/structure/dropship_equipment/electronics/spotlights/on_arrival()
	set_light(brightness, brightness)

/////////////////////////////////// COMPUTERS //////////////////////////////////////

//unfinished and unused
/obj/structure/dropship_equipment/adv_comp
	equip_category = DROPSHIP_COMPUTER
	point_cost = 0

/obj/structure/dropship_equipment/adv_comp/update_equipment()
	if(ship_base)
		icon_state = "[initial(icon_state)]_installed"
	else
		icon_state = initial(icon_state)


/obj/structure/dropship_equipment/adv_comp/docking
	name = "docking computer"
	icon_state = "docking_comp"
	point_cost = 0


////////////////////////////////////// WEAPONS ///////////////////////////////////////

/obj/structure/dropship_equipment/weapon
	name = "abstract weapon"
	icon = 'icons/Marine/mainship_props64.dmi'
	equip_category = DROPSHIP_WEAPON
	bound_width = 32
	bound_height = 64
	dropship_equipment_flags = USES_AMMO|IS_WEAPON|IS_INTERACTABLE|FIRE_MISSION_ONLY
	screen_mode = 1
	COOLDOWN_DECLARE(last_fired) //used for weapon cooldown after use.
	var/firing_sound
	var/firing_delay = 20 //delay between firing. 2 seconds by default

/obj/structure/dropship_equipment/weapon/update_equipment()
	if(ship_base)
		setDir(ship_base.dir)
		bound_width = 32
		bound_height = 32
	else
		setDir(initial(dir))
		bound_width = initial(bound_width)
		bound_height = initial(bound_height)
	update_icon()

/obj/structure/dropship_equipment/weapon/equipment_interact(mob/user)
	if(dropship_equipment_flags & IS_INTERACTABLE)
		if(linked_console.selected_equipment == src)
			linked_console.selected_equipment = null
		else
			linked_console.selected_equipment = src

/obj/structure/dropship_equipment/weapon/examine(mob/user)
	. = ..()
	if(ammo_equipped)
		. += ammo_equipped.show_loaded_desc(user)
		return
	. += "It's empty."



/obj/structure/dropship_equipment/weapon/proc/deplete_ammo()
	if(ammo_equipped)
		ammo_equipped.ammo_count = max(ammo_equipped.ammo_count-ammo_equipped.ammo_used_per_firing, 0)
	update_icon()

/obj/structure/dropship_equipment/weapon/proc/open_fire(obj/selected_target, attackdir)
	var/turf/target_turf = get_turf(selected_target)
	if(firing_sound)
		playsound(loc, firing_sound, 70, 1)
	var/obj/structure/ship_ammo/SA = ammo_equipped //necessary because we nullify ammo_equipped when firing big rockets
	var/ammo_travelling_time = SA.travelling_time * ((GLOB.current_orbit+3)/6) //how long the rockets/bullets take to reach the ground target.
	var/ammo_warn_sound = SA.warning_sound
	deplete_ammo()
	COOLDOWN_START(src, last_fired, firing_delay)

	if(ammo_warn_sound)
		playsound(target_turf, ammo_warn_sound, 70, 1)

	//Lase
	var/obj/effect/overlay/blinking_laser/laserdot = new SA.cas_effect(target_turf)
	laserdot.dir = attackdir
	var/list/effects_to_delete = list(laserdot)

	//Marine-only visuals
	var/predicted_dangerous_turfs = SA.get_turfs_to_impact(target_turf, attackdir)
	for(var/turf/impact in predicted_dangerous_turfs)
		effects_to_delete += new /obj/effect/overlay/blinking_laser/marine/lines(impact)

	addtimer(CALLBACK(SA, /obj/structure/ship_ammo.proc/detonate_on, target_turf, attackdir), ammo_travelling_time)
	QDEL_LIST_IN(effects_to_delete, ammo_travelling_time)

/obj/structure/dropship_equipment/weapon/heavygun
	name = "\improper GAU-21 30mm cannon"
	desc = "A dismounted GAU-21 'Rattler' 30mm rotary cannon. It seems to be missing its feed links and has exposed connection wires. Capable of firing 5200 rounds a minute, feared by many for its power. Earned the nickname 'Rattler' from the vibrations it would cause on dropships in its inital production run. Moving this will require some sort of lifter."
	icon_state = "30mm_cannon"
	firing_sound = 'sound/weapons/gunship_chaingun.ogg'
	point_cost = 400
	dropship_equipment_flags = USES_AMMO|IS_WEAPON|IS_INTERACTABLE
	ammo_type_used = CAS_30MM

/obj/structure/dropship_equipment/weapon/heavygun/update_icon()
	if(ammo_equipped)
		icon_state = "30mm_cannon_loaded[ammo_equipped.ammo_count?"1":"0"]"
	else
		if(ship_base)
			icon_state = "30mm_cannon_installed"
		else
			icon_state = "30mm_cannon"

/obj/structure/dropship_equipment/weapon/heavygun/radial_cas
	name = "Condor Jet Radial minigun"
	point_cost = 0
	dropship_equipment_flags = USES_AMMO|IS_WEAPON|IS_INTERACTABLE|IS_NOT_REMOVABLE

/obj/structure/dropship_equipment/weapon/heavygun/radial_cas/Initialize()
	. = ..()
	ammo_equipped = new /obj/structure/ship_ammo/heavygun(src)

/obj/structure/dropship_equipment/weapon/rocket_pod
	name = "rocket pod"
	icon_state = "rocket_pod"
	desc = "A rocket pod weapon system capable of launching a single laser-guided rocket. Moving this will require some sort of lifter."
	firing_sound = 'sound/weapons/gunship_rocket.ogg'
	firing_delay = 5
	point_cost = 600
	ammo_type_used = CAS_MISSILE

/obj/structure/dropship_equipment/weapon/rocket_pod/deplete_ammo()
	ammo_equipped = null //nothing left to empty after firing
	update_icon()

/obj/structure/dropship_equipment/weapon/rocket_pod/update_icon()
	if(ammo_equipped && ammo_equipped.ammo_count)
		icon_state = "rocket_pod_loaded[ammo_equipped.ammo_id]"
	else
		if(ship_base)
			icon_state = "rocket_pod_installed"
		else
			icon_state = "rocket_pod"


/obj/structure/dropship_equipment/weapon/minirocket_pod
	name = "minirocket pod"
	icon_state = "minirocket_pod"
	desc = "A mini rocket pod capable of launching six laser-guided mini rockets. Moving this will require some sort of lifter."
	icon = 'icons/Marine/mainship_props64.dmi'
	firing_sound = 'sound/weapons/gunship_rocketpod.ogg'
	firing_delay = 10 //1 seconds
	point_cost = 600
	ammo_type_used = CAS_MINI_ROCKET

/obj/structure/dropship_equipment/weapon/minirocket_pod/update_icon()
	if(ammo_equipped && ammo_equipped.ammo_count)
		icon_state = "minirocket_pod_loaded"
	else
		if(ship_base)
			icon_state = "minirocket_pod_installed"
		else
			icon_state = "minirocket_pod"

/obj/structure/dropship_equipment/weapon/minirocket_pod/deplete_ammo()
	..()
	if(ammo_equipped && !ammo_equipped.ammo_count) //fired last minirocket
		ammo_equipped = null

/obj/structure/dropship_equipment/weapon/laser_beam_gun
	name = "laser beam gun"
	icon_state = "laser_beam"
	desc = "State of the art technology recently acquired by the TGMC, it fires a battery-fed pulsed laser beam at near lightspeed setting on fire everything it touches. Moving this will require some sort of lifter."
	icon = 'icons/Marine/mainship_props64.dmi'
	firing_sound = 'sound/weapons/gunship_laser.ogg'
	firing_delay = 50 //5 seconds
	point_cost = 600
	dropship_equipment_flags = USES_AMMO|IS_WEAPON|IS_INTERACTABLE
	ammo_type_used = CAS_LASER_BATTERY

/obj/structure/dropship_equipment/weapon/laser_beam_gun/update_icon()
	if(ammo_equipped && ammo_equipped.ammo_count)
		icon_state = "laser_beam_loaded"
	else
		if(ship_base)
			icon_state = "laser_beam_installed"
		else
			icon_state = "laser_beam"



/obj/structure/dropship_equipment/weapon/launch_bay
	name = "launch bay"
	icon_state = "launch_bay"
	desc = "A launch bay to drop special ordnance. Fits inside the dropship's crew weapon emplacement. Moving this will require some sort of lifter."
	icon = 'icons/Marine/mainship_props.dmi'
	firing_sound = 'sound/weapons/guns/fire/gunshot.ogg'
	firing_delay = 10 //1 seconds
	equip_category = DROPSHIP_CREW_WEAPON //fits inside the central spot of the dropship
	point_cost = 0

/obj/structure/dropship_equipment/weapon/launch_bay/update_icon()
	if(ammo_equipped?.ammo_count)
		icon_state = "launch_bay_loaded"
	else
		if(ship_base)
			icon_state = "launch_bay"
		else
			icon_state = "launch_bay"




//////////////// OTHER EQUIPMENT /////////////////

/obj/structure/dropship_equipment/operatingtable
	name = "Dropship Operating Table Deployment System"
	desc = "Used for advanced medical procedures. Fits on the crewserved weapon attach points of dropships. You need a powerloader to lift it."
	equip_category = DROPSHIP_CREW_WEAPON
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	point_cost = 100
	var/obj/machinery/optable/deployed_table

/obj/structure/dropship_equipment/operatingtable/Initialize()
	. = ..()
	if(!deployed_table)
		deployed_table = new(src)
		RegisterSignal(deployed_table, COMSIG_PARENT_ATTACKBY, .proc/attackby_wrapper)//if something (like a powerloader) clicks on the deployed thing relay it

/obj/structure/dropship_equipment/operatingtable/proc/attackby_wrapper(datum/source, obj/item/I, mob/user, params)
	attackby(I, user, params)

/obj/structure/dropship_equipment/operatingtable/examine(mob/user)
	. = ..()
	if(!deployed_table)
		. += "Its table is broken."

/obj/structure/dropship_equipment/operatingtable/Destroy()
	QDEL_NULL(deployed_table)
	return ..()

/obj/structure/dropship_equipment/operatingtable/update_equipment()
	if(!deployed_table)
		return
	deployed_table.layer = ABOVE_OBJ_LAYER + 0.01 //make sure its directly ABOVE the layer
	deployed_table.loc = loc
	icon_state = "table2-idle"

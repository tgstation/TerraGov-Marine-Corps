
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
		to_chat(user, "<span class='warning'>[loaded_equipment] doesn't fit on [src].</span>")
		return TRUE
	if(installed_equipment)
		return TRUE
	playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
	if(!do_after(user, 7 SECONDS, FALSE, src))
		return TRUE
	if(installed_equipment || clamp.loaded != loaded_equipment)
		return TRUE
	to_chat(user, "<span class='notice'>You install [loaded_equipment] on [src].</span>")
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
	ship_tag = "alamo"

/obj/effect/attach_point/weapon/dropship2
	ship_tag = "normandy"

/obj/effect/attach_point/weapon/cas
	ship_tag = "casplane"
	icon = 'icons/Marine/casship.dmi'
	icon_state = "15"

/obj/effect/attach_point/weapon/minidropship
	ship_tag = "minidropship"
	icon_state = "equip_base"

/obj/effect/attach_point/crew_weapon
	name = "rear attach point"
	base_category = DROPSHIP_CREW_WEAPON

/obj/effect/attach_point/crew_weapon/dropship1
	ship_tag = "alamo"

/obj/effect/attach_point/crew_weapon/dropship2
	ship_tag = "normandy"

/obj/effect/attach_point/crew_weapon/minidropship
	ship_tag = "minidropship"

/obj/effect/attach_point/electronics
	name = "electronic system attach point"
	base_category = DROPSHIP_ELECTRONICS
	icon_state = "equip_base_front"

/obj/effect/attach_point/electronics/dropship1
	ship_tag = "alamo"

/obj/effect/attach_point/electronics/dropship2
	ship_tag = "normandy"


/obj/effect/attach_point/fuel
	name = "engine system attach point"
	icon = 'icons/Marine/mainship_props64.dmi'
	icon_state = "fuel_base"
	base_category = DROPSHIP_FUEL_EQP

/obj/effect/attach_point/fuel/dropship1
	ship_tag = "alamo"

/obj/effect/attach_point/fuel/dropship2
	ship_tag = "normandy"


/obj/effect/attach_point/computer
	base_category = DROPSHIP_COMPUTER

/obj/effect/attach_point/computer/dropship1
	ship_tag = "alamo"

/obj/effect/attach_point/computer/dropship2
	ship_tag = "normandy"



//////////////////////////////////////////////////////////////////////////////////////////////////////////////::

//Actual dropship equipments

/obj/structure/dropship_equipment
	density = TRUE
	anchored = TRUE
	icon = 'icons/Marine/mainship_props.dmi'
	climbable = TRUE
	layer = ABOVE_OBJ_LAYER //so they always appear above attach points when installed
	resistance_flags = XENO_DAMAGEABLE
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
		if(((!dropship_equipment_flags & IS_NOT_REMOVABLE) && !ship_base) || !(dropship_equipment_flags & USES_AMMO) || ammo_equipped || !istype(clamp.loaded, /obj/structure/ship_ammo))
			return FALSE
		var/obj/structure/ship_ammo/clamp_ammo = clamp.loaded
		if(istype(type, clamp_ammo.equipment_type) || clamp_ammo.ammo_type != ammo_type_used) //Incompatible ammo
			to_chat(user, "<span class='warning'>[clamp_ammo] doesn't fit in [src].</span>")
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
		to_chat(user, "<span class='notice'>You load [clamp_ammo] into [src].</span>")
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
			to_chat(user, "<span class='notice'>You've discarded the empty [ammo_equipped.name] in [src].</span>")
			qdel(ammo_equipped)
		else
			ammo_equipped.forceMove(clamp.linked_powerloader)
			clamp.loaded = ammo_equipped
			clamp.update_icon()
			to_chat(user, "<span class='notice'>You've removed [ammo_equipped] from [src] and loaded it into [clamp].</span>")
		ammo_equipped = null
		update_icon()
		return TRUE //emptied or removed dropship ammo
	else if(dropship_equipment_flags & IS_NOT_REMOVABLE)
		to_chat(user, "<span class='notice'>You cannot remove [src]!</span>")
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
		to_chat(user, "<span class='notice'>You've [ship_base ? "uninstalled" : "grabbed"] [clamp.loaded] with [clamp].</span>")
		if(ship_base)
			ship_base.installed_equipment = null
			ship_base = null
			if(linked_shuttle)
				linked_shuttle.equipments -= src
				linked_shuttle = null
				if(linked_console && linked_console.selected_equipment == src)
					linked_console.selected_equipment = null
		update_equipment()
		return TRUE //removed or uninstalled equipment
	to_chat(user, "<span class='notice'>You cannot touch [src] with the [clamp] due to the acid on [src].</span>")
	return TRUE

/obj/structure/dropship_equipment/update_icon()
	return

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
		to_chat(user, "<span class='notice'>You select [src].</span>")



//////////////////////////////////// turret holders //////////////////////////////////////

/obj/structure/dropship_equipment/sentry_holder
	equip_category = DROPSHIP_WEAPON
	name = "sentry deployment system"
	desc = "A box that deploys a sentry turret. Fits on the weapon attach points of dropships. You need a powerloader to lift it."
	icon_state = "sentry_system"
	dropship_equipment_flags = IS_INTERACTABLE
	point_cost = 500
	var/deployment_cooldown
	var/obj/machinery/marine_turret/premade/dropship/deployed_turret

/obj/structure/dropship_equipment/sentry_holder/Initialize()
	. = ..()
	if(!deployed_turret)
		deployed_turret = new(src)
		deployed_turret.deployment_system = src


/obj/structure/dropship_equipment/sentry_holder/examine(mob/user)
	. = ..()
	if(!deployed_turret)
		to_chat(user, "Its turret is missing.")

/obj/structure/dropship_equipment/sentry_holder/on_launch()
	undeploy_sentry()

/obj/structure/dropship_equipment/sentry_holder/equipment_interact(mob/user)
	if(!deployed_turret)
		to_chat(user, "<span class='warning'>[src] is unresponsive.</span>")
		return
	if(deployment_cooldown > world.time)
		to_chat(user, "<span class='warning'>[src] is busy.</span>")
		return //prevents spamming deployment/undeployment
	if(deployed_turret.loc == src) //not deployed
		if(is_reserved_level(z))
			to_chat(user, "<span class='warning'>[src] can't deploy mid-flight.</span>")
		else
			to_chat(user, "<span class='notice'>You deploy [src].</span>")
			deploy_sentry()
	else
		to_chat(user, "<span class='notice'>You retract [src].</span>")
		undeploy_sentry()


/obj/structure/dropship_equipment/sentry_holder/update_equipment()
	if(ship_base)
		setDir(ship_base.dir)
		icon_state = "sentry_system_installed"
		if(deployed_turret)
			deployed_turret.setDir(dir)
			if(linked_shuttle && deployed_turret.camera)
				if(linked_shuttle.id == "alamo")
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
			DISABLE_BITFIELD(deployed_turret.turret_flags, TURRET_ON)
		else
			icon_state = "sentry_system_destroyed"

/obj/structure/dropship_equipment/sentry_holder/proc/deploy_sentry()
	if(!deployed_turret)
		return
	setDir(ship_base.dir)
	deployed_turret.setDir(dir)
	playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
	deployment_cooldown = world.time + 50
	ENABLE_BITFIELD(deployed_turret.turret_flags, TURRET_ON)
	deployed_turret.update_icon()
	deployed_turret.loc = get_step(src, dir)
	icon_state = "sentry_system_deployed"

/obj/structure/dropship_equipment/sentry_holder/proc/undeploy_sentry()
	if(!deployed_turret)
		return
	playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
	deployment_cooldown = world.time + 50
	deployed_turret.loc = src
	DISABLE_BITFIELD(deployed_turret.turret_flags, TURRET_ON)
	deployed_turret.update_icon()
	icon_state = "sentry_system_installed"



/obj/structure/dropship_equipment/mg_holder
	name = "machinegun deployment system"
	desc = "A box that deploys a modified M56D crewserved machine gun. Fits on the crewserved weapon attach points of dropships. You need a powerloader to lift it."
	equip_category = DROPSHIP_CREW_WEAPON
	icon_state = "mg_system"
	point_cost = 300
	var/obj/machinery/standard_hmg/mg_turret/deployed_mg

/obj/structure/dropship_equipment/mg_holder/Initialize()
	. = ..()
	if(!deployed_mg)
		deployed_mg = new(src)

/obj/structure/dropship_equipment/mg_holder/examine(mob/user)
	. = ..()
	if(!deployed_mg)
		to_chat(user, "Its machine gun is missing.")

/obj/structure/dropship_equipment/mg_holder/update_equipment()
	if(!deployed_mg)
		return
	if(ship_base)
		deployed_mg.loc = loc
		icon_state = "mg_system_deployed"
	else
		deployed_mg.loc = src
		icon_state = "mg_system"


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


/obj/structure/dropship_equipment/fuel/fuel_enhancer
	name = "fuel enhancer"
	desc = "A fuel enhancement system for dropships. It improves the thrust produced by the fuel combustion for faster travels. Fits inside the engine attach points. You need a powerloader to lift it."
	icon_state = "fuel_enhancer"
	point_cost = 800

/obj/structure/dropship_equipment/fuel/cooling_system
	name = "cooling system"
	desc = "A cooling system for dropships. It produces additional cooling reducing delays between launch. Fits inside the engine attach points. You need a powerloader to lift it."
	icon_state = "cooling_system"
	point_cost = 800


///////////////////////////////////// ELECTRONICS /////////////////////////////////////////

/obj/structure/dropship_equipment/electronics
	equip_category = DROPSHIP_ELECTRONICS

/obj/structure/dropship_equipment/electronics/chaff_launcher
	name = "chaff launcher"
	icon_state = "chaff_launcher"
	point_cost = 0



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
		to_chat(user, "<span class='warning'>[src] is busy.</span>")
		return //prevents spamming deployment/undeployment
	if(luminosity != brightness)
		set_light(brightness)
		icon_state = "spotlights_on"
		to_chat(user, "<span class='notice'>You turn on [src].</span>")
	else
		set_light(0)
		icon_state = "spotlights_off"
		to_chat(user, "<span class='notice'>You turn off [src].</span>")
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
	set_light(brightness)



/obj/structure/dropship_equipment/electronics/flare_launcher
	name = "flare launcher"
	icon_state = "flare_launcher"
	point_cost = 0

/obj/structure/dropship_equipment/electronics/targeting_system
	name = "targeting system"
	icon_state = "targeting_system"
	desc = "A targeting system for dropships. It improves firing accuracy on laser targets. Fits on electronics attach points. You need a powerloader to lift this."
	point_cost = 800

/obj/structure/dropship_equipment/electronics/targeting_system/update_equipment()
	if(ship_base)
		icon_state = "[initial(icon_state)]_installed"
	else
		icon_state = initial(icon_state)


/obj/structure/dropship_equipment/electronics/laser_detector
	name = "laser detector"
	desc = "An electronic device linked to the dropship's camera system that lets you observe laser targets on the ground mid-flight."
	icon_state = "laser_detector"
	point_cost = 400
	var/obj/machinery/computer/security/dropship/linked_cam_console

/obj/structure/dropship_equipment/electronics/laser_detector/update_equipment()
	if(ship_base)
		if(!linked_cam_console)
			for(var/obj/machinery/computer/security/dropship/D in range(5, loc))
				linked_cam_console = D
				break
		icon_state = "[initial(icon_state)]_installed"
	else
		linked_cam_console = null
		icon_state = initial(icon_state)

/obj/structure/dropship_equipment/electronics/laser_detector/Destroy()
	linked_cam_console = null
	return ..()

/obj/structure/dropship_equipment/electronics/laser_detector/on_launch()
	linked_cam_console.network.Add("laser targets") //only accessible while in the air.

/obj/structure/dropship_equipment/electronics/laser_detector/on_arrival()
	linked_cam_console.network.Remove("laser targets")



/obj/structure/dropship_equipment/electronics/landing_zone_detector
	name = "\improper LZ detector"
	desc = "An electronic device linked to the dropship's camera system that lets you observe your landing zone mid-flight."
	icon_state = "lz_detector"
	point_cost = 400
	var/obj/machinery/computer/security/dropship/linked_cam_console

/obj/structure/dropship_equipment/electronics/landing_zone_detector/update_equipment()
	if(ship_base)
		if(!linked_cam_console)
			for(var/obj/machinery/computer/security/dropship/D in range(5, loc))
				linked_cam_console = D
				break
		icon_state = "[initial(icon_state)]_installed"
	else
		linked_cam_console = null
		icon_state = initial(icon_state)


/obj/structure/dropship_equipment/electronics/landing_zone_detector/Destroy()
	linked_cam_console = null
	return ..()

/obj/structure/dropship_equipment/electronics/landing_zone_detector/on_launch()
	linked_cam_console.network.Add("landing zones") //only accessible while in the air.

/obj/structure/dropship_equipment/electronics/landing_zone_detector/on_arrival()
	linked_cam_console.network.Remove("landing zones")


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
		ammo_equipped.show_loaded_desc(user)
	else
		to_chat(user, "It's empty.")



/obj/structure/dropship_equipment/weapon/proc/deplete_ammo()
	if(ammo_equipped)
		ammo_equipped.ammo_count = max(ammo_equipped.ammo_count-ammo_equipped.ammo_used_per_firing, 0)
	update_icon()

/obj/structure/dropship_equipment/weapon/proc/open_fire(obj/selected_target, attackdir)
	var/turf/target_turf = get_turf(selected_target)
	if(firing_sound)
		playsound(loc, firing_sound, 70, 1)
	var/obj/structure/ship_ammo/SA = ammo_equipped //necessary because we nullify ammo_equipped when firing big rockets
	var/ammo_travelling_time = SA.travelling_time * (GLOB.current_orbit/3) //how long the rockets/bullets take to reach the ground target.
	var/ammo_warn_sound = SA.warning_sound
	deplete_ammo()
	COOLDOWN_START(src, last_fired, firing_delay)
	if(linked_shuttle)
		for(var/obj/structure/dropship_equipment/electronics/targeting_system/TS in linked_shuttle.equipments)
			ammo_travelling_time = max(ammo_travelling_time - 2 SECONDS, 1 SECONDS) //targeting system reduces travelling time
			break

	if(ammo_warn_sound)
		playsound(target_turf, ammo_warn_sound, 70, 1)
	var/obj/effect/overlay/blinking_laser/laser = new (target_turf)
	addtimer(CALLBACK(SA, /obj/structure/ship_ammo.proc/detonate_on, target_turf, attackdir), ammo_travelling_time)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, laser), ammo_travelling_time)
/obj/structure/dropship_equipment/weapon/heavygun
	name = "\improper GAU-21 30mm cannon"
	desc = "A dismounted GAU-21 'Rattler' 30mm rotary cannon. It seems to be missing its feed links and has exposed connection wires. Capable of firing 5200 rounds a minute, feared by many for its power. Earned the nickname 'Rattler' from the vibrations it would cause on dropships in its inital production run."
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
	point_cost = 500
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
		to_chat(user, "Its table is broken.")

/obj/structure/dropship_equipment/operatingtable/Destroy()
	QDEL_NULL(deployed_table)
	return ..()

/obj/structure/dropship_equipment/operatingtable/update_equipment()
	if(!deployed_table)
		return
	deployed_table.layer = ABOVE_OBJ_LAYER + 0.01 //make sure its directly ABOVE the layer
	deployed_table.loc = loc
	icon_state = "table2-idle"

/obj/structure/dropship_equipment/medevac_system
	name = "medevac system"
	desc = "A winch system to lift injured marines on medical stretchers onto the dropship. Acquire lift target through the dropship equipment console."
	equip_category = DROPSHIP_CREW_WEAPON
	icon_state = "medevac_system"
	point_cost = 500
	dropship_equipment_flags = IS_INTERACTABLE
	var/obj/structure/bed/medevac_stretcher/linked_stretcher
	var/medevac_cooldown
	var/busy_winch

/obj/structure/dropship_equipment/medevac_system/Destroy()
	if(linked_stretcher)
		linked_stretcher.linked_medevac = null
		linked_stretcher = null
	return ..()

/obj/structure/dropship_equipment/medevac_system/update_equipment()
	if(ship_base)
		icon_state = "medevac_system_deployed"
	else
		if(linked_stretcher)
			linked_stretcher.linked_medevac = null
			linked_stretcher = null
		icon_state = "medevac_system"


/obj/structure/dropship_equipment/medevac_system/equipment_interact(mob/user)
	if(!linked_shuttle)
		return

	if(linked_shuttle.mode != SHUTTLE_CALL)
		to_chat(user, "<span class='warning'>[src] can only be used while in flight.</span>")
		return

	if(busy_winch)
		to_chat(user, "<span class='warning'> The winch is already in motion.</span>")
		return

	if(world.time < medevac_cooldown)
		to_chat(user, "<span class='warning'>[src] was just used, you need to wait a bit before using it again.</span>")
		return

	var/list/possible_stretchers = list()
	for(var/obj/structure/bed/medevac_stretcher/MS in GLOB.activated_medevac_stretchers)
		var/area/AR = get_area(MS)
		var/evaccee
		if(LAZYLEN(MS.buckled_mobs))
			evaccee = MS.buckled_mobs[1].real_name
		else if(MS.buckled_bodybag)
			for(var/atom/movable/AM in MS.buckled_bodybag)
				if(isliving(AM))
					var/mob/living/L = AM
					evaccee = "[MS.buckled_bodybag.name]: [L.real_name]"
					break
			if(!evaccee)
				evaccee = "Empty [MS.buckled_bodybag.name]"
		else
			evaccee = "Empty"
		possible_stretchers["[evaccee] ([AR.name])"] = MS

	if(!possible_stretchers.len)
		to_chat(user, "<span class='warning'>No active medevac stretcher detected.</span>")
		return

	var/stretcher_choice = tgui_input_list(user, "Which emitting stretcher would you like to link with?", "Available stretchers", possible_stretchers)
	if(!stretcher_choice)
		return

	var/obj/structure/bed/medevac_stretcher/selected_stretcher = possible_stretchers[stretcher_choice]
	if(!selected_stretcher)
		return

	if(!ship_base) //system was uninstalled midway
		return

	if(!selected_stretcher.stretcher_activated)//stretcher beacon was deactivated midway
		return

	if(!is_ground_level(selected_stretcher.z)) //in case the stretcher was on a groundside dropship that flew away during our input()
		return

	if(!LAZYLEN(selected_stretcher.buckled_mobs) && !selected_stretcher.buckled_bodybag)
		to_chat(user, "<span class='warning'>This medevac stretcher is empty.</span>")
		return

	if(selected_stretcher.linked_medevac && selected_stretcher.linked_medevac != src)
		to_chat(user, "<span class='warning'>There's another dropship hovering over that medevac stretcher.</span>")
		return

	if(!linked_shuttle)
		return

	if(linked_shuttle.mode != SHUTTLE_CALL)
		to_chat(user, "<span class='warning'>[src] can only be used while in flight.</span>")
		return

	if(busy_winch)
		to_chat(user, "<span class='warning'> The winch is already in motion.</span>")
		return

	if(world.time < medevac_cooldown)
		to_chat(user, "<span class='warning'>[src] was just used, you need to wait a bit before using it again.</span>")
		return

	if(selected_stretcher == linked_stretcher) //already linked to us, unlink it
		to_chat(user, "<span class='notice'> You move your dropship away from that stretcher's beacon.</span>")
		linked_stretcher.visible_message("<span class='notice'>[linked_stretcher] detects a dropship is no longer overhead.</span>")
		linked_stretcher.linked_medevac = null
		linked_stretcher = null
		return

	to_chat(user, "<span class='notice'> You move your dropship above the selected stretcher's beacon.</span>")

	if(linked_stretcher)
		linked_stretcher.linked_medevac = null
		linked_stretcher.visible_message("<span class='notice'>[linked_stretcher] detects a dropship is no longer overhead.</span>")

	linked_stretcher = selected_stretcher
	linked_stretcher.linked_medevac = src
	linked_stretcher.visible_message("<span class='notice'>[linked_stretcher] detects a dropship overhead.</span>")




//on arrival we break any link
/obj/structure/dropship_equipment/medevac_system/on_arrival()
	if(linked_stretcher)
		linked_stretcher.linked_medevac = null
		linked_stretcher = null


/obj/structure/dropship_equipment/medevac_system/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	if(!ship_base) //not installed
		return
	if(user.skills.getRating("pilot") < SKILL_PILOT_TRAINED)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to use the medevac system.</span>",
		"<span class='notice'>You fumble around figuring out how to use the medevac system.</span>")
		var/fumbling_time = 6 SECONDS - 2 SECONDS * user.skills.getRating("pilot")
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_BUILD))
			return

	if(!linked_shuttle)
		return

	if(linked_shuttle.mode != SHUTTLE_CALL)
		to_chat(user, "<span class='warning'>[src] can only be used while in flight.</span>")
		return

	if(busy_winch)
		to_chat(user, "<span class='warning'> The winch is already in motion.</span>")
		return

	if(!linked_stretcher)
		to_chat(user, "<span class='warning'>There seems to be no medevac stretcher connected to [src].</span>")
		return

	if(!is_ground_level(linked_stretcher.z))
		linked_stretcher.linked_medevac = null
		linked_stretcher = null
		to_chat(user, "<span class='warning'> There seems to be no medevac stretcher connected to [src].</span>")
		return

	if(world.time < medevac_cooldown)
		to_chat(user, "<span class='warning'>[src] was just used, you need to wait a bit before using it again.</span>")
		return

	activate_winch(user)


/obj/structure/dropship_equipment/medevac_system/proc/activate_winch(mob/user)
	set waitfor = 0
	var/old_stretcher = linked_stretcher
	busy_winch = TRUE
	playsound(loc, 'sound/machines/medevac_extend.ogg', 40, 1)
	flick("medevac_system_active", src)
	user.visible_message("<span class='notice'>[user] activates [src]'s winch.</span>", \
						"<span class='notice'>You activate [src]'s winch.</span>")
	sleep(3 SECONDS)

	busy_winch = FALSE
	var/fail
	if(!linked_stretcher || linked_stretcher != old_stretcher || !is_ground_level(linked_stretcher.z))
		fail = TRUE

	else if(!ship_base) //uninstalled midway
		fail = TRUE

	else if(!linked_shuttle || linked_shuttle.mode != SHUTTLE_CALL)
		fail = TRUE

	if(fail)
		if(linked_stretcher)
			linked_stretcher.linked_medevac = null
			linked_stretcher = null
		to_chat(user, "<span class='warning'>The winch finishes lifting but there seems to be no medevac stretchers connected to [src].</span>")
		return

	var/atom/movable/lifted_object
	if(LAZYLEN(linked_stretcher.buckled_mobs))
		lifted_object = linked_stretcher.buckled_mobs[1]
	else if(linked_stretcher.buckled_bodybag)
		lifted_object = linked_stretcher.buckled_bodybag

	if(lifted_object)
		var/turf/T = get_turf(lifted_object)
		T.ceiling_debris_check(2)
		lifted_object.forceMove(loc)
	else
		to_chat(user, "<span class='warning'>The winch finishes lifting the medevac stretcher but it's empty!</span>")
		linked_stretcher.linked_medevac = null
		linked_stretcher = null
		return

	flick("winched_stretcher", linked_stretcher)
	linked_stretcher.visible_message("<span class='notice'>A winch hook falls from the sky and starts lifting [linked_stretcher] up.</span>")

	medevac_cooldown = world.time + 600
	linked_stretcher.linked_medevac = null
	linked_stretcher = null


#define DROPSHIP_WEAPON "dropship_weapon"
#define DROPSHIP_CREW_WEAPON "dropship_crew_weapon"
#define DROPSHIP_ELECTRONICS "dropship_electronics"
#define DROPSHIP_FUEL_EQP "dropship_fuel_equipment"
#define DROPSHIP_COMPUTER "dropship_computer"


//the bases onto which you attach dropship equipments.

/obj/effect/attach_point
	name = "equipment attach point"
	desc = "A place where heavy equipment can be installed with a powerloader."
	unacidable = TRUE
	anchored = TRUE
	icon = 'icons/Marine/almayer_props.dmi'
	icon_state = "equip_base"
	var/base_category //what kind of equipment this base accepts.
	var/ship_tag//used to associate the base to a dropship.
	var/obj/structure/dropship_equipment/installed_equipment

	Dispose()
		if(installed_equipment)
			cdel(installed_equipment)
			installed_equipment = null
		. = ..()

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/powerloader_clamp))
			var/obj/item/powerloader_clamp/PC = I
			if(istype(PC.loaded, /obj/structure/dropship_equipment))
				var/obj/structure/dropship_equipment/SE = PC.loaded
				if(SE.equip_category != base_category)
					user << "<span class='warning'>[SE] doesn't fit on [src].</span>"
					return TRUE
				if(installed_equipment) return TRUE
				playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
				if(!do_after(user, 70, FALSE, 5, BUSY_ICON_BUILD)) return TRUE
				if(installed_equipment || PC.loaded != SE) return TRUE
				user << "<span class='notice'>You install [SE] on [src].</span>"
				SE.forceMove(loc)
				PC.loaded = null
				playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
				PC.update_icon()
				installed_equipment = SE
				SE.ship_base = src

				for(var/datum/shuttle/ferry/marine/S in shuttle_controller.process_shuttles)
					if(S.shuttle_tag == ship_tag)
						SE.linked_shuttle = S
						S.equipments += SE
						break

				SE.update_equipment()
			return TRUE
		. = ..()


/obj/effect/attach_point/weapon
	name = "weapon system attach point"
	icon_state = "equip_base_front"
	base_category = DROPSHIP_WEAPON

/obj/effect/attach_point/weapon/dropship1
	ship_tag = "USS Almayer Dropship 1"

/obj/effect/attach_point/weapon/dropship2
	ship_tag = "USS Almayer Dropship 2"


/obj/effect/attach_point/crew_weapon
	name = "rear attach point"
	base_category = DROPSHIP_CREW_WEAPON

/obj/effect/attach_point/crew_weapon/dropship1
	ship_tag = "USS Almayer Dropship 1"

/obj/effect/attach_point/crew_weapon/dropship2
	ship_tag = "USS Almayer Dropship 2"


/obj/effect/attach_point/electronics
	name = "electronic system attach point"
	base_category = DROPSHIP_ELECTRONICS
	icon_state = "equip_base_front"

/obj/effect/attach_point/electronics/dropship1
	ship_tag = "USS Almayer Dropship 1"

/obj/effect/attach_point/electronics/dropship2
	ship_tag = "USS Almayer Dropship 2"


/obj/effect/attach_point/fuel
	name = "engine system attach point"
	icon = 'icons/Marine/almayer_props64.dmi'
	icon_state = "fuel_base"
	base_category = DROPSHIP_FUEL_EQP

/obj/effect/attach_point/fuel/dropship1
	ship_tag = "USS Almayer Dropship 1"

/obj/effect/attach_point/fuel/dropship2
	ship_tag = "USS Almayer Dropship 2"


/obj/effect/attach_point/computer
	base_category = DROPSHIP_COMPUTER

/obj/effect/attach_point/computer/dropship1
	ship_tag = "USS Almayer Dropship 1"

/obj/effect/attach_point/computer/dropship2
	ship_tag = "USS Almayer Dropship 2"



//////////////////////////////////////////////////////////////////////////////////////////////////////////////::

//Actual dropship equipments

/obj/structure/dropship_equipment
	density = TRUE
	anchored = TRUE
	icon = 'icons/Marine/almayer_props.dmi'
	climbable = TRUE
	layer = ABOVE_OBJ_LAYER //so they always appear above attach points when installed
	var/equip_category //on what kind of base this can be installed.
	var/obj/effect/attach_point/ship_base //the ship base the equipment is currently installed on.
	var/uses_ammo = FALSE //whether it uses ammo
	var/obj/structure/ship_ammo/ammo_equipped //the ammo currently equipped.
	var/is_weapon = FALSE //whether the equipment is a weapon usable for dropship bombardment.
	var/obj/machinery/computer/dropship_weapons/linked_console //the weapons console of the dropship we're installed on.
	var/is_interactable = FALSE //whether they get a button when shown on the shuttle console's equipment list.
	var/datum/shuttle/ferry/marine/linked_shuttle
	var/screen_mode = 0 //used by the dropship console code when this equipment is selected
	var/point_cost = 0 //how many points it costs to build this with the fabricator, set to 0 if unbuildable.

	Dispose()
		if(ammo_equipped)
			cdel(ammo_equipped)
			ammo_equipped = null
		if(linked_shuttle)
			linked_shuttle.equipments -= src
			linked_shuttle = null
		if(ship_base)
			ship_base.installed_equipment = null
			ship_base = null
		if(linked_console)
			if(linked_console.selected_equipment && linked_console.selected_equipment == src)
				linked_console.selected_equipment = null
			linked_console = null
		. = ..()

	attackby(obj/item/I, mob/user)

		if(istype(I, /obj/item/powerloader_clamp))
			var/obj/item/powerloader_clamp/PC = I
			if(PC.loaded)
				if(ship_base && uses_ammo && !ammo_equipped && istype(PC.loaded, /obj/structure/ship_ammo))
					var/obj/structure/ship_ammo/SA = PC.loaded
					if(SA.equipment_type == type)
						playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
						if(do_after(user, 30, FALSE, 5, BUSY_ICON_BUILD))
							if(!ammo_equipped && PC.loaded == SA && PC.linked_powerloader && PC.linked_powerloader.buckled_mob == user)
								SA.forceMove(src)
								PC.loaded = null
								playsound(src, 'sound/machines/hydraulics_2.ogg', 40, 1)
								PC.update_icon()
								user << "<span class='notice'>You load [SA] into [src].</span>"
								ammo_equipped = SA
								update_equipment()
					else
						user << "<span class='warning'>[SA] doesn't fit in [src].</span>"

			else if(uses_ammo && ammo_equipped)
				playsound(src, 'sound/machines/hydraulics_2.ogg', 40, 1)
				if(do_after(user, 30, FALSE, 5, BUSY_ICON_BUILD))
					if(ammo_equipped && PC.linked_powerloader && PC.linked_powerloader.buckled_mob == user)
						playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
						if(!ammo_equipped.ammo_count)
							ammo_equipped.loc = null
							user << "<span class='notice'>You discarded the empty [ammo_equipped.name] in [src].</span>"
							cdel(ammo_equipped)
						else
							ammo_equipped.forceMove(PC.linked_powerloader)
							PC.loaded = ammo_equipped
							PC.update_icon()
							user << "<span class='notice'>You've removed [ammo_equipped] from [src] and loaded it into [PC].</span>"
						ammo_equipped = null
						update_icon()
			else
				playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
				var/duration_time = 10
				if(ship_base) duration_time = 70 //uninstalling equipment takes more time
				if(do_after(user, duration_time, FALSE, 5, BUSY_ICON_BUILD))
					if(PC.linked_powerloader && !PC.loaded && PC.linked_powerloader.buckled_mob == user)
						forceMove(PC.linked_powerloader)
						PC.loaded = src
						playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
						PC.update_icon()
						user << "<span class='notice'>You've [ship_base ? "uninstalled" : "grabbed"] [PC.loaded] with [PC].</span>"
						if(ship_base)
							ship_base.installed_equipment = null
							ship_base = null
							if(linked_shuttle)
								linked_shuttle.equipments -= src
								linked_shuttle = null
								if(linked_console && linked_console.selected_equipment == src)
									linked_console.selected_equipment = null
						update_equipment()
			return TRUE



	update_icon()
		return

/obj/structure/dropship_equipment/proc/update_equipment()
	return

//things to do when the shuttle this equipment is attached to is about to launch.
/obj/structure/dropship_equipment/proc/on_launch()
	return

//things to do when the shuttle this equipment is attached to land.
/obj/structure/dropship_equipment/proc/on_arrival()
	return

/obj/structure/dropship_equipment/proc/equipment_interact(mob/user)
	if(is_interactable)
		if(linked_console.selected_equipment) return
		linked_console.selected_equipment = src
		user << "<span class='notice'>You select [src].</span>"



//////////////////////////////////// turret holders //////////////////////////////////////

/obj/structure/dropship_equipment/sentry_holder
	equip_category = DROPSHIP_WEAPON
	name = "sentry deployment system"
	desc = "A box that deploys a sentry turret. Fits on the weapon attach points of dropships. You need a powerloader to lift it."
	icon_state = "sentry_system"
	is_interactable = TRUE
	point_cost = 500
	var/deployment_cooldown
	var/obj/machinery/marine_turret/premade/dropship/deployed_turret

	initialize()
		if(!deployed_turret)
			deployed_turret = new(src)
			deployed_turret.deployment_system = src
		..()

	New()
		if(!deployed_turret)
			deployed_turret = new(src)
			deployed_turret.deployment_system = src
		..()

	examine(mob/user)
		..()
		if(!deployed_turret)
			user << "Its turret is missing."

	on_launch()
		undeploy_sentry()

	equipment_interact(mob/user)
		if(deployed_turret)
			if(deployment_cooldown > world.time)
				user << "<span class='warning'>[src] is busy.</span>"
				return //prevents spamming deployment/undeployment
			if(deployed_turret.loc == src) //not deployed
				if(z == LOW_ORBIT_Z_LEVEL)
					user << "<span class='warning'>[src] can't deploy mid-flight.</span>"
				else
					user << "<span class='notice'>You deploy [src].</span>"
					deploy_sentry()
			else
				user << "<span class='notice'>You retract [src].</span>"
				undeploy_sentry()
		else
			user << "<span class='warning'>[src] is unresponsive.</span>"

	update_equipment()
		if(ship_base)
			dir = ship_base.dir
			icon_state = "sentry_system_installed"
			if(deployed_turret)
				deployed_turret.dir = dir
				if(linked_shuttle && deployed_turret.camera)
					if(linked_shuttle.shuttle_tag == "[MAIN_SHIP_NAME] Dropship 1")
						deployed_turret.camera.network.Add("dropship1") //accessible via the dropship camera console
					else
						deployed_turret.camera.network.Add("dropship2")
				switch(dir)
					if(SOUTH) deployed_turret.pixel_y = 8
					if(NORTH) deployed_turret.pixel_y = -8
					if(EAST) deployed_turret.pixel_x = -8
					if(WEST) deployed_turret.pixel_x = 8
		else
			dir = initial(dir)
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
				deployed_turret.dir = dir
				deployed_turret.on = 0
			else
				icon_state = "sentry_system_destroyed"

/obj/structure/dropship_equipment/sentry_holder/proc/deploy_sentry()
	if(deployed_turret)
		playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
		deployment_cooldown = world.time + 50
		deployed_turret.on = 1
		deployed_turret.loc = get_step(src, dir)
		icon_state = "sentry_system_deployed"

/obj/structure/dropship_equipment/sentry_holder/proc/undeploy_sentry()
	if(deployed_turret)
		playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
		deployment_cooldown = world.time + 50
		deployed_turret.loc = src
		deployed_turret.on = 0
		icon_state = "sentry_system_installed"





/obj/structure/dropship_equipment/mg_holder
	name = "machinegun deployment system"
	desc = "A box that deploys a modified M56D crewserved machine gun. Fits on the crewserved weapon attach points of dropships. You need a powerloader to lift it."
	equip_category = DROPSHIP_CREW_WEAPON
	icon_state = "mg_system"
	point_cost = 300
	var/obj/machinery/m56d_hmg/mg_turret/deployed_mg

	initialize()
		if(!deployed_mg) deployed_mg = new(src)
		..()

	New()
		if(!deployed_mg) deployed_mg = new(src)
		..()

	examine(mob/user)
		..()
		if(!deployed_mg)
			user << "Its machine gun is missing."

	update_equipment()
		if(deployed_mg)
			if(ship_base)
				deployed_mg.loc = loc
				icon_state = "mg_system_deployed"
			else
				deployed_mg.loc = src
				icon_state = "mg_system"


////////////////////////////////// FUEL EQUIPMENT /////////////////////////////////

/obj/structure/dropship_equipment/fuel
	icon = 'icons/Marine/almayer_props64.dmi'
	equip_category = DROPSHIP_FUEL_EQP


	update_equipment()
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


#define LIGHTING_MAX_LUMINOSITY_SHIPLIGHTS 12

/obj/structure/dropship_equipment/electronics/spotlights
	name = "spotlight"
	icon_state = "spotlights"
	desc = "A set of highpowered spotlights to illuminate large areas. Fits on electronics attach points of dropships. Moving this will require a powerloader."
	is_interactable = TRUE
	point_cost = 300
	var/spotlights_cooldown
	var/brightness = 11

	get_light_range()
		return min(luminosity, LIGHTING_MAX_LUMINOSITY_SHIPLIGHTS)

	equipment_interact(mob/user)
		if(spotlights_cooldown > world.time)
			user << "<span class='warning'>[src] is busy.</span>"
			return //prevents spamming deployment/undeployment
		if(luminosity != brightness)
			SetLuminosity(brightness)
			icon_state = "spotlights_on"
			user << "<span class='notice'>You turn on [src].</span>"
		else
			SetLuminosity(0)
			icon_state = "spotlights_off"
			user << "<span class='notice'>You turn off [src].</span>"
		spotlights_cooldown = world.time + 50

	update_equipment()
		..()
		if(ship_base)
			if(luminosity != brightness)
				icon_state = "spotlights_off"
			else
				icon_state = "spotlights_on"
		else
			icon_state = "spotlights"
			if(luminosity)
				SetLuminosity(0)

	on_launch()
		SetLuminosity(0)

	on_arrival()
		SetLuminosity(brightness)

#undef LIGHTING_MAX_LUMINOSITY_SHIPLIGHTS



/obj/structure/dropship_equipment/electronics/flare_launcher
	name = "flare launcher"
	icon_state = "flare_launcher"
	point_cost = 0

/obj/structure/dropship_equipment/electronics/targeting_system
	name = "targeting system"
	icon_state = "targeting_system"
	desc = "A targeting system for dropships. It improves firing accuracy on laser targets. Fits on electronics attach points. You need a powerloader to lift this."
	point_cost = 800

	update_equipment()
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

	update_equipment()
		if(ship_base)
			if(!linked_cam_console)
				for(var/obj/machinery/computer/security/dropship/D in range(5, loc))
					linked_cam_console = D
					break
			icon_state = "[initial(icon_state)]_installed"
		else
			linked_cam_console = null
			icon_state = initial(icon_state)

	Dispose()
		linked_cam_console = null
		. = ..()

	on_launch()
		linked_cam_console.network.Add("laser targets") //only accessible while in the air.

	on_arrival()
		linked_cam_console.network.Remove("laser targets")



/obj/structure/dropship_equipment/electronics/landing_zone_detector
	name = "\improper LZ detector"
	desc = "An electronic device linked to the dropship's camera system that lets you observe your landing zone mid-flight."
	icon_state = "lz_detector"
	point_cost = 400
	var/obj/machinery/computer/security/dropship/linked_cam_console

	update_equipment()
		if(ship_base)
			if(!linked_cam_console)
				for(var/obj/machinery/computer/security/dropship/D in range(5, loc))
					linked_cam_console = D
					break
			icon_state = "[initial(icon_state)]_installed"
		else
			linked_cam_console = null
			icon_state = initial(icon_state)


	Dispose()
		linked_cam_console = null
		. = ..()

	on_launch()
		linked_cam_console.network.Add("landing zones") //only accessible while in the air.

	on_arrival()
		linked_cam_console.network.Remove("landing zones")


/////////////////////////////////// COMPUTERS //////////////////////////////////////

//unfinished and unused
/obj/structure/dropship_equipment/adv_comp
	equip_category = DROPSHIP_COMPUTER
	point_cost = 0

	update_equipment()
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
	icon = 'icons/Marine/almayer_props64.dmi'
	equip_category = DROPSHIP_WEAPON
	bound_width = 32
	bound_height = 64
	uses_ammo = TRUE
	is_weapon = TRUE
	screen_mode = 1
	is_interactable = TRUE
	var/last_fired //used for weapon cooldown after use.
	var/firing_sound
	var/firing_delay = 20 //delay between firing. 2 seconds by default
	var/fire_mission_only = TRUE //whether the weapon can only be fire in fire mission mode.

	update_equipment()
		if(ship_base)
			dir = ship_base.dir
			bound_width = 32
			bound_height = 32
		else
			dir = initial(dir)
			bound_width = initial(bound_width)
			bound_height = initial(bound_height)
		update_icon()

	equipment_interact(mob/user)
		if(is_interactable)
			if(linked_console.selected_equipment == src)
				linked_console.selected_equipment = null
			else
				linked_console.selected_equipment = src

	examine(mob/user)
		..()
		if(ammo_equipped)
			ammo_equipped.show_loaded_desc(user)
		else
			user << "It's empty."



/obj/structure/dropship_equipment/weapon/proc/deplete_ammo()
	if(ammo_equipped)
		ammo_equipped.ammo_count = max(ammo_equipped.ammo_count-ammo_equipped.ammo_used_per_firing, 0)
	update_icon()

/obj/structure/dropship_equipment/weapon/proc/open_fire(obj/selected_target)
	set waitfor = 0
	var/turf/target_turf = get_turf(selected_target)
	if(firing_sound)
		playsound(loc, firing_sound, 70, 1)
	var/obj/structure/ship_ammo/SA = ammo_equipped //necessary because we nullify ammo_equipped when firing big rockets
	var/ammo_max_inaccuracy = SA.max_inaccuracy
	var/ammo_accuracy_range = SA.accuracy_range
	var/ammo_travelling_time = SA.travelling_time //how long the rockets/bullets take to reach the ground target.
	var/ammo_warn_sound = SA.warning_sound
	deplete_ammo()
	last_fired = world.time
	if(linked_shuttle)
		for(var/obj/structure/dropship_equipment/electronics/targeting_system/TS in linked_shuttle.equipments)
			ammo_accuracy_range = max(ammo_accuracy_range-2, 0) //targeting system increase accuracy and reduce travelling time.
			ammo_max_inaccuracy = max(ammo_max_inaccuracy -3, 1)
			ammo_travelling_time = max(ammo_travelling_time - 20, 10)
			break

	if(ammo_travelling_time)
		var/total_seconds = max(round(ammo_travelling_time/10),1)
		for(var/i = 0 to total_seconds)
			sleep(10)
			if(!selected_target || !selected_target.loc)//if laser disappeared before we reached the target,
				ammo_accuracy_range = min(ammo_accuracy_range + 1, ammo_max_inaccuracy) //accuracy decreases

	var/list/possible_turfs = list()
	for(var/turf/TU in range(ammo_accuracy_range, target_turf))
		possible_turfs += TU
	var/turf/impact = pick(possible_turfs)
	if(ammo_warn_sound)
		playsound(impact, ammo_warn_sound, 70, 1)
	new /obj/effect/overlay/temp/blinking_laser (impact)
	sleep(10)
	SA.detonate_on(impact)

/obj/structure/dropship_equipment/weapon/heavygun
	name = "\improper GAU-21 30mm cannon"
	desc = "A dismounted GAU-21 'Rattler' 30mm rotary cannon. It seems to be missing its feed links and has exposed connection wires. Capable of firing 5200 rounds a minute, feared by many for its power. Earned the nickname 'Rattler' from the vibrations it would cause on dropships in its inital production run."
	icon_state = "30mm_cannon"
	firing_sound = 'sound/effects/cannon30.ogg'
	point_cost = 400
	fire_mission_only = FALSE

	update_icon()
		if(ammo_equipped)
			icon_state = "30mm_cannon_loaded[ammo_equipped.ammo_count?"1":"0"]"
		else
			if(ship_base) icon_state = "30mm_cannon_installed"
			else icon_state = "30mm_cannon"


/obj/structure/dropship_equipment/weapon/rocket_pod
	name = "rocket pod"
	icon_state = "rocket_pod"
	desc = "A rocket pod weapon system capable of launching a single laser-guided rocket. Moving this will require some sort of lifter."
	firing_sound = 'sound/weapons/gun_flare_explode.ogg'
	firing_delay = 5
	point_cost = 600

	deplete_ammo()
		ammo_equipped = null //nothing left to empty after firing
		update_icon()

	update_icon()
		if(ammo_equipped && ammo_equipped.ammo_count)
			icon_state = "rocket_pod_loaded[ammo_equipped.ammo_id]"
		else
			if(ship_base) icon_state = "rocket_pod_installed"
			else icon_state = "rocket_pod"


/obj/structure/dropship_equipment/weapon/minirocket_pod
	name = "minirocket pod"
	icon_state = "minirocket_pod"
	desc = "A mini rocket pod capable of launching six laser-guided mini rockets. Moving this will require some sort of lifter."
	icon = 'icons/Marine/almayer_props64.dmi'
	firing_sound = 'sound/weapons/gun_flare_explode.ogg'
	firing_delay = 10 //1 seconds
	point_cost = 600

	update_icon()
		if(ammo_equipped && ammo_equipped.ammo_count)
			icon_state = "minirocket_pod_loaded"
		else
			if(ship_base) icon_state = "minirocket_pod_installed"
			else icon_state = "minirocket_pod"

	deplete_ammo()
		..()
		if(ammo_equipped && !ammo_equipped.ammo_count) //fired last minirocket
			ammo_equipped = null

/obj/structure/dropship_equipment/weapon/laser_beam_gun
	name = "laser beam gun"
	icon_state = "laser_beam"
	desc = "State of the art technology recently acquired by the USCM, it fires a battery-fed pulsed laser beam at near lightspeed setting on fire everything it touches. Moving this will require some sort of lifter."
	icon = 'icons/Marine/almayer_props64.dmi'
	firing_sound = 'sound/effects/phasein.ogg'
	firing_delay = 50 //5 seconds
	point_cost = 500
	fire_mission_only = FALSE

	update_icon()
		if(ammo_equipped && ammo_equipped.ammo_count)
			icon_state = "laser_beam_loaded"
		else
			if(ship_base) icon_state = "laser_beam_installed"
			else icon_state = "laser_beam"


/*TBD
/obj/structure/dropship_equipment/weapon/launch_bay
	name = "launch bay"
	icon_state = "launch_bay"
	desc = "A launch bay to drop special ordnance. Fits inside the dropship's crew weapon emplacement. Moving this will require some sort of lifter."
	icon = 'icons/Marine/almayer_props.dmi'
	firing_sound = 'sound/weapons/gun_flare_explode.ogg'
	firing_delay = 10 //1 seconds
	equip_category = DROPSHIP_CREW_WEAPON //fits inside the central spot of the dropship
	point_cost = 0

	update_icon()
		if(ammo_equipped && ammo_equipped.ammo_count)
			icon_state = "launch_bay_loaded"
		else
			if(ship_base) icon_state = "launch_bay"
			else icon_state = "launch_bay"
*/



//////////////// OTHER EQUIPMENT /////////////////



/obj/structure/dropship_equipment/medevac_system
	name = "medevac system"
	desc = "A winch system to lift injured marines on medical stretchers onto the dropship. Acquire lift target through the dropship equipment console."
	equip_category = DROPSHIP_CREW_WEAPON
	icon_state = "medevac_system"
	point_cost = 500
	is_interactable = TRUE
	var/obj/structure/bed/medevac_stretcher/linked_stretcher
	var/medevac_cooldown
	var/busy_winch

/obj/structure/dropship_equipment/medevac_system/Dispose()
	if(linked_stretcher)
		linked_stretcher.linked_medevac = null
		linked_stretcher = null
	. = ..()

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

	if(linked_shuttle.moving_status != SHUTTLE_INTRANSIT)
		user << "<span class='warning'>[src] can only be used while in flight.</span>"
		return

	if(!linked_shuttle.transit_gun_mission)
		user << "<span class='warning'>[src] requires a flyby flight to be used.</span>"
		return

	if(busy_winch)
		user << "<span class='warning'> The winch is already in motion.</span>"
		return

	if(world.time < medevac_cooldown)
		user << "<span class='warning'>[src] was just used, you need to wait a bit before using it again.</span>"
		return

	var/list/possible_stretchers = list()
	for(var/obj/structure/bed/medevac_stretcher/MS in activated_medevac_stretchers)
		var/area/AR = get_area(MS)
		var/evaccee
		if(MS.buckled_mob)
			evaccee = MS.buckled_mob.real_name
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
		user << "<span class='warning'>No active medevac stretcher detected.</span>"
		return

	var/stretcher_choice = input("Which emitting stretcher would you like to link with?", "Available stretchers") as null|anything in possible_stretchers
	if(!stretcher_choice)
		return

	var/obj/structure/bed/medevac_stretcher/selected_stretcher = possible_stretchers[stretcher_choice]
	if(!selected_stretcher)
		return

	if(!ship_base) //system was uninstalled midway
		return

	if(!selected_stretcher.stretcher_activated)//stretcher beacon was deactivated midway
		return

	if(selected_stretcher.z != 1) //in case the stretcher was on a groundside dropship that flew away during our input()
		return

	if(!selected_stretcher.buckled_mob && !selected_stretcher.buckled_bodybag)
		user << "<span class='warning'>This medevac stretcher is empty.</span>"
		return

	if(selected_stretcher.linked_medevac && selected_stretcher.linked_medevac != src)
		user << "<span class='warning'>There's another dropship hovering over that medevac stretcher.</span>"
		return

	if(!linked_shuttle)
		return

	if(linked_shuttle.moving_status != SHUTTLE_INTRANSIT)
		user << "<span class='warning'>[src] can only be used while in flight.</span>"
		return

	if(!linked_shuttle.transit_gun_mission)
		user << "<span class='warning'>[src] requires a flyby flight to be used.</span>"
		return

	if(busy_winch)
		user << "<span class='warning'> The winch is already in motion.</span>"
		return

	if(world.time < medevac_cooldown)
		user << "<span class='warning'>[src] was just used, you need to wait a bit before using it again.</span>"
		return

	if(selected_stretcher == linked_stretcher) //already linked to us, unlink it
		user << "<span class='notice'> You move your dropship away from that stretcher's beacon.</span>"
		linked_stretcher.visible_message("<span class='notice'>[linked_stretcher] detects a dropship is no longer overhead.</span>")
		linked_stretcher.linked_medevac = null
		linked_stretcher = null
		return

	user << "<span class='notice'> You move your dropship above the selected stretcher's beacon.</span>"

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


/obj/structure/dropship_equipment/medevac_system/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(!ship_base) //not installed
		return
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.pilot < SKILL_PILOT_TRAINED)
		user << "<span class='warning'> You don't know how to use [src].</span>"
		return

	if(!linked_shuttle)
		return

	if(linked_shuttle.moving_status != SHUTTLE_INTRANSIT)
		user << "<span class='warning'>[src] can only be used while in flight.</span>"
		return

	if(!linked_shuttle.transit_gun_mission)
		user << "<span class='warning'>[src] requires a flyby flight to be used.</span>"
		return

	if(busy_winch)
		user << "<span class='warning'> The winch is already in motion.</span>"
		return

	if(!linked_stretcher)
		user << "<span class='warning'>There seems to be no medevac stretcher connected to [src].</span>"
		return

	if(linked_stretcher.z != 1)
		linked_stretcher.linked_medevac = null
		linked_stretcher = null
		user << "<span class='warning'> There seems to be no medevac stretcher connected to [src].</span>"
		return

	if(world.time < medevac_cooldown)
		user << "<span class='warning'>[src] was just used, you need to wait a bit before using it again.</span>"
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
	sleep(30)

	busy_winch = FALSE
	var/fail
	if(!linked_stretcher || linked_stretcher != old_stretcher || linked_stretcher.z != 1)
		fail = TRUE

	else if(!ship_base) //uninstalled midway
		fail = TRUE

	else if(!linked_shuttle || linked_shuttle.moving_status != SHUTTLE_INTRANSIT || !linked_shuttle.transit_gun_mission)
		fail = TRUE

	if(fail)
		if(linked_stretcher)
			linked_stretcher.linked_medevac = null
			linked_stretcher = null
		user << "<span class='warning'>The winch finishes lifting but there seems to be no medevac stretchers connected to [src].</span>"
		return

	var/atom/movable/lifted_object
	if(linked_stretcher.buckled_mob)
		lifted_object = linked_stretcher.buckled_mob
	else if(linked_stretcher.buckled_bodybag)
		lifted_object = linked_stretcher.buckled_bodybag

	if(lifted_object)
		var/turf/T = get_turf(lifted_object)
		T.ceiling_debris_check(2)
		lifted_object.forceMove(loc)
	else
		user << "<span class='warning'>The winch finishes lifting the medevac stretcher but it's empty!</span>"
		linked_stretcher.linked_medevac = null
		linked_stretcher = null
		return

	flick("winched_stretcher", linked_stretcher)
	linked_stretcher.visible_message("<span class='notice'>A winch hook falls from the sky and starts lifting [linked_stretcher] up.</span>")

	medevac_cooldown = world.time + 600
	linked_stretcher.linked_medevac = null
	linked_stretcher = null
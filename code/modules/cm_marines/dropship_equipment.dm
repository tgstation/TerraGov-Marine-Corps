
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
	var/base_open = TRUE //whether the base is open and ready to accept equipment.
	var/openable_base = FALSE //can this base be open and closed

	Dispose()
		if(installed_equipment)
			cdel(installed_equipment)
			installed_equipment = null
		. = ..()

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/weapon/powerloader_clamp))
			var/obj/item/weapon/powerloader_clamp/PC = I
			if(istype(PC.loaded, /obj/structure/dropship_equipment))
				var/obj/structure/dropship_equipment/SE = PC.loaded
				if(SE.equip_category != base_category)
					user << "<span class='warning'>[SE] doesn't fit on [src].</span>"
					return TRUE
				if(!base_open)
					user << "<span class='warning'>You must open [src] first.</span>"
					return TRUE
				if(installed_equipment) return TRUE
				playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
				if(!do_after(user, 70, FALSE, 5, BUSY_ICON_CLOCK)) return TRUE
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
			else if(!PC.loaded && openable_base)
				var/old_open = base_open
				playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
				if(!do_after(user, 20, FALSE, 5, BUSY_ICON_CLOCK) && old_open == base_open) return TRUE
				playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
				base_open = !base_open
				if(base_open)
					icon_state = "[initial(icon_state)]_open"
					user << "<span class='notice'>You open [src].</span>"
					if(installed_equipment)
						installed_equipment.loc = loc
				else
					icon_state = "[initial(icon_state)]"
					user << "<span class='notice'>You close [src].</span>"
					if(installed_equipment)
						installed_equipment.loc = src
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
	name = "crew served weapon attach point"
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
	base_open = FALSE
	openable_base = TRUE

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





//Actual dropship equipments

/obj/structure/dropship_equipment
	density = TRUE
	anchored = TRUE
	icon = 'icons/Marine/almayer_props.dmi'
	var/equip_category //on what kind of base this can be installed.
	var/obj/effect/attach_point/ship_base //the ship base the equipment is currently installed on.
	var/uses_ammo = FALSE //whether it uses ammo
	var/obj/structure/ship_ammo/ammo_equipped //the ammo currently equipped.
	var/is_weapon = FALSE //whether the equipment is a weapon usable for dropship bombardment.
	var/obj/machinery/computer/shuttle_control/linked_console //the console of the dropship we're installed on.
	var/is_interactable = FALSE //whether they get a button when shown on the shuttle console's equipment list.
	var/datum/shuttle/ferry/marine/linked_shuttle
	var/screen_mode = 0 //used by the dropship console code when this equipment is selected

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

		if(istype(I, /obj/item/weapon/powerloader_clamp))
			var/obj/item/weapon/powerloader_clamp/PC = I
			if(PC.loaded)
				if(ship_base && uses_ammo && !ammo_equipped && istype(PC.loaded, /obj/structure/ship_ammo))
					var/obj/structure/ship_ammo/SA = PC.loaded
					if(SA.equipment_type == type)
						playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
						if(do_after(user, 30, FALSE, 5, BUSY_ICON_CLOCK))
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
				if(do_after(user, 30, FALSE, 5, BUSY_ICON_CLOCK))
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
				if(do_after(user, duration_time, FALSE, 5, BUSY_ICON_CLOCK))
					if(PC.linked_powerloader && PC.linked_powerloader.buckled_mob == user)
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

//things to do when the shuttle this equipment is attached to lands.
/obj/structure/dropship_equipment/proc/on_arrival()
	return

/obj/structure/dropship_equipment/proc/equipment_interact(mob/user)
	if(is_interactable)
		if(linked_console.selected_equipment) return
		linked_console.selected_equipment = src
		user << "<span class='notice'>You select [src].</span>"

//returns the camera linked to that equipment
/obj/structure/dropship_equipment/proc/get_camera()
	return

/obj/structure/dropship_equipment/proc/can_use_camera()
	return


//////////////////////////////////// turret holders //////////////////////////////////////

/obj/structure/dropship_equipment/sentry_holder
	equip_category = DROPSHIP_WEAPON
	name = "sentry deployment system"
	desc = "A box that deploys a sentry turret. Fits on the weapon attach points of dropships. You need a powerloader to lift it."
	icon_state = "sentry_system"
	is_interactable = TRUE
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
				if(z == ADMIN_Z_LEVEL)
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
				switch(dir)
					if(SOUTH) deployed_turret.pixel_y = 16
					if(NORTH) deployed_turret.pixel_y = -16
					if(EAST) deployed_turret.pixel_x = -16
					if(WEST) deployed_turret.pixel_x = 16
		else
			dir = initial(dir)
			if(deployed_turret)
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

/obj/structure/dropship_equipment/fuel/cooling_system
	name = "cooling system"
	desc = "A cooling system for dropships. It produces additional cooling reducing delays between launch. Fits inside the engine attach points. You need a powerloader to lift it."
	icon_state = "cooling_system"



///////////////////////////////////// ELECTRONICS /////////////////////////////////////////

/obj/structure/dropship_equipment/electronics
	equip_category = DROPSHIP_ELECTRONICS

/obj/structure/dropship_equipment/electronics/lantern_pod
	name = "lantern pod"
	icon_state = "lantern_pod"
	is_interactable = TRUE

	can_use_camera()
		if(linked_shuttle && linked_shuttle.moving_status == SHUTTLE_INTRANSIT)
			return TRUE

//	get_camera()
//		if(linked_shuttle)
//			return pick(linked_shuttle.locs_dock)


/obj/structure/dropship_equipment/electronics/chaff_launcher
	name = "chaff launcher"
	icon_state = "chaff_launcher"


#define LIGHTING_MAX_LUMINOSITY_SHIPLIGHTS 12

/obj/structure/dropship_equipment/electronics/spotlights
	name = "spotlight"
	icon_state = "spotlights"
	desc = "A set of highpowered spotlights to illuminate large areas. Fits on electronics attach points of dropships. Moving this will require a powerloader."
	is_interactable = TRUE
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

/obj/structure/dropship_equipment/electronics/targeting_system
	name = "targeting system"
	icon_state = "targeting_system"
	desc = "A targeting system for dropships. It improves firing accuracy on laser targets. Fits on electronics attach points. You need a powerloader to lift this."

	update_equipment()
		if(ship_base)
			icon_state = "[initial(icon_state)]_installed"
		else
			icon_state = initial(icon_state)


/////////////////////////////////// COMPUTERS //////////////////////////////////////

/obj/structure/dropship_equipment/adv_comp
	equip_category = DROPSHIP_COMPUTER

	update_equipment()
		if(ship_base)
			icon_state = "[initial(icon_state)]_installed"
		else
			icon_state = initial(icon_state)

/obj/structure/dropship_equipment/adv_comp/advanced_camera
	name = "advanced camera computer"
	icon_state = "advanced_camera"
	is_interactable = TRUE
	var/obj/machinery/camera/adv_dropship_camera/linked_cam

	initialize()
		if(!linked_cam) linked_cam = new(src)
		..()

	New()
		if(!linked_cam) linked_cam = new(src)
		..()

	update_equipment()
		if(ship_base)
			icon_state = "[initial(icon_state)]_installed"
			if(linked_cam)
				linked_cam.loc = loc
		else
			icon_state = initial(icon_state)
			if(linked_cam)
				linked_cam.loc = src

	can_use_camera()
		if(linked_shuttle && linked_shuttle.moving_status != SHUTTLE_INTRANSIT)
			return TRUE

	get_camera()
		return linked_cam


/obj/structure/dropship_equipment/adv_comp/docking
	name = "docking computer"
	icon_state = "docking_comp"


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
	var/is_busy = FALSE //used for weapon cooldown after use.
	var/firing_sound
	var/ammo_used_per_firing = 1
	var/firing_delay = 20 //delay between firing. 2 seconds by default

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
		ammo_equipped.ammo_count = max(ammo_equipped.ammo_count-ammo_used_per_firing, 0)
	update_icon()

/obj/structure/dropship_equipment/weapon/proc/open_fire(obj/selected_target)
	set waitfor = 0
	var/turf/target_turf = get_turf(selected_target)
	if(firing_sound)
		playsound(loc, firing_sound, 70, 1)
	var/obj/structure/ship_ammo/SA = ammo_equipped //necessary because we nullify ammo_equipped when firing big rockets
	deplete_ammo()
	is_busy = TRUE
	sleep(firing_delay)
	is_busy = FALSE
	var/accuracy_range = 3
	var/ammo_travelling_time = SA.travelling_time //how long the rockets/bullets take to reach the ground target.
	if(linked_shuttle)
		for(var/obj/structure/dropship_equipment/electronics/targeting_system/TS in linked_shuttle.equipments)
			accuracy_range = max(accuracy_range-2, 1) //targeting system increase accuracy and reduce travelling time.
			ammo_travelling_time = max(ammo_travelling_time - 20, 60)
	sleep(ammo_travelling_time)
	if(!selected_target || !selected_target.loc)//if laser disappeared before we reached the target,
		if(prob(accuracy_range*20)) //default is 60% chance the rocket completely misses the target and disappears
			return
		accuracy_range += 3
	var/list/possible_turfs = list()
	for(var/turf/TU in range(accuracy_range, target_turf))
		possible_turfs += TU
	var/turf/impact = pick(possible_turfs)
	SA.detonate_on(impact)

/obj/structure/dropship_equipment/weapon/heavygun
	name = "\improper GAU-21 30mm cannon"
	desc = "A dismounted GAU-21 'Rattler' 30mm rotary cannon. It seems to be missing its feed links and has exposed connection wires. Capable of firing 5200 rounds a minute, feared by many for its power. Earned the nickname 'Rattler' from the vibrations it would cause on dropships in its inital production run."
	icon_state = "30mm_cannon"
	firing_sound = 'sound/effects/cannon30.ogg'
	ammo_used_per_firing = 20

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

//////////////////////////////////// dropship weapon ammunition ////////////////////////////

/obj/structure/ship_ammo
	icon = 'icons/Marine/almayer_props.dmi'
	density = TRUE
	anchored = TRUE
	throwpass = TRUE
	climbable = TRUE
	var/travelling_time = 100 //time to impact
	var/equipment_type //type of equipment that accept this type of ammo.
	var/ammo_count
	var/max_ammo_count
	var/ammo_name = "round"
	var/ammo_id
	var/transferable_ammo = FALSE //whether the ammo inside this magazine can be transfered to another magazine.

	attackby(obj/item/I, mob/user)

		if(istype(I, /obj/item/weapon/powerloader_clamp))
			var/obj/item/weapon/powerloader_clamp/PC = I
			if(PC.linked_powerloader)
				if(PC.loaded)
					if(istype(PC.loaded, /obj/structure/ship_ammo))
						var/obj/structure/ship_ammo/SA = PC.loaded
						if(SA.transferable_ammo && SA.ammo_count > 0 && SA.type == type)
							if(ammo_count < max_ammo_count)
								var/transf_amt = min(max_ammo_count - ammo_count, SA.ammo_count)
								ammo_count += transf_amt
								SA.ammo_count -= transf_amt
								playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
								user << "<span class='notice'>You transfer [transf_amt] [ammo_name] to [src].</span>"
								if(!SA.ammo_count)
									PC.loaded = null
									PC.update_icon()
									cdel(SA)
				else
					forceMove(PC.linked_powerloader)
					PC.loaded = src
					playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
					PC.update_icon()
					user << "<span class='notice'>You grab [PC.loaded] with [PC].</span>"
					update_icon()
			return TRUE
		. = ..()

//what to show to the user that examines the weapon we're loaded on.
/obj/structure/ship_ammo/proc/show_loaded_desc(mob/user)
	user << "It's loaded with \a [src]."
	return

/obj/structure/ship_ammo/proc/detonate_on(turf/impact)
	return

/obj/structure/ship_ammo/heavygun
	name = "\improper 30mm ammo crate"
	icon_state = "30mm_crate"
	desc = "A crate full of 30mm bullets used on the dropship heavy guns. Moving this will require some sort of lifter."
	equipment_type = /obj/structure/dropship_equipment/weapon/heavygun
	ammo_count = 200
	max_ammo_count = 200
	transferable_ammo = TRUE

	examine(mob/user)
		..()
		user << "It has [ammo_count] round\s."

	show_loaded_desc(mob/user)
		if(ammo_count)
			user << "It's loaded with \a [src] containing [ammo_count] round\s."
		else
			user << "It's loaded with an empty [name]."

	detonate_on(turf/impact)
		set waitfor = 0
		var/list/turf_list = list()
		for(var/turf/T in range(impact, 4))
			turf_list += T
		var/soundplaycooldown = 0
		for(var/i=1, i<=20, i++)
			var/turf/U = pick(turf_list)
			turf_list -= U
			sleep(1)
			U.ex_act(3)
			for(var/atom/movable/AM in U)
				AM.ex_act(3)
			if(!soundplaycooldown) //so we don't play the same sound 20 times very fast.
				playsound(impact, get_sfx("explosion"), 40, 1, 20, falloff = 3)
				soundplaycooldown = 3
			soundplaycooldown--
			new /obj/effect/particle_effect/expl_particles(U)

/obj/structure/ship_ammo/rocket
	name = "abstract rocket"
	icon_state = "single"
	icon = 'icons/Marine/almayer_props64.dmi'
	equipment_type = /obj/structure/dropship_equipment/weapon/rocket_pod
	ammo_count = 1
	max_ammo_count = 1
	ammo_name = "rocket"
	ammo_id = ""
	bound_width = 64
	bound_height = 32
	travelling_time = 60 //faster than 30mm rounds

	detonate_on(turf/impact)
		explosion(impact,1,3,5)
		cdel(src)


//this one is air-to-air only
/obj/structure/ship_ammo/rocket/widowmaker
	name = "\improper AIM-224 'Widowmaker'"
	desc = "The AIM-224 is the latest in air to air missile technology. Earning the nickname of 'Widowmaker' from various dropship pilots after improvements to its guidence warhead prevents it from being jammed leading to its high kill rate. Not well suited for ground bombardment, but its high velocity makes it reach its target quickly. Moving this will require some sort of lifter."
	icon_state = "single"
	travelling_time = 35 //not powerful, but reaches target fast
	ammo_id = ""

/obj/structure/ship_ammo/rocket/banshee
	name = "\improper AGM-227 'Banshee'"
	desc = "The AGM-227 missile is a mainstay of the overhauled dropship fleet against any mobile or armored ground targets. It's earned the nickname of 'Banshee' from the sudden wail that it emitts right before hitting a target. Useful to clear out large areas. Moving this will require some sort of lifter."
	icon_state = "banshee"
	ammo_id = "b"

	detonate_on(turf/impact)
		explosion(impact,1,3,6,6,1,0,7) //more spread out, with flames
		cdel(src)

/obj/structure/ship_ammo/rocket/keeper
	name = "\improper GBU-67 'Keeper II'"
	desc = "The GBU-67 'Keeper II' is the latest in a generation of laser guided weaponry that spans all the way back to the 20th century. Earning its nickname from a shortening of 'Peacekeeper' which comes from the program that developed its guidance system and the various uses of it during peacekeeping conflicts. Its payload is designed to devastate armored targets. Moving this will require some sort of lifter."
	icon_state = "paveway"
	ammo_id = "k"

	detonate_on(turf/impact)
		explosion(impact,3,4,4,6) //tighter blast radius, but more devastating near center
		cdel(src)


/obj/structure/ship_ammo/minirocket
	name = "mini rocket stack"
	desc = "A pack of laser guided mini rockets. Moving this will require some sort of lifter."
	icon_state = "minirocket"
	icon = 'icons/Marine/almayer_props.dmi'
	equipment_type = /obj/structure/dropship_equipment/weapon/minirocket_pod
	ammo_count = 6
	max_ammo_count = 6
	ammo_name = "minirocket"
	travelling_time = 80 //faster than 30mm cannon, slower than real rockets
	transferable_ammo = TRUE

	detonate_on(turf/impact)
		explosion(impact,-1,1,3, 5, 0)//no messaging admin, that'd spam them.
		var/datum/effect_system/expl_particles/P = new/datum/effect_system/expl_particles()
		P.set_up(4, 0, impact)
		P.start()
		spawn(5)
			var/datum/effect_system/smoke_spread/S = new/datum/effect_system/smoke_spread()
			S.set_up(1,0,impact,null)
			S.start()
		if(!ammo_count && loc)
			cdel(src) //deleted after last minirocket is fired and impact the ground.

	show_loaded_desc(mob/user)
		if(ammo_count)
			user << "It's loaded with \a [src] containing [ammo_count] minirocket\s."

	examine(mob/user)
		..()
		user << "It has [ammo_count] minirocket\s."
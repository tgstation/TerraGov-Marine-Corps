/obj/structure/caspart/caschair/som
	name = "\improper Manta Jet pilot seat"
	icon = 'icons/obj/structures/prop/somship.dmi'
	icon_state = "somcas_cockpit"
	dir = 1
	layer = ABOVE_MOB_LAYER
	faction = FACTION_SOM
	home_dock = SHUTTLE_CAS_DOCK_SOM

///Handles updating the cockpit overlay
/obj/structure/caspart/caschair/som/set_cockpit_overlay(new_state)
	cut_overlays()
	cockpit = image('icons/obj/structures/prop/somship.dmi', src, new_state)
	cockpit.pixel_x = 0
	cockpit.pixel_y = 0
	cockpit.layer = ABOVE_ALL_MOB_LAYER
	add_overlay(cockpit)

/area/shuttle/som_cas
	name = "Manta Jet"

/datum/map_template/shuttle/cas/som
	shuttle_id = SHUTTLE_CAS_SOM
	name = "SOM Condor Jet"

/obj/docking_port/stationary/marine_dropship/cas/som
	name = "SOM CAS plane hangar pad"
	id = SHUTTLE_CAS_DOCK_SOM
	roundstart_template = /datum/map_template/shuttle/cas/som
	//fuckass thing wont work
	dwidth = 4
	dheight = 6
	width = 9
	height = 12

/obj/docking_port/mobile/marine_dropship/casplane/som
	name = "SOM Manta Jet"
	id = SHUTTLE_CAS_DOCK_SOM
	faction = FACTION_SOM
	dwidth = 5
	dheight = 7
	width = 8
	height = 11

/obj/docking_port/mobile/marine_dropship/casplane/som/process()
	#ifndef TESTING
	fuel_left--
	if((fuel_max*LOW_FUEL_WARNING_THRESHOLD) == fuel_left)
		chair.occupant?.playsound_local(loc, 'sound/voice/plane_vws/low_fuel.ogg', 70, FALSE)
	if((fuel_left <= LOW_FUEL_LANDING_THRESHOLD) && (state == PLANE_STATE_FLYING))
		to_chat(chair.occupant, span_warning("Out of fuel, landing."))
		chair.occupant?.playsound_local(loc, 'sound/voice/plane_vws/no_fuel.ogg', 70, FALSE)
		SSshuttle.moveShuttle(id, SHUTTLE_CAS_DOCK_SOM, TRUE)
		currently_returning = TRUE
		end_cas_mission(chair.occupant)
	if(fuel_left <= 0)
		fuel_left = 0
		turn_off_engines()
	#endif

/mob/camera/aiEye/remote/hud/som
	faction = FACTION_SOM
	hud_possible = list(SQUAD_HUD_SOM)

//desperateness
/mob/camera/aiEye/remote/hud/som/Initialize(mapload, cameranet, new_faction)
	parent_cameranet = GLOB.som_cameranet
	cameranet = GLOB.som_cameranet
	new_faction = FACTION_SOM
	. = ..()

//had to make som version here cuz lazy
//Marine-only visuals. Prediction HUD, etc. Does not show without marine headset
/obj/effect/overlay/blinking_laser/som
	name = "prediction matrix"
	icon = 'icons/effects/lases.dmi'
	icon_state = "nothing"
	var/icon_state_on = "nothing"
	hud_possible = list(SQUAD_HUD_SOM)

/obj/effect/overlay/blinking_laser/som/Initialize(mapload)
	. = ..()
	notify_ai_hazard()
	prepare_huds()
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[DATA_HUD_SQUAD_SOM]
	squad_hud.add_to_hud(src)
	set_visuals()

/obj/effect/overlay/blinking_laser/som/proc/set_visuals()
	var/image/new_hud_list = hud_list[SQUAD_HUD_SOM]
	if(!new_hud_list)
		return

	new_hud_list.icon = 'icons/effects/lases.dmi'
	new_hud_list.icon_state = icon_state_on
	hud_list[SQUAD_HUD_SOM] = new_hud_list

//Prediction lines. Those horizontal blue lines you see when CAS fires something
/obj/effect/overlay/blinking_laser/som/lines
	layer = WALL_OBJ_LAYER //Above walls/items, not above mobs
	icon_state_on = "middle"

/obj/effect/overlay/blinking_laser/som/lines/Initialize(mapload)
	. = ..()
	dir = pick(CARDINAL_DIRS) //Randomises type, for variation

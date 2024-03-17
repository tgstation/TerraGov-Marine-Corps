//effects are placed on maps but only generate objectives for applicable missions, so maps can be valid for multiple missions if desired.
/obj/effect/landmark/campaign_structure
	name = "GENERIC CAMPAIGN STRUCTURE"
	desc = "THIS SHOULDN'T BE VISIBLE"
	icon = 'icons/obj/structures/campaign_structures.dmi'
	///Missions that trigger this landmark to spawn an objective
	var/list/mission_types
	///Campaign structure spawned by this landmark
	var/obj/spawn_object

/obj/effect/landmark/campaign_structure/Initialize(mapload)
	. = ..()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	if(!istype(mode))
		return
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(current_mission.type in mission_types)
		var/obj/objective = new spawn_object(loc)
		objective.dir = dir
	qdel(src)


/obj/structure/campaign_objective
	name = "GENERIC CAMPAIGN STRUCTURE"
	desc = "THIS SHOULDN'T BE VISIBLE"
	density = TRUE
	anchored = TRUE
	allow_pass_flags = PASSABLE
	destroy_sound = 'sound/effects/meteorimpact.ogg'

	icon = 'icons/obj/structures/campaign_structures.dmi'

/obj/structure/campaign_objective/Initialize(mapload)
	. = ..()
	GLOB.campaign_objectives += src
	update_icon()

/obj/structure/campaign_objective/Destroy()
	disable()
	return ..()

/obj/structure/campaign_objective/update_icon()
	. = ..()
	update_control_minimap_icon()

/obj/structure/campaign_objective/ex_act()
	return

///Handles the objective being destroyed, disabled or otherwise completed
/obj/structure/campaign_objective/proc/disable()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_OBJECTIVE_DESTROYED, src)
	GLOB.campaign_objectives -= src
	SSminimaps.remove_marker(src)

///Update the minimap blips to show who is controlling this objective
/obj/structure/campaign_objective/proc/update_control_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "campaign_objective"))

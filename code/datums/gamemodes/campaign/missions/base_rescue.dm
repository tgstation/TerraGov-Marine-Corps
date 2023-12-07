//protecting an NT installation
/datum/campaign_mission/destroy_mission/base_rescue
	name = "NT base rescue"
	mission_icon = "nt_rescue"
	mission_flags = MISSION_DISALLOW_TELEPORT
	map_name = "NT site B-403"
	map_file = '_maps/map_files/Campaign maps/nt_base/nt_base.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_SNOWSTORM = TRUE)
	map_light_colours = list(COLOR_MISSION_BLUE, COLOR_MISSION_BLUE, COLOR_MISSION_BLUE, COLOR_MISSION_BLUE)
	map_light_levels = list(225, 150, 100, 75)
	objectives_total = 1
	min_destruction_amount = 1
	shutter_open_delay = list(
		MISSION_STARTING_FACTION = 60 SECONDS,
		MISSION_HOSTILE_FACTION = 0,
	)
	victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(2, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(1, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 1),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 2),
	)
	attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(10, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(5, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 25),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 30),
	)
	objective_destruction_messages = list(
		"last" = list(
			MISSION_ATTACKING_FACTION = "Objective destroyed, outstanding work!",
			MISSION_DEFENDING_FACTION = "Objective destroyed, fallback, fallback!",
		),
	)

	starting_faction_additional_rewards = "NanoTrasen has offered a level of corporate assistance if their facility can be protected."
	hostile_faction_additional_rewards = "Improved relations with local militias will allow us to call on their assistance in the future."

/datum/campaign_mission/destroy_mission/base_rescue/load_mission()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_CODE, PROC_REF(override_code_received))

/datum/campaign_mission/destroy_mission/base_rescue/set_factions()
	attacking_faction = hostile_faction
	defending_faction = starting_faction

/datum/campaign_mission/destroy_mission/base_rescue/unregister_mission_signals()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_CODE)

/datum/campaign_mission/destroy_mission/base_rescue/play_start_intro()
	intro_message = list(
		MISSION_STARTING_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Protect all the NT base from SOM aggression until reinforcements arrive. Eliminate all SOM forces and prevent them from overriding the security lockdown and raiding the facility.",
		MISSION_HOSTILE_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "The NT facility is on lockdown. Find a way to override the lockdown, then penetrate the facility and destroy whatever you find inside.",
	)
	return ..()

/datum/campaign_mission/destroy_mission/base_rescue/load_pre_mission_bonuses()
	. = ..()
	for(var/i = 1 to objectives_total)
		new /obj/item/storage/box/explosive_mines(get_turf(pick(GLOB.campaign_reward_spawners[defending_faction])))

/datum/campaign_mission/destroy_mission/base_rescue/load_mission_brief()
	starting_faction_mission_brief = "NanoTrasen has issues an emergency request for assistance at an isolated medical facility located in the Western Ayolan Ranges. \
		SOM forces are rapidly approaching the facility, which is currently on emergency lockdown. \
		Move quickly prevent the SOM from lifting the lockdown and destroying the facility."
	hostile_faction_mission_brief = "Recon forces have led us to this secure Nanotrasen facility in the Western Ayolan Ranges. Sympathetic native elements suggest NT have been conducting secret research here to the detriment of the local ecosystem and human settlements. \
		Find the security override terminals to override the facility's emergency lockdown. \
		Once the lockdown is lifted, destroy what they're working on inside."

/datum/campaign_mission/destroy_mission/base_rescue/load_objective_description()
	starting_faction_objective_description = "Major Victory:Protect the NT base from SOM attack. Do not allow them to override the security lockdown and destroy NT's sensitive equipment"
	hostile_faction_objective_description = "Major Victory: Override the security lockdown on the NT facility and destroy whatever secrets they are working on"

/datum/campaign_mission/destroy_mission/base_rescue/apply_major_victory()
	. = ..()
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_asset(/datum/campaign_asset/bonus_job/pmc)
	winning_team.add_asset(/datum/campaign_asset/attrition_modifier/corporate_approval)

/datum/campaign_mission/destroy_mission/base_rescue/apply_minor_victory()
	. = ..()
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_asset(/datum/campaign_asset/bonus_job/pmc)

/datum/campaign_mission/destroy_mission/base_rescue/apply_minor_loss()
	. = ..()
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/datum/campaign_asset/bonus_job/colonial_militia)

/datum/campaign_mission/destroy_mission/base_rescue/apply_major_loss()
	. = ..()
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/datum/campaign_asset/bonus_job/colonial_militia)
	winning_team.add_asset(/datum/campaign_asset/attrition_modifier/local_approval)

///Alerts players that a code has been sent
/datum/campaign_mission/destroy_mission/base_rescue/proc/override_code_received(datum/source, color)
	SIGNAL_HANDLER
	var/message_to_play = "[color] override code confirmed. Lifting [color] lockdown protocols."
	map_text_broadcast(attacking_faction, message_to_play, "[color] override broadcast", /atom/movable/screen/text/screen_text/picture/potrait/unknown)
	map_text_broadcast(defending_faction, message_to_play, "[color] override broadcast", /atom/movable/screen/text/screen_text/picture/potrait/unknown)


/obj/effect/landmark/campaign_structure/weapon_x
	name = "weapon X spawner"
	icon = 'icons/obj/structures/campaign/tall_structures.dmi'
	icon_state = "nt_pod"
	mission_types = list(/datum/campaign_mission/destroy_mission/base_rescue)
	spawn_object = /obj/structure/weapon_x_pod

/obj/structure/weapon_x_pod
	name = "pod"
	desc = "A unadorned metal pod of some kind. Seems kind of ominous."
	icon = 'icons/obj/structures/campaign/tall_structures.dmi'
	icon_state = "nt_pod"
	density = TRUE
	anchored = TRUE
	resistance_flags = RESIST_ALL
	destroy_sound = 'sound/effects/meteorimpact.ogg'
	///Mob type to spawn
	var/mob_type = /mob/living/carbon/xenomorph/hunter/weapon_x
	///Actual mob occupant
	var/mob/living/occupant
	///Color code associated for signal purposes
	var/code_color = MISSION_CODE_BLUE

/obj/structure/weapon_x_pod/Initialize(mapload)
	. = ..()
	GLOB.campaign_structures += src
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_CODE, PROC_REF(attempt_open))
	occupant = new mob_type(src)

/obj/structure/weapon_x_pod/Destroy()
	GLOB.campaign_structures -= src
	if(occupant)
		QDEL_NULL(occupant)
	return ..()

/obj/structure/weapon_x_pod/update_icon_state()
	if(occupant)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_open"

/obj/structure/weapon_x_pod/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X != occupant)
		return
	release_occupant()

///Releases the occupant and tries to find a ghost
/obj/structure/weapon_x_pod/proc/attempt_open(source, color)
	if(color != code_color)
		return
	if(!occupant)
		return
	occupant.offer_mob()
	RegisterSignal(occupant, COMSIG_MOVABLE_MOVED, PROC_REF(release_occupant))
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_CODE)

///Releases the occupant and tries to find a ghost
/obj/structure/weapon_x_pod/proc/release_occupant()
	if(!occupant)
		return
	UnregisterSignal(occupant, COMSIG_MOVABLE_MOVED)
	occupant.forceMove(loc)
	if(!occupant.client)
		occupant.offer_mob()
	occupant = null
	update_icon()
	playsound(src, 'sound/effects/airhiss.ogg', 60, 1)

/obj/effect/landmark/campaign_structure/weapon_x/red
	spawn_object = /obj/structure/weapon_x_pod/red

/obj/structure/weapon_x_pod/red
	code_color = MISSION_CODE_RED

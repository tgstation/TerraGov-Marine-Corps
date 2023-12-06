//mech on mech violence
/datum/campaign_mission/tdm/mech_wars
	name = "Mech war"
	mission_icon = "mech_war"
	map_name = "Patrick's Rest"
	map_file = '_maps/map_files/Campaign maps/patricks_rest/patricks_rest.dmm'
	map_light_colours = list(COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED)
	map_traits = list(ZTRAIT_AWAY = TRUE)
	map_light_levels = list(225, 150, 100, 75)
	starting_faction_objective_description = "Major Victory: Wipe out all hostiles in the area of operation. Minor Victory: Eliminate more hostiles than you lose."
	hostile_faction_objective_description = "Major Victory: Wipe out all hostiles in the area of operation. Minor Victory: Eliminate more hostiles than you lose."
	mission_start_delay = 5 MINUTES //since there is actual mech prep time required
	starting_faction_additional_rewards = "Mechanised units will be allocated to your battalion for use in future missions."
	hostile_faction_additional_rewards = "Mechanised units will be allocated to your battalion for use in future missions."

/datum/campaign_mission/tdm/mech_wars/play_start_intro()
	intro_message = list(
		MISSION_STARTING_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [hostile_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
		MISSION_HOSTILE_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [starting_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
	)
	. = ..()

/datum/campaign_mission/tdm/mech_wars/load_mission_brief()
	. = ..()
	starting_faction_mission_brief = "[hostile_faction] mechanised forces have been identified staging in this region, in advance of a suspected strike against our lines. \
		A heavy mechanised force of our own has been authorised for deployment to crush their forces before they can strike. \
		Unleash the full power of our mechanised units and crush all enemy forces in the ao while preserving your own forces. Good hunting"
	hostile_faction_mission_brief = "A large [starting_faction] mechanised force has been detected enroute towards one of our staging points in this region. \
		Our mechanised forces here are vital to our future plans. The enemy assault has given us a unique opportunity to destroy a significant portion of their mechanised forces with a swift counter attack. \
		Eliminate all hostiles you come across while preserving your own forces. Good hunting."

/datum/campaign_mission/tdm/mech_wars/load_pre_mission_bonuses()
	var/mechs_to_spawn = round(length(GLOB.clients) * 0.2) + 1
	var/obj/effect/landmark/campaign/mech_spawner/spawner
	var/obj/vehicle/sealed/mecha/combat/greyscale/new_mech
	var/faction_list = list(starting_faction, hostile_faction)
	for(var/faction in faction_list)
		for(var/i=1 to mechs_to_spawn)
			spawner = pick(GLOB.campaign_mech_spawners[faction])
			new_mech = spawner.spawn_mech()
			GLOB.campaign_structures += new_mech
			RegisterSignal(new_mech, COMSIG_QDELETING, TYPE_PROC_REF(/datum/campaign_mission, remove_mission_object))

			//anti mech infantry weapons
			if(i % 2)
				if(faction == FACTION_SOM)
					new /obj/item/storage/holster/backholster/rpg/som/heat(get_turf(pick(GLOB.campaign_reward_spawners[faction])))
				else
					new /obj/item/storage/holster/backholster/rpg/heam(get_turf(pick(GLOB.campaign_reward_spawners[faction])))

/datum/campaign_mission/tdm/mech_wars/apply_major_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/heavy)
	winning_team.add_asset(/datum/campaign_asset/mech)

/datum/campaign_mission/tdm/mech_wars/apply_minor_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_asset(/datum/campaign_asset/mech)
	winning_team.add_asset(/datum/campaign_asset/mech/light)

/datum/campaign_mission/tdm/mech_wars/apply_draw()
	winning_faction = hostile_faction

/datum/campaign_mission/tdm/mech_wars/apply_minor_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/som)
	winning_team.add_asset(/datum/campaign_asset/mech/light/som)

/datum/campaign_mission/tdm/mech_wars/apply_major_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/heavy/som)
	winning_team.add_asset(/datum/campaign_asset/mech/som)

//mech spawn points
/obj/effect/landmark/campaign/mech_spawner
	name = "tgmc med mech spawner"
	icon_state = "mech"
	var/faction = FACTION_TERRAGOV
	var/list/colors = list(ARMOR_PALETTE_SPACE_CADET, ARMOR_PALETTE_GREYISH_TURQUOISE, VISOR_PALETTE_MAGENTA)
	var/obj/vehicle/sealed/mecha/combat/greyscale/mech_type = /obj/vehicle/sealed/mecha/combat/greyscale/assault/noskill

/obj/effect/landmark/campaign/mech_spawner/Initialize(mapload)
	. = ..()
	GLOB.campaign_mech_spawners[faction] += list(src)

/obj/effect/landmark/campaign/mech_spawner/Destroy()
	GLOB.campaign_mech_spawners[faction] -= src
	return ..()

/obj/effect/landmark/campaign/mech_spawner/proc/spawn_mech()
	var/obj/vehicle/sealed/mecha/combat/greyscale/new_mech = new mech_type(loc)
	for(var/i in new_mech.limbs)
		var/datum/mech_limb/limb = new_mech.limbs[i]
		limb.update_colors(arglist(colors))
	new_mech.update_icon()
	return new_mech

/obj/effect/landmark/campaign/mech_spawner/heavy
	name = "tgmc heavy mech spawner"
	icon_state = "mech_heavy"
	mech_type = /obj/vehicle/sealed/mecha/combat/greyscale/vanguard/noskill

/obj/effect/landmark/campaign/mech_spawner/light
	name = "tgmc light mech spawner"
	icon_state = "mech_light"
	mech_type = /obj/vehicle/sealed/mecha/combat/greyscale/recon/noskill

/obj/effect/landmark/campaign/mech_spawner/som
	name = "som med mech spawner"
	faction = FACTION_SOM
	colors = list(ARMOR_PALETTE_GINGER, ARMOR_PALETTE_BLACK, VISOR_PALETTE_SYNDIE_GREEN)

/obj/effect/landmark/campaign/mech_spawner/som/heavy
	name = "som heavy mech spawner"
	icon_state = "mech_heavy"
	mech_type = /obj/vehicle/sealed/mecha/combat/greyscale/vanguard/noskill

/obj/effect/landmark/campaign/mech_spawner/som/light
	name = "som light mech spawner"
	icon_state = "mech_light"
	mech_type = /obj/vehicle/sealed/mecha/combat/greyscale/recon/noskill

/datum/campaign_mission/tdm/mech_wars/som
	name = "Mech war"
	mission_icon = "mech_war"
	map_name = "Big Red"
	map_file = '_maps/map_files/BigRed_v2/BigRed_v2.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_SANDSTORM = TRUE)
	map_light_colours = list(COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED)
	map_light_levels = list(225, 150, 100, 75)

/datum/campaign_mission/tdm/mech_wars/som/apply_major_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/heavy/som)
	winning_team.add_asset(/datum/campaign_asset/mech/som)

/datum/campaign_mission/tdm/mech_wars/som/apply_minor_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/som)
	winning_team.add_asset(/datum/campaign_asset/mech/light/som)

/datum/campaign_mission/tdm/mech_wars/som/apply_minor_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/datum/campaign_asset/mech)
	winning_team.add_asset(/datum/campaign_asset/mech/light)

/datum/campaign_mission/tdm/mech_wars/som/apply_major_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/heavy)
	winning_team.add_asset(/datum/campaign_asset/mech)

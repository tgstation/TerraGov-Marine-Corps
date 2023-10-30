/datum/campaign_asset/strategic_reserves
	name = "Strategic Reserve"
	desc = "Emergency reserve forces"
	detailed_desc = "A strategic reserve force is activated to bolster your numbers, increasing your active attrition significantly. Additionally, the respawn delay for your team is reduced by 90 seconds. Can only be used when defending a mission, and only once per campaign."
	ui_icon = "reserve_force"
	uses = 1
	asset_flags = ASSET_ACTIVATED_EFFECT|ASSET_DISABLE_ON_MISSION_END|ASSET_DISALLOW_REPEAT_USE
	///How much the faction's respawn delay is modified by
	var/respawn_delay_mod = -90 SECONDS

/datum/campaign_asset/strategic_reserves/activation_checks()
	. = ..()
	if(.)
		return
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(current_mission.mission_state != MISSION_STATE_ACTIVE) //we specifically want ONLY the active state, not the new state
		to_chat(faction.faction_leader, span_warning("You cannot call in the strategic reserve before the mission starts!"))
		return TRUE
	if(current_mission.hostile_faction != faction.faction)
		to_chat(faction.faction_leader, span_warning("You can only call in the strategic reserve when defending!"))
		return TRUE

/datum/campaign_asset/strategic_reserves/activated_effect()
	faction.active_attrition_points += round(length(GLOB.clients) * 0.3)
	faction.respawn_delay_modifier += respawn_delay_mod

/datum/campaign_asset/strategic_reserves/deactivate()
	. = ..()
	faction.respawn_delay_modifier -= respawn_delay_mod

/datum/campaign_asset/tactical_reserves
	name = "Rapid reserves"
	desc = "Reserves are able to immediately deploy"
	detailed_desc = "Tactical reserves undergo emergency rapid mobilisation to bolster your forces. All currently dead players on your team can immediately respawn, if attrition is available."
	ui_icon = "respawn"
	uses = 1
	cost = 5

/datum/campaign_asset/tactical_reserves/activation_checks()
	. = ..()
	if(.)
		return
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(current_mission.mission_state != MISSION_STATE_ACTIVE) //we specifically want ONLY the active state, not the new state
		to_chat(faction.faction_leader, span_warning("You cannot call in tactical reserve before the mission starts!"))
		return TRUE

/datum/campaign_asset/tactical_reserves/activated_effect()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	for(var/mob/candidate AS in GLOB.player_list)
		if(candidate.faction != faction.faction)
			continue
		mode.player_death_times -= candidate.key
		to_chat(candidate, "<span class='warning'>Tactical reserves mobilised. You can now respawn immediately if possible.<spawn>")
		candidate.playsound_local(null, 'sound/ambience/votestart.ogg', 50)



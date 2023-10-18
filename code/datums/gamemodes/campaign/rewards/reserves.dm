/datum/campaign_asset/reserves
	name = "Strategic Reserve"
	desc = "Emergency reserve forces"
	detailed_desc = "A strategic reserve force is activated to bolster your numbers, increasing your active attrition significantly. Additionally, the respawn delay for your team is reduced by 90 seconds. Can only be used when defending a mission, and only once per campaign."
	ui_icon = "reserve_force"
	uses = 1
	asset_flags = ASSET_ACTIVATED_EFFECT|ASSET_DISABLE_ON_MISSION_END|ASSET_DISALLOW_REPEAT_USE
	///How much the faction's respawn delay is modified by
	var/respawn_delay_mod = -90 SECONDS

/datum/campaign_asset/reserves/activation_checks()
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

/datum/campaign_asset/reserves/activated_effect()
	faction.active_attrition_points += round(length(GLOB.clients) * 0.3)
	faction.respawn_delay_modifier += respawn_delay_mod

/datum/campaign_asset/reserves/deactivate()
	. = ..()
	faction.respawn_delay_modifier -= respawn_delay_mod

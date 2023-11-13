///Whether this asset has been completed used and has no further effect
#define ASSET_CONSUMED (1<<0)
///This asset must be explicitly activated
#define ASSET_ACTIVATED_EFFECT (1<<1)
///This asset is active as soon as it is won
#define ASSET_IMMEDIATE_EFFECT (1<<2)
///This asset has a passive effect
#define ASSET_PASSIVE_EFFECT (1<<3)
///Can't activate unless mission is starting or started
#define ASSET_ACTIVE_MISSION_ONLY (1<<4)
///Temporarily unusable
#define ASSET_DISABLED (1<<5)
///Currently active
#define ASSET_ACTIVE (1<<6)
///debuff, used for UI purposes
#define ASSET_DEBUFF (1<<7)
///SL's can activate this asset
#define ASSET_SL_AVAILABLE (1<<8)
///Can only use one per mission or until otherwise deactivated
#define ASSET_DISALLOW_REPEAT_USE (1<<9)
///Reward will be marked as 'active'and be disabled at the end of the mission
#define ASSET_DISABLE_ON_MISSION_END (1<<10)

/datum/campaign_asset
	///Name of this asset
	var/name = "Placeholder asset"
	///Basic description
	var/desc = "This is a asset. It's a placeholder"
	///Detailed description
	var/detailed_desc = "This is a placeholder asset. You shouldn't see this, it does nothing at all."
	///The faction associated with these stats
	var/datum/faction_stats/faction
	///asset related flags
	var/asset_flags = ASSET_ACTIVATED_EFFECT
	///Number of times this can be used
	var/uses = 1
	///Cost in attrition points if this asset is purchased
	var/cost = 1
	///Iconstate for UI
	var/ui_icon = "test"
	///Message if this asset is already active and can't be activated again
	var/already_active_message = "Asset already active."
	///Missions flags that prevent the use of this asset
	var/blacklist_mission_flags = NONE
	///Feedback message if this asset is unusable during this mission
	var/blacklist_message = "Unavailable during this mission."

/datum/campaign_asset/New(datum/faction_stats/winning_faction)
	. = ..()
	faction = winning_faction
	if(asset_flags & ASSET_IMMEDIATE_EFFECT)
		immediate_effect()
	if(asset_flags & ASSET_PASSIVE_EFFECT)
		passive_effect()

/datum/campaign_asset/Destroy(force, ...)
	faction = null
	return ..()

///Reapplies the asset, refreshing it or restoring uses
/datum/campaign_asset/proc/reapply()
	uses += initial(uses)
	asset_flags &= ~ASSET_CONSUMED
	if(asset_flags & ASSET_IMMEDIATE_EFFECT)
		immediate_effect()

///Handles the activated asset process
/datum/campaign_asset/proc/attempt_activatation(mob/user)
	if(activation_checks(user))
		return FALSE

	activated_effect()

	if(asset_flags & ASSET_DISABLE_ON_MISSION_END)
		asset_flags |= ASSET_ACTIVE
		RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, TYPE_PROC_REF(/datum/campaign_asset, deactivate), override = TRUE) //Some assets can be used multiple times per mission

	uses --
	if(uses <= 0)
		asset_flags |= ASSET_CONSUMED
	SEND_SIGNAL(src, COMSIG_CAMPAIGN_ASSET_ACTIVATION)
	return TRUE

///Returns TRUE if unable to be activated
/datum/campaign_asset/proc/activation_checks(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(!(asset_flags & ASSET_ACTIVATED_EFFECT))
		return TRUE
	if((asset_flags & ASSET_CONSUMED))
		to_chat(user, span_warning("This asset is inactive."))
		return TRUE
	if(uses <= 0)
		to_chat(user, span_warning("No further uses of this assets available."))
		return TRUE
	if(asset_flags & ASSET_DISABLED)
		to_chat(user, span_warning("External interferance prevents the activation of this asset."))
		return TRUE
	if((asset_flags & ASSET_DISALLOW_REPEAT_USE) && (asset_flags & ASSET_ACTIVE))
		to_chat(user, span_warning(already_active_message))
		return TRUE
	if(asset_flags & ASSET_ACTIVE_MISSION_ONLY)
		var/datum/game_mode/hvh/campaign/mode = SSticker.mode
		var/datum/campaign_mission/current_mission = mode.current_mission
		if(!current_mission || (current_mission.mission_state == MISSION_STATE_NEW) || (current_mission.mission_state == MISSION_STATE_FINISHED))
			to_chat(user, span_warning("Unavailable until next mission confirmed."))
			return TRUE
		if(blacklist_mission_flags & current_mission.mission_flags)
			to_chat(user, span_warning(blacklist_message))
			return TRUE

	return FALSE

///Triggers any active effects of this asset
/datum/campaign_asset/proc/activated_effect()
	return

///Triggers any immediate effects of this asset
/datum/campaign_asset/proc/immediate_effect() //Immediate effects can be applied repeatedly if the asset is reobtained
	return
///Triggers any passive effects of this asset
/datum/campaign_asset/proc/passive_effect() //Passive effects do not stack
	return

///Removes the passive effect of this asset
/datum/campaign_asset/proc/remove_passive_effect()
	return

///Deactivates the asset once the mission is over
/datum/campaign_asset/proc/deactivate()
	SIGNAL_HANDLER
	asset_flags &= ~ASSET_ACTIVE
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED)

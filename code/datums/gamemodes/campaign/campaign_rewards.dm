//specific rewards won during a campaign game

//todo: move to the actual define page
//campaign reward defines

///Whether this reward has been completed used and has no further effect
#define REWARD_CONSUMED (1<<0)
///This reward must be explicitly activated
#define REWARD_ACTIVATED_EFFECT (1<<1)
///This reward is active as soon as it is won
#define REWARD_IMMEDIATE_EFFECT (1<<2)
///This reward has a passive effect
#define REWARD_PASSIVE_EFFECT (1<<3)

/datum/campaign_reward
	///Name of this reward
	var/name = "Placeholder reward"
	///Basic description
	var/desc = "This is a reward. It's a placeholder"
	///Detailed description
	var/detailed_desc = "This is a placeholder reward. You shouldn't see this, it does nothing at all."
	///The faction associated with these stats
	var/datum/faction_stats/faction
	///reward related flags
	var/reward_flags = REWARD_ACTIVATED_EFFECT
	///Number of times this can be used
	var/uses = 1

/datum/campaign_reward/New(datum/faction_stats/winning_faction)
	. = ..()
	faction = winning_faction
	if(reward_flags & REWARD_IMMEDIATE_EFFECT)
		immediate_effect()
	if(reward_flags & REWARD_PASSIVE_EFFECT)
		passive_effect()

///Triggers any active effects of this reward
/datum/campaign_reward/proc/activated_effect() //this shit should be in come checker proc for sanity
	SHOULD_CALL_PARENT(TRUE)
	if((reward_flags & REWARD_CONSUMED) || uses <= 0)
		return FALSE

	uses --
	if(uses <= 0)
		reward_flags |= REWARD_CONSUMED
	return TRUE

///Triggers any immediate effects of this reward
/datum/campaign_reward/proc/immediate_effect()

///Triggers any passive effects of this reward
/datum/campaign_reward/proc/passive_effect()




/datum/campaign_reward/equipment
	///list of objects to spawn when this reward is activated
	var/list/obj/equipment_to_spawn = list()

/datum/campaign_reward/equipment/activated_effect()
	. = ..()
	if(!.)
		return

	var/turf/spawn_location = get_turf(faction.faction_leader)  //placeholder spawn location

	playsound(spawn_location,'sound/effects/phasein.ogg', 80, FALSE)

	for(var/obj/object AS in equipment_to_spawn)
		new object(spawn_location)

/datum/campaign_reward/equipment/power_armor
	name = "B18 consignment"
	desc = "Two sets of B18 power armor."
	detailed_desc = "Your battalion has been assigned two sets of B18 power armor, available at your request. B18 is TGMC's premier infantry armor, providing superior protection, mobility and an advanced automedical system."
	uses = 2
	equipment_to_spawn = list(
		/obj/item/clothing/head/helmet/marine/specialist,
		/obj/item/clothing/gloves/marine/specialist,
		/obj/item/clothing/suit/storage/marine/specialist,
	)

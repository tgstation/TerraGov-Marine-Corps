/**
 * Research subsystem.
 *
 * Handles research rewards management and progression.
 */

//Bucket names
#define RES_MONEY "money"

//Reward tiers
#define RES_TIER_BASIC "basic"
#define RES_TIER_COMMON "common"
#define RES_TIER_UNCOMMON "uncommon"
#define RES_TIER_RARE "rare"

SUBSYSTEM_DEF(research)
	name = "Research"
	init_order = INIT_ORDER_RESEARCH
	flags = SS_NO_FIRE

	///Research reward tiers and their base chances
	var/list/reward_tiers = list(
		RES_TIER_BASIC = 100,
		RES_TIER_COMMON = 30,
		RES_TIER_UNCOMMON = 20,
		RES_TIER_RARE = 5,
	)

	var/list/rewards = list(
		RES_MONEY = list(
			RES_TIER_BASIC = list(
				/obj/item/research_product/money/basic,
				/obj/item/research_product/money/common,
			),
			RES_TIER_COMMON = list(
				/obj/item/research_product/money/common,
				/obj/item/research_product/money/uncommon,
			),
			RES_TIER_UNCOMMON = list(
				/obj/item/research_product/money/uncommon,
			),
			RES_TIER_RARE = list(
				/obj/item/research_product/money/rare,
			),
		),
	)

/datum/controller/subsystem/research/proc/research_item(atom/rewards_position, obj/item/research_resource/resource, bucket)
	var/list/potential_rewards = rewards[bucket]
	var/list/earned_rewards = list()
	var/list/resource_mods = resource.reward_tier_mods

	for (var/tier in reward_tiers)
		var/tier_base_prob = reward_tiers[tier]
		var/prob_mod = resource_mods[tier]
		if (!prob(tier_base_prob + prob_mod))
			continue

		var/list/tier_rewards = potential_rewards[tier]
		//getting random item from the list of items at the tier
		var/item_typepath = tier_rewards[rand(1, tier_rewards.len)]
		var/obj/item = new item_typepath
		item.desc += "<br>Received from \"[bucket]\", tier [tier]"
		earned_rewards += item

	var/turf/drop_loc = get_turf(rewards_position)
	for (var/obj/item in earned_rewards)
		item.forceMove(drop_loc)

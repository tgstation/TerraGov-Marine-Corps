/**
 * Research subsystem.
 *
 * Handles research rewards management and progression.
 */

//Bucket names
#define RES_MONEY "money"
#define RES_XENO "xeno"

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
		RES_TIER_BASIC,
		RES_TIER_COMMON,
		RES_TIER_UNCOMMON,
		RES_TIER_RARE
		)

	///List of rewards for each category
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
				/obj/item/implanter/blade,
			),
			RES_TIER_RARE = list(
				/obj/item/research_product/money/rare,
			),
		),
		RES_XENO = list(
			RES_TIER_BASIC = list(
				/obj/item/research_product/money/basic,
				/obj/item/research_product/money/common,
			),
			RES_TIER_COMMON = list(
				/obj/item/research_product/money/uncommon,
			),
			RES_TIER_UNCOMMON = list(
				/obj/item/research_product/money/uncommon,
				/obj/item/implanter/chem/blood,
			),
			RES_TIER_RARE = list(
				/obj/item/research_product/money/rare,
				/obj/item/implanter/cloak,
			),
		),
	)

///Generates rewards from a research resource
/datum/controller/subsystem/research/proc/research_item(atom/rewards_position, obj/item/research_resource/resource, bucket)
	var/list/potential_rewards = rewards[bucket]
	var/list/earned_rewards = list()

	for (var/tier in reward_tiers)
		var/tier_prob = resource.reward_probs[tier]
		if (!prob(tier_prob))
			continue

		var/list/tier_rewards = potential_rewards[tier]
		//getting random item from the list of items at the tier
		var/item_typepath = pick(tier_rewards)
		var/obj/item = new item_typepath
		earned_rewards += item

	var/turf/drop_loc = get_turf(rewards_position)
	for (var/obj/item AS in earned_rewards)
		item.forceMove(drop_loc)

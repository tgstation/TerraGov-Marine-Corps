/**
 * Research system
 */

//Bucket names
#define RES_MONEY "money"
#define RES_XENO "xeno"

//Reward tiers
#define RES_TIER_BASIC "basic"
#define RES_TIER_COMMON "common"
#define RES_TIER_UNCOMMON "uncommon"
#define RES_TIER_RARE "rare"

/obj/machinery/researchcomp
	name = "research console"
	desc = "A console for performing complex computations. Release the stabilizers to move it around."
	icon = 'icons/obj/machines/bepis.dmi'
	icon_state = "chamber"
	interaction_flags = INTERACT_MACHINE_TGUI
	req_access = list(ACCESS_MARINE_MEDBAY)
	///Description of usable resources for starting research
	var/allowed_resources_desc = ""
	///Loaded resource to begin research
	var/obj/item/research_resource/init_resource = null
	///UI holder
	var/researching = FALSE

	///Research reward tiers
	var/list/reward_tiers = list(
		RES_TIER_BASIC,
		RES_TIER_COMMON,
		RES_TIER_UNCOMMON,
		RES_TIER_RARE
		)

	///List of rewards for each category
	var/static/list/rewards_lists = list(
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
				/obj/item/attachable/shoulder_mount,
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
				/obj/item/attachable/shoulder_mount,
			),
			RES_TIER_RARE = list(
				/obj/item/research_product/money/rare,
				/obj/item/implanter/cloak,
			),
		),
	)

/obj/machinery/researchcomp/Initialize()
	. = ..()
	construct_insertable_resources_desc()

/obj/machinery/researchcomp/examine(user)
	. = ..()
	. += span_notice(allowed_resources_desc)

///Creates the description of usable resources for starting research
/obj/machinery/researchcomp/proc/construct_insertable_resources_desc()
	allowed_resources_desc = "<br><b>Insertable material:</b><br>"
	for(var/obj/resource AS in typesof(/obj/item/research_resource))
		allowed_resources_desc += " >[initial(resource.name)]<br>"

/obj/machinery/researchcomp/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(researching || !istype(I, /obj/item/research_resource))
		return

	if(!user.transferItemToLoc(I, src))
		return

	replace_init_resource(usr, I)

/obj/machinery/researchcomp/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Research", name)
		ui.open()

/obj/machinery/researchcomp/ui_static_data(mob/user)
	. = ..()

	.["acquired_points"] = GLOB.round_statistics.points_from_research
	.["anchored"] = anchored
	.["researching"] = researching
	if(!init_resource)
		.["init_resource"] = null
		return

	var/icon/resource_icon = icon(init_resource.icon, init_resource.icon_state, SOUTH)

	.["init_resource"] = list(
		"name" = init_resource.name,
		"colour" = init_resource.color,
		"icon" = icon2base64(resource_icon)
	)

	var/list/research_rewards = rewards_lists[init_resource.research_type]
	.["init_resource"]["rewards"] = list()
	for(var/tier in research_rewards)
		var/list/reward_tier = list(
			"type" = tier,
			"probability" = init_resource.reward_probs[tier],
			"rewards_list" = list(),
		)

		var/list/tier_rewards_typepaths = research_rewards[tier]
		for(var/obj/typepath AS in tier_rewards_typepaths)
			reward_tier["rewards_list"] += initial(typepath.name)

		.["init_resource"]["rewards"] += list(reward_tier)

/obj/machinery/researchcomp/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("switch_anchored")
			if (researching)
				to_chat(usr, span_notice("It is currently researching."))
				return

			setAnchored(!anchored)
			update_static_data(usr)

		if("start_research")
			if (!anchored)
				to_chat(usr, span_notice("It needs to be fastened before researching."))
				return
			if (!init_resource)
				to_chat(usr, span_notice("You have no resource to begin research."))
				return
			if (researching)
				to_chat(usr, span_notice("It is already researching something."))
				return

			start_research(usr, 5 SECONDS)
			update_static_data(usr)

///Inserts/Replaces the resource used to being research
/obj/machinery/researchcomp/proc/replace_init_resource(mob/living/user, obj/item/new_resource)
	if(init_resource)
		init_resource.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(init_resource)
	if(new_resource)
		init_resource = new_resource
		icon_state = "chamber_loaded"
	else
		init_resource = null
		icon_state = "chamber"
	update_static_data(usr)

///Begins the research process
/obj/machinery/researchcomp/proc/start_research(mob/living/user, research_time)
	icon_state = "chamber_active_loaded"
	researching = TRUE
	addtimer(CALLBACK(src, .proc/finish_research), research_time)

///Handles the research process completing
/obj/machinery/researchcomp/proc/finish_research()
	flick("chamber_flash",src)
	research_item(src, init_resource, init_resource.research_type)
	qdel(init_resource)
	init_resource = null
	icon_state = "chamber"
	researching = FALSE
	update_static_data(usr)

///Generates rewards from a research resource
/obj/machinery/researchcomp/proc/research_item(atom/rewards_position, obj/item/research_resource/resource, bucket)
	var/list/potential_rewards = rewards_lists[bucket]
	var/list/earned_rewards = list()

	generate_research_rewards_list(resource, potential_rewards, earned_rewards)

	var/turf/drop_loc = get_turf(rewards_position)
	for (var/obj/item AS in earned_rewards)
		item.forceMove(drop_loc)

///Generates rewards using the resource's rarity modifiers and a list of potential rewards
/obj/machinery/researchcomp/proc/generate_research_rewards_list(obj/item/research_resource/resource, list/potential_rewards, list/earned_rewards)
	for (var/tier in reward_tiers)
		var/tier_prob = resource.reward_probs[tier]
		if (!prob(tier_prob))
			continue

		var/list/tier_rewards = potential_rewards[tier]
		//getting random item from the list of items at the tier
		var/item_typepath = pick(tier_rewards)
		var/obj/item = new item_typepath
		earned_rewards += item

///
///Research materials
///

/obj/item/research_resource
	name = "Unknown substance"
	icon_state = "coin-mythril"
	color = "#e2a4dd"
	///Type of research the item is used for
	var/research_type = RES_MONEY
	///Research progress percent modifiers
	var/list/reward_probs = list(
		RES_TIER_BASIC = 0,
		RES_TIER_COMMON = 0,
		RES_TIER_UNCOMMON = 0,
		RES_TIER_RARE = 0,
	)

/obj/item/research_resource/money
	desc = "Unidentified substance. The random data it provides could probably secure some funding."
	research_type = RES_MONEY
	reward_probs = list(
		RES_TIER_BASIC = 100,
		RES_TIER_COMMON = 30,
		RES_TIER_UNCOMMON = 20,
		RES_TIER_RARE = 5,
	)

/obj/item/research_resource/xeno
	research_type = RES_XENO
	icon = 'icons/obj/alien_autopsy.dmi'
	icon_state = "sample_0"

/obj/item/research_resource/xeno/Initialize()
	. = ..()
	icon_state = "sample_[rand(0, 11)]"

/obj/item/research_resource/xeno/tier_one
	name = "Xenomorph research material - tier 1"
	color = "#f0bee3"
	reward_probs = list(
		RES_TIER_BASIC = 100,
		RES_TIER_COMMON = 15,
		RES_TIER_UNCOMMON = 7,
		RES_TIER_RARE = 1,
	)

/obj/item/research_resource/xeno/tier_two
	name = "Xenomorph research material - tier 2"
	color = "#d6e641"
	reward_probs = list(
		RES_TIER_BASIC = 100,
		RES_TIER_COMMON = 40,
		RES_TIER_UNCOMMON = 20,
		RES_TIER_RARE = 6,
	)

/obj/item/research_resource/xeno/tier_three
	name = "Xenomorph research material - tier 3"
	color = "#e43939"
	reward_probs = list(
		RES_TIER_BASIC = 100,
		RES_TIER_COMMON = 50,
		RES_TIER_UNCOMMON = 40,
		RES_TIER_RARE = 10,
	)

/obj/item/research_resource/xeno/tier_four
	name = "Xenomorph research material - tier 4"
	color = "#a800ad"
	reward_probs = list(
		RES_TIER_BASIC = 100,
		RES_TIER_COMMON = 50,
		RES_TIER_UNCOMMON = 40,
		RES_TIER_RARE = 50,
	)

///
///Items designed to be products of research
///It isn't required for a product of research to be subtype of these
///

/obj/item/research_product
	name = "money"
	icon_state = "coin_uranium"
	///Points provided for exporting the product
	var/export_points = 1

/obj/item/research_product/supply_export(faction_selling)
	SSpoints.supply_points[faction_selling] += export_points
	GLOB.round_statistics.points_from_research += export_points
	return new /datum/export_report(export_points, name, faction_selling)

/obj/item/research_product/money/examine(user)
	. = ..()
	. += span_notice("Rewards export points, as the name suggests.")

/obj/item/research_product/money/basic
	name = "credits - 5"
	export_points = 5

/obj/item/research_product/money/common
	name = "credits - 15"
	export_points = 15

/obj/item/research_product/money/uncommon
	name = "credits - 25"
	export_points = 25

/obj/item/research_product/money/rare
	name = "credits - 80"
	export_points = 80

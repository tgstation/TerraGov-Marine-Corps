/**
 * Research system
 */

/obj/machinery/computer/researchcomp
	name = "research console"
	desc = "A console for performing complex computations."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = SHUTTLE_SUPPLY
	interaction_flags = INTERACT_MACHINE_TGUI
	req_access = list(ACCESS_MARINE_MEDBAY)
	circuit = null
	///Description of usable resources for starting research
	var/allowed_resources_desc
	///Loaded resource to begin research
	var/obj/item/research_resource/init_resource = null
	///UI holder
	var/researching = FALSE

/obj/machinery/computer/researchcomp/Initialize()
	. = ..()
	construct_insertable_resources_desc()

/obj/machinery/computer/researchcomp/examine(user)
	. = ..()
	to_chat(user, span_notice(allowed_resources_desc))

#define BASE_RESEARCH_RES_TYPE /obj/item/research_resource

///Creates the description of usable resources for starting research
/obj/machinery/computer/researchcomp/proc/construct_insertable_resources_desc()
	allowed_resources_desc = ""
	allowed_resources_desc += "<br><b>Insertable material:</b><br>"
	for(var/obj/resource as() in typesof(BASE_RESEARCH_RES_TYPE))
		allowed_resources_desc += " >[initial(resource.name)]<br>"

/obj/machinery/computer/researchcomp/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!researching && istype(I, /obj/item/research_resource))
		if(!user.transferItemToLoc(I, src))
			return

		replace_init_resource(usr, I)
		return

#undef BASE_RESEARCH_RES_TYPE

/obj/machinery/computer/researchcomp/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Research", name)
		ui.open()

/obj/machinery/computer/researchcomp/ui_data(mob/user)
	var/list/data = list()
	data["init_resource"] = init_resource ? list(
		"name" = init_resource.name,
		"colour" = init_resource.colour,
	) : null
	data["researching"] = researching
	return data

/obj/machinery/computer/researchcomp/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("remove_init_resource")
			replace_init_resource(usr)
		if("start_research")
			if (!init_resource)
				to_chat(user, span_notice("You have no resource to begin research."))
				return
			start_research(usr)

/obj/machinery/computer/researchcomp/proc/replace_init_resource(mob/living/user, obj/item/new_resource)
	if(init_resource)
		init_resource.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(init_resource)
	if(new_resource)
		init_resource = new_resource
	else
		init_resource = null
	update_icon()
	return TRUE

/obj/machinery/computer/researchcomp/proc/start_research(mob/living/user)
	SSresearch.research_item(src, init_resource, init_resource.research_type)
	qdel(init_resource)
	init_resource = null

///
///Research materials
///

/obj/item/research_resource
	name = "base research token"
	icon_state = "coin-mythril"
	///Colour associated with the resource
	var/colour = "#f0bee3"
	///Type of research the item is used for
	var/research_type = RES_MONEY
	///Research progress percent modifiers
	var/list/reward_tier_mods = list(
		RES_TIER_BASIC = 0,
		RES_TIER_COMMON = 0,
		RES_TIER_UNCOMMON = 0,
		RES_TIER_RARE = 0,
	)

/obj/item/research_resource/xeno/Initialize()
	. = ..()
	color = colour

/obj/item/research_resource/xeno/tier_one
	name = "Xenomorph research material - tier 1"

/obj/item/research_resource/xeno/tier_two
	name = "Xenomorph research material - tier 2"
	colour = "#d6e641"
	reward_tier_mods = list(
		RES_TIER_BASIC = 0,
		RES_TIER_COMMON = 20,
		RES_TIER_UNCOMMON = 0,
		RES_TIER_RARE = 0,
	)

/obj/item/research_resource/xeno/tier_three
	name = "Xenomorph research material - tier 3"
	colour = "#e43939"
	reward_tier_mods = list(
		RES_TIER_BASIC = 0,
		RES_TIER_COMMON = 20,
		RES_TIER_UNCOMMON = 20,
		RES_TIER_RARE = 0,
	)

/obj/item/research_resource/xeno/tier_four
	name = "Xenomorph research material - tier 4"
	colour = "#a800ad"
	reward_tier_mods = list(
		RES_TIER_BASIC = 0,
		RES_TIER_COMMON = 20,
		RES_TIER_UNCOMMON = 20,
		RES_TIER_RARE = 40,
	)

///
///Items designed to be products of research
///It isn't required for a product of research to be subtype of these
///

/obj/item/research_product
	name = "money"
	icon_state = "coin_uranium"
	var/export_points = 100000

/obj/item/research_product/supply_export(faction_selling)
	return export_points

/obj/item/research_product/money/Initialize()
	. = ..()
	name += " - [export_points]"

/obj/item/research_product/money/examine(user)
	. = ..()
	to_chat(user, span_notice("Rewards export points, as the name suggests."))

/obj/item/research_product/money/basic
	export_points = 10

/obj/item/research_product/money/common
	export_points = 20

/obj/item/research_product/money/uncommon
	export_points = 30

/obj/item/research_product/money/rare
	export_points = 100

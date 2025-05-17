/obj/item/card/voucher
	name = "voucher"
	desc = "A voucher which can be redeemed at a voucher console or ASRS elevator. Cannot be redeemed by the issuing faction."
	faction = FACTION_TERRAGOV
	icon_state = "guest"
	var/supply_reward = 0
	var/dropship_reward = 0

/obj/item/card/voucher/Initialize(mapload, _faction, _supply_reward, _dropship_reward)
	. = ..()
	faction = _faction || faction
	supply_reward = _supply_reward || supply_reward
	dropship_reward = _dropship_reward || dropship_reward

/obj/item/card/voucher/examine(mob/user)
	. = ..()
	. += "It is issued by [faction]."
	. += "It is worth [supply_reward] supply points[dropship_reward ? " and [dropship_reward] dropship points" : ""]."

/obj/item/card/voucher/get_export_value()
	. = list(supply_reward, dropship_reward)

/obj/item/card/voucher/supply_export(faction_selling)
	if(faction_selling == faction)
		return list(new /datum/export_report(0, name, faction_selling))
	return ..()

/obj/machinery/computer/voucher
	name = "voucher console"
	desc = "A console used for issuing and redeeming vouchers. Can also be used to redeem classified data disks."
	icon_state = "computer_small"
	screen_overlay = "guest"
	density = FALSE
	interaction_flags = INTERACT_MACHINE_TGUI
	req_access = list(ACCESS_MARINE_CARGO)
	faction = FACTION_TERRAGOV
	var/supply_points = 0
	var/dropship_points = 0

/obj/machinery/computer/voucher/Initialize(mapload, _faction)
	. = ..()
	faction = _faction || faction
	name = "[faction] [name]"

/obj/machinery/computer/voucher/examine(mob/user)
	. = ..()
	. += "It belongs to [faction]."

/obj/machinery/computer/voucher/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	var/obj/item/card/voucher/voucher = I
	if(istype(voucher))
		if(voucher.faction == faction)
			to_chat(user, span_warning("[src] says \"Cannot redeem voucher - can only be redeemed by other factions.\""))
			return
		else
			I.supply_export(faction)
			qdel(I)
			return TRUE
	if(istype(I, /obj/item/disk/intel_disk))
		I.supply_export(faction)
		qdel(I)
		return TRUE

/obj/machinery/computer/voucher/ui_state(mob/user)
	return GLOB.access_state

/obj/machinery/computer/voucher/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "VoucherConsole", name)
		ui.open()

/obj/machinery/computer/voucher/ui_data(mob/user)
	. = list()
	.["faction"] = faction
	.["supply_points_available"] = SSpoints.supply_points[faction]
	.["supply_points_to_issue"] = supply_points
	.["supply_points_max"] = HUMAN_FACTION_MAX_POINTS
	.["dropship_points_to_issue"] = dropship_points
	.["dropship_points_available"] = SSpoints.dropship_points[faction]
	.["dropship_points_max"] = HUMAN_FACTION_MAX_DROPSHIP_POINTS

/obj/machinery/computer/voucher/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("issue")
			if(supply_points > SSpoints.supply_points[faction])
				to_chat(ui.user, span_warning("[src] says \"Not enough supply points to issue voucher!\""))
				return FALSE
			else
				SSpoints.supply_points[faction] -= supply_points
			if(dropship_points > SSpoints.dropship_points[faction])
				to_chat(ui.user, span_warning("[src] says \"Not enough dropship points to issue voucher!\""))
				return FALSE
			else
				SSpoints.dropship_points[faction] -= dropship_points
			if(!(supply_points || dropship_points))
				to_chat(ui.user, span_warning("[src] says \"Select a nonzero amount of points for the voucher!\""))
				return FALSE
			new /obj/item/card/voucher(loc, faction, supply_points, dropship_points)
			ui.user.log_message("Issued a voucher on behalf of [faction] for [supply_points] supply points and [dropship_points] dropship points.",LOG_GAME)
			supply_points = 0
			dropship_points = 0
			return TRUE
		if("set_supply_points")
			supply_points = params["new_value"]
		if("set_dropship_points")
			dropship_points = params["new_value"]

/obj/machinery/computer/voucher/som
	faction = FACTION_SOM
	req_access = list(ACCESS_SOM_REQUESITIONS)

/obj/machinery/computer/voucher/icc
	faction = FACTION_ICC
	req_access = list(ACCESS_ICC_CARGO)

/obj/machinery/computer/voucher/clf
	faction = FACTION_CLF
	req_access = list(ACCESS_CLF_CARGO)

/obj/machinery/computer/voucher/vsd
	faction = FACTION_VSD
	req_access = list(ACCESS_VSD_CARGO)
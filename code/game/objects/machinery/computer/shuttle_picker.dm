/*!
 * Consoles for picking a shuttle to spawn
 * The generic one is meant for testing and should not be used in an actual game
 */
/obj/machinery/computer/shuttle_picker
	name = "SHUTTLE PICKER - NAME DETERMINED BY dock_id"
	desc = "A console for choosing a shuttle model."
	density = TRUE
	icon_state = "computer"
	screen_overlay = "computer_generic"
	circuit = null
	resistance_flags = RESIST_ALL
	interaction_flags = INTERACT_MACHINE_TGUI
	///To determine where to spawn the shuttle; should match an existing /obj/docking_port/stationary's id var; if null, user is provided choices
	var/dock_id = ""
	///If TRUE, computer deletes itself after a shuttle is spawned
	var/single_use = FALSE
	///currently chosen ref to a template from tgui
	var/current_template_ref
	///List of shuttles to be generated are determined by the type and subtypes of this var
	var/available_shuttles = /datum/map_template/shuttle/flyable
	///Reference to the person using the console; only one player should be using it a time!
	var/datum/weakref/ui_user

/obj/machinery/computer/shuttle_picker/Initialize(mapload)
	. = ..()
	if(dock_id)
		name = "\improper[dock_id] shuttle selection terminal"

/obj/machinery/computer/shuttle_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	//Check to see if the console has a user
	if(ui_user?.resolve())
		return

	ui_user = WEAKREF(user)
	if(!ui)
		ui = new(user, src, "ShuttlePicker", name)
		ui.open()

/obj/machinery/computer/shuttle_picker/ui_static_data(mob/user)
	. = list()
	var/list/shuttles = list()
	//Would make it grab all shuttles but the code in general is a Jenga tower that needs reorganization
	for(var/datum/map_template/shuttle/flyable/shuttle_template AS in SSmapping.flyable_shuttle_templates)
		if((shuttle_template.restricted && !SSticker.mode.enable_restricted_shuttles) || !istype(shuttle_template, available_shuttles))
			continue
		shuttles += list(list(
			"name" = shuttle_template.display_name,
			"description" = shuttle_template.description,
			"ref" = REF(shuttle_template),
		))
	.["shuttles"] = shuttles

/obj/machinery/computer/shuttle_picker/ui_data(mob/user)
	. = list()
	.["current_ref"] = current_template_ref
	var/datum/map_template/shuttle/flyable/choice = locate(current_template_ref) in SSmapping.flyable_shuttle_templates
	if(choice)
		.["desc"] = choice.description
		.["name"] = choice.display_name
		.["assetpath"] = choice.suffix

/obj/machinery/computer/shuttle_picker/ui_close(mob/user)
	. = ..()
	ui_user = null

/obj/machinery/computer/shuttle_picker/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("pickship")
			current_template_ref = params["ref"]

		if("confirm")
			if(!current_template_ref)
				return FALSE

			SStgui.close_user_uis(usr, src)
			ui_user = null

			//User picks a docking port if there isn't one set; note that this should only really be used for testing
			//I imagine it might get real buggy if you don't make a choice and try to spawn another shuttle
			if(!dock_id && !tgui_input_list(usr, "Choose a docking port", "Shuttle Location Picker", SSshuttle.stationary))
				return FALSE

			//Look for the chosen shuttle type and spawn it in
			var/datum/map_template/shuttle/template = locate(current_template_ref) in SSmapping.flyable_shuttle_templates
			var/obj/docking_port/mobile/shuttle = SSshuttle.action_load(template)
			SSshuttle.moveShuttleQuickToDock(template.shuttle_id, dock_id)
			shuttle.setTimer(0)
			playsound(get_turf(src), 'sound/machines/twobeep.ogg', 25)
			if(single_use)
				qdel(src)	//You should QDEL yourself, NOW

	return TRUE

/obj/machinery/computer/shuttle_picker/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/simple/shuttle)

/datum/asset/simple/shuttle
	assets = list(
		"_standard" = 'icons/ui_icons/dropshippicker/_standard.png',
		"_big" = 'icons/ui_icons/dropshippicker/_big.png',
		"_food" = 'icons/ui_icons/dropshippicker/_food.png',
		"_factorio" = 'icons/ui_icons/dropshippicker/_factorio.png',
		"_combat_tad" = 'icons/ui_icons/dropshippicker/_combat_tad.png',
		"_mobile_bar" = 'icons/ui_icons/dropshippicker/_mobile_bar.png',
		"_umbilical" = 'icons/ui_icons/dropshippicker/_umbilical.png',
		"_outrider" = 'icons/ui_icons/dropshippicker/_outrider.png',
	)

/obj/machinery/computer/shuttle_picker/dropship
	desc = "A computer for selecting a model from a range of large shuttles."
	req_access = list(ACCESS_MARINE_PILOT)
	dock_id = SHUTTLE_DROPSHIP
	available_shuttles = /datum/map_template/shuttle/flyable/dropship
	single_use = TRUE

/obj/machinery/computer/shuttle_picker/mini
	desc = "A computer for selecting a model from a range of small shuttles."
	req_access = list(ACCESS_MARINE_PILOT)
	dock_id = SHUTTLE_MINI
	available_shuttles = /datum/map_template/shuttle/flyable/mini
	single_use = TRUE

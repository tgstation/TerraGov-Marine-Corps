
/obj/machinery/computer/dropship_picker
	name = "dropship picker"
	desc = "A computer that lets you choose the model of the tadpole.."
	density = TRUE
	icon_state = "computer"
	screen_overlay = "computer_generic"
	circuit = null
	resistance_flags = RESIST_ALL
	interaction_flags = INTERACT_MACHINE_TGUI
	req_access = list(ACCESS_MARINE_DROPSHIP)
	/// dock id to dock our chosen shuttle at
	var/dock_id = SHUTTLE_TADPOLE
	///if true lock console
	var/dropship_selected = FALSE
	///currently chosen ref to a template from tgui
	var/current_template_ref

/obj/machinery/computer/dropship_picker/attack_hand(mob/user)
	if(dropship_selected)
		balloon_alert(user, "model has already been chosen!")
		return FALSE
	return ..()

/obj/machinery/computer/dropship_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "DropshipPicker", name)
		ui.open()

/obj/machinery/computer/dropship_picker/ui_static_data(mob/user)
	. = list()
	var/list/shuttles = list()
	for (var/datum/map_template/shuttle/minidropship/shuttle_template AS in SSmapping.minidropship_templates)
		if(!shuttle_template.admin_enable && !SSticker.mode.enable_fun_tads)
			continue
		shuttles += list(list(
			"name" = shuttle_template.display_name,
			"description" = shuttle_template.description,
			"ref" = REF(shuttle_template),
		))
	.["shuttles"] = shuttles

/obj/machinery/computer/dropship_picker/ui_data(mob/user)
	. = list()
	.["dropship_selected"] = dropship_selected
	.["current_ref"] = current_template_ref
	var/datum/map_template/shuttle/minidropship/temp = locate(current_template_ref) in SSmapping.minidropship_templates
	if(temp)
		.["desc"] = temp.description
		.["name"] = temp.display_name
		.["assetpath"] = temp.suffix

/obj/machinery/computer/dropship_picker/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/simple/dropshippicker)

/datum/asset/simple/dropshippicker
	assets = list(
		"_standard" = 'icons/ui_icons/dropshippicker/_standard.png',
		"_big" = 'icons/ui_icons/dropshippicker/_big.png',
		"_food" = 'icons/ui_icons/dropshippicker/_food.png',
		"_factorio" = 'icons/ui_icons/dropshippicker/_factorio.png',
		"_combat_tad" = 'icons/ui_icons/dropshippicker/_combat_tad.png',
		"_mobile_bar" = 'icons/ui_icons/dropshippicker/_mobile_bar.png',
		"_umbilical" = 'icons/ui_icons/dropshippicker/_umbilical.png',
	)

/obj/machinery/computer/dropship_picker/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if(dropship_selected)
		return FALSE

	switch(action)
		if("pickship")
			current_template_ref = params["ref"]
		if("confirm")
			if(!current_template_ref)
				return FALSE
			var/datum/map_template/shuttle/template = locate(current_template_ref) in SSmapping.minidropship_templates
			var/obj/docking_port/mobile/shuttle = SSshuttle.action_load(template)
			SSshuttle.moveShuttleQuickToDock(template.shuttle_id, dock_id)
			shuttle.setTimer(0)
			dropship_selected = TRUE
			balloon_alert(usr, "shuttle selected, locking")
			ui.close()
	return TRUE


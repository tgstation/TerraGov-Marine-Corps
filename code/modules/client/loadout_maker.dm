/datum/loadout_maker/proc/start(mob/user)
	ui_interact(user)

/datum/loadout_maker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SlotSelector")
		ui.open()

/datum/loadout_maker/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/inventory),
	)

/datum/strip_menu/ui_data(mob/user)
	return
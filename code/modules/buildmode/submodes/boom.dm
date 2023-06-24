/datum/buildmode_mode/boom
	key = "boom"

	var/devastation = 0
	var/heavy = 0
	var/light = 0
	var/flash = 0
	var/throw_input = 0

/datum/buildmode_mode/boom/show_help(client/builder)
	to_chat(builder, span_purple(examine_block(
		"[span_bold("Set explosion destructiveness")] -> Right Mouse Button on buildmode button\n\
		[span_bold("Kaboom")] -> Mouse Button on obj\n\n\
		[span_warning("NOTE:")] Using the \"Config/Launch Supplypod\" verb allows you to do this in an IC way (i.e., making a cruise missile come down from the sky and explode wherever you click!)"))
	)


/datum/buildmode_mode/boom/change_settings(client/c)
	devastation = input(c, "Range of total devastation.", "Input") as num|null
	heavy = input(c, "Range of heavy impact.", "Input") as num|null
	light = input(c, "Range of light impact.", "Input") as num|null
	flash = input(c, "Range of flash.", "Input") as num|null
	throw_input = input(c, "Range of throw.", "Input") as num|null


/datum/buildmode_mode/boom/handle_click(client/c, params, obj/object)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		explosion(object, devastation, heavy, light, 0, flash, throw_range = throw_input, adminlog = FALSE, silent = TRUE, explosion_cause=key_name(c))
		to_chat(c, span_notice("Success."))
		log_admin("Build Mode: [key_name(c)] caused an explosion(dev=[devastation], hvy=[heavy], lgt=[light], flash=[flash]) at [AREACOORD(object)]")

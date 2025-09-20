/datum/buildmode_mode/basic
	key = "basic"

/datum/buildmode_mode/basic/show_help(client/user)
	to_chat(user, custom_boxed_message("purple_box",\
		"[span_bold("Construct wall / Upgrade wall")] -> Left Mouse Button\n\
		[span_bold("Deconstruct / Delete / Downgrade")] -> Right Mouse Button\n\
		[span_bold("R-Window. For full-tile windows use a diagonal direction.")] -> Left Mouse Button + Ctrl\n\
		[span_bold("Airlock")] -> Left Mouse Button + Alt \n\
		\n\
		Use the button in the upper left corner to change the direction of built objects."))

/datum/buildmode_mode/basic/handle_click(client/user, params, obj/object)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(LAZYACCESS(modifiers, CTRL_CLICK))
			var/obj/structure/window/reinforced/window
			if(BM.build_dir in GLOB.diagonals)
				window = new /obj/structure/window/framed/mainship(get_turf(object))
			else
				window = new /obj/structure/window/reinforced(get_turf(object))
				window.setDir(BM.build_dir)
			log_admin("Build Mode: [key_name(user)] built a window at [AREACOORD(object)]")
			to_chat(user, span_notice("Success."))
			return

		if(LAZYACCESS(modifiers, ALT_CLICK))
			log_admin("Build Mode: [key_name(user)] built an airlock at [AREACOORD(object)]")
			to_chat(user, span_notice("Success."))
			new /obj/machinery/door/airlock(get_turf(object))
			return

		var/turf/T = object
		if(isspaceturf(object))
			T.PlaceOnTop(/turf/open/floor/plating)
		else if(isfloorturf(object))
			T.PlaceOnTop(/turf/closed/wall)
		else if(iswallturf(object))
			T.PlaceOnTop(/turf/closed/wall/r_wall)
		log_admin("Build Mode: [key_name(user)] built [T] at [AREACOORD(T)]")
		to_chat(user, span_notice("Success."))
		return

	if(isturf(object))
		var/turf/T = object
		T.ScrapeAway()
	else if(isobj(object))
		qdel(object)

	log_admin("Build Mode: [key_name(user)] deleted [object] at [AREACOORD(object)]")
	to_chat(user, span_notice("Success."))

/obj/effect/countdown
	name = "countdown"
	desc = "We're leaving together\n\
		But still it's farewell\n\
		And maybe we'll come back\n\
		To Earth, who can tell?"

	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	layer = GHOST_LAYER
	color = "#ff0000" // text color
	var/text_size = 3 // larger values clip when the displayed text is larger than 2 digits.
	var/started = FALSE
	var/displayed_text
	var/atom/attached_to

/obj/effect/countdown/Initialize(mapload)
	. = ..()
	attach(loc)

/obj/effect/countdown/examine(mob/user)
	. = ..()
	. += "This countdown is displaying: [displayed_text]."

/obj/effect/countdown/proc/attach(atom/A)
	attached_to = A
	forceMove(get_turf(A))

/obj/effect/countdown/proc/start()
	if(!started)
		START_PROCESSING(SSprocessing, src)
		started = TRUE

/obj/effect/countdown/proc/stop()
	if(started)
		maptext = null
		STOP_PROCESSING(SSprocessing, src)
		started = FALSE

/obj/effect/countdown/proc/get_value()
	// Get the value from our atom
	return

/obj/effect/countdown/process()
	if(QDELETED(attached_to))
		qdel(src)
	forceMove(get_turf(attached_to))
	var/new_val = get_value()
	if(new_val == displayed_text)
		return
	displayed_text = new_val

	if(displayed_text)
		maptext = "<font size = [text_size]>[displayed_text]</font>"
	else
		maptext = null

/obj/effect/countdown/Destroy()
	attached_to = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/countdown/ex_act(severity) //immune to explosions
	return

/obj/effect/countdown/nuclearbomb
	name = "nuclear bomb countdown"
	color = "#81FF14"

/obj/effect/countdown/nuclearbomb/get_value()
	if(QDELETED(attached_to))
		return
	var/obj/machinery/nuclearbomb/N = attached_to
	if(!N.timer_enabled)
		return
	return N.get_time_left()

//campaign objective timer
/obj/effect/countdown/campaign_objective
	name = "objective countdown"
	color = "#d1d1d1"
	invisibility = SEE_INVISIBLE_LIVING
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 16

/obj/effect/countdown/campaign_objective/get_value()
	if(QDELETED(attached_to))
		return
	var/obj/structure/campaign_objective/capture_objective/objective = attached_to
	return objective.get_time_left()

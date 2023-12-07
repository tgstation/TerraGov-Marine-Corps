GLOBAL_LIST_INIT(ventcrawl_machinery, typecacheof(list(
	/obj/machinery/atmospherics/components/unary/vent_pump,
	/obj/machinery/atmospherics/components/unary/vent_scrubber)))

/mob/proc/start_ventcrawl()
	var/atom/pipe
	var/list/pipes = list()
	for(var/obj/machinery/atmospherics/components/unary/U in range(1))
		if(is_type_in_list(U, GLOB.ventcrawl_machinery) && Adjacent(U))
			pipes |= U
	if(!pipes || !length(pipes))
		balloon_alert(src, "No pipes in range!")
		return
	if(length(pipes) == 1)
		pipe = pipes[1]
	else
		pipe = tgui_input_list(usr, "Crawl Through Vent", "Pick a pipe",  pipes)
	if(!incapacitated() && pipe)
		return pipe

//VENTCRAWLING
/mob/living/proc/handle_ventcrawl(atom/A, crawl_time = 4.5 SECONDS, stealthy = FALSE)
	if(!HAS_TRAIT(src, TRAIT_CAN_VENTCRAWL) || !Adjacent(A) || !canmove)
		return
	if(stat)
		to_chat(src, "You must be conscious to do this!")
		return

	var/obj/machinery/atmospherics/components/unary/vent_found

	if(A)
		vent_found = A
		if(!istype(vent_found) || !vent_found.can_crawl_through())
			vent_found = null

	if(!vent_found)
		for(var/obj/machinery/atmospherics/machine in range(1,src))
			if(!is_type_in_typecache(machine, GLOB.ventcrawl_machinery))
				continue
			vent_found = machine

			if(!vent_found.can_crawl_through())
				vent_found = null

			if(vent_found)
				break

	if(vent_found)
		var/datum/pipeline/vent_found_parent = vent_found.parents[1]
		if(vent_found_parent && (length(vent_found_parent.members) || vent_found_parent.other_atmosmch))
			visible_message(span_notice("[stealthy ? "[src] begins climbing into the ventilation system..." : ""]"),span_notice("You begin climbing into the ventilation system..."))

			if(!do_after(src, crawl_time, IGNORE_HELD_ITEM, vent_found, BUSY_ICON_GENERIC) || !client || !canmove)
				return

			/// TODO istype(src) stupidity
			if(iscarbon(src))//It must have atleast been 1 to get this far
				var/failed = FALSE
				var/list/items_list = get_equipped_items() //include_pockets = TRUE)
				if(length(items_list))
					failed = TRUE
				if(failed)
					to_chat(src, span_warning("You can't crawl around in the ventilation ducts with items!"))
					return


			visible_message(span_notice("[stealthy ? "[src] scrambles into the ventilation ducts!" : ""]"),span_notice("You climb into the ventilation ducts."))

			if(!stealthy) //Xenos with stealth vent crawling can silently enter/exit vents.
				playsound(src, get_sfx("alien_ventpass"), 35, TRUE)

			forceMove(vent_found)
			update_pipe_vision()
	else
		to_chat(src, span_warning("This ventilation duct is not connected to anything!"))


/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/starting_machine)
	if(!istype(starting_machine) || !starting_machine.can_see_pipes)
		return
	var/list/totalMembers = list()
	for(var/datum/pipeline/P in starting_machine.returnPipenets())
		totalMembers += P.members
		totalMembers += P.other_atmosmch
	if(!length(totalMembers))
		return

	if(client)
		for(var/X in totalMembers)
			var/obj/machinery/atmospherics/A = X //all elements in totalMembers are necessarily of this type.
			if(!in_view_range(client.mob, A))
				continue
			if(!A.pipe_vision_img)
				A.pipe_vision_img = image(A, A.loc, layer = ABOVE_HUD_LAYER, dir = A.dir)
				A.pipe_vision_img.plane = ABOVE_HUD_PLANE
			A.pipe_vision_img.alpha = 200
			client.images += A.pipe_vision_img
			pipes_shown += A.pipe_vision_img
	is_ventcrawling = TRUE
	SEND_SIGNAL(src, COMSIG_LIVING_ADD_VENTCRAWL)
	return TRUE

/mob/living/proc/remove_ventcrawl()
	is_ventcrawling = FALSE
	if(client)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image

	pipes_shown.len = 0


/atom/proc/update_pipe_vision(atom/new_loc = null)
	return


/mob/living/update_pipe_vision(atom/new_loc = null)
	. = loc
	if(new_loc)
		. = new_loc
	remove_ventcrawl()
	add_ventcrawl(.)

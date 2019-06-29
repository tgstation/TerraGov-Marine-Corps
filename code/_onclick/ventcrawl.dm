GLOBAL_LIST_INIT(ventcrawl_machinery, typecacheof(list(
	/obj/machinery/atmospherics/components/unary/vent_pump,
	/obj/machinery/atmospherics/components/unary/vent_scrubber)))


/mob/proc/can_ventcrawl()
	return FALSE


/mob/proc/ventcrawl_carry()
	for(var/atom/A in src.contents)
		if(!istype(A, /obj/item/clothing/mask/facehugger))
			to_chat(src, "<span class='warning'>You can't be carrying items or have items equipped when vent crawling!</span>")
			return FALSE
	return TRUE


/mob/proc/start_ventcrawl()
	var/atom/pipe
	var/list/pipes = list()
	for(var/obj/machinery/atmospherics/components/unary/U in range(1))
		if(is_type_in_list(U, GLOB.ventcrawl_machinery) && Adjacent(U))
			pipes |= U
	if(!pipes || !pipes.len)
		to_chat(src, "<span class='warning'>There are no pipes that you can ventcrawl into within range!</span>")
		return
	if(pipes.len == 1)
		pipe = pipes[1]
	else
		pipe = input("Crawl Through Vent", "Pick a pipe") as null|anything in pipes
	if(!incapacitated() && pipe)
		return pipe


/mob/living/carbon/monkey/can_ventcrawl()
	return TRUE

/mob/living/simple_animal/mouse/can_ventcrawl()
	return TRUE


//VENTCRAWLING
/mob/proc/handle_ventcrawl(atom/A)
	if(!can_ventcrawl() || !Adjacent(A))
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
			if(is_type_in_typecache(machine, GLOB.ventcrawl_machinery))
				vent_found = machine

			if(!vent_found.can_crawl_through())
				vent_found = null

			if(vent_found)
				break


	if(vent_found)
		var/datum/pipeline/vent_found_parent = vent_found.parents[1]
		if(vent_found_parent && (vent_found_parent.members.len || vent_found_parent.other_atmosmch))
			visible_message("<span class='notice'>[src] begins climbing into the ventilation system...</span>" ,"<span class='notice'>You begin climbing into the ventilation system...</span>")

			if(!do_after(src, 45, FALSE, vent_found, BUSY_ICON_GENERIC) || !client)
				return

			if(iscarbon(src) && can_ventcrawl())//It must have atleast been 1 to get this far
				var/failed = FALSE
				var/list/items_list = get_equipped_items() //include_pockets = TRUE)
				if(items_list.len)
					failed = TRUE
				if(failed)
					to_chat(src, "<span class='warning'>You can't crawl around in the ventilation ducts with items!</span>")
					return

			if(!ventcrawl_carry())
				return

			visible_message("<span class='notice'>[src] scrambles into the ventilation ducts!</span>","<span class='notice'>You climb into the ventilation ducts.</span>")
			if(!isxenohunter(src)) //Hunters silently enter/exit vents.
				pick(playsound(src, 'sound/effects/alien_ventpass1.ogg', 35, 1), playsound(src, 'sound/effects/alien_ventpass2.ogg', 35, 1))

			forceMove(vent_found)
			update_pipe_vision(vent_found)
	else
		to_chat(src, "<span class='warning'>This ventilation duct is not connected to anything!</span>")


/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/starting_machine)
	if(!istype(starting_machine) || !starting_machine.can_see_pipes())
		return
	var/list/totalMembers = list()
	for(var/datum/pipeline/P in starting_machine.returnPipenets())
		totalMembers += P.members
		totalMembers += P.other_atmosmch
	if(!totalMembers.len)
		return

	if(client)
		for(var/X in totalMembers)
			var/obj/machinery/atmospherics/A = X //all elements in totalMembers are necessarily of this type.
			if(!A.pipe_vision_img)
				A.pipe_vision_img = image(A, A.loc, layer = ABOVE_HUD_LAYER, dir = A.dir)
				A.pipe_vision_img.plane = ABOVE_HUD_PLANE
			A.pipe_vision_img.alpha = 200
			client.images += A.pipe_vision_img
			pipes_shown += A.pipe_vision_img
	is_ventcrawling = TRUE
	return TRUE


/mob/living/carbon/xenomorph/hunter/add_ventcrawl(obj/machinery/atmospherics/starting_machine)
	. = ..()
	if(.)
		cancel_stealth()


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
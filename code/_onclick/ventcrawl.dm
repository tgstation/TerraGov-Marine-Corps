var/list/ventcrawl_machinery = list(/obj/machinery/atmospherics/components/unary/vent_pump, /obj/machinery/atmospherics/components/unary/vent_scrubber)

/mob/living/proc/can_ventcrawl()
	return 0

/mob/living/proc/ventcrawl_carry()
	for(var/atom/A in src.contents)
		if(!(is_type_in_list(A, canEnterVentWith)))
			to_chat(src, "<span class='warning'>You can't be carrying items or have items equipped when vent crawling!</span>")
			return 0
	return 1


/mob/living/click(var/atom/A, var/list/mods)
	if (..())
		return 1
	if (mods["alt"])
		if(can_ventcrawl() && is_type_in_list(A, ventcrawl_machinery))
			handle_ventcrawl(A)
		return 1


/mob/proc/start_ventcrawl()
	var/atom/pipe
	var/list/pipes = list()
	for(var/obj/machinery/atmospherics/components/unary/U in range(1))
		if(is_type_in_list(U,ventcrawl_machinery) && Adjacent(U))
			pipes |= U
	if(!pipes || !pipes.len)
		to_chat(src, "<span class='warning'>There are no pipes that you can ventcrawl into within range!</span>")
		return
	if(pipes.len == 1)
		pipe = pipes[1]
	else
		pipe = input("Crawl Through Vent", "Pick a pipe") as null|anything in pipes
	if(!is_mob_incapacitated() && pipe)
		return pipe

/mob/living/carbon/monkey/can_ventcrawl()
	return 1

/mob/living/simple_animal/mouse/can_ventcrawl()
	return 1

/mob/living/simple_animal/spiderbot/can_ventcrawl()
	return 1

GLOBAL_LIST_INIT(ventcrawl_machinery, typecacheof(list(
	/obj/machinery/atmospherics/components/unary/vent_pump,
	/obj/machinery/atmospherics/components/unary/vent_scrubber)))

//VENTCRAWLING

/mob/living/proc/handle_ventcrawl(atom/A)
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

			if(!do_after(src, 45, FALSE, 5, BUSY_ICON_GENERIC))
				return

			if(!client)
				return

			if(iscarbon(src) && can_ventcrawl())//It must have atleast been 1 to get this far
				var/failed = 0
				var/list/items_list = get_equipped_items() //include_pockets = TRUE)
				if(items_list.len)
					failed = 1
				if(failed)
					to_chat(src, "<span class='warning'>You can't crawl around in the ventilation ducts with items!</span>")
					return

			if(!ventcrawl_carry())
				return

			visible_message("<span class='notice'>[src] scrambles into the ventilation ducts!</span>","<span class='notice'>You climb into the ventilation ducts.</span>")
			if(!istype(src,/mob/living/carbon/Xenomorph/Hunter)) //Hunters silently enter/exit vents.
				pick(playsound(src, 'sound/effects/alien_ventpass1.ogg', 35, 1), playsound(src, 'sound/effects/alien_ventpass2.ogg', 35, 1))

			forceMove(vent_found)
	else
		to_chat(src, "<span class='warning'>This ventilation duct is not connected to anything!</span>")
/*
/mob/living/proc/handle_ventcrawl(var/atom/clicked_on)
	log_message("Started ventcrawling", LOG_GAME)
	if(stat)
		to_chat(src, "<span class='warning'>You must be conscious to do this!</span>")
		return
	if(lying)
		to_chat(src, "<span class='warning'>You can't vent crawl while you're stunned!</span>")
		return
	var/obj/machinery/atmospherics/components/unary/vent_found
	if(clicked_on && Adjacent(clicked_on))
		vent_found = clicked_on
		if(!istype(vent_found) || !vent_found.can_crawl_through())
			vent_found = null
	if(!vent_found)
		var/obj/machinery/atmospherics/P
		var/obj/O
		for(O in range(1, src))
			P = O
			if(is_type_in_list(P, ventcrawl_machinery) && P.can_crawl_through())
				vent_found = P
				break
	if(!vent_found)
		to_chat(src, "<span class='warning'>You must be standing on or beside an air vent to enter it.</span>")
		return
	if(!vent_found.parents?.members?.len || !vent_found.parents?.other_atmosmch)
		to_chat(src, "<span class='warning'>This vent is not connected to anything.</span>")
		return
	if(!issilicon(src))
		switch(vent_found.temperature)
			if(0 to BODYTEMP_COLD_DAMAGE_LIMIT)
				to_chat(src, "<span class='danger'>You feel a painful freeze coming from the vent!</span>")
			if(BODYTEMP_COLD_DAMAGE_LIMIT to T0C)
				to_chat(src, "<span class='warning'>You feel an icy chill coming from the vent.</span>")
			if(T0C + 40 to BODYTEMP_HEAT_DAMAGE_LIMIT)
				to_chat(src, "<span class='warning'>You feel a hot wash coming from the vent.</span>")
			if(BODYTEMP_HEAT_DAMAGE_LIMIT to INFINITY)
				to_chat(src, "<span class='danger'>You feel a searing heat coming from the vent!</span>")
	visible_message("<span class='notice'>[src] begins climbing into [vent_found].</span>", \
	"<span class='notice'>You begin climbing into [vent_found].</span>")
	if(!do_after(src, 45, FALSE, 5, BUSY_ICON_GENERIC))
		return
	updatehealth()
	if(stat || stunned || knocked_down || lying || health < 0)
		return
	if(!client)
		return
	if(!ventcrawl_carry())
		return
	visible_message("<span class='danger'>[src] scrambles into [vent_found]!</span>", \
	"<span class='warning'>You climb into [vent_found].</span>")
	if(!istype(src,/mob/living/carbon/Xenomorph/Hunter)) //Hunters silently enter/exit vents.
		pick(playsound(src, 'sound/effects/alien_ventpass1.ogg', 35, 1), playsound(src, 'sound/effects/alien_ventpass2.ogg', 35, 1))
	forceMove(vent_found)
	add_ventcrawl(vent_found)
	return*/


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
			if(in_view_range(client.mob, A))
				if(!A.pipe_vision_img)
					A.pipe_vision_img = image(A, A.loc, layer = ABOVE_HUD_LAYER, dir = A.dir)
					A.pipe_vision_img.plane = ABOVE_HUD_PLANE
				client.images += A.pipe_vision_img
				pipes_shown += A.pipe_vision_img
	//setMovetype(movement_type | VENTCRAWLING)

/mob/living/carbon/Xenomorph/Hunter/add_ventcrawl(obj/machinery/atmospherics/starting_machine)
	. = ..()
	cancel_stealth()

/mob/living/proc/remove_ventcrawl()
	is_ventcrawling = 0
	if(client)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		client.eye = src

	pipes_shown.len = 0

/mob/living/proc/update_pipe_vision(atom/new_loc = null)
	. = loc
	if(new_loc)
		. = new_loc
	remove_ventcrawl()
	add_ventcrawl(.)

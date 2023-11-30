//Vendor for CL stuff
//Bribe items may help marines, but also give CL more control over them
//Bought with points, which regenerate over time

/obj/item/portable_vendor
	name = "\improper Automated Storage Briefcase"
	desc = "A suitcase-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense small items."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "secure"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/containers_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/containers_right.dmi',
	)
	flags_atom = CONDUCT
	force = 8
	hitsound = "swing_hit"
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	interaction_flags = INTERACT_OBJ_UI

	var/req_role //to be compared with job.type to only allow those to use that machine.
	var/points = 40
	var/max_points = 50
	var/use_points = TRUE
	var/fabricating = 0
	var/broken = 0

	var/list/listed_products = list()

/obj/item/portable_vendor/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(loc == user)
		attack_self(user)


/obj/item/portable_vendor/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(broken)
		return FALSE

	if(!allowed(user))
		return FALSE

	if(isliving(user))
		var/obj/item/card/id/I = user.get_idcard()
		if(!istype(I))
			to_chat(usr, span_warning("Access denied. Authorized roles only."))
			return FALSE

		if(I.registered_name != user.real_name)
			return FALSE

		if(req_role)
			var/mob/living/living_user = user
			if(!istype(living_user.job, req_role))
				to_chat(usr, span_warning("Access denied. Authorized roles only."))
				return FALSE

	return TRUE

/obj/item/portable_vendor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableVendor", name)
		ui.open()

/obj/item/portable_vendor/ui_data(mob/user)
	var/list/display_list = list()


	for(var/i in 1 to length(listed_products))
		var/list/myprod = listed_products[i]
		var/p_name = myprod[1]
		var/p_cost = myprod[2]
		if(p_cost > 0)
			p_name += " ([p_cost] points)"

		var/prod_available = FALSE
		//var/avail_flag = myprod[4]
		if(points >= p_cost || !use_points)
			prod_available = TRUE

								//place in main list, name, cost, available or not, color.
		display_list += list(list("prod_index" = i, "prod_name" = p_name, "prod_available" = prod_available, "prod_color" = myprod[4], "prod_desc" = myprod[5]))


	var/list/data = list(
		"vendor_name" = name,
		"show_points" = use_points,
		"current_points" = round(points),
		"max_points" = max_points,
		"displayed_records" = display_list,
	)
	return data

/obj/item/portable_vendor/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	switch(action)
		if("vend")
			if(!allowed(user))
				balloon_alert(user, "Access denied.")
				return

			if(fabricating)
				balloon_alert(user, "already fabricating")
				return
			var/idx = text2num(params["vend"])

			var/list/L = listed_products[idx]
			var/cost = L[2]

			if(use_points && points < cost)
				balloon_alert(user, "Not enough points")

			var/turf/T = get_turf(src)
			if(length(T.contents) > 25)
				balloon_alert(user, "not enough space")
				return

			if(use_points)
				points -= cost

			playsound(src, "sound/machines/fax.ogg", 5)
			balloon_alert(user, "fabricating")
			fabricating = TRUE
			update_overlays()
			addtimer(CALLBACK(src, PROC_REF(do_vend), L[3], user), 1 SECONDS)

/obj/item/portable_vendor/proc/do_vend(thing, mob/user)
	var/obj/IT = new thing(get_turf(src))
	if(loc == user)
		user.put_in_hands(IT)
	fabricating = FALSE
	update_overlays()

/obj/item/portable_vendor/update_overlays()
	. = ..()
	if(overlays)
		overlays.Cut()
	if (broken)
		. += image(icon, "securespark")
	else if (fabricating)
		. += image(icon, "secureb")
	else
		. += image(icon, "secure0")


/obj/item/portable_vendor/process()
	points = min(max_points, points+0.05)


/obj/item/portable_vendor/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	update_overlays()

/obj/item/portable_vendor/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/portable_vendor/proc/malfunction()
	var/turf/T = get_turf(src)
	T.visible_message(span_warning("[src] shudders as its internal components break apart!"))
	broken = 1
	STOP_PROCESSING(SSobj, src)
	update_overlays()

	playsound(src, 'sound/effects/sparks4.ogg', 60, 1)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(2, 1, src)
	s.start()

/obj/item/portable_vendor/emp_act(severity)
	if (broken)
		return
	if (prob(40*severity))
		malfunction()

/obj/item/portable_vendor/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)


/obj/item/portable_vendor/corporate
	name = "\improper Nanotrasen Automated Storage Briefcase"
	desc = "A suitcase-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense small items. This one has the Nanotrasen logo stamped on its side."

	req_access = list(ACCESS_NT_CORPORATE)
	req_role = /datum/job/terragov/civilian/liaison
	listed_products = list(
		list("INCENTIVES", 0, null, null, null),
		list("Cash", 2, /obj/item/spacecash/c500, "white", "$500 USD, unmarked bills"),
		list("Cigars", 5, /obj/item/storage/fancy/cigar, "white", "Case of premium cigars, untampered."),
		list("Space Drug Autoinjector", 10, /obj/item/reagent_containers/hypospray/autoinjector/spacedrugs, "white", "Drugs for junkie marines who still need that fix."),
		list("Nanotrasen 'Space-Aged' 60-Year Old Whiskey", 20, /obj/item/reagent_containers/food/drinks/bottle/specialwhiskey, "white", "Aged at the bottom of a starship since 2378. You can guess how much it's worth."),
		list("Mindbreaker Toxin Autoinjector", 30, /obj/item/reagent_containers/hypospray/autoinjector/mindbreaker, "white", "Drugs for people whose PTSD have permanently scarred them."),
		list("Roulettium Autoinjector", 30, /obj/item/reagent_containers/hypospray/autoinjector/roulettium, "white", "Drugs for people who really, really miss gambling. Enough for their life." ),
		list("NT-06 Experimental Liquor", 40, /obj/item/reagent_containers/food/drinks/bottle/experimentalliquor, "white", "An experimental liquor we cooked up in the lab a few years back. Composed of ██████."),
		list("Elite Autoinjector", 50, /obj/item/reagent_containers/hypospray/autoinjector/elite, "white", "A combat injector 'supposedly' used by our 'Deathsquads'. Don't give it out unless they have something to give in return."),
		list("De Void of Soul", 51, /obj/item/clothing/under/liaison_suit/galaxy_blue, "white", "The latest in ultrafashion. for those with a cool demeanor."),
		list("Pulsar Gonne", 51, /obj/item/clothing/under/liaison_suit/galaxy_red, "white", "The latest in ultrafashion. for those with a fiery temper.")
	)

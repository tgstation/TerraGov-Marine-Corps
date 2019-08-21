//Vendor for CL stuff
//Bribe items may help marines, but also give CL more control over them
//Bought with points, which regenerate over time

/obj/item/portable_vendor
	name = "\improper Automated Storage Briefcase"
	desc = "A suitcase-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense small items."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "secure"
	flags_atom = CONDUCT
	force = 8.0
	hitsound = "swing_hit"
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY

	var/req_role = "" //to be compared with assigned_role to only allow those to use that machine.
	var/points = 40
	var/max_points = 50
	var/use_points = TRUE
	var/fabricating = 0
	var/broken = 0
	var/list/purchase_log = list()

	var/list/listed_products = list()


/obj/item/portable_vendor/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(loc == user)
		attack_self(user)


/obj/item/portable_vendor/attack_self(mob/user)

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	if(broken)
		to_chat(user, "<span class='notice'>[src] is irrepairably broken.</span>")
		return

	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	var/obj/item/card/id/I = H.wear_id
	if(!istype(I)) //not wearing an ID
		to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
		return

	if(I.registered_name != H.real_name)
		to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
		return

	if(req_role && I.rank != req_role)
		to_chat(H, "<span class='warning'>This device isn't for you.</span>")
		return


	user.set_interaction(src)
	ui_interact(user)


/obj/item/portable_vendor/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0)

	if(!ishuman(user)) return

	var/list/display_list = list()


	for(var/i in 1 to listed_products.len)
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

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "portable_vendor.tmpl", name , 600, 700)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/item/portable_vendor/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(broken)
		return
	if(usr.incapacitated())
		return

	if (in_range(src, usr) && ishuman(usr))
		usr.set_interaction(src)
		if (href_list["vend"])

			if(!allowed(usr))
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				return

			var/mob/living/carbon/human/H = usr
			var/obj/item/card/id/I = H.wear_id
			if(!istype(I)) //not wearing an ID
				to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
				return

			if(I.registered_name != H.real_name)
				to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
				return

			if(req_role && I.rank != req_role)
				to_chat(H, "<span class='warning'>This device isn't for you.</span>")
				return

			var/idx=text2num(href_list["vend"])

			var/list/L = listed_products[idx]
			var/cost = L[2]

			if(use_points && points < cost)
				to_chat(H, "<span class='warning'>Not enough points.</span>")


			var/turf/T = loc
			if(T.contents.len > 25)
				to_chat(H, "<span class='warning'>The floor is too cluttered, make some space.</span>")
				return


			if(use_points)
				points -= cost

			purchase_log += "[usr] ([usr.ckey]) bought [L[1]]."

			playsound(src, "sound/machines/fax.ogg", 5)
			fabricating = 1
			update_overlays()
			spawn(30)
				var/type_p = L[3]
				var/obj/IT = new type_p(get_turf(src))
				if(loc == H)
					H.put_in_any_hand_if_possible(IT)
				fabricating = 0
				update_overlays()

		ui_interact(usr) //updates the nanoUI window


/obj/item/portable_vendor/proc/update_overlays()
	if(overlays) overlays.Cut()
	if (broken)
		overlays += image(icon, "securespark")
	else if (fabricating)
		overlays += image(icon, "secureb")
	else
		overlays += image(icon, "secure0")


/obj/item/portable_vendor/process()
	points = min(max_points, points+0.05)


/obj/item/portable_vendor/New()
	..()
	START_PROCESSING(SSobj, src)
	update_overlays()

/obj/item/portable_vendor/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()


/obj/item/portable_vendor/proc/malfunction()
	var/turf/T = get_turf(src)
	T.visible_message("<span class='warning'>[src] shudders as its internal components break apart!</span>")
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
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
			else
				malfunction()
		else
			if(prob(80))
				malfunction()


/obj/item/portable_vendor/corporate
	name = "\improper Nanotrasen Automated Storage Briefcase"
	desc = "A suitcase-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense small items. This one has the Nanotrasen logo stamped on its side."

	req_access_txt = "200"
	req_role = CORPORATE_LIAISON
	listed_products = list(
							list("INCENTIVES", 0, null, null, null),
							list("Neurostimulator Implant", 30, /obj/item/implanter/neurostim, "white", "Implant which regulates nociception and sensory function. Benefits include pain reduction, improved balance, and improved resistance to overstimulation and disoritentation. To encourage compliance, negative stimulus is applied if the implant hears a (non-radio) spoken codephrase. Implant will be degraded by the body's immune system over time, and thus malfunction with gradually increasing frequency. Personal use not recommended."),
							list("Ultrazine Pills", 20, /obj/item/storage/pill_bottle/restricted/ultrazine, "white", "Highly-addictive stimulant. Enhances short-term physical performance, particularly running speed. Effects last approximately 10 minutes per pill. More than two pills at a time will result in overdose. Withdrawal causes extreme discomfort and hallucinations. Long-term use results in halluciations and organ failure. Conditional distribution secures subject compliance. Not for personal use."),
							list("Cash", 2, /obj/item/spacecash/c500, "white", "$500 USD, unmarked bills"),
							list("Cigars", 5, /obj/item/storage/fancy/cigar, "white", "Case of premium cigars, untampered."),
							list("De Void of Soul", 51, /obj/item/clothing/under/liaison_suit/galaxy_blue, "white", "The latest in ultrafashion. for those with a cool demeanor."),
							list("Pulsar Gonne", 51, /obj/item/clothing/under/liaison_suit/galaxy_red, "white", "The latest in ultrafashion. for those with a fiery temper.")
							)

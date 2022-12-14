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
	return data

/obj/item/portable_vendor/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("vend")
			if(!allowed(usr))
				to_chat(usr, span_warning("Access denied."))
				return

			var/idx = text2num(params["vend"])

			var/list/L = listed_products[idx]
			var/cost = L[2]

			if(use_points && points < cost)
				to_chat(usr, span_warning("Not enough points."))


			var/turf/T = get_turf(src)
			if(length(T.contents) > 25)
				to_chat(usr, span_warning("The floor is too cluttered, make some space."))
				return


			if(use_points)
				points -= cost

			playsound(src, "sound/machines/fax.ogg", 5)
			to_chat(usr, span_notice("The automated system clunks as it starts to vend something."))
			fabricating = TRUE
			update_overlays()
			addtimer(CALLBACK(src, .proc/do_vend, L[3], usr), 3 SECONDS)

	updateUsrDialog()

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


/obj/item/portable_vendor/Initialize()
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
		list("De Void of Soul", 51, /obj/item/clothing/under/liaison_suit/galaxy_blue, "white", "The latest in ultrafashion. for those with a cool demeanor."),
		list("Pulsar Gonne", 51, /obj/item/clothing/under/liaison_suit/galaxy_red, "white", "The latest in ultrafashion. for those with a fiery temper.")
	)

// A marine version of the portable vendor, points are not regenerated.
/obj/item/portable_vendor/marine
	name = "\improper TerraGov Storage Backpack"
	desc = "A backpack-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense large kits during immediate operations. Can only vend one kit per person."
	icon_state = "marinepack"
	req_access = list(ACCESS_MARINE_PREP)
	points = 1
	max_points = 1

/obj/item/portable_vendor/marine/squadmarine
	name = "\improper TerraGov Squad Marine Storage Backpack"
	desc = "A backpack-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense large kits during immediate operations. Can only vend one kit per person. Has a tag saying that this backpack is only for Squad Marines."
	req_role = /datum/job/terragov/squad/standard
	listed_products = list(
		list("MARINE KITS", 0, null, null, null),
		list("Rifleman Kit (AR-12 assault rifle, medium armor)", 1, /obj/item/storage/box/squadmarine/rifleman, "white", "Rifleman kit containing a AR-12 assault rifle and magazines, two HE grenades, a flare pouch and medium armor. \n\
An all-round kit that does not specialize in anything, but shooting enemy combatants at any range. Has two grenades for flushing cover. Comes with a webbing for additional ammo."),
		list("Pointman Kit (AR-18 carbine, SH-35 shotgun, light armor)", 1, /obj/item/storage/box/squadmarine/pointman, "white", "Pointman kit containing a AR-18 carbine and magazines, a SH-35 shotgun with buckshot shells as a backup, two HE grenades, a shotgun shell pouch and light armor. \n\
A kit meant for rushing into the frontlines, using the carbine for swift target aquisition at medium ranges and a shotgun which is devastating a short ranges. Comes with a webbing for additional ammo."),
		list("Automatic Rifleman Kit (MG-42 light machinegun, heavy armor)", 1, /obj/item/storage/box/squadmarine/autorifleman, "white", "Rifleman kit containing a MG-42 light machinegun, its attachments and magazines, a M4A3 sidearm with magazines, an explosive pouch and heavy armor and helmet. \n\
A heavy kit containing a light machinegun, usful in surpressing fire against enemy combatants. Remove the pistol and magazines inside the satchel to compliment LMG magazines and full holster."),
		list("Designated Marksman Kit (BR-64 DMR, M43 lasgun, IS armor)", 1, /obj/item/storage/box/squadmarine/marksman, "white", "Marksman kit containing a BR-64 DMR, its attachments and magazines, a M43 lasgun as a backup, a flare pouch and integrated storage armor. \n\
A marksman kit containing two rifles for area denial and overwatch. It also contains a lasgun for fierce engagements."),
		list("Breacher Kit (SMG-90 submachinegun, light armor, heavy helmet)", 1, /obj/item/storage/box/squadmarine/breacher, "white", "Breacher kit containing a SMG-90 SMG, its attachment and magazines, a machete as a backup, an explosive pouch, heavy helmet and light armor. \n\
A breacher kit with the least firepower, has a high capacity SMG and a machete for self-defense. But can get through walls no problem.")
	)

/obj/item/portable_vendor/marine/squadmarine/engineer
	name = "\improper TerraGov Squad Engineer Storage Backpack"
	desc = "A backpack-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense large kits during immediate operations. Can only vend one kit per person. Has a tag saying that this backpack is only for Squad Engineers."
	req_role = /datum/job/terragov/squad/engineer
	listed_products = list(
		list("MARINE WEAPONS", 0, null, null, null),
		list("AR-12 Assault Rifle", 1, /obj/item/storage/box/squadmarine/engineert12, "white", "A kit containing a AR-12 assault rifle. Comes with a magnetic harness and a angled grip."),
		list("AR-18 Carbine", 1, /obj/item/storage/box/squadmarine/engineert18, "white", "A kit containing a AR-18 carbine. Comes with a magnetic harness and a angled grip."),
		list("SMG-90 Submachinegun", 1, /obj/item/storage/box/squadmarine/engineert90, "white", "A kit containing a SMG-90 SMG. Comes with a red dot sight. Contains a heavy helmet."),
		list("SH-35 Shotgun", 1, /obj/item/storage/box/squadmarine/engineert35, "white", "A kit containing a SH-35 shotgun. Comes with a magnetic harness, its respective stock and an angled grip. Contains a heavy helmet.")
	)

/obj/item/portable_vendor/marine/squadmarine/corpsman
	name = "\improper TerraGov Squad Corpsman Storage Backpack"
	desc = "A backpack-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense large kits during immediate operations. Can only vend one kit per person. Has a tag saying that this backpack is only for Squad Corpsmen."
	req_role = /datum/job/terragov/squad/corpsman
	listed_products = list(
		list("MARINE WEAPONS", 0, null, null, null),
		list("SMG-90 Submachinegun", 1, /obj/item/storage/box/squadmarine/corpsmant90, "white", "A kit containing a SMG-90 SMG. Comes with a red dot sight."),
		list("SH-35 Shotgun", 1, /obj/item/storage/box/squadmarine/corpsmant35, "white", "A kit containing a SH-35 shotgun. Comes with a magnetic harness, its respective stock and an angled grip.")
	)

/obj/item/portable_vendor/marine/squadmarine/smartgunner
	name = "\improper TerraGov Squad Smartgunner Storage Backpack"
	desc = "A backpack-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense large kits during immediate operations. Can only vend one kit per person. Has a tag saying that this backpack is only for Squad Smartgunners."
	req_role = /datum/job/terragov/squad/smartgunner
	listed_products = list(
		list("MARINE WEAPONS", 0, null, null, null),
		list("MP-19 Machine Pistol", 1, /obj/item/storage/box/squadmarine/smartgunnert19, "white", "A kit containing a MP-19 machine pistol and ammo."),
		list("M4A3 Pistol", 1, /obj/item/storage/box/squadmarine/smartgunnerm4a3, "white", "A kit containing a M4A3 pistol and ammo.")
	)

/obj/item/portable_vendor/marine/process()
	STOP_PROCESSING(SSobj, src)
	return FALSE

/obj/item/portable_vendor/marine/do_vend()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	qdel(src)

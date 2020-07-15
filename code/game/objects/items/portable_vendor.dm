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
	interaction_flags = INTERACT_OBJ_NANO

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
			to_chat(usr, "<span class='warning'>Access denied. Authorized roles only.</span>")
			return FALSE

		if(I.registered_name != user.real_name)
			return FALSE

		if(req_role)
			var/mob/living/living_user = user
			if(!istype(living_user.job, req_role))
				to_chat(usr, "<span class='warning'>Access denied. Authorized roles only.</span>")
				return FALSE

	return TRUE

/obj/item/portable_vendor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "PortableVendor", name, 600, 700, master_ui, state)
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

/obj/item/portable_vendor/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("vend")
			if(!allowed(usr))
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				return

			var/idx = text2num(params["vend"])

			var/list/L = listed_products[idx]
			var/cost = L[2]

			if(use_points && points < cost)
				to_chat(usr, "<span class='warning'>Not enough points.</span>")


			var/turf/T = get_turf(src)
			if(length(T.contents) > 25)
				to_chat(usr, "<span class='warning'>The floor is too cluttered, make some space.</span>")
				return


			if(use_points)
				points -= cost

			playsound(src, "sound/machines/fax.ogg", 5)
			to_chat(usr, "<span class='notice'>The automated system clunks as it starts to vend something.</span>")
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
		overlays += image(icon, "securespark")
	else if (fabricating)
		overlays += image(icon, "secureb")
	else
		overlays += image(icon, "secure0")


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
		if(EXPLODE_DEVASTATE)
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)
				return
			else
				malfunction()
		if(EXPLODE_LIGHT)
			if(prob(80))
				malfunction()


/obj/item/portable_vendor/corporate
	name = "\improper Nanotrasen Automated Storage Briefcase"
	desc = "A suitcase-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense small items. This one has the Nanotrasen logo stamped on its side."

	req_access = list(ACCESS_NT_CORPORATE)
	req_role = /datum/job/terragov/civilian/liaison
	listed_products = list(
							list("INCENTIVES", 0, null, null, null),
							list("Neurostimulator Implant", 30, /obj/item/implanter/neurostim, "white", "Implant which regulates nociception and sensory function. Benefits include pain reduction, improved balance, and improved resistance to overstimulation and disoritentation. To encourage compliance, negative stimulus is applied if the implant hears a (non-radio) spoken codephrase. Implant will be degraded by the body's immune system over time, and thus malfunction with gradually increasing frequency. Personal use not recommended."),
							list("Ultrazine Pills", 20, /obj/item/storage/pill_bottle/restricted/ultrazine, "white", "Highly-addictive stimulant. Enhances short-term physical performance, particularly running speed. Effects last approximately 10 minutes per pill. More than two pills at a time will result in overdose. Withdrawal causes extreme discomfort and hallucinations. Long-term use results in halluciations and organ failure. Conditional distribution secures subject compliance. Not for personal use."),
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
							list("Rifleman Kit (T-12 assault rifle, medium armor)", 1, /obj/item/storage/box/squadmarine/rifleman, "white", "Rifleman kit containing a T-12 assault rifle and magazines, two HE grenades, a flare pouch and medium armor. \n\
An all-round kit that does not specialize in anything, but shooting enemy combatants at any range. Has two grenades for flushing cover. Comes with a webbing for additional ammo."),
							list("Pointman Kit (T-18 carbine, T-35 shotgun, light armor)", 1, /obj/item/storage/box/squadmarine/pointman, "white", "Pointman kit containing a T-18 carbine and magazines, a T-35 shotgun with buckshot shells as a backup, two HE grenades, a shotgun shell pouch and light armor. \n\
A kit meant for rushing into the frontlines, using the carbine for swift target aquisition at medium ranges and a shotgun which is devastating a short ranges. Comes with a webbing for additional ammo."),
							list("Automatic Rifleman Kit (T-42 light machinegun, heavy armor)", 1, /obj/item/storage/box/squadmarine/autorifleman, "white", "Rifleman kit containing a T-42 light machinegun, its attachments and magazines, a M4A3 sidearm with magazines, an explosive pouch and heavy armor and helmet. \n\
A heavy kit containing a light machinegun, usful in surpressing fire against enemy combatants. Remove the pistol and magazines inside the satchel to compliment LMG magazines and full holster."),
							list("Designated Marksman Kit (T-64 DMR, M43 lasgun, IS armor)", 1, /obj/item/storage/box/squadmarine/marksman, "white", "Marksman kit containing a T-64 DMR, its attachments and magazines, a M43 lasgun as a backup, a flare pouch and integrated storage armor. \n\
A marksman kit containing two rifles for area denial and overwatch. It also contains a lasgun for fierce engagements."),
							list("Breacher Kit (T-90 submachinegun, light armor, heavy helmet)", 1, /obj/item/storage/box/squadmarine/breacher, "white", "Breacher kit containing a T-90 SMG, its attachment and magazines, a machete as a backup, an explosive pouch, heavy helmet and light armor. \n\
A breacher kit with the least firepower, has a high capacity SMG and a machete for self-defense. But can get through walls no problem.")
							)

/obj/item/portable_vendor/marine/squadmarine/engineer
	name = "\improper TerraGov Squad Engineer Storage Backpack"
	desc = "A backpack-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense large kits during immediate operations. Can only vend one kit per person. Has a tag saying that this backpack is only for Squad Engineers."
	req_role = /datum/job/terragov/squad/engineer
	listed_products = list(
							list("MARINE WEAPONS", 0, null, null, null),
							list("T-12 Assault Rifle", 1, /obj/item/storage/box/squadmarine/engineert12, "white", "A kit containing a T-12 assault rifle. Comes with a magnetic harness and a angled grip."),
							list("T-18 Carbine", 1, /obj/item/storage/box/squadmarine/engineert18, "white", "A kit containing a T-18 carbine. Comes with a magnetic harness and a angled grip."),
							list("T-90 Submachinegun", 1, /obj/item/storage/box/squadmarine/engineert90, "white", "A kit containing a T-90 SMG. Comes with a red dot sight. Contains a heavy helmet."),
							list("T-35 Shotgun", 1, /obj/item/storage/box/squadmarine/engineert35, "white", "A kit containing a T-35 shotgun. Comes with a magnetic harness, its respective stock and an angled grip. Contains a heavy helmet.")
							)

/obj/item/portable_vendor/marine/squadmarine/corpsman
	name = "\improper TerraGov Squad Corpsman Storage Backpack"
	desc = "A backpack-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense large kits during immediate operations. Can only vend one kit per person. Has a tag saying that this backpack is only for Squad Corpsmen."
	req_role = /datum/job/terragov/squad/corpsman
	listed_products = list(
							list("MARINE WEAPONS", 0, null, null, null),
							list("T-90 Submachinegun", 1, /obj/item/storage/box/squadmarine/corpsmant90, "white", "A kit containing a T-90 SMG. Comes with a red dot sight."),
							list("T-35 Shotgun", 1, /obj/item/storage/box/squadmarine/corpsmant35, "white", "A kit containing a T-35 shotgun. Comes with a magnetic harness, its respective stock and an angled grip.")
							)

/obj/item/portable_vendor/marine/squadmarine/smartgunner
	name = "\improper TerraGov Squad Smartgunner Storage Backpack"
	desc = "A backpack-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense large kits during immediate operations. Can only vend one kit per person. Has a tag saying that this backpack is only for Squad Smartgunners."
	req_role = /datum/job/terragov/squad/smartgunner
	listed_products = list(
							list("MARINE WEAPONS", 0, null, null, null),
							list("T-19 Machine Pistol", 1, /obj/item/storage/box/squadmarine/smartgunnert19, "white", "A kit containing a T-19 machine pistol and ammo."),
							list("M4A3 Pistol", 1, /obj/item/storage/box/squadmarine/smartgunnerm4a3, "white", "A kit containing a M4A3 pistol and ammo.")
							)

/obj/item/portable_vendor/marine/squadmarine/specialist
	name = "\improper TerraGov Squad Specialist Storage Backpack"
	desc = "A backpack-sized automated storage and retrieval system. Designed to efficiently store and selectively dispense large kits during immediate operations. Can only vend one kit per person. Has a faded tag saying that this backpack is only for Squad Specialists, you wonder if you are either lucky or just disappointed."
	req_role = /datum/job/terragov/squad/specialist
	listed_products = list(
							list("SPECIALIST KITS", 0, null, null, null),
							list("Demolitionist (RPG, T-19 MP)", 1, /obj/item/storage/box/squadmarine/demolitionist, "white", "A kit specializing in explosives."),
							list("Sniper (M42A Scoped Rifle, 88 Mod 4 Pistol)", 1, /obj/item/storage/box/squadmarine/sniper, "white", "A kit specializing in long-ranged dispatch."),
							list("Scout (M4RA Battle Rifle, 88 Mod 4 Pistol)", 1, /obj/item/storage/box/squadmarine/scout, "white", "A kit specializing in area scouting."),
							list("Tracker (MBX900 Lever-Action Shotgun, M1911 Pistol)", 1, /obj/item/storage/box/squadmarine/tracker, "white", "A kit specializing in chasing enemy targets."),
							list("Pyrotechician (TL-84 Flamethrower, T-19 MP)", 1, /obj/item/storage/box/squadmarine/pyro, "white", "A kit specializing in firey area denial."),
							list("Heavy Grenadier (M92 Grenade Launcher)", 1, /obj/item/storage/box/squadmarine/heavy_grenadier, "white", "A kit specializing in explosive area denial."),
							list("Heavy Minigunner (MIC-A7 Minigun, M4A3 Pistol)", 1, /obj/item/storage/box/squadmarine/heavy_gunner, "white", "A kit specializing in direct assault and tanking.")
							)

/obj/item/portable_vendor/marine/process()
	STOP_PROCESSING(SSobj, src)
	return FALSE

/obj/item/portable_vendor/marine/do_vend()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	qdel(src)

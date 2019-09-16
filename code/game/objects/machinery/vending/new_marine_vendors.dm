#define MARINE_CAN_BUY_UNIFORM 		1
#define MARINE_CAN_BUY_SHOES	 	2
#define MARINE_CAN_BUY_HELMET 		4
#define MARINE_CAN_BUY_ARMOR	 	8
#define MARINE_CAN_BUY_GLOVES 		16
#define MARINE_CAN_BUY_EAR	 		32
#define MARINE_CAN_BUY_BACKPACK 	64
#define MARINE_CAN_BUY_R_POUCH 		128
#define MARINE_CAN_BUY_L_POUCH 		256
#define MARINE_CAN_BUY_BELT 		512
#define MARINE_CAN_BUY_GLASSES		1024
#define MARINE_CAN_BUY_MASK			2048
#define MARINE_CAN_BUY_ESSENTIALS	4096
#define MARINE_CAN_BUY_ATTACHMENT	8192
#define MARINE_CAN_BUY_ATTACHMENT2	16384

#define MARINE_CAN_BUY_WEBBING		32768



#define MARINE_CAN_BUY_ALL			65535

#define MARINE_TOTAL_BUY_POINTS		45

/obj/item/card/id/var/marine_points = MARINE_TOTAL_BUY_POINTS
/obj/item/card/id/var/marine_buy_flags = MARINE_CAN_BUY_ALL



/obj/machinery/marine_selector
	name = "\improper Theoretical Marine selector"
	desc = ""
	icon = 'icons/obj/machines/vending.dmi'
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	req_access = null
	req_access_txt = "0"
	req_one_access = null
	req_one_access_txt = "0"
	interaction_flags = INTERACT_MACHINE_NANO

	var/gives_webbing = FALSE
	var/vendor_role = "" //to be compared with assigned_role to only allow those to use that machine.
	var/squad_tag = ""
	var/use_points = FALSE
	var/lock_flags = SQUAD_LOCK|JOB_LOCK

	var/icon_vend
	var/icon_deny

	var/list/listed_products

/obj/machinery/marine_selector/update_icon()
	if(is_operational())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"



/obj/machinery/marine_selector/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!allowed(H))
			return FALSE

		var/obj/item/card/id/I = H.get_idcard()
		if(!istype(I)) //not wearing an ID
			return FALSE

		if(I.registered_name != H.real_name)
			return FALSE

		if(lock_flags & JOB_LOCK && vendor_role && I.rank != vendor_role)
			return FALSE

		if(lock_flags & SQUAD_LOCK && (!H.assigned_squad || (squad_tag && H.assigned_squad.name != squad_tag)))
			return FALSE

	return TRUE


/obj/machinery/marine_selector/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0)
	var/list/display_list = list()

	var/m_points = 0
	var/buy_flags = NONE
	var/obj/item/card/id/I = user.get_idcard()
	if(istype(I)) //wearing an ID
		m_points = I.marine_points
		buy_flags = I.marine_buy_flags

	/*
		The marine vendor expects a certain format for the display_list JSON for nano.
		{
			"essentials": {
				"limits": 0,
				"notice": "Some text to help describe whats going on.",
				"products": [{<item>}, {<item>}, {<item>}, {<item>}, ]
			}
			"helmets": { ... },
			"belts": { ... },
		}

		An <item> consists of 
		{
			"name": "Marine belt",
			"available": true|false,
			"color": "#fff",
			"cost": 5
		}
	*/

	var/category_name = "" // current category

	for(var/i in 1 to length(listed_products))
		var/list/product = listed_products[i]

		// Utility items are not products and used for group management
		if(product[1] == "utility")

			// Format ["utility", "group/sub-group", "header_name", limits, "some long notice to show in this group under the header"]
			var/category_type = product[2] // group, sub-group
			if(category_type == "sub-group")
				var/subgroup = product[3]
				var/summary = product[5] // Helper text to show in the ui (optional)
				display_list[category_name]["products"] += list(list(
					"type" = category_type, 
					"name" = subgroup, 
					"summary" = summary, 
					"is_util" = TRUE
				))
				continue

			category_name = product[3]
			var/category_limits = product[4] // How many things can be purchased from this list
			var/summary = product[5] // Helper text to show in the ui (optional)

			display_list[category_name] = list(
				"name" = category_name,
				"limits" = category_limits,
				"summary" = summary,
				"products" = list()
			)
			continue

		// Format ["m56", "30", /obj/item/weapon/gun/something, R_BAG_SLOT, "#fff"]
		var/p_name = product[1]
		var/p_cost = product[2]
		// var/p_type = product[3]
		var/p_avail_flag = product[4]
		var/choice_type = product[5]
		if(p_cost > 0)
			p_name += " ([p_cost] points)"

		var/product_available = FALSE
		var/avail_flag = product[4]
		if((!avail_flag && m_points >= p_cost) || (buy_flags & p_avail_flag))
			product_available = TRUE

		display_list[category_name]["products"] += list(list(
			"id" = i,
			"name" = p_name, 
			"available" = product_available, 
			"type" = choice_type, 
			"cost" = p_cost,
			"is_util" = FALSE
		))

	var/list/data = list(
		"vendor_name" = name,
		"show_points" = use_points,
		"current_m_points" = m_points,
		"display_list" = display_list,
	)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "marine_selector.tmpl", name , 600, 700)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/machinery/marine_selector/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if (in_range(src, usr) && isturf(loc) && ishuman(usr))
		usr.set_interaction(src)
		if (href_list["vend"])

			if(!allowed(usr))
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				if(icon_deny)
					flick(icon_deny, src)
				return

			var/idx=text2num(href_list["vend"])

			var/list/L = listed_products[idx]
			var/mob/living/carbon/human/H = usr
			var/cost = L[2]

			var/obj/item/card/id/I = H.wear_id
			if(!istype(I)) //not wearing an ID
				to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
				if(icon_deny)
					flick(icon_deny, src)
				return

			if(I.registered_name != H.real_name)
				to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
				if(icon_deny)
					flick(icon_deny, src)
				return

			if(vendor_role && I.rank != vendor_role)
				to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
				if(icon_deny)
					flick(icon_deny, src)
				return

	if(href_list["vend"])
		if(!allowed(usr))
			to_chat(usr, "<span class='warning'>Access denied.</span>")
			if(icon_deny)
				flick(icon_deny, src)
			return

		var/idx = text2num(href_list["vend"])
		var/obj/item/card/id/I = usr.get_idcard()

		var/list/L = listed_products[idx]
		var/cost = L[2]

		if(use_points && I.marine_points < cost)
			to_chat(usr, "<span class='warning'>Not enough points.</span>")
			if(icon_deny)
				flick(icon_deny, src)
			return

		var/turf/T = loc
		if(length(T.contents) > 25)
			to_chat(usr, "<span class='warning'>The floor is too cluttered, make some space.</span>")
			if(icon_deny)
				flick(icon_deny, src)
			return

		var/bitf = L[4]
		if(bitf)
			if(bitf == MARINE_CAN_BUY_ESSENTIALS && vendor_role == SQUAD_SPECIALIST)
				if(!usr.mind || usr.mind.assigned_role != SQUAD_SPECIALIST)
					to_chat(usr, "<span class='warning'>Only specialists can take specialist sets.</span>")
					return
				else if(!usr.mind.cm_skills || usr.mind.cm_skills.spec_weapons != SKILL_SPEC_TRAINED)
					to_chat(usr, "<span class='warning'>You already have a specialist specialization.</span>")
					return
				var/p_name = L[1]
				if(findtext(p_name, "Scout Set")) //Makes sure there can only be one Scout kit taken despite the two variants.
					p_name = "Scout Set"
				else if(findtext(p_name, "Heavy Armor Set")) //Makes sure there can only be one Heavy kit taken despite the two variants.
					p_name = "Heavy Armor Set"
				if(!GLOB.available_specialist_sets.Find(p_name))
					to_chat(usr, "<span class='warning'>That set is already taken</span>")
					return

			var/bitf = L[4]
			if(bitf)
				if(bitf == MARINE_CAN_BUY_ESSENTIALS && vendor_role == SQUAD_SPECIALIST)
					if(!H.mind || H.mind.assigned_role != SQUAD_SPECIALIST)
						to_chat(H, "<span class='warning'>Only specialists can take specialist sets.</span>")
						return
					else if(!H.mind.cm_skills || H.mind.cm_skills.spec_weapons != SKILL_SPEC_TRAINED)
						to_chat(H, "<span class='warning'>You don't have the required skills to use specialist sets.</span>")
						return
					var/p_name = L[1]
					if(findtext(p_name, "Scout Set")) //Makes sure there can only be one Scout kit taken despite the two variants.
						p_name = "Scout Set"
					else if(findtext(p_name, "Heavy Armor Set")) //Makes sure there can only be one Heavy kit taken despite the two variants.
						p_name = "Heavy Armor Set"
					if(!GLOB.available_specialist_sets.Find(p_name))
						to_chat(H, "<span class='warning'>That set is already taken</span>")
						return

				if(I.marine_buy_flags & bitf)
					if(bitf == (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH))
						if(I.marine_buy_flags & MARINE_CAN_BUY_R_POUCH)
							I.marine_buy_flags &= ~MARINE_CAN_BUY_R_POUCH
						else
							I.marine_buy_flags &= ~MARINE_CAN_BUY_L_POUCH
					else if(bitf == (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2))
						if(I.marine_buy_flags & MARINE_CAN_BUY_ATTACHMENT)
							I.marine_buy_flags &= ~MARINE_CAN_BUY_ATTACHMENT
						else
							I.marine_buy_flags &= ~MARINE_CAN_BUY_ATTACHMENT2
					else
						I.marine_buy_flags &= ~MARINE_CAN_BUY_ATTACHMENT2
				else
					to_chat(H, "<span class='warning'>You can't buy things from this category anymore.</span>")
					return

			var/type_p = L[3]

			var/item = new type_p(loc)
			if(isitem(item))
				var/obj/item/O = item
				usr.put_in_hands(O)

			if(icon_vend)
				flick(icon_vend, src)

			if(bitf == MARINE_CAN_BUY_UNIFORM && ishumanbasic(usr))
				new /obj/item/radio/headset/mainship/marine(loc, H.assigned_squad.name, vendor_role)
				new /obj/item/clothing/gloves/marine(loc, H.assigned_squad.name, vendor_role)
				if(SSmapping.configs[GROUND_MAP].map_name == MAP_ICE_COLONY)
					new /obj/item/clothing/mask/rebreather/scarf(loc)

			if(bitf == MARINE_CAN_BUY_ESSENTIALS)
				if(vendor_role == SQUAD_SPECIALIST && H.mind && H.mind.assigned_role == SQUAD_SPECIALIST)
					var/p_name = L[1]
					if(findtext(p_name, "Scout Set")) //Makes sure there can only be one Scout kit taken despite the two variants.
						p_name = "Scout Set"
					else if(findtext(p_name, "Heavy Armor Set")) //Makes sure there can only be one Heavy kit taken despite the two variants.
						p_name = "Heavy Armor Set"
					if(p_name)
						H.specset = p_name
						I.assignment = p_name
					else
						CRASH("Selected specialist armour does not have a name set")
						return
					H.update_action_buttons()
					GLOB.available_specialist_sets -= p_name

			if(use_points)
				I.marine_points -= cost

		if(bitf == MARINE_CAN_BUY_ESSENTIALS && vendor_role == SQUAD_SPECIALIST && usr.mind && usr.mind.assigned_role == SQUAD_SPECIALIST && ishuman(usr))
			var/mob/living/carbon/human/H = usr
			var/p_name = L[1]
			if(findtext(p_name, "Scout Set")) //Makes sure there can only be one Scout kit taken despite the two variants.
				p_name = "Scout Set"
			else if(findtext(p_name, "Heavy Armor Set")) //Makes sure there can only be one Heavy kit taken despite the two variants.
				p_name = "Heavy Armor Set"
			if(p_name)
				H.specset = p_name
			H.update_action_buttons()
			GLOB.available_specialist_sets -= p_name

		if(use_points)
			I.marine_points -= cost

	updateUsrDialog()



/obj/machinery/marine_selector/clothes
	name = "GHMME Automated Closet"
	desc = "An automated closet hooked up to a colossal storage unit of standard-issue uniform and armor."
	icon_state = "marineuniform"
	vendor_role = SQUAD_MARINE

	listed_products = list(
		list("utility", "header", "STANDARD EQUIPMENT", -1, ""),
			list("Standard Kit", 0, /obj/effect/essentials_set/basic, MARINE_CAN_BUY_UNIFORM, "essential"),
		list("utility", "header", "ARMOR", 1, ""),
			list("Regular Armor", 0, /obj/item/clothing/suit/storage/marine, MARINE_CAN_BUY_ARMOR, "suggested"),
			list("Heavy Armor", 0, /obj/item/clothing/suit/storage/marine/M3HB, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Light Armor", 0, /obj/item/clothing/suit/storage/marine/M3LB, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Ballistic Armor", 0, /obj/item/clothing/suit/storage/marine/M3P, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Integrated Storage Armor", 0, /obj/item/clothing/suit/storage/marine/M3IS, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Edge Melee Armor", 0, /obj/item/clothing/suit/storage/marine/M3E, MARINE_CAN_BUY_ARMOR, "standard"),
		list("utility", "header", "BACKPACK", 1, ""),
			list("Satchel", 0, /obj/item/storage/backpack/marine/satchel, MARINE_CAN_BUY_BACKPACK, "suggested"),
			list("Backpack", 0, /obj/item/storage/backpack/marine/standard, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Shotgun scabbard", 0, /obj/item/storage/large_holster/m37, MARINE_CAN_BUY_BACKPACK, "standard"),
		list("utility", "header", "WEBBING", 1, ""),
			list("Tactical Black Vest", 0, /obj/item/clothing/tie/storage/black_vest, MARINE_CAN_BUY_WEBBING, "suggested"),
			list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "standard"),
			list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "standard"),
		list("utility", "header", "BELT", 1, ""),
			list("Standard ammo belt", 0, /obj/item/storage/belt/marine, MARINE_CAN_BUY_BELT, "suggested"),
			list("Shotgun ammo belt", 0, /obj/item/storage/belt/shotgun, MARINE_CAN_BUY_BELT, "standard"),
			list("Knives belt", 0, /obj/item/storage/belt/knifepouch, MARINE_CAN_BUY_BELT, "standard"),
			list("Pistol belt", 0, /obj/item/storage/belt/gun/m4a3, MARINE_CAN_BUY_BELT, "standard"),
			list("Revolver belt", 0, /obj/item/storage/belt/gun/m44, MARINE_CAN_BUY_BELT, "standard"),
		list("utility", "header", "POUCHES", 2, ""),
			list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "suggested"),
			list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "suggested"),
			list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "suggested"),
			list("Tool pouch (tools included)", 0, /obj/item/storage/pouch/tools/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Construction pouch (materials included)", 0, /obj/item/storage/pouch/construction/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Magazine pouch", 0, /obj/item/storage/pouch/magazine, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
		list("utility", "header", "MASKS", 1, ""),
			list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "standard"),
			list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "standard"),
			list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "standard"),
		
		list("utility", "header", "GUN ATTACHMENTS", 2, "This is a limited selection of attachments. Requisitions would have more."),
			list("utility", "sub-group", "Muzzle attachments", null, ""),
				list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "Rail attachments", null, ""),
				list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "Underbarrel attachments", null, ""),
				list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "Stocks", null, ""),
				list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
	)	



/obj/machinery/marine_selector/clothes/alpha
	squad_tag = "Alpha"
	req_access = list(ACCESS_MARINE_ALPHA)

/obj/machinery/marine_selector/clothes/bravo
	squad_tag = "Bravo"
	req_access = list(ACCESS_MARINE_BRAVO)

/obj/machinery/marine_selector/clothes/charlie
	squad_tag = "Charlie"
	req_access = list(ACCESS_MARINE_CHARLIE)

/obj/machinery/marine_selector/clothes/delta
	squad_tag = "Delta"
	req_access = list(ACCESS_MARINE_DELTA)


/obj/machinery/marine_selector/clothes/engi
	name = "GHMME Automated Engineer Closet"
	req_access = list(ACCESS_MARINE_ENGPREP)
	vendor_role = SQUAD_ENGINEER
	gives_webbing = FALSE

	listed_products = list(
		list("utility", "header", "STANDARD EQUIPMENT", -1, ""),
			list("Standard Kit", 0, /obj/effect/essentials_set/basic_engineer, MARINE_CAN_BUY_UNIFORM, "essential"),
		list("utility", "header", "ARMOR", 1, ""),
			list("Regular Armor", 0, /obj/item/clothing/suit/storage/marine, MARINE_CAN_BUY_ARMOR, "suggested"),
			list("Heavy Armor", 0, /obj/item/clothing/suit/storage/marine/M3HB, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Light Armor", 0, /obj/item/clothing/suit/storage/marine/M3LB, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Ballistic Armor", 0, /obj/item/clothing/suit/storage/marine/M3P, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Integrated Storage Armor", 0, /obj/item/clothing/suit/storage/marine/M3IS, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Edge Melee Armor", 0, /obj/item/clothing/suit/storage/marine/M3E, MARINE_CAN_BUY_ARMOR, "standard"),
		list("utility", "header", "BACKPACK", 1, ""),
			list("Satchel", 0, /obj/item/storage/backpack/marine/satchel/tech, MARINE_CAN_BUY_BACKPACK, "suggested"),
			list("Backpack", 0, /obj/item/storage/backpack/marine/tech, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Shotgun scabbard", 0, /obj/item/storage/large_holster/m37, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Machete scabbard", 0, /obj/item/storage/large_holster/machete/full, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Welderpack", 0, /obj/item/storage/backpack/marine/engineerpack, MARINE_CAN_BUY_BACKPACK, "standard"),
		list("utility", "header", "WEBBING", 1, ""),
			list("Tactical Black Vest", 0, /obj/item/clothing/tie/storage/black_vest, MARINE_CAN_BUY_WEBBING, "suggested"),
			list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "standard"),
			list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "standard"),
		list("utility", "header", "BELT", 1, ""),
			list("Tool belt", 0, /obj/item/storage/belt/utility/full, MARINE_CAN_BUY_BELT, "suggested"),
		list("utility", "header", "POUCHES", 2, ""),
			list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Construction pouch", 0, /obj/item/storage/pouch/construction, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "suggested"),
			list("Explosive pouch", 0, /obj/item/storage/pouch/explosive, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Tools pouch", 0, /obj/item/storage/pouch/tools/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Electronics pouch", 0, /obj/item/storage/pouch/electronics/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Magazine pouch", 0, /obj/item/storage/pouch/magazine, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Medium general pouch", 0, /obj/item/storage/pouch/general/medium, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "suggested"),
			list("Large pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
		list("utility", "header", "MASKS", 1, ""),
			list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "standard"),
			list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "standard"),
			list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "standard"),
	)

/obj/machinery/marine_selector/clothes/engi/alpha
	squad_tag = "Alpha"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_ALPHA)

/obj/machinery/marine_selector/clothes/engi/bravo
	squad_tag = "Bravo"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_BRAVO)

/obj/machinery/marine_selector/clothes/engi/charlie
	squad_tag = "Charlie"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_CHARLIE)

/obj/machinery/marine_selector/clothes/engi/delta
	squad_tag = "Delta"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_DELTA)



/obj/machinery/marine_selector/clothes/medic
	name = "GHMME Automated Corpsman Closet"
	req_access = list(ACCESS_MARINE_MEDPREP)
	vendor_role = SQUAD_CORPSMAN
	gives_webbing = FALSE

	listed_products = list(
		list("utility", "header", "STANDARD EQUIPMENT", -1, ""),
			list("Standard Kit", 0, /obj/effect/essentials_set/basic_medic, MARINE_CAN_BUY_UNIFORM, "essential"),
		list("utility", "header", "ARMOR", 1, ""),
			list("Regular Armor", 0, /obj/item/clothing/suit/storage/marine, MARINE_CAN_BUY_ARMOR, "suggested"),
			list("Heavy Armor", 0, /obj/item/clothing/suit/storage/marine/M3HB, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Light Armor", 0, /obj/item/clothing/suit/storage/marine/M3LB, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Ballistic Armor", 0, /obj/item/clothing/suit/storage/marine/M3P, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Integrated Storage Armor", 0, /obj/item/clothing/suit/storage/marine/M3IS, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Edge Melee Armor", 0, /obj/item/clothing/suit/storage/marine/M3E, MARINE_CAN_BUY_ARMOR, "standard"),
		list("utility", "header", "BACKPACK", 1, ""),
			list("Satchel", 0, /obj/item/storage/backpack/marine/satchel/corpsman, MARINE_CAN_BUY_BACKPACK, "suggested"),
			list("Backpack", 0, /obj/item/storage/backpack/marine/corpsman, MARINE_CAN_BUY_BACKPACK, "standard"),
		list("utility", "header", "WEBBING", 1, ""),
			list("Tactical Brown Vest", 0, /obj/item/clothing/tie/storage/brown_vest, MARINE_CAN_BUY_WEBBING, "suggested"),
			list("Corpsman White Vest", 0, /obj/item/clothing/tie/storage/white_vest/medic, MARINE_CAN_BUY_WEBBING, "standard"),
			list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "standard"),
			list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "standard"),
		list("utility", "header", "BELT", 1, ""),
			list("Lifesaver belt", 0, /obj/item/storage/belt/combatLifesaver, MARINE_CAN_BUY_BELT, "suggested"),
			list("Medical belt", 0, /obj/item/storage/belt/medical, MARINE_CAN_BUY_BELT, "standard"),
		list("utility", "header", "POUCHES", 2, ""),
			list("Medical pouch", 0, /obj/item/storage/pouch/medical, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "suggested"),
			list("Medkit pouch", 0, /obj/item/storage/pouch/medkit, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "suggested"),
			list("Autoinjector pouch", 0, /obj/item/storage/pouch/autoinjector, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Magazine pouch", 0, /obj/item/storage/pouch/magazine, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Medium general pouch", 0, /obj/item/storage/pouch/general/medium, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Large pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
		list("utility", "header", "MASKS", 1, ""),
			list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "standard"),
			list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "standard"),
			list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "standard"),
	)



/obj/machinery/marine_selector/clothes/medic/alpha
	squad_tag = "Alpha"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ALPHA)

/obj/machinery/marine_selector/clothes/medic/bravo
	squad_tag = "Bravo"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_BRAVO)

/obj/machinery/marine_selector/clothes/medic/charlie
	squad_tag = "Charlie"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_CHARLIE)

/obj/machinery/marine_selector/clothes/medic/delta
	squad_tag = "Delta"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_DELTA)



/obj/machinery/marine_selector/clothes/smartgun
	name = "GHMME Automated Smartgunner Closet"
	req_access = list(ACCESS_MARINE_SMARTPREP)
	vendor_role = SQUAD_SMARTGUNNER
	gives_webbing = FALSE

	listed_products = list(
		list("utility", "header", "STANDARD EQUIPMENT", -1, ""),
			list("Standard Kit", 0, /obj/effect/essentials_set/basic_smartgunner, MARINE_CAN_BUY_UNIFORM, "essential"),
		list("utility", "header", "WEBBING", 1, ""),
			list("Tactical Black Vest", 0, /obj/item/clothing/tie/storage/black_vest, MARINE_CAN_BUY_WEBBING, "suggested"),
			list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "standard"),
			list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "standard"),
		list("utility", "header", "BELT", 1, ""),
			list("M39 holster belt", 0, /obj/item/storage/large_holster/m39, MARINE_CAN_BUY_BELT, "suggested"),
			list("Standard ammo belt", 0, /obj/item/storage/belt/marine, MARINE_CAN_BUY_BELT, "standard"),
			list("Shotgun ammo belt", 0, /obj/item/storage/belt/shotgun, MARINE_CAN_BUY_BELT, "standard"),
			list("Knives belt", 0, /obj/item/storage/belt/knifepouch, MARINE_CAN_BUY_BELT, "standard"),
			list("Pistol belt", 0, /obj/item/storage/belt/gun/m4a3, MARINE_CAN_BUY_BELT, "standard"),
			list("Revolver belt", 0, /obj/item/storage/belt/gun/m44, MARINE_CAN_BUY_BELT, "standard"),
			list("G8 general utility pouch", 0, /obj/item/storage/belt/sparepouch, MARINE_CAN_BUY_BELT, "standard"),
		list("utility", "header", "POUCHES", 2, ""),
			list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Magazine pouch", 0, /obj/item/storage/pouch/magazine, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Medium general pouch", 0, /obj/item/storage/pouch/general/medium, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "suggested"),
			list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "suggested"),
			list("Large pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
		list("utility", "header", "MASKS", 1, ""),
			list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "standard"),
			list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "standard"),
			list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "standard"),
	)



/obj/machinery/marine_selector/clothes/smartgun/alpha
	squad_tag = "Alpha"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_ALPHA)

/obj/machinery/marine_selector/clothes/smartgun/bravo
	squad_tag = "Bravo"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_BRAVO)

/obj/machinery/marine_selector/clothes/smartgun/charlie
	squad_tag = "Charlie"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_CHARLIE)

/obj/machinery/marine_selector/clothes/smartgun/delta
	squad_tag = "Delta"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_DELTA)



/obj/machinery/marine_selector/clothes/specialist
	name = "GHMME Automated Specialist Closet"
	req_access = list(ACCESS_MARINE_SPECPREP)
	vendor_role = SQUAD_SPECIALIST
	gives_webbing = FALSE

	listed_products = list(
		list("utility", "header", "STANDARD EQUIPMENT", -1, "This kit includes all the standard Specialist equipment."),
			list("Standard Kit", 0, /obj/effect/essentials_set/basic_specialist, MARINE_CAN_BUY_UNIFORM, "essential"),

		list("utility", "header", "BACKPACK", 1, ""),
			list("Satchel", 0, /obj/item/storage/backpack/marine/satchel, MARINE_CAN_BUY_BACKPACK, "suggested"),
			list("Backpack", 0, /obj/item/storage/backpack/marine/standard, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Shotgun scabbard", 0, /obj/item/storage/large_holster/m37, MARINE_CAN_BUY_BACKPACK, "standard"),

		list("utility", "header", "WEBBING", 1, ""),
			list("Tactical Black Vest", 0, /obj/item/clothing/tie/storage/black_vest, MARINE_CAN_BUY_WEBBING, "standard"),
			list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "suggested"),
			list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "standard"),

		list("utility", "header", "BELT", 1, ""),
			list("Standard ammo belt", 0, /obj/item/storage/belt/marine, MARINE_CAN_BUY_BELT, "suggested"),
			list("M39 holster belt", 0, /obj/item/storage/large_holster/m39, MARINE_CAN_BUY_BELT, "standard"),
			list("Shotgun ammo belt", 0, /obj/item/storage/belt/shotgun, MARINE_CAN_BUY_BELT, "standard"),
			list("Knives belt", 0, /obj/item/storage/belt/knifepouch, MARINE_CAN_BUY_BELT, "standard"),
			list("Pistol belt", 0, /obj/item/storage/belt/gun/m4a3, MARINE_CAN_BUY_BELT, "standard"),
			list("Revolver belt", 0, /obj/item/storage/belt/gun/m44, MARINE_CAN_BUY_BELT, "standard"),
			list("G8 general utility pouch", 0, /obj/item/storage/belt/sparepouch, MARINE_CAN_BUY_BELT, "standard"),

		list("utility", "header", "POUCHES", 2, ""),
			list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "suggested"),
			list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "suggested"),
			list("Medium general pouch", 0, /obj/item/storage/pouch/general/medium, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Large magazine pouch", 0, /obj/item/storage/pouch/magazine/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Large pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Explosive pouch", 0, /obj/item/storage/pouch/explosive, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),

		list("utility", "header", "MASKS", 1, ""),
			list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "standard"),
			list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "standard"),
			list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "standard"),
	)



/obj/machinery/marine_selector/clothes/specialist/alpha
	squad_tag = "Alpha"
	req_access = list(ACCESS_MARINE_SPECPREP, ACCESS_MARINE_ALPHA)

/obj/machinery/marine_selector/clothes/specialist/bravo
	squad_tag = "Bravo"
	req_access = list(ACCESS_MARINE_SPECPREP, ACCESS_MARINE_BRAVO)

/obj/machinery/marine_selector/clothes/specialist/charlie
	squad_tag = "Charlie"
	req_access = list(ACCESS_MARINE_SPECPREP, ACCESS_MARINE_CHARLIE)

/obj/machinery/marine_selector/clothes/specialist/delta
	squad_tag = "Delta"
	req_access = list(ACCESS_MARINE_SPECPREP, ACCESS_MARINE_DELTA)



/obj/machinery/marine_selector/clothes/leader
	name = "GHMME Automated Leader Closet"
	req_access = list(ACCESS_MARINE_LEADER)
	vendor_role = SQUAD_LEADER
	gives_webbing = FALSE

	listed_products = list(
		list("utility", "header", "STANDARD EQUIPMENT", -1, ""),
			list("Standard Kit", 0, /obj/effect/essentials_set/basic_squadleader, MARINE_CAN_BUY_UNIFORM, "essential"),
		list("utility", "header", "BACKPACK", 1, ""),
			list("Satchel", 0, /obj/item/storage/backpack/marine/satchel, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Backpack", 0, /obj/item/storage/backpack/marine/standard, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Shotgun scabbard", 0, /obj/item/storage/large_holster/m37, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Machete scabbard", 0, /obj/item/storage/large_holster/machete/full, MARINE_CAN_BUY_BACKPACK, "standard"),
		list("utility", "header", "WEBBING", 1, ""),
			list("Tactical Black Vest", 0, /obj/item/clothing/tie/storage/black_vest, MARINE_CAN_BUY_WEBBING, "standard"),
			list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "standard"),
			list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "standard"),
		list("utility", "header", "BELT", 1, ""),
			list("Standard ammo belt", 0, /obj/item/storage/belt/marine, MARINE_CAN_BUY_BELT, "standard"),
			list("Shotgun ammo belt", 0, /obj/item/storage/belt/shotgun, MARINE_CAN_BUY_BELT, "standard"),
			list("M39 holster belt", 0, /obj/item/storage/large_holster/m39, MARINE_CAN_BUY_BELT, "standard"),
			list("Knives belt", 0, /obj/item/storage/belt/knifepouch, MARINE_CAN_BUY_BELT, "standard"),
			list("Pistol belt", 0, /obj/item/storage/belt/gun/m4a3, MARINE_CAN_BUY_BELT, "standard"),
			list("Revolver belt", 0, /obj/item/storage/belt/gun/m44, MARINE_CAN_BUY_BELT, "standard"),
			list("G8 general utility pouch", 0, /obj/item/storage/belt/sparepouch, MARINE_CAN_BUY_BELT, "standard"),
		list("utility", "header", "POUCHES", 2, ""),
			list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Large general pouch", 0, /obj/item/storage/pouch/general/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Large magazine pouch", 0, /obj/item/storage/pouch/magazine/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Medkit pouch", 0, /obj/item/storage/pouch/medkit, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Tool pouch (tools included)", 0, /obj/item/storage/pouch/tools/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Construction pouch (materials included)", 0, /obj/item/storage/pouch/construction/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Large pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Explosive pouch", 0, /obj/item/storage/pouch/explosive, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
		list("utility", "header", "MASKS", 1, ""),
			list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "standard"),
			list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "standard"),
			list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "standard"),
	)



/obj/machinery/marine_selector/clothes/leader/alpha
	squad_tag = "Alpha"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_ALPHA)

/obj/machinery/marine_selector/clothes/leader/bravo
	squad_tag = "Bravo"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_BRAVO)

/obj/machinery/marine_selector/clothes/leader/charlie
	squad_tag = "Charlie"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_CHARLIE)

/obj/machinery/marine_selector/clothes/leader/delta
	squad_tag = "Delta"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DELTA)



/obj/machinery/marine_selector/clothes/synth
	name = "M57 Synthetic Equipment Vendor"
	desc = "An automated synthetic equipment vendor hooked up to a modest storage unit."
	icon_state = "synth"
	icon_vend = "synth-vend"
	icon_deny = "synth-deny"
	vendor_role = "Synthetic"
	lock_flags = JOB_LOCK

	listed_products = list(
		list("utility", "header", "STANDARD EQUIPMENT", -1, ""),
			list("Essential Synthetic Set", 0, /obj/effect/essentials_set/synth, MARINE_CAN_BUY_ESSENTIALS, "essential"),
		list("utility", "header", "UNIFORM", 1, ""),
			list("TGMC marine uniform", 0, /obj/item/clothing/under/marine, MARINE_CAN_BUY_UNIFORM, "standard"),
			list("Medical scrubs", 0, /obj/item/clothing/under/rank/medical/green, MARINE_CAN_BUY_UNIFORM, "standard"),
			list("Engineering uniform", 0, /obj/item/clothing/under/marine/officer/engi, MARINE_CAN_BUY_UNIFORM, "standard"),
			list("Officer uniform", 0, /obj/item/clothing/under/marine/officer/logistics, MARINE_CAN_BUY_UNIFORM, "standard"),
			list("TGMC dress uniform", 0, /obj/item/clothing/under/whites, MARINE_CAN_BUY_UNIFORM, "standard"),
			list("Pilot bodysuit", 0, /obj/item/clothing/under/marine/officer/pilot, MARINE_CAN_BUY_UNIFORM, "standard"),
			list("Military police uniform", 0, /obj/item/clothing/under/marine/mp, MARINE_CAN_BUY_UNIFORM, "standard"),
			list("Researcher outfit", 0, /obj/item/clothing/under/marine/officer/researcher, MARINE_CAN_BUY_UNIFORM, "standard"),
			list("Chef uniform", 0, /obj/item/clothing/under/rank/chef, MARINE_CAN_BUY_UNIFORM, "standard"),
			list("Bartender uniform", 0, /obj/item/clothing/under/rank/bartender, MARINE_CAN_BUY_UNIFORM, "standard"),
		list("utility", "header", "OUTERWEAR", 1, ""),
			list("Hazard vest", 0, /obj/item/clothing/suit/storage/hazardvest, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Surgical apron", 0, /obj/item/clothing/suit/surgical , MARINE_CAN_BUY_ARMOR, "standard"),
			list("Labcoat", 0, /obj/item/clothing/suit/storage/labcoat, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Researcher's labcoat", 0, /obj/item/clothing/suit/storage/labcoat/researcher, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Snow suit", 0, /obj/item/clothing/suit/storage/snow_suit , MARINE_CAN_BUY_ARMOR, "standard"),
			list("M70 flak jacket", 0, /obj/item/clothing/suit/armor/vest/pilot, MARINE_CAN_BUY_ARMOR, "standard"),
			list("N2 pattern MA armor", 0, /obj/item/clothing/suit/storage/marine/MP, MARINE_CAN_BUY_ARMOR, "standard"),
			list("M3 pattern officer armor", 0, /obj/item/clothing/suit/storage/marine/MP/RO, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Chef's apron", 0, /obj/item/clothing/suit/chef, MARINE_CAN_BUY_ARMOR, "standard"),
			list("Waistcoat", 0, /obj/item/clothing/suit/wcoat, MARINE_CAN_BUY_ARMOR, "standard"),
		list("utility", "header", "BACKPACK", 1, ""),
			list("Satchel", 0, /obj/item/storage/backpack/marine/satchel, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Lightweight IMP backpack", 0, /obj/item/storage/backpack/marine, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Industrial backpack", 0, /obj/item/storage/backpack/industrial, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("TGMC corpsman backpack", 0, /obj/item/storage/backpack/marine/corpsman, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("TGMC technician backpack", 0, /obj/item/storage/backpack/marine/tech , MARINE_CAN_BUY_BACKPACK, "standard"),
			list("TGMC technician welderpack", 0, /obj/item/storage/backpack/marine/engineerpack , MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Lightweight combat pack", 0, /obj/item/storage/backpack/lightpack, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Officer cloak", 0, /obj/item/storage/backpack/marine/satchel/officer_cloak, MARINE_CAN_BUY_BACKPACK, "standard"),
			list("Officer cloak, red", 0, /obj/item/storage/backpack/marine/satchel/officer_cloak_red, MARINE_CAN_BUY_BACKPACK, "standard"),
		list("utility", "header", "WEBBING", 1, ""),
			list("Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "standard"),
			list("Tactical Black Vest", 0, /obj/item/clothing/tie/storage/black_vest, MARINE_CAN_BUY_WEBBING, "standard"),
			list("White medical vest", 0, /obj/item/clothing/tie/storage/white_vest/medic, MARINE_CAN_BUY_WEBBING, "standard"),
		list("utility", "header", "GLOVES", 1, ""),
			list("Insulated gloves", 0, /obj/item/clothing/gloves/yellow, MARINE_CAN_BUY_GLOVES, "standard"),
			list("Latex gloves", 0, /obj/item/clothing/gloves/latex , MARINE_CAN_BUY_GLOVES, "standard"),
			list("Officer gloves", 0, /obj/item/clothing/gloves/marine/officer, MARINE_CAN_BUY_GLOVES, "standard"),
			list("White gloves", 0, /obj/item/clothing/gloves/white, MARINE_CAN_BUY_GLOVES, "standard"),
		list("utility", "header", "BELT", 1, ""),
			list("M276 pattern medical storage rig", 0, /obj/item/storage/belt/medical, MARINE_CAN_BUY_BELT, "standard"),
			list("M276 pattern lifesaver bag", 0, /obj/item/storage/belt/combatLifesaver, MARINE_CAN_BUY_BELT, "standard"),
			list("M276 pattern toolbelt rig", 0, /obj/item/storage/belt/utility/full, MARINE_CAN_BUY_BELT, "standard"),
			list("M276 pattern security rig ", 0, /obj/item/storage/belt/security/MP/full, MARINE_CAN_BUY_BELT, "standard"),
			list("G8 general utility pouch", 0, /obj/item/storage/belt/sparepouch, MARINE_CAN_BUY_BELT, "standard"),
		list("utility", "header", "SHOES", 1, ""),
			list("Marine combat boots", 0, /obj/item/clothing/shoes/marine, MARINE_CAN_BUY_SHOES, "standard"),
			list("White shoes", 0, /obj/item/clothing/shoes/white, MARINE_CAN_BUY_SHOES, "standard"),
			list("Formal shoes", 0, /obj/item/clothing/shoes/marinechief, MARINE_CAN_BUY_SHOES, "standard"),
		list("utility", "header", "POUCHES", 2, ""),
			list("Large general pouch", 0, /obj/item/storage/pouch/general/large , (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Tool pouch", 0, /obj/item/storage/pouch/tools/full , (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Construction pouch", 0, /obj/item/storage/pouch/construction/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Electronics pouch", 0, /obj/item/storage/pouch/electronics/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Medical pouch", 0, /obj/item/storage/pouch/medical, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Medkit pouch", 0, /obj/item/storage/pouch/medkit , (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Autoinjector pouch", 0, /obj/item/storage/pouch/autoinjector, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Radio pouch", 0, /obj/item/storage/pouch/radio, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
			list("Field pouch", 0, /obj/item/storage/pouch/field_pouch/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "standard"),
		list("utility", "header", "HATS", 1, ""),
			list("Hard hat", 0, /obj/item/clothing/head/hardhat, MARINE_CAN_BUY_HELMET, "standard"),
			list("Welding helmet", 0, /obj/item/clothing/head/welding , MARINE_CAN_BUY_HELMET, "standard"),
			list("Surgical cap", 0, /obj/item/clothing/head/surgery/green, MARINE_CAN_BUY_HELMET, "standard"),
			list("TGMC cap", 0, /obj/item/clothing/head/tgmccap, MARINE_CAN_BUY_HELMET, "standard"),
			list("Boonie hat", 0, /obj/item/clothing/head/boonie, MARINE_CAN_BUY_HELMET, "standard"),
			list("Marine beret", 0, /obj/item/clothing/head/beret/marine, MARINE_CAN_BUY_HELMET, "standard"),
			list("MP beret", 0, /obj/item/clothing/head/tgmcberet/red, MARINE_CAN_BUY_HELMET, "standard"),
			list("Engineering beret", 0, /obj/item/clothing/head/beret/eng, MARINE_CAN_BUY_HELMET, "standard"),
			list("Ushanka", 0, /obj/item/clothing/head/ushanka, MARINE_CAN_BUY_HELMET, "standard"),
			list("Top hat", 0, /obj/item/clothing/head/collectable/tophat, MARINE_CAN_BUY_HELMET, "standard"),
		list("utility", "header", "MASKS", 1, ""),
			list("Sterile mask", 0, /obj/item/clothing/mask/surgical, MARINE_CAN_BUY_MASK, "standard"),
			list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "standard"),
			list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "standard"),
			list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "standard"),
	)



////////////////////// Gear ////////////////////////////////////////////////////////



/obj/machinery/marine_selector/gear
	name = "NEXUS Automated Equipment Rack"
	desc = "An automated equipment rack hooked up to a colossal storage unit."
	icon_state = "marinearmory"
	use_points = TRUE
	listed_products = list(
		list("utility", "header", "GUN ATTACHMENTS", 1, ""),
			list("Vertical Grip", 0, /obj/item/attachable/verticalgrip, MARINE_CAN_BUY_ATTACHMENT, "standard"),
			list("Red-dot sight", 0, /obj/item/attachable/reddot, MARINE_CAN_BUY_ATTACHMENT, "standard"),
			list("Recoil Compensator", 0, /obj/item/attachable/compensator, MARINE_CAN_BUY_ATTACHMENT, "standard"),
			list("Laser Sight", 0, /obj/item/attachable/lasersight,  MARINE_CAN_BUY_ATTACHMENT, "standard")
	)


/obj/machinery/marine_selector/gear/medic
	name = "NEXUS Automated Medical Equipment Rack"
	desc = "An automated medic equipment rack hooked up to a colossal storage unit."
	icon_state = "medic"
	vendor_role = SQUAD_CORPSMAN
	req_access = list(ACCESS_MARINE_MEDPREP)

	listed_products = list(
		list("utility", "header", "ESSENTIAL MEDICAL EQUIPMENT", -1, ""),
			list("Essential Medic Set", 0, /obj/effect/essentials_set/medic, MARINE_CAN_BUY_ESSENTIALS, "essential"),
		list("utility", "header", "MEDICAL SUPPLIES", -1, ""),
			list("utility", "sub-group", "General Supplies", -1, ""),
				list("Medical splints", 1, /obj/item/stack/medical/splint, null, "suggested"),
				list("Adv trauma kit", 1, /obj/item/stack/medical/advanced/bruise_pack, null, "suggested"),
				list("Adv burn kit", 1, /obj/item/stack/medical/advanced/ointment, null, "suggested"),
				list("Roller Bed", 4, /obj/item/roller, null, "suggested"),
				list("Firstaid kit", 6, /obj/item/storage/firstaid/regular, null, "standard"),
				list("Advanced firstaid kit", 8, /obj/item/storage/firstaid/adv, null, "suggested"),
				list("Stasis bag", 4, /obj/item/bodybag/cryobag, null, "suggested"),
			list("utility", "sub-group", "Pillbottles", -1, ""),
				list("Pillbottle (Hypervene)", 4, /obj/item/storage/pill_bottle/hypervene, null, "standard"),
				list("Pillbottle (Quick-Clot)", 4, /obj/item/storage/pill_bottle/quickclot, null, "standard"),
				list("Pillbottle (Bicaridine)", 4, /obj/item/storage/pill_bottle/bicaridine, null, "suggested"),
				list("Pillbottle (Kelotane)", 4, /obj/item/storage/pill_bottle/kelotane, null, "suggested"),
				list("Pillbottle (Dylovene)", 4, /obj/item/storage/pill_bottle/dylovene, null, "standard"),
				list("Pillbottle (Dexalin)", 4, /obj/item/storage/pill_bottle/dexalin, null, "standard"),
				list("Pillbottle (Tramadol)", 4, /obj/item/storage/pill_bottle/tramadol, null, "suggested"),
				list("Pillbottle (Inaprovaline)", 4, /obj/item/storage/pill_bottle/inaprovaline, null, "standard"),
				list("Pillbottle (Peridaxon)", 4, /obj/item/storage/pill_bottle/peridaxon, null, "standard"),
				list("Pillbottle (Spaceacillin)", 4, /obj/item/storage/pill_bottle/spaceacillin, null, "standard"),
			list("utility", "sub-group", "Injectors", -1, ""),
				list("Injector (Inaprovaline)", 1, /obj/item/reagent_container/hypospray/autoinjector/inaprovaline, null, "standard"),
				list("Injector (Bicaridine)", 1, /obj/item/reagent_container/hypospray/autoinjector/bicaridine, null, "standard"),
				list("Injector (Kelotane)", 1, /obj/item/reagent_container/hypospray/autoinjector/kelotane, null, "standard"),
				list("Injector (Dylovene)", 1, /obj/item/reagent_container/hypospray/autoinjector/dylovene, null, "standard"),
				list("Injector (Dexalin+)", 1, /obj/item/reagent_container/hypospray/autoinjector/dexalinplus, null, "standard"),
				list("Injector (Quick-Clot)", 1, /obj/item/reagent_container/hypospray/autoinjector/quickclot, null, "standard"),
				list("Injector (Oxycodone)", 1, /obj/item/reagent_container/hypospray/autoinjector/oxycodone, null, "standard"),
				list("Injector (Tricord)", 1, /obj/item/reagent_container/hypospray/autoinjector/tricordrazine, null, "standard"),
				list("Injector (Hypervene)", 1, /obj/item/reagent_container/hypospray/autoinjector/hypervene, null, "standard"),
			list("utility", "sub-group", "Misc", -1, ""),
				list("Advanced hypospray", 2, /obj/item/reagent_container/hypospray/advanced, null, "standard"),
				list("Health analyzer", 2, /obj/item/healthanalyzer, null, "standard"),
				list("Medical HUD glasses", 2, /obj/item/clothing/glasses/hud/health, null, "standard"),

		list("utility", "header", "SPECIAL AMMUNITION", -1, ""),
			list("AP M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/ap, null, "standard"),
			list("Extended M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/extended, null, "standard"),
			list("AP M39 magazine", 6, /obj/item/ammo_magazine/smg/m39/ap, null, "standard"),
			list("Extended M39 magazine", 6, /obj/item/ammo_magazine/smg/m39/extended, null, "standard"),

		list("utility", "header", "GUN ATTACHMENTS", 2, ""),
			list("utility", "sub-group", "MUZZLE ATTACHMENTS", -1, ""),
				list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "RAIL ATTACHMENTS", -1, ""),
				list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "UNDERBARREL ATTACHMENTS", -1, ""),
				list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
			list("utility", "sub-group", "STOCKS", -1, ""),
				list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
	)

/obj/machinery/marine_selector/gear/engi
	name = "NEXUS Automated Engineer Equipment Rack"
	desc = "An automated engineer equipment rack hooked up to a colossal storage unit."
	icon_state = "engineer"
	vendor_role = SQUAD_ENGINEER
	req_access = list(ACCESS_MARINE_ENGPREP)

	listed_products = list(
		list("utility", "header", "ESSENTIAL ENGINEER EQUIPMENT", -1, ""),
			list("Essential Engineer Set", 0, /obj/effect/essentials_set/engi, MARINE_CAN_BUY_ESSENTIALS, "essential"),

		list("utility", "header", "ENGINEER SUPPLIES", -1, ""),
			list("Metal x10", 5, /obj/item/stack/sheet/metal/small_stack, null, "suggested"),
			list("Plasteel x10", 7, /obj/item/stack/sheet/plasteel/small_stack, null, "suggested"),
			list("Sandbags x25", 10, /obj/item/stack/sandbags_empty/half, null, "suggested"),
			list("Plasma cutter", 20, /obj/item/tool/pickaxe/plasmacutter, null, "standard"),
			list("UA-580 point defense sentry kit", 26, /obj/item/storage/box/minisentry, null, "standard"),
			list("Plastique explosive", 3, /obj/item/explosive/plastique, null, "standard"),
			list("Detonation pack", 5, /obj/item/radio/detpack, null, "standard"),
			list("Entrenching tool", 1, /obj/item/tool/shovel/etool, null, "standard"),
			list("Range Finder", 10, /obj/item/binoculars/tactical/range, null, "standard"),
			list("High capacity powercell", 1, /obj/item/cell/high, null, "standard"),
			list("M20 mine box", 18, /obj/item/storage/box/explosive_mines, null, "standard"),
			list("Incendiary grenade", 6, /obj/item/explosive/grenade/incendiary, null, "standard"),
			list("Multitool", 1, /obj/item/multitool, null, "standard"),
			list("General circuit board", 1, /obj/item/circuitboard/general, null, "standard"),
			list("Signaler (for detpacks)", 1, /obj/item/assembly/signaler, null, "standard"),

		list("utility", "header", "SPECIAL AMMUNITION", -1, ""),
			list("AP M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/ap, null, "standard"),
			list("Extended M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/extended, null, "standard"),
			list("AP M41A1 magazine", 6, /obj/item/ammo_magazine/rifle/ap, null, "standard"),
			list("Extended M41A1 magazine", 6, /obj/item/ammo_magazine/rifle/extended, null, "standard"),
			list("AP M39 magazine", 5, /obj/item/ammo_magazine/smg/m39/ap, null, "standard"),
			list("Extended M39 magazine", 5, /obj/item/ammo_magazine/smg/m39/extended, null, "standard"),

		list("utility", "header", "GUN ATTACHMENTS", 2, ""),
			list("utility", "sub-group", "MUZZLE ATTACHMENTS", -1, ""),
				list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "RAIL ATTACHMENTS", -1, ""),
				list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "UNDERBARREL ATTACHMENTS", -1, ""),
				list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
			list("utility", "sub-group", "STOCKS", -1, ""),
				list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
	)



/obj/machinery/marine_selector/gear/smartgun
	name = "NEXUS Automated Smartgunner Equipment Rack"
	desc = "An automated smartgunner equipment rack hooked up to a colossal storage unit."
	icon_state = "smartgunner"
	vendor_role = SQUAD_SMARTGUNNER
	req_access = list(ACCESS_MARINE_SMARTPREP)

	listed_products = list(
		list("utility", "header", "ESSENTIAL SMARTGUNNER EQUIPMENT", -1, ""),
			list("Essential Smartgunner Set", 0, /obj/item/storage/box/m56_system, MARINE_CAN_BUY_ESSENTIALS, "essential"),

		list("utility", "header", "SPECIAL AMMUNITION", -1, ""),
			list("M56 powerpack", 45, /obj/item/smartgun_powerpack, null, "standard"),
			list("AP M4A3 magazine", 10, /obj/item/ammo_magazine/pistol/ap, null, "standard"),
			list("Extended M4A3 magazine", 10, /obj/item/ammo_magazine/pistol/extended, null, "standard"),
			list("AP M41A1 magazine", 15, /obj/item/ammo_magazine/rifle/ap, null, "standard"),
			list("Extended M41A1 magazine", 15, /obj/item/ammo_magazine/rifle/extended, null, "standard"),
			list("AP M39 magazine", 13, /obj/item/ammo_magazine/smg/m39/ap, null, "standard"),
			list("Extended M39 magazine", 13, /obj/item/ammo_magazine/smg/m39/extended, null, "standard"),

		list("utility", "header", "GUN ATTACHMENTS", 2, ""),
			list("utility", "sub-group", "MUZZLE ATTACHMENTS", -1, ""),
				list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "RAIL ATTACHMENTS", -1, ""),
				list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "UNDERBARREL ATTACHMENTS", -1, ""),
				list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
			list("utility", "sub-group", "STOCKS", -1, ""),
				list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
	)


//todo: move this to some sort of kit controller/datum
//the global list of specialist sets that haven't been claimed yet.
GLOBAL_LIST_INIT(available_specialist_sets, list("Scout Set", "Sniper Set", "Demolitionist Set", "Heavy Armor Set", "Pyro Set"))


/obj/machinery/marine_selector/gear/spec
	name = "NEXUS Automated Specialist Equipment Rack"
	desc = "An automated specialist equipment rack hooked up to a colossal storage unit."
	icon_state = "specialist"
	vendor_role = SQUAD_SPECIALIST
	req_access = list(ACCESS_MARINE_SPECPREP)

	listed_products = list(
		list("utility", "header", "SPECIALIST SETS", 1, ""),
			list("Scout Set (Battle Rifle)", 0, /obj/item/storage/box/spec/scout, MARINE_CAN_BUY_ESSENTIALS, "essential"),
			list("Scout Set (Shotgun)", 0, /obj/item/storage/box/spec/scoutshotgun, MARINE_CAN_BUY_ESSENTIALS, "essential"),
			list("Sniper Set", 0, /obj/item/storage/box/spec/sniper, MARINE_CAN_BUY_ESSENTIALS, "essential"),
			list("Demolitionist Set", 0, /obj/item/storage/box/spec/demolitionist, MARINE_CAN_BUY_ESSENTIALS, "essential"),
			list("Heavy Armor Set (Grenadier)", 0, /obj/item/storage/box/spec/heavy_grenadier, MARINE_CAN_BUY_ESSENTIALS, "essential"),
			list("Heavy Armor Set (Minigun)", 0, /obj/item/storage/box/spec/heavy_gunner, MARINE_CAN_BUY_ESSENTIALS, "essential"),
			list("Pyro Set", 0, /obj/item/storage/box/spec/pyro, MARINE_CAN_BUY_ESSENTIALS, "essential"),

		list("utility", "header", "SPECIAL AMMUNITION", -1, ""),
			list("AP M4A3 magazine", 10, /obj/item/ammo_magazine/pistol/ap, null, "standard"),
			list("Extended M4A3 magazine", 10, /obj/item/ammo_magazine/pistol/extended, null, "standard"),
			list("88M4 AP magazine", 15, /obj/item/ammo_magazine/pistol/vp70, null, "standard"),
			list("M44 marksman speed loader", 15, /obj/item/ammo_magazine/revolver/marksman, null, "standard"),
			list("AP M41A1 magazine", 15, /obj/item/ammo_magazine/rifle/ap, null, "standard"),
			list("Extended M41A1 magazine", 15, /obj/item/ammo_magazine/rifle/extended, null, "standard"),
			list("AP M39 magazine", 13, /obj/item/ammo_magazine/smg/m39/ap, null, "standard"),
			list("Extended M39 magazine", 13, /obj/item/ammo_magazine/smg/m39/extended, null, "standard"),

		list("utility", "header", "GUN ATTACHMENTS", 2, ""),
			list("utility", "sub-group", "MUZZLE ATTACHMENTS", -1, ""),
				list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "RAIL ATTACHMENTS", -1, ""),
				list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "UNDERBARREL ATTACHMENTS", -1, ""),
				list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
			list("utility", "sub-group", "STOCKS", -1, ""),
				list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
	)


/obj/machinery/marine_selector/gear/leader
	name = "NEXUS Automated Squad Leader Equipment Rack"
	desc = "An automated squad leader equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	vendor_role = SQUAD_LEADER
	req_access = list(ACCESS_MARINE_LEADER)

	listed_products = list(
		list("utility", "header", "SQUAD LEADER ESSENTIAL EQUIPMENT", -1, ""),
			list("Essential SL Set", 0, /obj/effect/essentials_set/leader, MARINE_CAN_BUY_ESSENTIALS, "essential"),

		list("utility", "header", "LEADER SUPPLIES", -1, ""),
			list("Supply beacon", 10, /obj/item/squad_beacon, null, "standard"),
			list("Orbital beacon", 15, /obj/item/squad_beacon/bomb, null, "standard"),
			list("Entrenching tool", 1, /obj/item/tool/shovel/etool, null, "standard"),
			list("Sandbags x25", 10, /obj/item/stack/sandbags_empty/half, null, "standard"),
			list("Plastique explosive", 3, /obj/item/explosive/plastique, null, "standard"),
			list("Detonation pack", 5, /obj/item/radio/detpack, null, "standard"),
			list("Smoke grenade", 2, /obj/item/explosive/grenade/smokebomb, null, "standard"),
			list("Cloak grenade", 3, /obj/item/explosive/grenade/cloakbomb, null, "standard"),
			list("M40 HIDP incendiary grenade", 3, /obj/item/explosive/grenade/incendiary, null, "standard"),
			list("M40 HEDP grenade", 3, /obj/item/explosive/grenade/frag, null, "standard"),
			list("M40 IMDP grenade", 3, /obj/item/explosive/grenade/impact, null, "standard"),
			list("M41AE2 heavy pulse rifle", 12, /obj/item/weapon/gun/rifle/lmg, null, "suggested"),
			list("M41AE2 magazine", 4, /obj/item/ammo_magazine/rifle/lmg, null, "standard"),
			list("Flamethrower", 12, /obj/item/weapon/gun/flamer, null, "suggested"),
			list("Flamethrower tank", 4, /obj/item/ammo_magazine/flamer_tank, null, "standard"),
			list("Whistle", 5, /obj/item/whistle, null, "standard"),
			list("Station bounced radio", 1, /obj/item/radio, null, "standard"),
			list("Signaler (for detpacks)", 1, /obj/item/assembly/signaler, null, "standard"),
			list("Motion detector", 5, /obj/item/motiondetector, null, "standard"),
			list("Advanced firstaid kit", 10, /obj/item/storage/firstaid/adv, null, "suggested"),
			list("Ziptie box", 5, /obj/item/storage/box/zipcuffs, null, "standard"),
			list("V1 thermal-dampening tarp", 5, /obj/structure/closet/bodybag/tarp, null, "standard"),

		list("utility", "header", "SPECIAL AMMUNITION", -1, ""),
			list("HP M4A3 magazine", 5, /obj/item/ammo_magazine/pistol/hp, null, "standard"),
			list("AP M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/ap, null, "standard"),
			list("Extended M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/extended, null, "standard"),
			list("AP M41A1 magazine", 6, /obj/item/ammo_magazine/rifle/ap, null, "standard"),
			list("Extended M41A1 magazine", 6, /obj/item/ammo_magazine/rifle/extended, null, "standard"),
			list("AP M39 magazine", 5, /obj/item/ammo_magazine/smg/m39/ap, null, "standard"),
			list("Extended M39 magazine", 5, /obj/item/ammo_magazine/smg/m39/extended, null, "standard"),

		list("utility", "header", "GUN ATTACHMENTS", 2, ""),
			list("utility", "sub-group", "MUZZLE ATTACHMENTS", -1, ""),
				list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "RAIL ATTACHMENTS", -1, ""),
				list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
				list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
			list("utility", "sub-group", "UNDERBARREL ATTACHMENTS", -1, ""),
				list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "suggested"),
			list("utility", "sub-group", "STOCKS", -1, ""),
				list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
				list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "standard"),
	)


/obj/effect/essentials_set
	var/list/spawned_gear_list

/obj/effect/essentials_set/New(loc)
	. = ..()
	for(var/typepath in spawned_gear_list)
		if(spawned_gear_list[typepath])
			new typepath(loc, spawned_gear_list[typepath])
		else
			new typepath(loc)
	qdel(src)


/obj/effect/essentials_set/basic
	spawned_gear_list = list(
						/obj/item/clothing/head/helmet/marine,
						/obj/item/clothing/under/marine,
						/obj/item/clothing/shoes/marine,
						/obj/item/weapon/combat_knife,
						/obj/item/storage/box/MRE,
						)


/obj/effect/essentials_set/basic_smartgunner
	spawned_gear_list = list(
						/obj/item/clothing/head/helmet/marine,
						/obj/item/clothing/under/marine,
						/obj/item/clothing/shoes/marine,
						/obj/item/weapon/combat_knife,
						/obj/item/storage/box/MRE
						)

/obj/effect/essentials_set/basic_specialist
	spawned_gear_list = list(
						/obj/item/clothing/under/marine,
						/obj/item/clothing/shoes/marine,
						/obj/item/weapon/combat_knife,
						/obj/item/storage/box/MRE
						)

/obj/effect/essentials_set/basic_squadleader
	spawned_gear_list = list(
						/obj/item/clothing/suit/storage/marine/leader,
						/obj/item/clothing/head/helmet/marine/leader,
						/obj/item/clothing/glasses/hud/health,
						/obj/item/clothing/under/marine,
						/obj/item/clothing/shoes/marine,
						/obj/item/weapon/combat_knife,
						/obj/item/storage/box/MRE
						)

/obj/effect/essentials_set/basic_medic
	spawned_gear_list = list(
						/obj/item/clothing/head/helmet/marine/corpsman,
						/obj/item/clothing/glasses/hud/health,
						/obj/item/clothing/under/marine/corpsman,
						/obj/item/clothing/shoes/marine,
						/obj/item/weapon/combat_knife,
						/obj/item/storage/box/MRE
						)

/obj/effect/essentials_set/basic_engineer
	spawned_gear_list = list(
						/obj/item/clothing/head/helmet/marine/tech,
						/obj/item/clothing/glasses/welding,
						/obj/item/clothing/under/marine/engineer,
						/obj/item/clothing/shoes/marine,
						/obj/item/weapon/combat_knife,
						/obj/item/storage/box/MRE
						)

/obj/effect/essentials_set/medic
	spawned_gear_list = list(
						/obj/item/bodybag/cryobag,
						/obj/item/defibrillator,
						/obj/item/healthanalyzer,
						/obj/item/roller/medevac,
						/obj/item/medevac_beacon,
						/obj/item/roller,
						/obj/item/reagent_container/hypospray/advanced/oxycodone,
						)

/obj/effect/essentials_set/engi
	spawned_gear_list = list(
						/obj/item/explosive/plastique,
						/obj/item/stack/sandbags_empty = 25,
						/obj/item/stack/sheet/metal/small_stack,
						/obj/item/cell/high,
						/obj/item/tool/shovel/etool,
						/obj/item/lightreplacer,
						/obj/item/circuitboard/general,
						)


/obj/effect/essentials_set/leader
	spawned_gear_list = list(
						/obj/item/explosive/plastique,
						/obj/item/squad_beacon,
						/obj/item/squad_beacon,
						/obj/item/squad_beacon/bomb,
						/obj/item/whistle,
						/obj/item/radio,
						/obj/item/motiondetector,
						/obj/item/map/current_map,
						/obj/item/binoculars/tactical,
						)


/obj/effect/essentials_set/synth
	spawned_gear_list = list(
						/obj/item/stack/sheet/plasteel/medium_stack,
						/obj/item/stack/sheet/metal/large_stack,
						/obj/item/lightreplacer,
						/obj/item/healthanalyzer,
						/obj/item/defibrillator,
						/obj/item/medevac_beacon,
						/obj/item/roller/medevac,
						/obj/item/bodybag/cryobag,
						/obj/item/reagent_container/hypospray/advanced/oxycodone
						)

		



#undef MARINE_CAN_BUY_UNIFORM
#undef MARINE_CAN_BUY_SHOES
#undef MARINE_CAN_BUY_HELMET
#undef MARINE_CAN_BUY_ARMOR
#undef MARINE_CAN_BUY_GLOVES
#undef MARINE_CAN_BUY_EAR
#undef MARINE_CAN_BUY_BACKPACK
#undef MARINE_CAN_BUY_R_POUCH
#undef MARINE_CAN_BUY_L_POUCH
#undef MARINE_CAN_BUY_BELT
#undef MARINE_CAN_BUY_GLASSES
#undef MARINE_CAN_BUY_MASK
#undef MARINE_CAN_BUY_ESSENTIALS

#undef MARINE_CAN_BUY_ALL
#undef MARINE_TOTAL_BUY_POINTS
#undef SQUAD_LOCK
#undef JOB_LOCK

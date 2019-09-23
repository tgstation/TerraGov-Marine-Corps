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


	for(var/i in 1 to listed_products.len)
		var/list/myprod = listed_products[i]
		var/p_name = myprod[1]
		var/p_cost = myprod[2]
		if(p_cost > 0)
			p_name += " ([p_cost] points)"

		var/prod_available = FALSE
		var/avail_flag = myprod[4]
		if((!avail_flag && m_points >= p_cost) || (buy_flags & avail_flag))
			prod_available = TRUE

								//place in main list, name, cost, available or not, color.
		display_list += list(list("prod_index" = i, "prod_name" = p_name, "prod_available" = prod_available, "prod_color" = myprod[5]))


	var/list/data = list(
		"vendor_name" = name,
		"show_points" = use_points,
		"current_m_points" = m_points,
		"displayed_records" = display_list,
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
					I.marine_buy_flags &= ~bitf
			else
				to_chat(usr, "<span class='warning'>You can't buy things from this category anymore.</span>")
				return

		var/type_p = L[3]

		new type_p(loc)

		if(icon_vend)
			flick(icon_vend, src)

		if(bitf == MARINE_CAN_BUY_UNIFORM && ishumanbasic(usr))
			var/mob/living/carbon/human/H = usr
			new /obj/item/radio/headset/mainship/marine(loc, H.assigned_squad.name, vendor_role)
			new /obj/item/clothing/gloves/marine(loc, H.assigned_squad.name, vendor_role)
			if(SSmapping.configs[GROUND_MAP].map_name == MAP_ICE_COLONY)
				new /obj/item/clothing/mask/rebreather/scarf(loc)


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
							list("STANDARD EQUIPMENT (take all)", 0, null, null, null),
							list("Standard Kit", 0, /obj/effect/essentials_set/basic, MARINE_CAN_BUY_UNIFORM, "white"),
							list("ARMOR (choose 1)", 0, null, null, null),
							list("Regular Armor", 0, /obj/item/clothing/suit/storage/marine, MARINE_CAN_BUY_ARMOR, "orange"),
							list("Heavy Armor", 0, /obj/item/clothing/suit/storage/marine/M3HB, MARINE_CAN_BUY_ARMOR, "black"),
							list("Light Armor", 0, /obj/item/clothing/suit/storage/marine/M3LB, MARINE_CAN_BUY_ARMOR, "black"),
							list("Ballistic Armor", 0, /obj/item/clothing/suit/storage/marine/M3P, MARINE_CAN_BUY_ARMOR, "black"),
							list("Integrated Storage Armor", 0, /obj/item/clothing/suit/storage/marine/M3IS, MARINE_CAN_BUY_ARMOR, "black"),
							list("Edge Melee Armor", 0, /obj/item/clothing/suit/storage/marine/M3E, MARINE_CAN_BUY_ARMOR, "black"),
							list("Harness", 0, /obj/item/clothing/suit/storage/marine/harness, MARINE_CAN_BUY_ARMOR, "black"),
							list("BACKPACK (choose 1)", 0, null, null, null),
							list("Satchel", 0, /obj/item/storage/backpack/marine/satchel, MARINE_CAN_BUY_BACKPACK, "orange"),
							list("Backpack", 0, /obj/item/storage/backpack/marine/standard, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Shotgun scabbard", 0, /obj/item/storage/large_holster/m37, MARINE_CAN_BUY_BACKPACK, "black"),
							list("WEBBING (choose 1)", 0, null, null, null),
							list("Tactical Black Vest", 0, /obj/item/clothing/tie/storage/black_vest, MARINE_CAN_BUY_WEBBING, "orange"),
							list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "black"),
							list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "black"),
							list("BELT (choose 1)", 0, null, null, null),
							list("Standard ammo belt", 0, /obj/item/storage/belt/marine, MARINE_CAN_BUY_BELT, "orange"),
							list("Shotgun ammo belt", 0, /obj/item/storage/belt/shotgun, MARINE_CAN_BUY_BELT, "black"),
							list("Knives belt", 0, /obj/item/storage/belt/knifepouch, MARINE_CAN_BUY_BELT, "black"),
							list("Pistol belt", 0, /obj/item/storage/belt/gun/m4a3, MARINE_CAN_BUY_BELT, "black"),
							list("Revolver belt", 0, /obj/item/storage/belt/gun/m44, MARINE_CAN_BUY_BELT, "black"),
							list("POUCHES (choose 2)", 0, null, null, null),
							list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							list("Magazine pouch", 0, /obj/item/storage/pouch/magazine, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							list("Tool pouch (tools included)", 0, /obj/item/storage/pouch/tools/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Construction pouch (materials included)", 0, /obj/item/storage/pouch/construction/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("MASKS", 0, null, null, null),
							list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "black"),
							list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "black"),
							list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "black"),
							list("GUN ATTACHMENTS (Choose 2)", 0, null, null, null),
							list("MUZZLE ATTACHMENTS", 0, null, null, null),
							list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("RAIL ATTACHMENTS", 0, null, null, null),
							list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("UNDERBARREL ATTACHMENTS", 0, null, null, null),
							list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("STOCKS", 0, null, null, null),
							list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
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
							list("STANDARD EQUIPMENT (take all)", 0, null, null, null),
							list("Standard Kit", 0, /obj/effect/essentials_set/basic_engineer, MARINE_CAN_BUY_UNIFORM, "white"),
							list("ARMOR (choose 1)", 0, null, null, null),
							list("Regular Armor", 0, /obj/item/clothing/suit/storage/marine, MARINE_CAN_BUY_ARMOR, "orange"),
							list("Heavy Armor", 0, /obj/item/clothing/suit/storage/marine/M3HB, MARINE_CAN_BUY_ARMOR, "black"),
							list("Light Armor", 0, /obj/item/clothing/suit/storage/marine/M3LB, MARINE_CAN_BUY_ARMOR, "black"),
							list("Ballistic Armor", 0, /obj/item/clothing/suit/storage/marine/M3P, MARINE_CAN_BUY_ARMOR, "black"),
							list("Integrated Storage Armor", 0, /obj/item/clothing/suit/storage/marine/M3IS, MARINE_CAN_BUY_ARMOR, "black"),
							list("Edge Melee Armor", 0, /obj/item/clothing/suit/storage/marine/M3E, MARINE_CAN_BUY_ARMOR, "black"),
							list("Harness", 0, /obj/item/clothing/suit/storage/marine/harness, MARINE_CAN_BUY_ARMOR, "black"),
							list("BACKPACK (choose 1)", 0, null, null, null),
							list("Satchel", 0, /obj/item/storage/backpack/marine/satchel/tech, MARINE_CAN_BUY_BACKPACK, "orange"),
							list("Backpack", 0, /obj/item/storage/backpack/marine/tech, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Shotgun scabbard", 0, /obj/item/storage/large_holster/m37, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Machete scabbard", 0, /obj/item/storage/large_holster/machete/full, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Welderpack", 0, /obj/item/storage/backpack/marine/engineerpack, MARINE_CAN_BUY_BACKPACK, "black"),
							list("WEBBING (choose 1)", 0, null, null, null),
							list("Tactical Brown Vest", 0, /obj/item/clothing/tie/storage/brown_vest, MARINE_CAN_BUY_WEBBING, "orange"),
							list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "black"),
							list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "black"),
							list("BELT (choose 1)", 0, null, null, null),
							list("Tool belt", 0, /obj/item/storage/belt/utility/full, MARINE_CAN_BUY_BELT, "orange"),
							list("POUCHES (choose 2)", 0, null, null, null),
							list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Construction pouch", 0, /obj/item/storage/pouch/construction, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							list("Explosive pouch", 0, /obj/item/storage/pouch/explosive, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Tools pouch", 0, /obj/item/storage/pouch/tools/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Electronics pouch", 0, /obj/item/storage/pouch/electronics/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Magazine pouch", 0, /obj/item/storage/pouch/magazine, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Medium general pouch", 0, /obj/item/storage/pouch/general/medium, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							list("Large pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("MASKS", 0, null, null, null),
							list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "black"),
							list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "black"),
							list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "black"),
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
							list("STANDARD EQUIPMENT (take all)", 0, null, null, null),
							list("Standard Kit", 0, /obj/effect/essentials_set/basic_medic, MARINE_CAN_BUY_UNIFORM, "white"),
							list("ARMOR (choose 1)", 0, null, null, null),
							list("Regular Armor", 0, /obj/item/clothing/suit/storage/marine, MARINE_CAN_BUY_ARMOR, "orange"),
							list("Heavy Armor", 0, /obj/item/clothing/suit/storage/marine/M3HB, MARINE_CAN_BUY_ARMOR, "black"),
							list("Light Armor", 0, /obj/item/clothing/suit/storage/marine/M3LB, MARINE_CAN_BUY_ARMOR, "black"),
							list("Ballistic Armor", 0, /obj/item/clothing/suit/storage/marine/M3P, MARINE_CAN_BUY_ARMOR, "black"),
							list("Integrated Storage Armor", 0, /obj/item/clothing/suit/storage/marine/M3IS, MARINE_CAN_BUY_ARMOR, "black"),
							list("Edge Melee Armor", 0, /obj/item/clothing/suit/storage/marine/M3E, MARINE_CAN_BUY_ARMOR, "black"),
							list("Harness", 0, /obj/item/clothing/suit/storage/marine/harness, MARINE_CAN_BUY_ARMOR, "black"),
							list("BACKPACK (choose 1)", 0, null, null, null),
							list("Satchel", 0, /obj/item/storage/backpack/marine/satchel/corpsman, MARINE_CAN_BUY_BACKPACK, "orange"),
							list("Backpack", 0, /obj/item/storage/backpack/marine/corpsman, MARINE_CAN_BUY_BACKPACK, "black"),
							list("WEBBING (choose 1)", 0, null, null, null),
							list("Tactical Brown Vest", 0, /obj/item/clothing/tie/storage/brown_vest, MARINE_CAN_BUY_WEBBING, "orange"),
							list("Corpsman White Vest", 0, /obj/item/clothing/tie/storage/white_vest/medic, MARINE_CAN_BUY_WEBBING, "black"),
							list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "black"),
							list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "black"),
							list("BELT (choose 1)", 0, null, null, null),
							list("Lifesaver belt", 0, /obj/item/storage/belt/combatLifesaver, MARINE_CAN_BUY_BELT, "orange"),
							list("Medical belt", 0, /obj/item/storage/belt/medical, MARINE_CAN_BUY_BELT, "black"),
							list("POUCHES (choose 2)", 0, null, null, null),
							list("Medical pouch", 0, /obj/item/storage/pouch/medical, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							list("Medkit pouch", 0, /obj/item/storage/pouch/medkit, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							list("Autoinjector pouch", 0, /obj/item/storage/pouch/autoinjector, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Magazine pouch", 0, /obj/item/storage/pouch/magazine, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Medium general pouch", 0, /obj/item/storage/pouch/general/medium, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Large pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("MASKS", 0, null, null, null),
							list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "black"),
							list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "black"),
							list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "black"),
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
							list("STANDARD EQUIPMENT (take all)", 0, null, null, null),
							list("Standard Kit", 0, /obj/effect/essentials_set/basic_smartgunner, MARINE_CAN_BUY_UNIFORM, "white"),
							list("WEBBING (choose 1)", 0, null, null, null),
							list("Tactical Black Vest", 0, /obj/item/clothing/tie/storage/black_vest, MARINE_CAN_BUY_WEBBING, "orange"),
							list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "black"),
							list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "black"),
							list("BELT (choose 1)", 0, null, null, null),
							list("M39 holster belt", 0, /obj/item/storage/large_holster/m39, MARINE_CAN_BUY_BELT, "orange"),
							list("Standard ammo belt", 0, /obj/item/storage/belt/marine, MARINE_CAN_BUY_BELT, "black"),
							list("Shotgun ammo belt", 0, /obj/item/storage/belt/shotgun, MARINE_CAN_BUY_BELT, "black"),
							list("Knives belt", 0, /obj/item/storage/belt/knifepouch, MARINE_CAN_BUY_BELT, "black"),
							list("Pistol belt", 0, /obj/item/storage/belt/gun/m4a3, MARINE_CAN_BUY_BELT, "black"),
							list("Revolver belt", 0, /obj/item/storage/belt/gun/m44, MARINE_CAN_BUY_BELT, "black"),
							list("G8 general utility pouch", 0, /obj/item/storage/belt/sparepouch, MARINE_CAN_BUY_BELT, "black"),
							list("POUCHES (choose 2)", 0, null, null, null),
							list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Magazine pouch", 0, /obj/item/storage/pouch/magazine, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Medium general pouch", 0, /obj/item/storage/pouch/general/medium, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							list("Large pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("MASKS", 0, null, null, null),
							list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "black"),
							list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "black"),
							list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "black"),
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
							list("STANDARD EQUIPMENT (take all)", 0, null, null, null),
							list("Standard Kit", 0, /obj/effect/essentials_set/basic_specialist, MARINE_CAN_BUY_UNIFORM, "white"),
							list("BACKPACK (choose 1)", 0, null, null, null),
							list("Satchel", 0, /obj/item/storage/backpack/marine/satchel, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Backpack", 0, /obj/item/storage/backpack/marine/standard, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Shotgun scabbard", 0, /obj/item/storage/large_holster/m37, MARINE_CAN_BUY_BACKPACK, "black"),
							list("WEBBING (choose 1)", 0, null, null, null),
							list("Tactical Black Vest", 0, /obj/item/clothing/tie/storage/black_vest, MARINE_CAN_BUY_WEBBING, "black"),
							list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "black"),
							list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "black"),
							list("BELT (choose 1)", 0, null, null, null),
							list("M39 holster belt", 0, /obj/item/storage/large_holster/m39, MARINE_CAN_BUY_BELT, "black"),
							list("Standard ammo belt", 0, /obj/item/storage/belt/marine, MARINE_CAN_BUY_BELT, "black"),
							list("Shotgun ammo belt", 0, /obj/item/storage/belt/shotgun, MARINE_CAN_BUY_BELT, "black"),
							list("Knives belt", 0, /obj/item/storage/belt/knifepouch, MARINE_CAN_BUY_BELT, "black"),
							list("Pistol belt", 0, /obj/item/storage/belt/gun/m4a3, MARINE_CAN_BUY_BELT, "black"),
							list("Revolver belt", 0, /obj/item/storage/belt/gun/m44, MARINE_CAN_BUY_BELT, "black"),
							list("G8 general utility pouch", 0, /obj/item/storage/belt/sparepouch, MARINE_CAN_BUY_BELT, "black"),
							list("POUCHES (choose 2)", 0, null, null, null),
							list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Large magazine pouch", 0, /obj/item/storage/pouch/magazine/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Medium general pouch", 0, /obj/item/storage/pouch/general/medium, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Large pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Explosive pouch", 0, /obj/item/storage/pouch/explosive, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("MASKS", 0, null, null, null),
							list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "black"),
							list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "black"),
							list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "black"),
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
							list("STANDARD EQUIPMENT (take all)", 0, null, null, null),
							list("Standard Kit", 0, /obj/effect/essentials_set/basic_squadleader, MARINE_CAN_BUY_UNIFORM, "white"),
							list("BACKPACK (choose 1)", 0, null, null, null),
							list("Satchel", 0, /obj/item/storage/backpack/marine/satchel, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Backpack", 0, /obj/item/storage/backpack/marine/standard, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Shotgun scabbard", 0, /obj/item/storage/large_holster/m37, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Machete scabbard", 0, /obj/item/storage/large_holster/machete/full, MARINE_CAN_BUY_BACKPACK, "black"),
							list("WEBBING (choose 1)", 0, null, null, null),
							list("Tactical Black Vest", 0, /obj/item/clothing/tie/storage/black_vest, MARINE_CAN_BUY_WEBBING, "black"),
							list("Tactical Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "black"),
							list("Shoulder Handgun Holster", 0, /obj/item/clothing/tie/holster, MARINE_CAN_BUY_WEBBING, "black"),
							list("BELT (choose 1)", 0, null, null, null),
							list("Standard ammo belt", 0, /obj/item/storage/belt/marine, MARINE_CAN_BUY_BELT, "black"),
							list("Shotgun ammo belt", 0, /obj/item/storage/belt/shotgun, MARINE_CAN_BUY_BELT, "black"),
							list("M39 holster belt", 0, /obj/item/storage/large_holster/m39, MARINE_CAN_BUY_BELT, "black"),
							list("Knives belt", 0, /obj/item/storage/belt/knifepouch, MARINE_CAN_BUY_BELT, "black"),
							list("Pistol belt", 0, /obj/item/storage/belt/gun/m4a3, MARINE_CAN_BUY_BELT, "black"),
							list("Revolver belt", 0, /obj/item/storage/belt/gun/m44, MARINE_CAN_BUY_BELT, "black"),
							list("G8 general utility pouch", 0, /obj/item/storage/belt/sparepouch, MARINE_CAN_BUY_BELT, "black"),
							list("POUCHES (choose 2)", 0, null, null, null),
							list("Shotgun shell pouch", 0, /obj/item/storage/pouch/shotgun, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Large general pouch", 0, /obj/item/storage/pouch/general/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Large magazine pouch", 0, /obj/item/storage/pouch/magazine/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Firstaid pouch", 0, /obj/item/storage/pouch/firstaid/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Medkit pouch", 0, /obj/item/storage/pouch/medkit, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Tool pouch (tools included)", 0, /obj/item/storage/pouch/tools/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Construction pouch (materials included)", 0, /obj/item/storage/pouch/construction/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Large pistol magazine pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Sidearm pouch", 0, /obj/item/storage/pouch/pistol, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Explosive pouch", 0, /obj/item/storage/pouch/explosive, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("MASKS", 0, null, null, null),
							list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "black"),
							list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "black"),
							list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "black"),
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
							list("STANDARD EQUIPMENT", 0, null, null, null),
							list("Essential Synthetic Set", 0, /obj/effect/essentials_set/synth, MARINE_CAN_BUY_ESSENTIALS, "white"),
							list("UNIFORM (choose 1)", 0, null, null, null),
							list("TGMC marine uniform", 0, /obj/item/clothing/under/marine, MARINE_CAN_BUY_UNIFORM, "black"),
							list("Medical scrubs", 0, /obj/item/clothing/under/rank/medical/green, MARINE_CAN_BUY_UNIFORM, "black"),
							list("Engineering uniform", 0, /obj/item/clothing/under/marine/officer/engi, MARINE_CAN_BUY_UNIFORM, "black"),
							list("Officer uniform", 0, /obj/item/clothing/under/marine/officer/logistics, MARINE_CAN_BUY_UNIFORM, "black"),
							list("TGMC dress uniform", 0, /obj/item/clothing/under/whites, MARINE_CAN_BUY_UNIFORM, "black"),
							list("Pilot bodysuit", 0, /obj/item/clothing/under/marine/officer/pilot, MARINE_CAN_BUY_UNIFORM, "black"),
							list("Military police uniform", 0, /obj/item/clothing/under/marine/mp, MARINE_CAN_BUY_UNIFORM, "black"),
							list("Researcher outfit", 0, /obj/item/clothing/under/marine/officer/researcher, MARINE_CAN_BUY_UNIFORM, "black"),
							list("Chef uniform", 0, /obj/item/clothing/under/rank/chef, MARINE_CAN_BUY_UNIFORM, "black"),
							list("Bartender uniform", 0, /obj/item/clothing/under/rank/bartender, MARINE_CAN_BUY_UNIFORM, "black"),
							list("OUTERWEAR (choose 1)", 0, null, null, null),
							list("Hazard vest", 0, /obj/item/clothing/suit/storage/hazardvest, MARINE_CAN_BUY_ARMOR, "black"),
							list("Surgical apron", 0, /obj/item/clothing/suit/surgical , MARINE_CAN_BUY_ARMOR, "black"),
							list("Labcoat", 0, /obj/item/clothing/suit/storage/labcoat, MARINE_CAN_BUY_ARMOR, "black"),
							list("Researcher's labcoat", 0, /obj/item/clothing/suit/storage/labcoat/researcher, MARINE_CAN_BUY_ARMOR, "black"),
							list("Snow suit", 0, /obj/item/clothing/suit/storage/snow_suit , MARINE_CAN_BUY_ARMOR, "black"),
							list("M70 flak jacket", 0, /obj/item/clothing/suit/armor/vest/pilot, MARINE_CAN_BUY_ARMOR, "black"),
							list("N2 pattern MA armor", 0, /obj/item/clothing/suit/storage/marine/MP, MARINE_CAN_BUY_ARMOR, "black"),
							list("M3 pattern officer armor", 0, /obj/item/clothing/suit/storage/marine/MP/RO, MARINE_CAN_BUY_ARMOR, "black"),
							list("Chef's apron", 0, /obj/item/clothing/suit/chef, MARINE_CAN_BUY_ARMOR, "black"),
							list("Waistcoat", 0, /obj/item/clothing/suit/wcoat, MARINE_CAN_BUY_ARMOR, "black"),
							list("BACKPACK (choose 1)", 0, null, null, null),
							list("Satchel", 0, /obj/item/storage/backpack/marine/satchel, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Lightweight IMP backpack", 0, /obj/item/storage/backpack/marine, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Industrial backpack", 0, /obj/item/storage/backpack/industrial, MARINE_CAN_BUY_BACKPACK, "black"),
							list("TGMC corpsman backpack", 0, /obj/item/storage/backpack/marine/corpsman, MARINE_CAN_BUY_BACKPACK, "black"),
							list("TGMC technician backpack", 0, /obj/item/storage/backpack/marine/tech , MARINE_CAN_BUY_BACKPACK, "black"),
							list("TGMC technician welderpack", 0, /obj/item/storage/backpack/marine/engineerpack , MARINE_CAN_BUY_BACKPACK, "black"),
							list("Lightweight combat pack", 0, /obj/item/storage/backpack/lightpack, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Officer cloak", 0, /obj/item/storage/backpack/marine/satchel/officer_cloak, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Officer cloak, red", 0, /obj/item/storage/backpack/marine/satchel/officer_cloak_red, MARINE_CAN_BUY_BACKPACK, "black"),
							list("WEBBING (choose 1)", 0, null, null, null),
							list("Webbing", 0, /obj/item/clothing/tie/storage/webbing, MARINE_CAN_BUY_WEBBING, "black"),
							list("Tactical Black Vest", 0, /obj/item/clothing/tie/storage/black_vest, MARINE_CAN_BUY_WEBBING, "black"),
							list("White medical vest", 0, /obj/item/clothing/tie/storage/white_vest/medic, MARINE_CAN_BUY_WEBBING, "black"),
							list("GLOVES (choose 1)", 0, null, null, null),
							list("Insulated gloves", 0, /obj/item/clothing/gloves/yellow, MARINE_CAN_BUY_GLOVES, "black"),
							list("Latex gloves", 0, /obj/item/clothing/gloves/latex , MARINE_CAN_BUY_GLOVES, "black"),
							list("Officer gloves", 0, /obj/item/clothing/gloves/marine/officer, MARINE_CAN_BUY_GLOVES, "black"),
							list("White gloves", 0, /obj/item/clothing/gloves/white, MARINE_CAN_BUY_GLOVES, "black"),
							list("BELT (choose 1)", 0, null, null, null),
							list("M276 pattern medical storage rig", 0, /obj/item/storage/belt/medical, MARINE_CAN_BUY_BELT, "black"),
							list("M276 pattern lifesaver bag", 0, /obj/item/storage/belt/combatLifesaver, MARINE_CAN_BUY_BELT, "black"),
							list("M276 pattern toolbelt rig", 0, /obj/item/storage/belt/utility/full, MARINE_CAN_BUY_BELT, "black"),
							list("M276 pattern security rig ", 0, /obj/item/storage/belt/security/MP/full, MARINE_CAN_BUY_BELT, "black"),
							list("G8 general utility pouch", 0, /obj/item/storage/belt/sparepouch, MARINE_CAN_BUY_BELT, "black"),
							list("SHOES (choose 1)", 0, null, null, null),
							list("Marine combat boots", 0, /obj/item/clothing/shoes/marine, MARINE_CAN_BUY_SHOES, "black"),
							list("White shoes", 0, /obj/item/clothing/shoes/white, MARINE_CAN_BUY_SHOES, "black"),
							list("Formal shoes", 0, /obj/item/clothing/shoes/marinechief, MARINE_CAN_BUY_SHOES, "black"),
							list("POUCHES (choose 2)", 0, null, null, null),
							list("Large general pouch", 0, /obj/item/storage/pouch/general/large , (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Tool pouch", 0, /obj/item/storage/pouch/tools/full , (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Construction pouch", 0, /obj/item/storage/pouch/construction/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Electronics pouch", 0, /obj/item/storage/pouch/electronics/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Medical pouch", 0, /obj/item/storage/pouch/medical, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Medkit pouch", 0, /obj/item/storage/pouch/medkit , (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Autoinjector pouch", 0, /obj/item/storage/pouch/autoinjector, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Flare pouch", 0, /obj/item/storage/pouch/flare/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Radio pouch", 0, /obj/item/storage/pouch/radio, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Field pouch", 0, /obj/item/storage/pouch/field_pouch/full, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("HATS (choose 1)", 0, null, null, null),
							list("Hard hat", 0, /obj/item/clothing/head/hardhat, MARINE_CAN_BUY_HELMET, "black"),
							list("Welding helmet", 0, /obj/item/clothing/head/welding , MARINE_CAN_BUY_HELMET, "black"),
							list("Surgical cap", 0, /obj/item/clothing/head/surgery/green, MARINE_CAN_BUY_HELMET, "black"),
							list("TGMC cap", 0, /obj/item/clothing/head/tgmccap, MARINE_CAN_BUY_HELMET, "black"),
							list("Boonie hat", 0, /obj/item/clothing/head/boonie, MARINE_CAN_BUY_HELMET, "black"),
							list("Marine beret", 0, /obj/item/clothing/head/beret/marine, MARINE_CAN_BUY_HELMET, "black"),
							list("MP beret", 0, /obj/item/clothing/head/tgmcberet/red, MARINE_CAN_BUY_HELMET, "black"),
							list("Engineering beret", 0, /obj/item/clothing/head/beret/eng, MARINE_CAN_BUY_HELMET, "black"),
							list("Ushanka", 0, /obj/item/clothing/head/ushanka, MARINE_CAN_BUY_HELMET, "black"),
							list("Top hat", 0, /obj/item/clothing/head/collectable/tophat, MARINE_CAN_BUY_HELMET, "black"),
							list("MASKS", 0, null, null, null),
							list("Sterile mask", 0, /obj/item/clothing/mask/surgical, MARINE_CAN_BUY_MASK, "black"),
							list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, "black"),
							list("Heat absorbent coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, "black"),
							list("Gas mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, "black"),
							)



////////////////////// Gear ////////////////////////////////////////////////////////



/obj/machinery/marine_selector/gear
	name = "NEXUS Automated Equipment Rack"
	desc = "An automated equipment rack hooked up to a colossal storage unit."
	icon_state = "marinearmory"
	use_points = TRUE
	listed_products = list(
		list("GUN ATTACHMENTS (Choose 1)", 0, null, null, null),
		list("Vertical Grip", 0, /obj/item/attachable/verticalgrip, MARINE_CAN_BUY_ATTACHMENT, "black"),
		list("Red-dot sight", 0, /obj/item/attachable/reddot, MARINE_CAN_BUY_ATTACHMENT, "black"),
		list("Recoil Compensator", 0, /obj/item/attachable/compensator, MARINE_CAN_BUY_ATTACHMENT, "black"),
		list("Laser Sight", 0, /obj/item/attachable/lasersight,  MARINE_CAN_BUY_ATTACHMENT, "black")
		)


/obj/machinery/marine_selector/gear/medic
	name = "NEXUS Automated Medical Equipment Rack"
	desc = "An automated medic equipment rack hooked up to a colossal storage unit."
	icon_state = "medic"
	vendor_role = SQUAD_CORPSMAN
	req_access = list(ACCESS_MARINE_MEDPREP)

	listed_products = list(
							list("MEDICAL SET (Mandatory)", 0, null, null, null),
							list("Essential Medic Set", 0, /obj/effect/essentials_set/medic, MARINE_CAN_BUY_ESSENTIALS, "white"),

							list("MEDICAL SUPPLIES", 0, null, null, null),
							list("Medical splints", 1, /obj/item/stack/medical/splint, null, "orange"),
							list("Adv trauma kit", 1, /obj/item/stack/medical/advanced/bruise_pack, null, "orange"),
							list("Adv burn kit", 1, /obj/item/stack/medical/advanced/ointment, null, "orange"),
							list("Roller Bed", 4, /obj/item/roller, null, "orange"),
							list("Firstaid kit", 6, /obj/item/storage/firstaid/regular, null, "black"),
							list("Advanced firstaid kit", 8, /obj/item/storage/firstaid/adv, null, "orange"),
							list("Stasis bag", 4, /obj/item/bodybag/cryobag, null, "orange"),
							list("Pillbottle (Hypervene)", 4, /obj/item/storage/pill_bottle/hypervene, null, "black"),
							list("Pillbottle (Quick-Clot)", 4, /obj/item/storage/pill_bottle/quickclot, null, "black"),
							list("Pillbottle (Bicaridine)", 4, /obj/item/storage/pill_bottle/bicaridine, null, "orange"),
							list("Pillbottle (Kelotane)", 4, /obj/item/storage/pill_bottle/kelotane, null, "orange"),
							list("Pillbottle (Dylovene)", 4, /obj/item/storage/pill_bottle/dylovene, null, "black"),
							list("Pillbottle (Dexalin)", 4, /obj/item/storage/pill_bottle/dexalin, null, "black"),
							list("Pillbottle (Tramadol)", 4, /obj/item/storage/pill_bottle/tramadol, null, "orange"),
							list("Pillbottle (Inaprovaline)", 4, /obj/item/storage/pill_bottle/inaprovaline, null, "black"),
							list("Pillbottle (Peridaxon)", 4, /obj/item/storage/pill_bottle/peridaxon, null, "black"),
							list("Pillbottle (Spaceacillin)", 4, /obj/item/storage/pill_bottle/spaceacillin, null, "black"),
							list("Injector (Inaprovaline)", 1, /obj/item/reagent_container/hypospray/autoinjector/inaprovaline, null, "black"),
							list("Injector (Bicaridine)", 1, /obj/item/reagent_container/hypospray/autoinjector/bicaridine, null, "black"),
							list("Injector (Kelotane)", 1, /obj/item/reagent_container/hypospray/autoinjector/kelotane, null, "black"),
							list("Injector (Dylovene)", 1, /obj/item/reagent_container/hypospray/autoinjector/dylovene, null, "black"),
							list("Injector (Dexalin+)", 1, /obj/item/reagent_container/hypospray/autoinjector/dexalinplus, null, "black"),
							list("Injector (Quick-Clot)", 1, /obj/item/reagent_container/hypospray/autoinjector/quickclot, null, "black"),
							list("Injector (Oxycodone)", 1, /obj/item/reagent_container/hypospray/autoinjector/oxycodone, null, "black"),
							list("Injector (Tricord)", 1, /obj/item/reagent_container/hypospray/autoinjector/tricordrazine, null, "black"),
							list("Injector (Hypervene)", 1, /obj/item/reagent_container/hypospray/autoinjector/hypervene, null, "black"),
							list("Advanced hypospray", 2, /obj/item/reagent_container/hypospray/advanced, null, "black"),
							list("Health analyzer", 2, /obj/item/healthanalyzer, null, "black"),
							list("Medical HUD glasses", 2, /obj/item/clothing/glasses/hud/health, null, "black"),

							list("SPECIAL AMMUNITION", 0, null, null, null),
							list("AP M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/ap, null, "black"),
							list("Extended M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/extended, null, "black"),
							list("AP M39 magazine", 6, /obj/item/ammo_magazine/smg/m39/ap, null, "black"),
							list("Extended M39 magazine", 6, /obj/item/ammo_magazine/smg/m39/extended, null, "black"),

							list("GUN ATTACHMENTS (Choose 2)", 0, null, null, null),
							list("MUZZLE ATTACHMENTS", 0, null, null, null),
							list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("RAIL ATTACHMENTS", 0, null, null, null),
							list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("UNDERBARREL ATTACHMENTS", 0, null, null, null),
							list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("STOCKS", 0, null, null, null),
							list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							)



/obj/machinery/marine_selector/gear/engi
	name = "NEXUS Automated Engineer Equipment Rack"
	desc = "An automated engineer equipment rack hooked up to a colossal storage unit."
	icon_state = "engineer"
	vendor_role = SQUAD_ENGINEER
	req_access = list(ACCESS_MARINE_ENGPREP)

	listed_products = list(
							list("ENGINEER SET (Mandatory)", 0, null, null, null),
							list("Essential Engineer Set", 0, /obj/effect/essentials_set/engi, MARINE_CAN_BUY_ESSENTIALS, "white"),

							list("ENGINEER SUPPLIES", 0, null, null, null),
							list("Metal x10", 5, /obj/item/stack/sheet/metal/small_stack, null, "orange"),
							list("Plasteel x10", 7, /obj/item/stack/sheet/plasteel/small_stack, null, "orange"),
							list("Sandbags x25", 10, /obj/item/stack/sandbags_empty/half, null, "orange"),
							list("Plasma cutter", 20, /obj/item/tool/pickaxe/plasmacutter, null, "black"),
							list("UA-580 point defense sentry kit", 26, /obj/item/storage/box/minisentry, null, "black"),
							list("Plastique explosive", 3, /obj/item/explosive/plastique, null, "black"),
							list("Detonation pack", 5, /obj/item/detpack, null, "black"),
							list("Entrenching tool", 1, /obj/item/tool/shovel/etool, null, "black"),
							list("Range Finder", 10, /obj/item/binoculars/tactical/range, null, "black"),
							list("High capacity powercell", 1, /obj/item/cell/high, null, "black"),
							list("M20 mine box", 18, /obj/item/storage/box/explosive_mines, null, "black"),
							list("Incendiary grenade", 6, /obj/item/explosive/grenade/incendiary, null, "black"),
							list("Multitool", 1, /obj/item/multitool, null, "black"),
							list("General circuit board", 1, /obj/item/circuitboard/general, null, "black"),
							list("Signaler (for detpacks)", 1, /obj/item/assembly/signaler, null, "black"),

							list("SPECIAL AMMUNITION", 0, null, null, null),
							list("AP M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/ap, null, "black"),
							list("Extended M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/extended, null, "black"),
							list("AP M41A1 magazine", 6, /obj/item/ammo_magazine/rifle/ap, null, "black"),
							list("Extended M41A1 magazine", 6, /obj/item/ammo_magazine/rifle/extended, null, "black"),
							list("AP M39 magazine", 5, /obj/item/ammo_magazine/smg/m39/ap, null, "black"),
							list("Extended M39 magazine", 5, /obj/item/ammo_magazine/smg/m39/extended, null, "black"),

							list("GUN ATTACHMENTS (Choose 2)", 0, null, null, null),
							list("MUZZLE ATTACHMENTS", 0, null, null, null),
							list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("RAIL ATTACHMENTS", 0, null, null, null),
							list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("UNDERBARREL ATTACHMENTS", 0, null, null, null),
							list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("STOCKS", 0, null, null, null),
							list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							)



/obj/machinery/marine_selector/gear/smartgun
	name = "NEXUS Automated Smartgunner Equipment Rack"
	desc = "An automated smartgunner equipment rack hooked up to a colossal storage unit."
	icon_state = "smartgunner"
	vendor_role = SQUAD_SMARTGUNNER
	req_access = list(ACCESS_MARINE_SMARTPREP)

	listed_products = list(
							list("SMARTGUN SET (Mandatory)", 0, null, null, null),
							list("Essential Smartgunner Set", 0, /obj/item/storage/box/m56_system, MARINE_CAN_BUY_ESSENTIALS, "white"),

							list("SPECIAL AMMUNITION", 0, null, null, null),

							list("M56 powerpack", 45, /obj/item/smartgun_powerpack, null, "black"),
							list("AP M4A3 magazine", 10, /obj/item/ammo_magazine/pistol/ap, null, "black"),
							list("Extended M4A3 magazine", 10, /obj/item/ammo_magazine/pistol/extended, null, "black"),
							list("AP M41A1 magazine", 15, /obj/item/ammo_magazine/rifle/ap, null, "black"),
							list("Extended M41A1 magazine", 15, /obj/item/ammo_magazine/rifle/extended, null, "black"),
							list("AP M39 magazine", 13, /obj/item/ammo_magazine/smg/m39/ap, null, "black"),
							list("Extended M39 magazine", 13, /obj/item/ammo_magazine/smg/m39/extended, null, "black"),

							list("GUN ATTACHMENTS (Choose 2)", 0, null, null, null),
							list("MUZZLE ATTACHMENTS", 0, null, null, null),
							list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("RAIL ATTACHMENTS", 0, null, null, null),
							list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("UNDERBARREL ATTACHMENTS", 0, null, null, null),
							list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("STOCKS", 0, null, null, null),
							list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
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
							list("SPECIALIST SETS (Choose one)", 0, null, null, null),
							list("Scout Set (Battle Rifle)", 0, /obj/item/storage/box/spec/scout, MARINE_CAN_BUY_ESSENTIALS, "white"),
							list("Scout Set (Shotgun)", 0, /obj/item/storage/box/spec/scoutshotgun, MARINE_CAN_BUY_ESSENTIALS, "white"),
							list("Sniper Set", 0, /obj/item/storage/box/spec/sniper, MARINE_CAN_BUY_ESSENTIALS, "white"),
							list("Demolitionist Set", 0, /obj/item/storage/box/spec/demolitionist, MARINE_CAN_BUY_ESSENTIALS, "white"),
							list("Heavy Armor Set (Grenadier)", 0, /obj/item/storage/box/spec/heavy_grenadier, MARINE_CAN_BUY_ESSENTIALS, "white"),
							list("Heavy Armor Set (Minigun)", 0, /obj/item/storage/box/spec/heavy_gunner, MARINE_CAN_BUY_ESSENTIALS, "white"),
							list("Pyro Set", 0, /obj/item/storage/box/spec/pyro, MARINE_CAN_BUY_ESSENTIALS, "white"),

							list("SPECIAL AMMUNITION", 0, null, null, null),
							list("AP M4A3 magazine", 10, /obj/item/ammo_magazine/pistol/ap, null, "black"),
							list("Extended M4A3 magazine", 10, /obj/item/ammo_magazine/pistol/extended, null, "black"),
							list("88M4 AP magazine", 15, /obj/item/ammo_magazine/pistol/vp70, null, "black"),
							list("M44 marksman speed loader", 15, /obj/item/ammo_magazine/revolver/marksman, null, "black"),
							list("AP M41A1 magazine", 15, /obj/item/ammo_magazine/rifle/ap, null, "black"),
							list("Extended M41A1 magazine", 15, /obj/item/ammo_magazine/rifle/extended, null, "black"),
							list("AP M39 magazine", 13, /obj/item/ammo_magazine/smg/m39/ap, null, "black"),
							list("Extended M39 magazine", 13, /obj/item/ammo_magazine/smg/m39/extended, null, "black"),

							list("GUN ATTACHMENTS (Choose 2)", 0, null, null, null),
							list("MUZZLE ATTACHMENTS", 0, null, null, null),
							list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("RAIL ATTACHMENTS", 0, null, null, null),
							list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("UNDERBARREL ATTACHMENTS", 0, null, null, null),
							list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("STOCKS", 0, null, null, null),
							list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							)




/obj/machinery/marine_selector/gear/leader
	name = "NEXUS Automated Squad Leader Equipment Rack"
	desc = "An automated squad leader equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	vendor_role = SQUAD_LEADER
	req_access = list(ACCESS_MARINE_LEADER)

	listed_products = list(
							list("SQUAD LEADER SET (Mandatory)", 0, null, null, null),
							list("Essential SL Set", 0, /obj/effect/essentials_set/leader, MARINE_CAN_BUY_ESSENTIALS, "white"),

							list("LEADER SUPPLIES", 0, null, null, null),
							list("Supply beacon", 10, /obj/item/squad_beacon, null, "black"),
							list("Orbital beacon", 15, /obj/item/squad_beacon/bomb, null, "black"),
							list("Entrenching tool", 1, /obj/item/tool/shovel/etool, null, "black"),
							list("Sandbags x25", 10, /obj/item/stack/sandbags_empty/half, null, "black"),
							list("Plastique explosive", 3, /obj/item/explosive/plastique, null, "black"),
							list("Detonation pack", 5, /obj/item/detpack, null, "black"),
							list("Smoke grenade", 2, /obj/item/explosive/grenade/smokebomb, null, "black"),
							list("Cloak grenade", 3, /obj/item/explosive/grenade/cloakbomb, null, "black"),
							list("M40 HIDP incendiary grenade", 3, /obj/item/explosive/grenade/incendiary, null, "black"),
							list("M40 HEDP grenade", 3, /obj/item/explosive/grenade/frag, null, "black"),
							list("M40 IMDP grenade", 3, /obj/item/explosive/grenade/impact, null, "black"),
							list("M41AE2 heavy pulse rifle", 12, /obj/item/weapon/gun/rifle/lmg, null, "orange"),
							list("M41AE2 magazine", 4, /obj/item/ammo_magazine/rifle/lmg, null, "black"),
							list("Flamethrower", 12, /obj/item/weapon/gun/flamer, null, "orange"),
							list("Flamethrower tank", 4, /obj/item/ammo_magazine/flamer_tank, null, "black"),
							list("Whistle", 5, /obj/item/whistle, null, "black"),
							list("Station bounced radio", 1, /obj/item/radio, null, "black"),
							list("Signaler (for detpacks)", 1, /obj/item/assembly/signaler, null, "black"),
							list("Motion detector", 5, /obj/item/motiondetector, null, "black"),
							list("Advanced firstaid kit", 10, /obj/item/storage/firstaid/adv, null, "orange"),
							list("Ziptie box", 5, /obj/item/storage/box/zipcuffs, null, "black"),
							list("V1 thermal-dampening tarp", 5, /obj/structure/closet/bodybag/tarp, null, "black"),

							list("SPECIAL AMMUNITION", 0, null, null, null),
							list("HP M4A3 magazine", 5, /obj/item/ammo_magazine/pistol/hp, null, "black"),
							list("AP M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/ap, null, "black"),
							list("Extended M4A3 magazine", 3, /obj/item/ammo_magazine/pistol/extended, null, "black"),
							list("AP M41A1 magazine", 6, /obj/item/ammo_magazine/rifle/ap, null, "black"),
							list("Extended M41A1 magazine", 6, /obj/item/ammo_magazine/rifle/extended, null, "black"),
							list("AP M39 magazine", 5, /obj/item/ammo_magazine/smg/m39/ap, null, "black"),
							list("Extended M39 magazine", 5, /obj/item/ammo_magazine/smg/m39/extended, null, "black"),

							list("GUN ATTACHMENTS (Choose 2)", 0, null, null, null),
							list("MUZZLE ATTACHMENTS", 0, null, null, null),
							list("Suppressor", 0, /obj/item/attachable/suppressor, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Extended barrel", 0, /obj/item/attachable/extended_barrel, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Recoil compensator", 0, /obj/item/attachable/compensator, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("RAIL ATTACHMENTS", 0, null, null, null),
							list("Magnetic harness", 0, /obj/item/attachable/magnetic_harness, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("Red dot sight", 0, /obj/item/attachable/reddot, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Quickfire assembly", 0, /obj/item/attachable/quickfire, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("UNDERBARREL ATTACHMENTS", 0, null, null, null),
							list("Laser sight", 0, /obj/item/attachable/lasersight, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Vertical grip", 0, /obj/item/attachable/verticalgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("Angled grip", 0, /obj/item/attachable/angledgrip, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							list("STOCKS", 0, null, null, null),
							list("M41A1 skeleton stock", 0, /obj/item/attachable/stock/rifle, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M37 wooden stock", 0, /obj/item/attachable/stock/shotgun, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							list("M39 submachinegun stock", 0, /obj/item/attachable/stock/smg, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							)


/obj/effect/essentials_set
	var/list/spawned_gear_list

/obj/effect/essentials_set/Initialize()
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

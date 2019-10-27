#define MARINE_CAN_BUY_UNIFORM 		(1 << 0)
#define MARINE_CAN_BUY_SHOES	 	(1 << 1)
#define MARINE_CAN_BUY_HELMET 		(1 << 2)
#define MARINE_CAN_BUY_ARMOR	 	(1 << 3)
#define MARINE_CAN_BUY_GLOVES 		(1 << 4)
#define MARINE_CAN_BUY_EAR	 		(1 << 5)
#define MARINE_CAN_BUY_BACKPACK 	(1 << 6)
#define MARINE_CAN_BUY_R_POUCH 		(1 << 7)
#define MARINE_CAN_BUY_L_POUCH 		(1 << 8)
#define MARINE_CAN_BUY_BELT 		(1 << 9)
#define MARINE_CAN_BUY_GLASSES		(1 << 10)
#define MARINE_CAN_BUY_MASK			(1 << 11)
#define MARINE_CAN_BUY_ESSENTIALS	(1 << 12)
#define MARINE_CAN_BUY_ATTACHMENT	(1 << 13)
#define MARINE_CAN_BUY_ATTACHMENT2	(1 << 14)

#define MARINE_CAN_BUY_WEBBING		(1 << 15)



#define MARINE_CAN_BUY_ALL			(1 << 16)

#define MARINE_TOTAL_BUY_POINTS		45


#define CAT_STD "STANDARD EQUIPMENT"
#define CAT_SHO "SHOES"
#define CAT_HEL "HATS"
#define CAT_AMR "ARMOR"
#define CAT_GLO "GLOVES"
#define CAT_EAR "EAR"
#define CAT_BAK "BACKPACK"
#define CAT_POU "POUCHES"
#define CAT_WEB "WEBBING"
#define CAT_BEL "BELT"
#define CAT_MAS "MASKS"
#define CAT_ATT "GUN ATTACHMENTS"

/obj/item/card/id/var/marine_points = MARINE_TOTAL_BUY_POINTS
/obj/item/card/id/var/marine_buy_flags = MARINE_CAN_BUY_ALL

GLOBAL_LIST_INIT(marine_selector_cats, list(
		CAT_STD = list(MARINE_CAN_BUY_UNIFORM),
		CAT_SHO = list(MARINE_CAN_BUY_SHOES),
		CAT_HEL = list(MARINE_CAN_BUY_HELMET),
		CAT_AMR = list(MARINE_CAN_BUY_ARMOR),
		CAT_GLO = list(MARINE_CAN_BUY_GLOVES),
		CAT_EAR = list(MARINE_CAN_BUY_EAR),
		CAT_BAK = list(MARINE_CAN_BUY_BACKPACK),
		CAT_WEB = list(MARINE_CAN_BUY_WEBBING),
		CAT_POU = list(MARINE_CAN_BUY_R_POUCH,MARINE_CAN_BUY_L_POUCH),
		CAT_BEL = list(MARINE_CAN_BUY_BELT),
		CAT_GLA = list(MARINE_CAN_BUY_GLASSES),
		CAT_MAS = list(MARINE_CAN_BUY_MASK),
		CAT_ATT = list(MARINE_CAN_BUY_ATTACHMENT,MARINE_CAN_BUY_ATTACHMENT2),
		CAT_ESS = list(MARINE_CAN_BUY_ESSENTIALS),
	))

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

	var/list/categories
	var/list/listed_products

	ui_x = 600
	ui_y = 700

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

/obj/machinery/marine_selector/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "marineselector", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/marine_selector/ui_data(mob/user)
	var/list/display_list = list()

	for(var/c in categories)
		display_list[c] = list()

	var/m_points = 0
	var/buy_flags = NONE
	var/obj/item/card/id/I = user.get_idcard()
	if(istype(I)) //wearing an ID
		m_points = I.marine_points
		buy_flags = I.marine_buy_flags


	for(var/i in listed_products)
		var/list/myprod = listed_products[i]
		var/category = myprod[1]
		var/p_name = myprod[2]
		var/p_cost = myprod[3]
		if(p_cost > 0)
			p_name += " ([p_cost] points)"

		var/prod_available = FALSE
		var/avail_flag = myprod[4]
		if((!avail_flag && m_points >= p_cost) || (buy_flags & avail_flag))
			prod_available = TRUE

								//place in main list, name, cost, available or not, color.
		display_list[category] += list(list("prod_index" = i, "prod_name" = p_name, "prod_available" = prod_available, "prod_color" = myprod[5]))


	var/list/data = list(
		"vendor_name" = name,
		"show_points" = use_points,
		"current_m_points" = m_points,
		"displayed_records" = display_list,
	)
	return data

/obj/machinery/marine_selector/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("vend")
			if(!allowed(usr))
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				if(icon_deny)
					flick(icon_deny, src)
				return

			var/idx = text2num(params["vend"])
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
				if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
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
			. = TRUE

	updateUsrDialog()

/obj/machinery/marine_selector/clothes
	name = "GHMME Automated Closet"
	desc = "An automated closet hooked up to a colossal storage unit of standard-issue uniform and armor."
	icon_state = "marineuniform"
	vendor_role = SQUAD_MARINE
	categories = list(
		CAT_STD = list(MARINE_CAN_BUY_UNIFORM),
		CAT_AMR = list(MARINE_CAN_BUY_ARMOR),
		CAT_BAK = list(MARINE_CAN_BUY_BACKPACK),
		CAT_WEB = list(MARINE_CAN_BUY_WEBBING),
		CAT_POU = list(MARINE_CAN_BUY_R_POUCH,MARINE_CAN_BUY_L_POUCH),
		CAT_MAS = list(MARINE_CAN_BUY_MASK),
		CAT_ATT = list(MARINE_CAN_BUY_ATTACHMENT,MARINE_CAN_BUY_ATTACHMENT2),
	)

	listed_products = list(
		/obj/effect/essentials_set/basic = list(CAT_STD, "Standard Kit", 0, "white"),
		/obj/item/clothing/suit/storage/marine = list(CAT_AMR, "Regular Armor", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/M3HB = list(CAT_AMR, "Heavy Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/M3LB = list(CAT_AMR, "Light Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/M3P = list(CAT_AMR, "Ballistic Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/M3IS = list(CAT_AMR, "Integrated Storage Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/M3E = list(CAT_AMR, "Edge Melee Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/harness = list(CAT_AMR, "Harness", 0, "black"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/large_holster/m37 = list(CAT_BAK, "Shotgun scabbard", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical Black Vest", 0, "orange"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder Handgun Holster", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "orange"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/m4a3 = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/m44 = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt Harness", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "orange"),
		/obj/item/storage/pouch/magazine = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "orange"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0,"orange"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch (tools included)", 0,"black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch (materials included)", 0,"black"),
		/obj/item/storage/pouch/magazine/pistol = list(CAT_POU, "Pistol magazine pouch", 0,"black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0,"black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0,"black"),
		/obj/item/clothing/mask/bandanna = list(CAT_MAS, "Tan bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/green = list(CAT_MAS, "Green bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/white = list(CAT_MAS, "White bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/black = list(CAT_MAS, "Black bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/skull = list(CAT_MAS, "Skull bandanna", 0,"black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0,"black"),
		/obj/item/attachable/suppressor = list(CAT_ATT, "Suppressor", 0,"black"),
		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0,"orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0,"black"),
		/obj/item/attachable/efflens = list(CAT_ATT, "M43 Efficient lens", 0,"black"),
		/obj/item/attachable/focuslens = list(CAT_ATT, "M43 Focus lens", 0,"black"),
		/obj/item/attachable/widelens = list(CAT_ATT, "M43 Wide lens", 0,"black"),
		/obj/item/attachable/pulselens = list(CAT_ATT, "M43 pulse lens", 0,"black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0,"orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0,"black"),
		/obj/item/attachable/quickfire = list(CAT_ATT, "Quickfire assembly", 0,"black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0,"black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0,"black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0,"orange"),
		/obj/item/attachable/stock/rifle = list(CAT_ATT, "M41A1 skeleton stock", 0,"black"),
		/obj/item/attachable/stock/shotgun = list(CAT_ATT, "M37 wooden stock", 0,"black"),
		/obj/item/attachable/stock/smg = list(CAT_ATT, "M39 submachinegun stock", 0,"black"),
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
							null = list(xxx, "STANDARD EQUIPMENT (take all)", 0, null, null),
							/obj/effect/essentials_set/basic_engineer = list(CAT_STD, "Standard Kit", 0, MARINE_CAN_BUY_UNIFORM, "white"),
							null = list(xxx, "ARMOR (choose 1)", 0, null, null),
							/obj/item/clothing/suit/storage/marine = list(CAT_AMR, "Regular Armor", 0, MARINE_CAN_BUY_ARMOR, "orange"),
							/obj/item/clothing/suit/storage/marine/M3HB = list(CAT_AMR, "Heavy Armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/M3LB = list(CAT_AMR, "Light Armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/M3P = list(CAT_AMR, "Ballistic Armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/M3IS = list(CAT_AMR, "Integrated Storage Armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/M3E = list(CAT_AMR, "Edge Melee Armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/harness = list(CAT_AMR, "Harness", 0, MARINE_CAN_BUY_ARMOR, "black"),
							null = list(xxx, "BACKPACK (choose 1)", 0, null, null),
							/obj/item/storage/backpack/marine/satchel/tech = list(CAT_BAK, "Satchel", 0, MARINE_CAN_BUY_BACKPACK, "orange"),
							/obj/item/storage/backpack/marine/tech = list(CAT_BAK, "Backpack", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/large_holster/m37 = list(CAT_BAK, "Shotgun scabbard", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/large_holster/machete/full = list(CAT_BAK, "Machete scabbard", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/backpack/marine/engineerpack = list(CAT_BAK, "Welderpack", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							null = list(xxx, "WEBBING (choose 1)", 0, null, null),
							/obj/item/clothing/tie/storage/brown_vest = list(CAT_WEB, "Tactical Brown Vest", 0, MARINE_CAN_BUY_WEBBING, "orange"),
							/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, MARINE_CAN_BUY_WEBBING, "black"),
							/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder Handgun Holster", 0, MARINE_CAN_BUY_WEBBING, "black"),
							null = list(xxx, "BELT (choose 1)", 0, null, null),
							/obj/item/storage/belt/utility/full = list(CAT_BEL, "Tool belt", 0, MARINE_CAN_BUY_BELT, "orange"),
							null = list(xxx, "POUCHES (choose 2)", 0, null, null),
							/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/construction = list(CAT_POU, "Construction pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tools pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/electronics/full = list(CAT_POU, "Electronics pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/magazine = list(CAT_POU, "Magazine pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Large pistol magazine pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							null = list(xxx, "MASKS", 0, null, null),
							/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, MARINE_CAN_BUY_MASK, "black"),
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
							null = list(xxx, "STANDARD EQUIPMENT (take all)", 0, null, null),
							/obj/effect/essentials_set/basic_medic = list(CAT_STD, "Standard Kit", 0, MARINE_CAN_BUY_UNIFORM, "white"),
							null = list(xxx, "ARMOR (choose 1)", 0, null, null),
							/obj/item/clothing/suit/storage/marine = list(CAT_AMR, "Regular Armor", 0, MARINE_CAN_BUY_ARMOR, "orange"),
							/obj/item/clothing/suit/storage/marine/M3HB = list(CAT_AMR, "Heavy Armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/M3LB = list(CAT_AMR, "Light Armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/M3P = list(CAT_AMR, "Ballistic Armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/M3IS = list(CAT_AMR, "Integrated Storage Armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/M3E = list(CAT_AMR, "Edge Melee Armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/harness = list(CAT_AMR, "Harness", 0, MARINE_CAN_BUY_ARMOR, "black"),
							null = list(xxx, "BACKPACK (choose 1)", 0, null, null),
							/obj/item/storage/backpack/marine/satchel/corpsman = list(CAT_BAK, "Satchel", 0, MARINE_CAN_BUY_BACKPACK, "orange"),
							/obj/item/storage/backpack/marine/corpsman = list(CAT_BAK, "Backpack", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							null = list(xxx, "WEBBING (choose 1)", 0, null, null),
							/obj/item/clothing/tie/storage/brown_vest = list(CAT_WEB, "Tactical Brown Vest", 0, MARINE_CAN_BUY_WEBBING, "orange"),
							/obj/item/clothing/tie/storage/white_vest/medic = list(CAT_WEB, "Corpsman White Vest", 0, MARINE_CAN_BUY_WEBBING, "black"),
							/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, MARINE_CAN_BUY_WEBBING, "black"),
							/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder Handgun Holster", 0, MARINE_CAN_BUY_WEBBING, "black"),
							null = list(xxx, "BELT (choose 1)", 0, null, null),
							/obj/item/storage/belt/combatLifesaver = list(CAT_BEL, "Lifesaver belt", 0, MARINE_CAN_BUY_BELT, "orange"),
							/obj/item/storage/belt/medical = list(CAT_BEL, "Medical belt", 0, MARINE_CAN_BUY_BELT, "black"),
							null = list(xxx, "POUCHES (choose 2)", 0, null, null),
							/obj/item/storage/pouch/medical = list(CAT_POU, "Medical pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							/obj/item/storage/pouch/medkit = list(CAT_POU, "Medkit pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							/obj/item/storage/pouch/autoinjector = list(CAT_POU, "Autoinjector pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/magazine = list(CAT_POU, "Magazine pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Large pistol magazine pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							null = list(xxx, "MASKS", 0, null, null),
							/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, MARINE_CAN_BUY_MASK, "black"),
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
							null = list(xxx, "STANDARD EQUIPMENT (take all)", 0, null, null),
							/obj/effect/essentials_set/basic_smartgunner = list(CAT_STD, "Standard Kit", 0, MARINE_CAN_BUY_UNIFORM, "white"),
							null = list(xxx, "WEBBING (choose 1)", 0, null, null),
							/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical Black Vest", 0, MARINE_CAN_BUY_WEBBING, "orange"),
							/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, MARINE_CAN_BUY_WEBBING, "black"),
							/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder Handgun Holster", 0, MARINE_CAN_BUY_WEBBING, "black"),
							null = list(xxx, "BELT (choose 1)", 0, null, null),
							/obj/item/storage/large_holster/m39 = list(CAT_BEL, "M39 holster belt", 0, MARINE_CAN_BUY_BELT, "orange"),
							/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/gun/m4a3 = list(CAT_BEL, "Pistol belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/gun/m44 = list(CAT_BEL, "Revolver belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, MARINE_CAN_BUY_BELT, "black"),
							null = list(xxx, "POUCHES (choose 2)", 0, null, null),
							/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/magazine = list(CAT_POU, "Magazine pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "orange"),
							/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Large pistol magazine pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							null = list(xxx, "MASKS", 0, null, null),
							/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, MARINE_CAN_BUY_MASK, "black"),
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
							null = list(xxx, "STANDARD EQUIPMENT (take all)", 0, null, null),
							/obj/effect/essentials_set/basic_specialist = list(CAT_STD, "Standard Kit", 0, MARINE_CAN_BUY_UNIFORM, "white"),
							null = list(xxx, "BACKPACK (choose 1)", 0, null, null),
							/obj/item/storage/backpack/marine/satchel = list(xxx, "Satchel", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/backpack/marine/standard = list(xxx, "Backpack", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/large_holster/m37 = list(xxx, "Shotgun scabbard", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							null = list(xxx, "WEBBING (choose 1)", 0, null, null),
							/obj/item/clothing/tie/storage/black_vest = list(xxx, "Tactical Black Vest", 0, MARINE_CAN_BUY_WEBBING, "black"),
							/obj/item/clothing/tie/storage/webbing = list(xxx, "Tactical Webbing", 0, MARINE_CAN_BUY_WEBBING, "black"),
							/obj/item/clothing/tie/holster = list(xxx, "Shoulder Handgun Holster", 0, MARINE_CAN_BUY_WEBBING, "black"),
							null = list(xxx, "BELT (choose 1)", 0, null, null),
							/obj/item/storage/large_holster/m39 = list(xxx, "M39 holster belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/marine = list(xxx, "Standard ammo belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/shotgun = list(xxx, "Shotgun ammo belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/knifepouch = list(xxx, "Knives belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/gun/m4a3 = list(xxx, "Pistol belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/gun/m44 = list(xxx, "Revolver belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/sparepouch = list(xxx, "G8 general utility pouch", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/belt_harness/marine = list(xxx, "Belt Harness", 0, MARINE_CAN_BUY_BELT, "black"),
							null = list(xxx, "POUCHES (choose 2)", 0, null, null),
							/obj/item/storage/pouch/shotgun = list(xxx, "Shotgun shell pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/magazine/large = list(xxx, "Large magazine pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/general/medium = list(xxx, "Medium general pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/flare/full = list(xxx, "Flare pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/firstaid/full = list(xxx, "Firstaid pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/magazine/pistol/large = list(xxx, "Large pistol magazine pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/pistol = list(xxx, "Sidearm pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/explosive = list(xxx, "Explosive pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							null = list(xxx, "MASKS", 0, null, null),
							/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, MARINE_CAN_BUY_MASK, "black"),
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
							null = list(xxx, "STANDARD EQUIPMENT (take all)", 0, null, null),
							/obj/effect/essentials_set/basic_squadleader = list(xxx, "Standard Kit", 0, MARINE_CAN_BUY_UNIFORM, "white"),
							null = list(xxx, "BACKPACK (choose 1)", 0, null, null),
							/obj/item/storage/backpack/marine/satchel = list(xxx, "Satchel", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/backpack/marine/standard = list(xxx, "Backpack", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/large_holster/m37 = list(xxx, "Shotgun scabbard", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/large_holster/machete/full = list(xxx, "Machete scabbard", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							null = list(xxx, "WEBBING (choose 1)", 0, null, null),
							/obj/item/clothing/tie/storage/black_vest = list(xxx, "Tactical Black Vest", 0, MARINE_CAN_BUY_WEBBING, "black"),
							/obj/item/clothing/tie/storage/webbing = list(xxx, "Tactical Webbing", 0, MARINE_CAN_BUY_WEBBING, "black"),
							/obj/item/clothing/tie/holster = list(xxx, "Shoulder Handgun Holster", 0, MARINE_CAN_BUY_WEBBING, "black"),
							null = list(xxx, "BELT (choose 1)", 0, null, null),
							/obj/item/storage/belt/marine = list(xxx, "Standard ammo belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/shotgun = list(xxx, "Shotgun ammo belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/large_holster/m39 = list(xxx, "M39 holster belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/knifepouch = list(xxx, "Knives belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/gun/m4a3 = list(xxx, "Pistol belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/gun/m44 = list(xxx, "Revolver belt", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/sparepouch = list(xxx, "G8 general utility pouch", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/belt_harness/marine = list(xxx, "Belt Harness", 0, MARINE_CAN_BUY_BELT, "black"),
							null = list(xxx, "POUCHES (choose 2)", 0, null, null),
							/obj/item/storage/pouch/shotgun = list(xxx, "Shotgun shell pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/general/large = list(xxx, "Large general pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/magazine/large = list(xxx, "Large magazine pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/flare/full = list(xxx, "Flare pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/firstaid/full = list(xxx, "Firstaid pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/medkit = list(xxx, "Medkit pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/tools/full = list(xxx, "Tool pouch (tools included)", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/construction/full = list(xxx, "Construction pouch (materials included)", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/magazine/pistol/large = list(xxx, "Large pistol magazine pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/pistol = list(xxx, "Sidearm pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/explosive = list(xxx, "Explosive pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							null = list(xxx, "MASKS", 0, null, null),
							/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, MARINE_CAN_BUY_MASK, "black"),
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
							null = list(xxx, "STANDARD EQUIPMENT", 0, null, null),
							/obj/effect/essentials_set/synth = list(xxx, "Essential Synthetic Set", 0, MARINE_CAN_BUY_ESSENTIALS, "white"),
							null = list(xxx, "UNIFORM (choose 1)", 0, null, null),
							/obj/item/clothing/under/marine = list(xxx, "TGMC marine uniform", 0, MARINE_CAN_BUY_UNIFORM, "black"),
							/obj/item/clothing/under/rank/medical/green = list(xxx, "Medical scrubs", 0, MARINE_CAN_BUY_UNIFORM, "black"),
							/obj/item/clothing/under/marine/officer/engi = list(xxx, "Engineering uniform", 0, MARINE_CAN_BUY_UNIFORM, "black"),
							/obj/item/clothing/under/marine/officer/logistics = list(xxx, "Officer uniform", 0, MARINE_CAN_BUY_UNIFORM, "black"),
							/obj/item/clothing/under/whites = list(xxx, "TGMC dress uniform", 0, MARINE_CAN_BUY_UNIFORM, "black"),
							/obj/item/clothing/under/marine/officer/pilot = list(xxx, "Pilot bodysuit", 0, MARINE_CAN_BUY_UNIFORM, "black"),
							/obj/item/clothing/under/marine/mp = list(xxx, "Military police uniform", 0, MARINE_CAN_BUY_UNIFORM, "black"),
							/obj/item/clothing/under/marine/officer/researcher = list(xxx, "Researcher outfit", 0, MARINE_CAN_BUY_UNIFORM, "black"),
							/obj/item/clothing/under/rank/chef = list(xxx, "Chef uniform", 0, MARINE_CAN_BUY_UNIFORM, "black"),
							/obj/item/clothing/under/rank/bartender = list(xxx, "Bartender uniform", 0, MARINE_CAN_BUY_UNIFORM, "black"),
							null = list(xxx, "OUTERWEAR (choose 1)", 0, null, null),
							/obj/item/clothing/suit/storage/hazardvest = list(xxx, "Hazard vest", 0, MARINE_CAN_BUY_ARMOR, "black"),
							list("Surgical apron", 0, /obj/item/clothing/suit/surgical , MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/labcoat = list(xxx, "Labcoat", 0, MARINE_CAN_BUY_ARMOR, "black"),
							list("Researcher's labcoat", 0, /obj/item/clothing/suit/storage/labcoat/researcher, MARINE_CAN_BUY_ARMOR, "black"),
							list("Snow suit", 0, /obj/item/clothing/suit/storage/snow_suit , MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/armor/vest/pilot = list(xxx, "M70 flak jacket", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/MP = list(xxx, "N2 pattern MA armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/storage/marine/MP/RO = list(xxx, "M3 pattern officer armor", 0, MARINE_CAN_BUY_ARMOR, "black"),
							list("Chef's apron", 0, /obj/item/clothing/suit/chef, MARINE_CAN_BUY_ARMOR, "black"),
							/obj/item/clothing/suit/wcoat = list(xxx, "Waistcoat", 0, MARINE_CAN_BUY_ARMOR, "black"),
							null = list(xxx, "BACKPACK (choose 1)", 0, null, null),
							/obj/item/storage/backpack/marine/satchel = list(xxx, "Satchel", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/backpack/marine = list(xxx, "Lightweight IMP backpack", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/backpack/industrial = list(xxx, "Industrial backpack", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/backpack/marine/corpsman = list(xxx, "TGMC corpsman backpack", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							list("TGMC technician backpack", 0, /obj/item/storage/backpack/marine/tech , MARINE_CAN_BUY_BACKPACK, "black"),
							list("TGMC technician welderpack", 0, /obj/item/storage/backpack/marine/engineerpack , MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/backpack/lightpack = list(xxx, "Lightweight combat pack", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							/obj/item/storage/backpack/marine/satchel/officer_cloak = list(xxx, "Officer cloak", 0, MARINE_CAN_BUY_BACKPACK, "black"),
							list("Officer cloak, red", 0, /obj/item/storage/backpack/marine/satchel/officer_cloak_red, MARINE_CAN_BUY_BACKPACK, "black"),
							null = list(xxx, "WEBBING (choose 1)", 0, null, null),
							/obj/item/clothing/tie/storage/webbing = list(xxx, "Webbing", 0, MARINE_CAN_BUY_WEBBING, "black"),
							/obj/item/clothing/tie/storage/black_vest = list(xxx, "Tactical Black Vest", 0, MARINE_CAN_BUY_WEBBING, "black"),
							/obj/item/clothing/tie/storage/white_vest/medic = list(xxx, "White medical vest", 0, MARINE_CAN_BUY_WEBBING, "black"),
							null = list(xxx, "GLOVES (choose 1)", 0, null, null),
							/obj/item/clothing/gloves/yellow = list(xxx, "Insulated gloves", 0, MARINE_CAN_BUY_GLOVES, "black"),
							list("Latex gloves", 0, /obj/item/clothing/gloves/latex , MARINE_CAN_BUY_GLOVES, "black"),
							/obj/item/clothing/gloves/marine/officer = list(xxx, "Officer gloves", 0, MARINE_CAN_BUY_GLOVES, "black"),
							/obj/item/clothing/gloves/white = list(xxx, "White gloves", 0, MARINE_CAN_BUY_GLOVES, "black"),
							null = list(xxx, "BELT (choose 1)", 0, null, null),
							/obj/item/storage/belt/medical = list(xxx, "M276 pattern medical storage rig", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/combatLifesaver = list(xxx, "M276 pattern lifesaver bag", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/utility/full = list(xxx, "M276 pattern toolbelt rig", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/security/MP/full = list(xxx, "M276 pattern security rig ", 0, MARINE_CAN_BUY_BELT, "black"),
							/obj/item/storage/belt/sparepouch = list(xxx, "G8 general utility pouch", 0, MARINE_CAN_BUY_BELT, "black"),
							null = list(xxx, "SHOES (choose 1)", 0, null, null),
							/obj/item/clothing/shoes/marine = list(xxx, "Marine combat boots", 0, MARINE_CAN_BUY_SHOES, "black"),
							/obj/item/clothing/shoes/white = list(xxx, "White shoes", 0, MARINE_CAN_BUY_SHOES, "black"),
							/obj/item/clothing/shoes/marinechief = list(xxx, "Formal shoes", 0, MARINE_CAN_BUY_SHOES, "black"),
							null = list(xxx, "POUCHES (choose 2)", 0, null, null),
							list("Large general pouch", 0, /obj/item/storage/pouch/general/large , (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Tool pouch", 0, /obj/item/storage/pouch/tools/full , (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/construction/full = list(xxx, "Construction pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/electronics/full = list(xxx, "Electronics pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/medical = list(xxx, "Medical pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							list("Medkit pouch", 0, /obj/item/storage/pouch/medkit , (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/autoinjector = list(xxx, "Autoinjector pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/flare/full = list(xxx, "Flare pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/radio = list(xxx, "Radio pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							/obj/item/storage/pouch/field_pouch/full = list(xxx, "Field pouch", 0, (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH), "black"),
							null = list(xxx, "HATS (choose 1)", 0, null, null),
							/obj/item/clothing/head/hardhat = list(xxx, "Hard hat", 0, MARINE_CAN_BUY_HELMET, "black"),
							list("Welding helmet", 0, /obj/item/clothing/head/welding , MARINE_CAN_BUY_HELMET, "black"),
							/obj/item/clothing/head/surgery/green = list(xxx, "Surgical cap", 0, MARINE_CAN_BUY_HELMET, "black"),
							/obj/item/clothing/head/tgmccap = list(xxx, "TGMC cap", 0, MARINE_CAN_BUY_HELMET, "black"),
							/obj/item/clothing/head/boonie = list(xxx, "Boonie hat", 0, MARINE_CAN_BUY_HELMET, "black"),
							/obj/item/clothing/head/beret/marine = list(xxx, "Marine beret", 0, MARINE_CAN_BUY_HELMET, "black"),
							/obj/item/clothing/head/tgmcberet/red = list(xxx, "MP beret", 0, MARINE_CAN_BUY_HELMET, "black"),
							/obj/item/clothing/head/beret/eng = list(xxx, "Engineering beret", 0, MARINE_CAN_BUY_HELMET, "black"),
							/obj/item/clothing/head/ushanka = list(xxx, "Ushanka", 0, MARINE_CAN_BUY_HELMET, "black"),
							/obj/item/clothing/head/collectable/tophat = list(xxx, "Top hat", 0, MARINE_CAN_BUY_HELMET, "black"),
							null = list(xxx, "MASKS", 0, null, null),
							/obj/item/clothing/mask/surgical = list(CAT_MAS, "Sterile mask", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, MARINE_CAN_BUY_MASK, "black"),
							/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, MARINE_CAN_BUY_MASK, "black"),
							)



////////////////////// Gear ////////////////////////////////////////////////////////



/obj/machinery/marine_selector/gear
	name = "NEXUS Automated Equipment Rack"
	desc = "An automated equipment rack hooked up to a colossal storage unit."
	icon_state = "marinearmory"
	use_points = TRUE
	listed_products = list(
		null = list(xxx, "GUN ATTACHMENTS (Choose 1)", 0, null, null),
		/obj/item/attachable/verticalgrip = list(xxx, "Vertical Grip", 0, MARINE_CAN_BUY_ATTACHMENT, "black"),
		list("Red-dot sight", 0, /obj/item/attachable/reddot, MARINE_CAN_BUY_ATTACHMENT, "black"),
		/obj/item/attachable/compensator = list(xxx, "Recoil Compensator", 0, MARINE_CAN_BUY_ATTACHMENT, "black"),
		list("Laser Sight", 0, /obj/item/attachable/lasersight,  MARINE_CAN_BUY_ATTACHMENT, "black")
		)


/obj/machinery/marine_selector/gear/medic
	name = "NEXUS Automated Medical Equipment Rack"
	desc = "An automated medic equipment rack hooked up to a colossal storage unit."
	icon_state = "medic"
	vendor_role = SQUAD_CORPSMAN
	req_access = list(ACCESS_MARINE_MEDPREP)

	listed_products = list(
							null = list(xxx, "MEDICAL SET (Mandatory)", 0, null, null),
							/obj/effect/essentials_set/medic = list(xxx, "Essential Medic Set", 0, MARINE_CAN_BUY_ESSENTIALS, "white"),

							null = list(xxx, "MEDICAL SUPPLIES", 0, null, null),
							/obj/item/storage/firstaid/regular = list(xxx, "Firstaid kit", 6, null, "black"),
							/obj/item/storage/firstaid/adv = list(xxx, "Advanced firstaid kit", 8, null, "orange"),
							/obj/item/bodybag/cryobag = list(xxx, "Stasis bag", 4, null, "orange"),
							/obj/item/storage/pill_bottle/hypervene = list(xxx, "Pillbottle (Hypervene)", 4, null, "black"),
							list("Pillbottle (Quick-Clot)", 4, /obj/item/storage/pill_bottle/quickclot, null, "black"),
							/obj/item/storage/pill_bottle/bicaridine = list(xxx, "Pillbottle (Bicaridine)", 4, null, "orange"),
							/obj/item/storage/pill_bottle/kelotane = list(xxx, "Pillbottle (Kelotane)", 4, null, "orange"),
							/obj/item/storage/pill_bottle/dylovene = list(xxx, "Pillbottle (Dylovene)", 4, null, "black"),
							/obj/item/storage/pill_bottle/dexalin = list(xxx, "Pillbottle (Dexalin)", 4, null, "black"),
							/obj/item/storage/pill_bottle/tramadol = list(xxx, "Pillbottle (Tramadol)", 4, null, "orange"),
							/obj/item/storage/pill_bottle/inaprovaline = list(xxx, "Pillbottle (Inaprovaline)", 4, null, "black"),
							/obj/item/storage/pill_bottle/peridaxon = list(xxx, "Pillbottle (Peridaxon)", 4, null, "black"),
							/obj/item/storage/syringe_case/meralyne = list(xxx, "syringe Case (120u Meralyne)", 15, null, "orange"),
							/obj/item/storage/syringe_case/dermaline = list(xxx, "syringe Case (120u Dermaline)", 15, null, "orange"),
							/obj/item/storage/syringe_case/meraderm = list(xxx, "syringe Case (120u Meraderm)", 15, null, "orange"),
							/obj/item/storage/syringe_case/ironsugar = list(xxx, "syringe Case (120u Ironsugar)", 15, null, "orange"),
							/obj/item/reagent_container/hypospray/autoinjector/inaprovaline = list(xxx, "Injector (Inaprovaline)", 1, null, "black"),
							/obj/item/reagent_container/hypospray/autoinjector/bicaridine = list(xxx, "Injector (Bicaridine)", 1, null, "black"),
							/obj/item/reagent_container/hypospray/autoinjector/kelotane = list(xxx, "Injector (Kelotane)", 1, null, "black"),
							/obj/item/reagent_container/hypospray/autoinjector/dylovene = list(xxx, "Injector (Dylovene)", 1, null, "black"),
							list("Injector (Dexalin+)", 1, /obj/item/reagent_container/hypospray/autoinjector/dexalinplus, null, "black"),
							list("Injector (Quick-Clot)", 1, /obj/item/reagent_container/hypospray/autoinjector/quickclot, null, "black"),
							/obj/item/reagent_container/hypospray/autoinjector/oxycodone = list(xxx, "Injector (Oxycodone)", 1, null, "black"),
							/obj/item/reagent_container/hypospray/autoinjector/tricordrazine = list(xxx, "Injector (Tricord)", 1, null, "black"),
							/obj/item/reagent_container/hypospray/autoinjector/hypervene = list(xxx, "Injector (Hypervene)", 1, null, "black"),

							/obj/item/reagent_container/hypospray/autoinjector/hyperzine = list(xxx, "Injector (Hyperzine)", 10, null, "orange"),
							/obj/item/reagent_container/hypospray/advanced = list(xxx, "Advanced hypospray", 2, null, "black"),
							/obj/item/healthanalyzer = list(xxx, "Health analyzer", 2, null, "black"),
							/obj/item/clothing/glasses/hud/health = list(xxx, "Medical HUD glasses", 2, null, "black"),

							null = list(xxx, "SPECIAL AMMUNITION", 0, null, null),
							/obj/item/ammo_magazine/pistol/ap = list(xxx, "AP M4A3 magazine", 3, null, "black"),
							/obj/item/ammo_magazine/pistol/extended = list(xxx, "Extended M4A3 magazine", 3, null, "black"),
							/obj/item/ammo_magazine/smg/m39/ap = list(xxx, "AP M39 magazine", 6, null, "black"),
							/obj/item/ammo_magazine/smg/m39/extended = list(xxx, "Extended M39 magazine", 6, null, "black"),

							null = list(xxx, "GUN ATTACHMENTS (Choose 2)", 0, null, null),
							null = list(xxx, "MUZZLE ATTACHMENTS", 0, null, null),
							/obj/item/attachable/suppressor = list(xxx, "Suppressor", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/extended_barrel = list(xxx, "Extended barrel", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							/obj/item/attachable/compensator = list(xxx, "Recoil compensator", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							null = list(xxx, "RAIL ATTACHMENTS", 0, null, null),
							/obj/item/attachable/magnetic_harness = list(xxx, "Magnetic harness", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							/obj/item/attachable/reddot = list(xxx, "Red dot sight", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/quickfire = list(xxx, "Quickfire assembly", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							null = list(xxx, "UNDERBARREL ATTACHMENTS", 0, null, null),
							/obj/item/attachable/lasersight = list(xxx, "Laser sight", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/verticalgrip = list(xxx, "Vertical grip", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/angledgrip = list(xxx, "Angled grip", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							null = list(xxx, "STOCKS", 0, null, null),
							/obj/item/attachable/stock/rifle = list(xxx, "M41A1 skeleton stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/stock/shotgun = list(xxx, "M37 wooden stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/stock/smg = list(xxx, "M39 submachinegun stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							)



/obj/machinery/marine_selector/gear/engi
	name = "NEXUS Automated Engineer Equipment Rack"
	desc = "An automated engineer equipment rack hooked up to a colossal storage unit."
	icon_state = "engineer"
	vendor_role = SQUAD_ENGINEER
	req_access = list(ACCESS_MARINE_ENGPREP)

	listed_products = list(
							null = list(xxx, "ENGINEER SET (Mandatory)", 0, null, null),
							/obj/effect/essentials_set/engi = list(xxx, "Essential Engineer Set", 0, MARINE_CAN_BUY_ESSENTIALS, "white"),

							null = list(xxx, "ENGINEER SUPPLIES", 0, null, null),
							/obj/item/stack/sheet/metal/small_stack = list(xxx, "Metal x10", 5, null, "orange"),
							/obj/item/stack/sheet/plasteel/small_stack = list(xxx, "Plasteel x10", 7, null, "orange"),
							/obj/item/stack/sandbags_empty/half = list(xxx, "Sandbags x25", 10, null, "orange"),
							/obj/item/tool/pickaxe/plasmacutter = list(xxx, "Plasma cutter", 20, null, "black"),
							list("UA-580 point defense sentry kit", 26, /obj/item/storage/box/minisentry, null, "black"),
							/obj/item/explosive/plastique = list(xxx, "Plastique explosive", 3, null, "black"),
							/obj/item/detpack = list(xxx, "Detonation pack", 5, null, "black"),
							/obj/item/tool/shovel/etool = list(xxx, "Entrenching tool", 1, null, "black"),
							/obj/item/binoculars/tactical/range = list(xxx, "Range Finder", 10, null, "black"),
							/obj/item/cell/high = list(xxx, "High capacity powercell", 1, null, "black"),
							/obj/item/storage/box/explosive_mines = list(xxx, "M20 mine box", 18, null, "black"),
							/obj/item/explosive/grenade/incendiary = list(xxx, "Incendiary grenade", 6, null, "black"),
							/obj/item/multitool = list(xxx, "Multitool", 1, null, "black"),
							/obj/item/circuitboard/general = list(xxx, "General circuit board", 1, null, "black"),
							/obj/item/assembly/signaler = list(xxx, "Signaler (for detpacks)", 1, null, "black"),

							null = list(xxx, "SPECIAL AMMUNITION", 0, null, null),
							/obj/item/ammo_magazine/pistol/ap = list(xxx, "AP M4A3 magazine", 3, null, "black"),
							/obj/item/ammo_magazine/pistol/extended = list(xxx, "Extended M4A3 magazine", 3, null, "black"),
							/obj/item/ammo_magazine/rifle/ap = list(xxx, "AP M41A1 magazine", 6, null, "black"),
							/obj/item/ammo_magazine/rifle/extended = list(xxx, "Extended M41A1 magazine", 6, null, "black"),
							/obj/item/ammo_magazine/smg/m39/ap = list(xxx, "AP M39 magazine", 5, null, "black"),
							/obj/item/ammo_magazine/smg/m39/extended = list(xxx, "Extended M39 magazine", 5, null, "black"),

							null = list(xxx, "GUN ATTACHMENTS (Choose 2)", 0, null, null),
							null = list(xxx, "MUZZLE ATTACHMENTS", 0, null, null),
							/obj/item/attachable/suppressor = list(xxx, "Suppressor", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/extended_barrel = list(xxx, "Extended barrel", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							/obj/item/attachable/compensator = list(xxx, "Recoil compensator", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							null = list(xxx, "RAIL ATTACHMENTS", 0, null, null),
							/obj/item/attachable/magnetic_harness = list(xxx, "Magnetic harness", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							/obj/item/attachable/reddot = list(xxx, "Red dot sight", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/quickfire = list(xxx, "Quickfire assembly", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							null = list(xxx, "UNDERBARREL ATTACHMENTS", 0, null, null),
							/obj/item/attachable/lasersight = list(xxx, "Laser sight", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/verticalgrip = list(xxx, "Vertical grip", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/angledgrip = list(xxx, "Angled grip", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							null = list(xxx, "STOCKS", 0, null, null),
							/obj/item/attachable/stock/rifle = list(xxx, "M41A1 skeleton stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/stock/shotgun = list(xxx, "M37 wooden stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/stock/smg = list(xxx, "M39 submachinegun stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							)



/obj/machinery/marine_selector/gear/smartgun
	name = "NEXUS Automated Smartgunner Equipment Rack"
	desc = "An automated smartgunner equipment rack hooked up to a colossal storage unit."
	icon_state = "smartgunner"
	vendor_role = SQUAD_SMARTGUNNER
	req_access = list(ACCESS_MARINE_SMARTPREP)

	listed_products = list(
							null = list(xxx, "SMARTGUN SET (Mandatory)", 0, null, null),
							/obj/item/storage/box/m56_system = list(xxx, "Essential Smartgunner Set", 0, MARINE_CAN_BUY_ESSENTIALS, "white"),

							null = list(xxx, "SPECIAL AMMUNITION", 0, null, null),

							/obj/item/smartgun_powerpack = list(xxx, "M56 powerpack", 45, null, "black"),
							/obj/item/ammo_magazine/pistol/ap = list(xxx, "AP M4A3 magazine", 10, null, "black"),
							/obj/item/ammo_magazine/pistol/extended = list(xxx, "Extended M4A3 magazine", 10, null, "black"),
							/obj/item/ammo_magazine/rifle/ap = list(xxx, "AP M41A1 magazine", 15, null, "black"),
							/obj/item/ammo_magazine/rifle/extended = list(xxx, "Extended M41A1 magazine", 15, null, "black"),
							/obj/item/ammo_magazine/smg/m39/ap = list(xxx, "AP M39 magazine", 13, null, "black"),
							/obj/item/ammo_magazine/smg/m39/extended = list(xxx, "Extended M39 magazine", 13, null, "black"),

							null = list(xxx, "GUN ATTACHMENTS (Choose 2)", 0, null, null),
							null = list(xxx, "MUZZLE ATTACHMENTS", 0, null, null),
							/obj/item/attachable/suppressor = list(xxx, "Suppressor", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/extended_barrel = list(xxx, "Extended barrel", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							/obj/item/attachable/compensator = list(xxx, "Recoil compensator", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							null = list(xxx, "RAIL ATTACHMENTS", 0, null, null),
							/obj/item/attachable/magnetic_harness = list(xxx, "Magnetic harness", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							/obj/item/attachable/reddot = list(xxx, "Red dot sight", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/quickfire = list(xxx, "Quickfire assembly", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							null = list(xxx, "UNDERBARREL ATTACHMENTS", 0, null, null),
							/obj/item/attachable/lasersight = list(xxx, "Laser sight", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/verticalgrip = list(xxx, "Vertical grip", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/angledgrip = list(xxx, "Angled grip", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							null = list(xxx, "STOCKS", 0, null, null),
							/obj/item/attachable/stock/rifle = list(xxx, "M41A1 skeleton stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/stock/shotgun = list(xxx, "M37 wooden stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/stock/smg = list(xxx, "M39 submachinegun stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
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
							null = list(xxx, "SPECIALIST SETS (Choose one)", 0, null, null),
							/obj/item/storage/box/spec/scout = list(xxx, "Scout Set (Battle Rifle)", 0, MARINE_CAN_BUY_ESSENTIALS, "white"),
							/obj/item/storage/box/spec/sniper = list(xxx, "Sniper Set", 0, MARINE_CAN_BUY_ESSENTIALS, "white"),
							/obj/item/storage/box/spec/demolitionist = list(xxx, "Demolitionist Set", 0, MARINE_CAN_BUY_ESSENTIALS, "white"),
							/obj/item/storage/box/spec/heavy_grenadier = list(xxx, "Heavy Armor Set (Grenadier)", 0, MARINE_CAN_BUY_ESSENTIALS, "white"),
							/obj/item/storage/box/spec/heavy_gunner = list(xxx, "Heavy Armor Set (Minigun)", 0, MARINE_CAN_BUY_ESSENTIALS, "white"),
							/obj/item/storage/box/spec/pyro = list(xxx, "Pyro Set", 0, MARINE_CAN_BUY_ESSENTIALS, "white"),

							null = list(xxx, "SPECIAL AMMUNITION", 0, null, null),
							/obj/item/ammo_magazine/pistol/ap = list(xxx, "AP M4A3 magazine", 10, null, "black"),
							/obj/item/ammo_magazine/pistol/extended = list(xxx, "Extended M4A3 magazine", 10, null, "black"),
							/obj/item/ammo_magazine/pistol/vp70 = list(xxx, "88M4 AP magazine", 15, null, "black"),
							/obj/item/ammo_magazine/revolver/marksman = list(xxx, "M44 marksman speed loader", 15, null, "black"),
							/obj/item/ammo_magazine/rifle/ap = list(xxx, "AP M41A1 magazine", 15, null, "black"),
							/obj/item/ammo_magazine/rifle/extended = list(xxx, "Extended M41A1 magazine", 15, null, "black"),
							/obj/item/ammo_magazine/smg/m39/ap = list(xxx, "AP M39 magazine", 13, null, "black"),
							/obj/item/ammo_magazine/smg/m39/extended = list(xxx, "Extended M39 magazine", 13, null, "black"),

							null = list(xxx, "GUN ATTACHMENTS (Choose 2)", 0, null, null),
							null = list(xxx, "MUZZLE ATTACHMENTS", 0, null, null),
							/obj/item/attachable/suppressor = list(xxx, "Suppressor", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/extended_barrel = list(xxx, "Extended barrel", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							/obj/item/attachable/compensator = list(xxx, "Recoil compensator", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							null = list(xxx, "RAIL ATTACHMENTS", 0, null, null),
							/obj/item/attachable/magnetic_harness = list(xxx, "Magnetic harness", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							/obj/item/attachable/reddot = list(xxx, "Red dot sight", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/quickfire = list(xxx, "Quickfire assembly", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							null = list(xxx, "UNDERBARREL ATTACHMENTS", 0, null, null),
							/obj/item/attachable/lasersight = list(xxx, "Laser sight", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/verticalgrip = list(xxx, "Vertical grip", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/angledgrip = list(xxx, "Angled grip", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							null = list(xxx, "STOCKS", 0, null, null),
							/obj/item/attachable/stock/rifle = list(xxx, "M41A1 skeleton stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/stock/shotgun = list(xxx, "M37 wooden stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/stock/smg = list(xxx, "M39 submachinegun stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							)




/obj/machinery/marine_selector/gear/leader
	name = "NEXUS Automated Squad Leader Equipment Rack"
	desc = "An automated squad leader equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	vendor_role = SQUAD_LEADER
	req_access = list(ACCESS_MARINE_LEADER)

	listed_products = list(
							null = list(xxx, "SQUAD LEADER SET (Mandatory)", 0, null, null),
							/obj/effect/essentials_set/leader = list(xxx, "Essential SL Set", 0, MARINE_CAN_BUY_ESSENTIALS, "white"),

							null = list(xxx, "LEADER SUPPLIES", 0, null, null),
							/obj/item/squad_beacon = list(xxx, "Supply beacon", 10, null, "black"),
							/obj/item/squad_beacon/bomb = list(xxx, "Orbital beacon", 15, null, "black"),
							/obj/item/tool/shovel/etool = list(xxx, "Entrenching tool", 1, null, "black"),
							/obj/item/stack/sandbags_empty/half = list(xxx, "Sandbags x25", 10, null, "black"),
							/obj/item/explosive/plastique = list(xxx, "Plastique explosive", 3, null, "black"),
							/obj/item/detpack = list(xxx, "Detonation pack", 5, null, "black"),
							/obj/item/explosive/grenade/smokebomb = list(xxx, "Smoke grenade", 2, null, "black"),
							/obj/item/explosive/grenade/cloakbomb = list(xxx, "Cloak grenade", 3, null, "black"),
							/obj/item/explosive/grenade/incendiary = list(xxx, "M40 HIDP incendiary grenade", 3, null, "black"),
							/obj/item/explosive/grenade/frag = list(xxx, "M40 HEDP grenade", 3, null, "black"),
							/obj/item/explosive/grenade/impact = list(xxx, "M40 IMDP grenade", 3, null, "black"),
							/obj/item/weapon/gun/rifle/lmg = list(xxx, "M41AE2 heavy pulse rifle", 12, null, "orange"),
							/obj/item/ammo_magazine/lmg = list(xxx, "M41AE2 magazine", 4, null, "black"),
							/obj/item/weapon/gun/flamer = list(xxx, "Flamethrower", 12, null, "orange"),
							/obj/item/ammo_magazine/flamer_tank = list(xxx, "Flamethrower tank", 4, null, "black"),
							/obj/item/whistle = list(xxx, "Whistle", 5, null, "black"),
							/obj/item/radio = list(xxx, "Station bounced radio", 1, null, "black"),
							/obj/item/assembly/signaler = list(xxx, "Signaler (for detpacks)", 1, null, "black"),
							/obj/item/motiondetector = list(xxx, "Motion detector", 5, null, "black"),
							/obj/item/storage/firstaid/adv = list(xxx, "Advanced firstaid kit", 10, null, "orange"),
							/obj/item/storage/box/zipcuffs = list(xxx, "Ziptie box", 5, null, "black"),
							list("V1 thermal-dampening tarp", 5, /obj/structure/closet/bodybag/tarp, null, "black"),

							null = list(xxx, "SPECIAL AMMUNITION", 0, null, null),
							/obj/item/ammo_magazine/pistol/hp = list(xxx, "HP M4A3 magazine", 5, null, "black"),
							/obj/item/ammo_magazine/pistol/ap = list(xxx, "AP M4A3 magazine", 3, null, "black"),
							/obj/item/ammo_magazine/pistol/extended = list(xxx, "Extended M4A3 magazine", 3, null, "black"),
							/obj/item/ammo_magazine/rifle/ap = list(xxx, "AP M41A1 magazine", 6, null, "black"),
							/obj/item/ammo_magazine/rifle/extended = list(xxx, "Extended M41A1 magazine", 6, null, "black"),
							/obj/item/ammo_magazine/smg/m39/ap = list(xxx, "AP M39 magazine", 5, null, "black"),
							/obj/item/ammo_magazine/smg/m39/extended = list(xxx, "Extended M39 magazine", 5, null, "black"),

							null = list(xxx, "GUN ATTACHMENTS (Choose 2)", 0, null, null),
							null = list(xxx, "MUZZLE ATTACHMENTS", 0, null, null),
							/obj/item/attachable/suppressor = list(xxx, "Suppressor", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/extended_barrel = list(xxx, "Extended barrel", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							/obj/item/attachable/compensator = list(xxx, "Recoil compensator", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							null = list(xxx, "RAIL ATTACHMENTS", 0, null, null),
							/obj/item/attachable/magnetic_harness = list(xxx, "Magnetic harness", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							/obj/item/attachable/reddot = list(xxx, "Red dot sight", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/quickfire = list(xxx, "Quickfire assembly", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							null = list(xxx, "UNDERBARREL ATTACHMENTS", 0, null, null),
							/obj/item/attachable/lasersight = list(xxx, "Laser sight", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/verticalgrip = list(xxx, "Vertical grip", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/angledgrip = list(xxx, "Angled grip", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "orange"),
							null = list(xxx, "STOCKS", 0, null, null),
							/obj/item/attachable/stock/rifle = list(xxx, "M41A1 skeleton stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/stock/shotgun = list(xxx, "M37 wooden stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
							/obj/item/attachable/stock/smg = list(xxx, "M39 submachinegun stock", 0, (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2), "black"),
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
						/obj/item/clothing/head/helmet/marine/standard,
						/obj/item/clothing/under/marine,
						/obj/item/clothing/shoes/marine,
						/obj/item/weapon/combat_knife,
						/obj/item/storage/box/MRE,
						)


/obj/effect/essentials_set/basic_smartgunner
	spawned_gear_list = list(
						/obj/item/clothing/head/helmet/marine/standard,
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
						/obj/item/reagent_containers/hypospray/advanced/oxycodone,
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
						/obj/item/reagent_containers/hypospray/advanced/oxycodone
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

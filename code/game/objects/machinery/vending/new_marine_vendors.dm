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



#define MARINE_CAN_BUY_ALL			((1 << 16) - 1)

#define MARINE_TOTAL_BUY_POINTS		45

#define CAT_ESS "ESSENTIALS"
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

#define CAT_MEDSUP "MEDICAL SUPPLIES"
#define CAT_ENGSUP "ENGINEERING SUPPLIES"
#define CAT_LEDSUP "LEADER SUPPLIES"
#define CAT_SPEAMM "SPECIAL AMMUNITION"

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
		CAT_MEDSUP = null,
		CAT_ENGSUP = null,
		CAT_LEDSUP = null,
		CAT_SPEAMM = null,
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
		var/list/avail_flags = GLOB.marine_selector_cats[category]
		var/flags = NONE
		if(LAZYLEN(avail_flags))
			for(var/f in avail_flags)
				flags |= f
			if(buy_flags & flags)
				prod_available = TRUE
		else if(m_points >= p_cost)
			prod_available = TRUE

		LAZYADD(display_list[category], list(list("prod_index" = i, "prod_name" = p_name, "prod_available" = prod_available, "prod_color" = myprod[4])))

	var/list/cats = list()
	for(var/i in GLOB.marine_selector_cats)
		if(!display_list[i]) // vendor doesnt have this category
			continue
		cats[i] = 0
		for(var/flag in GLOB.marine_selector_cats[i])
			if(buy_flags & flag)
				cats[i]++

	var/list/data = list(
		"vendor_name" = name,
		"show_points" = use_points,
		"current_m_points" = m_points,
		"displayed_records" = display_list,
		"cats" = cats,
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

			var/idx = text2path(params["vend"])
			var/obj/item/card/id/I = usr.get_idcard()

			var/list/L = listed_products[idx]
			var/cost = L[3]

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
			var/bitf = NONE
			var/list/C = GLOB.marine_selector_cats[L[1]]
			for(var/i in C)
				bitf |= i
			if(bitf)
				if(bitf == MARINE_CAN_BUY_ESSENTIALS && vendor_role == SQUAD_SPECIALIST)
					if(!usr.mind || usr.mind.assigned_role != SQUAD_SPECIALIST)
						to_chat(usr, "<span class='warning'>Only specialists can take specialist sets.</span>")
						return
					else if(!usr.mind.cm_skills || usr.mind.cm_skills.spec_weapons != SKILL_SPEC_TRAINED)
						to_chat(usr, "<span class='warning'>You already have a specialist specialization.</span>")
						return
					var/p_name = L[2]
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

			new idx(loc)

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
				var/p_name = L[2]
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
		CAT_HEL = list(MARINE_CAN_BUY_HELMET),
		CAT_AMR = list(MARINE_CAN_BUY_ARMOR),
		CAT_BAK = list(MARINE_CAN_BUY_BACKPACK),
		CAT_WEB = list(MARINE_CAN_BUY_WEBBING),
		CAT_POU = list(MARINE_CAN_BUY_R_POUCH,MARINE_CAN_BUY_L_POUCH),
		CAT_MAS = list(MARINE_CAN_BUY_MASK),
		CAT_ATT = list(MARINE_CAN_BUY_ATTACHMENT,MARINE_CAN_BUY_ATTACHMENT2),
	)

	listed_products = list(
		/obj/effect/essentials_set/basic = list(CAT_STD, "Standard Kit", 0, "white"),
		/obj/item/clothing/head/helmet/marine/standard = list(CAT_HEL, "Regular Helmet", 0, "orange"),
		/obj/item/clothing/head/helmet/marine/heavy = list(CAT_HEL, "Heavy Helmet", 0, "black"),
		/obj/item/clothing/suit/storage/marine = list(CAT_AMR, "Regular Armor", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/M3HB = list(CAT_AMR, "Heavy Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/M3LB = list(CAT_AMR, "Light Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/M3IS = list(CAT_AMR, "Integrated Storage Armor", 0, "black"),
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
		/obj/item/attachable/stock/shotgun = list(CAT_ATT, "M37 wooden stock", 0,"black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 Submachinegun stock", 0,"black"),
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
		/obj/effect/essentials_set/basic_engineer = list(CAT_STD, "Standard Kit", 0, "white"),
		/obj/item/clothing/suit/storage/marine = list(CAT_AMR, "Regular Armor", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/M3HB = list(CAT_AMR, "Heavy Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/M3LB = list(CAT_AMR, "Light Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/M3IS = list(CAT_AMR, "Integrated Storage Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/harness = list(CAT_AMR, "Harness", 0, "black"),
		/obj/item/storage/backpack/marine/satchel/tech = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/tech = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/large_holster/m37 = list(CAT_BAK, "Shotgun scabbard", 0, "black"),
		/obj/item/storage/large_holster/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/storage/backpack/marine/engineerpack = list(CAT_BAK, "Welderpack", 0, "black"),
		/obj/item/clothing/tie/storage/brown_vest = list(CAT_WEB, "Tactical Brown Vest", 0, "orange"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder Handgun Holster", 0, "black"),
		/obj/item/storage/belt/utility/full = list(CAT_BEL, "Tool belt", 0, "orange"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/construction = list(CAT_POU, "Construction pouch", 0, "orange"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tools pouch", 0, "black"),
		/obj/item/storage/pouch/electronics/full = list(CAT_POU, "Electronics pouch", 0, "black"),
		/obj/item/storage/pouch/magazine = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "orange"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Large pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, "black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
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
		/obj/effect/essentials_set/basic_medic = list(CAT_STD, "Standard Kit", 0, "white"),
		/obj/item/clothing/suit/storage/marine = list(CAT_AMR, "Regular Armor", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/M3HB = list(CAT_AMR, "Heavy Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/M3LB = list(CAT_AMR, "Light Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/M3IS = list(CAT_AMR, "Integrated Storage Armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/harness = list(CAT_AMR, "Harness", 0, "black"),
		/obj/item/storage/backpack/marine/satchel/corpsman = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/corpsman = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/clothing/tie/storage/brown_vest = list(CAT_WEB, "Tactical Brown Vest", 0, "orange"),
		/obj/item/clothing/tie/storage/white_vest/medic = list(CAT_WEB, "Corpsman White Vest", 0, "black"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder Handgun Holster", 0, "black"),
		/obj/item/storage/belt/combatLifesaver = list(CAT_BEL, "Lifesaver belt", 0, "orange"),
		/obj/item/storage/belt/medical = list(CAT_BEL, "Medical belt", 0, "black"),
		/obj/item/storage/pouch/medical = list(CAT_POU, "Medical pouch", 0, "orange"),
		/obj/item/storage/pouch/medkit = list(CAT_POU, "Medkit pouch", 0, "orange"),
		/obj/item/storage/pouch/autoinjector = list(CAT_POU, "Autoinjector pouch", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/magazine = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Large pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, "black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
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
		/obj/effect/essentials_set/basic_smartgunner = list(CAT_STD, "Standard Kit", 0, "white"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical Black Vest", 0, "orange"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder Handgun Holster", 0, "black"),
		/obj/item/storage/large_holster/t19 = list(CAT_BEL, "T-19 holster belt", 0, "orange"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/m4a3 = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/m44 = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/magazine = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "orange"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "orange"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Large pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, "black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
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
		/obj/effect/essentials_set/basic_specialist = list(CAT_STD, "Standard Kit", 0, "white"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "black"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/large_holster/m37 = list(CAT_BAK, "Shotgun scabbard", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical Black Vest", 0, "black"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder Handgun Holster", 0, "black"),
		/obj/item/storage/large_holster/t19 = list(CAT_BEL, "T-19 holster belt", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/m4a3 = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/m44 = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt Harness", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Large magazine pouch", 0, "black"),
		/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Large pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, "black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
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
		/obj/effect/essentials_set/basic_squadleader = list(CAT_STD, "Standard Kit", 0, "white"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "black"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/large_holster/m37 = list(CAT_BAK, "Shotgun scabbard", 0, "black"),
		/obj/item/storage/large_holster/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical Black Vest", 0, "black"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder Handgun Holster", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/large_holster/t19 = list(CAT_BEL, "T-19 holster belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/m4a3 = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/m44 = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt Harness", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/general/large = list(CAT_POU, "Large general pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Large magazine pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "black"),
		/obj/item/storage/pouch/medkit = list(CAT_POU, "Medkit pouch", 0, "black"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch (tools included)", 0, "black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch (materials included)", 0, "black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Large pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, "black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
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
		/obj/effect/essentials_set/synth = list(CAT_ESS, "Essential Synthetic Set", 0, "white"),
		/obj/item/clothing/under/marine = list(CAT_STD, "TGMC marine uniform", 0, "black"),
		/obj/item/clothing/under/rank/medical/green = list(CAT_STD, "Medical scrubs", 0, "black"),
		/obj/item/clothing/under/marine/officer/engi = list(CAT_STD, "Engineering uniform", 0, "black"),
		/obj/item/clothing/under/marine/officer/logistics = list(CAT_STD, "Officer uniform", 0, "black"),
		/obj/item/clothing/under/whites = list(CAT_STD, "TGMC dress uniform", 0, "black"),
		/obj/item/clothing/under/marine/officer/pilot = list(CAT_STD, "Pilot bodysuit", 0, "black"),
		/obj/item/clothing/under/marine/mp = list(CAT_STD, "Military police uniform", 0, "black"),
		/obj/item/clothing/under/marine/officer/researcher = list(CAT_STD, "Researcher outfit", 0, "black"),
		/obj/item/clothing/under/rank/chef = list(CAT_STD, "Chef uniform", 0, "black"),
		/obj/item/clothing/under/rank/bartender = list(CAT_STD, "Bartender uniform", 0, "black"),
		/obj/item/clothing/suit/storage/hazardvest = list(CAT_AMR, "Hazard vest", 0, "black"),
		/obj/item/clothing/suit/surgical = list(CAT_AMR, "Surgical apron", 0, "black"),
		/obj/item/clothing/suit/storage/labcoat = list(CAT_AMR, "Labcoat", 0, "black"),
		/obj/item/clothing/suit/storage/labcoat/researcher = list(CAT_AMR, "Researcher's labcoat", 0, "black"),
		/obj/item/clothing/suit/storage/snow_suit = list(CAT_AMR, "Snow suit", 0, "black"),
		/obj/item/clothing/suit/armor/vest/pilot = list(CAT_AMR, "M70 flak jacket", 0, "black"),
		/obj/item/clothing/suit/storage/marine/MP = list(CAT_AMR, "N2 pattern MA armor", 0, "black"),
		/obj/item/clothing/suit/storage/marine/MP/RO = list(CAT_AMR, "M3 pattern officer armor", 0, "black"),
		/obj/item/clothing/suit/chef = list(CAT_AMR, "Chef's apron", 0, "black"),
		/obj/item/clothing/suit/wcoat = list(CAT_AMR, "Waistcoat", 0, "black"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "black"),
		/obj/item/storage/backpack/marine = list(CAT_BAK, "Lightweight IMP backpack", 0, "black"),
		/obj/item/storage/backpack/industrial = list(CAT_BAK, "Industrial backpack", 0, "black"),
		/obj/item/storage/backpack/marine/corpsman = list(CAT_BAK, "TGMC corpsman backpack", 0, "black"),
		/obj/item/storage/backpack/marine/tech = list(CAT_BAK, "TGMC technician backpack", 0, "black"),
		/obj/item/storage/backpack/marine/engineerpack = list(CAT_BAK, "TGMC technician welderpack", 0, "black"),
		/obj/item/storage/backpack/lightpack = list(CAT_BAK, "Lightweight combat pack", 0, "black"),
		/obj/item/storage/backpack/marine/satchel/officer_cloak = list(CAT_BAK, "Officer cloak", 0, "black"),
		/obj/item/storage/backpack/marine/satchel/officer_cloak_red = list(CAT_BAK, "Officer cloak, red", 0, "black"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Webbing", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical Black Vest", 0, "black"),
		/obj/item/clothing/tie/storage/white_vest/medic = list(CAT_WEB, "White medical vest", 0, "black"),
		/obj/item/clothing/gloves/yellow = list(CAT_GLO, "Insulated gloves", 0, "black"),
		/obj/item/clothing/gloves/latex = list(CAT_GLO, "Latex gloves", 0, "black"),
		/obj/item/clothing/gloves/marine/officer = list(CAT_GLO, "Officer gloves", 0, "black"),
		/obj/item/clothing/gloves/white = list(CAT_GLO, "White gloves", 0, "black"),
		/obj/item/storage/belt/medical = list(CAT_BEL, "M276 pattern medical storage rig", 0, "black"),
		/obj/item/storage/belt/combatLifesaver = list(CAT_BEL, "M276 pattern lifesaver bag", 0, "black"),
		/obj/item/storage/belt/utility/full = list(CAT_BEL, "M276 pattern toolbelt rig", 0, "black"),
		/obj/item/storage/belt/security/MP/full = list(CAT_BEL, "M276 pattern security rig ", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "black"),
		/obj/item/clothing/shoes/marine = list(CAT_SHO, "Marine combat boots", 0, "black"),
		/obj/item/clothing/shoes/white = list(CAT_SHO, "White shoes", 0, "black"),
		/obj/item/clothing/shoes/marinechief = list(CAT_SHO, "Formal shoes", 0, "black"),
		/obj/item/storage/pouch/general/large = list(CAT_POU, "Large general pouch", 0, "black"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch", 0, "black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch", 0, "black"),
		/obj/item/storage/pouch/electronics/full = list(CAT_POU, "Electronics pouch", 0, "black"),
		/obj/item/storage/pouch/medical = list(CAT_POU, "Medical pouch", 0, "black"),
		/obj/item/storage/pouch/medkit = list(CAT_POU, "Medkit pouch", 0, "black"),
		/obj/item/storage/pouch/autoinjector = list(CAT_POU, "Autoinjector pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/radio = list(CAT_POU, "Radio pouch", 0, "black"),
		/obj/item/storage/pouch/field_pouch/full = list(CAT_POU, "Field pouch", 0, "black"),
		/obj/item/clothing/head/hardhat = list(CAT_HEL, "Hard hat", 0, "black"),
		/obj/item/clothing/head/welding = list(CAT_HEL, "Welding helmet", 0, "black"),
		/obj/item/clothing/head/surgery/green = list(CAT_HEL, "Surgical cap", 0, "black"),
		/obj/item/clothing/head/tgmccap = list(CAT_HEL, "TGMC cap", 0, "black"),
		/obj/item/clothing/head/boonie = list(CAT_HEL, "Boonie hat", 0, "black"),
		/obj/item/clothing/head/beret/marine = list(CAT_HEL, "Marine beret", 0, "black"),
		/obj/item/clothing/head/tgmcberet/red = list(CAT_HEL, "MP beret", 0, "black"),
		/obj/item/clothing/head/beret/eng = list(CAT_HEL, "Engineering beret", 0, "black"),
		/obj/item/clothing/head/ushanka = list(CAT_HEL, "Ushanka", 0, "black"),
		/obj/item/clothing/head/collectable/tophat = list(CAT_HEL, "Top hat", 0, "black"),
		/obj/item/clothing/mask/surgical = list(CAT_MAS, "Sterile mask", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Gas mask", 0, "black"),
	)



////////////////////// Gear ////////////////////////////////////////////////////////



/obj/machinery/marine_selector/gear
	name = "NEXUS Automated Equipment Rack"
	desc = "An automated equipment rack hooked up to a colossal storage unit."
	icon_state = "marinearmory"
	use_points = TRUE
	listed_products = list(
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical Grip", 0, "black"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red-dot sight", 0, "black"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil Compensator", 0, "black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser Sight", 0, "black")
	)



/obj/machinery/marine_selector/gear/medic
	name = "NEXUS Automated Medical Equipment Rack"
	desc = "An automated medic equipment rack hooked up to a colossal storage unit."
	icon_state = "medic"
	vendor_role = SQUAD_CORPSMAN
	req_access = list(ACCESS_MARINE_MEDPREP)

	listed_products = list(
		/obj/effect/essentials_set/medic = list(CAT_ESS, "Essential Medic Set", 0, "white"),

		/obj/item/storage/firstaid/regular = list(CAT_MEDSUP, "Firstaid kit", 6, "black"),
		/obj/item/storage/firstaid/adv = list(CAT_MEDSUP, "Advanced firstaid kit", 8, "orange"),
		/obj/item/bodybag/cryobag = list(CAT_MEDSUP, "Stasis bag", 4, "orange"),
		/obj/item/storage/pill_bottle/hypervene = list(CAT_MEDSUP, "Pillbottle (Hypervene)", 4, "black"),
		/obj/item/storage/pill_bottle/quickclot = list(CAT_MEDSUP, "Pillbottle (Quick-Clot)", 4, "black"),
		/obj/item/storage/pill_bottle/bicaridine = list(CAT_MEDSUP, "Pillbottle (Bicaridine)", 4, "orange"),
		/obj/item/storage/pill_bottle/kelotane = list(CAT_MEDSUP, "Pillbottle (Kelotane)", 4, "orange"),
		/obj/item/storage/pill_bottle/dylovene = list(CAT_MEDSUP, "Pillbottle (Dylovene)", 4, "black"),
		/obj/item/storage/pill_bottle/dexalin = list(CAT_MEDSUP, "Pillbottle (Dexalin)", 4, "black"),
		/obj/item/storage/pill_bottle/tramadol = list(CAT_MEDSUP, "Pillbottle (Tramadol)", 4, "orange"),
		/obj/item/storage/pill_bottle/inaprovaline = list(CAT_MEDSUP, "Pillbottle (Inaprovaline)", 4, "black"),
		/obj/item/storage/pill_bottle/peridaxon = list(CAT_MEDSUP, "Pillbottle (Peridaxon)", 4, "black"),
		/obj/item/storage/syringe_case/meralyne = list(CAT_MEDSUP, "syringe Case (120u Meralyne)", 15, "orange"),
		/obj/item/storage/syringe_case/dermaline = list(CAT_MEDSUP, "syringe Case (120u Dermaline)", 15, "orange"),
		/obj/item/storage/syringe_case/meraderm = list(CAT_MEDSUP, "syringe Case (120u Meraderm)", 15, "orange"),
		/obj/item/storage/syringe_case/ironsugar = list(CAT_MEDSUP, "syringe Case (120u Ironsugar)", 15, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = list(CAT_MEDSUP, "Injector (Inaprovaline)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = list(CAT_MEDSUP, "Injector (Bicaridine)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/kelotane = list(CAT_MEDSUP, "Injector (Kelotane)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = list(CAT_MEDSUP, "Injector (Dylovene)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = list(CAT_MEDSUP, "Injector (Dexalin+)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = list(CAT_MEDSUP, "Injector (Quick-Clot)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = list(CAT_MEDSUP, "Injector (Oxycodone)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = list(CAT_MEDSUP, "Injector (Tricord)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/hypervene = list(CAT_MEDSUP, "Injector (Hypervene)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/hyperzine = list(CAT_MEDSUP, "Injector (Hyperzine)", 10, "orange"),
		/obj/item/reagent_containers/hypospray/advanced = list(CAT_MEDSUP, "Advanced hypospray", 2, "black"),
		/obj/item/healthanalyzer = list(CAT_MEDSUP, "Health analyzer", 2, "black"),
		/obj/item/clothing/glasses/hud/health = list(CAT_MEDSUP, "Medical HUD glasses", 2, "black"),

		/obj/item/ammo_magazine/pistol/ap = list(CAT_SPEAMM, "AP M4A3 magazine", 3, "black"),
		/obj/item/ammo_magazine/pistol/extended = list(CAT_SPEAMM, "Extended M4A3 magazine", 3, "black"),

		/obj/item/attachable/suppressor = list(CAT_ATT, "Suppressor", 0, "black"),
		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0, "orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0, "black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0, "orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0, "black"),
		/obj/item/attachable/quickfire = list(CAT_ATT, "Quickfire assembly", 0, "black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0, "black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0, "black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0, "orange"),
		/obj/item/attachable/stock/shotgun = list(CAT_ATT, "M37 wooden stock", 0, "black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 Submachinegun stock", 0, "black"),
	)



/obj/machinery/marine_selector/gear/engi
	name = "NEXUS Automated Engineer Equipment Rack"
	desc = "An automated engineer equipment rack hooked up to a colossal storage unit."
	icon_state = "engineer"
	vendor_role = SQUAD_ENGINEER
	req_access = list(ACCESS_MARINE_ENGPREP)

	listed_products = list(
		/obj/effect/essentials_set/engi = list(CAT_ESS, "Essential Engineer Set", 0, "white"),

		/obj/item/stack/sheet/metal/small_stack = list(CAT_ENGSUP, "Metal x10", 5, "orange"),
		/obj/item/stack/sheet/plasteel/small_stack = list(CAT_ENGSUP, "Plasteel x10", 7, "orange"),
		/obj/item/stack/sandbags_empty/half = list(CAT_ENGSUP, "Sandbags x25", 10, "orange"),
		/obj/item/tool/pickaxe/plasmacutter = list(CAT_ENGSUP, "Plasma cutter", 20, "black"),
		/obj/item/storage/box/minisentry = list(CAT_ENGSUP, "UA-580 point defense sentry kit", 26, "black"),
		/obj/item/explosive/plastique = list(CAT_ENGSUP, "Plastique explosive", 3, "black"),
		/obj/item/detpack = list(CAT_ENGSUP, "Detonation pack", 5, "black"),
		/obj/item/tool/shovel/etool = list(CAT_ENGSUP, "Entrenching tool", 1, "black"),
		/obj/item/binoculars/tactical/range = list(CAT_ENGSUP, "Range Finder", 10, "black"),
		/obj/item/cell/high = list(CAT_ENGSUP, "High capacity powercell", 1, "black"),
		/obj/item/storage/box/explosive_mines = list(CAT_ENGSUP, "M20 mine box", 18, "black"),
		/obj/item/explosive/grenade/incendiary = list(CAT_ENGSUP, "Incendiary grenade", 6, "black"),
		/obj/item/multitool = list(CAT_ENGSUP, "Multitool", 1, "black"),
		/obj/item/circuitboard/general = list(CAT_ENGSUP, "General circuit board", 1, "black"),
		/obj/item/assembly/signaler = list(CAT_ENGSUP, "Signaler (for detpacks)", 1, "black"),

		/obj/item/ammo_magazine/pistol/ap = list(CAT_SPEAMM, "AP M4A3 magazine", 3, "black"),
		/obj/item/ammo_magazine/pistol/extended = list(CAT_SPEAMM, "Extended M4A3 magazine", 3, "black"),

		/obj/item/attachable/suppressor = list(CAT_ATT, "Suppressor", 0, "black"),
		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0, "orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0, "black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0, "orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0, "black"),
		/obj/item/attachable/quickfire = list(CAT_ATT, "Quickfire assembly", 0, "black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0, "black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0, "black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0, "orange"),
		/obj/item/attachable/stock/shotgun = list(CAT_ATT, "M37 wooden stock", 0, "black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 Submachinegun stock", 0, "black"),
	)



/obj/machinery/marine_selector/gear/smartgun
	name = "NEXUS Automated Smartgunner Equipment Rack"
	desc = "An automated smartgunner equipment rack hooked up to a colossal storage unit."
	icon_state = "smartgunner"
	vendor_role = SQUAD_SMARTGUNNER
	req_access = list(ACCESS_MARINE_SMARTPREP)

	listed_products = list(
		/obj/item/storage/box/m56_system = list(CAT_ESS, "Essential Smartgunner Set", 0, "white"),

		/obj/item/smartgun_powerpack = list(CAT_SPEAMM, "M56 powerpack", 45, "black"),
		/obj/item/ammo_magazine/pistol/ap = list(CAT_SPEAMM, "AP M4A3 magazine", 10, "black"),
		/obj/item/ammo_magazine/pistol/extended = list(CAT_SPEAMM, "Extended M4A3 magazine", 10, "black"),

		/obj/item/attachable/suppressor = list(CAT_ATT, "Suppressor", 0, "black"),
		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0, "orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0, "black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0, "orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0, "black"),
		/obj/item/attachable/quickfire = list(CAT_ATT, "Quickfire assembly", 0, "black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0, "black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0, "black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0, "orange"),
		/obj/item/attachable/stock/shotgun = list(CAT_ATT, "M37 wooden stock", 0, "black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 Submachinegun stock", 0, "black"),
	)


//todo: move this to some sort of kit controller/datum
//the global list of specialist sets that haven't been claimed yet.
GLOBAL_LIST_INIT(available_specialist_sets, list("Scout Set", "Sniper Set", "Demolitionist Set", "Heavy Grenadier Set","Heavy Gunner Set", "Pyro Set"))


/obj/machinery/marine_selector/gear/spec
	name = "NEXUS Automated Specialist Equipment Rack"
	desc = "An automated specialist equipment rack hooked up to a colossal storage unit."
	icon_state = "specialist"
	vendor_role = SQUAD_SPECIALIST
	req_access = list(ACCESS_MARINE_SPECPREP)

	listed_products = list(
		/obj/item/storage/box/spec/scout = list(CAT_ESS, "Scout Set (Battle Rifle)", 0, "white"),
		/obj/item/storage/box/spec/tracker = list(CAT_ESS, "Scout Set (Shotgun)", 0, "white"),
		/obj/item/storage/box/spec/sniper = list(CAT_ESS, "Sniper Set", 0, "white"),
		/obj/item/storage/box/spec/demolitionist = list(CAT_ESS, "Demolitionist Set", 0, "white"),
		/obj/item/storage/box/spec/heavy_grenadier = list(CAT_ESS, "Heavy Grenadier Set", 0, "white"),
		/obj/item/storage/box/spec/heavy_gunner = list(CAT_ESS, "Heavy Gunner Set", 0, "white"),
		/obj/item/storage/box/spec/pyro = list(CAT_ESS, "Pyro Set", 0, "white"),

		/obj/item/ammo_magazine/pistol/ap = list(CAT_SPEAMM, "AP M4A3 magazine", 10, "black"),
		/obj/item/ammo_magazine/pistol/extended = list(CAT_SPEAMM, "Extended M4A3 magazine", 10, "black"),
		/obj/item/ammo_magazine/pistol/vp70 = list(CAT_SPEAMM, "88M4 AP magazine", 15, "black"),
		/obj/item/ammo_magazine/revolver/marksman = list(CAT_SPEAMM, "M44 marksman speed loader", 15, "black"),

		/obj/item/attachable/suppressor = list(CAT_ATT, "Suppressor", 0, "black"),
		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0, "orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0, "black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0, "orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0, "black"),
		/obj/item/attachable/quickfire = list(CAT_ATT, "Quickfire assembly", 0, "black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0, "black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0, "black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0, "orange"),
		/obj/item/attachable/stock/shotgun = list(CAT_ATT, "M37 wooden stock", 0, "black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 Submachinegun stock", 0, "black"),
	)




/obj/machinery/marine_selector/gear/leader
	name = "NEXUS Automated Squad Leader Equipment Rack"
	desc = "An automated squad leader equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	vendor_role = SQUAD_LEADER
	req_access = list(ACCESS_MARINE_LEADER)

	listed_products = list(
		/obj/effect/essentials_set/leader = list(CAT_ESS, "Essential SL Set", 0, "white"),

		/obj/item/squad_beacon = list(CAT_LEDSUP, "Supply beacon", 10, "black"),
		/obj/item/squad_beacon/bomb = list(CAT_LEDSUP, "Orbital beacon", 15, "black"),
		/obj/item/tool/shovel/etool = list(CAT_LEDSUP, "Entrenching tool", 1, "black"),
		/obj/item/stack/sandbags_empty/half = list(CAT_LEDSUP, "Sandbags x25", 10, "black"),
		/obj/item/explosive/plastique = list(CAT_LEDSUP, "Plastique explosive", 3, "black"),
		/obj/item/detpack = list(CAT_LEDSUP, "Detonation pack", 5, "black"),
		/obj/item/explosive/grenade/smokebomb = list(CAT_LEDSUP, "Smoke grenade", 2, "black"),
		/obj/item/explosive/grenade/cloakbomb = list(CAT_LEDSUP, "Cloak grenade", 3, "black"),
		/obj/item/explosive/grenade/incendiary = list(CAT_LEDSUP, "M40 HIDP incendiary grenade", 3, "black"),
		/obj/item/explosive/grenade/frag = list(CAT_LEDSUP, "M40 HEDP grenade", 3, "black"),
		/obj/item/weapon/gun/flamer = list(CAT_LEDSUP, "Flamethrower", 12, "orange"),
		/obj/item/ammo_magazine/flamer_tank = list(CAT_LEDSUP, "Flamethrower tank", 4, "black"),
		/obj/item/whistle = list(CAT_LEDSUP, "Whistle", 5, "black"),
		/obj/item/radio = list(CAT_LEDSUP, "Station bounced radio", 1, "black"),
		/obj/item/assembly/signaler = list(CAT_LEDSUP, "Signaler (for detpacks)", 1, "black"),
		/obj/item/motiondetector = list(CAT_LEDSUP, "Motion detector", 5, "black"),
		/obj/item/storage/firstaid/adv = list(CAT_LEDSUP, "Advanced firstaid kit", 10, "orange"),
		/obj/item/storage/box/zipcuffs = list(CAT_LEDSUP, "Ziptie box", 5, "black"),
		/obj/structure/closet/bodybag/tarp = list(CAT_LEDSUP, "V1 thermal-dampening tarp", 5, "black"),

		/obj/item/ammo_magazine/pistol/hp = list(CAT_SPEAMM, "HP M4A3 magazine", 5, "black"),
		/obj/item/ammo_magazine/pistol/ap = list(CAT_SPEAMM, "AP M4A3 magazine", 3, "black"),
		/obj/item/ammo_magazine/pistol/extended = list(CAT_SPEAMM, "Extended M4A3 magazine", 3, "black"),

		/obj/item/attachable/suppressor = list(CAT_ATT, "Suppressor", 0, "black"),
		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0, "orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0, "black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0, "orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0, "black"),
		/obj/item/attachable/quickfire = list(CAT_ATT, "Quickfire assembly", 0, "black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0, "black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0, "black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0, "orange"),
		/obj/item/attachable/stock/shotgun = list(CAT_ATT, "M37 wooden stock", 0, "black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 Submachine Gun stock", 0, "black"),
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
						/obj/item/clothing/under/marine,
						/obj/item/clothing/shoes/marine,
						/obj/item/weapon/combat_knife,
						/obj/item/storage/box/MRE,
						)


/obj/effect/essentials_set/basic_smartgunner
	spawned_gear_list = list(
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

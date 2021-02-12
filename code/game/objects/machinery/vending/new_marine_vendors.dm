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
#define MARINE_CAN_BUY_MODULE		(1 << 16)
#define MARINE_CAN_BUY_ARMORMOD		(1 << 17)



#define MARINE_CAN_BUY_ALL			((1 << 18) - 1)

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
#define CAT_MOD "JAEGER STORAGE MODULES"
#define CAT_ARMMOD "JAEGER ARMOR MODULES"

#define CAT_MEDSUP "MEDICAL SUPPLIES"
#define CAT_ENGSUP "ENGINEERING SUPPLIES"
#define CAT_LEDSUP "LEADER SUPPLIES"
#define CAT_SPEAMM "SPECIAL AMMUNITION"

/obj/item/card/id/var/marine_points = MARINE_TOTAL_BUY_POINTS
/obj/item/card/id/var/marine_buy_flags = MARINE_CAN_BUY_ALL

GLOBAL_LIST_INIT(marine_selector_cats, list(
		CAT_MOD = list(MARINE_CAN_BUY_MODULE),
		CAT_ARMMOD = list(MARINE_CAN_BUY_ARMORMOD),
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
	req_one_access = null
	interaction_flags = INTERACT_MACHINE_TGUI

	idle_power_usage = 60
	active_power_usage = 3000

	var/gives_webbing = FALSE
	var/vendor_role //to be compared with job.type to only allow those to use that machine.
	var/squad_tag = ""
	var/use_points = FALSE
	var/lock_flags = SQUAD_LOCK|JOB_LOCK

	var/icon_vend
	var/icon_deny

	var/list/categories
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

		if(lock_flags & JOB_LOCK && vendor_role && !istype(H.job, vendor_role))
			return FALSE

		if(lock_flags & SQUAD_LOCK && (!H.assigned_squad || (squad_tag && H.assigned_squad.name != squad_tag)))
			return FALSE

	return TRUE

/obj/machinery/marine_selector/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "MarineSelector", name)
		ui.open()

/obj/machinery/marine_selector/ui_static_data(mob/user)
	. = list()
	.["displayed_records"] = list()
	for(var/c in categories)
		.["displayed_records"][c] = list()

	.["vendor_name"] = name
	.["show_points"] = use_points
	.["total_marine_points"] = MARINE_TOTAL_BUY_POINTS

	for(var/i in listed_products)
		var/list/myprod = listed_products[i]
		var/category = myprod[1]
		var/p_name = myprod[2]
		var/p_cost = myprod[3]
		var/atom/productpath = i

		LAZYADD(.["displayed_records"][category], list(list("prod_index" = i, "prod_name" = p_name, "prod_color" = myprod[4], "prod_cost" = p_cost, "prod_desc" = initial(productpath.desc))))

/obj/machinery/marine_selector/ui_data(mob/user)
	. = list()

	var/obj/item/card/id/I = user.get_idcard()
	.["current_m_points"] = I?.marine_points || 0
	var/buy_flags = I?.marine_buy_flags || NONE


	.["cats"] = list()
	for(var/i in GLOB.marine_selector_cats)
		.["cats"][i] = list("remaining" = 0, "total" = 0)
		for(var/flag in GLOB.marine_selector_cats[i])
			.["cats"][i]["total"]++
			if(buy_flags & flag)
				.["cats"][i]["remaining"]++

/obj/machinery/marine_selector/ui_act(action, list/params)
	. = ..()
	if(.)
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
				if(bitf == MARINE_CAN_BUY_ESSENTIALS && vendor_role == /datum/job/terragov/squad/specialist)
					if(!isliving(usr))
						return
					var/mob/living/user = usr
					if(!ismarinespecjob(user.job))
						to_chat(usr, "<span class='warning'>Only specialists can take specialist sets.</span>")
						return
					if(usr.skills.getRating("spec_weapons") != SKILL_SPEC_TRAINED)
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

			var/obj/item/vended_item = new idx(loc)

			if(istype(vended_item)) // in case of spawning /obj
				usr.put_in_any_hand_if_possible(vended_item, warning = FALSE)

			if(icon_vend)
				flick(icon_vend, src)

			use_power(active_power_usage)

			if(bitf == MARINE_CAN_BUY_UNIFORM && ishumanbasic(usr))
				var/mob/living/carbon/human/H = usr
				new /obj/item/radio/headset/mainship/marine(loc, H.assigned_squad, vendor_role)
				if(!istype(H.job, /datum/job/terragov/squad/engineer))
					new /obj/item/clothing/gloves/marine(loc, H.assigned_squad, vendor_role)
				if(istype(H.job, /datum/job/terragov/squad/leader))
					new /obj/item/hud_tablet(loc, vendor_role, H.assigned_squad)
				if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
					new /obj/item/clothing/mask/rebreather/scarf(loc)

			if(bitf == MARINE_CAN_BUY_ESSENTIALS && vendor_role == /datum/job/terragov/squad/specialist && ishuman(usr))
				var/mob/living/carbon/human/H = usr
				if(ismarinespecjob(H.job))
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
	vendor_role = /datum/job/terragov/squad/standard
	categories = list(
		CAT_STD = list(MARINE_CAN_BUY_UNIFORM),
		CAT_HEL = list(MARINE_CAN_BUY_HELMET),
		CAT_AMR = list(MARINE_CAN_BUY_ARMOR),
		CAT_BAK = list(MARINE_CAN_BUY_BACKPACK),
		CAT_WEB = list(MARINE_CAN_BUY_WEBBING),
		CAT_BEL = list(MARINE_CAN_BUY_BELT),
		CAT_POU = list(MARINE_CAN_BUY_R_POUCH,MARINE_CAN_BUY_L_POUCH),
		CAT_MAS = list(MARINE_CAN_BUY_MASK),
		CAT_ATT = list(MARINE_CAN_BUY_ATTACHMENT,MARINE_CAN_BUY_ATTACHMENT2),
		CAT_MOD = list(MARINE_CAN_BUY_MODULE),
		CAT_ARMMOD = list(MARINE_CAN_BUY_ARMORMOD),
	)

	listed_products = list(
		/obj/effect/essentials_set/basic = list(CAT_STD, "Standard Kit", 0, "white"),
		/obj/effect/essentials_set/basicmodular = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/essentials_set/modular/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/item/helmet_module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/helmet_module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/helmet_module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/helmet/marine/standard = list(CAT_HEL, "Regular helmet", 0, "black"),
		/obj/item/clothing/head/modular/marine/infantry = list(CAT_HEL, "Open Jaeger helmet", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/clothing/suit/storage/marine/pasvest = list(CAT_AMR, "Regular armor", 0, "orange"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical black vest", 0, "orange"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "Utility belt", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "orange"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "orange"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt harness", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "orange"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0,"orange"),
		/obj/item/storage/pouch/firstaid/injectors/full = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch (tools included)", 0,"black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch (materials included)", 0,"black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0,"black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0,"black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0,"black"),
		/obj/item/clothing/mask/bandanna = list(CAT_MAS, "Tan bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/green = list(CAT_MAS, "Green bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/white = list(CAT_MAS, "White bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/black = list(CAT_MAS, "Black bandanna", 0,"black"),
		/obj/item/clothing/mask/bandanna/skull = list(CAT_MAS, "Skull bandanna", 0,"black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0,"black"),
		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0,"orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0,"black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0,"orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0,"black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0,"black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0,"black"),
		/obj/item/attachable/scope/mini = list(CAT_ATT, "Mini scope", 0,"black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0,"orange"),
		/obj/item/attachable/stock/t35stock = list(CAT_ATT, "T-35 stock", 0,"black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 machine pistol stock", 0,"black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/ballistic_armor = list(CAT_ARMMOD, "Ballistic armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
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
	vendor_role = /datum/job/terragov/squad/engineer
	gives_webbing = FALSE

	listed_products = list(
		/obj/effect/essentials_set/basic_engineer = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/essentials_set/basic_engineermodular = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/essentials_set/modular/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/pasvest = list(CAT_AMR, "Regular armor", 0, "orange"),
		/obj/item/storage/backpack/marine/satchel/tech = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/tech = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/large_holster/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/storage/backpack/marine/engineerpack = list(CAT_BAK, "Welderpack", 0, "black"),
		/obj/item/clothing/tie/storage/brown_vest = list(CAT_WEB, "Tactical brown vest", 0, "orange"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/utility/full = list(CAT_BEL, "Tool belt", 0, "white"),
		/obj/item/helmet_module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/helmet_module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/helmet_module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/construction = list(CAT_POU, "Construction pouch", 0, "orange"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tools pouch", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/electronics/full = list(CAT_POU, "Electronics pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "orange"),
		/obj/item/storage/pouch/firstaid/injectors/full = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/ballistic_armor = list(CAT_ARMMOD, "Ballistic armor module", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
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
	vendor_role = /datum/job/terragov/squad/corpsman
	gives_webbing = FALSE

	listed_products = list(
		/obj/effect/essentials_set/basic_medic = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/essentials_set/basic_medicmodular = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/essentials_set/modular/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/pasvest = list(CAT_AMR, "Regular armor", 0, "orange"),
		/obj/item/storage/backpack/marine/satchel/corpsman = list(CAT_BAK, "Satchel", 0, "orange"),
		/obj/item/storage/backpack/marine/corpsman = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/clothing/tie/storage/brown_vest = list(CAT_WEB, "Tactical brown vest", 0, "orange"),
		/obj/item/clothing/tie/storage/white_vest/medic = list(CAT_WEB, "Corpsman white vest", 0, "black"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/medicLifesaver = list(CAT_BEL, "Lifesaver medic belt", 0, "orange"),
		/obj/item/storage/belt/medical = list(CAT_BEL, "Medical belt", 0, "black"),
		/obj/item/storage/pouch/autoinjector/advanced/full = list(CAT_POU, "Advanced Autoinjector pouch", 0, "orange"),
		/obj/item/storage/pouch/hypospray/corps/full = list(CAT_POU, "Advanced hypospray pouch", 0, "orange"),
		/obj/item/storage/pouch/medkit/full = list(CAT_POU, "Medkit pouch", 0, "orange"),
		/obj/item/helmet_module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/helmet_module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/helmet_module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/ballistic_armor = list(CAT_ARMMOD, "Ballistic armor module", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
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
	vendor_role = /datum/job/terragov/squad/smartgunner
	gives_webbing = FALSE

	listed_products = list(
		/obj/effect/essentials_set/basic_smartgunner = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/essentials_set/basic_smartgunnermodular = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/essentials_set/modular/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "orange"),
		/obj/item/clothing/suit/storage/marine/pasvest = list(CAT_AMR, "Regular armor", 0, "orange"),
		/obj/item/helmet_module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/helmet_module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/helmet_module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/helmet/marine/standard = list(CAT_HEL, "Regular helmet", 0, "black"),
		/obj/item/clothing/head/helmet/marine/heavy = list(CAT_HEL, "Heavy helmet", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical black vest", 0, "orange"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "orange"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "orange"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "orange"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/general/medium = list(CAT_POU, "Medium general pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "orange"),
		/obj/item/storage/pouch/firstaid/injectors/full = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "orange"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
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
	vendor_role = /datum/job/terragov/squad/specialist
	gives_webbing = FALSE


	listed_products = list(
		/obj/effect/essentials_set/basic_specialist = list(CAT_STD, "Standard Kit", 0, "white"),
		/obj/effect/essentials_set/modular/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "black"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "black"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical Black Vest", 0, "black"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical Webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder Handgun Holster", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt Harness", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/general/large = list(CAT_POU, "General pouch", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (Grenades included)", 0,"black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/firstaid/injectors/full = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/ballistic_armor = list(CAT_ARMMOD, "Ballistic armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
	)

/obj/machinery/marine_selector/clothes/specialist/Initialize()
	. = ..()
	new /obj/effect/decal/cleanable/cobweb(loc)
	for(var/d in GLOB.alldirs)
		var/turf/T = get_step(src, d)
		if(!T.density)
			new /obj/effect/decal/cleanable/cobweb(T)


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
	vendor_role = /datum/job/terragov/squad/leader
	gives_webbing = FALSE

	listed_products = list(
		/obj/effect/essentials_set/basic_squadleader = list(CAT_STD, "Standard kit (vest included)", 0, "white"),
		/obj/effect/essentials_set/basic_squadleadermodular = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/essentials_set/modular/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "black"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "black"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/large_holster/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical black vest", 0, "black"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt Harness", 0, "black"),
		/obj/item/helmet_module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/helmet_module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/helmet_module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/general/large = list(CAT_POU, "General pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/firstaid/injectors/full = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "orange"),
		/obj/item/storage/pouch/medkit = list(CAT_POU, "Medkit pouch", 0, "black"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch (tools included)", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch (materials included)", 0, "black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/ballistic_armor = list(CAT_ARMMOD, "Ballistic armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur better light armor module", 0,"black"),
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

/obj/machinery/marine_selector/clothes/commander
	name = "GHMME Automated Commander Closet"
	req_access = list(ACCESS_MARINE_COMMANDER)
	vendor_role = /datum/job/terragov/command/fieldcommander
	lock_flags = JOB_LOCK
	gives_webbing = FALSE

	listed_products = list(
		/obj/effect/essentials_set/commander = list(CAT_STD, "Standard Commander kit ", 0, "white"),
		/obj/effect/essentials_set/modular/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/essentials_set/modular/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/modular/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "black"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "black"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/large_holster/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical black vest", 0, "black"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/clothing/tie/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt Harness", 0, "black"),
		/obj/item/helmet_module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/helmet_module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/helmet_module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/general/large = list(CAT_POU, "General pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/firstaid/injectors/full = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/firstaid/full = list(CAT_POU, "Firstaid pouch", 0, "orange"),
		/obj/item/storage/pouch/medkit = list(CAT_POU, "Medkit pouch", 0, "black"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch (tools included)", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch (materials included)", 0, "black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
		/obj/item/clothing/head/headband/red = list(CAT_HEL, "FC Headband", 0, "black"),
		/obj/item/clothing/head/tgmcberet/fc = list(CAT_HEL, "FC Beret", 0, "black"),
		/obj/item/clothing/head/helmet/marine/leader = list(CAT_HEL, "FC Helmet", 0, "black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/ballistic_armor = list(CAT_ARMMOD, "Ballistic armor module", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
	)


/obj/machinery/marine_selector/clothes/synth
	name = "M57 Synthetic Equipment Vendor"
	desc = "An automated synthetic equipment vendor hooked up to a modest storage unit."
	icon_state = "synth"
	icon_vend = "synth-vend"
	icon_deny = "synth-deny"
	vendor_role = /datum/job/terragov/silicon/synthetic
	lock_flags = JOB_LOCK

	listed_products = list(
		/obj/effect/essentials_set/synth = list(CAT_ESS, "Essential synthetic set", 0, "white"),
		/obj/item/clothing/under/marine = list(CAT_STD, "TGMC marine uniform", 0, "black"),
		/obj/item/clothing/under/rank/medical/blue = list(CAT_STD, "Medical scrubs (blue)", 0, "black"),
		/obj/item/clothing/under/rank/medical/green = list(CAT_STD, "Medical scrubs (green)", 0, "black"),
		/obj/item/clothing/under/rank/medical/purple = list(CAT_STD, "Medical scrubs (purple)", 0, "black"),
		/obj/item/clothing/under/marine/officer/engi = list(CAT_STD, "Engineering uniform", 0, "black"),
		/obj/item/clothing/under/marine/officer/logistics = list(CAT_STD, "Officer uniform", 0, "black"),
		/obj/item/clothing/under/whites = list(CAT_STD, "TGMC dress uniform", 0, "black"),
		/obj/item/clothing/under/marine/officer/pilot = list(CAT_STD, "Pilot bodysuit", 0, "black"),
		/obj/item/clothing/under/marine/mp = list(CAT_STD, "Military police uniform", 0, "black"),
		/obj/item/clothing/under/marine/officer/warden = list(CAT_STD, "Marine Officer uniform", 0, "black"),
		/obj/item/clothing/under/marine/officer/researcher = list(CAT_STD, "Researcher outfit", 0, "black"),
		/obj/item/clothing/under/rank/chef = list(CAT_STD, "Chef uniform", 0, "black"),
		/obj/item/clothing/under/rank/bartender = list(CAT_STD, "Bartender uniform", 0, "black"),
		/obj/item/clothing/under/rank/chef/altchef = list(CAT_STD, "Red Chef uniform", 0, "black"),
		/obj/item/clothing/under/rank/vice = list(CAT_STD, "Vice Officer's uniform", 0, "black"),
		/obj/item/clothing/under/rank/janitor = list(CAT_STD, "Janitor uniform", 0, "black"),
		/obj/item/clothing/under/rank/det = list(CAT_STD, "Detective uniform", 0, "black"),
		/obj/item/clothing/under/rank/dispatch = list(CAT_STD, "Dispatch uniform", 0, "black"),
		/obj/item/clothing/under/overalls = list(CAT_STD, "Overalls", 0, "black"),
		/obj/item/clothing/under/CM_uniform = list(CAT_STD, "Colonial Marshal uniform", 0, "black"),
		/obj/item/clothing/under/gentlesuit = list(CAT_STD, "Gentleman's Suit", 0, "black"),
		/obj/item/clothing/under/sl_suit = list(CAT_STD, "Amish Suit", 0, "black"),
		/obj/item/clothing/under/kilt = list(CAT_STD, "Kilt", 0, "black"),
		/obj/item/clothing/under/waiter = list(CAT_STD, "Waiter's uniform", 0, "black"),
		/obj/item/clothing/suit/storage/hazardvest = list(CAT_AMR, "Hazard vest", 0, "black"),
		/obj/item/clothing/suit/surgical = list(CAT_AMR, "Surgical apron", 0, "black"),
		/obj/item/clothing/suit/storage/labcoat = list(CAT_AMR, "Labcoat", 0, "black"),
		/obj/item/clothing/suit/storage/labcoat/researcher = list(CAT_AMR, "Researcher's labcoat", 0, "black"),
		/obj/item/clothing/suit/storage/CMB = list(CAT_AMR, "CMB Jacket", 0, "black"),
		/obj/item/clothing/suit/storage/RO = list(CAT_AMR, "TGMC RO Jacket", 0, "black"),
		/obj/item/clothing/suit/storage/lawyer/bluejacket = list(CAT_AMR, "Blue Jacket", 0, "black"),
		/obj/item/clothing/suit/storage/lawyer/purpjacket = list(CAT_AMR, "Purple Jacket", 0, "black"),
		/obj/item/clothing/suit/storage/snow_suit = list(CAT_AMR, "Snowsuit", 0, "black"),
		/obj/item/clothing/suit/armor/bulletproof = list(CAT_AMR, "Bulletproof Vest", 0, "black"),
		/obj/item/clothing/suit/armor/vest/pilot = list(CAT_AMR, "M70 flak jacket", 0, "black"),
		/obj/item/clothing/suit/chef = list(CAT_AMR, "Chef's apron", 0, "black"),
		/obj/item/clothing/suit/wcoat = list(CAT_AMR, "Waistcoat", 0, "black"),
		/obj/item/clothing/suit/wizrobe/gentlecoat = list(CAT_AMR, "Gentleman's Coat", 0, "black"),
		/obj/item/clothing/suit/bomber = list(CAT_AMR, "Bomber Jacket", 0, "black"),
		/obj/item/clothing/suit/security/navyhos = list(CAT_AMR, "Navy HoS Jacket", 0, "black"),
		/obj/item/clothing/suit/chef/classic = list(CAT_AMR, "Classic Chef vest", 0, "black"),
		/obj/item/clothing/suit/ianshirt = list(CAT_AMR, "Ian Shirt", 0, "black"),
		/obj/item/clothing/suit/suspenders = list(CAT_AMR, "Suspenders", 0, "black"),
		/obj/item/clothing/suit/apron = list(CAT_AMR, "Apron", 0, "black"),
		/obj/item/clothing/suit/apron/overalls = list(CAT_AMR, "Overalls", 0, "black"),
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
		/obj/item/clothing/tie/red = list(CAT_WEB, "Red Tie", 0, "black"),
		/obj/item/clothing/tie/blue = list(CAT_WEB, "Blue Tie", 0, "black"),
		/obj/item/clothing/tie/horrible = list(CAT_WEB, "Horrible Tie", 0, "black"),
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
		/obj/item/clothing/shoes/brown = list(CAT_SHO, "Brown shoes", 0, "black"),
		/obj/item/clothing/shoes/leather = list(CAT_SHO, "Leather Shoes", 0, "black"),
		/obj/item/clothing/shoes/centcom = list(CAT_SHO, "Dress Shoes", 0, "black"),
		/obj/item/clothing/shoes/black = list(CAT_SHO, "Black Shoes", 0, "black"),
		/obj/item/storage/pouch/general/large = list(CAT_POU, "General pouch", 0, "black"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch", 0, "black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch", 0, "black"),
		/obj/item/storage/pouch/electronics/full = list(CAT_POU, "Electronics pouch", 0, "black"),
		/obj/item/storage/pouch/medkit = list(CAT_POU, "Medkit pouch", 0, "black"),
		/obj/item/storage/pouch/autoinjector/full = list(CAT_POU, "Autoinjector pouch", 0, "orange"),
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
		/obj/item/clothing/head/beret = list(CAT_HEL, "Beret", 0, "black"),
		/obj/item/clothing/head/beanie = list(CAT_HEL, "Beanie", 0, "black"),
		/obj/item/clothing/head/beret/marine/logisticsofficer = list(CAT_HEL, "Logistics Officer Cap", 0, "black"),
		/obj/item/clothing/head/beret/jan = list(CAT_HEL, "Purple Beret", 0, "black"),
		/obj/item/clothing/head/tgmccap/ro = list(CAT_HEL, "RO's Cap", 0, "black"),
		/obj/item/clothing/head/bowlerhat = list(CAT_HEL, "Bowler hat", 0, "black"),
		/obj/item/clothing/head/hairflower = list(CAT_HEL, "Hairflower pin", 0, "black"),
		/obj/item/clothing/head/fez = list(CAT_HEL, "Fez", 0, "black"),
		/obj/item/clothing/head/chefhat = list(CAT_HEL, "Chef's hat", 0, "black"),
		/obj/item/clothing/head/beaverhat = list(CAT_HEL, "Beaver hat", 0, "black"),
		/obj/item/clothing/mask/surgical = list(CAT_MAS, "Sterile mask", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
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
	vendor_role = /datum/job/terragov/squad/corpsman
	req_access = list(ACCESS_MARINE_MEDPREP)

	listed_products = list(
		/obj/effect/essentials_set/medic = list(CAT_ESS, "Essential Medic Set", 0, "white"),

		/obj/item/storage/pill_bottle/bicamera = list(CAT_MEDSUP, "BicaMera pills", 30, "orange"),
		/obj/item/storage/pill_bottle/keloderm = list(CAT_MEDSUP, "KeloDerm pills", 30, "orange"),
		/obj/item/storage/pill_bottle/paracetamol = list(CAT_MEDSUP, "Paracetamol pills", 8, "orange"),
		/obj/item/storage/pill_bottle/bicaridine = list(CAT_MEDSUP, "Bicaridine pills", 8, "black"),
		/obj/item/storage/pill_bottle/kelotane = list(CAT_MEDSUP, "Kelotane pills", 8, "black"),
		/obj/item/storage/pill_bottle/tramadol = list(CAT_MEDSUP, "Tramadol pills", 8, "black"),
		/obj/item/storage/pill_bottle/tricordrazine = list(CAT_MEDSUP, "Tricordrazine", 8, "black"),
		/obj/item/storage/syringe_case/meralyne = list(CAT_MEDSUP, "syringe Case (120u Meralyne)", 16, "orange"),
		/obj/item/reagent_containers/hypospray/advanced/meralyne = list(CAT_MEDSUP, "hypospray (60u Meralyne)", 8, "orange"), //half the units of the mera case half the price
		/obj/item/storage/syringe_case/dermaline = list(CAT_MEDSUP, "syringe Case (120u Dermaline)", 16, "orange"),
		/obj/item/reagent_containers/hypospray/advanced/dermaline = list(CAT_MEDSUP, "hypospray (60u dermaline)", 8, "orange"), //half the units of the derm case half the price
		/obj/item/storage/syringe_case/meraderm = list(CAT_MEDSUP, "syringe Case (120u Meraderm)", 16, "orange"),
		/obj/item/reagent_containers/hypospray/advanced/meraderm = list(CAT_MEDSUP, "hypospray (60u Meraderm)", 8, "orange"), //half the units of the meraderm case half the price
		/obj/item/storage/syringe_case/ironsugar = list(CAT_MEDSUP, "syringe Case (120u Ironsugar)", 5, "black"),
		/obj/item/reagent_containers/hypospray/advanced/ironsugar = list(CAT_MEDSUP, "hypospray (60u Ironsugar)", 3, "black"), //bit more than half of the ironsugar case
		/obj/item/storage/syringe_case/tricordrazine = list(CAT_MEDSUP, "syringe Case (120u Tricordrazine)", 5, "black"),
		/obj/item/reagent_containers/hypospray/advanced/tricordrazine = list(CAT_MEDSUP, "hypospray (60u Tricordrazine)", 3, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = list(CAT_MEDSUP, "Injector (Advanced)", 5, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = list(CAT_MEDSUP, "Injector (Oxycodone)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/hypervene = list(CAT_MEDSUP, "Injector (Hypervene)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = list(CAT_MEDSUP, "Injector (QuickclotPlus)", 1, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = list(CAT_MEDSUP, "Injector (Peridaxon Plus)", 1, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = list(CAT_MEDSUP, "Injector (Dexalin Plus)", 1, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = list(CAT_MEDSUP, "Injector (Synaptizine)", 4, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/neuraline = list(CAT_MEDSUP, "Injector (Neuraline)", 14, "orange"),
		/obj/item/reagent_containers/hypospray/advanced = list(CAT_MEDSUP, "Advanced hypospray", 2, "black"),
		/obj/item/reagent_containers/hypospray/advanced/big = list(CAT_MEDSUP, "Big hypospray", 10, "black"),
		/obj/item/clothing/glasses/hud/health = list(CAT_MEDSUP, "Medical HUD glasses", 2, "black"),
		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0, "orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0, "black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0, "orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0, "black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0, "black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0, "black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0, "orange"),
		/obj/item/attachable/stock/t35stock = list(CAT_ATT, "T-35 stock", 0, "black"),
		/obj/item/attachable/stock/t19stock  = list(CAT_ATT, "T-19 machine pistol stock", 0, "black"),
		/obj/item/attachable/gyro = list(CAT_ATT, "gyroscopic stabilizer", 0, "black"),
		/obj/item/attachable/heavy_barrel = list(CAT_ATT, "barrel charger", 0, "black"),
	)



/obj/machinery/marine_selector/gear/engi
	name = "NEXUS Automated Engineer Equipment Rack"
	desc = "An automated engineer equipment rack hooked up to a colossal storage unit."
	icon_state = "engineer"
	vendor_role = /datum/job/terragov/squad/engineer
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
		/obj/item/storage/box/explosive_mines/large = list(CAT_ENGSUP, "Large M20 mine box", 35, "black"),
		/obj/item/storage/pouch/explosive/razorburn = list(CAT_ENGSUP, "Pack of Razorburn grenades", 11, "orange"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_large = list(CAT_ENGSUP, "Razorburn canister", 7, "black"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol = list(CAT_ENGSUP, "Razorburn grenade", 3, "black"),
		/obj/item/multitool = list(CAT_ENGSUP, "Multitool", 1, "black"),
		/obj/item/circuitboard/general = list(CAT_ENGSUP, "General circuit board", 1, "black"),
		/obj/item/assembly/signaler = list(CAT_ENGSUP, "Signaler (for detpacks)", 1, "black"),
		/obj/item/stack/voucher/sentry = list(CAT_ENGSUP, "UA-580 point defense sentry voucher", 26, "black"),

		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0, "orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0, "black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0, "orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0, "black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0, "black"),
		/obj/item/attachable/scope/mini = list(CAT_ATT, "Mini-Scope", 0,"black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0, "black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0, "orange"),
		/obj/item/attachable/stock/t35stock = list(CAT_ATT, "T-35 stock", 0, "black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 machine pistol stock", 0, "black"),
	)



/obj/machinery/marine_selector/gear/smartgun
	name = "NEXUS Automated Smartgunner Equipment Rack"
	desc = "An automated smartgunner equipment rack hooked up to a colossal storage unit."
	icon_state = "smartgunner"
	vendor_role = /datum/job/terragov/squad/smartgunner
	req_access = list(ACCESS_MARINE_SMARTPREP)

	listed_products = list(
		/obj/item/storage/box/t26_system = list(CAT_ESS, "Essential Smartgunner Set", 0, "white"),

		/obj/item/ammo_magazine/standard_smartmachinegun = list(CAT_SPEAMM, "T26 ammo drum", 45, "black"),

		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0, "orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0, "black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0, "orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0, "black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0, "black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0, "black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0, "orange"),
		/obj/item/attachable/stock/t35stock = list(CAT_ATT, "T-35 stock", 0, "black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 machine pistol stock", 0, "black"),
	)


//todo: move this to some sort of kit controller/datum
//the global list of specialist sets that haven't been claimed yet.
GLOBAL_LIST_INIT(available_specialist_sets, list("Scout Set", "Sniper Set", "Demolitionist Set", "Heavy Grenadier Set","Heavy Gunner Set", "Pyro Set"))


/obj/machinery/marine_selector/gear/spec
	name = "NEXUS Automated Specialist Equipment Rack"
	desc = "An automated specialist equipment rack hooked up to a colossal storage unit."
	icon_state = "specialist"
	vendor_role = /datum/job/terragov/squad/specialist
	req_access = list(ACCESS_MARINE_SPECPREP)

	listed_products = list(
		/obj/item/storage/box/spec/scout = list(CAT_ESS, "Scout Set (Battle Rifle)", 0, "white"),
		/obj/item/storage/box/spec/tracker = list(CAT_ESS, "Scout Set (Shotgun)", 0, "white"),
		/obj/item/storage/box/spec/sniper = list(CAT_ESS, "Sniper Set", 0, "white"),
		/obj/item/storage/box/spec/demolitionist = list(CAT_ESS, "Demolitionist Set", 0, "white"),
		/obj/item/storage/box/spec/heavy_grenadier = list(CAT_ESS, "Heavy Grenadier Set", 0, "white"),
		/obj/item/storage/box/spec/heavy_gunner = list(CAT_ESS, "Heavy Gunner Set", 0, "white"),
		/obj/item/storage/box/spec/pyro = list(CAT_ESS, "Pyro Set", 0, "white"),

		/obj/item/ammo_magazine/pistol/vp70 = list(CAT_SPEAMM, "88M4 AP magazine", 15, "black"),

		/obj/item/attachable/suppressor = list(CAT_ATT, "Suppressor", 0, "black"),
		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0, "orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0, "black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0, "orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0, "black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0, "black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0, "black"),
		/obj/item/attachable/scope/mini = list(CAT_ATT, "Mini-Scope", 0,"black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0, "orange"),
		/obj/item/attachable/stock/t35stock = list(CAT_ATT, "T-35 stock", 0, "black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 machine pistol stock", 0, "black"),
	)

/obj/machinery/marine_selector/gear/spec/Initialize()
	. = ..()
	new /obj/effect/decal/cleanable/cobweb(loc)
	for(var/d in GLOB.alldirs)
		var/turf/T = get_step(src, d)
		if(!T.density)
			new /obj/effect/decal/cleanable/cobweb(T)



/obj/machinery/marine_selector/gear/leader
	name = "NEXUS Automated Squad Leader Equipment Rack"
	desc = "An automated squad leader equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	vendor_role = /datum/job/terragov/squad/leader
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
		/obj/item/storage/pouch/explosive/razorburn = list(CAT_LEDSUP, "Pack of Razorburn grenades", 24, "orange"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_large = list(CAT_LEDSUP, "Razorburn canister", 21, "black"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol = list(CAT_LEDSUP, "Razorburn grenade", 6, "black"),
		/obj/item/weapon/gun/flamer = list(CAT_LEDSUP, "Flamethrower", 12, "black"),
		/obj/item/ammo_magazine/flamer_tank = list(CAT_LEDSUP, "Flamethrower tank", 4, "black"),
		/obj/item/whistle = list(CAT_LEDSUP, "Whistle", 5, "black"),
		/obj/item/radio = list(CAT_LEDSUP, "Station bounced radio", 1, "black"),
		/obj/item/assembly/signaler = list(CAT_LEDSUP, "Signaler (for detpacks)", 1, "black"),
		/obj/item/motiondetector = list(CAT_LEDSUP, "Motion detector", 5, "black"),
		/obj/item/storage/firstaid/adv = list(CAT_LEDSUP, "Advanced firstaid kit", 10, "orange"),
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = list(CAT_MEDSUP, "Injector (Synaptizine)", 10, "black"),
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = list(CAT_MEDSUP, "Injector (Advanced)", 15, "orange"),
		/obj/item/storage/box/zipcuffs = list(CAT_LEDSUP, "Ziptie box", 5, "black"),
		/obj/structure/closet/bodybag/tarp = list(CAT_LEDSUP, "V1 thermal-dampening tarp", 5, "black"),
		/obj/item/storage/box/m94/cas = list(CAT_LEDSUP, "CAS flare box", 10, "orange"),
		/obj/item/deployable_camera = list(CAT_LEDSUP, "Deployable Overwatch Camera", 2, "orange"),

		/obj/item/attachable/suppressor = list(CAT_ATT, "Suppressor", 0, "black"),
		/obj/item/attachable/extended_barrel = list(CAT_ATT, "Extended barrel", 0, "orange"),
		/obj/item/attachable/compensator = list(CAT_ATT, "Recoil compensator", 0, "black"),
		/obj/item/attachable/magnetic_harness = list(CAT_ATT, "Magnetic harness", 0, "orange"),
		/obj/item/attachable/reddot = list(CAT_ATT, "Red dot sight", 0, "black"),
		/obj/item/attachable/lasersight = list(CAT_ATT, "Laser sight", 0, "black"),
		/obj/item/attachable/scope/mini = list(CAT_ATT, "Mini-Scope", 0,"black"),
		/obj/item/attachable/verticalgrip = list(CAT_ATT, "Vertical grip", 0, "black"),
		/obj/item/attachable/angledgrip = list(CAT_ATT, "Angled grip", 0, "orange"),
		/obj/item/attachable/stock/t35stock = list(CAT_ATT, "T-35 stock", 0, "black"),
		/obj/item/attachable/stock/t19stock = list(CAT_ATT, "T-19 machine pistol stock", 0, "black"),
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
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/essentials_set/basicmodular
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/suit/modular,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/essentials_set/basic_smartgunner
	spawned_gear_list = list(
		/obj/item/clothing/under/marine,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/essentials_set/basic_smartgunnermodular
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/suit/modular,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/essentials_set/basic_specialist
	spawned_gear_list = list(
		/obj/item/clothing/under/marine,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/essentials_set/basic_squadleader
	spawned_gear_list = list(
		/obj/item/clothing/suit/storage/marine/pasvest,
		/obj/item/clothing/head/helmet/marine/leader,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/under/marine,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/essentials_set/basic_commander
	spawned_gear_list = list(
		/obj/item/clothing/suit/storage/marine/pasvest,
		/obj/item/clothing/head/helmet/marine/leader,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/under/marine,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/essentials_set/basic_squadleadermodular
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/suit/modular,
		/obj/item/clothing/head/helmet/marine/leader,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/essentials_set/basic_medic
	spawned_gear_list = list(
		/obj/item/clothing/head/helmet/marine/corpsman,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/under/marine/corpsman,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/essentials_set/basic_medicmodular
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/suit/modular,
		/obj/item/clothing/head/helmet/marine/corpsman,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/essentials_set/basic_engineer
	spawned_gear_list = list(
		/obj/item/clothing/head/helmet/marine/tech,
		/obj/item/clothing/glasses/welding,
		/obj/item/clothing/under/marine/engineer,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
		/obj/item/clothing/gloves/marine/insulated,
	)

/obj/effect/essentials_set/basic_engineermodular
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/suit/modular,
		/obj/item/clothing/head/helmet/marine/tech,
		/obj/item/clothing/glasses/welding,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
		/obj/item/clothing/gloves/marine/insulated,
		/obj/item/facepaint/green,
	)

/obj/effect/essentials_set/medic
	spawned_gear_list = list(
		/obj/item/bodybag/cryobag,
		/obj/item/defibrillator,
		/obj/item/healthanalyzer,
		/obj/item/roller/medevac,
		/obj/item/medevac_beacon,
		/obj/item/roller,
		/obj/item/tweezers,
		/obj/item/reagent_containers/hypospray/advanced/oxycodone,
		/obj/item/storage/firstaid/adv,
	)

/obj/effect/essentials_set/engi
	spawned_gear_list = list(
		/obj/item/explosive/plastique,
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol,
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
		/obj/item/binoculars/tactical,
	)

/obj/effect/essentials_set/commander
	spawned_gear_list = list(
		/obj/item/squad_beacon,
		/obj/item/squad_beacon/bomb,
		/obj/item/healthanalyzer,
		/obj/item/roller/medevac,
		/obj/item/medevac_beacon,
		/obj/item/whistle,
		/obj/item/radio,
		/obj/item/motiondetector,
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
		/obj/item/reagent_containers/hypospray/advanced/oxycodone,
	)

/obj/effect/essentials_set/modular/infantry
	desc = "A set of medium Infantry pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine,
		/obj/item/armor_module/armor/chest/marine,
		/obj/item/armor_module/armor/arms/marine,
		/obj/item/armor_module/armor/legs/marine,
	)

/obj/effect/essentials_set/modular/eva
	desc = "A set of medium EVA pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/eva,
		/obj/item/clothing/head/modular/marine/eva/skull,
		/obj/item/armor_module/armor/chest/marine/eva,
		/obj/item/armor_module/armor/arms/marine/eva,
		/obj/item/armor_module/armor/legs/marine/eva,
	)

/obj/effect/essentials_set/modular/skirmisher
	desc = "A set of light Skirmisher pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/skirmisher,
		/obj/item/armor_module/armor/chest/marine/skirmisher,
		/obj/item/armor_module/armor/arms/marine/skirmisher,
		/obj/item/armor_module/armor/legs/marine/skirmisher,
	)

/obj/effect/essentials_set/modular/scout
	desc = "A set of light Scout pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/scout,
		/obj/item/armor_module/armor/chest/marine/skirmisher/scout,
		/obj/item/armor_module/armor/arms/marine/scout,
		/obj/item/armor_module/armor/legs/marine/scout,
	)

/obj/effect/essentials_set/modular/assault
	desc = "A set of heavy Assault pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/assault,
		/obj/item/armor_module/armor/chest/marine/assault,
		/obj/item/armor_module/armor/arms/marine/assault,
		/obj/item/armor_module/armor/legs/marine/assault,
	)

/obj/effect/essentials_set/modular/eod
	desc = "A set of heavy EOD pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/eod,
		/obj/item/armor_module/armor/chest/marine/assault/eod,
		/obj/item/armor_module/armor/arms/marine/eod,
		/obj/item/armor_module/armor/legs/marine/eod,
	)

/obj/effect/essentials_set/mimir
	desc = "A set of anti-gas gear setup to protect one from gas threats."
	spawned_gear_list = list(
		/obj/item/helmet_module/attachable/mimir_environment_protection/mark1,
		/obj/item/clothing/mask/gas/tactical,
		/obj/item/armor_module/attachable/mimir_environment_protection/mark1,
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

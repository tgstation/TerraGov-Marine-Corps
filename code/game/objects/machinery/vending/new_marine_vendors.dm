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
	///The faction of that vendor, can be null
	var/faction

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
	var/obj/item/card/id/ID = user.get_idcard()
	.["total_marine_points"] = ID ? initial(ID.marine_points) : 0


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

			var/obj/item/vended_item

			if(faction && ispath(idx, /obj/effect/modular_set))
				vended_item = new idx(loc, faction)
			else
				vended_item = new idx(loc)

			if(istype(vended_item)) // in case of spawning /obj
				usr.put_in_any_hand_if_possible(vended_item, warning = FALSE)

			if(icon_vend)
				flick(icon_vend, src)

			use_power(active_power_usage)

			if(bitf == MARINE_CAN_BUY_UNIFORM && ishumanbasic(usr))
				var/mob/living/carbon/human/H = usr
				var/headset_type = H.faction == FACTION_TERRAGOV ? /obj/item/radio/headset/mainship/marine : /obj/item/radio/headset/mainship/marine/rebel
				new headset_type(loc, H.assigned_squad, vendor_role)
				if(!istype(H.job, /datum/job/terragov/squad/engineer))
					new /obj/item/clothing/gloves/marine(loc, H.assigned_squad, vendor_role)
				if(istype(H.job, /datum/job/terragov/squad/leader))
					new /obj/item/hud_tablet(loc, vendor_role, H.assigned_squad)
				if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
					new /obj/item/clothing/mask/rebreather/scarf(loc)

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
		CAT_ATT = list(MARINE_CAN_BUY_ATTACHMENT,MARINE_CAN_BUY_ATTACHMENT2),
		CAT_MOD = list(MARINE_CAN_BUY_MODULE),
		CAT_ARMMOD = list(MARINE_CAN_BUY_ARMORMOD),
		CAT_MAS = list(MARINE_CAN_BUY_MASK),
	)

/obj/machinery/marine_selector/clothes/Initialize()
	. = ..()
	listed_products = GLOB.marine_clothes_listed_products

/obj/machinery/marine_selector/clothes/loyalist
	faction = FACTION_TERRAGOV

/obj/machinery/marine_selector/clothes/rebel
	faction = FACTION_TERRAGOV_REBEL

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

/obj/machinery/marine_selector/clothes/engi/Initialize()
	. = ..()
	listed_products = GLOB.engineer_clothes_listed_products

/obj/machinery/marine_selector/clothes/engi/loyalist
	faction = FACTION_TERRAGOV

/obj/machinery/marine_selector/clothes/engi/rebel
	req_access = list(ACCESS_MARINE_ENGPREP_REBEL)
	vendor_role = /datum/job/terragov/squad/engineer/rebel
	faction = FACTION_TERRAGOV_REBEL

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


/obj/machinery/marine_selector/clothes/medic/Initialize()
	. = ..()
	listed_products = GLOB.medic_clothes_listed_products

/obj/machinery/marine_selector/clothes/medic/loyalist
	faction = FACTION_TERRAGOV

/obj/machinery/marine_selector/clothes/medic/rebel
	req_access = list(ACCESS_MARINE_MEDPREP_REBEL)
	vendor_role = /datum/job/terragov/squad/corpsman/rebel
	faction = FACTION_TERRAGOV_REBEL

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

/obj/machinery/marine_selector/clothes/smartgun/Initialize()
	. = ..()
	listed_products = GLOB.smartgunner_clothes_listed_products

/obj/machinery/marine_selector/clothes/smartgun/loyalist
	faction = FACTION_TERRAGOV

/obj/machinery/marine_selector/clothes/smartgun/rebel
	req_access = list(ACCESS_MARINE_SMARTPREP_REBEL)
	vendor_role = /datum/job/terragov/squad/smartgunner/rebel
	faction = FACTION_TERRAGOV_REBEL


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

/obj/machinery/marine_selector/clothes/leader
	name = "GHMME Automated Leader Closet"
	req_access = list(ACCESS_MARINE_LEADER)
	vendor_role = /datum/job/terragov/squad/leader
	gives_webbing = FALSE

/obj/machinery/marine_selector/clothes/leader/Initialize()
	. = ..()
	listed_products = GLOB.leader_clothes_listed_products

/obj/machinery/marine_selector/clothes/leader/loyalist
	faction = FACTION_TERRAGOV

/obj/machinery/marine_selector/clothes/leader/rebel
	req_access = list(ACCESS_MARINE_LEADER_REBEL)
	vendor_role = /datum/job/terragov/squad/leader/rebel
	faction = FACTION_TERRAGOV_REBEL


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

/obj/machinery/marine_selector/clothes/commander/Initialize()
	. = ..()
	listed_products = list(
		/obj/effect/essentials_set/commander = list(CAT_STD, "Standard Commander kit ", 0, "white"),
		/obj/effect/modular_set/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "black"),
		/obj/effect/modular_set/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "black"),
		/obj/effect/modular_set/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "black"),
		/obj/effect/modular_set/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "black"),
		/obj/effect/modular_set/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "black"),
		/obj/item/clothing/suit/storage/marine/pasvest = list(CAT_AMR, "Regular armor", 0, "orange"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "black"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/large_holster/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/clothing/tie/storage/black_vest = list(CAT_WEB, "Tactical black vest", 0, "black"),
		/obj/item/clothing/tie/storage/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/clothing/tie/storage/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
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
		/obj/item/clothing/head/headband/red = list(CAT_HEL, "FC Headband", 0, "black"),
		/obj/item/clothing/head/tgmcberet/fc = list(CAT_HEL, "FC Beret", 0, "black"),
		/obj/item/clothing/head/helmet/marine/leader = list(CAT_HEL, "FC Helmet", 0, "black"),
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
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/attachable/ballistic_armor = list(CAT_ARMMOD, "Ballistic armor module", 0,"black"),
		/obj/item/armor_module/attachable/tyr_extra_armor/mark1 = list(CAT_ARMMOD, "Mark 1 Tyr extra armor module", 0,"black"),
		/obj/item/armor_module/attachable/better_shoulder_lamp/mark1 = list(CAT_ARMMOD, "Mark 1 Baldur light armor module", 0,"black"),
		/obj/effect/essentials_set/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
	)

/obj/machinery/marine_selector/clothes/commander/loyalist
	faction = FACTION_TERRAGOV

/obj/machinery/marine_selector/clothes/commander/rebel
	req_access = list(ACCESS_MARINE_COMMANDER_REBEL)
	vendor_role = /datum/job/terragov/command/fieldcommander/rebel
	faction = FACTION_TERRAGOV_REBEL

/obj/machinery/marine_selector/clothes/synth
	name = "M57 Synthetic Equipment Vendor"
	desc = "An automated synthetic equipment vendor hooked up to a modest storage unit."
	icon_state = "synth"
	icon_vend = "synth-vend"
	icon_deny = "synth-deny"
	vendor_role = /datum/job/terragov/silicon/synthetic
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/clothes/synth/Initialize()
	. = ..()
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
		/obj/item/clothing/tie/storage/white_vest/surgery = list(CAT_WEB, "White surgical vest", 0, "black"),
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

/obj/machinery/marine_selector/gear/medic/Initialize()
	. = ..()
	listed_products = GLOB.medic_gear_listed_products

/obj/machinery/marine_selector/gear/medic/rebel
	req_access = list(ACCESS_MARINE_MEDPREP_REBEL)

/obj/machinery/marine_selector/gear/engi
	name = "NEXUS Automated Engineer Equipment Rack"
	desc = "An automated engineer equipment rack hooked up to a colossal storage unit."
	icon_state = "engineer"
	vendor_role = /datum/job/terragov/squad/engineer
	req_access = list(ACCESS_MARINE_ENGPREP)

/obj/machinery/marine_selector/gear/engi/Initialize()
	. = ..()
	listed_products = GLOB.engineer_gear_listed_products

/obj/machinery/marine_selector/gear/engi/rebel
	req_access = list(ACCESS_MARINE_ENGPREP_REBEL)


/obj/machinery/marine_selector/gear/smartgun
	name = "NEXUS Automated Smartgunner Equipment Rack"
	desc = "An automated smartgunner equipment rack hooked up to a colossal storage unit."
	icon_state = "smartgunner"
	vendor_role = /datum/job/terragov/squad/smartgunner
	req_access = list(ACCESS_MARINE_SMARTPREP)

	listed_products = list(
		/obj/item/storage/box/t26_system = list(CAT_ESS, "T-26 Smartmachinegun Set", 0, "white"),
		/obj/item/storage/box/t25_system = list(CAT_ESS, "T-25 Smartrifle Set", 0, "white"),


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

/obj/machinery/marine_selector/gear/smartgun/rebel
	req_access = list(ACCESS_MARINE_SMARTPREP_REBEL)

/obj/machinery/marine_selector/gear/leader
	name = "NEXUS Automated Squad Leader Equipment Rack"
	desc = "An automated squad leader equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	vendor_role = /datum/job/terragov/squad/leader
	req_access = list(ACCESS_MARINE_LEADER)

/obj/machinery/marine_selector/gear/leader/Initialize()
	. = ..()
	listed_products = GLOB.leader_gear_listed_products

/obj/machinery/marine_selector/gear/leader/rebel
	req_access = list(ACCESS_MARINE_LEADER_REBEL)


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

/obj/effect/essentials_set/basic_squadleader
	spawned_gear_list = list(
		/obj/item/clothing/under/marine,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/essentials_set/basic_squadleadermodular
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/suit/modular,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/essentials_set/basic_medic
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/corpsman,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/essentials_set/basic_medicmodular
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/suit/modular,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/essentials_set/basic_engineer
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/engineer,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/essentials_set/basic_engineermodular
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/suit/modular,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
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
		/obj/item/clothing/glasses/hud/health,
	)

/obj/effect/essentials_set/engi
	spawned_gear_list = list(
		/obj/item/explosive/plastique,
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol,
		/obj/item/clothing/glasses/welding,
		/obj/item/clothing/gloves/marine/insulated,
		/obj/item/cell/high,
		/obj/item/tool/shovel/etool,
		/obj/item/lightreplacer,
		/obj/item/circuitboard/general,
	)

/obj/effect/essentials_set/leader
	spawned_gear_list = list(
		/obj/item/explosive/plastique,
		/obj/item/beacon/supply_beacon,
		/obj/item/beacon/supply_beacon,
		/obj/item/beacon/orbital_bombardment_beacon,
		/obj/item/whistle,
		/obj/item/radio,
		/obj/item/motiondetector,
		/obj/item/binoculars/tactical,
		/obj/item/pinpointer/pool,
		/obj/item/clothing/glasses/hud/health,
	)

/obj/effect/essentials_set/commander
	spawned_gear_list = list(
		/obj/item/beacon/supply_beacon,
		/obj/item/beacon/orbital_bombardment_beacon,
		/obj/item/healthanalyzer,
		/obj/item/roller/medevac,
		/obj/item/medevac_beacon,
		/obj/item/whistle,
		/obj/item/motiondetector,
		/obj/item/clothing/suit/modular,
		/obj/item/facepaint/green,
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
		/obj/item/tweezers,
	)

/obj/effect/modular_set
	///List of all gear to spawn
	var/list/spawned_gear_list = list()

/obj/effect/modular_set/Initialize(mapload, faction)
	. = ..()
	for(var/typepath in spawned_gear_list)
		var/item = new typepath(loc)
		if(!faction)
			continue
		if(ismodulararmorarmorpiece(item))
			var/obj/item/armor_module/armor/armorpiece = item
			armorpiece.limit_colorable_colors(faction)
			continue
		if(ismodularhelmet(item))
			var/obj/item/clothing/head/modular/helmet = item
			helmet.limit_colorable_colors(faction)
	qdel(src)


/obj/effect/modular_set/infantry
	desc = "A set of medium Infantry pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine,
		/obj/item/clothing/head/modular/marine/infantry,
		/obj/item/armor_module/armor/chest/marine,
		/obj/item/armor_module/armor/arms/marine,
		/obj/item/armor_module/armor/legs/marine,
	)

/obj/effect/modular_set/eva
	desc = "A set of medium EVA pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/eva,
		/obj/item/clothing/head/modular/marine/eva/skull,
		/obj/item/armor_module/armor/chest/marine/eva,
		/obj/item/armor_module/armor/arms/marine/eva,
		/obj/item/armor_module/armor/legs/marine/eva,
	)

/obj/effect/modular_set/skirmisher
	desc = "A set of light Skirmisher pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/skirmisher,
		/obj/item/armor_module/armor/chest/marine/skirmisher,
		/obj/item/armor_module/armor/arms/marine/skirmisher,
		/obj/item/armor_module/armor/legs/marine/skirmisher,
	)

/obj/effect/modular_set/scout
	desc = "A set of light Scout pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/scout,
		/obj/item/armor_module/armor/chest/marine/skirmisher/scout,
		/obj/item/armor_module/armor/arms/marine/scout,
		/obj/item/armor_module/armor/legs/marine/scout,
	)

/obj/effect/modular_set/assault
	desc = "A set of heavy Assault pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/assault,
		/obj/item/armor_module/armor/chest/marine/assault,
		/obj/item/armor_module/armor/arms/marine/assault,
		/obj/item/armor_module/armor/legs/marine/assault,
	)

/obj/effect/modular_set/eod
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

/obj/effect/essentials_set/vali
	desc = "A set of specialized gear for close-quarters combat and enhanced chemical effectiveness."
	spawned_gear_list = list(
		/obj/item/armor_module/attachable/chemsystem,
		/obj/item/storage/large_holster/machete/full_harvester,
		/obj/item/paper/chemsystem,
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

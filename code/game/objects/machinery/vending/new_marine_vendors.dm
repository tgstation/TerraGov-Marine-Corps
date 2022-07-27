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
			to_chat(user, span_warning("Access denied. Your assigned role doesn't have access to this machinery."))
			return FALSE

		var/obj/item/card/id/I = H.get_idcard()
		if(!istype(I)) //not wearing an ID
			return FALSE

		if(I.registered_name != H.real_name)
			return FALSE

		if(lock_flags & JOB_LOCK && vendor_role && !istype(H.job, vendor_role))
			to_chat(user, span_warning("Access denied. This vendor is heavily restricted."))
			return FALSE

		if(lock_flags & SQUAD_LOCK && (!H.assigned_squad || (squad_tag && H.assigned_squad.name != squad_tag)))
			to_chat(user, span_warning("Access denied. Your assigned squad isn't allowed to access this machinery."))
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
	var/buy_choices = I?.marine_buy_choices
	var/obj/item/card/id/dogtag/full/ptscheck = new /obj/item/card/id/dogtag/full

	.["cats"] = list()
	for(var/cat in GLOB.marine_selector_cats)
		.["cats"][cat] = list(
			"remaining" = buy_choices[cat],
			"total" = GLOB.marine_selector_cats[cat],
			"choice" = "choice",
			)

	for(var/cat in I?.marine_points)
		.["cats"][cat] = list(
			"remaining_points" = I?.marine_points[cat],
			"total_points" = ptscheck?.marine_points[cat],
			"choice" = "points",
			)

/obj/machinery/marine_selector/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("vend")
			if(!allowed(usr))
				to_chat(usr, span_warning("Access denied."))
				if(icon_deny)
					flick(icon_deny, src)
				return

			var/idx = text2path(params["vend"])
			var/obj/item/card/id/I = usr.get_idcard()

			var/list/L = listed_products[idx]
			var/item_category = L[1]
			var/cost = L[3]

			if(SSticker.mode?.flags_round_type & MODE_HUMAN_ONLY && is_type_in_typecache(idx, GLOB.hvh_restricted_items_list))
				to_chat(usr, span_warning("This item is banned by the Space Geneva Convention."))
				if(icon_deny)
					flick(icon_deny, src)
				return

			if(use_points && (item_category in I.marine_points) && I.marine_points[item_category] < cost)
				to_chat(usr, span_warning("Not enough points."))
				if(icon_deny)
					flick(icon_deny, src)
				return

			var/turf/T = loc
			if(length(T.contents) > 25)
				to_chat(usr, span_warning("The floor is too cluttered, make some space."))
				if(icon_deny)
					flick(icon_deny, src)
				return

			if(item_category in I.marine_buy_choices)
				if(I.marine_buy_choices[item_category] && GLOB.marine_selector_cats[item_category])
					I.marine_buy_choices[item_category] -= 1
				else
					if(cost == 0)
						to_chat(usr, span_warning("You can't buy things from this category anymore."))
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

			if(item_category == CAT_STD && !issynth(usr))
				var/mob/living/carbon/human/H = usr
				if(!istype(H.job, /datum/job/terragov/command/fieldcommander))
					var/headset_type = H.faction == FACTION_TERRAGOV ? /obj/item/radio/headset/mainship/marine : /obj/item/radio/headset/mainship/marine/rebel
					new headset_type(loc, H.assigned_squad, vendor_role)
					if(!istype(H.job, /datum/job/terragov/squad/engineer))
						new /obj/item/clothing/gloves/marine(loc, H.assigned_squad, vendor_role)
					if(istype(H.job, /datum/job/terragov/squad/leader))
						new /obj/item/hud_tablet(loc, vendor_role, H.assigned_squad)

			if(use_points && (item_category in I.marine_points))
				I.marine_points[item_category] -= cost
			. = TRUE

	updateUsrDialog()

/obj/machinery/marine_selector/clothes
	name = "GHMME Automated Closet"
	desc = "An automated closet hooked up to a colossal storage unit of standard-issue uniform and armor."
	icon_state = "marineuniform"
	vendor_role = /datum/job/terragov/squad/standard
	use_points = TRUE
	categories = list(
		CAT_STD = 1,
		CAT_GLA = 1,
		CAT_HEL = 1,
		CAT_AMR = 1,
		CAT_BAK = 1,
		CAT_WEB = 1,
		CAT_BEL = 1,
		CAT_POU = 2,
		CAT_MOD = 1,
		CAT_ARMMOD = 1,
		CAT_MAS = 1,
	)

/obj/machinery/marine_selector/clothes/Initialize()
	. = ..()
	listed_products = GLOB.marine_clothes_listed_products + GLOB.marine_gear_listed_products

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

/obj/machinery/marine_selector/clothes/engi/valhalla
	vendor_role = /datum/job/fallen/engineer
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

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

/obj/machinery/marine_selector/clothes/medic/valhalla
	vendor_role = /datum/job/fallen/corpsman
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

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

/obj/machinery/marine_selector/clothes/smartgun/valhalla
	vendor_role = /datum/job/fallen/smartgunner
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

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

/obj/machinery/marine_selector/clothes/leader/valhalla
	vendor_role = /datum/job/fallen/leader
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

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
		/obj/effect/essentials_set/jaeger_commander = list(CAT_STD, "Jaeger Commander kit ", 0, "white"),
		/obj/effect/modular_set/skirmisher = list(CAT_AMR, "Light Skirmisher Jaeger kit", 0, "black"),
		/obj/effect/modular_set/scout = list(CAT_AMR, "Light Scout Jaeger kit", 0, "orange"),
		/obj/effect/modular_set/infantry = list(CAT_AMR, "Medium Infantry Jaeger kit", 0, "black"),
		/obj/effect/modular_set/eva = list(CAT_AMR, "Medium EVA Jaeger kit", 0, "black"),
		/obj/effect/modular_set/helljumper = list(CAT_AMR, "Medium Helljumper Jaeger kit", 0, "black"),
		/obj/effect/modular_set/assault = list(CAT_AMR, "Heavy Assault Jaeger kit", 0, "black"),
		/obj/effect/modular_set/eod = list(CAT_AMR, "Heavy EOD Jaeger kit", 0, "black"),
		/obj/effect/essentials_set/xenonauten_light/leader = list(CAT_AMR, "Xenonauten light armor kit", 0, "orange"),
		/obj/effect/essentials_set/xenonauten_medium/leader = list(CAT_AMR, "Xenonauten medium armor kit", 0, "orange"),
		/obj/effect/essentials_set/xenonauten_heavy/leader = list(CAT_AMR, "Xenonauten heavy armor kit", 0, "orange"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "black"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/holster/blade/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/armor_module/storage/uniform/black_vest = list(CAT_WEB, "Tactical black vest", 0, "black"),
		/obj/item/armor_module/storage/uniform/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/armor_module/storage/uniform/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/gun/pistol/m4a3/fieldcommander = list(CAT_BEL, "1911-custom belt", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/belt/gun/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/belt/gun/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt Harness", 0, "black"),
		/obj/item/armor_module/module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/armor_module/module/binoculars =  list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/armor_module/module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/tgmcberet/fc = list(CAT_HEL, "FC Beret", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/injector = list(CAT_MOD, "Injector Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/general/large = list(CAT_POU, "General pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/pouch/flare/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/medical_injectors/firstaid = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/medkit/firstaid = list(CAT_POU, "Firstaid pouch", 0, "orange"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch (tools included)", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch (materials included)", 0, "black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/effect/essentials_set/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
		/obj/item/armor_module/module/ballistic_armor = list(CAT_ARMMOD, "Hod Accident Prevention Plating", 0,"black"),
		/obj/effect/essentials_set/tyr = list(CAT_ARMMOD, "Mark 1 Tyr extra armor set", 0,"black"),
		/obj/item/armor_module/module/better_shoulder_lamp = list(CAT_ARMMOD, "Baldur light armor module", 0,"black"),
		/obj/effect/essentials_set/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/armor_module/module/eshield = list(CAT_ARMMOD, "Arrowhead Energy Shield System", 0 , "black"),
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
	listed_products = GLOB.synthetic_clothes_listed_products

////////////////////// Gear ////////////////////////////////////////////////////////



/obj/machinery/marine_selector/gear
	name = "NEXUS Automated Equipment Rack"
	desc = "An automated equipment rack hooked up to a colossal storage unit."
	icon_state = "marinearmory"
	use_points = TRUE

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

/obj/machinery/marine_selector/gear/medic/valhalla
	vendor_role = /datum/job/fallen/corpsman
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

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

/obj/machinery/marine_selector/gear/engi/valhalla
	vendor_role = /datum/job/fallen/engineer
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/gear/smartgun
	name = "NEXUS Automated Smartgunner Equipment Rack"
	desc = "An automated smartgunner equipment rack hooked up to a colossal storage unit."
	icon_state = "smartgunner"
	vendor_role = /datum/job/terragov/squad/smartgunner
	req_access = list(ACCESS_MARINE_SMARTPREP)

/obj/machinery/marine_selector/gear/smartgun/Initialize()
	. = ..()
	listed_products = GLOB.smartgunner_gear_listed_products

/obj/machinery/marine_selector/gear/smartgun/rebel
	req_access = list(ACCESS_MARINE_SMARTPREP_REBEL)

/obj/machinery/marine_selector/gear/smartgun/valhalla
	vendor_role = /datum/job/fallen/smartgunner
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

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

/obj/machinery/marine_selector/gear/leader/valhalla
	vendor_role = /datum/job/fallen/leader
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK


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

/obj/effect/essentials_set/basic_jaeger
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

/obj/effect/essentials_set/basic_jaeger_smartgunner
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

/obj/effect/essentials_set/basic_jaeger_squadleader
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

/obj/effect/essentials_set/basic_jaeger_medic
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

/obj/effect/essentials_set/basic_jaeger_engineer
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
		/obj/item/clothing/gloves/marine/insulated,
		/obj/item/cell/high,
		/obj/item/lightreplacer,
		/obj/item/circuitboard/apc,
		/obj/item/tool/surgery/solderingtool,
	)

/obj/effect/essentials_set/leader
	spawned_gear_list = list(
		/obj/item/explosive/plastique,
		/obj/item/beacon/supply_beacon,
		/obj/item/beacon/supply_beacon,
		/obj/item/whistle,
		/obj/item/compass,
		/obj/item/binoculars/tactical,
		/obj/item/pinpointer,
		/obj/item/clothing/glasses/hud/health,
	)

/obj/effect/essentials_set/commander
	spawned_gear_list = list(
		/obj/item/beacon/supply_beacon,
		/obj/item/healthanalyzer,
		/obj/item/roller/medevac,
		/obj/item/medevac_beacon,
		/obj/item/whistle,
		/obj/item/storage/box/MRE,
	)

/obj/effect/essentials_set/jaeger_commander
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/suit/modular,
		/obj/item/beacon/supply_beacon,
		/obj/item/healthanalyzer,
		/obj/item/roller/medevac,
		/obj/item/medevac_beacon,
		/obj/item/whistle,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/essentials_set/synth
	spawned_gear_list = list(
		/obj/item/stack/sheet/plasteel/medium_stack,
		/obj/item/stack/sheet/metal/large_stack,
		/obj/item/tool/weldingtool/hugetank,
		/obj/item/lightreplacer,
		/obj/item/healthanalyzer,
		/obj/item/tool/handheld_charger,
		/obj/item/defibrillator,
		/obj/item/medevac_beacon,
		/obj/item/roller/medevac,
		/obj/item/bodybag/cryobag,
		/obj/item/reagent_containers/hypospray/advanced/oxycodone,
		/obj/item/tweezers,
		/obj/item/tool/surgery/solderingtool,
	)

/obj/effect/essentials_set/white_dress
	name = "Full set of TGMC white dress uniform"
	desc = "A standard-issue TerraGov Marine Corps white dress uniform. The starch in the fabric chafes a small amount but it pales in comparison to the pride you feel when you first put it on during graduation from boot camp. Doesn't seem to fit perfectly around the waist though."
	spawned_gear_list = list(
		/obj/item/clothing/under/whites,
		/obj/item/clothing/suit/white_dress_jacket,
		/obj/item/clothing/head/white_dress,
		/obj/item/clothing/shoes/white,
		/obj/item/clothing/gloves/white,
	)

/obj/effect/essentials_set/service_uniform
	name = "Full set of TGMC service uniform"
	desc = "A standard-issue TerraGov Marine Corps dress uniform. Sometimes, you hate wearing this since you remember wearing this to Infantry School and have to wear this when meeting a commissioned officer. This is what you wear when you are not deployed and are working in an office. Doesn't seem to fit perfectly around the waist."
	spawned_gear_list = list(
		/obj/item/clothing/under/service,
		/obj/item/clothing/head/garrisoncap,
		/obj/item/clothing/head/servicecap,
		/obj/item/clothing/shoes/marine/full,
	)


/obj/effect/essentials_set/xenonauten_light
	desc = "A set of light Xenonauten pattern armor, including an armor suit and helmet."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/m10x,
		/obj/item/clothing/suit/modular/xenonauten/light,
	)

/obj/effect/essentials_set/xenonauten_medium
	desc = "A set of medium Xenonauten pattern armor, including an armor suit and helmet."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/m10x,
		/obj/item/clothing/suit/modular/xenonauten,
	)

/obj/effect/essentials_set/xenonauten_heavy
	desc = "A set of heavy Xenonauten pattern armor, including an armor suit and helmet."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/m10x,
		/obj/item/clothing/suit/modular/xenonauten/heavy,
	)

/obj/effect/essentials_set/xenonauten_light/leader
	desc = "A set of light Xenonauten pattern armor, including an armor suit and a fancier helmet."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/m10x/leader,
		/obj/item/clothing/suit/modular/xenonauten/light,
	)

/obj/effect/essentials_set/xenonauten_medium/leader
	desc = "A set of medium Xenonauten pattern armor, including an armor suit and a fancier helmet."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/m10x/leader,
		/obj/item/clothing/suit/modular/xenonauten,
	)

/obj/effect/essentials_set/xenonauten_heavy/leader
	desc = "A set of heavy Xenonauten pattern armor, including an armor suit and a fancier helmet."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/m10x/leader,
		/obj/item/clothing/suit/modular/xenonauten/heavy,
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

/obj/effect/modular_set/helljumper
	desc = "A set of Helljumper pattern Jaeger armor, including an exoskeleton, helmet, and armor plates."
	spawned_gear_list = list(
		/obj/item/clothing/head/modular/marine/helljumper,
		/obj/item/armor_module/armor/chest/marine/helljumper,
		/obj/item/armor_module/armor/arms/marine/helljumper,
		/obj/item/armor_module/armor/legs/marine/helljumper,
	)

/obj/effect/essentials_set/mimir
	desc = "A set of anti-gas gear setup to protect one from gas threats."
	spawned_gear_list = list(
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/clothing/mask/gas/tactical,
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
	)

/obj/effect/essentials_set/vali
	desc = "A set of specialized gear for close-quarters combat and enhanced chemical effectiveness."
	spawned_gear_list = list(
		/obj/item/armor_module/module/chemsystem,
		/obj/item/storage/holster/blade/machete/full_harvester,
		/obj/item/paper/chemsystem,
	)

/obj/effect/essentials_set/tyr
	desc = "A set of specialized gear for improved close-quarters combat longevitiy."
	spawned_gear_list = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
	)

/obj/effect/essentials_set/robot
	spawned_gear_list = list(
		/obj/item/clothing/under/marine/robotic,
		/obj/item/tool/weldingtool,
		/obj/item/stack/cable_coil/twentyfive,
	)

#undef DEFAULT_TOTAL_BUY_POINTS
#undef MEDIC_TOTAL_BUY_POINTS
#undef ENGINEER_TOTAL_BUY_POINTS
#undef SQUAD_LOCK
#undef JOB_LOCK

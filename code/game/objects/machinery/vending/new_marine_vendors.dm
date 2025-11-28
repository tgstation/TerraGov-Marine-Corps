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
	light_range = 1.5
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE

	var/gives_webbing = FALSE
	var/vendor_role //to be compared with job.type to only allow those to use that machine.
	var/squad_tag = ""
	var/use_points = FALSE
	var/lock_flags = SQUAD_LOCK|JOB_LOCK

	var/icon_vend
	var/icon_deny

	var/list/categories
	var/list/listed_products

/obj/machinery/marine_selector/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/marine_selector/update_icon()
	. = ..()
	if(is_operational())
		set_light(initial(light_range))
	else
		set_light(0)

/obj/machinery/marine_selector/update_icon_state()
	. = ..()
	if(is_operational())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/marine_selector/update_overlays()
	. = ..()
	if(!is_operational() || !icon_state)
		return
	. += emissive_appearance(icon, "[icon_state]_emissive", src)

/obj/machinery/marine_selector/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!allowed(H))
			to_chat(user, span_warning("Access denied. Your assigned role doesn't have access to this machinery."))
			return FALSE

		var/obj/item/card/id/user_id = H.get_idcard()
		if(!istype(user_id)) //not wearing an ID
			return FALSE

		if(user_id.registered_name != H.real_name)
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
	var/list/buy_choices = I?.marine_buy_choices
	var/obj/item/card/id/dogtag/full/ptscheck = new /obj/item/card/id/dogtag/full

	.["cats"] = list()
	for(var/cat in GLOB.marine_selector_cats)
		if(!length(buy_choices))
			break
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

	var/ui_theme
	switch(faction)
		if(FACTION_SOM)
			ui_theme = "som"
		if(FACTION_VSD)
			ui_theme = "syndicate"
		if(FACTION_CLF)
			ui_theme = "xeno"
		else
			ui_theme = "ntos"

	.["ui_theme"] = ui_theme

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
			var/obj/item/card/id/user_id = usr.get_idcard()

			var/list/L = listed_products[idx]
			var/item_category = L[1]
			var/cost = L[3]

			if(!(user_id.id_flags & CAN_BUY_LOADOUT)) //If you use the quick-e-quip, you cannot also use the GHMMEs
				to_chat(usr, span_warning("Access denied. You have already vended a loadout."))
				return FALSE
			if(use_points && (item_category in user_id.marine_points) && user_id.marine_points[item_category] < cost)
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

			if(item_category in user_id.marine_buy_choices)
				if(user_id.marine_buy_choices[item_category] && GLOB.marine_selector_cats[item_category])
					user_id.marine_buy_choices[item_category] -= 1
				else
					if(cost == 0)
						to_chat(usr, span_warning("You can't buy things from this category anymore."))
						return

			var/list/vended_items = list()

			if (ispath(idx, /obj/effect/vendor_bundle))
				var/obj/effect/vendor_bundle/bundle = new idx(loc, FALSE)
				vended_items += bundle.spawned_gear
				qdel(bundle)
			else
				vended_items += new idx(loc)

			playsound(src, SFX_VENDING, 25, 0)

			if(icon_vend)
				flick(icon_vend, src)

			use_power(active_power_usage)

			if(item_category == CAT_STD && !issynth(usr))
				var/mob/living/carbon/human/H = usr
				if(!istype(H.job, /datum/job/terragov/command/fieldcommander))
					give_free_headset(usr, faction)
				if(istype(H.job, /datum/job/terragov/squad/leader))
					vended_items += new /obj/item/hud_tablet(loc, vendor_role, H.assigned_squad)
					vended_items += new /obj/item/squad_transfer_tablet(loc)

			for (var/obj/item/vended_item in vended_items)
				vended_item.on_vend(usr, faction, auto_equip = TRUE)

			if(use_points && (item_category in user_id.marine_points))
				user_id.marine_points[item_category] -= cost
			. = TRUE
			user_id.id_flags |= USED_GHMME

/obj/machinery/marine_selector/clothes
	name = "\improper GHMME Automated Closet"
	desc = "An automated closet hooked up to a colossal storage unit of standard-issue uniform and armor."
	icon_state = "marineuniform"
	icon_vend = "marineuniform-vend"
	icon_deny = "marineuniform-deny"
	lock_flags = null
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

/obj/machinery/marine_selector/clothes/Initialize(mapload)
	. = ..()
	listed_products = GLOB.marine_clothes_listed_products + GLOB.marine_gear_listed_products

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
	name = "\improper GHMME Automated Engineer Closet"
	req_access = list(ACCESS_MARINE_ENGPREP)
	vendor_role = /datum/job/terragov/squad/engineer
	gives_webbing = FALSE

/obj/machinery/marine_selector/clothes/engi/Initialize(mapload)
	. = ..()
	listed_products = GLOB.engineer_clothes_listed_products

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
	vendor_role = /datum/job/fallen/marine/engineer
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/clothes/medic
	name = "\improper GHMME Automated Corpsman Closet"
	req_access = list(ACCESS_MARINE_MEDPREP)
	vendor_role = /datum/job/terragov/squad/corpsman
	gives_webbing = FALSE


/obj/machinery/marine_selector/clothes/medic/Initialize(mapload)
	. = ..()
	listed_products = GLOB.medic_clothes_listed_products

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
	vendor_role = /datum/job/fallen/marine/corpsman
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/clothes/smartgun
	name = "\improper GHMME Automated Smartgunner Closet"
	req_access = list(ACCESS_MARINE_SMARTPREP)
	vendor_role = /datum/job/terragov/squad/smartgunner
	gives_webbing = FALSE

/obj/machinery/marine_selector/clothes/smartgun/Initialize(mapload)
	. = ..()
	listed_products = GLOB.smartgunner_clothes_listed_products

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
	vendor_role = /datum/job/fallen/marine/smartgunner
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/clothes/specialist
	name = "GHMME Automated Specialist Closet"
	req_access = list(ACCESS_MARINE_SPECPREP)
	vendor_role = /datum/job/terragov/squad/specialist
	lock_flags = JOB_LOCK
	gives_webbing = FALSE

/obj/machinery/marine_selector/clothes/specialist/Initialize(mapload)
	. = ..()
	listed_products = GLOB.specialist_clothes_listed_products

/obj/machinery/marine_selector/clothes/specialist/alpha
	squad_tag = "Alpha"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_ALPHA)

/obj/machinery/marine_selector/clothes/specialist/bravo
	squad_tag = "Bravo"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_BRAVO)

/obj/machinery/marine_selector/clothes/specialist/charlie
	squad_tag = "Charlie"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_CHARLIE)

/obj/machinery/marine_selector/clothes/specialist/delta
	squad_tag = "Delta"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_DELTA)

/obj/machinery/marine_selector/clothes/leader
	name = "\improper GHMME Automated Leader Closet"
	req_access = list(ACCESS_MARINE_LEADER)
	vendor_role = /datum/job/terragov/squad/leader
	gives_webbing = FALSE

/obj/machinery/marine_selector/clothes/leader/Initialize(mapload)
	. = ..()
	listed_products = GLOB.leader_clothes_listed_products

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
	vendor_role = /datum/job/fallen/marine/leader
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/clothes/valhalla
	vendor_role = /datum/job/fallen/marine/standard
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/clothes/commander
	name = "\improper GHMME Automated Commander Closet"
	req_access = list(ACCESS_MARINE_COMMANDER)
	vendor_role = /datum/job/terragov/command/fieldcommander
	lock_flags = JOB_LOCK
	gives_webbing = FALSE

/obj/machinery/marine_selector/clothes/commander/valhalla
	vendor_role = /datum/job/fallen/marine/fieldcommander
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/clothes/commander/Initialize(mapload)
	. = ..()
	listed_products = list(
		/obj/effect/vendor_bundle/basic_commander = list(CAT_STD, "Standard kit", 0, "white"),
		/obj/effect/vendor_bundle/basic_jaeger_commander = list(CAT_STD, "Essential Jaeger Kit", 0, "white"),
		/obj/effect/vendor_bundle/xenonauten_light/leader = list(CAT_AMR, "Xenonauten light armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_medium/leader = list(CAT_AMR, "Xenonauten medium armor kit", 0, "orange"),
		/obj/effect/vendor_bundle/xenonauten_heavy/leader = list(CAT_AMR, "Xenonauten heavy armor kit", 0, "orange"),
		/obj/item/clothing/suit/modular/jaeger/light = list(CAT_AMR, "Jaeger Scout light exo", 0, "orange"),
		/obj/item/clothing/suit/modular/jaeger/light/skirmisher = list(CAT_AMR, "Jaeger Skirmisher light exo", 0, "orange"),
		/obj/item/clothing/suit/modular/jaeger = list(CAT_AMR, "Jaeger Infantry medium exo", 0, "orange"),
		/obj/item/clothing/suit/modular/jaeger/eva = list(CAT_AMR, "Jaeger EVA medium exo", 0, "orange"),
		/obj/item/clothing/suit/modular/jaeger/heavy = list(CAT_AMR, "Jaeger Gungnir heavy exo", 0, "orange"),
		/obj/item/clothing/suit/modular/jaeger/heavy/assault = list(CAT_AMR, "Jaeger Assault heavy exo", 0, "orange"),
		/obj/item/clothing/suit/modular/jaeger/heavy/eod = list(CAT_AMR, "Jaeger EOD heavy exo", 0, "orange"),
		/obj/item/storage/backpack/marine/satchel = list(CAT_BAK, "Satchel", 0, "black"),
		/obj/item/storage/backpack/marine/standard = list(CAT_BAK, "Backpack", 0, "black"),
		/obj/item/storage/holster/blade/machete/full = list(CAT_BAK, "Machete scabbard", 0, "black"),
		/obj/item/armor_module/storage/uniform/black_vest = list(CAT_WEB, "Tactical black vest", 0, "black"),
		/obj/item/armor_module/storage/uniform/webbing = list(CAT_WEB, "Tactical webbing", 0, "black"),
		/obj/item/armor_module/storage/uniform/holster = list(CAT_WEB, "Shoulder handgun holster", 0, "black"),
		/obj/item/storage/belt/marine = list(CAT_BEL, "Standard ammo belt", 0, "black"),
		/obj/item/storage/belt/shotgun = list(CAT_BEL, "Shotgun ammo belt", 0, "black"),
		/obj/item/storage/belt/knifepouch = list(CAT_BEL, "Knives belt", 0, "black"),
		/obj/item/storage/holster/belt/pistol/standard_pistol = list(CAT_BEL, "Pistol belt", 0, "black"),
		/obj/item/storage/holster/belt/revolver/standard_revolver = list(CAT_BEL, "Revolver belt", 0, "black"),
		/obj/item/storage/belt/sparepouch = list(CAT_BEL, "G8 general utility pouch", 0, "black"),
		/obj/item/belt_harness/marine = list(CAT_BEL, "Belt Harness", 0, "black"),
		/obj/item/armor_module/module/welding = list(CAT_HEL, "Jaeger welding module", 0, "orange"),
		/obj/item/armor_module/module/binoculars = list(CAT_HEL, "Jaeger binoculars module", 0, "orange"),
		/obj/item/armor_module/module/artemis = list(CAT_HEL, "Jaeger Freyr module", 0, "orange"),
		/obj/item/armor_module/module/antenna = list(CAT_HEL, "Jaeger Antenna module", 0, "orange"),
		/obj/item/clothing/head/tgmcberet/fc = list(CAT_HEL, "FC Beret", 0, "black"),
		/obj/item/armor_module/storage/medical = list(CAT_MOD, "Medical Storage Module", 0, "black"),
		/obj/item/armor_module/storage/injector = list(CAT_MOD, "Injector Storage Module", 0, "black"),
		/obj/item/armor_module/storage/general = list(CAT_MOD, "General Purpose Storage Module", 0, "black"),
		/obj/item/armor_module/storage/ammo_mag = list(CAT_MOD, "Ammo Storage Module", 0, "black"),
		/obj/item/armor_module/storage/engineering = list(CAT_MOD, "Engineering Storage Module", 0, "black"),
		/obj/item/armor_module/storage/grenade = list(CAT_MOD, "Grenade Storage Module", 0, "black"),
		/obj/item/storage/pouch/shotgun = list(CAT_POU, "Shotgun shell pouch", 0, "black"),
		/obj/item/storage/pouch/general/large = list(CAT_POU, "General pouch", 0, "black"),
		/obj/item/storage/pouch/magazine/large = list(CAT_POU, "Magazine pouch", 0, "black"),
		/obj/item/storage/holster/flarepouch/full = list(CAT_POU, "Flare pouch", 0, "black"),
		/obj/item/storage/pouch/medical_injectors/standard = list(CAT_POU, "Combat injector pouch", 0,"orange"),
		/obj/item/storage/pouch/medkit/firstaid = list(CAT_POU, "Firstaid pouch", 0, "orange"),
		/obj/item/storage/pouch/tools/full = list(CAT_POU, "Tool pouch (tools included)", 0, "black"),
		/obj/item/storage/pouch/grenade/slightlyfull = list(CAT_POU, "Grenade pouch (grenades included)", 0,"black"),
		/obj/item/storage/pouch/construction/full = list(CAT_POU, "Construction pouch (materials included)", 0, "black"),
		/obj/item/storage/pouch/magazine/pistol/large = list(CAT_POU, "Pistol magazine pouch", 0, "black"),
		/obj/item/storage/pouch/pistol = list(CAT_POU, "Sidearm pouch", 0, "black"),
		/obj/item/storage/pouch/explosive = list(CAT_POU, "Explosive pouch", 0, "black"),
		/obj/effect/vendor_bundle/mimir = list(CAT_ARMMOD, "Mark 1 Mimir Resistance set", 0,"black"),
//		/obj/item/armor_module/module/ballistic_armor = list(CAT_ARMMOD, "Hod Accident Prevention Plating", 0,"black"),
		/obj/effect/vendor_bundle/tyr = list(CAT_ARMMOD, "Mark 1 Tyr extra armor set", 0,"black"),
		/obj/item/armor_module/module/better_shoulder_lamp = list(CAT_ARMMOD, "Baldur light armor module", 0,"black"),
		/obj/effect/vendor_bundle/vali = list(CAT_ARMMOD, "Vali chemical enhancement set", 0,"black"),
		/obj/item/armor_module/module/eshield = list(CAT_ARMMOD, "Svalinn Energy Shield System", 0 , "black"),
		/obj/item/armor_module/module/mirage = list(CAT_ARMMOD, "Loki Illusion Module", 0, "black"),
		/obj/item/armor_module/module/armorlock = list(CAT_ARMMOD, "Thor Armorlock Module", 0, "black"),
		/obj/item/clothing/mask/gas = list(CAT_MAS, "Transparent gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical = list(CAT_MAS, "Tactical gas mask", 0,"black"),
		/obj/item/clothing/mask/gas/tactical/coif = list(CAT_MAS, "Tactical coifed gas mask", 0,"black"),
		/obj/item/clothing/mask/rebreather/scarf = list(CAT_MAS, "Heat absorbent coif", 0, "black"),
		/obj/item/clothing/mask/rebreather = list(CAT_MAS, "Rebreather", 0, "black"),
	)



/obj/machinery/marine_selector/clothes/synth
	name = "M57 Synthetic Equipment Vendor"
	desc = "An automated synthetic equipment vendor hooked up to a modest storage unit."
	icon_state = "synth"
	icon_vend = "synth-vend"
	icon_deny = "synth-deny"
	vendor_role = /datum/job/terragov/silicon/synthetic
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/clothes/synth/valhalla
	vendor_role = /datum/job/fallen/marine/synthetic
	resistance_flags = INDESTRUCTIBLE


/obj/machinery/marine_selector/clothes/synth/Initialize(mapload)
	. = ..()
	listed_products = GLOB.synthetic_clothes_listed_products

/obj/machinery/marine_selector/clothes/synth/valhalla
	vendor_role = /datum/job/fallen/marine/synthetic
	resistance_flags = INDESTRUCTIBLE


/obj/machinery/marine_selector/clothes/synth/Initialize(mapload)
	. = ..()
	listed_products = GLOB.synthetic_clothes_listed_products

// SOM

/obj/machinery/marine_selector/clothes/som
	name = "GHMME Automated SOM Closet"
	desc = "An automated closet hooked up to a colossal storage unit of SOM-issue uniform and armor."
	req_access = list(ACCESS_SOM_DEFAULT)
	vendor_role = /datum/job/som/squad/standard
	gives_webbing = FALSE
	faction = FACTION_SOM

/obj/machinery/marine_selector/clothes/som/standard
	name = "GHMME Automated Standard Closet"
	vendor_role = /datum/job/som/squad/standard

/obj/machinery/marine_selector/clothes/som/standard/Initialize(mapload)
	. = ..()
	listed_products = GLOB.som_standard_clothes_listed_products

/obj/machinery/marine_selector/clothes/som/medic
	name = "GHMME Medical Equipment Closet"
	icon_state = "medic"
	icon_vend = "medic-vend"
	icon_deny = "medic-deny"
	vendor_role = /datum/job/som/squad/medic
	req_access = list(ACCESS_SOM_MEDICAL)

/obj/machinery/marine_selector/clothes/som/medic/Initialize(mapload)
	. = ..()
	listed_products = GLOB.som_medic_clothes_listed_products

/obj/machinery/marine_selector/clothes/som/veteran
	name = "GHMME Veteran Equipment Closet"
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	vendor_role = /datum/job/som/squad/veteran
	req_access = list(ACCESS_SOM_VETERAN)

/obj/machinery/marine_selector/clothes/som/veteran/Initialize(mapload)
	. = ..()
	listed_products = GLOB.som_veteran_clothes_listed_products

/obj/machinery/marine_selector/clothes/som/engi
	name = "GHMME Engineer Equipment Rack"
	icon_state = "engineer"
	icon_vend = "engineer-vend"
	icon_deny = "engineer-deny"
	vendor_role = /datum/job/som/squad/engineer
	req_access = list(ACCESS_SOM_ENGINEERING)

/obj/machinery/marine_selector/clothes/som/engi/Initialize(mapload)
	. = ..()
	listed_products = GLOB.som_engineer_clothes_listed_products

/obj/machinery/marine_selector/clothes/som/leader
	name = "GHMME Squad Leader Equipment Rack"
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	vendor_role = /datum/job/som/squad/leader
	req_access = list(ACCESS_SOM_SQUADLEADER)

/obj/machinery/marine_selector/clothes/som/leader/Initialize(mapload)
	. = ..()
	listed_products = GLOB.som_leader_clothes_listed_products

// VSD

/obj/machinery/marine_selector/clothes/vsd
	name = "GHMME Automated KZ Closet"
	req_access = list(ACCESS_VSD_PREP)
	vendor_role = /datum/job/vsd_squad/standard
	gives_webbing = FALSE
	faction = FACTION_VSD
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/clothes/vsd/standard
	name = "GHMME Automated KZ Standard Closet"
	vendor_role = /datum/job/vsd_squad/standard

/obj/machinery/marine_selector/clothes/vsd/standard/Initialize(mapload)
	. = ..()
	listed_products = GLOB.vsd_standard_clothes_listed_products

/obj/machinery/marine_selector/clothes/vsd/medic
	name = "GHMME Automated KZ Medic Closet"
	vendor_role = /datum/job/vsd_squad/medic
	req_access = list(ACCESS_VSD_MEDPREP)

/obj/machinery/marine_selector/clothes/vsd/medic/Initialize(mapload)
	. = ..()
	listed_products = GLOB.vsd_medic_clothes_listed_products

/obj/machinery/marine_selector/clothes/vsd/engineer
	name = "GHMME Automated KZ Engineer Closet"
	vendor_role = /datum/job/vsd_squad/engineer
	req_access = list(ACCESS_VSD_ENGPREP)

/obj/machinery/marine_selector/clothes/vsd/engineer/Initialize(mapload)
	. = ..()
	listed_products = GLOB.vsd_engineer_clothes_listed_products

/obj/machinery/marine_selector/clothes/vsd/specialist
	name = "GHMME Automated KZ Specialist Closet"
	vendor_role = /datum/job/vsd_squad/spec
	req_access = list(ACCESS_VSD_SPECPREP)

/obj/machinery/marine_selector/clothes/vsd/specialist/Initialize(mapload)
	. = ..()
	listed_products = GLOB.vsd_specialist_clothes_listed_products

/obj/machinery/marine_selector/clothes/vsd/leader
	name = "GHMME Automated KZ Leader Closet"
	vendor_role = /datum/job/vsd_squad/leader
	req_access = list(ACCESS_VSD_LEADPREP)

/obj/machinery/marine_selector/clothes/vsd/leader/Initialize(mapload)
	. = ..()
	listed_products = GLOB.vsd_leader_clothes_listed_products

// PMC

/obj/machinery/marine_selector/clothes/pmc
	name = "GHMME Automated PMC Closet"
	req_access = list(ACCESS_NT_PMC_COMMON)
	vendor_role = /datum/job/pmc/squad/standard
	gives_webbing = FALSE
	faction = FACTION_NANOTRASEN
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/clothes/pmc/standard
	name = "GHMME Automated PMC Standard Closet"
	vendor_role = /datum/job/pmc/squad/standard

/obj/machinery/marine_selector/clothes/pmc/standard/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_standard_clothes_listed_products

/obj/machinery/marine_selector/clothes/pmc/medic
	name = "GHMME Automated PMC Medic Closet"
	vendor_role = /datum/job/pmc/squad/medic

/obj/machinery/marine_selector/clothes/pmc/medic/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_medic_clothes_listed_products

/obj/machinery/marine_selector/clothes/pmc/engineer
	name = "GHMME Automated PMC Engineer Closet"
	vendor_role = /datum/job/pmc/squad/engineer

/obj/machinery/marine_selector/clothes/pmc/engineer/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_engineer_clothes_listed_products

/obj/machinery/marine_selector/clothes/pmc/gunner
	name = "GHMME Automated PMC Gunner Closet"
	vendor_role = /datum/job/pmc/squad/gunner

/obj/machinery/marine_selector/clothes/pmc/gunner/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_gunner_clothes_listed_products

/obj/machinery/marine_selector/clothes/pmc/sniper
	name = "GHMME Automated PMC Specialist Closet"
	vendor_role = /datum/job/pmc/squad/sniper

/obj/machinery/marine_selector/clothes/pmc/sniper/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_sniper_clothes_listed_products

/obj/machinery/marine_selector/clothes/pmc/leader
	name = "GHMME Automated PMC Leader Closet"
	vendor_role = /datum/job/pmc/squad/leader

/obj/machinery/marine_selector/clothes/pmc/leader/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_leader_clothes_listed_products

// ICC

/obj/machinery/marine_selector/clothes/icc
	name = "GHMME Automated ICC Closet"
	req_access = list(ACCESS_ICC_PREP)
	vendor_role = /datum/job/icc_squad/standard
	gives_webbing = FALSE
	faction = FACTION_ICC
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/clothes/icc/standard
	name = "GHMME Automated ICC Standard Closet"
	vendor_role = /datum/job/icc_squad/standard

/obj/machinery/marine_selector/clothes/icc/standard/Initialize(mapload)
	. = ..()
	listed_products = GLOB.icc_standard_clothes_listed_products

/obj/machinery/marine_selector/clothes/icc/medic
	name = "GHMME Automated ICC Medic Closet"
	req_access = list(ACCESS_ICC_MEDPREP)
	vendor_role = /datum/job/icc_squad/medic

/obj/machinery/marine_selector/clothes/icc/medic/Initialize(mapload)
	. = ..()
	listed_products = GLOB.icc_medic_clothes_listed_products

/obj/machinery/marine_selector/clothes/icc/guard
	name = "GHMME Automated ICC Guardsman Closet"
	req_access = list(ACCESS_ICC_GUARDPREP)
	vendor_role = /datum/job/icc_squad/spec

/obj/machinery/marine_selector/clothes/icc/guard/Initialize(mapload)
	. = ..()
	listed_products = GLOB.icc_standard_clothes_listed_products

/obj/machinery/marine_selector/clothes/icc/leader
	name = "GHMME Automated ICC Squad Leader Closet"
	req_access = list(ACCESS_ICC_LEADPREP)
	vendor_role = /datum/job/icc_squad/leader

/obj/machinery/marine_selector/clothes/icc/leader/Initialize(mapload)
	. = ..()
	listed_products = GLOB.icc_standard_clothes_listed_products

////////////////////// Gear ////////////////////////////////////////////////////////



/obj/machinery/marine_selector/gear
	name = "\improper NEXUS Automated Equipment Rack"
	desc = "An automated equipment rack hooked up to a colossal storage unit."
	icon_state = "marinearmory"
	use_points = TRUE

/obj/machinery/marine_selector/gear/medic
	name = "\improper NEXUS automated medical equipment rack"
	desc = "An automated equipment rack hooked up to a colossal storage of medical goods."
	icon_state = "medic"
	icon_vend = "medic-vend"
	icon_deny = "medic-deny"
	vendor_role = /datum/job/terragov/squad/corpsman
	req_access = list(ACCESS_MARINE_MEDPREP)

/obj/machinery/marine_selector/gear/medic/Initialize(mapload)
	. = ..()
	listed_products = GLOB.medic_gear_listed_products

/obj/machinery/marine_selector/gear/medic/valhalla
	vendor_role = /datum/job/fallen/marine/corpsman
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/gear/specialist
	name = "NEXUS Automated Specialist Equipment Rack"
	desc = "An automated specialist equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	vendor_role = /datum/job/terragov/squad/specialist
	req_access = list(ACCESS_MARINE_SPECPREP)

/obj/machinery/marine_selector/gear/specialist/Initialize(mapload)
	. = ..()
	listed_products = GLOB.specialist_gear_listed_products

/obj/machinery/marine_selector/gear/vanguard
	name = "NEXUS Automated Vanguard Equipment Rack"
	desc = "An automated Vanguard equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	vendor_role = /datum/job/terragov/command/vanguard
	req_access = list(ACCESS_MARINE_VANGPREP)
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/gear/vanguard/Initialize(mapload)
	. = ..()
	listed_products = GLOB.vanguard_gear_listed_products

/obj/machinery/marine_selector/gear/engi
	name = "\improper NEXUS automated engineering equipment rack"
	desc = "An automated equipment rack hooked up to a colossal storage of engineering-related goods."
	icon_state = "engineer"
	icon_vend = "engineer-vend"
	icon_deny = "engineer-deny"
	vendor_role = /datum/job/terragov/squad/engineer
	req_access = list(ACCESS_MARINE_ENGPREP)

/obj/machinery/marine_selector/gear/engi/Initialize(mapload)
	. = ..()
	listed_products = GLOB.engineer_gear_listed_products

/obj/machinery/marine_selector/gear/engi/valhalla
	vendor_role = /datum/job/fallen/marine/engineer
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/gear/smartgun
	name = "\improper NEXUS automated smartgun equipment rack"
	desc = "An automated equipment rack hooked up to a colossal storage of smartgun-related goods."
	icon_state = "smartgunner"
	icon_vend = "smartgunner-vend"
	icon_deny = "smartgunner-deny"
	vendor_role = /datum/job/terragov/squad/smartgunner
	req_access = list(ACCESS_MARINE_SMARTPREP)

/obj/machinery/marine_selector/gear/smartgun/Initialize(mapload)
	. = ..()
	listed_products = GLOB.smartgunner_gear_listed_products

/obj/machinery/marine_selector/gear/smartgun/valhalla
	vendor_role = /datum/job/fallen/marine/smartgunner
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/gear/leader
	name = "\improper NEXUS automated squad leader's equipment rack"
	desc = "An automated equipment rack hooked up to a colossal storage of basic cat-herding devices."
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	vendor_role = /datum/job/terragov/squad/leader
	req_access = list(ACCESS_MARINE_LEADER)

/obj/machinery/marine_selector/gear/leader/Initialize(mapload)
	. = ..()
	listed_products = GLOB.leader_gear_listed_products

/obj/machinery/marine_selector/gear/leader/valhalla
	vendor_role = /datum/job/fallen/marine/leader
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/gear/commander
	name = "\improper NEXUS automated command equipment rack"
	desc = "An automated equipment rack hooked up to a colossal storage unit of advanced cat-herding devices."
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	vendor_role = /datum/job/terragov/command/fieldcommander
	req_access = list(ACCESS_MARINE_COMMANDER)
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/gear/commander/Initialize(mapload)
	. = ..()
	listed_products = GLOB.commander_gear_listed_products

/obj/machinery/marine_selector/gear/commander/valhalla
	vendor_role = /datum/job/fallen/marine/fieldcommander
	resistance_flags = INDESTRUCTIBLE
	lock_flags = JOB_LOCK

// SOM

/obj/machinery/marine_selector/gear/som
	name = "Automated Equipment Rack"
	desc = "An automated equipment rack hooked up to a colossal storage unit."
	icon_state = "marinearmory"
	use_points = TRUE
	faction = FACTION_SOM

/obj/machinery/marine_selector/gear/som/standard
	name = "Automated Equipment Rack"
	desc = "An automated equipment rack hooked up to a colossal storage unit."
	icon_state = "marinearmory"
	use_points = TRUE
	req_access = list(ACCESS_SOM_DEFAULT)
	vendor_role = /datum/job/som/squad/standard

/obj/machinery/marine_selector/gear/som/standard/Initialize(mapload)
	. = ..()
	listed_products = GLOB.som_standard_gear_listed_products

/obj/machinery/marine_selector/gear/som/medic
	name = "Automated Medical Equipment Rack"
	desc = "An automated medic equipment rack hooked up to a colossal storage unit."
	icon_state = "medic"
	icon_vend = "medic-vend"
	icon_deny = "medic-deny"
	vendor_role = /datum/job/som/squad/medic
	req_access = list(ACCESS_SOM_MEDICAL)

/obj/machinery/marine_selector/gear/som/medic/Initialize(mapload)
	. = ..()
	listed_products = GLOB.som_medic_gear_listed_products

/obj/machinery/marine_selector/gear/som/veteran
	name = "Automated Veteran Equipment Rack"
	desc = "An automated veteran equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	vendor_role = /datum/job/som/squad/veteran
	req_access = list(ACCESS_SOM_VETERAN)

/obj/machinery/marine_selector/gear/som/veteran/Initialize(mapload)
	. = ..()
	listed_products = GLOB.som_veteran_gear_listed_products

/obj/machinery/marine_selector/gear/som/engi
	name = "Automated Engineer Equipment Rack"
	desc = "An automated engineer equipment rack hooked up to a colossal storage unit."
	icon_state = "engineer"
	icon_vend = "engineer-vend"
	icon_deny = "engineer-deny"
	vendor_role = /datum/job/som/squad/engineer
	req_access = list(ACCESS_SOM_ENGINEERING)

/obj/machinery/marine_selector/gear/som/engi/Initialize(mapload)
	. = ..()
	listed_products = GLOB.som_engineer_gear_listed_products

/obj/machinery/marine_selector/gear/som/leader
	name = "Automated Squad Leader Equipment Rack"
	desc = "An automated squad leader equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	vendor_role = /datum/job/som/squad/leader
	req_access = list(ACCESS_SOM_SQUADLEADER)

/obj/machinery/marine_selector/gear/som/leader/Initialize(mapload)
	. = ..()
	listed_products = GLOB.som_leader_gear_listed_products

// VSD

/obj/machinery/marine_selector/gear/vsd
	name = "Automated Equipment Rack"
	desc = "An automated equipment rack hooked up to a colossal storage unit."
	icon_state = "marinearmory"
	use_points = TRUE
	req_access = list(ACCESS_VSD_PREP)
	faction = FACTION_VSD
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/gear/vsd/medic
	name = "Automated Medical Equipment Rack"
	desc = "An automated medic equipment rack hooked up to a colossal storage unit."
	icon_state = "medic"
	icon_vend = "medic-vend"
	icon_deny = "medic-deny"
	req_access = list(ACCESS_VSD_MEDPREP)
	vendor_role = /datum/job/vsd_squad/medic

/obj/machinery/marine_selector/gear/vsd/medic/Initialize(mapload)
	. = ..()
	listed_products = GLOB.vsd_medic_gear_listed_products

/obj/machinery/marine_selector/gear/vsd/specialist
	name = "Automated Specialist Equipment Rack"
	desc = "An automated specialist equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	req_access = list(ACCESS_VSD_SPECPREP)
	vendor_role = /datum/job/vsd_squad/spec

/obj/machinery/marine_selector/gear/vsd/specialist/Initialize(mapload)
	. = ..()
	listed_products = GLOB.vsd_specialist_gear_listed_products

/obj/machinery/marine_selector/gear/vsd/engi
	name = "Automated Engineer Equipment Rack"
	desc = "An automated engineer equipment rack hooked up to a colossal storage unit."
	icon_state = "engineer"
	icon_vend = "engineer-vend"
	icon_deny = "engineer-deny"
	req_access = list(ACCESS_VSD_ENGPREP)
	vendor_role = /datum/job/vsd_squad/engineer

/obj/machinery/marine_selector/gear/vsd/engi/Initialize(mapload)
	. = ..()
	listed_products = GLOB.vsd_engineer_gear_listed_products

/obj/machinery/marine_selector/gear/vsd/leader
	name = "Automated Squad Leader Equipment Rack"
	desc = "An automated squad leader equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	req_access = list(ACCESS_VSD_LEADPREP)
	vendor_role = /datum/job/vsd_squad/leader

/obj/machinery/marine_selector/gear/vsd/leader/Initialize(mapload)
	. = ..()
	listed_products = GLOB.vsd_leader_gear_listed_products

// PMC

/obj/machinery/marine_selector/clothes/pmc
	name = "Nexus Automated PMC Rack"
	icon_state = "marinearmory"
	use_points = TRUE
	req_access = list(ACCESS_NT_PMC_COMMON)
	vendor_role = /datum/job/pmc/squad/standard
	gives_webbing = FALSE
	faction = FACTION_NANOTRASEN
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/gear/pmc/standard
	name = "Nexus Automated PMC Standard Rack"
	vendor_role = /datum/job/pmc/squad/standard

/obj/machinery/marine_selector/gear/pmc/standard/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_standard_gear_listed_products

/obj/machinery/marine_selector/gear/pmc/medic
	name = "Nexus Automated PMC Medic Rack"
	vendor_role = /datum/job/pmc/squad/medic

/obj/machinery/marine_selector/gear/pmc/medic/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_medic_gear_listed_products

/obj/machinery/marine_selector/gear/pmc/engineer
	name = "Nexus Automated PMC Engineer Rack"
	vendor_role = /datum/job/pmc/squad/engineer

/obj/machinery/marine_selector/gear/pmc/engineer/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_engineer_gear_listed_products

/obj/machinery/marine_selector/gear/pmc/gunner
	name = "Nexus Automated PMC Gunner Rack"
	vendor_role = /datum/job/pmc/squad/gunner

/obj/machinery/marine_selector/gear/pmc/gunner/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_gunner_gear_listed_products

/obj/machinery/marine_selector/gear/pmc/sniper
	name = "Nexus Automated PMC Specialist Rack"
	vendor_role = /datum/job/pmc/squad/sniper

/obj/machinery/marine_selector/gear/pmc/sniper/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_sniper_gear_listed_products

/obj/machinery/marine_selector/gear/pmc/leader
	name = "Nexus Automated PMC Leader Rack"
	vendor_role = /datum/job/pmc/squad/leader

/obj/machinery/marine_selector/gear/pmc/leader/Initialize(mapload)
	. = ..()
	listed_products = GLOB.pmc_leader_gear_listed_products

// ICC

/obj/machinery/marine_selector/gear/icc
	name = "Automated Equipment Rack"
	desc = "An automated equipment rack hooked up to a colossal storage unit."
	icon_state = "marinearmory"
	use_points = TRUE
	req_access = list(ACCESS_ICC_PREP)
	faction = FACTION_ICC
	lock_flags = JOB_LOCK

/obj/machinery/marine_selector/gear/icc/medic
	name = "Automated Medical Equipment Rack"
	desc = "An automated medic equipment rack hooked up to a colossal storage unit."
	icon_state = "medic"
	icon_vend = "medic-vend"
	icon_deny = "medic-deny"
	req_access = list(ACCESS_ICC_MEDPREP)
	vendor_role = /datum/job/icc_squad/medic

/obj/machinery/marine_selector/gear/icc/medic/Initialize(mapload)
	. = ..()
	listed_products = GLOB.icc_medic_gear_listed_products

/obj/machinery/marine_selector/gear/icc/guard
	name = "Automated Guardsman Equipment Rack"
	desc = "An automated guardsman equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	req_access = list(ACCESS_ICC_GUARDPREP)
	vendor_role = /datum/job/icc_squad/spec

/obj/machinery/marine_selector/gear/icc/guard/Initialize(mapload)
	. = ..()
	listed_products = GLOB.icc_guard_gear_listed_products

/obj/machinery/marine_selector/gear/icc/leader
	name = "Automated Squad Leader Equipment Rack"
	desc = "An automated squad leader equipment rack hooked up to a colossal storage unit."
	icon_state = "squadleader"
	icon_vend = "squadleader-vend"
	icon_deny = "squadleader-deny"
	req_access = list(ACCESS_ICC_LEADPREP)
	vendor_role = /datum/job/icc_squad/leader

/obj/machinery/marine_selector/gear/icc/leader/Initialize(mapload)
	. = ..()
	listed_products = GLOB.icc_leader_gear_listed_products

///Spawns a set of objects from specified typepaths. For vendors to spawn multiple items while only needing one path.
/obj/effect/vendor_bundle
	///The set of typepaths to spawn
	var/list/gear_to_spawn
	///Records the gear objects that have been spawned, so vendors can see what they just vended
	var/list/spawned_gear

///Spawns the gear from this vendor_bundle. Deletes itself after spawning gear; can be disabled to check what has been spawned (must then delete the bundle yourself)
/obj/effect/vendor_bundle/Initialize(mapload, autodelete = TRUE)
	. = ..()
	LAZYINITLIST(gear_to_spawn)
	for(var/typepath in gear_to_spawn)
		LAZYADD(spawned_gear, new typepath(loc))
	if (autodelete)
		qdel(src)

/obj/effect/vendor_bundle/basic
	gear_to_spawn = list(
		/obj/item/clothing/under/marine,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/clothing/gloves/marine,
		/obj/item/storage/box/MRE,
		/obj/item/paper/tutorial/medical,
		/obj/item/paper/tutorial/mechanics,
	)

/obj/effect/vendor_bundle/basic_jaeger
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/clothing/gloves/marine,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
		/obj/item/paper/tutorial/medical,
		/obj/item/paper/tutorial/mechanics,
	)

/obj/effect/vendor_bundle/basic_smartgunner
	gear_to_spawn = list(
		/obj/item/clothing/under/marine,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/clothing/gloves/marine,
		/obj/item/storage/box/MRE,
	)

/obj/effect/vendor_bundle/basic_jaeger_smartgunner
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/clothing/gloves/marine,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/vendor_bundle/basic_squadleader
	gear_to_spawn = list(
		/obj/item/clothing/under/marine,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/clothing/gloves/marine,
		/obj/item/storage/box/MRE,
	)

/obj/effect/vendor_bundle/basic_jaeger_squadleader
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/clothing/gloves/marine,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/vendor_bundle/basic_medic
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/corpsman,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/clothing/gloves/marine,
		/obj/item/storage/box/MRE,
	)

/obj/effect/vendor_bundle/basic_jaeger_medic
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/clothing/gloves/marine,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/vendor_bundle/basic_engineer
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/engineer,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/vendor_bundle/basic_jaeger_engineer
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/vendor_bundle/basic_commander
	gear_to_spawn = list(
		/obj/item/clothing/under/marine,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
	)

/obj/effect/vendor_bundle/basic_jaeger_commander
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/jaeger,
		/obj/item/clothing/shoes/marine/full,
		/obj/item/storage/box/MRE,
		/obj/item/facepaint/green,
	)

/obj/effect/vendor_bundle/medic
	gear_to_spawn = list(
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

/obj/effect/vendor_bundle/vanguard
	gear_to_spawn = list(
		/obj/item/weapon/gun/rifle/nt_halter/cqb/elite,
		/obj/item/tweezers,
		/obj/item/storage/holster/belt/pistol/smart_pistol/full,
		/obj/item/reagent_containers/hypospray/advanced/oxycodone,
		/obj/item/storage/box/MRE,
		/obj/item/reagent_containers/hypospray/advanced/big/combatmix,
		/obj/item/storage/firstaid/adv,
		/obj/item/defibrillator,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/clothing/head/modular/m10x/leader,
		/obj/item/storage/pouch/medkit/medic,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/storage/backpack/lightpack
	)

/obj/effect/vendor_bundle/stretcher
	desc = "A standard-issue Nine-Tailed Fox corpsman medivac stretcher. Comes with an extra beacon, but multiple beds can be linked to one beacon."
	gear_to_spawn = list(
		/obj/item/roller/medevac,
		/obj/item/medevac_beacon,
	)

/obj/effect/vendor_bundle/engi
	gear_to_spawn = list(
		/obj/item/explosive/plastique,
		/obj/item/explosive/grenade/chem_grenade/razorburn_small,
		/obj/item/clothing/gloves/marine/insulated,
		/obj/item/cell/high,
		/obj/item/lightreplacer,
		/obj/item/circuitboard/apc,
	)

/obj/effect/vendor_bundle/smartgunner_pistol
	gear_to_spawn = list(
		/obj/item/clothing/glasses/night/m56_goggles,
		/obj/item/storage/holster/belt/pistol/smart_pistol,
		/obj/item/weapon/gun/pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
	)

/obj/effect/vendor_bundle/leader
	gear_to_spawn = list(
		/obj/item/explosive/plastique,
		/obj/item/supply_beacon,
		/obj/item/supply_beacon,
		/obj/item/whistle,
		/obj/item/compass,
		/obj/item/binoculars/tactical,
		/obj/item/pinpointer,
		/obj/item/clothing/glasses/hud/health,
	)

/obj/effect/vendor_bundle/specialist
	gear_to_spawn = list(
		/obj/item/clothing/gloves/marine/insulated,
		/obj/item/binoculars/tactical/scout,
		/obj/item/explosive/plastique,
	)

/obj/effect/vendor_bundle/commander
	gear_to_spawn = list(
		/obj/item/explosive/plastique,
		/obj/item/supply_beacon,
		/obj/item/healthanalyzer,
		/obj/item/roller/medevac,
		/obj/item/medevac_beacon,
		/obj/item/whistle,
		/obj/item/clothing/glasses/hud/health,
	)

/obj/effect/vendor_bundle/synth
	gear_to_spawn = list(
		/obj/item/stack/sheet/plasteel/medium_stack,
		/obj/item/stack/sheet/metal/large_stack,
		/obj/item/tool/weldingtool/hugetank,
		/obj/item/tool/handheld_charger,
		/obj/item/defibrillator,
		/obj/item/medevac_beacon,
		/obj/item/roller/medevac,
		/obj/item/roller,
		/obj/item/bodybag/cryobag,
		/obj/item/reagent_containers/hypospray/advanced/oxycodone,
		/obj/item/tweezers,
		/obj/item/cell/high,
		/obj/item/circuitboard/apc,
		/obj/item/tool/soap,
	)

/obj/effect/vendor_bundle/white_dress
	name = "Full set of NTC white dress uniform"
	desc = "A standard-issue Nine Tailed Fox white dress uniform. The starch in the fabric chafes a small amount but it pales in comparison to the pride you feel when you first put it on during graduation from boot camp. Doesn't seem to fit perfectly around the waist though."
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/whites,
		/obj/item/clothing/suit/white_dress_jacket,
		/obj/item/clothing/head/white_dress,
		/obj/item/clothing/shoes/white,
		/obj/item/clothing/gloves/white,
	)

/obj/effect/vendor_bundle/service_uniform
	name = "Full set of NTC service uniform"
	desc = "A standard-issue Nine Tailed Fox dress uniform. Sometimes, you hate wearing this since you remember wearing this to Infantry School and have to wear this when meeting a commissioned officer. This is what you wear when you are not deployed and are working in an office. Doesn't seem to fit perfectly around the waist."
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/service,
		/obj/item/clothing/head/garrisoncap,
		/obj/item/clothing/head/servicecap,
		/obj/item/clothing/shoes/marine/full,
	)

/obj/effect/vendor_bundle/jaeger_light
	desc = "A set of light scout pattern jaeger armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/marine/scout,
		/obj/item/clothing/suit/modular/jaeger/light,
	)

/obj/effect/vendor_bundle/jaeger_skirmish
	desc = "A set of light skirmisher pattern jaeger armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/marine/skirmisher,
		/obj/item/clothing/suit/modular/jaeger/light/skirmisher,
	)

/obj/effect/vendor_bundle/jaeger_infantry
	desc = "A set of medium Infantry pattern jaeger armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/marine,
		/obj/item/clothing/suit/modular/jaeger,
	)

/obj/effect/vendor_bundle/jaeger_eva
	desc = "A set of medium EVA pattern jaeger armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/marine/eva,
		/obj/item/clothing/suit/modular/jaeger/eva,
	)

/obj/effect/vendor_bundle/jaeger_hell_jumper
	desc = "A set of medium Hell Jumper pattern jaeger armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/marine/helljumper,
		/obj/item/clothing/suit/modular/jaeger/helljumper,
	)

/obj/effect/vendor_bundle/jaeger_ranger
	desc = "A set of medium Ranger pattern jaeger armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/marine/ranger,
		/obj/item/clothing/suit/modular/jaeger/ranger,
	)

/obj/effect/vendor_bundle/jaeger_gungnir
	desc = "A set of Heavy Gungnir pattern jaeger armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/marine/gungnir,
		/obj/item/clothing/suit/modular/jaeger/heavy,
	)

/obj/effect/vendor_bundle/jaeger_assault
	desc = "A set of heavy Assault pattern jaeger armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/marine/assault,
		/obj/item/clothing/suit/modular/jaeger/heavy/assault,
	)

/obj/effect/vendor_bundle/jaeger_eod
	desc = "A set of heavy EOD pattern jaeger armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/marine/eod,
		/obj/item/clothing/suit/modular/jaeger/heavy/eod,
	)

/obj/effect/vendor_bundle/xenonauten_light
	desc = "A set of light Xenonauten pattern armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/m10x,
		/obj/item/clothing/suit/modular/xenonauten/light,
	)

/obj/effect/vendor_bundle/xenonauten_medium
	desc = "A set of medium Xenonauten pattern armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/m10x,
		/obj/item/clothing/suit/modular/xenonauten,
	)

/obj/effect/vendor_bundle/xenonauten_heavy
	desc = "A set of heavy Xenonauten pattern armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/m10x,
		/obj/item/clothing/suit/modular/xenonauten/heavy,
	)

/obj/effect/vendor_bundle/xenonauten_light/leader
	desc = "A set of light Xenonauten pattern armor, including an armor suit and a superior helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/m10x/leader,
		/obj/item/clothing/suit/modular/xenonauten/light,
	)

/obj/effect/vendor_bundle/xenonauten_medium/leader
	desc = "A set of medium Xenonauten pattern armor, including an armor suit and a superior helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/m10x/leader,
		/obj/item/clothing/suit/modular/xenonauten,
	)

/obj/effect/vendor_bundle/xenonauten_heavy/leader
	desc = "A set of heavy Xenonauten pattern armor, including an armor suit and a superior helmet."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/m10x/leader,
		/obj/item/clothing/suit/modular/xenonauten/heavy,
	)

/obj/effect/vendor_bundle/mimir
	desc = "A set of anti-gas gear setup to protect one from gas threats."
	gear_to_spawn = list(
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/clothing/mask/gas/tactical,
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
	)

/obj/effect/vendor_bundle/vali
	desc = "A set of specialized gear for close-quarters combat and enhanced chemical effectiveness."
	gear_to_spawn = list(
		/obj/item/armor_module/module/chemsystem,
		/obj/item/storage/holster/blade/machete/full_harvester,
		/obj/item/paper/chemsystem,
	)

/obj/effect/vendor_bundle/tyr
	desc = "A set of specialized gear for improved close-quarters combat longevitiy."
	gear_to_spawn = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
	)

// SOM vendor bundles
/obj/effect/vendor_bundle/som/engi
	gear_to_spawn = list(
		/obj/item/explosive/plastique,
		/obj/item/explosive/plastique,
		/obj/item/clothing/gloves/marine/som/insulated,
		/obj/item/cell/high,
		/obj/item/lightreplacer,
		/obj/item/circuitboard/apc,
	)

/obj/effect/vendor_bundle/som/medic
	gear_to_spawn = list(
		/obj/item/bodybag/cryobag,
		/obj/item/defibrillator,
		/obj/item/healthanalyzer,
		/obj/item/roller,
		/obj/item/tweezers_advanced,
		/obj/item/reagent_containers/hypospray/advanced/oxycodone,
		/obj/item/storage/firstaid/adv,
		/obj/item/clothing/glasses/hud/health,
	)

/obj/effect/vendor_bundle/som/veteran
	gear_to_spawn = list(
		/obj/item/supply_beacon,
		/obj/item/compass,
		/obj/item/binoculars/fire_support/campaign/som,
		/obj/item/explosive/plastique,
	)

/obj/effect/vendor_bundle/som/leader
	gear_to_spawn = list(
		/obj/item/explosive/plastique,
		/obj/item/supply_beacon,
		/obj/item/supply_beacon,
		/obj/item/whistle,
		/obj/item/compass,
		/obj/item/binoculars/fire_support/campaign/som,
		/obj/item/pinpointer,
		/obj/item/clothing/glasses/hud/health,
	)

/obj/effect/vendor_bundle/som/basic
	gear_to_spawn = list(
		/obj/item/clothing/under/som,
		/obj/item/clothing/shoes/marine/som/knife,
		/obj/item/clothing/gloves/marine/som,
		/obj/item/storage/box/MRE/som,
	)


/obj/effect/vendor_bundle/som/basic_medic
	gear_to_spawn = list(
		/obj/item/clothing/under/som/medic,
		/obj/item/clothing/shoes/marine/som/knife,
		/obj/item/clothing/gloves/marine/som,
		/obj/item/storage/box/MRE/som,
	)

/obj/effect/vendor_bundle/som/basic_engineer
	gear_to_spawn = list(
		/obj/item/clothing/under/som,
		/obj/item/clothing/shoes/marine/som/knife,
		/obj/item/storage/box/MRE/som,
	)

/obj/effect/vendor_bundle/som/basic_veteran
	gear_to_spawn = list(
		/obj/item/clothing/under/som/veteran,
		/obj/item/clothing/shoes/marine/som/knife,
		/obj/item/clothing/gloves/marine/som/veteran,
		/obj/item/storage/box/MRE/som,
	)

/obj/effect/vendor_bundle/som/basic_leader
	gear_to_spawn = list(
		/obj/item/clothing/under/som/leader,
		/obj/item/clothing/shoes/marine/som/knife,
		/obj/item/clothing/gloves/marine/som/veteran,
		/obj/item/storage/box/MRE/som,
	)

/obj/effect/vendor_bundle/som/light_armor
	desc = "A set of M-11 scout armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som/light,
		/obj/item/clothing/head/modular/som,
	)

/obj/effect/vendor_bundle/som/medium_armor
	desc = "A set of M-21 battle armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som,
		/obj/item/clothing/head/modular/som,
	)

/obj/effect/vendor_bundle/som/heavy_armor
	desc = "A set of M-31 heavy battle armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som/heavy,
		/obj/item/clothing/head/modular/som,
	)

/obj/effect/vendor_bundle/som/light_armor/engineer
	desc = "A set of M-11 scout armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som/light,
		/obj/item/clothing/head/modular/som/engineer,
	)

/obj/effect/vendor_bundle/som/medium_armor/engineer
	desc = "A set of M-21 battle armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som,
		/obj/item/clothing/head/modular/som/engineer,
	)

/obj/effect/vendor_bundle/som/heavy_armor/engineer
	desc = "A set of M-31 heavy battle armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som/heavy,
		/obj/item/clothing/head/modular/som/engineer,
	)

/obj/effect/vendor_bundle/som/light_armor/veteran
	desc = "A set of M-11 scout armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som/light,
		/obj/item/clothing/head/modular/som/veteran,
	)

/obj/effect/vendor_bundle/som/medium_armor/veteran
	desc = "A set of M-21 battle armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som,
		/obj/item/clothing/head/modular/som/veteran,
	)

/obj/effect/vendor_bundle/som/heavy_armor/veteran
	desc = "A set of M-31 heavy battle armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som/heavy,
		/obj/item/clothing/head/modular/som/veteran,
	)

/obj/effect/vendor_bundle/som/light_armor/leader
	desc = "A set of M-11 scout armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som/light,
		/obj/item/clothing/head/modular/som/leader,
	)

/obj/effect/vendor_bundle/som/medium_armor/leader
	desc = "A set of M-21 battle armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som,
		/obj/item/clothing/head/modular/som/leader,
	)

/obj/effect/vendor_bundle/som/heavy_armor/leader
	desc = "A set of M-35 'Gorgon' heavy combat armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/modular/som/heavy/leader,
		/obj/item/clothing/head/modular/som/veteran,
	)

/obj/effect/vendor_bundle/som/lorica
	desc = "A 'Lorica' armor module and helmet with a built-in 'Lorica' module, grants extra protection at the cost of mobility."
	gear_to_spawn = list(
		/obj/item/clothing/head/modular/som/lorica,
		/obj/item/armor_module/module/tyr_extra_armor/som,
	)

/obj/effect/vendor_bundle/som/hades
	desc = "A 'Hades' armor module and helmet with a built-in 'Hades' module. Provides excellent resistance to fire and prevents combustion."
	gear_to_spawn = list(
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/clothing/head/modular/som/hades,
	)

/obj/effect/vendor_bundle/som/mithridatius
	desc = "A set of anti-radiological gear, which can also protect from acid and gas."
	gear_to_spawn = list(
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/clothing/mask/gas/tactical,
		/obj/item/clothing/head/modular/som/bio,
	)

/obj/effect/vendor_bundle/som/aegis
	desc = "An 'Aegis' armor module. A sophisticated shielding unit, designed to disperse the energy of incoming impacts."
	gear_to_spawn = list(
		/obj/item/armor_module/module/eshield/som
	)

// VSD vendor bundles

/obj/effect/vendor_bundle/vsd/leader
	gear_to_spawn = list(
		/obj/item/clothing/glasses/night/vsd,
		/obj/item/explosive/plastique,
		/obj/item/binoculars/tactical/range,
		/obj/item/pinpointer,
	)

/obj/effect/vendor_bundle/vsd/engi
	gear_to_spawn = list(
		/obj/item/cell/high,
		/obj/item/lightreplacer,
		/obj/item/circuitboard/apc,
	)

/obj/effect/vendor_bundle/vsd/medic
	gear_to_spawn = list(
		/obj/item/bodybag/cryobag,
		/obj/item/defibrillator,
		/obj/item/healthanalyzer,
		/obj/item/roller,
		/obj/item/tweezers,
		/obj/item/clothing/glasses/hud/health,
	)

/obj/effect/vendor_bundle/vsd/specialist
	gear_to_spawn = list(
		/obj/item/clothing/glasses/night/vsd,
		/obj/item/binoculars/tactical/range,
		/obj/item/explosive/plastique,
		/obj/item/explosive/plastique,
	)

/obj/effect/vendor_bundle/vsd/basic
	gear_to_spawn = list(
		/obj/item/clothing/under/vsd,
		/obj/item/clothing/shoes/marine/vsd/full,
		/obj/item/clothing/gloves/marine/veteran/pmc,
		/obj/item/storage/box/MRE/som,
	)


/obj/effect/vendor_bundle/vsd/basic_medic
	gear_to_spawn = list(
		/obj/item/clothing/under/vsd,
		/obj/item/clothing/shoes/marine/vsd/full,
		/obj/item/clothing/gloves/marine/veteran/pmc,
		/obj/item/storage/box/MRE/som,
	)

/obj/effect/vendor_bundle/vsd/basic_engineer
	gear_to_spawn = list(
		/obj/item/clothing/under/vsd/secondary,
		/obj/item/clothing/shoes/marine/vsd/full,
		/obj/item/clothing/gloves/marine/veteran/pmc,
		/obj/item/storage/box/MRE/som,
	)

/obj/effect/vendor_bundle/vsd/basic_specialist
	gear_to_spawn = list(
		/obj/item/clothing/under/vsd/shirt,
		/obj/item/clothing/shoes/marine/vsd/full,
		/obj/item/clothing/gloves/marine/veteran/pmc,
		/obj/item/storage/box/MRE/som,
	)

/obj/effect/vendor_bundle/vsd/basic_leader
	gear_to_spawn = list(
		/obj/item/clothing/under/vsd,
		/obj/item/clothing/shoes/marine/vsd/full,
		/obj/item/clothing/gloves/marine/veteran/pmc,
		/obj/item/storage/box/MRE/som,
	)

/obj/effect/vendor_bundle/vsd/light_armor
	desc = "A set of Crasher multi-threat light ballistic armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/vsd_two,
		/obj/item/clothing/head/helmet/marine/vsd_two,
	)

/obj/effect/vendor_bundle/vsd/medium_armor
	desc = "A set of Crasher multi-threat medium-set ballistic armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/vsd_two/marmor,
		/obj/item/clothing/head/helmet/marine/vsd_two,
	)

/obj/effect/vendor_bundle/vsd/heavy_armor
	desc = "A set of Crasher multi-threat heavy-set ballistic armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/vsd_two/harmor,
		/obj/item/clothing/head/helmet/marine/vsd_two,
	)

/obj/effect/vendor_bundle/vsd/juggernaut_armor
	desc = "A set of Crasher multi-threat 'Juggernaut' ballistic armor, including an armor suit and helmet. Designed for very high protection against ballistic threats."
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/vsd/juggernaut,
		/obj/item/clothing/head/helmet/marine/vsd/juggernaut,
	)

/obj/effect/vendor_bundle/vsd/syndicate_armor
	desc = "A set of Crasher multi-threat 'Syndicate' EOD ballistic armor, including an experimental armor suit and helmet. Designed for extreme explosive resistance."
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/vsd/eod,
		/obj/item/clothing/head/helmet/marine/vsd/eod,
	)

// PMC vendor bundles

/obj/effect/vendor_bundle/pmc/medic
	gear_to_spawn = list(
		/obj/item/bodybag/cryobag,
		/obj/item/defibrillator,
		/obj/item/healthanalyzer,
		/obj/item/roller,
		/obj/item/tweezers,
		/obj/item/explosive/plastique,
		/obj/item/explosive/plastique,
		/obj/item/reagent_containers/hypospray/advanced/nanoblood,
		/obj/item/storage/firstaid/adv,
		/obj/item/clothing/glasses/hud/health,
	)

/obj/effect/vendor_bundle/pmc/engi
	gear_to_spawn = list(
		/obj/item/explosive/plastique,
		/obj/item/cell/high,
		/obj/item/lightreplacer,
		/obj/item/circuitboard/apc,
	)

/obj/effect/vendor_bundle/pmc/sniper
	gear_to_spawn = list(
		/obj/item/clothing/glasses/night/m42_night_goggles,
		/obj/item/binoculars/tactical/range,
	)

/obj/effect/vendor_bundle/pmc/leader
	gear_to_spawn = list(
		/obj/item/clothing/glasses/night/m42_night_goggles,
		/obj/item/binoculars/tactical/range,
		/obj/item/explosive/plastique,
		/obj/item/pinpointer,
	)

/obj/effect/vendor_bundle/pmc/basic
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/veteran/pmc,
		/obj/item/clothing/shoes/marine/pmc/full,
		/obj/item/clothing/gloves/marine/veteran/pmc,
		/obj/item/storage/box/MRE,
	)

/obj/effect/vendor_bundle/pmc/basic_leader
	gear_to_spawn = list(
		/obj/item/clothing/under/marine/veteran/pmc/leader,
		/obj/item/clothing/shoes/marine/pmc/full,
		/obj/item/clothing/gloves/marine/veteran/pmc,
		/obj/item/storage/box/MRE,
	)


/obj/effect/vendor_bundle/pmc/standard_armor
	desc = "A set of standard M4 pattern PMC armor, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/veteran/pmc,
		/obj/item/clothing/head/helmet/marine/veteran/pmc,
	)

/obj/effect/vendor_bundle/pmc/gunner_armor
	desc = "A set of M4 pattern PMC armor that's been modified to carry a smartgun, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/veteran/pmc/gunner,
		/obj/item/clothing/head/helmet/marine/veteran/pmc/gunner,
	)

/obj/effect/vendor_bundle/pmc/sniper_armor
	desc = "A set of M4 pattern PMC armor slightly redesigned for PMC snipers, including an armor suit and helmet."
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/veteran/pmc/sniper,
		/obj/item/clothing/head/helmet/marine/veteran/pmc/sniper,
	)

/obj/effect/vendor_bundle/pmc/leader_armor
	desc = "A set of M4 pattern PMC armor designed for PMC Squad Leaders, including an armor suit and armored beret."
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/veteran/pmc/leader,
		/obj/item/clothing/head/helmet/marine/veteran/pmc/leader,
	)

// ICC vendor bundles

/obj/effect/vendor_bundle/icc/guard
	gear_to_spawn = list(
		/obj/item/binoculars/tactical/range,
		/obj/item/explosive/plastique,
		/obj/item/explosive/plastique,
	)

/obj/effect/vendor_bundle/icc/leader
	gear_to_spawn = list(
		/obj/item/explosive/plastique,
		/obj/item/explosive/plastique,
		/obj/item/explosive/plastique,
		/obj/item/binoculars/tactical/range,
		/obj/item/pinpointer,
		/obj/item/clothing/glasses/hud/health,
	)

/obj/effect/vendor_bundle/icc/basic
	gear_to_spawn = list(
		/obj/item/clothing/under/icc/,
		/obj/item/clothing/shoes/marine/icc/knife,
		/obj/item/clothing/gloves/marine/icc,
		/obj/item/reagent_containers/food/snacks/wrapped/barcaridine,
	)

/obj/effect/vendor_bundle/icc/icc_light
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/icc,
		/obj/item/clothing/head/helmet/marine/icc,
	)

/obj/effect/vendor_bundle/icc/icc_medium
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/icc/guard,
		/obj/item/clothing/head/helmet/marine/icc/guard,
	)

/obj/effect/vendor_bundle/icc/icc_heavy
	gear_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/icc/guard/heavy,
		/obj/item/clothing/head/helmet/marine/icc/guard/heavy,
	)

#undef DEFAULT_TOTAL_BUY_POINTS
#undef MEDIC_TOTAL_BUY_POINTS
#undef ENGINEER_TOTAL_BUY_POINTS
#undef COMMANDER_TOTAL_BUY_POINTS
#undef SQUAD_LOCK
#undef JOB_LOCK

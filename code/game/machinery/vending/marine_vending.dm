///******MARINE VENDOR******///

/obj/machinery/vending/marine
	name = "ColMarTech Automated Weapons rack"
	desc = "A automated weapon rack hooked up to a colossal storage of standard-issue weapons."
	icon_state = "marinearmory"
	icon_vend = "marinearmory-vend"
	icon_deny = "marinearmory"
	req_access = null
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_CARGO)
	wrenchable = FALSE
	tokensupport = TOKEN_MARINE

	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
					/obj/item/weapon/gun/pistol/m4a3 = 25,
					/obj/item/weapon/gun/revolver/m44 = 5,
					/obj/item/weapon/gun/smg/m39 = 20,
					/obj/item/weapon/gun/rifle/m41a = 25,
					/obj/item/weapon/gun/energy/lasgun/M43 = 10,
					/obj/item/weapon/gun/shotgun/pump = 10,
					/obj/item/ammo_magazine/pistol = 30,
					/obj/item/ammo_magazine/revolver = 25,
					/obj/item/ammo_magazine/smg/m39 = 30,
					/obj/item/ammo_magazine/rifle = 22,
					/obj/item/cell/lasgun/M43 = 22,
					/obj/item/ammo_magazine/shotgun = 8,
					/obj/item/ammo_magazine/shotgun/buckshot = 8,
					/obj/item/ammo_magazine/shotgun/flechette = 8,
					/obj/item/weapon/combat_knife = 20,
					/obj/item/weapon/throwing_knife = 5,
					/obj/item/storage/box/m94 = 5,
					/obj/item/attachable/flashlight = 10,
					/obj/item/attachable/bayonet = 10,
					)

	contraband =   list(/obj/item/ammo_magazine/revolver/marksman = 2,
						/obj/item/ammo_magazine/pistol/ap = 2,
						/obj/item/ammo_magazine/smg/m39/ap = 1
						)

	premium = list(
					/obj/item/weapon/gun/rifle/m41aMK1 = 1,
					/obj/item/ammo_magazine/rifle/m41aMK1 = 6
					)

	prices = list()

/obj/machinery/vending/marine/select_gamemode_equipment(gamemode)
	var/products2[]
	switch(SSmapping.config.map_name)
		if(MAP_ICE_COLONY)
			products2 = list(
						/obj/item/clothing/mask/rebreather/scarf = 10,
						/obj/item/clothing/mask/rebreather = 10
							)
	build_inventory(products2)

/obj/machinery/vending/marine/New()
	..()
	GLOB.marine_vendors.Add(src)

/obj/machinery/vending/marine/Destroy()
	. = ..()
	GLOB.marine_vendors.Remove(src)

/obj/machinery/vending/marine/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/weapon/gun) || istype(I, /obj/item/ammo_magazine))
		stock(I, user)
		return TRUE

//What do grenade do against candy machine?
/obj/machinery/vending/marine/ex_act(severity)
	return

/obj/machinery/vending/marine/cargo_guns
	name = "\improper ColMarTech automated armaments vendor"
	desc = "A automated rack hooked up to a small supply of various firearms and explosives."
	wrenchable = FALSE
	products = list(
					/obj/item/storage/backpack/marine/standard = 15,
					/obj/item/storage/belt/marine = 15,
					/obj/item/storage/belt/shotgun = 10,
					/obj/item/clothing/tie/storage/webbing = 3,
					/obj/item/clothing/tie/storage/brown_vest = 1,
					/obj/item/clothing/tie/storage/white_vest/medic = 1,
					/obj/item/clothing/tie/holster = 1,
					/obj/item/storage/belt/gun/m4a3 = 10,
					/obj/item/storage/belt/gun/m44 = 5,
					/obj/item/storage/large_holster/m39 = 5,
					/obj/item/storage/pouch/general/medium = 2,
					/obj/item/storage/pouch/construction = 2,
					/obj/item/storage/pouch/tools = 2,
					/obj/item/storage/pouch/explosive = 2,
					/obj/item/storage/pouch/syringe = 2,
					/obj/item/storage/pouch/medical = 2,
					/obj/item/storage/pouch/medkit = 2,
					/obj/item/storage/pouch/magazine = 5,
					/obj/item/storage/pouch/flare/full = 5,
					/obj/item/storage/pouch/firstaid/full = 5,
					/obj/item/storage/pouch/pistol = 10,
					/obj/item/storage/pouch/magazine/pistol/large = 5,
					/obj/item/storage/pouch/shotgun = 10,
					/obj/item/weapon/gun/pistol/m4a3 = 20,
					/obj/item/weapon/gun/pistol/m1911 = 2,
					/obj/item/weapon/gun/revolver/m44 = 10,
					/obj/item/weapon/gun/smg/m39 = 15,
					/obj/item/weapon/gun/rifle/m41a = 20,
					/obj/item/weapon/gun/shotgun/pump = 10,
					// /obj/item/weapon/gun/shotgun/combat = 1,
					/obj/item/explosive/mine = 2,
					/obj/item/storage/box/nade_box = 1,
					/obj/item/storage/box/nade_box/impact = 1,
					/obj/item/weapon/gun/energy/lasgun/M43 = 5,
					/obj/item/explosive/grenade/frag/m15 = 2,
					/obj/item/explosive/grenade/incendiary = 4,
					/obj/item/explosive/grenade/smokebomb = 5,
					/obj/item/explosive/grenade/cloakbomb = 3,
					/obj/item/storage/box/m94 = 30,
					/obj/item/flashlight/combat = 5,
					/obj/item/clothing/mask/gas = 10
					)

	contraband = list(
					/obj/item/storage/box/nade_box/HIDP = 1,
					/obj/item/storage/box/nade_box/M15 = 1,
					/obj/item/weapon/gun/smg/ppsh = 4,
					/obj/item/weapon/gun/shotgun/double = 2,
					/obj/item/weapon/gun/shotgun/pump/bolt = 2,
					/obj/item/weapon/gun/smg/m39/elite = 0,
					/obj/item/weapon/gun/rifle/m41aMK1 = 0,
					/obj/item/weapon/gun/rifle/m41a/elite = 0,
					/obj/item/weapon/gun/rifle/lmg = 0,
					/obj/item/explosive/grenade/frag = 0,
					/obj/item/explosive/grenade/phosphorus = 0,
					/obj/item/weapon/gun/pistol/holdout = 0,
					/obj/item/weapon/gun/pistol/heavy = 0,
					/obj/item/weapon/gun/pistol/highpower = 0,
					/obj/item/weapon/gun/pistol/vp70 = 0,
					/obj/item/weapon/gun/revolver/small = 0,
					/obj/item/weapon/gun/revolver/cmb = 0,
					/obj/item/weapon/gun/shotgun/merc = 0,
					/obj/item/weapon/gun/shotgun/pump/cmb = 0,
					/obj/item/weapon/gun/smg/mp7 = 0,
					/obj/item/weapon/gun/smg/skorpion = 0,
					/obj/item/weapon/gun/smg/uzi = 0,
					/obj/item/weapon/gun/smg/p90 = 0
					)
	premium = list()



/obj/machinery/vending/marine/cargo_guns/select_gamemode_equipment(gamemode)
	return

/obj/machinery/vending/marine/cargo_guns/New()
	..()
	GLOB.cargo_guns_vendors.Add(src)
	GLOB.marine_vendors.Remove(src)

/obj/machinery/vending/marine/cargo_guns/Destroy()
	. = ..()
	GLOB.cargo_guns_vendors.Remove(src)




/obj/machinery/vending/marine/cargo_ammo
	name = "\improper ColMarTech automated munition vendor"
	desc = "A automated rack hooked up to a small supply of ammo magazines."
	icon_state = "marinerequisitions"
	icon_vend = "marinerequisitions-vend"
	icon_deny = "marinerequisitions"
	wrenchable = FALSE
	products = list(
					/obj/item/storage/large_holster/machete/full = 10,
					/obj/item/ammo_magazine/pistol = 20,
					/obj/item/ammobox/m4a3 = 3,
					/obj/item/ammo_magazine/pistol/ap = 5,
					/obj/item/ammobox/m4a3ap = 3,
					/obj/item/ammo_magazine/pistol/incendiary = 2,
					/obj/item/ammo_magazine/pistol/extended = 10,
					/obj/item/ammobox/m4a3ext = 3,
					/obj/item/ammo_magazine/pistol/m1911 = 10,
					/obj/item/ammo_magazine/revolver = 20,
					/obj/item/ammo_magazine/revolver/marksman = 5,
					/obj/item/ammobox/m39 = 3,
					/obj/item/ammo_magazine/smg/m39 = 15,
					/obj/item/ammobox/m39ap = 1,
					/obj/item/ammo_magazine/smg/m39/ap = 5,
					/obj/item/ammobox/m39ext = 1,
					/obj/item/ammo_magazine/smg/m39/extended = 5,
					/obj/item/ammobox = 3,
					/obj/item/ammo_magazine/rifle = 15,
					/obj/item/ammobox/ext = 1,
					/obj/item/ammo_magazine/rifle/extended = 5,
					/obj/item/ammobox/ap = 1,
					/obj/item/ammo_magazine/rifle/ap = 5,
					/obj/item/ammo_magazine/shotgunbox = 3,
					/obj/item/ammo_magazine/shotgun = 10,
					/obj/item/ammo_magazine/shotgunbox/buckshot = 3,
					/obj/item/ammo_magazine/shotgun/buckshot = 10,
					/obj/item/ammo_magazine/shotgunbox/flechette = 3,
					/obj/item/ammo_magazine/shotgun/flechette = 15,
					/obj/item/cell/lasgun/M43 = 15,
					/obj/item/cell/lasgun/M43/highcap = 1,
					/obj/item/smartgun_powerpack = 2
					)

	contraband = list(
					/obj/item/ammo_magazine/smg/ppsh/ = 20,
					/obj/item/ammo_magazine/smg/ppsh/extended = 4,
					/obj/item/ammo_magazine/rifle/bolt = 10,
					/obj/item/ammo_magazine/sniper = 0,
					/obj/item/ammo_magazine/sniper/incendiary = 0,
					/obj/item/ammo_magazine/sniper/flak = 0,
					/obj/item/ammo_magazine/rifle/m4ra = 0,
					/obj/item/ammo_magazine/rifle/incendiary = 0,
					/obj/item/ammo_magazine/rifle/m41aMK1 = 0,
					/obj/item/ammo_magazine/rifle/lmg = 0,
					/obj/item/ammo_magazine/pistol/hp = 0,
					/obj/item/ammo_magazine/pistol/heavy = 0,
					/obj/item/ammo_magazine/pistol/holdout = 0,
					/obj/item/ammo_magazine/pistol/highpower = 0,
					/obj/item/ammo_magazine/pistol/vp70 = 0,
					/obj/item/ammo_magazine/revolver/small = 0,
					/obj/item/ammo_magazine/revolver/cmb = 0,
					/obj/item/ammo_magazine/smg/mp7 = 0,
					/obj/item/ammo_magazine/smg/skorpion = 0,
					/obj/item/ammo_magazine/smg/uzi = 0,
					/obj/item/ammo_magazine/smg/p90 = 0
					)
	premium = list()


/obj/machinery/vending/marine/cargo_ammo/select_gamemode_equipment(gamemode)
	return

/obj/machinery/vending/marine/cargo_ammo/New()
	..()
	GLOB.cargo_ammo_vendors.Add(src)
	GLOB.marine_vendors.Remove(src)

/obj/machinery/vending/marine/cargo_ammo/Destroy()
	. = ..()
	GLOB.cargo_ammo_vendors.Remove(src)

/obj/machinery/vending/lasgun
	name = "ColMarTech Lasgun Field Charger"
	desc = "An automated power cell dispenser and charger. Used to recharge energy weapon power cells, including in the field. Has an internal battery that charges off the power grid when wrenched down."
	icon_state = "lascharger"
	icon_vend = "lascharger-vend"
	icon_deny = "lascharger-denied"
	req_access = null
	req_one_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	wrenchable = TRUE
	drag_delay = FALSE
	anchored = FALSE
	idle_power_usage = 1
	vend_power_usage = 50
	machine_current_charge = 50000 //integrated battery for recharging energy weapons. Normally 10000.
	machine_max_charge = 50000

	product_ads = "Lasgun running low? Recharge here!;Need a charge?;Power up!;Electrifying!;Empower yourself!"
	products = list(
					/obj/item/cell/lasgun/M43 = 10,
					/obj/item/cell/lasgun/M43/highcap = 2,
					)

	contraband =   list()

	premium = list()

	prices = list()

/obj/machinery/vending/lasgun/New()
	. = ..()
	update_icon()

/obj/machinery/vending/lasgun/update_icon()
	if(machine_max_charge)
		switch(machine_current_charge / max(1,machine_max_charge))
			if(0)
				icon_state = "lascharger-off"
			if(1 to 0.76)
				icon_state = "lascharger"
			if(0.75 to 0.51)
				icon_state = "lascharger_75"
			if(0.50 to 0.26)
				icon_state = "lascharger_50"
			if(0.25 to 0.01)
				icon_state = "lascharger_25"

/obj/machinery/vending/lasgun/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/cell/lasgun))
		stock(I, user, TRUE)
		return TRUE

/obj/machinery/vending/lasgun/examine(mob/user)
	. = ..()
	to_chat(user, "<b>It has [machine_current_charge] of [machine_max_charge] charge remaining.</b>")


/obj/machinery/vending/lasgun/MouseDrop_T(var/atom/movable/A, mob/user)
	. = ..()

	var/obj/item/I = A
	if(istype(I, /obj/item/cell/lasgun))
		stock(I, user, TRUE)
	else
		stock(I, user)

/obj/machinery/vending/lasgun/stock(obj/item/item_to_stock, mob/user, recharge = FALSE)
	var/datum/data/vending_product/R //Let's try with a new datum.
	 //More accurate comparison between absolute paths.
	for(R in (product_records + hidden_records + coin_records))
		if(item_to_stock.type == R.product_path && !istype(item_to_stock,/obj/item/storage)) //Nice try, specialists/engis
			if(istype(item_to_stock, /obj/item/cell/lasgun) && recharge)
				if(!recharge_lasguncell(item_to_stock, user))
					return //Can't recharge so cancel out

			if(item_to_stock.loc == user) //Inside the mob's inventory
				if(item_to_stock.flags_item & WIELDED)
					item_to_stock.unwield(user)
				user.temporarilyRemoveItemFromInventory(item_to_stock)

			if(istype(item_to_stock.loc, /obj/item/storage)) //inside a storage item
				var/obj/item/storage/S = item_to_stock.loc
				S.remove_from_storage(item_to_stock, user.loc)

			qdel(item_to_stock)
			if(!recharge)
				user.visible_message("<span class='notice'>[user] stocks [src] with \a [R.product_name].</span>",
				"<span class='notice'>You stock [src] with \a [R.product_name].</span>")
			R.amount++
			updateUsrDialog()
			break //We found our item, no reason to go on.

/obj/machinery/vending/lasgun/proc/recharge_lasguncell(obj/item/cell/lasgun/A, mob/user)
	var/recharge_cost = (A.maxcharge - A.charge)
	if(recharge_cost > machine_current_charge)
		to_chat(user, "<span class='warning'>[A] cannot be recharged; [src] has inadequate charge remaining: [machine_current_charge] of [machine_max_charge].</span>")
		return FALSE
	else
		to_chat(user, "<span class='warning'>You insert [A] into [src] to be recharged.</span>")
		if(icon_vend)
			flick(icon_vend,src)
		playsound(loc, 'sound/machines/hydraulics_1.ogg', 25, 0, 1)
		machine_current_charge -= min(machine_current_charge, recharge_cost)
		to_chat(user, "<span class='notice'>This dispenser has [machine_current_charge] of [machine_max_charge] remaining.</span>")
		update_icon()
		return TRUE


/obj/machinery/vending/marineFood
	name = "\improper Marine Food and Drinks Vendor"
	desc = "Standard Issue Food and Drinks Vendor, containing standard military food and drinks."
	icon_state = "sustenance"
	wrenchable = FALSE
	products = list(/obj/item/reagent_container/food/snacks/protein_pack = 50,
					/obj/item/reagent_container/food/snacks/mre_pack/meal1 = 15,
					/obj/item/reagent_container/food/snacks/mre_pack/meal2 = 15,
					/obj/item/reagent_container/food/snacks/mre_pack/meal3 = 15,
					/obj/item/reagent_container/food/snacks/mre_pack/meal4 = 15,
					/obj/item/reagent_container/food/snacks/mre_pack/meal6 = 15,
					/obj/item/storage/box/MRE = 10,
					/obj/item/reagent_container/food/drinks/flask = 5)
//Christmas inventory
/*
					/obj/item/reagent_container/food/snacks/mre_pack/xmas1 = 25,
					/obj/item/reagent_container/food/snacks/mre_pack/xmas2 = 25,
					/obj/item/reagent_container/food/snacks/mre_pack/xmas3 = 25)*/
	contraband = list(/obj/item/reagent_container/food/drinks/flask/marine = 10,
					/obj/item/reagent_container/food/snacks/mre_pack/meal5 = 15)
	vend_delay = 15
	//product_slogans = "Standard Issue Marine food!;It's good for you, and not the worst thing in the world.;Just fucking eat it.;"
	product_ads = "Try the cornbread.;Try the pizza.;Try the pasta.;Try the tofu, wimp.;Try the pork."
	req_access_txt = ""


/obj/machinery/vending/MarineMed
	name = "\improper MarineMed"
	desc = "Marine Medical Drug Dispenser - Provided by Nanotrasen Pharmaceuticals Division(TM)"
	icon_state = "marinemed"
	icon_deny = "marinemed-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;All natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_one_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_MEDPREP) //Medics, doctors and researchers can access
	wrenchable = FALSE
	products = list(/obj/item/reagent_container/hypospray/autoinjector/quickclot = 6,
					/obj/item/reagent_container/hypospray/autoinjector/bicaridine = 6,
					/obj/item/reagent_container/hypospray/autoinjector/dexalinplus = 6,
					/obj/item/reagent_container/hypospray/autoinjector/dylovene = 6,
					/obj/item/reagent_container/hypospray/autoinjector/inaprovaline = 6,
					/obj/item/reagent_container/hypospray/autoinjector/kelotane = 6,
					/obj/item/reagent_container/hypospray/autoinjector/oxycodone = 4,
					/obj/item/reagent_container/hypospray/autoinjector/tricordrazine = 8,
					/obj/item/reagent_container/hypospray/autoinjector/hypervene = 4,
					/obj/item/storage/pill_bottle/bicaridine = 3,
					/obj/item/storage/pill_bottle/dexalin = 3,
					/obj/item/storage/pill_bottle/dylovene = 3,
					/obj/item/storage/pill_bottle/kelotane = 3,
					/obj/item/storage/pill_bottle/spaceacillin = 3,
					/obj/item/storage/pill_bottle/inaprovaline = 3,
					/obj/item/storage/pill_bottle/tramadol = 3,
					/obj/item/storage/pill_bottle/russianRed = 5,
					/obj/item/storage/pill_bottle/peridaxon = 2,
					/obj/item/storage/pill_bottle/quickclot = 2,
					/obj/item/storage/pill_bottle/hypervene = 2,
					/obj/item/stack/medical/advanced/bruise_pack = 6,
					/obj/item/stack/medical/bruise_pack = 8,
					/obj/item/stack/medical/advanced/ointment = 6,
					/obj/item/stack/medical/ointment = 8,
					/obj/item/stack/medical/splint = 2,
					/obj/item/healthanalyzer = 3,
					/obj/item/bodybag/cryobag = 2)

	contraband = list(/obj/item/reagent_container/hypospray/autoinjector/sleeptoxin =3)



/obj/machinery/vending/MarineMed/Blood
	name = "\improper MM Blood Dispenser"
	desc = "Marine Med brand Blood Pack Dispensery"
	icon_state = "bloodvendor"
	icon_deny = "bloodvendor-deny"
	product_ads = "The best blood on the market!"
	req_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	products = list(/obj/item/reagent_container/blood/APlus = 5, /obj/item/reagent_container/blood/AMinus = 5,
					/obj/item/reagent_container/blood/BPlus = 5, /obj/item/reagent_container/blood/BMinus = 5,
					/obj/item/reagent_container/blood/OPlus = 5, /obj/item/reagent_container/blood/OMinus = 5,
					/obj/item/reagent_container/blood/empty = 10)
	contraband = list()

/obj/machinery/vending/MarineMed/Blood/build_inventory(productlist[])
	. = ..()
	var/temp_list[] = productlist
	var/obj/item/reagent_container/blood/temp_path
	var/datum/data/vending_product/R
	var/blood_type
	for(R in (product_records + hidden_records + coin_records))
		if(R.product_path in temp_list)
			temp_path = R.product_path
			blood_type = initial(temp_path.blood_type)
			R.product_name += blood_type? " [blood_type]" : ""
			temp_list -= R.product_path
			if(!temp_list.len) break

/obj/machinery/vending/marine_medic
	name = "\improper ColMarTech Medic Vendor"
	desc = "A marine medic equipment vendor"
	product_ads = "They were gonna die anyway.;Let's get space drugged!"
	req_access = list(ACCESS_MARINE_MEDPREP)
	icon_state = "marinemed"
	icon_deny = "marinemed-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/clothing/under/marine/medic = 4,
						/obj/item/clothing/head/helmet/marine/corpsman = 4,
						/obj/item/storage/backpack/marine/corpsman = 4,
						/obj/item/storage/backpack/marine/satchel/corpsman = 4,
						/obj/item/encryptionkey/med = 4,
						/obj/item/storage/belt/medical = 4,
						/obj/item/bodybag/cryobag = 4,
						/obj/item/healthanalyzer = 4,
						/obj/item/clothing/glasses/hud/health = 4,
						/obj/item/storage/firstaid/regular = 4,
						/obj/item/storage/firstaid/adv = 4,
						/obj/item/storage/pouch/medical = 4,
						/obj/item/storage/pouch/medkit = 4,
						/obj/item/storage/pouch/magazine = 4,
						/obj/item/storage/pouch/pistol = 4,
						/obj/item/clothing/mask/gas = 4
					)
	contraband = list(/obj/item/reagent_container/blood/OMinus = 1)


/obj/machinery/vending/marine_special
	name = "\improper ColMarTech Specialist Vendor"
	desc = "A marine specialist equipment vendor"
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_SPECPREP)
	icon_state = "specialist"
	icon_deny = "specialist-deny"
	wrenchable = FALSE
	tokensupport = TOKEN_SPEC

	products = list(
						/obj/item/coin/marine/specialist = 1,
						/obj/item/clothing/tie/storage/webbing = 1,
						/obj/item/explosive/plastique = 2,
						/obj/item/explosive/grenade/frag = 2,
						/obj/item/explosive/grenade/incendiary = 2,
						/obj/item/storage/pouch/magazine/large = 1,
						/obj/item/storage/pouch/general/medium = 1,
						/obj/item/clothing/mask/gas = 1
					)
	contraband = list()
	premium = list(
					/obj/item/storage/box/spec/demolitionist = 1,
					/obj/item/storage/box/spec/heavy_grenadier = 1,
					/obj/item/storage/box/m42c_system = 1,
					/obj/item/storage/box/m42c_system_Jungle = 1,
					/obj/item/storage/box/spec/pyro = 1
					)
	prices = list()


/obj/machinery/vending/shared_vending/marine_special
	name = "\improper ColMarTech Specialist Vendor"
	desc = "A marine specialist equipment vendor"
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_SPECPREP)
	icon_state = "specialist"
	icon_deny = "specialist-deny"
	wrenchable = FALSE
	tokensupport = TOKEN_SPEC

	products = list(
						/obj/item/coin/marine/specialist = 1,
					)
	contraband = list()
	premium = list()
	shared = list(
					/obj/item/storage/box/spec/demolitionist = 1,
					/obj/item/storage/box/spec/heavy_grenadier = 1,
					/obj/item/storage/box/spec/sniper = 1,
					/obj/item/storage/box/spec/scout = 1,
					/obj/item/storage/box/spec/scoutshotgun = 1,
					/obj/item/storage/box/spec/pyro = 1
			)
	prices = list()

/obj/machinery/vending/shared_vending/marine_special/New()

	if(shared_products.len == 0)
		var/i

		for(i in shared)
			shared_products.Add(new /datum/data/vending_product())
	..()

/obj/machinery/vending/shared_vending/marine_engi
	name = "\improper ColMarTech Engineer System Vendor"
	desc = "A marine engineering system vendor"
	product_ads = "If it breaks, wrench it!;If it wrenches, weld it!;If it snips, snip it!"
	req_access = list(ACCESS_MARINE_ENGPREP)
	icon_state = "engiprep"
	icon_deny = "engiprep-deny"
	wrenchable = FALSE
	tokensupport = TOKEN_ENGI

	products = list(
					/obj/item/coin/marine/engineer = 1,
					)
	contraband = list(/obj/item/cell/super = 1)

	premium = list(
					/obj/item/storage/box/sentry = 1,
					/obj/item/storage/box/m56d_hmg = 1
					)
	shared = list(
				/obj/structure/closet/crate/mortar_ammo/mortar_kit = 1,
				)
	prices = list()

/obj/machinery/vending/shared_vending/marine_engi/New()

	if(shared_products.len == 0)
		var/i

		for(i in shared)
			shared_products.Add(new /datum/data/vending_product())
	..()

/obj/machinery/vending/marine_smartgun
	name = "\improper ColMarTech Smartgun Vendor"
	desc = "A marine smartgun equipment vendor"
	hacking_safety = 1
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_SMARTPREP)
	icon_state = "smartgunner"
	icon_deny = "smartgunner-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/clothing/tie/storage/webbing = 1,
						/obj/item/storage/box/m56_system = 1,
						/obj/item/smartgun_powerpack = 1,
						/obj/item/storage/pouch/magazine = 1,
						/obj/item/clothing/mask/gas = 1
			)
	contraband = list()
	premium = list()
	prices = list()

/obj/machinery/vending/marine_leader
	name = "\improper ColMarTech Leader Vendor"
	desc = "A marine leader equipment vendor"
	hacking_safety = 1
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_LEADER)
	icon_state = "squadleader"
	icon_deny = "squadleader-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/clothing/suit/storage/marine/leader = 1,
						/obj/item/clothing/head/helmet/marine/leader = 1,
						/obj/item/clothing/tie/storage/webbing = 1,
						/obj/item/squad_beacon = 3,
						/obj/item/squad_beacon/bomb = 1,
						/obj/item/explosive/plastique = 1,
						/obj/item/explosive/grenade/smokebomb = 3,
						/obj/item/binoculars/tactical = 1,
						/obj/item/motiondetector = 1,
						/obj/item/ammo_magazine/pistol/hp = 2,
						/obj/item/ammo_magazine/pistol/ap = 1,
						/obj/item/storage/backpack/marine/satchel = 2,
						/obj/item/weapon/gun/flamer = 2,
						/obj/item/ammo_magazine/flamer_tank = 8,
						/obj/item/storage/pouch/magazine/large = 1,
						/obj/item/storage/pouch/general/large = 1,
						/obj/item/storage/pouch/pistol = 1,
						/obj/item/clothing/mask/gas = 1,
						/obj/item/whistle = 1,
						/obj/item/storage/box/zipcuffs = 2
					)

/obj/machinery/vending/marine_leader/select_gamemode_equipment(gamemode)
	var/products2[]
	switch(SSmapping.config.map_name)
		if(MAP_ICE_COLONY)
			products2 = list( /obj/item/map/ice_colony_map = 3)
		if(MAP_BIG_RED)
			products2 = list(/obj/item/map/big_red_map = 3)
		if(MAP_WHISKEY_OUTPOST)
			products2 = list(/obj/item/map/whiskey_outpost_map = 3)
		if(MAP_LV_624)
			products2 = list(/obj/item/map/lazarus_landing_map = 3)
	build_inventory(products2)



/obj/machinery/vending/attachments
	name = "\improper Armat Systems Attachments Vendor"
	desc = "A subsidiary-owned vendor of weapon attachments. This can only be accessed by the Requisitions Officer and Cargo Techs."
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_CARGO)
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/attachable/bayonet = 15,
						/obj/item/attachable/compensator = 4,
						/obj/item/attachable/extended_barrel = 8,
						/obj/item/attachable/heavy_barrel = 2,
						/obj/item/attachable/suppressor = 8,

						/obj/item/attachable/flashlight = 20,
						/obj/item/attachable/magnetic_harness = 8,
						/obj/item/attachable/quickfire = 2,
						/obj/item/attachable/reddot = 10,
						/obj/item/attachable/scope = 1,

						/obj/item/attachable/angledgrip = 10,
						/obj/item/attachable/bipod = 4,
						/obj/item/attachable/burstfire_assembly = 2,
						/obj/item/attachable/gyro = 4,
						/obj/item/attachable/lasersight = 10,
						/obj/item/attachable/verticalgrip = 10,

						/obj/item/attachable/stock/smg = 3,
						/obj/item/attachable/stock/revolver = 3,
						/obj/item/attachable/stock/shotgun = 3,
						/obj/item/attachable/stock/rifle = 3 ,
						/obj/item/attachable/stock/tactical = 3,

						/obj/item/attachable/attached_gun/flamer = 3,
						/obj/item/attachable/attached_gun/shotgun = 3,
						/obj/item/attachable/attached_gun/grenade = 5
					)

/obj/machinery/vending/attachments/New()
	..()
	GLOB.attachment_vendors.Add(src)

/obj/machinery/vending/attachments/Destroy()
	. = ..()
	GLOB.attachment_vendors.Remove(src)



/obj/machinery/vending/uniform_supply
	name = "\improper ColMarTech surplus uniform vendor"
	desc = "A automated weapon rack hooked up to a colossal storage of uniforms"
	icon_state = "marineuniform"
	icon_vend = "marineuniform_vend"
	icon_deny = "marineuniform"
	req_access = null
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_CARGO)
	var/squad_tag = ""

	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
					/obj/item/clothing/shoes/marine = 20,
					/obj/item/clothing/under/marine = 20,
					/obj/item/storage/backpack/marine/standard = 10,
					/obj/item/storage/backpack/marine/satchel = 10,
					/obj/item/clothing/suit/storage/marine = 10,
					/obj/item/clothing/suit/storage/marine/M3HB = 10,
					/obj/item/clothing/suit/storage/marine/M3LB = 10,
					/obj/item/clothing/suit/storage/marine/M3P = 10,
					/obj/item/clothing/suit/storage/marine/M3IS = 10,
					/obj/item/clothing/suit/storage/marine/M3E = 10,
					/obj/item/clothing/head/helmet/marine = 20,
					/obj/item/clothing/mask/rebreather/scarf = 10,
					/obj/item/clothing/mask/rebreather = 10,
					/obj/item/clothing/mask/breath = 10,
					/obj/item/tank/emergency_oxygen = 10,
					/obj/item/storage/belt/marine = 10,
					/obj/item/storage/belt/shotgun = 10,
					/obj/item/storage/belt/knifepouch = 10,
					/obj/item/storage/belt/utility/full = 10,
					/obj/item/storage/belt/gun/m4a3 = 10,
					/obj/item/storage/belt/gun/m44 = 10,
					/obj/item/storage/large_holster/m39 = 10,
					/obj/item/storage/large_holster/machete/full = 10,
					/obj/item/storage/belt/sparepouch = 10,
					/obj/item/storage/pouch/pistol = 10,
					/obj/item/storage/pouch/magazine = 10,
					/obj/item/storage/pouch/magazine/pistol = 10,
					/obj/item/storage/pouch/shotgun = 10,
					/obj/item/storage/pouch/firstaid = 10,
					/obj/item/storage/pouch/medkit = 10,
					/obj/item/storage/pouch/flare = 10,
					/obj/item/storage/pouch/construction = 10,
					/obj/item/storage/pouch/tools/full = 10,
					/obj/item/clothing/tie/storage/brown_vest = 10,
					/obj/item/clothing/tie/storage/white_vest/medic = 10,
					/obj/item/clothing/tie/storage/webbing = 10,
					/obj/item/clothing/tie/holster = 10
					)

	prices = list()

/obj/machinery/vending/dress_supply
	name = "\improper ColMarTech dress uniform vendor"
	desc = "A automated weapon rack hooked up to a colossal storage of dress uniforms"
	icon_state = "marineuniform"
	icon_vend = "marineuniform_vend"
	icon_deny = "marineuniform"
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_CARGO)
	product_ads = "Hey! You! Stop looking like a turtle and start looking like a TRUE soldier!;Dress whites, fresh off the ironing board!;Why kill in armor when you can kill in style?;These uniforms are so sharp you'd cut yourself just looking at them!"
	products = list(
					/obj/item/clothing/under/whites = 50,
					/obj/item/clothing/head/white_dress = 50,
					/obj/item/clothing/shoes/white = 50,
					/obj/item/clothing/gloves/white = 50,
					)

/obj/machinery/vending/uniform_supply/New()
	..()
	var/products2[]
	if(squad_tag != null) //probably some better way to slide this in but no sleep is no sleep.
		switch(squad_tag)
			if("Alpha")
				products2 = list(/obj/item/radio/headset/almayer/marine/alpha = 20,
								/obj/item/clothing/gloves/marine/alpha = 10)
			if("Bravo")
				products2 = list(/obj/item/radio/headset/almayer/marine/bravo = 20,
								/obj/item/clothing/gloves/marine/bravo = 10)
			if("Charlie")
				products2 = list(/obj/item/radio/headset/almayer/marine/charlie = 20,
								/obj/item/clothing/gloves/marine/charlie = 10)
			if("Delta")
				products2 = list(/obj/item/radio/headset/almayer/marine/delta = 20,
								/obj/item/clothing/gloves/marine/delta = 10)
	else
		products2 = list(/obj/item/radio/headset/almayer = 10,
						/obj/item/clothing/gloves/marine = 10)
	build_inventory(products2)
	GLOB.marine_vendors.Add(src)


/obj/machinery/vending/uniform_supply/Destroy()
	. = ..()
	GLOB.marine_vendors.Remove(src)



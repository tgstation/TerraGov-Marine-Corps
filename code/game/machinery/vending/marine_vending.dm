//MARINE VENDING - APOPHIS775 - LAST UPDATE - 25JAN2015


///******MARINE VENDOR******///

/obj/machinery/vending/marine
	name = "ColMarTech Automated Weapons rack"
	desc = "A automated weapon rack hooked up to a colossal storage of standard-issue weapons."
	icon_state = "armory"
	icon_vend = "armory-vend"
	icon_deny = "armory"
	req_access = null
	req_access_txt = "0"
	req_one_access = null
	req_one_access_txt = "9;2;21"
	wrenchable = FALSE

	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
					/obj/item/weapon/gun/pistol/m4a3 = 25,
					/obj/item/weapon/gun/revolver/m44 = 5,
					/obj/item/weapon/gun/smg/m39 = 20,
					/obj/item/weapon/gun/rifle/m41a = 25,
					/obj/item/weapon/gun/shotgun/pump = 10,
					/obj/item/ammo_magazine/pistol = 30,
					/obj/item/ammo_magazine/revolver = 25,
					/obj/item/ammo_magazine/smg/m39 = 30,
					/obj/item/ammo_magazine/rifle = 22,
					/obj/item/ammo_magazine/shotgun = 8,
					/obj/item/ammo_magazine/shotgun/buckshot = 8,
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
	switch(map_tag)
		if(MAP_ICE_COLONY)
			products2 = list(
						/obj/item/clothing/mask/rebreather/scarf = 10,
							)
	build_inventory(products2)

/obj/machinery/vending/marine/New()
	..()
	marine_vendors.Add(src)

/obj/machinery/vending/marine/Dispose()
	. = ..()
	marine_vendors.Remove(src)

/obj/machinery/vending/marine/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/gun))
		stock(W, user)
		return TRUE
	if(istype(W, /obj/item/ammo_magazine))
		stock(W, user)
		return TRUE
	. = ..()

//What do grenade do against candy machine?
/obj/machinery/vending/marine/ex_act(severity)
	return

/obj/machinery/vending/marine/cargo_guns
	name = "\improper ColMarTech automated armaments vendor"
	desc = "A automated rack hooked up to a small supply of various firearms and explosives."
	hacking_safety = 1
	wrenchable = FALSE
	products = list(
					/obj/item/storage/backpack/marine = 10,
					/obj/item/storage/belt/marine = 10,
					/obj/item/storage/belt/shotgun = 6,
					/obj/item/clothing/tie/storage/webbing = 3,
					/obj/item/clothing/tie/storage/brown_vest = 0,
					/obj/item/clothing/tie/holster = 0,
					/obj/item/storage/belt/gun/m4a3 = 5,
					/obj/item/storage/belt/gun/m44 = 3,
					/obj/item/storage/large_holster/m39 = 3,
					/obj/item/storage/pouch/general/medium = 1,
					/obj/item/storage/pouch/construction = 1,
					/obj/item/storage/pouch/tools = 1,
					/obj/item/storage/pouch/explosive = 1,
					/obj/item/storage/pouch/syringe = 1,
					/obj/item/storage/pouch/medical = 1,
					/obj/item/storage/pouch/medkit = 1,
					/obj/item/storage/pouch/magazine = 1,
					/obj/item/storage/pouch/flare/full = 3,
					/obj/item/storage/pouch/firstaid/full = 3,
					/obj/item/storage/pouch/pistol = 10,
					/obj/item/storage/pouch/magazine/pistol/large = 1,
					/obj/item/weapon/gun/pistol/m4a3 = 5,
					/obj/item/weapon/gun/pistol/m1911 = 1,
					/obj/item/weapon/gun/revolver/m44 = 5,
					/obj/item/weapon/gun/smg/m39 = 10,
					/obj/item/weapon/gun/smg/m39/elite = 0,
					/obj/item/weapon/gun/rifle/m41aMK1 = 0,
					/obj/item/weapon/gun/rifle/m41a = 10,
					/obj/item/weapon/gun/rifle/m41a/elite = 0,
					/obj/item/weapon/gun/rifle/lmg = 0,
					/obj/item/weapon/gun/shotgun/pump = 5,
					/obj/item/weapon/gun/shotgun/combat = 0,
					/obj/item/explosive/mine = 1,
					/obj/item/storage/box/nade_box = 4,
					/obj/item/explosive/grenade/frag = 1,
					/obj/item/explosive/grenade/frag/m15 = 1,
					/obj/item/explosive/grenade/incendiary = 1,
					/obj/item/explosive/grenade/smokebomb = 1,
					/obj/item/explosive/grenade/phosphorus = 0,
					/obj/item/storage/box/m94 = 8,
					/obj/item/storage/box/zipcuffs = 4,
					/obj/item/device/flashlight/combat = 5,
					/obj/item/clothing/mask/gas = 10
					)

	contraband = list(
					/obj/item/weapon/gun/pistol/holdout = 0,
					/obj/item/weapon/gun/pistol/heavy = 0,
					/obj/item/weapon/gun/pistol/highpower = 0,
					/obj/item/weapon/gun/pistol/vp70 = 0,
					/obj/item/weapon/gun/revolver/small = 0,
					/obj/item/weapon/gun/revolver/cmb = 0,
					/obj/item/weapon/gun/shotgun/merc = 0,
					/obj/item/weapon/gun/shotgun/pump/cmb = 0,
					/obj/item/weapon/gun/shotgun/double = 0,
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
	cargo_guns_vendors.Add(src)
	marine_vendors.Remove(src)

/obj/machinery/vending/marine/cargo_guns/Dispose()
	. = ..()
	cargo_guns_vendors.Remove(src)




/obj/machinery/vending/marine/cargo_ammo
	name = "\improper ColMarTech automated munition vendor"
	desc = "A automated rack hooked up to a small supply of ammo magazines."
	hacking_safety = 1
	wrenchable = FALSE
	products = list(
					///obj/item/weapon/claymore/mercsword/machete = 5,
					/obj/item/storage/large_holster/machete/full = 6,
					/obj/item/ammo_magazine/pistol = 10,
					/obj/item/ammo_magazine/pistol/hp = 0,
					/obj/item/ammo_magazine/pistol/ap = 3,
					/obj/item/ammo_magazine/pistol/incendiary = 1,
					/obj/item/ammo_magazine/pistol/extended = 1,
					/obj/item/ammo_magazine/pistol/m1911 = 1,
					/obj/item/ammo_magazine/revolver = 10,
					/obj/item/ammo_magazine/revolver/marksman = 2,
					/obj/item/ammo_magazine/smg/m39 = 15,
					/obj/item/ammo_magazine/smg/m39/ap = 5,
					/obj/item/ammo_magazine/smg/m39/extended = 1,
					/obj/item/ammo_magazine/rifle = 15,
					/obj/item/ammo_magazine/rifle/extended = 1,
					/obj/item/ammo_magazine/rifle/incendiary = 1,
					/obj/item/ammo_magazine/rifle/ap = 10,
					/obj/item/ammo_magazine/rifle/m4ra = 1,
					/obj/item/ammo_magazine/rifle/m41aMK1 = 0,
					/obj/item/ammo_magazine/rifle/lmg = 0,
					/obj/item/ammo_magazine/shotgun = 5,
					/obj/item/ammo_magazine/shotgun/buckshot = 5,
					/obj/item/ammo_magazine/shotgun/flechette = 5,
					/obj/item/ammo_magazine/sniper = 1,
					/obj/item/ammo_magazine/sniper/incendiary = 1,
					/obj/item/ammo_magazine/sniper/flak = 1,
					/obj/item/smartgun_powerpack = 0
					)

	contraband = list(
					/obj/item/ammo_magazine/pistol/incendiary = 0,
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
	cargo_ammo_vendors.Add(src)
	marine_vendors.Remove(src)

/obj/machinery/vending/marine/cargo_ammo/Dispose()
	. = ..()
	cargo_ammo_vendors.Remove(src)




//MARINE FOOD VENDOR APOPHIS775 23DEC2017
/obj/machinery/vending/marineFood
	name = "\improper Marine Food and Drinks Vendor"
	desc = "Standard Issue Food and Drinks Vendor, containing standard military food and drinks."
	icon_state = "generic"
	icon_deny = "generic-deny"
	wrenchable = FALSE
	products = list(/obj/item/reagent_container/food/snacks/protein_pack = 50,
					/obj/item/reagent_container/food/snacks/mre_pack/meal1 = 15,
					/obj/item/reagent_container/food/snacks/mre_pack/meal2 = 15,
					/obj/item/reagent_container/food/snacks/mre_pack/meal3 = 15,
					/obj/item/reagent_container/food/snacks/mre_pack/meal4 = 15,
					/obj/item/reagent_container/food/snacks/mre_pack/meal5 = 15,
					/obj/item/reagent_container/food/snacks/mre_pack/meal6 = 15,
					/obj/item/reagent_container/food/drinks/flask = 5)
//Christmas inventory
/*
					/obj/item/reagent_container/food/snacks/mre_pack/xmas1 = 25,
					/obj/item/reagent_container/food/snacks/mre_pack/xmas2 = 25,
					/obj/item/reagent_container/food/snacks/mre_pack/xmas3 = 25)*/
	contraband = list(/obj/item/reagent_container/food/drinks/flask/marine = 10)
	vend_delay = 15
	//product_slogans = "Standard Issue Marine food!;It's good for you, and not the worst thing in the world.;Just fucking eat it.;"
	product_ads = "Try the cornbread.;Try the pizza.;Try the pasta.;Try the tofu, wimp.;Try the pork."
	req_access_txt = ""


//MARINE MEDICAL VENDOR -APOPHIS775 31JAN2017
/obj/machinery/vending/MarineMed
	name = "\improper MarineMed"
	desc = "Marine Medical Drug Dispenser - Provided by Weyland-Yutani Pharmaceuticals Division(TM)"
	icon_state = "marinemed"
	icon_deny = "marinemed-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY) //only doctors and researchers can access these
	wrenchable = FALSE
	products = list(/obj/item/reagent_container/hypospray/autoinjector/quickclot = 6,
					/obj/item/reagent_container/hypospray/autoinjector/Bicard = 6,
					/obj/item/reagent_container/hypospray/autoinjector/dexP = 6,
					/obj/item/reagent_container/hypospray/autoinjector/Dylovene = 6,
					/obj/item/reagent_container/hypospray/autoinjector/Inaprovaline = 6,
					/obj/item/reagent_container/hypospray/autoinjector/Kelo = 6,
					/obj/item/reagent_container/hypospray/autoinjector/Oxycodone = 4,
					/obj/item/reagent_container/hypospray/autoinjector/tricord = 8,
					/obj/item/storage/pill_bottle/bicaridine = 3,
					/obj/item/storage/pill_bottle/dexalin = 3,
					/obj/item/storage/pill_bottle/antitox = 3,
					/obj/item/storage/pill_bottle/kelotane = 3,
					/obj/item/storage/pill_bottle/spaceacillin = 3,
					/obj/item/storage/pill_bottle/inaprovaline = 3,
					/obj/item/storage/pill_bottle/tramadol = 3,
					/obj/item/storage/pill_bottle/russianRed = 5,
					/obj/item/storage/pill_bottle/peridaxon = 2,
					/obj/item/storage/pill_bottle/quickclot = 2,
					/obj/item/stack/medical/advanced/bruise_pack = 6,
					/obj/item/stack/medical/bruise_pack = 8,
					/obj/item/stack/medical/advanced/ointment = 6,
					/obj/item/stack/medical/ointment = 8,
					/obj/item/stack/medical/splint = 2,
					/obj/item/device/healthanalyzer = 3,
					/obj/item/bodybag/cryobag = 2)

	contraband = list(/obj/item/reagent_container/hypospray/autoinjector/chloralhydrate =3)



//NEW BLOOD VENDOR CODE - APOPHIS775 22JAN2015
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
	icon_state = "medicprepvendor"
	icon_deny = "medicprepvendor-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/clothing/under/marine/medic = 4,
						/obj/item/clothing/head/helmet/marine/medic = 4,
						/obj/item/storage/backpack/marine/medic = 4,
						/obj/item/storage/backpack/marine/satchel/medic = 4,
						/obj/item/device/encryptionkey/med = 4,
						/obj/item/storage/belt/medical = 4,
						/obj/item/bodybag/cryobag = 4,
						/obj/item/device/healthanalyzer = 4,
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
	hacking_safety = 1
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_SPECPREP)
	icon_state = "boozeomat"
	icon_deny = "boozeomat-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/coin/marine = 1,
						/obj/item/clothing/tie/storage/webbing = 1,
						/obj/item/explosive/plastique = 2,
						/obj/item/explosive/grenade/frag = 2,
						/obj/item/explosive/grenade/incendiary = 2,
//						/obj/item/weapon/gun/flamer = 1,
//						/obj/item/tank/phoron/m240 = 3,
						///obj/item/weapon/shield/riot = 1,
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
	hacking_safety = 1
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_SPECPREP)
	icon_state = "boozeomat"
	icon_deny = "boozeomat-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/coin/marine = 1,
			)
	contraband = list()
	//premium = list(/obj/item/weapon/shield/riot = 1)	//NOTE: This needs to be re-worked so we don't have to have a riot shield in here at all. ~Bmc777
	shared = list(
					/obj/item/storage/box/spec/demolitionist = 1,
					/obj/item/storage/box/spec/heavy_grenadier = 1,
					/obj/item/storage/box/spec/sniper = 1,
					/obj/item/storage/box/spec/scout = 1,
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
	icon_state = "tool"
	icon_deny = "tool-deny"
	wrenchable = FALSE
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
	icon_state = "boozeomat"
	icon_deny = "boozeomat-deny"
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
	icon_state = "tool"
	icon_deny = "tool-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/clothing/suit/storage/marine/leader = 1,
						/obj/item/clothing/head/helmet/marine/leader = 1,
						/obj/item/clothing/tie/storage/webbing = 1,
						/obj/item/device/squad_beacon = 3,
						/obj/item/device/squad_beacon/bomb = 1,
						/obj/item/explosive/plastique = 1,
						/obj/item/explosive/grenade/smokebomb = 3,
						/obj/item/device/binoculars/tactical = 1,
						/obj/item/device/motiondetector = 1,
						/obj/item/ammo_magazine/pistol/hp = 2,
						/obj/item/ammo_magazine/pistol/ap = 1,
						/obj/item/storage/backpack/marine/satchel = 2,
						/obj/item/weapon/gun/flamer = 2,
						/obj/item/ammo_magazine/flamer_tank = 8,
						/obj/item/storage/pouch/magazine/large = 1,
						/obj/item/storage/pouch/general/large = 1,
						/obj/item/storage/pouch/pistol = 1,
						/obj/item/clothing/mask/gas = 1,
						/obj/item/device/whistle = 1,
						/obj/item/storage/box/zipcuffs = 2
					)

/obj/machinery/vending/marine_leader/select_gamemode_equipment(gamemode)
	var/products2[]
	switch(map_tag)
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
	hacking_safety = 1
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_CARGO)
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/attachable/suppressor = 8,
						/obj/item/attachable/bayonet = 15,
						/obj/item/attachable/compensator = 4,
						/obj/item/attachable/extended_barrel = 8,
						/obj/item/attachable/heavy_barrel = 2,

						/obj/item/attachable/scope = 1,
						/obj/item/attachable/flashlight = 20,
						/obj/item/attachable/reddot = 10,
						/obj/item/attachable/magnetic_harness = 8,
						/obj/item/attachable/quickfire = 2,

						/obj/item/attachable/verticalgrip = 10,
						/obj/item/attachable/angledgrip = 10,
						/obj/item/attachable/lasersight = 10,
						/obj/item/attachable/gyro = 4,
						/obj/item/attachable/bipod = 4,
						/obj/item/attachable/burstfire_assembly = 2,

						/obj/item/attachable/stock/shotgun = 3,
						/obj/item/attachable/stock/rifle = 3 ,
						/obj/item/attachable/stock/revolver = 3,
						/obj/item/attachable/stock/smg = 3,

						/obj/item/attachable/attached_gun/grenade = 5,
						/obj/item/attachable/attached_gun/shotgun = 3,
						/obj/item/attachable/attached_gun/flamer = 3
					)

/obj/machinery/vending/attachments/New()
	..()
	attachment_vendors.Add(src)

/obj/machinery/vending/attachments/Dispose()
	. = ..()
	attachment_vendors.Remove(src)



/obj/machinery/vending/uniform_supply
	name = "\improper ColMarTech surplus uniform vendor"
	desc = "A automated weapon rack hooked up to a colossal storage of uniforms"
	icon_state = "uniform_marine"
	icon_vend = "uniform_marine_vend"
	icon_deny = "uniform_marine"
	req_access = null
	req_access_txt = "0"
	req_one_access = null
	req_one_access_txt = "9;2;21"
	var/squad_tag = ""

	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
					/obj/item/storage/backpack/marine = 10,
					/obj/item/storage/backpack/marine/satchel = 10,
					/obj/item/storage/belt/marine = 10,
					/obj/item/clothing/shoes/marine = 20,
					/obj/item/clothing/under/marine = 20,
					/obj/item/clothing/suit/storage/marine = 20,
					/obj/item/clothing/head/helmet/marine = 20,
					/obj/item/clothing/mask/rebreather/scarf = 10,
					)

	prices = list()

/obj/machinery/vending/uniform_supply/New()
	..()
	var/products2[]
	if(squad_tag != null) //probably some better way to slide this in but no sleep is no sleep.
		switch(squad_tag)
			if("Alpha")
				products2 = list(/obj/item/device/radio/headset/almayer/marine/alpha = 20,
								/obj/item/clothing/gloves/marine/alpha = 10)
			if("Bravo")
				products2 = list(/obj/item/device/radio/headset/almayer/marine/bravo = 20,
								/obj/item/clothing/gloves/marine/bravo = 10)
			if("Charlie")
				products2 = list(/obj/item/device/radio/headset/almayer/marine/charlie = 20,
								/obj/item/clothing/gloves/marine/charlie = 10)
			if("Delta")
				products2 = list(/obj/item/device/radio/headset/almayer/marine/delta = 20,
								/obj/item/clothing/gloves/marine/delta = 10)
	else
		products2 = list(/obj/item/device/radio/headset/almayer = 10,
						/obj/item/clothing/gloves/marine = 10)
	build_inventory(products2)
	marine_vendors.Add(src)


/obj/machinery/vending/uniform_supply/Dispose()
	. = ..()
	marine_vendors.Remove(src)



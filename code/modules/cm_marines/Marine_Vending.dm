//MARINE VENDING - APOPHIS775 - LAST UPDATE - 25JAN2015


///******MARINE VENDOR******///

/obj/machinery/vending/marine
	name = "ColMarTech Automated Weapons rack"
	desc = "A automated weapon rack hooked up to a colossal storage of standard-issue weapons and armor."
	icon_state = "armory"
	icon_vend = "armory-vend"
	icon_deny = "armory"
	req_access = null
	req_access_txt = "0"
	req_one_access = null
	req_one_access_txt = "9;2;21"

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
					/obj/item/ammo_magazine/rifle/ap = 5,
					/obj/item/ammo_magazine/shotgun = 8,
					/obj/item/ammo_magazine/shotgun/buckshot = 8,

					/obj/item/weapon/combat_knife = 20,
					/obj/item/weapon/throwing_knife = 5,
					/obj/item/weapon/storage/box/m94 = 5,
					/obj/item/weapon/storage/backpack/marine = 10,
					/obj/item/device/radio/headset/msulaco = 5,
					/obj/item/weapon/storage/belt/marine = 5,
					/obj/item/weapon/storage/belt/knifepouch = 5,
					/obj/item/weapon/storage/belt/gun/m4a3 = 5,
					/obj/item/weapon/large_holster/m37 = 5,
					/obj/item/clothing/shoes/marine = 5,
					/obj/item/clothing/under/marine = 10,
					/obj/item/clothing/suit/storage/marine = 10,
					/obj/item/clothing/head/helmet/marine = 10
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

	select_gamemode_equipment(gamemode)
		var/products2[]
		switch(gamemode)
			if(/datum/game_mode/ice_colony)
				products2 = list(
							/obj/item/clothing/mask/rebreather/scarf = 10,
								)
			if(/datum/game_mode/bigred)
				products2 = list(
							/obj/item/clothing/mask/gas/ = 20,
								)
		build_inventory(products2)

	New()

		..()

		marine_vendors.Add(src)

/obj/machinery/vending/marine/cargo_guns
	name = "\improper ColMarTech automated armaments vendor"
	desc = "A automated rack hooked up to a small supply of various firearms and explosives."
	hacking_safety = 1
	products = list(
					/obj/item/weapon/storage/backpack/marine = 10,
					/obj/item/weapon/storage/belt/marine = 10,
					/obj/item/clothing/tie/storage/webbing = 3,
					/obj/item/clothing/tie/storage/brown_vest = 0,
					/obj/item/clothing/tie/holster = 0,
					/obj/item/weapon/storage/belt/gun/m4a3 = 5,
					/obj/item/weapon/storage/belt/gun/m44 = 3,
					/obj/item/weapon/storage/belt/gun/m39 = 3,
					/obj/item/weapon/gun/pistol/m4a3 = 5,
					/obj/item/weapon/gun/pistol/m1911 = 1,
					/obj/item/weapon/gun/revolver/m44 = 5,
					/obj/item/weapon/gun/smg/m39 = 10,
					/obj/item/weapon/gun/smg/m39/elite = 0,
					/obj/item/weapon/gun/rifle/m41aMK1 = 0,
					/obj/item/weapon/gun/rifle/m41a = 10,
					/obj/item/weapon/gun/rifle/m41a/scoped = 0,
					/obj/item/weapon/gun/rifle/m41a/elite = 0,
					/obj/item/weapon/gun/rifle/lmg = 0,
					/obj/item/weapon/gun/shotgun/pump = 5,
					/obj/item/weapon/gun/shotgun/combat = 0,
					/obj/item/device/mine = 0,
					/obj/item/weapon/grenade/explosive = 0,
					/obj/item/weapon/grenade/explosive/m40 = 0,
					/obj/item/weapon/grenade/incendiary = 0,
					/obj/item/weapon/grenade/smokebomb = 0,
					/obj/item/weapon/grenade/phosphorus = 0,
					/obj/item/device/flashlight/ = 5
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
	select_gamemode_equipment()

	New()

		..()

		marine_vendors.Remove(src)

/obj/machinery/vending/marine/cargo_ammo
	name = "\improper ColMarTech automated munition vendor"
	desc = "A automated rack hooked up to a small supply of ammo magazines."
	hacking_safety = 1
	products = list(
					///obj/item/weapon/claymore/mercsword/machete = 5,
					/obj/item/weapon/large_holster/machete/full = 6,
					/obj/item/ammo_magazine/pistol = 10,
					/obj/item/ammo_magazine/pistol/hp = 0,
					/obj/item/ammo_magazine/pistol/ap = 0,
					/obj/item/ammo_magazine/pistol/incendiary = 0,
					/obj/item/ammo_magazine/pistol/extended = 0,
					/obj/item/ammo_magazine/pistol/m1911 = 0,
					/obj/item/ammo_magazine/revolver = 10,
					/obj/item/ammo_magazine/revolver/marksman = 0,
					/obj/item/ammo_magazine/smg/m39 = 15,
					/obj/item/ammo_magazine/smg/m39/ap = 0,
					/obj/item/ammo_magazine/smg/m39/extended = 0,
					/obj/item/ammo_magazine/rifle = 15,
					/obj/item/ammo_magazine/rifle/extended = 0,
					/obj/item/ammo_magazine/rifle/incendiary = 0,
					/obj/item/ammo_magazine/rifle/ap = 0,
					/obj/item/ammo_magazine/rifle/marksman = 0,
					/obj/item/ammo_magazine/rifle/m41aMK1 = 0,
					/obj/item/ammo_magazine/rifle/lmg = 0,
					/obj/item/ammo_magazine/shotgun = 5,
					/obj/item/ammo_magazine/shotgun/buckshot = 5,
					/obj/item/ammo_magazine/sniper = 0,
					/obj/item/ammo_magazine/sniper/incendiary = 0,
					/obj/item/ammo_magazine/sniper/flak = 0,
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
	select_gamemode_equipment()

	New()

		..()

		marine_vendors.Remove(src)

//MARINE FOOD VENDOR APOPHIS775 22DEC2015
/obj/machinery/vending/marineFood
	name = "\improper Marine Food and Drinks Vendor"
	desc = "Standard Issue Food and Drinks Vendor, containing standard military food and drinks."
	icon_state = "generic"
	icon_deny = "generic-deny"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/protein_pack = 50,
					/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal1 = 15,
					/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal2 = 15,
					/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal3 = 15,
					/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal4 = 15,
					/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal5 = 15,
					/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal6 = 15,
					/obj/item/weapon/reagent_containers/food/drinks/flask = 5)
//Christmas inventory
/*					/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas1 = 25,
					/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas2 = 25,
					/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas3 = 25)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/flask/marine = 10)*/
	vend_delay = 15
	//product_slogans = "Standard Issue Marine food!;It's good for you, and not the worst thing in the world.;Just fucking eat it.;"
	product_ads = "Try the cornbread.;Try the pizza.;Try the pasta.;Try the tofu, wimp.;Try the pork."
	req_access_txt = ""


//MARINE MEDICAL VENDOR -APOPHIS775 31JAN2017
/obj/machinery/vending/MarineMed
	name = "\improper MarineMed"
	desc = "Marine Medical Drug Dispenser - Provided by Weyland-Yutani Pharmaceuticals Division(TM)"
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access = list(ACCESS_MARINE_MEDBAY)
	products = list(/obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot = 5,
					/obj/item/weapon/reagent_containers/hypospray/autoinjector/Bicard = 5,
					/obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP = 5,
					/obj/item/weapon/reagent_containers/hypospray/autoinjector/Dylovene = 5,
					/obj/item/weapon/reagent_containers/hypospray/autoinjector/Inaprovaline = 5,
					/obj/item/weapon/reagent_containers/hypospray/autoinjector/Kelo = 5,
					/obj/item/weapon/reagent_containers/hypospray/autoinjector/Oxycodone = 4,
					/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord = 5,
					/obj/item/weapon/storage/pill_bottle/bicaridine = 3,
					/obj/item/weapon/storage/pill_bottle/dexalin = 3,
					/obj/item/weapon/storage/pill_bottle/antitox = 3,
					/obj/item/weapon/storage/pill_bottle/kelotane = 3,
					/obj/item/weapon/storage/pill_bottle/spaceacillin = 3,
					/obj/item/weapon/storage/pill_bottle/inaprovaline = 3,
					/obj/item/weapon/storage/pill_bottle/tramadol = 3,
					/obj/item/weapon/storage/pill_bottle/russianRed = 5,
					/obj/item/stack/medical/advanced/bruise_pack = 4,
					/obj/item/stack/medical/bruise_pack = 8,
					/obj/item/stack/medical/advanced/ointment = 4,
					/obj/item/stack/medical/ointment = 8,
					/obj/item/stack/medical/splint = 2,
					/obj/item/device/healthanalyzer = 3,
					/obj/item/bodybag/cryobag = 2)

	contraband = list(/obj/item/weapon/reagent_containers/hypospray/autoinjector/chloralhydrate =3)



//NEW BLOOD VENDOR CODE - APOPHIS775 22JAN2015
/obj/machinery/vending/MarineMed/Blood
	name = "\improper MM Blood Dispenser"
	desc = "Marine Med brand Blood Pack Dispensery"
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "The best blood on the market!"
	req_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	products = list(/obj/item/weapon/reagent_containers/blood/APlus = 5, /obj/item/weapon/reagent_containers/blood/AMinus = 5,
					/obj/item/weapon/reagent_containers/blood/BPlus = 5, /obj/item/weapon/reagent_containers/blood/BMinus = 5,
					/obj/item/weapon/reagent_containers/blood/OPlus = 5, /obj/item/weapon/reagent_containers/blood/OMinus = 5,
					/obj/item/weapon/reagent_containers/blood/empty = 10)
	contraband = list()

	build_inventory(productlist[])
		. = ..()
		var/temp_list[] = productlist
		var/obj/item/weapon/reagent_containers/blood/temp_path
		var/datum/data/vending_product/R
		var/blood_type
		for(R in (product_records + hidden_records + coin_records))
			if(R.product_path in temp_list)
				temp_path = R.product_path
				blood_type = initial(temp_path.blood_type)
				R.product_name += blood_type? " [blood_type]" : ""
				temp_list -= R.product_path
				if(!temp_list.len) break

/obj/machinery/vending/marine_engi
	name = "\improper ColMarTech Engineer Vendor"
	desc = "A marine engineering equipment vendor"
	product_ads = "If it breaks, wrench it!;If it wrenches, weld it!;If it snips, snip it!"
	req_access = list(ACCESS_MARINE_ENGPREP)
	icon_state = "tool"
	icon_deny = "tool-deny"
	products = list(
						/obj/item/weapon/coin/marine/engineer = 1,
						/obj/item/clothing/under/marine/engineer = 3,
						/obj/item/clothing/head/helmet/marine/tech = 2,
						/obj/item/weapon/storage/backpack/marine/tech = 4,
						/obj/item/weapon/storage/backpack/marine/satchel/tech = 2,
						/obj/item/weapon/storage/backpack/marine/engineerpack = 2,
						/obj/item/clothing/tie/storage/webbing = 3,
						/obj/item/device/encryptionkey/headset_eng = 3,
						/obj/item/weapon/storage/belt/utility/full = 3,
						/obj/item/clothing/gloves/yellow = 3,
						/obj/item/clothing/glasses/meson = 3,
						/obj/item/device/multitool = 4,
						/obj/item/weapon/grenade/incendiary = 2,
						/obj/item/weapon/storage/box/explosive_mines = 1,
						/obj/item/clothing/glasses/welding = 3,
						/obj/item/weapon/plastique = 4,
						/obj/item/device/lightreplacer = 2,
						/obj/item/weapon/airlock_electronics = 10,
						/obj/item/weapon/module/power_control = 10,
						/obj/item/weapon/airalarm_electronics = 10,
						/obj/item/weapon/cell/high = 10,
						/obj/item/weapon/etool = 3
					)
	contraband = list(/obj/item/weapon/cell/super = 1)

	premium = list(
					/obj/item/weapon/storage/box/sentry = 1,
					/obj/item/weapon/storage/box/m56d_hmg = 1
					)

/obj/machinery/vending/marine_medic
	name = "\improper ColMarTech Medic Vendor"
	desc = "A marine medic equipment vendor"
	product_ads = "They were gonna die anyway.;Let's get space drugged!"
	req_access = list(ACCESS_MARINE_MEDPREP)
	icon_state = "med"
	icon_deny = "med-deny"

	products = list(
						/obj/item/clothing/under/marine/medic = 3,
						/obj/item/clothing/head/helmet/marine/medic = 2,
						/obj/item/weapon/storage/backpack/marine/medic = 4,
						/obj/item/weapon/storage/backpack/marine/satchel/medic = 2,
						/obj/item/device/encryptionkey/headset_med = 3,
						/obj/item/weapon/storage/belt/medical/combatLifesaver = 3,
						/obj/item/weapon/storage/belt/medical = 3,
						/obj/item/clothing/tie/storage/webbing = 2,
						/obj/item/weapon/melee/defibrillator = 3,
						/obj/item/bodybag/cryobag = 4,
						/obj/item/device/healthanalyzer = 3,
						/obj/item/clothing/glasses/hud/health = 3,
						/obj/item/weapon/storage/firstaid/regular = 4,
						/obj/item/weapon/storage/firstaid/adv = 3
					)
	contraband = list(/obj/item/weapon/reagent_containers/blood/OMinus = 1)


/obj/machinery/vending/marine_special
	name = "\improper ColMarTech Specialist Vendor"
	desc = "A marine specialist equipment vendor"
	hacking_safety = 1
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_SPECPREP)
	icon_state = "boozeomat"
	icon_deny = "boozeomat-deny"

	products = list(
						/obj/item/weapon/coin/marine = 1,
						/obj/item/clothing/tie/storage/webbing = 1,
						/obj/item/weapon/plastique = 2,
						/obj/item/weapon/grenade/explosive = 2,
						/obj/item/weapon/grenade/incendiary = 2,
//						/obj/item/weapon/flamethrower/full = 1,
//						/obj/item/weapon/tank/phoron/m240 = 3,
						/obj/item/weapon/shield/riot = 1,
						/obj/item/smartgun_powerpack = 1
			)
	contraband = list()
	premium = list(
					/obj/item/weapon/storage/box/rocket_system = 1,
					/obj/item/weapon/storage/box/grenade_system = 1,
					/obj/item/weapon/storage/box/m42c_system = 1,
					/obj/item/weapon/storage/box/m42c_system_Jungle = 1,
					/obj/item/weapon/storage/box/m56_system = 1,
					/obj/item/weapon/storage/box/heavy_armor = 1
			)
	prices = list()

/obj/machinery/vending/marine_leader
	name = "\improper ColMarTech Leader Vendor"
	desc = "A marine leader equipment vendor"
	hacking_safety = 1
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_LEADER)
	icon_state = "tool"
	icon_deny = "tool-deny"

	products = list(
						/obj/item/clothing/suit/storage/marine/leader = 1,
						/obj/item/clothing/head/helmet/marine/leader = 1,
						/obj/item/clothing/tie/storage/webbing = 1,
						/obj/item/device/squad_beacon = 3,
						/obj/item/device/squad_beacon/bomb = 1,
						/obj/item/weapon/plastique = 1,
						/obj/item/weapon/grenade/smokebomb = 3,
						/obj/item/device/binoculars = 1,
						/obj/item/weapon/storage/backpack/marine/satchel = 2,
						/obj/item/weapon/gun/flamer = 2,
						/obj/item/ammo_magazine/flamer_tank = 8
					)

/obj/machinery/vending/attachments
	name = "\improper Armat Systems Attachments Vendor"
	desc = "A subsidiary-owned vendor of weapon attachments. This can only be accessed by the Requisitions Officer and Cargo Techs."
	hacking_safety = 1
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_CARGO)
	icon_state = "robotics"
	icon_deny = "robotics-deny"

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

						/obj/item/attachable/foregrip = 10,
						/obj/item/attachable/gyro = 4,
						/obj/item/attachable/bipod = 4,
						/obj/item/attachable/burstfire_assembly = 2,

						/obj/item/attachable/stock/shotgun = 3,
						/obj/item/attachable/stock/rifle = 3 ,
						/obj/item/attachable/stock/revolver = 3,

						/obj/item/attachable/grenade = 5,
						/obj/item/attachable/shotgun = 3,
						/obj/item/attachable/flamer = 3
					)

	New()

		..()

		attachment_vendors.Add(src)

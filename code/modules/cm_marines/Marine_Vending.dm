//MARINE VENDING - APOPHIS775 - LAST UPDATE - 25JAN2015


///******MARINE VENDOR******///

/obj/machinery/vending/marine
	name = "ColMarTech"
	desc = "A marine equipment vendor"
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
					/obj/item/weapon/gun/projectile/m4a3 = 8,
					/obj/item/weapon/gun/projectile/m44m = 8,
					/obj/item/weapon/gun/projectile/automatic/m39 = 8,
					/obj/item/weapon/gun/projectile/automatic/m41 = 10,
					/obj/item/weapon/gun/projectile/shotgun/pump/m37 = 5,

					/obj/item/ammo_magazine/m4a3 = 25,
					/obj/item/ammo_magazine/m44m =25,
					/obj/item/ammo_magazine/m39 = 25,
					/obj/item/ammo_magazine/m41 = 25,
					/obj/item/weapon/storage/box/m37 = 25,

					/obj/item/weapon/combat_knife = 10,
					/obj/item/weapon/storage/belt/knifepouch = 3,
					/obj/item/weapon/throwing_knife = 9,
					/obj/item/device/flashlight/flare = 10,
					/obj/item/weapon/storage/backpack/marine = 20,
					/obj/item/device/radio/headset/msulaco = 5,


					/obj/item/weapon/reagent_containers/food/snacks/donkpocket = 5

					)
	contraband = list(/*bj/item/weapon/storage/fancy/donut_box = 5,
					/obj/item/ammo_magazine/a357 = 5,
					/obj/item/ammo_magazine/a50 = 5,*/
					)
	premium = list(
//				/obj/item/ammo_magazine/a762 = 5,
				)
	prices = list()

//MARINE FOOD VENDOR APOPHIS775 10JAN2014
/obj/machinery/vending/marineFood
	name = "Marine Food Vendor"
	desc = "Standard Issue Food Vendor, containing standard military food"
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat-deny"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/monkeyburger = 20, /obj/item/weapon/reagent_containers/food/snacks/tofuburger = 5,
					/obj/item/weapon/reagent_containers/food/snacks/omelette = 10, /obj/item/weapon/reagent_containers/food/snacks/muffin = 20,
					/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 30, /obj/item/weapon/reagent_containers/food/snacks/meatsteak = 10)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/tea = 10, /obj/item/weapon/reagent_containers/food/snacks/donkpocket = 50)
	vend_delay = 15
	product_slogans = "Standard Issue Marine food!;It's good for you, and not the worst thing in the world.;Just fucking eat it;"
	product_ads = "Your only choice for food...Literally;"
	req_access_txt = ""


//MARINE MEDICAL VENDOR -APOPHIS775 24JAN2015
/obj/machinery/vending/MarineMed
	name = "MarineMed"
	desc = "Advanced Marine Drug Dispenser"
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access_txt = "0"
	products = list(/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord = 5,
					/obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP =5,
					/obj/item/weapon/reagent_containers/hypospray/autoinjector/clonefix = 10)
	contraband = list(/obj/item/weapon/reagent_containers/hypospray/autoinjector/chloralhydrate =3)



//NEW BLOOD VENDOR CODE - APOPHIS775 22JAN2015
/obj/machinery/vending/MarineMed/Blood
	name = "MM Blood Dispenser"
	desc = "Marine Med brand Blood Pack Dispensery"
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "The best blood on the market!"
	req_access_txt = "0"
	products = list(/obj/item/weapon/reagent_containers/blood/APlus = 5, /obj/item/weapon/reagent_containers/blood/AMinus = 5,
					/obj/item/weapon/reagent_containers/blood/BPlus = 5, /obj/item/weapon/reagent_containers/blood/BMinus = 5,
					/obj/item/weapon/reagent_containers/blood/OPlus = 5, /obj/item/weapon/reagent_containers/blood/OMinus = 5,
					/obj/item/weapon/reagent_containers/blood/empty = 10)

	contraband= list()
	prices = list()
	premium = list()


/obj/machinery/vending/marine_engi
	name = "ColMarTech Engineer Vendor"
	desc = "A marine engineering equipment vendor"
	product_ads = "If it breaks, wrench it!;If it wrenches, weld it!;If it snips, snip it!"
	req_access = list(access_marine_engprep)
	products = list(
						/obj/item/clothing/under/rank/engineer = 3,
						/obj/item/weapon/storage/belt/utility/full = 3,
						/obj/item/clothing/gloves/yellow = 3,
						/obj/item/clothing/glasses/meson = 3,
						/obj/item/device/multitool = 4,
						/obj/item/weapon/storage/backpack/industrial = 3,
						/obj/item/weapon/plastique = 3,
						/obj/item/weapon/airlock_electronics = 10,
						/obj/item/weapon/module/power_control = 10,
						/obj/item/weapon/airalarm_electronics = 10,
						/obj/item/weapon/cell/high = 10,
						/obj/item/device/assembly/prox_sensor = 5,
						/obj/item/device/assembly/igniter = 3,
						/obj/item/device/assembly/signaler = 4,
						/obj/item/stack/cable_coil/random = 10,
						/obj/item/weapon/crowbar = 5,
						/obj/item/weapon/weldingtool = 3,
						/obj/item/weapon/wirecutters = 5,
						/obj/item/weapon/wrench = 5,
						/obj/item/device/analyzer = 5,
						/obj/item/device/t_scanner = 5,
						/obj/item/weapon/screwdriver = 5
					)
	contraband = list()
	premium = list()
	prices = list()

/obj/machinery/vending/marine_medic
	name = "ColMarTech Medic Vendor"
	desc = "A marine medic equipment vendor"
	product_ads = "They were gonna die anyway.;Let's get space drugged!"
	req_access = list(access_marine_medprep)
	icon_state = "med"
	icon_deny = "med-deny"
	products = list(
						/obj/item/weapon/storage/backpack/medic = 3,
						/obj/item/clothing/under/rank/medical = 4,
						/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 4,
						/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 4,
						/obj/item/device/healthanalyzer = 5,
						/obj/item/stack/medical/advanced/bruise_pack = 6,
						/obj/item/stack/medical/advanced/ointment = 6,
						/obj/item/stack/medical/splint = 2,
						/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord = 5,
						/obj/item/weapon/storage/belt/medical = 3,
						/obj/item/clothing/glasses/hud/health = 3
					)
	contraband = list()
	premium = list()
	prices = list()

/obj/machinery/vending/marine_special
	name = "ColMarTech Specialist Vendor"
	desc = "A marine specialist equipment vendor"
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(access_marine_specprep)
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	products = list(
						/obj/item/weapon/coin/marine = 1,
						/obj/item/weapon/plastique = 2,
						/obj/item/weapon/grenade/explosive = 5,
						/obj/item/weapon/grenade/smokebomb = 5,
						/obj/item/device/mine = 2,
						/obj/item/ammo_casing/rocket = 2,
						/obj/item/ammo_casing/rocket/ap = 2,
						/obj/item/weapon/flamethrower = 1,
						/obj/item/weapon/tank/phoron = 2,
						/obj/item/weapon/shield/riot = 1,
						/obj/item/ammo_magazine/m42c = 1,
						/obj/item/smartgun_powerpack = 1
			)
	contraband = list()
	premium = list(
					/obj/item/weapon/gun/rocketlauncher = 1,
					/obj/item/weapon/gun/m92 = 1,
					/obj/item/weapon/gun/projectile/M42C = 1,
					/obj/item/weapon/storage/box/m56_system = 1,
					/obj/item/weapon/storage/box/heavy_armor = 1
			)
	prices = list()

/obj/machinery/vending/marine_leader
	name = "ColMarTech Leader Vendor"
	desc = "A marine leader equipment vendor"
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(access_marine_leader)
	icon_state = "tool"
	icon_deny = "tool-deny"
	products = list(
						/obj/item/clothing/suit/storage/marine_leader_armor = 1,
						/obj/item/weapon/plastique = 3,
						/obj/item/weapon/grenade/explosive = 5,
						/obj/item/device/binoculars = 1,
						/obj/item/device/paicard = 1,
						/obj/item/weapon/handcuffs = 2,
						/obj/item/weapon/implanter/adrenalin = 1,
						/obj/item/weapon/storage/box/explosive_mines = 1
					)
	contraband = list()
	premium = list()
	prices = list()
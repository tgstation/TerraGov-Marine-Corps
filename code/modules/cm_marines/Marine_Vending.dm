//MARINE VENDING - APOPHIS775 - LAST UPDATE - 25JAN2015


///******MARINE VENDOR******///

/obj/machinery/vending/marine
	name = "ColMarTech"
	desc = "A marine equipment vendor"
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/donut/normal = 25,

/obj/item/weapon/gun/projectile/pistol/m4a3 = 5,
					/obj/item/weapon/gun/projectile/m44m = 5,
					/obj/item/weapon/gun/projectile/automatic/Assault/m39 = 5,
					/obj/item/weapon/gun/projectile/Assault/m41 = 5,
					/obj/item/weapon/gun/projectile/shotgun/pump/m37 = 5,


					/obj/item/ammo_magazine/m4a3 = 25,
					/obj/item/ammo_magazine/m44m =25,
					/obj/item/ammo_magazine/m39 = 25,
					/obj/item/ammo_magazine/m41 = 25,
					/obj/item/weapon/storage/box/m37 = 25,
					/obj/item/ammo_magazine/a762 = 10,
					/obj/item/ammo_magazine/a12mm = 25,


					/obj/item/weapon/combat_knife = 5,
					/obj/item/device/flashlight/flare = 10,

					)
	contraband = list(/*bj/item/weapon/storage/fancy/donut_box = 5,
					/obj/item/ammo_magazine/a357 = 5,
					/obj/item/ammo_magazine/a50 = 5,*/
					)
	premium = list(
				/obj/item/ammo_magazine/a762 = 5,
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
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/tea = 10)
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
	products = list(/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord = 10,  /obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot = 10,
					/obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP =10, /obj/item/weapon/reagent_containers/hypospray/autoinjector/clonefix = 10)
	contraband = list(/obj/item/weapon/reagent_containers/hypospray/autoinjector/chloralhydrate =5)



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
					/*/obj/item/weapon/reagent_containers/blood/ABPlus = 5, /obj/item/weapon/reagent_containers/blood/ABMinus = 5*/,
					/obj/item/weapon/reagent_containers/blood/empty = 10)


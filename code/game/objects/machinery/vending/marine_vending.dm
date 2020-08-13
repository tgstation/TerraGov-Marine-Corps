///******MARINE VENDOR******///

/obj/machinery/vending/marine
	name = "\improper Automated Weapons Rack"
	desc = "A automated weapon rack hooked up to a colossal storage of standard-issue weapons."
	icon_state = "marinearmory"
	icon_vend = "marinearmory-vend"
	icon_deny = "marinearmory"
	wrenchable = FALSE
	tokensupport = TOKEN_MARINE

	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
					/obj/item/weapon/gun/pistol/standard_pistol = 25,
					/obj/item/ammo_magazine/pistol/standard_pistol = 30,
					/obj/item/weapon/gun/pistol/standard_heavypistol = 10,
					/obj/item/ammo_magazine/pistol/standard_heavypistol = 25,
					/obj/item/weapon/gun/revolver/standard_revolver = 15,
					/obj/item/ammo_magazine/revolver/standard_revolver = 25,
					/obj/item/weapon/gun/smg/standard_machinepistol = 20,
					/obj/item/ammo_magazine/smg/standard_machinepistol = 30,
					/obj/item/weapon/gun/pistol/standard_pocketpistol = 25,
					/obj/item/ammo_magazine/pistol/standard_pocketpistol = 50,
					/obj/item/weapon/gun/smg/standard_smg = 20,
					/obj/item/ammo_magazine/smg/standard_smg = 30,
					/obj/item/weapon/gun/rifle/standard_carbine = 25,
					/obj/item/ammo_magazine/rifle/standard_carbine = 25,
					/obj/item/weapon/gun/rifle/standard_assaultrifle = 25,
					/obj/item/ammo_magazine/rifle/standard_assaultrifle = 25,
					/obj/item/weapon/gun/rifle/standard_lmg = 15,
					/obj/item/ammo_magazine/standard_lmg = 30,
					/obj/item/weapon/gun/rifle/standard_gpmg = 15,
					/obj/item/ammo_magazine/standard_gpmg = 30,
					/obj/item/weapon/gun/rifle/standard_dmr = 10,
					/obj/item/ammo_magazine/rifle/standard_dmr = 25,
					/obj/item/weapon/gun/rifle/standard_br = 10,
					/obj/item/ammo_magazine/rifle/standard_br = 25,
					/obj/item/weapon/gun/rifle/chambered = 20,
					/obj/item/ammo_magazine/rifle/chamberedrifle = 20,
					/obj/item/weapon/gun/energy/lasgun/lasrifle = 10,
					/obj/item/cell/lasgun/lasrifle = 20,
					/obj/item/weapon/gun/shotgun/pump/t35 = 10,
					/obj/item/weapon/gun/shotgun/combat/standardmarine = 10,
					/obj/item/ammo_magazine/shotgun = 10,
					/obj/item/ammo_magazine/shotgun/buckshot = 10,
					/obj/item/ammo_magazine/shotgun/flechette = 10,
					/obj/item/weapon/gun/rifle/standard_autoshotgun = 10,
					/obj/item/ammo_magazine/rifle/tx15_slug = 25,
					/obj/item/ammo_magazine/rifle/tx15_flechette = 25,
					/obj/item/weapon/gun/launcher/m92/standardmarine = 10,
					/obj/item/explosive/grenade/frag = 30,
					/obj/item/attachable/bayonetknife = 20,
					/obj/item/weapon/throwing_knife = 5,
					/obj/item/storage/box/m94 = 5,
					/obj/item/attachable/flashlight = 10,
					/obj/item/explosive/grenade/mirage = 5,
					)
	prices = list()

/obj/machinery/vending/marine/select_gamemode_equipment(gamemode)
	var/products2[]
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		products2 = list(/obj/item/clothing/mask/rebreather/scarf = 10, /obj/item/clothing/mask/rebreather = 10)
	build_inventory(products2)

/obj/machinery/vending/marine/Initialize()
	. = ..()
	GLOB.marine_vendors.Add(src)

/obj/machinery/vending/marine/Destroy()
	. = ..()
	GLOB.marine_vendors.Remove(src)

//What do grenade do against candy machine?
/obj/machinery/vending/marine/ex_act(severity)
	return

/obj/machinery/vending/marine/cargo_supply
	name = "\improper Operational Supplies Vendor"
	desc = "A large vendor for dispensing specialty and bulk supplies. Restricted to cargo personnel only."
	icon_state = "synth"
	icon_vend = "synth-vend"
	icon_deny = "synth-deny"
	wrenchable = FALSE
	req_one_access = list(ACCESS_MARINE_CARGO, ACCESS_MARINE_LOGISTICS)
	products = list(
					/obj/item/storage/box/ammo = 30,
					/obj/item/storage/box/nade_box = 2,
					/obj/item/storage/box/nade_box/HIDP = 2,
					/obj/item/storage/box/nade_box/M15 = 2,
					/obj/item/ammo_magazine/sniper = 3,
					/obj/item/ammo_magazine/rifle/m4ra = 3,
					/obj/item/ammo_magazine/rocket = 3,
					/obj/item/ammo_magazine/minigun = 2,
					/obj/item/ammo_magazine/shotgun/mbx900 = 2,
					/obj/item/bodybag/tarp = 2,
					/obj/item/explosive/plastique = 2)

/obj/machinery/vending/marine/cargo_guns
	name = "\improper Automated Armaments Vendor"
	desc = "A automated rack hooked up to a small supply of various firearms and explosives."
	wrenchable = FALSE
	products = list(
					/obj/item/weapon/gun/pistol/standard_pistol = 10,
					/obj/item/weapon/gun/revolver/standard_revolver = 10,
					/obj/item/weapon/gun/pistol/standard_heavypistol = 10,
					/obj/item/weapon/gun/pistol/vp70 = 10,
					/obj/item/weapon/gun/smg/ppsh = 5,
					/obj/item/weapon/gun/smg/standard_smg = 10,
					/obj/item/weapon/gun/smg/standard_machinepistol = 10,
					/obj/item/weapon/gun/rifle/standard_carbine = 10,
					/obj/item/weapon/gun/rifle/standard_assaultrifle = 10,
					/obj/item/weapon/gun/rifle/standard_lmg = 10,
					/obj/item/weapon/gun/rifle/standard_gpmg = 10,
					/obj/item/weapon/gun/rifle/standard_dmr = 10,
					/obj/item/weapon/gun/rifle/standard_br = 10,
					/obj/item/weapon/gun/energy/lasgun/lasrifle = 10,
					/obj/item/weapon/gun/rifle/chambered = 10,
					/obj/item/weapon/gun/shotgun/pump/t35 = 10,
					/obj/item/weapon/gun/shotgun/combat/standardmarine = 10,
					/obj/item/weapon/gun/rifle/standard_autoshotgun = 10,
					/obj/item/weapon/gun/launcher/m92/standardmarine = 10,
					/obj/item/weapon/gun/pistol/standard_pocketpistol = 20,
					/obj/item/weapon/gun/shotgun/double/marine = 5,
					/obj/item/weapon/gun/shotgun/pump/ksg = 5,
					/obj/item/weapon/gun/shotgun/pump/bolt = 5,
					/obj/item/weapon/gun/flamer/marinestandard = 2,
					/obj/item/explosive/mine = 5,
					/obj/item/explosive/grenade/frag/m15 = 25,
					/obj/item/explosive/grenade/incendiary = 25,
					/obj/item/explosive/grenade/smokebomb = 25,
					/obj/item/explosive/grenade/cloakbomb = 25,
					/obj/item/storage/box/m94 = 30
					)

	premium = list()



/obj/machinery/vending/marine/cargo_guns/select_gamemode_equipment(gamemode)
	return

/obj/machinery/vending/marine/cargo_guns/Initialize()
	. = ..()
	GLOB.cargo_guns_vendors.Add(src)
	GLOB.marine_vendors.Remove(src)

/obj/machinery/vending/marine/cargo_guns/Destroy()
	. = ..()
	GLOB.cargo_guns_vendors.Remove(src)




/obj/machinery/vending/marine/cargo_ammo
	name = "\improper Automated Munition Vendor"
	desc = "A automated rack hooked up to a small supply of ammo magazines."
	icon_state = "marinerequisitions"
	icon_vend = "marinerequisitions-vend"
	icon_deny = "marinerequisitions"
	wrenchable = FALSE
	products = list(
					/obj/item/ammo_magazine/pistol/standard_pistol = 50,
					/obj/item/ammo_magazine/revolver/standard_revolver = 50,
					/obj/item/ammo_magazine/pistol/standard_heavypistol = 50,
					/obj/item/ammo_magazine/pistol/vp70 = 50,
					/obj/item/ammo_magazine/smg/standard_smg = 50,
					/obj/item/ammo_magazine/smg/standard_machinepistol = 50,
					/obj/item/ammo_magazine/rifle/standard_carbine = 50,
					/obj/item/ammo_magazine/rifle/standard_assaultrifle = 50,
					/obj/item/ammo_magazine/standard_lmg = 50,
					/obj/item/ammo_magazine/standard_gpmg = 50,
					/obj/item/ammo_magazine/rifle/standard_dmr = 50,
					/obj/item/ammo_magazine/rifle/standard_br = 50,
					/obj/item/cell/lasgun/lasrifle = 50,
					/obj/item/ammo_magazine/rifle/chamberedrifle = 50,
					/obj/item/ammo_magazine/shotgun = 50,
					/obj/item/ammo_magazine/shotgun/buckshot = 50,
					/obj/item/ammo_magazine/shotgun/flechette = 50,
					/obj/item/ammo_magazine/rifle/tx15_slug = 50,
					/obj/item/ammo_magazine/rifle/tx15_flechette = 50,
					/obj/item/ammo_magazine/pistol/standard_pocketpistol = 50,
					/obj/item/ammo_magazine/flamer_tank/large = 10,
					/obj/item/ammo_magazine/standard_smartmachinegun = 2,
					/obj/item/ammo_magazine/flamer_tank = 10,
					/obj/item/ammo_magazine/smg/ppsh/ = 30,
					/obj/item/ammo_magazine/smg/ppsh/extended = 10,
					/obj/item/ammo_magazine/rifle/bolt = 7,
					)
	premium = list()


/obj/machinery/vending/marine/cargo_ammo/select_gamemode_equipment(gamemode)
	return

/obj/machinery/vending/marine/cargo_ammo/Initialize()
	. = ..()
	GLOB.cargo_ammo_vendors.Add(src)
	GLOB.marine_vendors.Remove(src)

/obj/machinery/vending/marine/cargo_ammo/Destroy()
	. = ..()
	GLOB.cargo_ammo_vendors.Remove(src)

/obj/machinery/vending/lasgun
	name = "\improper Lasrifle Field Charger"
	desc = "An automated power cell dispenser and charger. Used to recharge energy weapon power cells, including in the field. Has an internal battery that charges off the power grid when wrenched down."
	icon_state = "lascharger"
	icon_vend = "lascharger-vend"
	icon_deny = "lascharger-denied"
	wrenchable = TRUE
	drag_delay = FALSE
	anchored = FALSE
	idle_power_usage = 1
	active_power_usage = 50
	machine_current_charge = 50000 //integrated battery for recharging energy weapons. Normally 10000.
	machine_max_charge = 50000

	product_ads = "Lasrifle running low? Recharge here!;Need a charge?;Power up!;Electrifying!;Empower yourself!"
	products = list(
					/obj/item/cell/lasgun/lasrifle = 10,
					/obj/item/cell/lasgun/lasrifle/highcap = 2,
					)

	contraband =   list()

	premium = list()

	prices = list()

/obj/machinery/vending/lasgun/Initialize()
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

/obj/machinery/vending/lasgun/examine(mob/user)
	. = ..()
	to_chat(user, "<b>It has [machine_current_charge] of [machine_max_charge] charge remaining.</b>")


/obj/machinery/vending/lasgun/MouseDrop_T(atom/movable/A, mob/user)
	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(user.stat || user.restrained() || user.lying_angle)
		return

	if(get_dist(user, src) > 1 || get_dist(src, A) > 1)
		return

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
	products = list(/obj/item/reagent_containers/food/snacks/protein_pack = 50,
					/obj/item/reagent_containers/food/snacks/mre_pack/meal1 = 15,
					/obj/item/reagent_containers/food/snacks/mre_pack/meal2 = 15,
					/obj/item/reagent_containers/food/snacks/mre_pack/meal3 = 15,
					/obj/item/reagent_containers/food/snacks/mre_pack/meal4 = 15,
					/obj/item/reagent_containers/food/snacks/mre_pack/meal6 = 15,
					/obj/item/storage/box/MRE = 10,
					/obj/item/reagent_containers/food/drinks/flask = 5)
//Christmas inventory
/*
					/obj/item/reagent_containers/food/snacks/mre_pack/xmas1 = 25,
					/obj/item/reagent_containers/food/snacks/mre_pack/xmas2 = 25,
					/obj/item/reagent_containers/food/snacks/mre_pack/xmas3 = 25)*/
	contraband = list(/obj/item/reagent_containers/food/drinks/flask/marine = 10,
					/obj/item/reagent_containers/food/snacks/mre_pack/meal5 = 15)
	vend_delay = 15
	//product_slogans = "Standard Issue Marine food!;It's good for you, and not the worst thing in the world.;Just fucking eat it.;"
	product_ads = "Try the cornbread.;Try the pizza.;Try the pasta.;Try the tofu, wimp.;Try the pork."


/obj/machinery/vending/MarineMed
	name = "\improper MarineMed"
	desc = "Marine Medical drug dispenser - Provided by Nanotrasen Pharmaceuticals Division(TM)."
	icon_state = "marinemed"
	icon_deny = "marinemed-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;All natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_one_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_MEDPREP) //Medics, doctors and researchers can access
	wrenchable = FALSE
	products = list(/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 6,
					/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = 6,
					/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = 6,
					/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 6,
					/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 6,
					/obj/item/reagent_containers/hypospray/autoinjector/kelotane = 6,
					/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 4,
					/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 8,
					/obj/item/reagent_containers/hypospray/autoinjector/combat = 2,
					/obj/item/reagent_containers/hypospray/autoinjector/hypervene = 4,
					/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 0,
					/obj/item/storage/pill_bottle/bicaridine = 3,
					/obj/item/storage/pill_bottle/dexalin = 3,
					/obj/item/storage/pill_bottle/dylovene = 3,
					/obj/item/storage/pill_bottle/kelotane = 3,
					/obj/item/storage/pill_bottle/spaceacillin = 3,
					/obj/item/storage/pill_bottle/inaprovaline = 3,
					/obj/item/storage/pill_bottle/alkysine = 3,
					/obj/item/storage/pill_bottle/tricordrazine = 3,
					/obj/item/storage/pill_bottle/imidazoline = 3,
					/obj/item/storage/pill_bottle/tramadol = 3,
					/obj/item/storage/pill_bottle/russianRed = 5,
					/obj/item/storage/pill_bottle/peridaxon = 2,
					/obj/item/storage/pill_bottle/quickclot = 2,
					/obj/item/storage/pill_bottle/hypervene = 2,
					/obj/item/stack/medical/advanced/bruise_pack = 8,
					/obj/item/stack/medical/bruise_pack = 8,
					/obj/item/stack/medical/advanced/ointment = 8,
					/obj/item/stack/medical/ointment = 8,
					/obj/item/stack/medical/splint = 4,
					/obj/item/healthanalyzer = 3,
					/obj/item/bodybag/cryobag = 2)

	contraband = list(/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin =3,
					/obj/item/reagent_containers/hypospray/autoinjector/synaptizine_expired =3)



/obj/machinery/vending/MarineMed/Blood
	name = "\improper MM Blood Dispenser"
	desc = "Marine Med brand Blood Pack dispensery."
	icon_state = "bloodvendor"
	icon_deny = "bloodvendor-deny"
	product_ads = "The best blood on the market!"
	req_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	products = list(/obj/item/reagent_containers/blood/APlus = 5,
					/obj/item/reagent_containers/blood/AMinus = 5,
					/obj/item/reagent_containers/blood/BPlus = 5,
					/obj/item/reagent_containers/blood/BMinus = 5,
					/obj/item/reagent_containers/blood/OPlus = 5,
					/obj/item/reagent_containers/blood/OMinus = 5,
					/obj/item/reagent_containers/blood/empty = 10)
	contraband = list()

/obj/machinery/vending/MarineMed/Blood/build_inventory(productlist[])
	. = ..()
	var/temp_list[] = productlist
	var/obj/item/reagent_containers/blood/temp_path
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
	name = "\improper TerraGovTech Medic Vendor"
	desc = "A marine medic equipment vendor"
	product_ads = "They were gonna die anyway.;Let's get space drugged!"
	req_access = list(ACCESS_MARINE_MEDPREP)
	icon_state = "marinemed"
	icon_deny = "marinemed-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/clothing/under/marine/corpsman = 4,
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
	contraband = list(/obj/item/reagent_containers/blood/OMinus = 1)


/obj/machinery/vending/marine_special
	name = "\improper TerraGovTech Specialist Vendor"
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
					/obj/item/storage/box/spec/pyro = 1,
					/obj/item/storage/box/spec/tracker = 1
					)
	prices = list()


/obj/machinery/vending/shared_vending/marine_special
	name = "\improper TerraGovTech Specialist Vendor"
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
					/obj/item/storage/box/spec/pyro = 1,
					/obj/item/storage/box/spec/tracker = 1

			)
	prices = list()


/obj/machinery/vending/shared_vending/marine_engi
	name = "\improper TerraGovTech Engineer System Vendor"
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
					/obj/item/storage/box/standard_hmg = 1
					)
	shared = list(
				/obj/structure/closet/crate/mortar_ammo/mortar_kit = 1,
				)
	prices = list()


/obj/machinery/vending/marine_smartgun
	name = "\improper TerraGovTech Smartgun Vendor"
	desc = "A marine smartgun equipment vendor"
	hacking_safety = 1
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	req_access = list(ACCESS_MARINE_SMARTPREP)
	icon_state = "smartgunner"
	icon_deny = "smartgunner-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/clothing/tie/storage/webbing = 1,
						/obj/item/storage/box/t26_system = 1,
						/obj/item/smartgun_powerpack = 1,
						/obj/item/storage/pouch/magazine = 1,
						/obj/item/clothing/mask/gas = 1
			)
	contraband = list()
	premium = list()
	prices = list()

/obj/machinery/vending/marine_leader
	name = "\improper TerraGovTech Leader Vendor"
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
						/obj/item/squad_beacon = 1,
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


/obj/machinery/vending/attachments
	name = "\improper Terran Armories Attachments Vendor"
	desc = "A subsidiary-owned vendor of weapon attachments."
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	wrenchable = FALSE

	products = list(
						/obj/item/attachable/bayonet = 25,
						/obj/item/attachable/compensator = 25,
						/obj/item/attachable/extended_barrel = 25,
						/obj/item/attachable/heavy_barrel = 25,
						/obj/item/attachable/suppressor = 25,

						/obj/item/attachable/flashlight = 25,
						/obj/item/attachable/magnetic_harness = 25,
						/obj/item/attachable/reddot = 25,
						/obj/item/attachable/scope = 25,
						/obj/item/attachable/scope/mini = 25,

						/obj/item/attachable/angledgrip = 25,
						/obj/item/attachable/bipod = 25,
						/obj/item/attachable/burstfire_assembly = 25,
						/obj/item/attachable/gyro = 25,
						/obj/item/attachable/lasersight = 25,
						/obj/item/attachable/verticalgrip = 25,

						/obj/item/attachable/stock/t19stock = 25,
						/obj/item/attachable/stock/t35stock = 25,
						/obj/item/attachable/stock/tactical = 25,

						/obj/item/attachable/attached_gun/flamer = 25,
						/obj/item/attachable/attached_gun/shotgun = 25,
						/obj/item/attachable/attached_gun/grenade = 25
					)

/obj/machinery/vending/attachments/Initialize()
	. = ..()
	GLOB.attachment_vendors.Add(src)

/obj/machinery/vending/attachments/Destroy()
	. = ..()
	GLOB.attachment_vendors.Remove(src)



/obj/machinery/vending/uniform_supply
	name = "\improper Surplus Equipment Vendor"
	desc = "A automated equipment rack hooked up to a colossal storage of uniforms and accessories."
	icon_state = "marineuniform"
	icon_vend = "marineuniform_vend"
	icon_deny = "marineuniform"
	var/squad_tag = ""

	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
					/obj/item/storage/large_holster/machete/full = 10,
					/obj/item/clothing/shoes/marine = 20,
					/obj/item/clothing/under/marine/standard = 20,
					/obj/item/clothing/under/marine/jaeger = 30,
					/obj/item/storage/backpack/marine/standard = 10,
					/obj/item/storage/backpack/marine/satchel = 10,
					/obj/item/tool/weldpack/marinestandard = 10,
					/obj/item/clothing/gloves/marine = 20,
					/obj/item/clothing/suit/storage/marine/pasvest = 40,
					/obj/item/clothing/head/helmet/marine = 40,
					/obj/item/clothing/head/helmet/marine/heavy = 10,
					/obj/item/clothing/glasses/mgoggles = 10,
					/obj/item/clothing/glasses/mgoggles/prescription = 10,
					/obj/item/clothing/mask/rebreather/scarf = 10,
					/obj/item/clothing/mask/bandanna/skull = 10,
					/obj/item/clothing/mask/bandanna/green = 10,
					/obj/item/clothing/mask/bandanna/white = 10,
					/obj/item/clothing/mask/bandanna/black = 10,
					/obj/item/clothing/mask/bandanna = 10,
					/obj/item/clothing/mask/rebreather = 10,
					/obj/item/clothing/mask/breath = 10,
					/obj/item/clothing/mask/gas = 10,
					/obj/item/storage/belt/marine = 10,
					/obj/item/storage/belt/shotgun = 10,
					/obj/item/storage/belt/grenade = 10,
					/obj/item/storage/belt/knifepouch = 10,
					/obj/item/belt_harness/marine = 10,
					/obj/item/storage/belt/sparepouch = 10,
					/obj/item/storage/belt/gun/pistol/standard_pistol = 10,
					/obj/item/storage/belt/gun/revolver/standard_revolver = 10,
					/obj/item/armor_module/storage/general = 20,
					/obj/item/armor_module/storage/ammo_mag = 20,
					/obj/item/armor_module/storage/engineering = 20,
					/obj/item/armor_module/storage/medical = 20,
					/obj/item/armor_module/storage/integrated = 20,
					/obj/item/storage/pouch/pistol = 10,
					/obj/item/storage/pouch/magazine = 10,
					/obj/item/storage/pouch/magazine/large = 5,
					/obj/item/storage/pouch/magazine/pistol = 10,
					/obj/item/storage/pouch/magazine/pistol/large = 5,
					/obj/item/storage/pouch/shotgun = 10,
					/obj/item/storage/pouch/flare = 10,
					/obj/item/storage/pouch/grenade = 10,
					/obj/item/storage/pouch/explosive = 10,
					/obj/item/storage/pouch/firstaid = 10,
					/obj/item/storage/pouch/syringe = 5,
					/obj/item/storage/pouch/medical = 5,
					/obj/item/storage/pouch/medkit = 10,
					/obj/item/storage/pouch/autoinjector = 10,
					/obj/item/storage/pouch/construction = 10,
					/obj/item/storage/pouch/electronics = 10,
					/obj/item/storage/pouch/tools = 10,
					/obj/item/storage/pouch/field_pouch = 10,
					/obj/item/storage/pouch/general/large = 10,
					/obj/item/storage/pouch/document = 10,
					/obj/item/clothing/tie/storage/brown_vest = 10,
					/obj/item/clothing/tie/storage/white_vest/medic = 10,
					/obj/item/clothing/tie/storage/webbing = 10,
					/obj/item/clothing/tie/holster = 10,
					/obj/item/flashlight/combat = 10,
					/obj/item/clothing/under/whites = 50,
					/obj/item/clothing/head/white_dress = 50,
					/obj/item/clothing/shoes/white = 50,
					/obj/item/clothing/gloves/white = 50,
					/obj/item/clothing/suit/modular = 20,
					/obj/item/armor_module/armor/chest/marine = 20,
					/obj/item/armor_module/armor/chest/marine/skirmisher = 20,
					/obj/item/armor_module/armor/chest/marine/assault = 20,
					/obj/item/armor_module/armor/arms/marine = 20,
					/obj/item/armor_module/armor/arms/marine/skirmisher = 20,
					/obj/item/armor_module/armor/arms/marine/assault = 20,
					/obj/item/armor_module/armor/legs/marine = 20,
					/obj/item/armor_module/armor/legs/marine/skirmisher = 20,
					/obj/item/armor_module/armor/legs/marine/assault = 20,
					/obj/item/clothing/head/modular/marine = 20,
					/obj/item/clothing/head/modular/marine/skirmisher = 20,
					/obj/item/clothing/head/modular/marine/assault = 20,
					/obj/item/facepaint/green = 20
					)

	prices = list()

/obj/machinery/vending/dress_supply
	name = "\improper TerraGovTech dress uniform vendor"
	desc = "A automated rack hooked up to a colossal storage of dress uniforms."
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

/obj/machinery/vending/uniform_supply/Initialize()
	. = ..()
	var/products2[]
	if(squad_tag != null) //probably some better way to slide this in but no sleep is no sleep.
		switch(squad_tag)
			if("Alpha")
				products2 = list(/obj/item/radio/headset/mainship/marine/alpha = 20,
								/obj/item/clothing/mask/bandanna/alpha = 10)
			if("Bravo")
				products2 = list(/obj/item/radio/headset/mainship/marine/bravo = 20,
								/obj/item/clothing/mask/bandanna/bravo = 10)
			if("Charlie")
				products2 = list(/obj/item/radio/headset/mainship/marine/charlie = 20,
								/obj/item/clothing/mask/bandanna/charlie = 10)
			if("Delta")
				products2 = list(/obj/item/radio/headset/mainship/marine/delta = 20,
								/obj/item/clothing/mask/bandanna/delta = 10)
	else
		products2 = list(/obj/item/radio/headset/mainship = 20,
						/obj/item/clothing/mask/bandanna = 10)
	build_inventory(products2)
	GLOB.marine_vendors.Add(src)


/obj/machinery/vending/uniform_supply/Destroy()
	. = ..()
	GLOB.marine_vendors.Remove(src)

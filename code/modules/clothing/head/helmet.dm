

/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	item_state = "helmet"
	armor = list(melee = 50, bullet = 15, laser = 50,energy = 10, bomb = 25, bio = 0, rad = 0)
	flags_atom = FPRINT|CONDUCT
	flags_inventory = HIDEEARS|HIDEEYES|COVEREYES|BLOCKSHARPOBJ
	flags_cold_protection = HEAD
	flags_heat_protection = HEAD
	min_cold_protection_temperature = HELMET_min_cold_protection_temperature
	max_heat_protection_temperature = HELMET_max_heat_protection_temperature
	siemens_coefficient = 0.7
	w_class = 5



/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	armor = list(melee = 82, bullet = 15, laser = 5, energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inventory = HIDEEARS|HIDEEYES|COVEREYES|HIDETOPHAIR|BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/augment
	name = "augment array"
	desc = "A helmet with optical and cranial augments coupled to it."
	icon_state = "v62"
	item_state = "v62"
	armor = list(melee = 80, bullet = 60, laser = 50, energy = 25, bomb = 50, bio = 10, rad = 0)
	siemens_coefficient = 0.5

/obj/item/clothing/head/helmet/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a securiy force. Protects the head from impacts."
	icon_state = "policehelm"
	flags_inventory = 0
	flags_armor_protection = 0

/obj/item/clothing/head/helmet/hop
	name = "crew resource's hat"
	desc = "A stylish hat that both protects you from enraged former-crewmembers and gives you a false sense of authority."
	icon_state = "hopcap"
	flags_inventory = 0
	flags_armor_protection = 0

/obj/item/clothing/head/helmet/formalcaptain
	name = "parade hat"
	desc = "No one in a commanding position should be without a perfect, white hat of ultimate authority."
	icon_state = "officercap"
	flags_inventory = 0
	flags_armor_protection = 0

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	item_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags_inventory = HIDEEARS|HIDEEYES|COVEREYES|BLOCKSHARPOBJ
	flags_cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_min_cold_protection_temperature
	siemens_coefficient = 0.5
	anti_hug = 1

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	flags_inventory = HIDEEARS|HIDEEYES|COVEREYES|BLOCKSHARPOBJ
	item_state = "thunderdome"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_min_cold_protection_temperature
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	item_state = "gladiator"
	flags_inventory = HIDEMASK|HIDEEARS|HIDEEYES |COVEREYES|HIDEALLHAIR|BLOCKSHARPOBJ
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/tactical
	name = "tactical helmet"
	desc = "An armored helmet capable of being fitted with a multitude of attachments."
	icon_state = "swathelm"
	item_state = "helmet"
	flags_inventory = HIDEEARS|HIDEEYES|COVEREYES|BLOCKSHARPOBJ
	anti_hug = 1

	armor = list(melee = 62, bullet = 50, laser = 50,energy = 35, bomb = 10, bio = 2, rad = 0)
	flags_inventory = HIDEEARS
	siemens_coefficient = 0.7

//Non-hardsuit ERT helmets.
/obj/item/clothing/head/helmet/ert
	name = "emergency response team helmet"
	desc = "An in-atmosphere helmet worn by members of the Emergency Response Team. Protects the head from impacts."
	icon_state = "erthelmet_cmd"
	item_state = "syndicate-helm-green"
	armor = list(melee = 62, bullet = 50, laser = 50,energy = 35, bomb = 10, bio = 2, rad = 0)
	anti_hug = 5

//Commander
/obj/item/clothing/head/helmet/ert/command
	name = "emergency response team commander helmet"
	desc = "An in-atmosphere helmet worn by the commander of a Emergency Response Team. Has blue highlights."

//Security
/obj/item/clothing/head/helmet/ert/security
	name = "emergency response team security helmet"
	desc = "An in-atmosphere helmet worn by security members of the Emergency Response Team. Has red highlights."
	icon_state = "erthelmet_sec"

//Engineer
/obj/item/clothing/head/helmet/ert/engineer
	name = "emergency response team engineer helmet"
	desc = "An in-atmosphere helmet worn by engineering members of the Emergency Response Team. Has orange highlights."
	icon_state = "erthelmet_eng"

//Medical
/obj/item/clothing/head/helmet/ert/medical
	name = "emergency response team medical helmet"
	desc = "A set of armor worn by medical members of the Emergency Response Team. Has red and white highlights."
	icon_state = "erthelmet_med"





//===========================//MARINES HELMETS\\=================================\\
//=======================================================================\\


/obj/item/clothing/head/helmet/marine
	name = "\improper M10 pattern marine helmet"
	desc = "A standard M10 Pattern Helmet. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "helmet"
	item_state = "helmet"
	icon_override = 'icons/Marine/marine_armor.dmi'
	armor = list(melee = 65, bullet = 35, laser = 30, energy = 20, bomb = 25, bio = 0, rad = 0)
	health = 5
	var/helmet_overlays[]
	flags_inventory = HIDEEARS|BLOCKSHARPOBJ
	var/flags_marine_helmet = HELMET_SQUAD_OVERLAY|HELMET_GARB_OVERLAY|HELMET_DAMAGE_OVERLAY|HELMET_STORE_GARB
	var/obj/item/weapon/storage/internal/pockets
	var/list/allowed_helmet_items = list(
						/obj/item/weapon/flame/lighter/random = "helmet_lighter_",
						/obj/item/weapon/flame/lighter/zippo = "helmet_lighter_zippo",
						/obj/item/weapon/storage/box/matches = "helmet_matches",
						/obj/item/weapon/storage/fancy/cigarettes = "helmet_cig_kpack",
						/obj/item/weapon/storage/fancy/cigarettes/kpack = "helmet_cig_kpack",
						/obj/item/weapon/storage/fancy/cigarettes/lucky_strikes = "helmet_cig_ls",
						/obj/item/weapon/storage/fancy/cigarettes/dromedaryco = "helmet_cig_kpack",
						/obj/item/weapon/storage/fancy/cigarettes/lady_finger = "helmet_cig_lf",
						/obj/item/weapon/deck = "helmet_card_card",
						/obj/item/weapon/handcard = "helmet_card_card",
						/obj/item/weapon/reagent_containers/food/drinks/flask = "helmet_flask",
						/obj/item/weapon/reagent_containers/food/drinks/flask/marine = "helmet_flask",
						/obj/item/weapon/reagent_containers/food/snacks/eat_bar = "helmet_snack_eat",
						/obj/item/weapon/reagent_containers/food/snacks/packaged_burrito = "helmet_snack_burrito",
						/obj/item/clothing/glasses/mgoggles = "goggles",
						/obj/item/clothing/glasses/mgoggles/prescription = "goggles",
						/obj/item/fluff/val_mcneil_1 = "helmet_rosary",
						/obj/item/clothing/mask/mara_kilpatrick_1 = "helmet_rosary")


	New(loc,expected_type 		= /obj/item/clothing/head/helmet/marine,
		new_name[] 			= list(/datum/game_mode/ice_colony =  "\improper M10 pattern marine snow helmet"),
		new_protection[]	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature))
		var/icon_override[] = type == /obj/item/clothing/head/helmet/marine ? list(/datum/game_mode/ice_colony = "s_helmet[pick(200;1,2)]") : null
		select_gamemode_skin(expected_type,icon_override,new_name,new_protection)
		..()
		helmet_overlays = list("damage","band","item") //To make things simple.
		pockets = new/obj/item/weapon/storage/internal(src)
		pockets.storage_slots = 1
		pockets.max_w_class = 2
		pockets.max_combined_w_class = 2

	attack_hand(mob/user)
		if (pockets.handle_attack_hand(user))
			..()

	MouseDrop(over_object, src_location, over_location)
		if(pockets.handle_mousedrop(usr, over_object))
			..()

	attackby(obj/item/W, mob/user)
		..()
		return pockets.attackby(W, user)

	on_pocket_insertion()
		update_icon()

	on_pocket_removal()
		update_icon()

	update_icon()
		if(pockets.contents.len && (flags_marine_helmet & HELMET_GARB_OVERLAY))
			if(!helmet_overlays["band"])
				var/image/reusable/I = rnew(/image/reusable, list('icons/Marine/marine_armor.dmi', src, "helmet_band"))
				helmet_overlays["band"] = I

			if(!helmet_overlays["item"])
				var/obj/O = pockets.contents[1]
				if(O.type in allowed_helmet_items)
					var/image/reusable/I = rnew(/image/reusable, list('icons/Marine/marine_armor.dmi', src, "[allowed_helmet_items[O.type]][O.type == /obj/item/weapon/flame/lighter/random ? O:clr : ""]"))
					helmet_overlays["item"] = I

		else
			if(helmet_overlays["item"])
				var/image/reusable/RI = helmet_overlays["item"]
				helmet_overlays["item"] = null
				cdel(RI)
			if(helmet_overlays["band"])
				var/image/reusable/J = helmet_overlays["band"]
				helmet_overlays["band"] = null
				cdel(J)

		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_head()

/obj/item/clothing/head/helmet/marine/proc/add_hugger_damage() //This is called in XenoFacehuggers.dm to first add the overlay and set the var.
	if(flags_marine_helmet & HELMET_DAMAGE_OVERLAY && !(flags_marine_helmet & HELMET_IS_DAMAGED))
		helmet_overlays["damage"] = image('icons/Marine/marine_armor.dmi',icon_state = "hugger_damage")
		flags_marine_helmet |= HELMET_IS_DAMAGED
		update_icon()
		desc += "\n<b>This helmet seems to be scratched up and damaged, particularly around the face area...</b>"



/obj/item/clothing/head/helmet/marine/tech
	name = "\improper M10 technician helmet"
	icon_state = "helmett"
	item_color = "helmett"

	New(loc,expected_type 		= type,
		new_name[] 			= list(/datum/game_mode/ice_colony = "\improper M10 technician snow helmet"),
		new_protection[]	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature))
		..(loc,expected_type,new_name,new_protection)

/obj/item/clothing/head/helmet/marine/medic
	name = "\improper M10 medic helmet"
	icon_state = "helmetm"
	item_color = "helmetm"

	New(loc,expected_type 		= type,
		new_name[] 			= list(/datum/game_mode/ice_colony = "\improper M10 medic snow helmet"),
		new_protection[]	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature))
		..(loc,expected_type,new_name,new_protection)


/obj/item/clothing/head/helmet/marine/leader
	name = "\improper M11 pattern leader helmet"
	icon_state = "helml"
	desc = "A slightly fancier helmet for marine leaders. This one contains a small built-in camera and has cushioning to project your fragile brain."
	armor = list(melee = 75, bullet = 45, laser = 40, energy = 40, bomb = 35, bio = 10, rad = 10)
	var/obj/machinery/camera/camera

	New(loc,expected_type 		= type,
		new_name[] 			= list(/datum/game_mode/ice_colony = "\improper M11 pattern leader snow helmet"),
		new_protection[]	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature))
		..(loc,expected_type,new_name,new_protection)

		camera = new /obj/machinery/camera(src)
		camera.network = list("LEADER")

	equipped(var/mob/living/carbon/human/mob, slot)
		if(camera)
			camera.c_tag = mob.name
		..()

	dropped(var/mob/living/carbon/human/mob)
		if(camera)
			camera.c_tag = "Unknown"
		..()


/obj/item/clothing/head/helmet/marine/specialist
	name = "\improper B18 helmet"
	icon_state = "helml"
	desc = "The B18 Helmet that goes along with the B18 Defensive Armor. It's heavy, reinforced, and protects more of the face."
	icon_override = 'icons/Marine/marine_armor.dmi'
	armor = list(melee = 95, bullet = 105, laser = 75, energy = 65, bomb = 70, bio = 15, rad = 15)
	unacidable = 1
	anti_hug = 6

	New(loc,expected_type 		= type,
		new_name[] 			= list(/datum/game_mode/ice_colony = "\improper B18 snow helmet"),
		new_protection[]	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature))
		..(loc,expected_type,new_name,new_protection)

/obj/item/clothing/head/helmet/marine/pilot
	name = "\improper M30 tactical helmet"
	desc = "The M30 tactical helmet has an left eyepiece filter used to filter tactical data. It is required to fly the Rasputin dropship manually and in safety."
	icon_state = "helmetp"
	armor = list(melee = 65, bullet = 50, laser = 35, energy = 45, bomb = 30, bio = 15, rad = 15)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	flags_inventory = HIDEEARS|HIDETOPHAIR|BLOCKSHARPOBJ
	flags_marine_helmet = NOFLAGS

//=============================//PMCS\\==================================\\
//=======================================================================\\

/obj/item/clothing/head/helmet/marine/veteran/PMC
	name = "\improper PMC tactical cap"
	desc = "A protective cap made from flexable kevlar. Standard issue for most security forms in the place of a helmet."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "helmet"
	icon_state = "pmc_hat"
	armor = list(melee = 38, bullet = 38, laser = 32, energy = 22, bomb = 12, bio = 5, rad = 5)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	flags_inventory = BLOCKSHARPOBJ
	flags_marine_helmet = NOFLAGS

/obj/item/clothing/head/helmet/marine/veteran/PMC/leader
	name = "\improper PMC beret"
	desc = "The pinacle of fashion for any aspiring mercenary leader. Designed to protect the head from light impacts."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "officer_hat"
	icon_state = "officer_hat"

/obj/item/clothing/head/helmet/marine/veteran/PMC/sniper
	name = "\improper PMC sniper helmet"
	desc = "A helmet worn by PMC Marksmen"
	item_state = "pmc_sniper_hat"
	icon_state = "pmc_sniper_hat"
	flags_armor_protection = HEAD|FACE|EYES
	armor = list(melee = 55, bullet = 65, laser = 45, energy = 55, bomb = 60, bio = 10, rad = 10)
	flags_inventory = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|COVEREYES|COVERMOUTH|HIDEALLHAIR|BLOCKSHARPOBJ
	flags_marine_helmet = HELMET_DAMAGE_OVERLAY

/obj/item/clothing/head/helmet/marine/veteran/PMC/gunner
	name = "\improper PMC gunner helmet"
	desc = "A modification of the standard Armat Systems M3 armor."
	item_state = "heavy_helmet"
	icon_state = "heavy_helmet"
	flags_armor_protection = HEAD|FACE|EYES
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 60, bomb = 70, bio = 10, rad = 10)
	flags_inventory = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|COVEREYES|COVERMOUTH|HIDEALLHAIR|BLOCKSHARPOBJ
	flags_marine_helmet = HELMET_DAMAGE_OVERLAY

/obj/item/clothing/head/helmet/marine/veteran/PMC/commando
	name = "\improper PMC commando helmet"
	desc = "A fully enclosed, armored helmet made for Weyland Yutani elite commandos."
	item_state = "commando_helmet"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "commando_helmet"
	icon_override = 'icons/PMC/PMC.dmi'
	flags_armor_protection = HEAD|FACE|EYES
	armor = list(melee = 90, bullet = 120, laser = 90, energy = 90, bomb = 90, bio = 100, rad = 100)
	flags_inventory = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|COVEREYES|COVERMOUTH|HIDEALLHAIR|BLOCKSHARPOBJ|BLOCKGASEFFECT
	flags_marine_helmet = HELMET_DAMAGE_OVERLAY
	unacidable = 1

//==========================//DISTRESS\\=================================\\
//=======================================================================\\

/obj/item/clothing/head/helmet/marine/veteran/dutch
	name = "\improper Dutch's Dozen helmet"
	desc = "A protective helmet worn by some seriously experienced mercs."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "dutch_helmet"
	icon_state = "dutch_helmet"
	armor = list(melee = 70, bullet = 70, laser = 0,energy = 20, bomb = 0, bio = 0, rad = 0)
	flags_marine_helmet = HELMET_GARB_OVERLAY|HELMET_DAMAGE_OVERLAY|HELMET_STORE_GARB

/obj/item/clothing/head/helmet/marine/veteran/dutch/cap
	name = "\improper Dutch's Dozen cap"
	desc = "A protective cap worn by some seriously experienced mercs."
	item_state = "dutch_cap"
	icon_state = "dutch_cap"
	flags_inventory = BLOCKSHARPOBJ
	flags_marine_helmet = NOFLAGS

/obj/item/clothing/head/helmet/marine/veteran/dutch/band
	name = "\improper Dutch's Dozen band"
	desc = "A protective band worn by some seriously experienced mercs."
	item_state = "dutch_band"
	icon_state = "dutch_band"
	flags_inventory = BLOCKSHARPOBJ
	flags_marine_helmet = NOFLAGS

/obj/item/clothing/head/helmet/marine/veteran/bear
	name = "\improper Iron Bear helmet"
	desc = "Is good for winter, because it has hole to put vodka through."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "dutch_helmet"
	icon_state = "dutch_helmet"
	armor = list(melee = 90, bullet = 65, laser = 40, energy = 35, bomb = 35, bio = 5, rad = 5)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	flags_marine_helmet = HELMET_GARB_OVERLAY|HELMET_DAMAGE_OVERLAY|HELMET_STORE_GARB

/obj/item/clothing/head/helmet/UPP
	name = "\improper UM4 helmet"
	desc = "A skirted helmet designed for use with the UM/UH system."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "upp_helmet1"
	icon_state = "upp_helmet1"
	armor = list(melee = 70, bullet = 55, laser = 40, energy = 35, bomb = 35, bio = 5, rad = 5)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature

/obj/item/clothing/head/helmet/UPP/heavy
	name = "\improper UH7 helmet"
	item_state = "upp_helmet_heavy"
	icon_state = "upp_helmet_heavy"
	armor = list(melee = 90, bullet = 85, laser = 60, energy = 65, bomb = 85, bio = 5, rad = 5)
	unacidable = 1
	anti_hug = 3



//head rag

/obj/item/clothing/head/helmet/specrag
	name = "specialist head-rag"
	desc = "A hat worn by heavy-weapons operators to block sweat."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_override = 'icons/Marine/marine_armor.dmi'
	icon_state = "spec"
	item_state = "spec"
	item_color = "spec"
	armor = list(melee = 35, bullet = 35, laser = 35, energy = 15, bomb = 10, bio = 0, rad = 0)
	flags_inventory = HIDEEARS|HIDETOPHAIR|BLOCKSHARPOBJ

	New()
		select_gamemode_skin(type)
		..()

/obj/item/clothing/head/helmet/durag
	name = "durag"
	desc = "Good for keeping sweat out of your eyes"
	icon = 'icons/Marine/marine_armor.dmi'
	item_state = "durag"
	icon_state = "durag"
	armor = list(melee = 35, bullet = 35, laser = 35, energy = 15, bomb = 10, bio = 0, rad = 0)
	flags_inventory = HIDEEARS|HIDETOPHAIR|BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/durag/jungle
	name = "\improper M8 marksman cowl"
	desc = "A cowl worn to conceal the face of a marksman in the jungle."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "duragm"
	item_state = "duragm"

	New(loc,expected_type 	= type,
		new_name[] 		= list(/datum/game_mode/ice_colony = "\improper M6 marksman hood"),
		new_protection[] 	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature))
		select_gamemode_skin(expected_type,,new_name,new_protection)
		..()
		switch(icon_state)
			if("s_duragm")
				desc = "A hood meant to protect the wearer from both the cold and the guise of the enemy in the tundra."
				flags_inventory = HIDEEARS|HIDEALLHAIR|BLOCKSHARPOBJ

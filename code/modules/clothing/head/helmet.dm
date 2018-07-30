
/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	item_state = "helmet"
	armor = list(melee = 50, bullet = 15, laser = 50,energy = 10, bomb = 25, bio = 0, rad = 0)
	flags_atom = FPRINT|CONDUCT
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES
	flags_cold_protection = HEAD
	flags_heat_protection = HEAD
	min_cold_protection_temperature = HELMET_min_cold_protection_temperature
	max_heat_protection_temperature = HELMET_max_heat_protection_temperature
	siemens_coefficient = 0.7
	w_class = 4



/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks. It covers your ears."
	icon_state = "riot"
	armor = list(melee = 82, bullet = 15, laser = 5, energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDETOPHAIR

/obj/item/clothing/head/helmet/augment
	name = "augment array"
	desc = "A helmet with optical and cranial augments coupled to it."
	icon_state = "v62"
	item_state = "v62"
	armor = list(melee = 80, bullet = 60, laser = 50, energy = 25, bomb = 50, bio = 10, rad = 0)
	siemens_coefficient = 0.5

/obj/item/clothing/head/helmet/HoS
	name = "Head of Security Hat"
	desc = "The hat of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	flags_inventory = COVEREYES
	flags_inv_hide = HIDEEARS
	flags_armor_protection = 0
	siemens_coefficient = 0.8

/obj/item/clothing/head/helmet/HoS/dermal
	name = "Dermal Armour Patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head."
	icon_state = "dermal"
	item_state = "dermal"
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a securiy force. Protects the head from impacts."
	icon_state = "policehelm"
	flags_inventory = NOFLAGS
	flags_inv_hide = NOFLAGS
	flags_armor_protection = 0

/obj/item/clothing/head/helmet/hop
	name = "crew resource's hat"
	desc = "A stylish hat that both protects you from enraged former-crewmembers and gives you a false sense of authority."
	icon_state = "hopcap"
	flags_inventory = NOFLAGS
	flags_inv_hide = NOFLAGS
	flags_armor_protection = 0

/obj/item/clothing/head/helmet/formalcaptain
	name = "parade hat"
	desc = "No one in a commanding position should be without a perfect, white hat of ultimate authority."
	icon_state = "officercap"
	flags_inventory = NOFLAGS
	flags_inv_hide = NOFLAGS
	flags_armor_protection = 0

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	item_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES
	flags_cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_min_cold_protection_temperature
	siemens_coefficient = 0.5
	anti_hug = 1

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES
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
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEALLHAIR
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/tactical
	name = "tactical helmet"
	desc = "An armored helmet capable of being fitted with a multitude of attachments."
	icon_state = "swathelm"
	item_state = "helmet"
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES
	anti_hug = 1
	armor = list(melee = 62, bullet = 50, laser = 50,energy = 35, bomb = 10, bio = 2, rad = 0)
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
	desc = "A standard M10 Pattern Helmet. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'. Contains a small built-in camera."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "helmet"
	armor = list(melee = 65, bullet = 35, laser = 30, energy = 20, bomb = 25, bio = 0, rad = 0)
	health = 5
	var/obj/machinery/camera/camera
	var/helmet_overlays[]
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS
	var/flags_marine_helmet = HELMET_SQUAD_OVERLAY|HELMET_GARB_OVERLAY|HELMET_DAMAGE_OVERLAY|HELMET_STORE_GARB
	var/obj/item/storage/internal/pockets
	var/list/allowed_helmet_items = list(
						/obj/item/tool/lighter/random = "helmet_lighter_",
						/obj/item/tool/lighter/zippo = "helmet_lighter_zippo",
						/obj/item/storage/box/matches = "helmet_matches",
						/obj/item/storage/fancy/cigarettes = "helmet_cig_kpack",
						/obj/item/storage/fancy/cigarettes/kpack = "helmet_cig_kpack",
						/obj/item/storage/fancy/cigarettes/lucky_strikes = "helmet_cig_ls",
						/obj/item/storage/fancy/cigarettes/dromedaryco = "helmet_cig_kpack",
						/obj/item/storage/fancy/cigarettes/lady_finger = "helmet_cig_lf",
						/obj/item/toy/deck = "helmet_card_card",
						/obj/item/toy/handcard = "helmet_card_card",
						/obj/item/reagent_container/food/drinks/flask = "helmet_flask",
						/obj/item/reagent_container/food/drinks/flask/marine = "helmet_flask",
						/obj/item/reagent_container/food/snacks/eat_bar = "helmet_snack_eat",
						/obj/item/reagent_container/food/snacks/packaged_burrito = "helmet_snack_burrito",
						/obj/item/clothing/glasses/mgoggles = "goggles",
						/obj/item/clothing/glasses/mgoggles/prescription = "goggles")


/obj/item/clothing/head/helmet/marine/New(loc,expected_type 		= /obj/item/clothing/head/helmet/marine,
	new_name[] 			= list(MAP_ICE_COLONY =  "\improper M10 pattern marine snow helmet"),
	new_protection[]	= list(MAP_ICE_COLONY = ICE_PLANET_min_cold_protection_temperature))
	select_gamemode_skin(expected_type,null,new_name,new_protection)
	..()
	helmet_overlays = list("damage","band","item") //To make things simple.
	pockets = new/obj/item/storage/internal(src)
	pockets.storage_slots = 2
	pockets.max_w_class = 1 //can hold tiny items only, EXCEPT for glasses & metal flask.
	pockets.bypass_w_limit = list("/obj/item/clothing/glasses", "/obj/item/reagent_container/food/drinks/flask")
	pockets.max_storage_space = 3

	camera = new /obj/machinery/camera(src)
	camera.network = list("LEADER")

/obj/item/clothing/head/helmet/marine/attack_hand(mob/user)
	if (pockets.handle_attack_hand(user))
		..()

/obj/item/clothing/head/helmet/marine/MouseDrop(over_object, src_location, over_location)
	if(pockets.handle_mousedrop(usr, over_object))
		..()

/obj/item/clothing/head/helmet/marine/attackby(obj/item/W, mob/user)
	..()
	return pockets.attackby(W, user)

/obj/item/clothing/head/helmet/marine/on_pocket_insertion()
	update_icon()

/obj/item/clothing/head/helmet/marine/on_pocket_removal()
	update_icon()

/obj/item/clothing/head/helmet/marine/update_icon()
	if(pockets.contents.len && (flags_marine_helmet & HELMET_GARB_OVERLAY))
		if(!helmet_overlays["band"])
			var/image/reusable/I = rnew(/image/reusable, list('icons/obj/clothing/cm_hats.dmi', src, "helmet_band"))
			helmet_overlays["band"] = I

		if(!helmet_overlays["item"])
			var/obj/O = pockets.contents[1]
			if(O.type in allowed_helmet_items)
				var/image/reusable/I = rnew(/image/reusable, list('icons/obj/clothing/cm_hats.dmi', src, "[allowed_helmet_items[O.type]][O.type == /obj/item/tool/lighter/random ? O:clr : ""]"))
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

/obj/item/clothing/head/helmet/marine/equipped(var/mob/living/carbon/human/mob, slot)
	if(camera)
		camera.c_tag = mob.name
	..()

/obj/item/clothing/head/helmet/marine/dropped(var/mob/living/carbon/human/mob)
	if(camera)
		camera.c_tag = "Unknown"
	..()


/obj/item/clothing/head/helmet/marine/proc/add_hugger_damage() //This is called in XenoFacehuggers.dm to first add the overlay and set the var.
	if(flags_marine_helmet & HELMET_DAMAGE_OVERLAY && !(flags_marine_helmet & HELMET_IS_DAMAGED))
		helmet_overlays["damage"] = image('icons/obj/clothing/cm_hats.dmi',icon_state = "hugger_damage")
		flags_marine_helmet |= HELMET_IS_DAMAGED
		update_icon()
		desc += "\n<b>This helmet seems to be scratched up and damaged, particularly around the face area...</b>"



/obj/item/clothing/head/helmet/marine/tech
	name = "\improper M10 technician helmet"

/obj/item/clothing/head/helmet/marine/tech/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper M10 technician snow helmet"),
	new_protection[]	= list(MAP_ICE_COLONY = ICE_PLANET_min_cold_protection_temperature))
	..(loc,expected_type,new_name,new_protection)

/obj/item/clothing/head/helmet/marine/medic
	name = "\improper M10 medic helmet"

/obj/item/clothing/head/helmet/marine/medic/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper M10 medic snow helmet"),
	new_protection[]	= list(MAP_ICE_COLONY = ICE_PLANET_min_cold_protection_temperature))
	..(loc,expected_type,new_name,new_protection)


/obj/item/clothing/head/helmet/marine/leader
	name = "\improper M11 pattern leader helmet"
	desc = "A slightly fancier helmet for marine leaders. This one contains a small built-in camera and has cushioning to project your fragile brain."
	armor = list(melee = 75, bullet = 45, laser = 40, energy = 40, bomb = 35, bio = 10, rad = 10)

/obj/item/clothing/head/helmet/marine/leader/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper M11 pattern leader snow helmet"),
	new_protection[]	= list(MAP_ICE_COLONY = ICE_PLANET_min_cold_protection_temperature))
	..(loc,expected_type,new_name,new_protection)

/obj/item/clothing/head/helmet/marine/specialist
	name = "\improper B18 helmet"
	desc = "The B18 Helmet that goes along with the B18 Defensive Armor. It's heavy, reinforced, and protects more of the face."
	armor = list(melee = 95, bullet = 105, laser = 75, energy = 65, bomb = 70, bio = 15, rad = 15)
	unacidable = 1
	anti_hug = 6

/obj/item/clothing/head/helmet/marine/specialist/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper B18 snow helmet"),
	new_protection[]	= list(MAP_ICE_COLONY = ICE_PLANET_min_cold_protection_temperature))
	..(loc,expected_type,new_name,new_protection)

/obj/item/clothing/head/helmet/marine/scout
	name = "\improper M3-S helmet"
	icon_state = "scout_helmet"
	desc = "A custom helmet designed for USCM Scouts."
	armor = list(melee = 75, bullet = 45, laser = 40, energy = 40, bomb = 35, bio = 10, rad = 10)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature

	New()
		select_gamemode_skin(type)
		..()

/obj/item/clothing/head/helmet/marine/pyro
	name = "\improper M35 helmet"
	icon_state = "pyro_helmet"
	desc = "A helmet designed for USCM Pyrotechnicians."
	armor = list(melee = 85, bullet = 75, laser = 60, energy = 50, bomb = 50, bio = 10, rad = 10)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	max_heat_protection_temperature = FIRESUIT_max_heat_protection_temperature

	New()
		select_gamemode_skin(type)
		..()

/obj/item/clothing/head/helmet/marine/pilot
	name = "\improper M30 tactical helmet"
	desc = "The M30 tactical helmet has an left eyepiece filter used to filter tactical data. It is required to fly the Rasputin dropship manually and in safety."
	icon_state = "helmetp"
	armor = list(melee = 65, bullet = 50, laser = 35, energy = 45, bomb = 30, bio = 15, rad = 15)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDETOPHAIR
	flags_marine_helmet = NOFLAGS
	New()
		select_gamemode_skin(/obj/item/clothing/head/helmet/marine/pilot)
		..()

/obj/item/clothing/head/helmet/marine/tanker
	name = "\improper M50 tanker helmet"
	desc = "The lightweight M50 tanker helmet is designed for use by armored crewmen in the USCM. It offers low weight protection, and allows agile movement inside the confines of an armored vehicle."
	icon_state = "tanker_helmet"
	armor = list(melee = 40, bullet = 40, laser = 35, energy = 45, bomb = 30, bio = 15, rad = 15)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDETOPHAIR
	flags_marine_helmet = NOFLAGS
	New()
		select_gamemode_skin(/obj/item/clothing/head/helmet/marine/tanker)
		..()

//=============================//PMCS\\==================================\\
//=======================================================================\\

/obj/item/clothing/head/helmet/marine/veteran

/obj/item/clothing/head/helmet/marine/veteran/PMC
	name = "\improper PMC tactical cap"
	desc = "A protective cap made from flexible kevlar. Standard issue for most security forms in the place of a helmet."
	icon_state = "pmc_hat"
	armor = list(melee = 38, bullet = 38, laser = 32, energy = 22, bomb = 12, bio = 5, rad = 5)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = NOFLAGS
	flags_marine_helmet = NOFLAGS

/obj/item/clothing/head/helmet/marine/veteran/PMC/leader
	name = "\improper PMC beret"
	desc = "The pinacle of fashion for any aspiring mercenary leader. Designed to protect the head from light impacts."
	icon_state = "officer_hat"

/obj/item/clothing/head/helmet/marine/veteran/PMC/sniper
	name = "\improper PMC sniper helmet"
	desc = "A helmet worn by PMC Marksmen"
	icon_state = "pmc_sniper_hat"
	flags_armor_protection = HEAD|FACE|EYES
	armor = list(melee = 55, bullet = 65, laser = 45, energy = 55, bomb = 60, bio = 10, rad = 10)
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR
	flags_marine_helmet = HELMET_DAMAGE_OVERLAY

/obj/item/clothing/head/helmet/marine/veteran/PMC/gunner
	name = "\improper PMC gunner helmet"
	desc = "A modification of the standard Armat Systems M3 armor."
	icon_state = "heavy_helmet"
	flags_armor_protection = HEAD|FACE|EYES
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 60, bomb = 70, bio = 10, rad = 10)
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR
	flags_marine_helmet = HELMET_DAMAGE_OVERLAY

/obj/item/clothing/head/helmet/marine/veteran/PMC/commando
	name = "\improper PMC commando helmet"
	desc = "A fully enclosed, armored helmet made for Weyland Yutani elite commandos."
	icon_state = "commando_helmet"
	flags_armor_protection = HEAD|FACE|EYES
	armor = list(melee = 90, bullet = 120, laser = 90, energy = 90, bomb = 90, bio = 100, rad = 100)
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ|BLOCKGASEFFECT
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR
	flags_marine_helmet = HELMET_DAMAGE_OVERLAY
	unacidable = 1

//==========================//DISTRESS\\=================================\\
//=======================================================================\\

/obj/item/clothing/head/helmet/marine/veteran/dutch
	name = "\improper Dutch's Dozen helmet"
	desc = "A protective helmet worn by some seriously experienced mercs."
	icon_state = "dutch_helmet"
	armor = list(melee = 70, bullet = 70, laser = 0,energy = 20, bomb = 0, bio = 0, rad = 0)
	flags_marine_helmet = HELMET_GARB_OVERLAY|HELMET_DAMAGE_OVERLAY|HELMET_STORE_GARB

/obj/item/clothing/head/helmet/marine/veteran/dutch/cap
	name = "\improper Dutch's Dozen cap"
	desc = "A protective cap worn by some seriously experienced mercs."
	icon_state = "dutch_cap"
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = NOFLAGS
	flags_marine_helmet = NOFLAGS

/obj/item/clothing/head/helmet/marine/veteran/dutch/band
	name = "\improper Dutch's Dozen band"
	desc = "A protective band worn by some seriously experienced mercs."
	icon_state = "dutch_band"
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = NOFLAGS
	flags_marine_helmet = NOFLAGS

/obj/item/clothing/head/helmet/marine/veteran/bear
	name = "\improper Iron Bear helmet"
	desc = "Is good for winter, because it has hole to put vodka through."
	icon_state = "dutch_helmet"
	armor = list(melee = 90, bullet = 65, laser = 40, energy = 35, bomb = 35, bio = 5, rad = 5)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	flags_marine_helmet = HELMET_GARB_OVERLAY|HELMET_DAMAGE_OVERLAY|HELMET_STORE_GARB

/obj/item/clothing/head/helmet/UPP
	name = "\improper UM4 helmet"
	desc = "A skirted helmet designed for use with the UM/UH system."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "upp_helmet1"
	armor = list(melee = 70, bullet = 55, laser = 40, energy = 35, bomb = 35, bio = 5, rad = 5)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature

/obj/item/clothing/head/helmet/UPP/heavy
	name = "\improper UH7 helmet"
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "upp_helmet_heavy"
	armor = list(melee = 90, bullet = 85, laser = 60, energy = 65, bomb = 85, bio = 5, rad = 5)
	unacidable = 1
	anti_hug = 3



//head rag

/obj/item/clothing/head/helmet/specrag
	name = "specialist head-rag"
	desc = "A hat worn by heavy-weapons operators to block sweat."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "spec"
	armor = list(melee = 35, bullet = 35, laser = 35, energy = 15, bomb = 10, bio = 0, rad = 0)
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDETOPHAIR

/obj/item/clothing/head/helmet/specrag/New()
	select_gamemode_skin(type)
	..()

/obj/item/clothing/head/helmet/durag
	name = "durag"
	desc = "Good for keeping sweat out of your eyes"
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "durag"
	armor = list(melee = 35, bullet = 35, laser = 35, energy = 15, bomb = 10, bio = 0, rad = 0)
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDETOPHAIR

/obj/item/clothing/head/helmet/durag/jungle
	name = "\improper M8 marksman cowl"
	desc = "A cowl worn to conceal the face of a marksman in the jungle."
	icon_state = "duragm"

/obj/item/clothing/head/helmet/durag/jungle/New(loc,expected_type 	= type,
	new_name[] 		= list(MAP_ICE_COLONY = "\improper M6 marksman hood"),
	new_protection[] 	= list(MAP_ICE_COLONY = ICE_PLANET_min_cold_protection_temperature))
	select_gamemode_skin(expected_type,,new_name,new_protection)
	..()
	switch(icon_state)
		if("s_duragm")
			desc = "A hood meant to protect the wearer from both the cold and the guise of the enemy in the tundra."
			flags_inventory = BLOCKSHARPOBJ
			flags_inv_hide = HIDEEARS|HIDEALLHAIR

//===========================//HELGHAST - MERCENARY\\================================\\
//=====================================================================\\

/obj/item/clothing/head/helmet/marine/veteran/mercenary
	name = "\improper K12 ceramic helmet"
	desc = "A sturdy helmet worn by an unknown mercenary group."
	icon_state = "mercenary_heavy_helmet"
	flags_armor_protection = HEAD|FACE|EYES
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 60, bomb = 70, bio = 10, rad = 10)
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR
	flags_marine_helmet = HELMET_DAMAGE_OVERLAY

/obj/item/clothing/head/helmet/marine/veteran/mercenary/miner
	name = "\improper Y8 miner helmet"
	desc = "A sturdy helmet worn by an unknown mercenary group."
	icon_state = "mercenary_miner_helmet"
	flags_armor_protection = HEAD|FACE|EYES
	armor = list(melee = 55, bullet = 55, laser = 45, energy = 55, bomb = 55, bio = 10, rad = 10)


/obj/item/clothing/head/helmet/marine/veteran/mercenary/engineer
	name = "\improper Z7 engineer helmet"
	desc = "A sturdy helmet worn by an unknown mercenary group."
	icon_state = "mercenary_engineer_helmet"
	flags_armor_protection = HEAD|FACE|EYES
	armor = list(melee = 55, bullet = 60, laser = 45, energy = 55, bomb = 60, bio = 10, rad = 10)

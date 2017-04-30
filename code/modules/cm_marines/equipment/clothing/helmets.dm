//===========================//HELMETS\\=================================\\
//=======================================================================\\

/*Any helmet with antihug properties should go in here. Other headwear,
protective or not, should go in to hats.dm. Try to rank them by overall protection.*/

//=======================================================================\\
//=======================================================================\\


//=============================//MISC\\==================================\\
//=======================================================================\\

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
	anti_hug = 1

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
	anti_hug = 3

//===========================//MARINES\\=================================\\
//=======================================================================\\

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

/obj/item/clothing/head/helmet/marine
	name = "\improper M10 pattern marine helmet"
	desc = "A standard M10 Pattern Helmet. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "helmet"
	item_state = "helmet"
	icon_override = 'icons/Marine/marine_armor.dmi'
	armor = list(melee = 65, bullet = 35, laser = 30, energy = 20, bomb = 25, bio = 0, rad = 0)
	health = 5
	var/helmet_garb[] //What items are stored in the helmet as garb, capped at 3.
	var/helmet_overlays[]
	flags_inventory = HIDEEARS|BLOCKSHARPOBJ
	var/flags_marine_helmet = HELMET_SQUAD_OVERLAY|HELMET_GARB_OVERLAY|HELMET_DAMAGE_OVERLAY|HELMET_STORE_GARB

	New(loc,expected_type 		= /obj/item/clothing/head/helmet/marine,
		new_name[] 			= list(/datum/game_mode/ice_colony =  "\improper M10 pattern marine snow helmet"),
		new_protection[]	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature))
		var/icon_override[] = type == /obj/item/clothing/head/helmet/marine ? list(/datum/game_mode/ice_colony = "s_helmet[pick(200;1,2)]") : null
		select_gamemode_skin(expected_type,icon_override,new_name,new_protection)
		..()
		helmet_garb = list()
		helmet_overlays = list("damage","band","garb1","garb2","garb3") //To make things simple.

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
	anti_hug = 2
	var/obj/machinery/camera/camera

	New(loc,expected_type 		= type,
		new_name[] 			= list(/datum/game_mode/ice_colony = "\improper M11 pattern leader snow helmet"),
		new_protection[]	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature))
		..(loc,expected_type,new_name,new_protection)

		camera = new /obj/machinery/camera(src)
		camera.network = list("LEADER")

/obj/item/clothing/head/helmet/marine/specialist
	name = "\improper B18 helmet"
	icon_state = "helml"
	desc = "The B18 Helmet that goes along with the B18 Defensive Armor. It's heavy, reinforced, and protects more of the face."
	icon_override = 'icons/Marine/marine_armor.dmi'
	armor = list(melee = 95, bullet = 105, laser = 75, energy = 65, bomb = 70, bio = 15, rad = 15)
	anti_hug = 3
	unacidable = 1

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
	anti_hug = 2
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
	anti_hug = 3

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
	anti_hug = 4

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
	anti_hug = 8
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
	anti_hug = 2
	flags_marine_helmet = HELMET_GARB_OVERLAY|HELMET_DAMAGE_OVERLAY|HELMET_STORE_GARB

/obj/item/clothing/head/helmet/space/compression
	name = "\improper MK.50 compression helmet"
	desc = "A heavy space helmet, designed to be coupled with the MK.50 compression suit, though it is less resilient than the suit. Feels like you could hotbox in here."
	item_state = "compression"
	icon_state = "compression"
	armor = list(melee = 40, bullet = 45, laser = 40, energy = 55, bomb = 40, bio = 100, rad = 50)
	anti_hug = 3
	unacidable = 1

//==========================//HELMET PROCS\\=============================\\
//=======================================================================\\

/obj/item/clothing/head/helmet/marine/proc/add_hugger_damage() //This is called in XenoFacehuggers.dm to first add the overlay and set the var.
	if(flags_marine_helmet & HELMET_DAMAGE_OVERLAY && !(flags_marine_helmet & HELMET_IS_DAMAGED))
		helmet_overlays["damage"] = image('icons/Marine/marine_armor.dmi',icon_state = "hugger_damage")
		overlays += helmet_overlays["damage"]
		flags_marine_helmet |= HELMET_IS_DAMAGED
		if(ismob(loc)) update_icon(loc)
		desc += "\n<b>This helmet seems to be scratched up and damaged, particularly around the face area...</b>"

/obj/item/clothing/head/helmet/marine
	examine()
		if(contents.len)
			var/dat = "<br><br>There is something attached to [src]:<br><br>"
			for(var/obj/O in src)
				dat += "\blue *\icon[O] - [O]<br>"
		..()

	update_icon(mob/user, directive = 0) //Defaults to taking things from the helmet.
		if(!(flags_marine_helmet & HELMET_GARB_OVERLAY) && directive != 2) return

		var/image/reusable/I
		switch(directive)
			if(1,2) //We are removing an overlay/s.
				var/c
				var/l =  directive == 2? helmet_garb.len : 1
				for(var/i = 1 to l)
					c = "garb[directive == 2? i : helmet_garb.len + 1]"
					I = helmet_overlays[c]
					overlays -= I
					cdel(I)
					helmet_overlays[c] = null

			else //We are adding an overlay.
				var/allowed_items[] = return_allowed_items()
				var/obj/O
				 //It will either have no overlays, or it will have at least the first.
				for(var/i = helmet_overlays["garb1"]? helmet_garb.len : 1 to helmet_garb.len)
					O = helmet_garb[i]
					I = rnew(/image/reusable, list('icons/mob/helmet_garb.dmi', src, "[allowed_items[O.type]][O.type == /obj/item/weapon/flame/lighter/random ? O:clr : ""]"))
					helmet_overlays["garb[i]"] = I
					overlays += I

		//Create a band overlay.
		I = helmet_overlays["band"]
		overlays -= I
		cdel(I)
		if(helmet_garb.len && directive != 2)
			I = rnew(/image/reusable, list('icons/mob/helmet_garb.dmi', src, "helmet_band"))
			helmet_overlays["band"] = I
			overlays += I
		else helmet_overlays["band"] = null

		user.update_inv_head()

	attackby(obj/item/W, mob/user)
		if(!(flags_marine_helmet & HELMET_STORE_GARB))
			user << "<span class='warning'>[src] cannot hold any items!</span>"
			return
		var/allowed_items[] = return_allowed_items()
		if(W.type in allowed_items)
			if(helmet_garb.len < 3)
				user.temp_drop_inv_item(W)
				W.forceMove(src)
				helmet_garb += W
				user.visible_message("<span class='notice'>[user] puts [W] on [src].</span>","<span class='info'>You put [W] on [src].</span>")
				update_icon(user)
			else user << "<span class='warning'>There is no more space for [W]!</span>"
		else if(istype(W, /obj/item/weapon/claymore/mercsword/machete))
			user.visible_message("<span class='warning'>[user] tries to put [W] on [src] like a pro, <b>but fails miserably and looks like an idiot...</b></span>","<span class='warning'>You try to put [W] on [src], but there simply isn't enough space! <b><i>Maybe I should try again?</i></b></span>")
		else user << "<span class='warning'>[W] does not fit on [src]!</span>"

	MouseDrop(over_object, src_location, over_location)
		if(!ishuman(usr)) return
		var/mob/living/carbon/human/user = usr
		if((over_object == user && (in_range(src, user) || locate(src) in user)))
			if(helmet_garb.len)
				var/obj/item/choice = input("What item would you like to remove from [src]?") as null|obj in helmet_garb
				if(choice)
					if((!user.canmove && !user.buckled) || user.stat || user.restrained() || !in_range(src, user) || !locate(src) in user) return
					user.put_in_hands(choice)
					helmet_garb -= choice
					user.visible_message("<span class='info'>[user] removes [choice] from [src].</span>","<span class='notice'>You remove [choice] from [src].</span>")
					update_icon(user,1)

			else user << "<span class='warning'>There is nothing attached to [src]!<span>"

/obj/item/clothing/head/helmet/marine/proc/return_allowed_items()
	var/allowed_items[] = list(
						/obj/item/weapon/flame/lighter/random = "helmet_lighter_",
						/obj/item/weapon/flame/lighter/zippo = "helmet_lighter_zippo",
						/obj/item/weapon/storage/box/matches = "helmet_matches",
						/obj/item/weapon/storage/fancy/cigarettes = "helmet_cig_kpack",
						/obj/item/weapon/storage/fancy/cigarettes/kpack = "helmet_cig_kpack",
						/obj/item/weapon/storage/fancy/cigarettes/lucky_strikes = "helmet_cig_ls",
						/obj/item/weapon/storage/fancy/cigarettes/dromedaryco = "helmet_cig_kpack",
						/obj/item/weapon/storage/fancy/cigarettes/lady_finger = "helmet_cig_lf",
						/obj/item/weapon/deck = "helmet_card_card",
						/obj/item/weapon/hand = "helmet_card_card",
						/obj/item/weapon/reagent_containers/food/drinks/flask = "helmet_flask",
						/obj/item/weapon/reagent_containers/food/drinks/flask/marine = "helmet_flask",
						/obj/item/weapon/reagent_containers/food/snacks/eat_bar = "helmet_snack_eat",
						/obj/item/weapon/reagent_containers/food/snacks/packaged_burrito = "helmet_snack_burrito",
						/obj/item/clothing/glasses/mgoggles = "goggles",
						/obj/item/clothing/glasses/mgoggles/prescription = "goggles",
						/obj/item/fluff/val_mcneil_1 = "helmet_rosary",
						/obj/item/clothing/mask/mara_kilpatrick_1 = "helmet_rosary")
	. = allowed_items

/obj/item/clothing/head/helmet/marine/leader
	equipped(var/mob/living/carbon/human/mob, slot)
		if(camera)
			camera.c_tag = mob.name
		..()

	dropped(var/mob/living/carbon/human/mob)
		if(camera)
			camera.c_tag = "Unknown"
		..()

/obj/item/clothing/head/ushanka
	attack_self(mob/user as mob)
		if(src.icon_state == "ushankadown")
			src.icon_state = "ushankaup"
			src.item_state = "ushankaup"
			user << "You raise the ear flaps on the ushanka."
		else
			src.icon_state = "ushankadown"
			src.item_state = "ushankadown"
			user << "You lower the ear flaps on the ushanka."
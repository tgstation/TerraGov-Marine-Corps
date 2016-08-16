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
	flags = FPRINT | CONDUCT
	flags_inv = HIDEEARS | HIDEEYES | COVEREYES | BLOCKSHARPOBJ
	cold_protection = HEAD
	heat_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7
	w_class = 5
	anti_hug = 1

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	armor = list(melee = 82, bullet = 15, laser = 5, energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inv = HIDEEARS | HIDEEYES | COVEREYES | HIDETOPHAIR | BLOCKSHARPOBJ

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
	flags_inv = HIDEEARS | HIDETOPHAIR | BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/specrag/snow
	icon_state = "s_spec"
	item_state = "s_spec"
	item_color = "s_spec"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/durag
	name = "durag"
	desc = "Good for keeping sweat out of your eyes"
	icon = 'icons/obj/clothing/hats.dmi'
	item_state = "durag"
	icon_state = "durag"
	armor = list(melee = 35, bullet = 35, laser = 35, energy = 15, bomb = 10, bio = 0, rad = 0)
	flags_inv = HIDEEARS | HIDETOPHAIR | BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/durag/jungle
	name = "\improper M8 marksman cowl"
	desc = "A cowl worn to conceal the face of a marksman in the jungle."
	icon_state = "duragG"
	item_state = "duragG"

/obj/item/clothing/head/helmet/durag/snow
	desc = "\improper M6 marksman hood"
	desc = "A hood meant to protect the wearer from both the cold and the guise of the enemy in the tundra."
	icon_state = "duragS"
	item_state = "duragS"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/marine
	name = "\improper M10 pattern marine helmet"
	desc = "A standard M10 Pattern Helmet. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "helmet"
	item_state = "helmet"
	icon_override = 'icons/Marine/marine_armor.dmi'
	armor = list(melee = 65, bullet = 35, laser = 30, energy = 20, bomb = 25, bio = 0, rad = 0)
	flags_inv = HIDEEARS | BLOCKSHARPOBJ
	health = 5
	var/hug_damage = 0

/obj/item/clothing/head/helmet/marine/snow
	name = "\improper M10 pattern marine snow helmet"
	icon_state = "helmet_snow"
	item_state = "helmet_snow"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	New()
		..()
		var/helmet_color = rand(1,4)
		if(helmet_color == 4)
			icon_state = "helmet_snow2"
			item_state = "helmet_snow2"

/obj/item/clothing/head/helmet/marine/tech
	name = "\improper M10 technician helmet"
	icon_state = "helmet-tech"
	item_color = "helmet-tech"

/obj/item/clothing/head/helmet/marine/tech/snow
	name = "\improper M10 technician snow helmet"
	icon_state = "s_helmet-tech"
	item_color = "s_helmet-tech"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/marine/medic
	name = "\improper M10 medic helmet"
	icon_state = "helmet-medic"
	item_color = "helmet-medic"

/obj/item/clothing/head/helmet/marine/medic/snow
	name = "\improper M10 medic snow helmet"
	icon_state = "s_helmet-medic" //NEEDS ICON
	item_color = "s_helmet-medic"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/marine/leader
	name = "\improper M11 pattern leader helmet"
	icon_state = "xhelm"
	desc = "A slightly fancier helmet for marine leaders. This one contains a small built-in camera and has cushioning to project your fragile brain."
	armor = list(melee = 75, bullet = 45, laser = 40, energy = 40, bomb = 35, bio = 10, rad = 10)
	anti_hug = 2
	var/obj/machinery/camera/camera

/obj/item/clothing/head/helmet/marine/leader/snow
	name = "\improper M11 pattern leader snow helmet"
	icon_state = "s_xhelm"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/marine/specialist
	name = "\improper B18 helmet"
	icon_state = "xhelm"
	desc = "The B18 Helmet that goes along with the B18 Defensive Armor. It's heavy, reinforced, and protects more of the face."
	icon_override = 'icons/Marine/marine_armor.dmi'
	armor = list(melee = 95, bullet = 105, laser = 75, energy = 65, bomb = 70, bio = 15, rad = 15)
	anti_hug = 3
	unacidable = 1

/obj/item/clothing/head/helmet/marine/specialist/snow
	name = "\improper B18 snow helmet"
	icon_state = "s_xhelm"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/marine/pilot
	name = "\improper M30 tactical helmet"
	desc = "The M30 tactical helmet has an left eyepiece filter used to filter tactical data. It is required to fly the Rasputin dropship manually and in safety."
	icon_state = "pilot_helmet"
	icon_override = 'icons/Marine/marine_armor.dmi'
	armor = list(melee = 75, bullet = 45, laser = 40, energy = 40, bomb = 35, bio = 10, rad = 10)
	anti_hug = 2

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
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inv = BLOCKSHARPOBJ

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
	armor = list(melee = 55, bullet = 65, laser = 45, energy = 55, bomb = 60, bio = 10, rad = 10)
	flags_inv = HIDEEARS | HIDEEYES | HIDEFACE | HIDEMASK | COVEREYES | COVERMOUTH | HIDEALLHAIR | BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/marine/veteran/PMC/gunner
	name = "\improper PMC gunner helmet"
	desc = "A modification of the standard Armat Systems M3 armor."
	item_state = "heavy_helmet"
	icon_state = "heavy_helmet"
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 60, bomb = 70, bio = 10, rad = 10)
	flags_inv = HIDEEARS | HIDEEYES | HIDEFACE | HIDEMASK | COVEREYES | COVERMOUTH | HIDEALLHAIR | BLOCKSHARPOBJ
	anti_hug = 4

/obj/item/clothing/head/helmet/marine/veteran/PMC/commando
	name = "\improper PMC commando helmet"
	desc = "A fully enclosed, armored helmet made for Weyland Yutani elite commandos."
	item_state = "commando_helmet"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "commando_helmet"
	icon_override = 'icons/PMC/PMC.dmi'
	armor = list(melee = 90, bullet = 120, laser = 90, energy = 90, bomb = 90, bio = 100, rad = 100)
	flags_inv = HIDEEARS | HIDEEYES | HIDEFACE | HIDEMASK | COVEREYES | COVERMOUTH | HIDEALLHAIR | BLOCKSHARPOBJ | BLOCKGASEFFECT
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

/obj/item/clothing/head/helmet/marine/veteran/dutch/cap
	name = "\improper Dutch's Dozen cap"
	desc = "A protective cap worn by some seriously experienced mercs."
	item_state = "dutch_cap"
	icon_state = "dutch_cap"
	flags_inv = BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/marine/veteran/dutch/band
	name = "\improper Dutch's Dozen band"
	desc = "A protective band worn by some seriously experienced mercs."
	item_state = "dutch_band"
	icon_state = "dutch_band"
	flags_inv = BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/marine/veteran/bear
	name = "\improper Iron Bear helmet"
	desc = "Is good for winter, because it has hole to put vodka through."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "dutch_helmet"
	icon_state = "dutch_helmet"
	armor = list(melee = 90, bullet = 65, laser = 40, energy = 35, bomb = 35, bio = 5, rad = 5)
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	anti_hug = 2

//==========================//HELMET PROCS\\=============================\\
//=======================================================================\\

/obj/item/clothing/head/helmet/marine/proc/add_hugger_damage() //This is called in XenoFacehuggers.dm to first add the overlay and set the var.
	if(!hug_damage) //If this is our first check.
		var/image/scratchy = image('icons/Marine/marine_armor.dmi',icon_state = "hugger_damage")
		overlays += scratchy
		hug_damage = 1
		desc = "[initial(desc)]\n<b>This helmet seems to be scratched up and damaged, particularly around the face area..</b>"

/obj/item/clothing/head/helmet/marine
	examine()
		if(contents.len)
			var/dat = "<br><br>There is something attached to [src]:<br><br>"
			for(var/obj/O in src)
				dat += "\blue *\icon[O] - [O]<br>"
		desc = "[initial(desc)][hug_damage?"\n<b>This [src] seems to be scratched up and damaged, particularly around the face area...</b>":""]"
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(src,/obj/item/clothing/head/helmet/marine/veteran)) //Not for distress items.
			user << "<span class='warning'>[src] cannot hold any items!</span>"
			return
		var/allowed_items[] = return_allowed_items()
		if(W.type in allowed_items)
			if(contents.len < 3)
				user.remove_from_mob(W)
				W.loc = src
				user.visible_message("<span class='notice'>[user] puts [W] on [src].</span>","<span class='info'>You put [W] on [src].</span>")
				update_icon(user)
			else user << "<span class='warning'>There is no more space for [W]!</span>"
		else if(istype(W, /obj/item/weapon/claymore/mercsword/machete))
			user.visible_message("<span class='warning'>[user] tries to put [W] on [src] like a pro, <b>but fails miserably and looks like an idiot...</b></span>","<span class='warning'>You try to put [W] on [src], but there simply isn't enough space! <b><i>Maybe I should try again?</i></b></span>")
		else user << "<span class='warning'>[W] does not fit on [src]!</span>"

	update_icon(var/mob/user)
		if(istype(src,/obj/item/clothing/head/helmet/marine/fluff)) return //Don't want these to update.
		overlays.Cut()
		if(hug_damage) overlays += image('icons/Marine/marine_armor.dmi',icon_state = "hugger_damage")
		if(contents.len)
			var/allowed_items[] = return_allowed_items()
			for(var/obj/I in contents)
				overlays += image('icons/mob/helmet_garb.dmi', "[allowed_items[I.type]][I.type == /obj/item/weapon/flame/lighter/random ? I:clr : ""]")
			overlays += image('icons/mob/helmet_garb.dmi', "helmet_band")
		user.update_inv_head()

	MouseDrop(over_object, src_location, over_location)
		if(!ishuman(usr)) return
		var/mob/living/carbon/human/user = usr
		if((over_object == user && (in_range(src, user) || user.contents.Find(src))))
			if(contents.len)
				var/obj/item/choice = input("What item would you like to remove from [src]?") as null|obj in contents
				if(choice)
					if((!usr.canmove && !usr.buckled) || usr.stat || usr.restrained() || !in_range(loc, usr)) return

					user.put_in_hands(choice)
					user.visible_message("<span class='info'>[user] removes [choice] from [src].</span>","<span class='notice'>You remove [choice] from [src].</span>")
					update_icon(user)

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
						/obj/item/weapon/deck = "helmet_card_card",
						/obj/item/weapon/hand = "helmet_card_card",
						/obj/item/weapon/reagent_containers/food/drinks/flask = "helmet_flask",
						/obj/item/weapon/reagent_containers/food/snacks/eat_bar = "helmet_snack_eat",
						/obj/item/weapon/reagent_containers/food/snacks/packaged_burrito = "helmet_snack_burrito",
						/obj/item/weapon/reagent_containers/food/snacks/donkpocket = "helmet_snack_eat",
						/obj/item/fluff/val_mcneil_1 = "helmet_rosary",
						/obj/item/clothing/mask/mara_kilpatrick_1 = "helmet_rosary")
	. = allowed_items

/obj/item/clothing/head/helmet/marine/leader
	New()
		spawn(8)
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
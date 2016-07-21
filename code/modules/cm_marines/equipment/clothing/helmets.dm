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
	flags = FPRINT | TABLEPASS | CONDUCT
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
	flags = FPRINT | TABLEPASS
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
	flags = FPRINT | TABLEPASS
	flags_inv = HIDEEARS | HIDETOPHAIR | BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/durag/jungle
	name = "marksman cowl"
	desc = "A cowl worn to conceal the face of a marksman in the jungle."
	icon_state = "duragG"
	item_state = "duragG"

/obj/item/clothing/head/helmet/marine
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "helmet"
	item_state = "helmet"
	icon_override = 'icons/Marine/marine_armor.dmi'
	name = "M10 Pattern Marine Helmet"
	desc = "A standard M10 Pattern Helmet. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."
	armor = list(melee = 65, bullet = 35, laser = 30, energy = 20, bomb = 25, bio = 0, rad = 0)
	flags_inv = HIDEEARS | HIDETOPHAIR | BLOCKSHARPOBJ
	health = 5
	var/hug_damage = 0

/obj/item/clothing/head/helmet/marine/snow
	name = "M10 pattern marine snow helmet"
	icon_state = "helmet_snow"
	item_state = "helmet_snow"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/marine/tech
	name = "M10 technician helmet"
	icon_state = "helmet-tech"
	item_color = "helmet-tech"

/obj/item/clothing/head/helmet/marine/tech/snow
	name = "M10 technician snow helmet"
	icon_state = "s_helmet-tech"
	item_color = "s_helmet-tech"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/marine/medic
	name = "M10 medic helmet"
	icon_state = "helmet-medic"
	item_color = "helmet-medic"

/obj/item/clothing/head/helmet/marine/medic/snow
	name = "M10 medic snow helmet"
	icon_state = "s_helmet-medic" //NEEDS ICON
	item_color = "s_helmet-medic"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/marine/leader
	name = "M11 pattern leader helmet"
	icon_state = "xhelm"
	desc = "A slightly fancier helmet for marine leaders. This one contains a small built-in camera and has cushioning to project your fragile brain."
	armor = list(melee = 75, bullet = 45, laser = 40, energy = 40, bomb = 35, bio = 10, rad = 10)
	anti_hug = 2
	var/obj/machinery/camera/camera

/obj/item/clothing/head/helmet/marine/leader/snow
	name = "M11 pattern leader snow helmet"
	icon_state = "s_xhelm"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/marine/specialist
	name = "B18 helmet"
	icon_state = "xhelm"
	desc = "The B18 Helmet that goes along with the B18 Defensive armor. It's heavy, reinforced, and protects more of the face."
	icon_override = 'icons/Marine/marine_armor.dmi'
	armor = list(melee = 95, bullet = 105, laser = 75, energy = 65, bomb = 70, bio = 15, rad = 15)
	anti_hug = 3
	unacidable = 1

/obj/item/clothing/head/helmet/marine/specialist/snow
	name = "B18 snow helmet"
	icon_state = "s_xhelm"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

//=============================//PMCS\\==================================\\
//=======================================================================\\

/obj/item/clothing/head/helmet/marine/veteran/PMC
	name = "PMC tactical cap"
	desc = "A protective cap made from flexable kevlar. Standard issue for most security forms in the place of a helmet."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "helmet"
	icon_state = "pmc_hat"
	armor = list(melee = 38, bullet = 38, laser = 32, energy = 22, bomb = 12, bio = 5, rad = 5)
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags = FPRINT | TABLEPASS
	flags_inv = BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/marine/veteran/PMC/leader
	name = "PMC beret"
	desc = "The pinacle of fashion for any aspiring mercenary leader. Designed to protect the head from light impacts."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "officer_hat"
	icon_state = "officer_hat"
	anti_hug = 3

/obj/item/clothing/head/helmet/marine/veteran/PMC/sniper
	name = "PMC sniper helmet"
	desc = "A helmet worn by PMC Marksmen"
	item_state = "pmc_sniper_hat"
	icon_state = "pmc_sniper_hat"
	armor = list(melee = 55, bullet = 65, laser = 45, energy = 55, bomb = 60, bio = 10, rad = 10)
	flags = FPRINT | TABLEPASS | CONDUCT
	flags_inv = HIDEEARS | HIDEEYES | COVEREYES | COVERMOUTH | HIDEALLHAIR | BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/marine/veteran/PMC/gunner
	name = "PMC gunner helmet"
	desc = "A modification of the standard Armat Systems M3 armor."
	item_state = "heavy_helmet"
	icon_state = "heavy_helmet"
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 60, bomb = 70, bio = 10, rad = 10)
	flags = FPRINT | TABLEPASS | CONDUCT
	flags_inv = HIDEEARS | HIDEEYES | COVEREYES | COVERMOUTH | HIDEALLHAIR | BLOCKSHARPOBJ
	anti_hug = 4

/obj/item/clothing/head/helmet/marine/veteran/PMC/commando
	name = "PMC commando helmet"
	desc = "A fully enclosed, armored helmet made for Weyland Yutani elite commandos."
	item_state = "commando_helmet"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "commando_helmet"
	icon_override = 'icons/PMC/PMC.dmi'
	armor = list(melee = 90, bullet = 120, laser = 90, energy = 90, bomb = 90, bio = 100, rad = 100)
	flags = FPRINT | TABLEPASS | CONDUCT
	flags_inv = HIDEEARS | HIDEEYES | COVEREYES | COVERMOUTH | HIDEALLHAIR | BLOCKSHARPOBJ | BLOCKGASEFFECT
	anti_hug = 6
	unacidable = 1

//==========================//DISTRESS\\=================================\\
//=======================================================================\\

/obj/item/clothing/head/helmet/marine/veteran/dutch
	name = "Dutch's Dozen helmet"
	desc = "A protective helmet worn by some seriously experienced mercs."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "dutch_helmet"
	icon_state = "dutch_helmet"
	armor = list(melee = 70, bullet = 70, laser = 0,energy = 20, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/marine/veteran/dutch/cap
	name = "Dutch's Dozen cap"
	item_state = "dutch_cap"
	icon_state = "dutch_cap"
	flags = FPRINT | TABLEPASS | CONDUCT
	flags_inv = BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/marine/veteran/dutch/band
	name = "Dutch's Dozen band"
	item_state = "dutch_band"
	icon_state = "dutch_band"
	flags = FPRINT | TABLEPASS | CONDUCT
	flags_inv = BLOCKSHARPOBJ

/obj/item/clothing/head/helmet/marine/veteran/bear
	name = "Iron Bear helmet"
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
			var/dat = "<br><br>There is something attached to \the [src]:<br><br>"
			for(var/obj/O in src)
				dat += "\blue *\icon[O] - [O]<br>"
			desc = "[initial(desc)][hug_damage?"\n<b>This helmet seems to be scratched up and damaged, particularly around the face area..</b>":""][dat]"
		else
			desc = "[initial(desc)][hug_damage?"\n<b>This helmet seems to be scratched up and damaged, particularly around the face area..</b>":""]"
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/flame/lighter) || istype(W, /obj/item/weapon/storage/fancy/cigarettes)\
		|| istype(W, /obj/item/weapon/storage/box/matches) || istype(W, /obj/item/weapon/deck)\
		|| istype(W, /obj/item/weapon/hand) || istype(W,/obj/item/weapon/reagent_containers/food/drinks/flask)\
		|| istype(W, /obj/item/weapon/reagent_containers/food/snacks/eat_bar) || istype(W,/obj/item/weapon/reagent_containers/food/snacks/packaged_burrito)\
		|| istype(W, /obj/item/fluff/val_mcneil_1) || istype(W, /obj/item/clothing/mask/mara_kilpatrick_1))
			if(contents.len < 3)
				user.drop_item()
				W.loc = src
				user.visible_message("[usr] puts \the [W] on the [src].","\blue You put \the [W] on the [src].")
				update_icon()
			else
				user << "\red There is no more space for [W]."
		else if(istype(W, /obj/item/weapon/claymore/mercsword/machete))
			user.visible_message("[usr] tries to put \the [W] on [src] like a pro, <b>but fails miserably and looks like an idiot...</b>","\red You try to put \the [W] on the [src], but there simply isn't enough space! <b><i>Maybe I should try again?</i></b>")
		else
			user << "\red \the [W] does not fit on [src]."

	update_icon()
		overlays.Cut()
		if(hug_damage)
			overlays += image('icons/Marine/marine_armor.dmi',icon_state = "hugger_damage")
		if(contents.len)
			for(var/obj/I in contents)
				if(!isnull(I) && I in contents)
					//Cigar Packs
					if(istype(I,/obj/item/weapon/storage/fancy/cigarettes) && !istype(I,/obj/item/weapon/storage/fancy/cigarettes/lucky_strikes) && !istype(I,/obj/item/weapon/storage/fancy/cigarettes/dromedaryco) && !istype(I,/obj/item/weapon/storage/fancy/cigarettes/kpack))
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_cig_kpack")//TODO
					else if(istype(I,/obj/item/weapon/storage/fancy/cigarettes/kpack))
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_cig_kpack")
					else if(istype(I,/obj/item/weapon/storage/fancy/cigarettes/lucky_strikes))
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_cig_ls")
					else if(istype(I,/obj/item/weapon/storage/fancy/cigarettes/dromedaryco))
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_cig_kpack")//TODO

					//Cards
					else if(istype(I,/obj/item/weapon/deck) || istype(I,/obj/item/weapon/hand))
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_card_card")

					//Matches
					else if(istype(I,/obj/item/weapon/storage/box/matches))
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_matches")

					//Rosary
					else if(istype(I,/obj/item/fluff/val_mcneil_1) || istype(I, /obj/item/clothing/mask/mara_kilpatrick_1))
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_rosary")

					//Flasks
					else if(istype(I,/obj/item/weapon/reagent_containers/food/drinks/flask))
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_flask")

					//Lighters
					else if(istype(I,/obj/item/weapon/flame/lighter/zippo))
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_lighter_zippo")
					else if(istype(I,/obj/item/weapon/flame/lighter) && !istype(I,/obj/item/weapon/flame/lighter/zippo))
						var/obj/item/weapon/flame/lighter/L = I
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_lighter_[L.clr]")

					//Snacks
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/packaged_burrito))
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_snack_burrito")
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/eat_bar) || istype(I,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
						overlays += image('icons/mob/helmet_garb.dmi', "helmet_snack_eat")

			overlays += image('icons/mob/helmet_garb.dmi', "helmet_band")
		usr.update_inv_head()


	MouseDrop(over_object, src_location, over_location)
		if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
			if(!ishuman(usr))
				return
			if(contents.len)
				var/obj/item/choice = input("What item would you like to remove from the [src]?") as null|obj in contents
				if(!isnull(choice) && choice)
					if((!usr.canmove && !usr.buckled) || usr.stat || usr.restrained() || !in_range(loc, usr))
						return
					if(!istype(choice, /obj/item))
						usr << "\red You can't remove \the [choice] from your [src]."
						return
					if(!usr.get_active_hand())
						usr.put_in_hands(choice)
					else
						choice.loc = get_turf(src)
					update_icon()
					usr.visible_message("\blue [usr] removes \the [choice] off \the [src].","\blue You remove \the [choice] off \the [src].")
			else
				usr << "\red There is nothing on [src]."

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
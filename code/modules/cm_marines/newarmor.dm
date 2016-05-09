
#define ALPHA		1
#define BRAVO		2
#define CHARLIE		3
#define DELTA		4
#define NONE 		5

var/list/armormarkings = list()
var/list/armormarkings_sql = list()
var/list/helmetmarkings = list()
var/list/helmetmarkings_sql = list()
var/list/squad_colors = list(rgb(230,25,25), rgb(255,195,45), rgb(160,32,240), rgb(65,72,200))

/proc/initialize_marine_armor()
	var/i
	for(i=1, i<5, i++)
		var/image/armor
		var/image/helmet
		armor = image('icons/Marine/marine_armor.dmi',icon_state = "std-armor")
		armor.color = squad_colors[i]
		armormarkings += armor
		armor = image('icons/Marine/marine_armor.dmi',icon_state = "sql-armor")
		armor.color = squad_colors[i]
		armormarkings_sql += armor

		helmet = image('icons/Marine/marine_armor.dmi',icon_state = "std-helmet")
		helmet.color = squad_colors[i]
		helmetmarkings += helmet
		helmet = image('icons/Marine/marine_armor.dmi',icon_state = "sql-helmet")
		helmet.color = squad_colors[i]
		helmetmarkings_sql += helmet

/obj/item/clothing/head/helmet/marine
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "helmet"
	item_state = "helmet"
	icon_override = 'icons/Marine/marine_armor.dmi'
	name = "M10 Pattern Marine Helmet"
	desc = "A standard M10 Pattern Helmet. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."
	armor = list(melee = 65, bullet = 85, laser = 50,energy = 20, bomb = 25, bio = 0, rad = 0)
	health = 5
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES|HEADCOVERSMOUTH
	anti_hug = 1
	w_class = 5
	var/hug_damage = 0

	examine()
		if(contents.len)
			var/dat = "<br><br>There is something attached to \the [src]:<br><br>"
			for(var/obj/O in src)
				dat += "\blue *\icon[O] - [O]<br>"
			desc = "[initial(desc)][hug_damage?"\n<b>This helmet seems to be scratched up and damaged, particularly around the face area..</b>":""][dat]"
		else
			desc = "[initial(desc)][hug_damage?"\n<b>This helmet seems to be scratched up and damaged, particularly around the face area..</b>":""]"
		..()

	proc/add_hugger_damage() //This is called in XenoFacehuggers.dm to first add the overlay and set the var.
		if(!hug_damage) //If this is our first check.
			var/image/scratchy = image('icons/Marine/marine_armor.dmi',icon_state = "hugger_damage")
			overlays += scratchy
			hug_damage = 1
			desc = "[initial(desc)]\n<b>This helmet seems to be scratched up and damaged, particularly around the face area..</b>"

/obj/item/clothing/suit/storage/marine
	name = "M3 Pattern Marine Armor"
	desc = "A standard Colonial Marines M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "1"
	item_state = "armor"
	icon_override = 'icons/Marine/marine_armor.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	blood_overlay_type = "armor"
	armor = list(melee = 50, bullet = 90, laser = 50, energy = 20, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.7
	allowed = list(/obj/item/weapon/gun/,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/ammo_casing/,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/storage/fancy/cigarettes,
		/obj/item/weapon/flame/lighter,
		/obj/item/weapon/grenade,
		/obj/item/weapon/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/flamethrower/full,
		/obj/item/weapon/combat_knife)
	var/ArmorVariation
	var/brightness_on = 5
	var/on = 0
	var/reinforced = 0
	var/lamp = 1 //So we don't stack lamp overlays every time we update the suit icons
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list

	New()
		..()
		if(src.name == "M3 Pattern Marine Armor") //This is to stop subtypes from icon changing. There's prolly a better way
			spawn(5)
				icon_state = "[rand(1,6)]"
				ArmorVariation = icon_state
		else if(src.name == "M3 Pattern Marine Snow Armor") //This is to stop subtypes from icon changing. There's prolly a better way
			spawn(5)
				icon_state = "s_[rand(1,6)]"
				ArmorVariation = icon_state
		else
			ArmorVariation = icon_state
		overlays += image('icons/Marine/marine_armor.dmi', "lamp")



	pickup(mob/user)
		if(on && src.loc != user)
			user.SetLuminosity(brightness_on)
			SetLuminosity(0)

	dropped(mob/user)
		if(on && src.loc != user)
			user.SetLuminosity(-brightness_on)
			SetLuminosity(brightness_on)

	Del()
		if(ismob(src.loc))
			src.loc.SetLuminosity(-brightness_on)
		else
			SetLuminosity(0)
		..()

	attack_self(mob/user)
		if(!isturf(user.loc))
			user << "You cannot turn the light on while in this [user.loc]." //To prevent some lighting anomalities.
			return 0

		if(on) //Turn it off.
			if(user)
				user.SetLuminosity(-brightness_on)
			else //Shouldn't be possible, but whatever
				SetLuminosity(0)
			overlays -= image('icons/Marine/marine_armor.dmi', "beam")
			user.update_inv_wear_suit()
			on = 0
		else //Turn it on!
			on = 1
			if(user)
				user.SetLuminosity(brightness_on)
			else //Somehow
				SetLuminosity(brightness_on)
			overlays += image('icons/Marine/marine_armor.dmi', "beam")
			user.update_inv_wear_suit()

		playsound(src,'sound/machines/click.ogg', 20, 1)
		update_clothing_icon()
		return 1


/obj/item/clothing/suit/storage/marine/marine_spec_armor
	name = "B18 Defensive Armor"
	desc = "A heavy, rugged set of armor plates for when you really, really need to not die horribly. Slows you down though.\nComes with a tricord injector in each arm guard."
	icon_state = "xarmor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	slowdown = 1
	armor = list(melee = 95, bullet = 100, laser = 80, energy = 90, bomb = 75, bio = 20, rad = 10)
	var/injections = 2
	unacidable = 1
	allowed = list(/obj/item/weapon/gun,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/device/flashlight,
					/obj/item/ammo_magazine,
					/obj/item/ammo_casing,
					/obj/item/weapon/flamethrower,
					/obj/item/device/mine,
					/obj/item/weapon/claymore/mercsword/machete,
					/obj/item/weapon/combat_knife)

	verb/inject()
		set name = "Create Injector"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		if(!injections)
			usr << "Your armor is all out of injectors."
			return 0

		if(usr.get_active_hand())
			usr << "Your active hand must be empty."
			return 0

		usr << "You feel a faint hiss and an injector drops into your hand."
		var/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord/O = new(usr)
		usr.put_in_active_hand(O)
		injections--
		playsound(src,'sound/machines/click.ogg', 20, 1)
		return

/obj/item/clothing/head/helmet/specrag
	icon = 'icons/Marine/marine_armor.dmi'
	icon_override = 'icons/Marine/marine_armor.dmi'
	icon_state = "spec"
	item_state = "spec"
	item_color = "spec"
	name = "Specialist head-rag"
	desc = "A hat worn by heavy-weapons operators to block sweat."
	anti_hug = 1
	w_class = 5

	flags = FPRINT|TABLEPASS|BLOCKHEADHAIR

/obj/item/clothing/head/helmet/marine/heavy
	name = "B18 Helmet"
	icon_state = "xhelm"
	desc = "The B18 Helmet that goes along with the B18 Defensive armor. It's heavy, reinforced, and protects more of the face."
	icon_override = 'icons/Marine/marine_armor.dmi'
	armor = list(melee = 95, bullet = 100, laser = 70,energy = 60, bomb = 35, bio = 10, rad = 10)
	anti_hug = 3
	unacidable = 1

/obj/item/clothing/gloves/specialist
	name = "B18 Defensive Gauntlets"
	desc = "A pair of heavily armored gloves."
	icon_state = "brown"
	item_state = "browngloves"
	item_color="brown"
	armor = list(melee = 95, bullet = 100, laser = 70,energy = 60, bomb = 35, bio = 10, rad = 10)
	unacidable = 1
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/weapon/storage/box/heavy_armor
	name = "B-Series Defensive Armor crate"
	desc = "A large case containing an experiemental suit of B18 armor for the discerning specialist."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = 5
	storage_slots = 2
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

	New()
		..()
		spawn(1)//Hax
			new /obj/item/clothing/gloves/specialist(src)
			if(istype(ticker.mode,/datum/game_mode/ice_colony))
				new /obj/item/clothing/suit/storage/marine/marine_spec_armor/snow(src)
				new /obj/item/clothing/head/helmet/marine/heavy/snow(src)
			else
				new /obj/item/clothing/suit/storage/marine/marine_spec_armor(src)
				new /obj/item/clothing/head/helmet/marine/heavy(src)

/obj/item/clothing/head/helmet/marine/leader
	name = "M11 Pattern Leader Helmet"
	icon_state = "xhelm"
	desc = "A slightly fancier helmet for marine leaders. This one contains a small built-in camera and has cushioning to project your fragile brain."
	armor = list(melee = 75, bullet = 90, laser = 70,energy = 50, bomb = 35, bio = 10, rad = 10)
	anti_hug = 2
	var/obj/machinery/camera/camera

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

/obj/item/clothing/suit/storage/marine/marine_leader_armor
	name = "B12 Pattern Leader Armor"
	desc = "A lightweight suit of carbon fiber body armor built for quick movement. Designed in a lovely forest green. Use it to toggle the built-in flashlight."
	icon_state = "7"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 45, bullet = 85, laser = 70, energy = 40, bomb = 15, bio = 0, rad = 0)
	allowed = list(
					/obj/item/weapon/gun,
					/obj/item/device/binoculars,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/device/flashlight,
					/obj/item/ammo_magazine,
					/obj/item/ammo_casing,
					/obj/item/weapon/melee/baton,
					/obj/item/weapon/handcuffs,
					/obj/item/weapon/storage/fancy/cigarettes,
					/obj/item/weapon/flame/lighter,
					/obj/item/weapon/grenade,
					/obj/item/weapon/combat_knife,
					/obj/item/weapon/claymore/mercsword/machete,
					/obj/item/weapon/storage/bible)

/obj/item/clothing/suit/storage/marine/MP
	icon_state = "mp"
	armor = list(melee = 40, bullet = 90, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	name = "M2 Pattern MP Armor"
	desc = "A standard Colonial Marines M2 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."

/obj/item/clothing/suit/storage/marine/MP/RO
	icon_state = "officer"
	name = "M3 Pattern Officer Armor"
	desc = "A well-crafted suit of M3 Pattern armor typically found in the hands of higher-ranking officers. Useful for letting your men know who is in charge when taking to the field"

//Helmet Attachables
/obj/item/clothing/head/helmet/marine/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/flame/lighter) || istype(W, /obj/item/weapon/storage/fancy/cigarettes)\
	|| istype(W, /obj/item/weapon/storage/box/matches) || istype(W, /obj/item/weapon/deck)\
	|| istype(W, /obj/item/weapon/hand) || istype(W,/obj/item/weapon/reagent_containers/food/drinks/flask)\
	|| istype(W, /obj/item/weapon/reagent_containers/food/snacks/eat_bar) || istype(W,/obj/item/weapon/reagent_containers/food/snacks/packaged_burrito)\
	|| istype(W, /obj/item/fluff/val_mcneil_1) || istype(W, /obj/item/clothing/mask/mara_kilpatrick_1))
		if(contents.len < 3)
			user.drop_item()
			W.loc = src
			user.visible_message("[src] puts \the [W] on the [src].","\blue You put \the [W] on the [src].")
			update_icon()
		else
			user << "\red There is no more space for [W]."
	else if(istype(W, /obj/item/weapon/claymore/mercsword/machete))
		user.visible_message("[src] tries to put \the [W] on [src] like a pro, <b>but fails miserably and looks like an idiot...</b>","\red You try to put \the [W] on the [src], but there simply isn't enough space! <b><i>Maybe I should try again?</i></b>")
	else
		user << "\red \the [W] does not fit on [src]."

/obj/item/clothing/head/helmet/marine/update_icon()
	overlays.Cut()
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


/obj/item/clothing/head/helmet/marine/MouseDrop(over_object, src_location, over_location)
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


/obj/item/clothing/suit/storage/marine/sniper
	name = "M3 Pattern Sniper Armor"
	desc = "A custom modified set of M3 armor designed for recon missions."
	icon_state = "marine_sniper"
	item_state = "marine_sniper"
	armor = list(melee = 70, bullet = 75, laser = 50,energy = 20, bomb = 30, bio = 0, rad = 0)


/obj/item/clothing/head/helmet/durag
	name = "durag"
	desc = "Good for keeping sweat out of your eyes"
	icon = 'icons/obj/clothing/hats.dmi'
	item_state = "durag"
	icon_state = "durag"
	armor = list(melee = 5, bullet = 5, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	min_cold_protection_temperature = 220
	cold_protection = HEAD

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
	armor = list(melee = 75, bullet = 60, laser = 50,energy = 20, bomb = 25, bio = 0, rad = 0)
	flags = FPRINT|TABLEPASS
	var/hug_damage = 0
	anti_hug = 1

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
	armor = list(melee = 50, bullet = 70, laser = 50, energy = 20, bomb = 25, bio = 0, rad = 0)
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
		/obj/item/weapon/flamethrower/full,
		/obj/item/weapon/combat_knife)

	New()
		..()
		if(src.name == "M3 Pattern Marine Armor") //This is to stop subtypes from icon changing. There's prolly a better way
			spawn(5)
				icon_state = "[rand(1,6)]"


/obj/item/clothing/suit/storage/marine/marine_spec_armor
	name = "B18 Defensive Armor"
	desc = "A heavy, rugged set of armor plates for when you really, really need to not die horribly. Slows you down though.\nComes with a tricord injector in each arm guard."
	icon_state = "xarmor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	slowdown = 1
	armor = list(melee = 95, bullet = 95, laser = 80, energy = 90, bomb = 75, bio = 20, rad = 10)
	var/injections = 2
	unacidable = 1
	allowed = list(/obj/item/weapon/gun,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/device/flashlight,
					/obj/item/ammo_magazine,
					/obj/item/ammo_casing,
					/obj/item/weapon/flamethrower,
					/obj/item/device/mine,
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

	flags = FPRINT|TABLEPASS|BLOCKHEADHAIR

/obj/item/clothing/head/helmet/marine/heavy
	name = "B18 Helmet"
	icon_state = "xhelm"
	desc = "The B18 Helmet that goes along with the B18 Defensive armor. It's heavy, reinforced, and protects more of the face."
	icon_override = 'icons/Marine/marine_armor.dmi'
	armor = list(melee = 95, bullet = 90, laser = 70,energy = 60, bomb = 35, bio = 10, rad = 10)
	anti_hug = 3
	unacidable = 1

/obj/item/clothing/gloves/specialist
	name = "B18 Defensive Gauntlets"
	desc = "A pair of heavily armored gloves."
	icon_state = "gray"
	item_state = "graygloves"
	item_color="grey"
	armor = list(melee = 95, bullet = 90, laser = 70,energy = 60, bomb = 35, bio = 10, rad = 10)
	unacidable = 1

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
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/marine_spec_armor(src)
			new /obj/item/clothing/head/helmet/marine/heavy(src)
			new /obj/item/clothing/gloves/specialist(src)

/obj/item/clothing/head/helmet/marine/leader
	name = "M11 Pattern Leader Helmet"
	icon_state = "xhelm"
	desc = "A slightly fancier helmet for marine leaders. This one contains a small built-in camera and has cushioning to project your fragile brain."
	armor = list(melee = 75, bullet = 60, laser = 70,energy = 50, bomb = 35, bio = 10, rad = 10)
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
	cold_protection = UPPER_TORSO|LOWER_TORSO
	heat_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 45, bullet = 75, laser = 70, energy = 40, bomb = 15, bio = 0, rad = 0)
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
					/obj/item/weapon/storage/bible)
	var/brightness_on = 7
	var/on = 0
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list

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
			icon_state = "[initial(icon_state)]"
			on = 0
		else //Turn it on!
			on = 1
			if(user)
				user.SetLuminosity(brightness_on)
			else //Somehow
				SetLuminosity(brightness_on)
			icon_state = "[initial(icon_state)]-on"

		playsound(src,'sound/machines/click.ogg', 20, 1)
		update_clothing_icon()
		return 1

/obj/item/clothing/suit/storage/marine/MP
	icon_state = "mp"
	armor = list(melee = 40, bullet = 85, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	name = "M2 Pattern MP Armor"
	desc = "A standard Colonial Marines M2 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."

/obj/item/clothing/suit/storage/marine/MP/RO
	icon_state = "officer"
	name = "M3 Pattern Officer Armor"
	desc = "A well-crafted suit of M3 Pattern armor typically found in the hands of higher-ranking officers. Useful for letting your men know who is in charge when taking to the field"

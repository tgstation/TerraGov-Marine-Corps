//=============================//ARMOR\\=================================\\
//=======================================================================\\

/*All protective armor should go in here. This also defined armor for squad
use, and contains the necessary procs at the bottom of the file.

//You can enable this proc to see the combined armor value of a person.
/mob/living/carbon/human/verb/check_overall_protection()
	set name = "Get Armor Value"
	set category = "Debug"
	set desc = "Shows the armor value of the bullet category."

	var/armor = 0
	var/counter = 0
	for(var/i in organs_by_name)
		armor = getarmor_organ(organs_by_name[i], "bullet")
		src << "<b>[i]</b> is protected with <b>[armor]</b> armor against bullets."
		counter += armor
	src << "The overall armor score is: <b>[counter]</b>."

*/
//=======================================================================\\
//=======================================================================\\

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

//============================//MISC\\===================================\\
//=======================================================================\\

/obj/item/clothing/suit/armor/vest
	name = "armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO
	armor = list(melee = 50, bullet = 30, laser = 25, energy = 10, bomb = 15, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/bulletproof
	name = "Bulletproof Vest"
	desc = "A vest that excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "bulletproof"
	item_state = "armor"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO
	armor = list(melee = 30, bullet = 50, laser = 25, energy = 10, bomb = 15, bio = 0, rad = 0)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/armor/riot
	name = "Riot Suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement."
	icon_state = "riot"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	slowdown = 1
	armor = list(melee = 80, bullet = 10, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0.5

//===========================//MARINES\\=================================\\
//=======================================================================\\

/obj/item/clothing/suit/armor/riot/marine
	name = "M5 Riot Control Armor"
	desc = "A heavily modified suit of M2 MP Armor used to supress riots from buckethead marines. Slows you down a lot."
	icon_state = "riot"
	item_state = "swat_suit"
	slowdown = 3
	armor = list(melee = 70, bullet = 45, laser = 35, energy = 20, bomb = 35, bio = 10, rad = 10)

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
	armor = list(melee = 50, bullet = 40, laser = 35, energy = 20, bomb = 25, bio = 0, rad = 0)
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

/obj/item/clothing/suit/storage/marine/snow
	name = "M3 Pattern Marine Snow Armor"
	desc = "A standard Colonial Marines M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage. It's extremely thick insulation can protect the wearer from extreme temperatures down to 220K (-53°C)."
	icon_state = "s_1"
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/storage/marine/MP
	name = "M2 Pattern MP Armor"
	desc = "A standard Colonial Marines M2 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon_state = "mp"
	armor = list(melee = 40, bullet = 70, laser = 35, energy = 20, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/marine/MP/RO
	icon_state = "officer"
	name = "M3 Pattern Officer Armor"
	desc = "A well-crafted suit of M3 Pattern armor typically found in the hands of higher-ranking officers. Useful for letting your men know who is in charge when taking to the field"

/obj/item/clothing/suit/storage/marine/sniper
	name = "M3 Pattern Recon Armor"
	desc = "A custom modified set of M3 armor designed for recon missions."
	icon_state = "marine_sniper"
	item_state = "marine_sniper"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 70, bullet = 45, laser = 40, energy = 25, bomb = 30, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/marine/sniper/jungle
	name = "M3 Pattern Marksman Armor"
	icon_state = "marine_sniperG"
	item_state = "marine_sniperG"

/obj/item/clothing/suit/storage/marine/sniper/snow
	name = "M3 Pattern Sniper Snow Armor"
	icon_state = "s_marine_sniper" //NEEDS ICON
	item_state = "s_marine_sniper"
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/storage/marine_smartgun_armor
	name = "M56 combat harness"
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "8"
	item_state = "armor"
	slowdown = 1
	icon_override = 'icons/Marine/marine_armor.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	desc = "A heavy protective vest designed to be worn with the M56 Smartgun System. \nIt has specially designed straps and reinforcement to carry the Smartgun and accessories."
	blood_overlay_type = "armor"
	armor = list(melee = 55, bullet = 75, laser = 35, energy = 35, bomb = 35, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/device/flashlight,
					/obj/item/ammo_magazine,
					/obj/item/device/mine,
					/obj/item/weapon/combat_knife,
					/obj/item/weapon/gun/smartgun)

/obj/item/clothing/suit/storage/marine_smartgun_armor/snow
	name = "M56 Combat Snow Harness"
	icon_state = "s_8"
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/storage/marine/marine_leader_armor
	name = "B12 Pattern Leader Armor"
	desc = "A lightweight suit of carbon fiber body armor built for quick movement. Designed in a lovely forest green. Use it to toggle the built-in flashlight."
	icon_state = "7"
	armor = list(melee = 50, bullet = 60, laser = 45, energy = 40, bomb = 40, bio = 15, rad = 15)
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

/obj/item/clothing/suit/storage/marine/marine_leader_armor/snow
	name = "B12 Pattern Leader Snow Armor"
	icon_state = "s_7"
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/storage/marine/marine_spec_armor
	name = "B18 Defensive Armor"
	desc = "A heavy, rugged set of armor plates for when you really, really need to not die horribly. Slows you down though.\nComes with a tricord injector in each arm guard."
	icon_state = "xarmor"
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	slowdown = 1
	armor = list(melee = 95, bullet = 110, laser = 80, energy = 80, bomb = 75, bio = 20, rad = 20)
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

/obj/item/clothing/suit/storage/marine/marine_spec_armor/snow
	name = "B18 Defensive Snow Armor"
	icon_state = "s_xarmor"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE


//=============================//PMCS\\==================================\\
//=======================================================================\\

/obj/item/clothing/suit/storage/marine/PMCarmor
	name = "M4 Pattern PMC Armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "armor"
	icon_state = "pmc_armor"
	armor = list(melee = 55, bullet = 62, laser = 42, energy = 38, bomb = 40, bio = 15, rad = 15)

/obj/item/clothing/suit/storage/marine/PMCarmor/leader
	name = "M4 Pattern PMC Armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind. This particular suit looks like it belongs to a high-ranking officer."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "officer_armor"

/obj/item/clothing/suit/storage/marine/PMCarmor/sniper
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "pmc_sniper"
	icon_state = "pmc_sniper"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS
	armor = list(melee = 60, bullet = 70, laser = 50, energy = 60, bomb = 65, bio = 10, rad = 10)

/obj/item/clothing/suit/storage/marine_smartgun_armor/heavypmc
	name = "PMC Gunner Armor"
	desc = "A modification of the standard Armat Systems M3 armor. Hooked up with harnesses and straps allowing the user to carry an M56 Smartgun."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "heavy_armor"
	icon_state = "heavy_armor"
	item_color = "bear_jumpsuit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 85, bullet = 85, laser = 55, energy = 65, bomb = 70, bio = 20, rad = 20)

/obj/item/clothing/suit/storage/marine/PMCarmor/commando
	name = "PMC Commando Armor"
	desc = "A heavily armored suit built by a subsidiary of Weyland Yutani for elite commandos. It is a fully self-contained system and is heavily corrosion resistant."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "commando_armor"
	icon_state = "commando_armor"
	icon_override = 'icons/PMC/PMC.dmi'
	armor = list(melee = 90, bullet = 120, laser = 100, energy = 90, bomb = 90, bio = 100, rad = 100)
	unacidable = 1
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

//===========================//DISTRESS\\================================\\
//=======================================================================\\

/obj/item/clothing/suit/storage/marine/PMCarmor/Bear
	name = "H1 Iron Bears Vest"
	desc = "A protective vest worn by Iron Bears mercenaries."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "bear_armor"
	icon_state = "bear_armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 70, bullet = 70, laser = 50, energy = 60, bomb = 50, bio = 10, rad = 10)

/obj/item/clothing/suit/storage/marine/PMCarmor/dutch
	name = "Armored Vest"
	desc = "A protective vest"
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "dutch_armor"
	icon_state = "dutch_armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 70, bullet = 85, laser = 55,energy = 65, bomb = 70, bio = 10, rad = 10)

//=========================//ARMOR PROCS\\===============================\\
//=======================================================================\\

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

/obj/item/clothing/suit/storage/marine
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
		overlays += image('icons/Marine/marine_armor.dmi', "lamp-off")


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

		overlays.Cut()
		if(on) //Turn it off.
			if(user)
				user.SetLuminosity(-brightness_on)
			else //Shouldn't be possible, but whatever
				SetLuminosity(0)
			overlays += image('icons/Marine/marine_armor.dmi', "lamp-off")
			on = 0
		else //Turn it on!
			on = 1
			if(user)
				user.SetLuminosity(brightness_on)
			else //Somehow
				SetLuminosity(brightness_on)
			overlays += image('icons/Marine/marine_armor.dmi', "lamp-on")

		playsound(src,'sound/machines/click.ogg', 20, 1)
		update_clothing_icon()
		return 1

/obj/item/clothing/suit/storage/marine/marine_spec_armor/verb/inject()
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
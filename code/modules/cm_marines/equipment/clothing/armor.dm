//=============================//ARMOR\\=================================\\
//=======================================================================\\

/*All protective armor should go in here. This also defined armor for squad
use, and contains the necessary procs at the bottom of the file.
*/
//You can enable this proc to see the combined armor value of a person.

#define DEBUG_ARMOR_PROTECTION 0

#if DEBUG_ARMOR_PROTECTION
/mob/living/carbon/human/verb/check_overall_protection()
	set name = "Get Armor Value"
	set category = "Debug"
	set desc = "Shows the armor value of the bullet category."

	var/armor = 0
	var/counter = 0
	for(var/i in organs_by_name)
		armor = getarmor_organ(organs_by_name[i], "bullet")
		src << "<span class='debuginfo'><b>[i]</b> is protected with <b>[armor]</b> armor against bullets.</span>"
		counter += armor
	src << "<span class='debuginfo'>The overall armor score is: <b>[counter]</b>.</span>"
#endif

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

/obj/item/clothing/suit/armor
	flags_atom = FPRINT
	flags_inventory = BLOCKSHARPOBJ
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_min_cold_protection_temperature
	max_heat_protection_temperature = ARMOR_max_heat_protection_temperature
	siemens_coefficient = 0.6
	w_class = 5
	allowed = list(/obj/item/weapon/gun)//Guns only.
	uniform_restricted = list(/obj/item/clothing/under)

/obj/item/clothing/suit/armor/vest
	name = "armored vest"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	flags_armor_protection = UPPER_TORSO
	armor = list(melee = 50, bullet = 30, laser = 25, energy = 10, bomb = 15, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/vest/pilot
	name = "\improper M70 flak jacket"
	desc = "A flak jacket used by dropship pilots to protect themselves while flying in the cockpit. Excels in protecting the wearer against high-velocity solid projectiles."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "pilot"
	item_state = "pilot"
	icon_override = 'icons/Marine/marine_armor.dmi'
	blood_overlay_type = "armor"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 50, bullet = 60, laser = 35, energy = 20, bomb = 25, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/gun/,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/storage/fancy/cigarettes,
		/obj/item/weapon/flame/lighter,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/grenade,
		/obj/item/device/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/weapon/storage/sparepouch,
		/obj/item/weapon/large_holster/machete,
		/obj/item/weapon/storage/belt/gun/m4a3,
		/obj/item/weapon/storage/belt/gun/m44)
	uniform_restricted = list(/obj/item/clothing/under/marine/officer/pilot)

/obj/item/clothing/suit/armor/vest/dutch
	name = "armored jacket"
	desc = "It's hot in the jungle. Sometimes it's hot and heavy, and sometimes it's hell on earth."
	icon_state = "dutch_armor"
	item_state = "dutch_armor"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/dutch)

/obj/item/clothing/suit/armor/bulletproof
	name = "bulletproof vest"
	desc = "A vest that excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "bulletproof"
	item_state = "armor"
	blood_overlay_type = "armor"
	flags_armor_protection = UPPER_TORSO
	armor = list(melee = 30, bullet = 50, laser = 25, energy = 10, bomb = 15, bio = 0, rad = 0)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/armor/riot
	name = "riot suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement."
	icon_state = "riot"
	item_state = "swat_suit"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	slowdown = 1
	armor = list(melee = 80, bullet = 10, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)
	flags_inventory = HIDEJUMPSUIT|BLOCKSHARPOBJ
	siemens_coefficient = 0.5

/obj/item/clothing/suit/storage/labcoat/officer
	//name = "Medical officer's labcoat"
	icon_state = "labcoatg"
	item_state = "labcoatg"

//===========================//MARINES\\=================================\\
//=======================================================================\\

/obj/item/clothing/suit/armor/riot/marine
	name = "\improper M5 riot control armor"
	desc = "A heavily modified suit of M2 MP Armor used to supress riots from buckethead marines. Slows you down a lot."
	icon_state = "riot"
	item_state = "swat_suit"
	slowdown = SLOWDOWN_ARMOR_VERY_HEAVY
	armor = list(melee = 70, bullet = 45, laser = 35, energy = 20, bomb = 35, bio = 10, rad = 10)

/obj/item/clothing/suit/storage/marine
	name = "\improper M3 pattern marine armor"
	desc = "A standard Colonial Marines M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "1"
	item_state = "armor"
	icon_override = 'icons/Marine/marine_armor.dmi'
	flags_atom = FPRINT|CONDUCT
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = ARMOR_min_cold_protection_temperature
	max_heat_protection_temperature = ARMOR_max_heat_protection_temperature
	blood_overlay_type = "armor"
	armor = list(melee = 50, bullet = 40, laser = 35, energy = 20, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.7
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	allowed = list(/obj/item/weapon/gun/,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/storage/fancy/cigarettes,
		/obj/item/weapon/flame/lighter,
		/obj/item/weapon/grenade,
		/obj/item/weapon/storage/bible,
		///obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/flamethrower,
		/obj/item/device/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/weapon/storage/sparepouch,
		/obj/item/weapon/large_holster/machete,
		/obj/item/weapon/storage/belt/gun/m4a3,
		/obj/item/weapon/storage/belt/gun/m44)

	var/brightness_on = 5 //Average attachable pocket light
	var/flashlight_cooldown = 0 //Cooldown for toggling the light
	var/armor_overlays[]
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list
	var/flags_marine_armor = ARMOR_SQUAD_OVERLAY|ARMOR_LAMP_OVERLAY
	w_class = 5
	uniform_restricted = list(/obj/item/clothing/under/marine)

/obj/item/clothing/suit/storage/marine/MP
	name = "\improper M2 pattern MP armor"
	desc = "A standard Colonial Marines M2 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon_state = "mp"
	armor = list(melee = 40, bullet = 70, laser = 35, energy = 20, bomb = 25, bio = 0, rad = 0)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun/,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/storage/fancy/cigarettes,
		/obj/item/weapon/flame/lighter,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/grenade,
		/obj/item/device/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/weapon/storage/sparepouch,
		/obj/item/device/hailer)
	uniform_restricted = list(/obj/item/clothing/under/marine/mp)

/obj/item/clothing/suit/storage/marine/MP/WO
	icon_state = "warrant_officer"
	name = "\improper M3 pattern MP armor"
	desc = "A well-crafted suit of M3 Pattern Armor typically distributed to Warrant Officers. Useful for letting your men know who is in charge."
	armor = list(melee = 50, bullet = 80, laser = 40, energy = 25, bomb = 30, bio = 0, rad = 0)
	uniform_restricted = list(/obj/item/clothing/under/marine/officer/warrant)

/obj/item/clothing/suit/storage/marine/MP/RO
	icon_state = "officer"
	name = "\improper M3 pattern officer armor"
	desc = "A well-crafted suit of M3 Pattern Armor typically found in the hands of higher-ranking officers. Useful for letting your men know who is in charge when taking to the field"
	uniform_restricted = list(/obj/item/clothing/under/marine/officer, /obj/item/clothing/under/rank/ro_suit)

/obj/item/clothing/suit/storage/marine/sniper
	name = "\improper M3 pattern recon armor"
	desc = "A custom modified set of M3 Armor designed for recon missions."
	icon_state = "marine_sniper"
	item_state = "marine_sniper"
	armor = list(melee = 70, bullet = 45, laser = 40, energy = 25, bomb = 30, bio = 0, rad = 0)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEG_RIGHT|ARM_LEFT
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEG_RIGHT|ARM_LEFT
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEG_RIGHT|ARM_LEFT
	//uniform_restricted = list(/obj/item/clothing/under/marine/sniper) //TODO : This item exists, but isn't implemented yet. Makes sense otherwise

	New(loc,expected_type 	= type,
		new_name[] 		= list(/datum/game_mode/ice_colony = "\improper M3 pattern sniper snow armor"))
		..(loc,expected_type,,new_name)

/obj/item/clothing/suit/storage/marine/sniper/jungle
	name = "\improper M3 pattern marksman armor"
	icon_state = "marine_sniperm"
	item_state = "marine_sniperm"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

	New(loc,expected_type 	= type,
		new_name[] 		= list(/datum/game_mode/ice_colony = "\improper M3 pattern marksman snow armor"))
		..(loc,expected_type,,new_name)

/obj/item/clothing/suit/storage/marine/smartgunner
	name = "M56 combat harness"
	desc = "A heavy protective vest designed to be worn with the M56 Smartgun System. \nIt has specially designed straps and reinforcement to carry the Smartgun and accessories."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "8"
	item_state = "armor"
	icon_override = 'icons/Marine/marine_armor.dmi'
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	armor = list(melee = 55, bullet = 75, laser = 35, energy = 35, bomb = 35, bio = 0, rad = 0)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/device/flashlight,
					/obj/item/ammo_magazine,
					/obj/item/device/mine,
					/obj/item/weapon/combat_knife,
					/obj/item/weapon/gun/smartgun,
					/obj/item/weapon/storage/sparepouch)

/obj/item/clothing/suit/storage/marine/leader
	name = "\improper B12 pattern leader armor"
	desc = "A lightweight suit of carbon fiber body armor built for quick movement. Designed in a lovely forest green. Use it to toggle the built-in flashlight."
	icon_state = "7"
	armor = list(melee = 50, bullet = 60, laser = 45, energy = 40, bomb = 40, bio = 15, rad = 15)

	New(loc,expected_type 	= type,
		new_name[] 		= list(/datum/game_mode/ice_colony = "\improper B12 pattern leader snow armor"))
		..(loc,expected_type,new_name)

/obj/item/clothing/suit/storage/marine/specialist
	name = "\improper B18 defensive armor"
	desc = "A heavy, rugged set of armor plates for when you really, really need to not die horribly. Slows you down though.\nComes with a tricord injector in each arm guard."
	icon_state = "xarmor"
	armor = list(melee = 95, bullet = 110, laser = 80, energy = 80, bomb = 75, bio = 20, rad = 20)
	slowdown = SLOWDOWN_ARMOR_HEAVY
	var/injections = 2
	unacidable = 1

	New(loc,expected_type 	= type,
		new_name[] 		= list(/datum/game_mode/ice_colony = "\improper B18 defensive snow armor"))
		..(loc,expected_type,new_name)

//=============================//PMCS\\==================================\\
//=======================================================================\\

/obj/item/clothing/suit/storage/marine/veteran
	flags_marine_armor = ARMOR_LAMP_OVERLAY

/obj/item/clothing/suit/storage/marine/veteran/PMC
	name = "\improper M4 pattern PMC armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "armor"
	icon_state = "pmc_armor"
	armor = list(melee = 55, bullet = 62, laser = 42, energy = 38, bomb = 40, bio = 15, rad = 15)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun/,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/storage/fancy/cigarettes,
		/obj/item/weapon/flame/lighter,
		/obj/item/weapon/grenade,
		/obj/item/weapon/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/flamethrower,
		/obj/item/weapon/combat_knife)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/PMC)

/obj/item/clothing/suit/storage/marine/veteran/PMC/leader
	name = "\improper M4 pattern PMC leader armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind. This particular suit looks like it belongs to a high-ranking officer."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "officer_armor"
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/PMC/leader)

/obj/item/clothing/suit/storage/marine/veteran/PMC/sniper
	name = "\improper M4 pattern PMC sniper armor"
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "pmc_sniper"
	icon_state = "pmc_sniper"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	armor = list(melee = 60, bullet = 70, laser = 50, energy = 60, bomb = 65, bio = 10, rad = 10)
	flags_inventory = BLOCKSHARPOBJ|HIDELOWHAIR

/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC
	name = "\improper PMC gunner armor"
	desc = "A modification of the standard Armat Systems M3 armor. Hooked up with harnesses and straps allowing the user to carry an M56 Smartgun."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "heavy_armor"
	icon_state = "heavy_armor"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 85, bullet = 85, laser = 55, energy = 65, bomb = 70, bio = 20, rad = 20)

/obj/item/clothing/suit/storage/marine/veteran/PMC/commando
	name = "\improper PMC commando armor"
	desc = "A heavily armored suit built by who-knows-what for elite operations. It is a fully self-contained system and is heavily corrosion resistant."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "commando_armor"
	icon_state = "commando_armor"
	icon_override = 'icons/PMC/PMC.dmi'
	slowdown = SLOWDOWN_ARMOR_VERY_HEAVY
	armor = list(melee = 90, bullet = 120, laser = 100, energy = 90, bomb = 90, bio = 100, rad = 100)
	unacidable = 1
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/PMC/commando)

//===========================//DISTRESS\\================================\\
//=======================================================================\\

/obj/item/clothing/suit/storage/marine/veteran/bear
	name = "\improper H1 Iron Bears vest"
	desc = "A protective vest worn by Iron Bears mercenaries."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "bear_armor"
	icon_state = "bear_armor"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 70, bullet = 70, laser = 50, energy = 60, bomb = 50, bio = 10, rad = 10)
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/bear)

/obj/item/clothing/suit/storage/marine/veteran/dutch
	name = "\improper D2 armored vest"
	desc = "A protective vest worn by some seriously experienced mercs."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "dutch_armor"
	icon_state = "dutch_armor"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 70, bullet = 85, laser = 55,energy = 65, bomb = 70, bio = 10, rad = 10)
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/dutch)

/obj/item/clothing/suit/space/compression
	name = "\improper MK.50 compression suit"
	desc = "A heavy, bulky civilian space suit, fitted with armored plates. Commonly seen in the hands of mercenaries, explorers, scavengers, and researchers."
	item_state = "compression"
	icon_state = "compression"
	armor = list(melee = 50, bullet = 55, laser = 65,energy = 70, bomb = 65, bio = 100, rad = 70)
	unacidable = 1


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
	New(loc,expected_type 		= /obj/item/clothing/suit/storage/marine,
		new_name[] 			= list(/datum/game_mode/ice_colony = "\improper M3 pattern marine snow armor"))
		if(type == /obj/item/clothing/suit/storage/marine)
			var/armor_variation = rand(1,6)
			switch(armor_variation)
				if(2,3)
					flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS
					flags_cold_protection = flags_armor_protection
					flags_heat_protection = flags_armor_protection
			icon_state = "[armor_variation]"

		select_gamemode_skin(expected_type,,new_name)
		..()
		armor_overlays = list("lamp") //Just one for now, can add more later.
		update_icon()

	update_icon(mob/user)
		var/image/reusable/I
		I = armor_overlays["lamp"]
		overlays -= I
		cdel(I)
		if(flags_marine_armor & ARMOR_LAMP_OVERLAY)
			I = rnew(/image/reusable, flags_marine_armor & ARMOR_LAMP_ON? list('icons/Marine/marine_armor.dmi', src, "lamp-on") : list('icons/Marine/marine_armor.dmi', src, "lamp-off"))
			armor_overlays["lamp"] = I
			overlays += I
		else armor_overlays["lamp"] = null
		if(user) user.update_inv_wear_suit()

	pickup(mob/user)
		if(flags_marine_armor & ARMOR_LAMP_ON && src.loc != user)
			user.SetLuminosity(brightness_on)
			SetLuminosity(0)

	dropped(mob/user)
		if(flags_marine_armor & ARMOR_LAMP_ON && src.loc != user)
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
			user << "<span class='warning'>You cannot turn the light on while in this [user.loc].</span>" //To prevent some lighting anomalities.
			return

		if(flashlight_cooldown > world.time)
			return

		flashlight_cooldown = world.time + 20 //2 seconds cooldown every time the light is toggled
		if(flags_marine_armor & ARMOR_LAMP_ON) //Turn it off.
			if(user) user.SetLuminosity(-brightness_on)
			else SetLuminosity(0)
		else //Turn it on.
			if(user) user.SetLuminosity(brightness_on)
			else SetLuminosity(brightness_on)

		flags_marine_armor ^= ARMOR_LAMP_ON

		playsound(src,'sound/machines/click.ogg', 20, 1)
		update_icon(user)
		return 1

/obj/item/clothing/suit/storage/marine/specialist/verb/inject()
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
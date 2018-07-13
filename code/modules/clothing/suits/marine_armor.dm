#define DEBUG_ARMOR_PROTECTION 0

#if DEBUG_ARMOR_PROTECTION
/mob/living/carbon/human/verb/check_overall_protection()
	set name = "Get Armor Value"
	set category = "Debug"
	set desc = "Shows the armor value of the bullet category."

	var/armor = 0
	var/counter = 0
	for(var/X in H.limbs)
		var/datum/limb/E = X
		armor = getarmor_organ(E, "bullet")
		src << "<span class='debuginfo'><b>[E.name]</b> is protected with <b>[armor]</b> armor against bullets.</span>"
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
var/list/squad_colors = list(rgb(230,25,25), rgb(255,195,45), rgb(200,100,200), rgb(65,72,200))

/proc/initialize_marine_armor()
	var/i
	for(i=1, i<5, i++)
		var/image/armor
		var/image/helmet
		armor = image('icons/mob/suit_1.dmi',icon_state = "std-armor")
		armor.color = squad_colors[i]
		armormarkings += armor
		armor = image('icons/mob/suit_1.dmi',icon_state = "sql-armor")
		armor.color = squad_colors[i]
		armormarkings_sql += armor

		helmet = image('icons/mob/head_1.dmi',icon_state = "std-helmet")
		helmet.color = squad_colors[i]
		helmetmarkings += helmet
		helmet = image('icons/mob/head_1.dmi',icon_state = "sql-helmet")
		helmet.color = squad_colors[i]
		helmetmarkings_sql += helmet




// MARINE STORAGE ARMOR

/obj/item/clothing/suit/storage/marine
	name = "\improper M3 pattern marine armor"
	desc = "A standard Colonial Marines M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon = 'icons/obj/clothing/cm_suits.dmi'
	icon_state = "1"
	item_state = "armor"
	sprite_sheet_id = 1
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
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/device/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/storage/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/storage/belt/gun/m4a3,
		/obj/item/storage/belt/gun/m44,
		/obj/item/device/healthanalyzer)

	var/brightness_on = 5 //Average attachable pocket light
	var/flashlight_cooldown = 0 //Cooldown for toggling the light
	var/locate_cooldown = 0 //Cooldown for SL locator
	var/armor_overlays[]
	actions_types = list(/datum/action/item_action/toggle)
	var/flags_marine_armor = ARMOR_SQUAD_OVERLAY|ARMOR_LAMP_OVERLAY
	w_class = 5
	uniform_restricted = list(/obj/item/clothing/under/marine)
	time_to_unequip = 20
	time_to_equip = 20

/obj/item/clothing/suit/storage/marine/New(loc,expected_type 		= /obj/item/clothing/suit/storage/marine,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper M3 pattern marine snow armor"))
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
	pockets.max_w_class = 2 //Can contain small items AND rifle magazines.
	pockets.bypass_w_limit = list(
	"/obj/item/ammo_magazine/rifle",
	"/obj/item/ammo_magazine/smg",
	"/obj/item/ammo_magazine/sniper",
	 )
	pockets.max_storage_space = 6



/obj/item/clothing/suit/storage/marine/update_icon(mob/user)
	var/image/reusable/I
	I = armor_overlays["lamp"]
	overlays -= I
	cdel(I)
	if(flags_marine_armor & ARMOR_LAMP_OVERLAY)
		I = rnew(/image/reusable, flags_marine_armor & ARMOR_LAMP_ON? list('icons/obj/clothing/cm_suits.dmi', src, "lamp-on") : list('icons/obj/clothing/cm_suits.dmi', src, "lamp-off"))
		armor_overlays["lamp"] = I
		overlays += I
	else armor_overlays["lamp"] = null
	if(user) user.update_inv_wear_suit()

/obj/item/clothing/suit/storage/marine/pickup(mob/user)
	if(flags_marine_armor & ARMOR_LAMP_ON && src.loc != user)
		user.SetLuminosity(brightness_on)
		SetLuminosity(0)
	..()

/obj/item/clothing/suit/storage/marine/dropped(mob/user)
	if(loc != user)
		turn_off_light(user)
	..()

/obj/item/clothing/suit/storage/marine/proc/turn_off_light(mob/wearer)
	if(flags_marine_armor & ARMOR_LAMP_ON)
		wearer.SetLuminosity(-brightness_on)
		SetLuminosity(brightness_on)
		toggle_armor_light() //turn the light off
		return 1
	return 0

/obj/item/clothing/suit/storage/marine/Dispose()
	if(ismob(src.loc))
		src.loc.SetLuminosity(-brightness_on)
	else
		SetLuminosity(0)
	. = ..()

/obj/item/clothing/suit/storage/marine/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "<span class='warning'>You cannot turn the light on while in [user.loc].</span>" //To prevent some lighting anomalities.
		return

	if(flashlight_cooldown > world.time)
		return

	if(!ishuman(user)) return
	var/mob/living/carbon/human/H = user
	if(H.wear_suit != src) return

	toggle_armor_light(user)
	return 1

/obj/item/clothing/suit/storage/marine/item_action_slot_check(mob/user, slot)
	if(!ishuman(user)) return FALSE
	if(slot != WEAR_JACKET) return FALSE
	return TRUE //only give action button when armor is worn.

/obj/item/clothing/suit/storage/marine/proc/toggle_armor_light(mob/user)
	flashlight_cooldown = world.time + 20 //2 seconds cooldown every time the light is toggled
	if(flags_marine_armor & ARMOR_LAMP_ON) //Turn it off.
		if(user) user.SetLuminosity(-brightness_on)
		else SetLuminosity(0)
	else //Turn it on.
		if(user) user.SetLuminosity(brightness_on)
		else SetLuminosity(brightness_on)

	flags_marine_armor ^= ARMOR_LAMP_ON

	playsound(src,'sound/machines/click.ogg', 15, 1)
	update_icon(user)

	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()




/obj/item/clothing/suit/storage/marine/MP
	name = "\improper M2 pattern MP armor"
	desc = "A standard Colonial Marines M2 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon_state = "mp"
	armor = list(melee = 40, bullet = 70, laser = 35, energy = 20, bomb = 25, bio = 0, rad = 0)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/weapon/baton,
		/obj/item/handcuffs,
		/obj/item/explosive/grenade,
		/obj/item/device/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/storage/sparepouch,
		/obj/item/device/hailer,
		/obj/item/storage/belt/gun)
	uniform_restricted = list(/obj/item/clothing/under/marine/mp)

/obj/item/clothing/suit/storage/marine/MP/WO
	icon_state = "warrant_officer"
	name = "\improper M3 pattern MP armor"
	desc = "A well-crafted suit of M3 Pattern Armor typically distributed to Chief MPs. Useful for letting your men know who is in charge."
	armor = list(melee = 50, bullet = 80, laser = 40, energy = 25, bomb = 30, bio = 0, rad = 0)
	uniform_restricted = list(/obj/item/clothing/under/marine/officer/warrant)

/obj/item/clothing/suit/storage/marine/MP/admiral
	icon_state = "admiral"
	name = "\improper M3 pattern admiral armor"
	desc = "A well-crafted suit of M3 Pattern Armor with a gold shine. It looks very expensive, but shockingly fairly easy to carry and wear."
	w_class = 3
	armor = list(melee = 50, bullet = 80, laser = 40, energy = 25, bomb = 30, bio = 0, rad = 0)
	uniform_restricted = list(/obj/item/clothing/under/marine/officer/admiral)

/obj/item/clothing/suit/storage/marine/MP/RO
	icon_state = "officer"
	name = "\improper M3 pattern officer armor"
	desc = "A well-crafted suit of M3 Pattern Armor typically found in the hands of higher-ranking officers. Useful for letting your men know who is in charge when taking to the field"
	uniform_restricted = list(/obj/item/clothing/under/marine/officer, /obj/item/clothing/under/rank/ro_suit)

/obj/item/clothing/suit/storage/marine/MP/RO/New()
	select_gamemode_skin(/obj/item/clothing/suit/storage/marine/MP/RO)
	..()


/obj/item/clothing/suit/storage/marine/smartgunner
	name = "M56 combat harness"
	desc = "A heavy protective vest designed to be worn with the M56 Smartgun System. \nIt has specially designed straps and reinforcement to carry the Smartgun and accessories."
	icon_state = "8"
	item_state = "armor"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 55, bullet = 75, laser = 35, energy = 35, bomb = 35, bio = 0, rad = 0)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/tank/emergency_oxygen,
					/obj/item/device/flashlight,
					/obj/item/ammo_magazine,
					/obj/item/explosive/mine,
					/obj/item/weapon/combat_knife,
					/obj/item/weapon/gun/smartgun,
					/obj/item/storage/sparepouch)

/obj/item/clothing/suit/storage/marine/smartgunner/New()
	select_gamemode_skin(/obj/item/clothing/suit/storage/marine/smartgunner)
	..()


/obj/item/clothing/suit/storage/marine/leader
	name = "\improper B12 pattern leader armor"
	desc = "A lightweight suit of carbon fiber body armor built for quick movement. Designed in a lovely forest green. Use it to toggle the built-in flashlight."
	icon_state = "7"
	armor = list(melee = 50, bullet = 60, laser = 45, energy = 40, bomb = 40, bio = 15, rad = 15)

	New(loc,expected_type 	= type,
		new_name[] 		= list(MAP_ICE_COLONY = "\improper B12 pattern leader snow armor"))
		..(loc,expected_type,new_name)

/obj/item/clothing/suit/storage/marine/tanker
	name = "\improper M3 pattern tanker armor"
	desc = "A modified and refashioned suit of M3 Pattern armor designed to be worn by the loader of a USCM vehicle crew. While the suit is a bit more encumbering to wear with the crewman uniform, it offers the loader a degree of protection that would otherwise not be enjoyed."
	icon_state = "tanker"
	uniform_restricted = list(/obj/item/clothing/under/marine/officer/tanker)

	New()
		select_gamemode_skin(type)
		..()

//===========================//SPECIALIST\\================================\\
//=======================================================================\\

/obj/item/clothing/suit/storage/marine/specialist
	name = "\improper B18 defensive armor"
	desc = "A heavy, rugged set of armor plates for when you really, really need to not die horribly. Slows you down though.\nComes with two tricord injectors in each arm guard."
	icon_state = "xarmor"
	armor = list(melee = 95, bullet = 110, laser = 80, energy = 80, bomb = 75, bio = 20, rad = 20)
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|FEET
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|FEET
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|FEET
	slowdown = SLOWDOWN_ARMOR_HEAVY
	var/injections = 4
	unacidable = 1

	New(loc,expected_type 	= type,
		new_name[] 		= list(MAP_ICE_COLONY = "\improper B18 defensive snow armor"))
		..(loc,expected_type,new_name)

/obj/item/clothing/suit/storage/marine/specialist/mob_can_equip(mob/M, slot, disable_warning = 0)
	. = ..()
	if(.)
		if(M.mind && M.mind.cm_skills && M.mind.cm_skills.spec_weapons < SKILL_SPEC_TRAINED && M.mind.cm_skills.spec_weapons != SKILL_SPEC_GRENADIER)
			M << "<span class='warning'>You are not trained to use [src]!</span>"
			return 0

/obj/item/clothing/suit/storage/marine/specialist/verb/inject()
	set name = "Create Injector"
	set category = "Object"
	set src in usr

	if(!usr.canmove || usr.stat || usr.is_mob_restrained())
		return 0

	if(!injections)
		usr << "Your armor is all out of injectors."
		return 0

	if(usr.get_active_hand())
		usr << "Your active hand must be empty."
		return 0

	usr << "You feel a faint hiss and an injector drops into your hand."
	var/obj/item/reagent_container/hypospray/autoinjector/tricord/skillless/O = new(usr)
	usr.put_in_active_hand(O)
	injections--
	playsound(src,'sound/machines/click.ogg', 15, 1)
	return

/obj/item/clothing/suit/storage/marine/M3T
	name = "\improper M3-T light armor"
	desc = "A custom set of M3 armor designed for users of long ranged explosive weaponry."
	icon_state = "demolitionist"
	armor = list(melee = 70, bullet = 45, laser = 40, energy = 25, bomb = 35, bio = 0, rad = 0)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun/launcher/rocket)

	New()
		select_gamemode_skin(type)
		..()

/obj/item/clothing/suit/storage/marine/M3S
	name = "\improper M3-S light armor"
	desc = "A custom set of M3 armor designed for USCM Scouts."
	icon_state = "scout_armor"
	armor = list(melee = 75, bullet = 45, laser = 40, energy = 25, bomb = 55, bio = 0, rad = 0)
	slowdown = SLOWDOWN_ARMOR_LIGHT

	New()
		select_gamemode_skin(type)
		..()

/obj/item/clothing/suit/storage/marine/M3S/mob_can_equip(mob/M, slot, disable_warning = 0)
	. = ..()
	if(.)
		if(M.mind && M.mind.cm_skills && M.mind.cm_skills.spec_weapons < SKILL_SPEC_TRAINED && M.mind.cm_skills.spec_weapons != SKILL_SPEC_SCOUT)
			M << "<span class='warning'>You are not trained to use [src]!</span>"
			return 0

/obj/item/clothing/suit/storage/marine/M35
	name = "\improper M35 armor"
	desc = "A custom set of M35 armor designed for use by USCM Pyrotechnicians."
	icon_state = "pyro_armor"
	armor = list(melee = 85, bullet = 90, laser = 60, energy = 60, bomb = 30, bio = 0, rad = 0)
	max_heat_protection_temperature = FIRESUIT_max_heat_protection_temperature
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|FEET
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|FEET
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|FEET

	New()
		select_gamemode_skin(type)
		..()

/obj/item/clothing/suit/storage/marine/M35/mob_can_equip(mob/M, slot, disable_warning = 0)
	. = ..()
	if(.)
		if(M.mind && M.mind.cm_skills && M.mind.cm_skills.spec_weapons < SKILL_SPEC_TRAINED && M.mind.cm_skills.spec_weapons != SKILL_SPEC_PYRO)
			M << "<span class='warning'>You are not trained to use [src]!</span>"
			return 0

/obj/item/clothing/suit/storage/marine/sniper
	name = "\improper M3 pattern recon armor"
	desc = "A custom modified set of M3 armor designed for recon missions."
	icon_state = "marine_sniper"
	armor = list(melee = 70, bullet = 45, laser = 40, energy = 25, bomb = 30, bio = 0, rad = 0)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	//uniform_restricted = list(/obj/item/clothing/under/marine/sniper) //TODO : This item exists, but isn't implemented yet. Makes sense otherwise

	New(loc,expected_type 	= type,
		new_name[] 		= list(MAP_ICE_COLONY = "\improper M3 pattern sniper snow armor"))
		..(loc,expected_type,,new_name)

/obj/item/clothing/suit/storage/marine/sniper/jungle
	name = "\improper M3 pattern marksman armor"
	icon_state = "marine_sniperm"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

	New(loc,expected_type 	= type,
		new_name[] 		= list(MAP_ICE_COLONY = "\improper M3 pattern marksman snow armor"))
		..(loc,expected_type,,new_name)


//=============================//PMCS\\==================================\\
//=======================================================================\\

/obj/item/clothing/suit/storage/marine/veteran
	flags_marine_armor = ARMOR_LAMP_OVERLAY

/obj/item/clothing/suit/storage/marine/veteran/PMC
	name = "\improper M4 pattern PMC armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind."
	icon_state = "pmc_armor"
	armor = list(melee = 55, bullet = 62, laser = 42, energy = 38, bomb = 40, bio = 15, rad = 15)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/PMC)

/obj/item/clothing/suit/storage/marine/veteran/PMC/leader
	name = "\improper M4 pattern PMC leader armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind. This particular suit looks like it belongs to a high-ranking officer."
	icon_state = "officer_armor"
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/PMC/leader)

/obj/item/clothing/suit/storage/marine/veteran/PMC/sniper
	name = "\improper M4 pattern PMC sniper armor"
	icon_state = "pmc_sniper"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	armor = list(melee = 60, bullet = 70, laser = 50, energy = 60, bomb = 65, bio = 10, rad = 10)
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDELOWHAIR

/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC
	name = "\improper PMC gunner armor"
	desc = "A modification of the standard Armat Systems M3 armor. Hooked up with harnesses and straps allowing the user to carry an M56 Smartgun."
	icon_state = "heavy_armor"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 85, bullet = 85, laser = 55, energy = 65, bomb = 70, bio = 20, rad = 20)

/obj/item/clothing/suit/storage/marine/veteran/PMC/commando
	name = "\improper PMC commando armor"
	desc = "A heavily armored suit built by who-knows-what for elite operations. It is a fully self-contained system and is heavily corrosion resistant."
	icon_state = "commando_armor"
	slowdown = SLOWDOWN_ARMOR_VERY_HEAVY
	armor = list(melee = 90, bullet = 120, laser = 100, energy = 90, bomb = 90, bio = 100, rad = 100)
	unacidable = 1
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/PMC/commando)

//===========================//DISTRESS\\================================\\
//=======================================================================\\

/obj/item/clothing/suit/storage/marine/veteran/bear
	name = "\improper H1 Iron Bears vest"
	desc = "A protective vest worn by Iron Bears mercenaries."
	icon_state = "bear_armor"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 70, bullet = 70, laser = 50, energy = 60, bomb = 50, bio = 10, rad = 10)
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/bear)

/obj/item/clothing/suit/storage/marine/veteran/dutch
	name = "\improper D2 armored vest"
	desc = "A protective vest worn by some seriously experienced mercs."
	icon_state = "dutch_armor"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 70, bullet = 85, laser = 55,energy = 65, bomb = 70, bio = 10, rad = 10)
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/dutch)




//===========================//U.P.P\\================================\\
//=====================================================================\\

/obj/item/clothing/suit/storage/faction
	icon = 'icons/obj/clothing/cm_suits.dmi'
	sprite_sheet_id = 1
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
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/explosive/grenade,
		/obj/item/device/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/storage/sparepouch,
		/obj/item/storage/large_holster/machete)
	var/brightness_on = 5 //Average attachable pocket light
	var/flashlight_cooldown = 0 //Cooldown for toggling the light
	var/locate_cooldown = 0 //Cooldown for SL locator
	var/armor_overlays["lamp"]
	actions_types = list(/datum/action/item_action/toggle)
	var/flags_faction_armor = ARMOR_LAMP_OVERLAY

/obj/item/clothing/suit/storage/faction/New()
	..()
	armor_overlays = list("lamp")
	update_icon()

/obj/item/clothing/suit/storage/faction/update_icon(mob/user)
	var/image/reusable/I
	I = armor_overlays["lamp"]
	overlays -= I
	cdel(I)
	if(flags_faction_armor & ARMOR_LAMP_OVERLAY)
		I = rnew(/image/reusable, flags_faction_armor & ARMOR_LAMP_ON? list('icons/obj/clothing/cm_suits.dmi', src, "lamp-on") : list('icons/obj/clothing/cm_suits.dmi', src, "lamp-off"))
		armor_overlays["lamp"] = I
		overlays += I
	else armor_overlays["lamp"] = null
	if(user) user.update_inv_wear_suit()

/obj/item/clothing/suit/storage/faction/pickup(mob/user)
	if(flags_faction_armor & ARMOR_LAMP_ON && src.loc != user)
		user.SetLuminosity(brightness_on)
		SetLuminosity(0)
	..()

/obj/item/clothing/suit/storage/faction/dropped(mob/user)
	if(flags_faction_armor & ARMOR_LAMP_ON && src.loc != user)
		user.SetLuminosity(-brightness_on)
		SetLuminosity(brightness_on)
		toggle_armor_light() //turn the light off
	..()

/obj/item/clothing/suit/storage/faction/Dispose()
	if(ismob(src.loc))
		src.loc.SetLuminosity(-brightness_on)
	else
		SetLuminosity(0)
	. = ..()

/obj/item/clothing/suit/storage/faction/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "<span class='warning'>You cannot turn the light on while in [user.loc].</span>" //To prevent some lighting anomalities.
		return

	if(flashlight_cooldown > world.time)
		return

	if(!ishuman(user)) return
	var/mob/living/carbon/human/H = user
	if(H.wear_suit != src) return

	toggle_armor_light(user)
	return 1

/obj/item/clothing/suit/storage/faction/item_action_slot_check(mob/user, slot)
	if(!ishuman(user)) return FALSE
	if(slot != WEAR_JACKET) return FALSE
	return TRUE //only give action button when armor is worn.

/obj/item/clothing/suit/storage/faction/proc/toggle_armor_light(mob/user)
	flashlight_cooldown = world.time + 20 //2 seconds cooldown every time the light is toggled
	if(flags_faction_armor & ARMOR_LAMP_ON) //Turn it off.
		if(user) user.SetLuminosity(-brightness_on)
		else SetLuminosity(0)
	else //Turn it on.
		if(user) user.SetLuminosity(brightness_on)
		else SetLuminosity(brightness_on)

	flags_faction_armor ^= ARMOR_LAMP_ON

	playsound(src,'sound/machines/click.ogg', 15, 1)
	update_icon(user)

	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()




/obj/item/clothing/suit/storage/faction/UPP
	name = "\improper UM5 personal armor"
	desc = "Standard body armor of the UPP military, the UM5 (Union Medium MK5) is a medium body armor, roughly on par with the venerable M3 pattern body armor in service with the USCM. Unlike the M3, however, the plate has a heavier neckplate, but unfortunately restricts movement slightly more. This has earned many UA members to refer to UPP soldiers as 'tin men'."
	icon_state = "upp_armor"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 60, bullet = 60, laser = 50, energy = 60, bomb = 40, bio = 10, rad = 10)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/UPP)

/obj/item/clothing/suit/storage/faction/UPP/commando
	name = "\improper UM5CU personal armor"
	desc = "A modification of the UM5, designed for stealth operations."
	icon_state = "upp_armor_commando"
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/storage/faction/UPP/heavy
	name = "\improper UH7 heavy plated armor"
	desc = "An extremely heavy duty set of body armor in service with the UPP military, the UH7 (Union Heavy MK5) is known for being a rugged set of armor, capable of taking immesnse punishment. Although the armor doesn't protect certain areas, it provides unmatchable protection from the front, which UPP engineers summerized as the most likely target for enemy fire. In order to cut costs, the head shielding in the MK6 has been stripped down a bit in the MK7, but this comes at much more streamlined production.  "
	icon_state = "upp_armor_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	armor = list(melee = 85, bullet = 85, laser = 50, energy = 60, bomb = 60, bio = 10, rad = 10)

/obj/item/clothing/suit/storage/marine/smartgunner/UPP
	name = "\improper UH7 heavy plated armor"
	desc = "An extremely heavy duty set of body armor in service with the UPP military, the UH7 (Union Heavy MK5) is known for being a rugged set of armor, capable of taking immesnse punishment. Although the armor doesn't protect certain areas, it provides unmatchable protection from the front, which UPP engineers summerized as the most likely target for enemy fire. In order to cut costs, the head shielding in the MK6 has been stripped down a bit in the MK7, but this comes at much more streamlined production.  "
	icon_state = "upp_armor_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 85, bullet = 85, laser = 50, energy = 60, bomb = 60, bio = 10, rad = 10)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/UPP)

//===========================//FREELANCER\\================================\\
//=====================================================================\\

/obj/item/clothing/suit/storage/faction/freelancer
	name = "\improper freelancer cuirass"
	desc = "A armored protective chestplate scrapped together from various plates. It keeps up remarkably well, as the craftsmanship is solid, and the design mirrors such armors in the UPP and the USCM. The many skilled craftsmen in the freelancers ranks produce these vests at a rate about one a month."
	icon_state = "freelancer_armor"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 60, bullet = 60, laser = 50, energy = 60, bomb = 40, bio = 10, rad = 10)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/freelancer)

//this one is for CLF
/obj/item/clothing/suit/storage/militia
	name = "\improper colonial militia hauberk"
	desc = "The hauberk of a colonist militia member, created from boiled leather and some modern armored plates. While not the most powerful form of armor, and primitive compared to most modern suits of armor, it gives the wearer almost perfect mobility, which suits the needs of the local colonists. It is also quick to don, easy to hide, and cheap to produce in large workshops."
	icon = 'icons/obj/clothing/cm_suits.dmi'
	icon_state = "rebel_armor"
	sprite_sheet_id = 1
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 30, bomb = 60, bio = 30, rad = 30)
	uniform_restricted = list(/obj/item/clothing/under/colonist)
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/explosive/grenade,
		/obj/item/device/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/storage/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/weapon/baseballbat,
		/obj/item/weapon/baseballbat/metal)
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_min_cold_protection_temperature

/obj/item/clothing/suit/storage/CMB
	name = "\improper CMB jacket"
	desc = "A green jacket worn by crew on the Colonial Marshals."
	icon_state = "CMB_jacket"
	blood_overlay_type = "coat"
	flags_armor_protection = UPPER_TORSO|ARMS

/obj/item/clothing/suit/storage/RO
	name = "\improper RO jacket"
	desc = "A green jacket worn by USCM personnel. The back has the flag of the United Americas on it."
	icon_state = "RO_jacket"
	blood_overlay_type = "coat"
	flags_armor_protection = UPPER_TORSO|ARMS

//===========================//HELGHAST - MERCENARY\\================================\\
//=====================================================================\\

/obj/item/clothing/suit/storage/marine/veteran/mercenary
	name = "\improper K12 ceramic plated armor"
	desc = "A set of grey, heavy ceramic armor with dark blue highlights. It is the standard uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_heavy_armor"
	armor = list(melee = 75, bullet = 62, laser = 42, energy = 38, bomb = 40, bio = 15, rad = 15)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/mercenary)

/obj/item/clothing/suit/storage/marine/veteran/mercenary/miner
	name = "\improper Y8 armored miner vest"
	desc = "A set of beige, light armor built for protection while mining. It is a specialized uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_miner_armor"
	armor = list(melee = 50, bullet = 42, laser = 42, energy = 38, bomb = 25, bio = 15, rad = 15)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/mercenary)

/obj/item/clothing/suit/storage/marine/veteran/mercenary/engineer
	name = "\improper Z7 armored engineer vest"
	desc = "A set of blue armor with yellow highlights built for protection while building in highly dangerous environments. It is a specialized uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_engineer_armor"
	armor = list(melee = 55, bullet = 52, laser = 42, energy = 38, bomb = 30, bio = 15, rad = 15)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/mercenary)
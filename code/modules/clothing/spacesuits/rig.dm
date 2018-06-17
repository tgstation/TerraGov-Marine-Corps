//Regular rig suits
/obj/item/clothing/head/helmet/space/rig
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/device/flashlight)
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	var/rig_color = "engineering" //Determines used sprites: rig[on]-[color] and rig[on]-[color]2 (lying down sprite)
	actions_types = list(/datum/action/item_action/toggle)
	flags_heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_max_heat_protection_temperature

	//Species-specific stuff.
	species_restricted = list("exclude","Unathi","Tajara","Skrell","Vox")
	sprite_sheets_refit = list(
		"Unathi" = 'icons/mob/species/unathi/helmet.dmi',
		"Tajara" = 'icons/mob/species/tajaran/helmet.dmi',
		"Skrell" = 'icons/mob/species/skrell/helmet.dmi',
		)
	sprite_sheets_obj = list(
		"Unathi" = 'icons/obj/clothing/species/unathi/hats.dmi',
		"Tajara" = 'icons/obj/clothing/species/tajaran/hats.dmi',
		"Skrell" = 'icons/obj/clothing/species/skrell/hats.dmi',
		)

	attack_self(mob/user)
		if(!isturf(user.loc))
			user << "You cannot turn the light on while in [user.loc]" //To prevent some lighting anomalities.
			return
		on = !on
		icon_state = "rig[on]-[rig_color]"

		if(on)	user.SetLuminosity(brightness_on)
		else	user.SetLuminosity(-brightness_on)

		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.update_inv_head()

		for(var/X in actions)
			var/datum/action/A = X
			A.update_button_icon()

	pickup(mob/user)
		if(on)
			user.SetLuminosity(brightness_on)
//			user.UpdateLuminosity()
			SetLuminosity(0)
		..()

	dropped(mob/user)
		if(on)
			user.SetLuminosity(-brightness_on)
//			user.UpdateLuminosity()
			SetLuminosity(brightness_on)
		..()

	Dispose()
		if(ismob(src.loc))
			src.loc.SetLuminosity(-brightness_on)
		else
			SetLuminosity(0)
		. = ..()

/obj/item/clothing/suit/space/rig
	name = "hardsuit"
	desc = "A special space suit for environments that might pose hazards beyond just the vacuum of space. Provides more protection than a standard space suit."
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	slowdown = 1
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit)
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_max_heat_protection_temperature

	species_restricted = list("exclude","Unathi","Tajara","Vox")
	sprite_sheets_refit = list(
		"Unathi" = 'icons/mob/species/unathi/suit.dmi',
		"Tajara" = 'icons/mob/species/tajaran/suit.dmi',
		"Skrell" = 'icons/mob/species/skrell/suit.dmi',
		)
	sprite_sheets_obj = list(
		"Unathi" = 'icons/obj/clothing/species/unathi/suits.dmi',
		"Tajara" = 'icons/obj/clothing/species/tajaran/suits.dmi',
		"Skrell" = 'icons/obj/clothing/species/skrell/suits.dmi',
		)

	//Breach thresholds, should ideally be inherited by most (if not all) hardsuits.
	breach_threshold = 18
	can_breach = 1

	//Component/device holders.
	var/obj/item/stock_parts/gloves = null     // Basic capacitor allows insulation, upgrades allow shock gloves etc.

	var/attached_boots = 1                            // Can't wear boots if some are attached
	var/obj/item/clothing/shoes/magboots/boots = null // Deployable boots, if any.
	var/attached_helmet = 1                           // Can't wear a helmet if one is deployable.
	var/obj/item/clothing/head/helmet/helmet = null   // Deployable helmet, if any.

	var/list/max_mounted_devices = 0                  // Maximum devices. Easy.
	var/list/can_mount = null                         // Types of device that can be hardpoint mounted.
	var/list/mounted_devices = null                   // Holder for the above device.
	var/obj/item/active_device = null                 // Currently deployed device, if any.

/obj/item/clothing/suit/space/rig/equipped(mob/M)
	..()

	var/mob/living/carbon/human/H = M

	if(!istype(H)) return

	if(H.wear_suit != src)
		return

	if(attached_helmet && helmet)
		if(H.head)
			M << "You are unable to deploy your suit's helmet as \the [H.head] is in the way."
		else
			M << "Your suit's helmet deploys with a hiss."
			//TODO: Species check, skull damage for forcing an unfitting helmet on?
			helmet.loc = H
			H.equip_to_slot(helmet, WEAR_HEAD)
			helmet.flags_item |= NODROP

	if(attached_boots && boots)
		if(H.shoes)
			M << "You are unable to deploy your suit's magboots as \the [H.shoes] are in the way."
		else
			M << "Your suit's boots deploy with a hiss."
			boots.loc = H
			H.equip_to_slot(boots, WEAR_FEET)
			boots.flags_item |= NODROP

/obj/item/clothing/suit/space/rig/dropped()
	..()

	var/mob/living/carbon/human/H

	if(helmet)
		H = helmet.loc
		if(istype(H))
			if(helmet && H.head == helmet)
				helmet.flags_item &= ~NODROP
				H.drop_inv_item_to_loc(helmet, src)

	if(boots)
		H = boots.loc
		if(istype(H))
			if(boots && H.shoes == boots)
				boots.flags_item &= ~NODROP
				H.drop_inv_item_to_loc(boots, src)

/*
/obj/item/clothing/suit/space/rig/verb/get_mounted_device()

	set name = "Deploy Mounted Device"
	set category = "Object"
	set src in usr

	if(!can_mount)
		verbs -= /obj/item/clothing/suit/space/rig/verb/get_mounted_device
		verbs -= /obj/item/clothing/suit/space/rig/verb/stow_mounted_device
		return

	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	if(active_device)
		usr << "You already have \the [active_device] deployed."
		return

	if(!mounted_devices.len)
		usr << "You do not have any devices mounted on \the [src]."
		return

/obj/item/clothing/suit/space/rig/verb/stow_mounted_device()

	set name = "Stow Mounted Device"
	set category = "Object"
	set src in usr

	if(!can_mount)
		verbs -= /obj/item/clothing/suit/space/rig/verb/get_mounted_device
		verbs -= /obj/item/clothing/suit/space/rig/verb/stow_mounted_device
		return

	if(!istype(usr, /mob/living)) return

	if(usr.stat) return

	if(!active_device)
		usr << "You have no device currently deployed."
		return
*/

/obj/item/clothing/suit/space/rig/verb/toggle_helmet()

	set name = "Toggle Helmet"
	set category = "Object"
	set src in usr

	if(!istype(src.loc,/mob/living)) return

	if(!helmet)
		usr << "There is no helmet installed."
		return

	var/mob/living/carbon/human/H = usr

	if(!istype(H)) return
	if(H.stat) return
	if(H.wear_suit != src) return

	if(H.head == helmet)
		helmet.flags_item &= ~NODROP
		H.drop_inv_item_to_loc(helmet, src)
		H << "\blue You retract your hardsuit helmet."
	else
		if(H.head)
			H << "\red You cannot deploy your helmet while wearing another helmet."
			return
		//TODO: Species check, skull damage for forcing an unfitting helmet on?
		helmet.loc = H
		helmet.pickup(H)
		H.equip_to_slot(helmet, WEAR_HEAD)
		helmet.flags_item |= NODROP
		H << "\blue You deploy your hardsuit helmet, sealing you off from the world."

/obj/item/clothing/suit/space/rig/attackby(obj/item/W as obj, mob/user as mob)

	if(!istype(user,/mob/living)) return

	if(user.a_intent == "help")

		if(istype(src.loc,/mob/living))
			user << "How do you propose to modify a hardsuit while it is being worn?"
			return

		var/target_zone = user.zone_selected

		if(target_zone == "head")

			//Installing a component into or modifying the contents of the helmet.
			if(!attached_helmet)
				user << "\The [src] does not have a helmet mount."
				return

			if(istype(W,/obj/item/tool/screwdriver))
				if(!helmet)
					user << "\The [src] does not have a helmet installed."
				else
					user << "You detatch \the [helmet] from \the [src]'s helmet mount."
					helmet.loc = get_turf(src)
					src.helmet = null
				return
			else if(istype(W,/obj/item/clothing/head/helmet/space))
				if(helmet)
					user << "\The [src] already has a helmet installed."
				else
					user << "You attach \the [W] to \the [src]'s helmet mount."
					user.drop_held_item()
					W.loc = src
					src.helmet = W
				return
			else
				return ..()

		else if(target_zone == "l_leg" || target_zone == "r_leg" || target_zone == "l_foot" || target_zone == "r_foot")

			//Installing a component into or modifying the contents of the feet.
			if(!attached_boots)
				user << "\The [src] does not have boot mounts."
				return

			if(istype(W,/obj/item/tool/screwdriver))
				if(!boots)
					user << "\The [src] does not have any boots installed."
				else
					user << "You detatch \the [boots] from \the [src]'s boot mounts."
					boots.loc = get_turf(src)
					boots = null
				return
			else if(istype(W,/obj/item/clothing/shoes/magboots))
				if(boots)
					user << "\The [src] already has magboots installed."
				else
					user << "You attach \the [W] to \the [src]'s boot mounts."
					user.drop_held_item()
					W.loc = src
					boots = W
			else
				return ..()

		/*
		else if(target_zone == "l_arm" || target_zone == "r_arm" || target_zone == "l_hand" || target_zone == "r_hand")

			//Installing a component into or modifying the contents of the hands.

		else if(target_zone == "torso" || target_zone == "groin")

			//Modifying the cell or mounted devices

			if(!mounted_devices)
				return
		*/

		else //wat
			return ..()

	..()

//Engineering rig
/obj/item/clothing/head/helmet/space/rig/engineering
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)

/obj/item/clothing/suit/space/rig/engineering
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	slowdown = 1
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/tool/pickaxe, /obj/item/device/rcd)

//Chief Engineer's rig
/obj/item/clothing/head/helmet/space/rig/engineering/chief
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "rig0-white"
	item_state = "ce_helm"
	rig_color = "white"
	sprite_sheets_refit = null
	sprite_sheets_obj = null

/obj/item/clothing/suit/space/rig/engineering/chief
	icon_state = "rig-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	sprite_sheets_refit = null
	sprite_sheets_obj = null

//Mining rig
/obj/item/clothing/head/helmet/space/rig/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "rig0-mining"
	item_state = "mining_helm"
	rig_color = "mining"
	armor = list(melee = 50, bullet = 5, laser = 20,energy = 5, bomb = 55, bio = 100, rad = 20)

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	item_state = "mining_hardsuit"
	armor = list(melee = 50, bullet = 5, laser = 20,energy = 5, bomb = 55, bio = 100, rad = 20)


//Syndicate rig
/obj/item/clothing/head/helmet/space/rig/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced helmet designed for work in special operations. Property of Gorlex Marauders."
	icon_state = "rig0-syndie"
	item_state = "syndie_helm"
	rig_color = "syndie"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.6
	var/obj/machinery/camera/camera
	species_restricted = list("exclude","Unathi","Tajara","Skrell","Vox")


/obj/item/clothing/head/helmet/space/rig/syndi/attack_self(mob/user)
	if(camera)
		..(user)
	else
		camera = new /obj/machinery/camera(src)
		camera.network = list("NUKE")
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
		user << "\blue User scanned as [camera.c_tag]. Camera activated."

/obj/item/clothing/head/helmet/space/rig/syndi/examine(mob/user)
	..()
	if(get_dist(user,src) <= 1)
		user << "This helmet has a built-in camera. It's [camera ? "" : "in"]active."

/obj/item/clothing/suit/space/rig/syndi
	icon_state = "rig-syndie"
	name = "blood-red hardsuit"
	desc = "An advanced suit that protects against injuries during special operations. Property of Gorlex Marauders."
	item_state = "syndie_hardsuit"
	slowdown = 1
	w_class = 3
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/baton,/obj/item/weapon/energy/sword,/obj/item/handcuffs)
	siemens_coefficient = 0.6
	species_restricted = list("exclude","Unathi","Tajara","Skrell","Vox")


//Wizard Rig
/obj/item/clothing/head/helmet/space/rig/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "rig0-wiz"
	item_state = "wiz_helm"
	rig_color = "wiz"
	unacidable = 1 //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(melee = 40, bullet = 20, laser = 20,energy = 20, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7
	sprite_sheets_refit = null
	sprite_sheets_obj = null

/obj/item/clothing/suit/space/rig/wizard
	icon_state = "rig-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	item_state = "wiz_hardsuit"
	slowdown = 1
	w_class = 3
	unacidable = 1
	armor = list(melee = 40, bullet = 20, laser = 20,energy = 20, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7
	sprite_sheets_refit = null
	sprite_sheets_obj = null

//Medical Rig
/obj/item/clothing/head/helmet/space/rig/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has minor radiation shielding."
	icon_state = "rig0-medical"
	item_state = "medical_helm"
	rig_color = "medical"
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 5, bomb = 25, bio = 100, rad = 50)

/obj/item/clothing/suit/space/rig/medical
	icon_state = "rig-medical"
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has minor radiation shielding."
	item_state = "medical_hardsuit"
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 5, bomb = 25, bio = 100, rad = 50)

	//Security
/obj/item/clothing/head/helmet/space/rig/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "rig0-sec"
	item_state = "sec_helm"
	rig_color = "sec"
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/space/rig/security
	icon_state = "rig-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	item_state = "sec_hardsuit"
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/baton)
	siemens_coefficient = 0.7


//Atmospherics Rig (BS12)
/obj/item/clothing/head/helmet/space/rig/atmos
	desc = "A special helmet designed for work in a hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	name = "atmospherics hardsuit helmet"
	icon_state = "rig0-atmos"
	item_state = "atmos_helm"
	rig_color = "atmos"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRE_HELMET_max_heat_protection_temperature

/obj/item/clothing/suit/space/rig/atmos
	desc = "A special suit that protects against hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	icon_state = "rig-atmos"
	name = "atmos hardsuit"
	item_state = "atmos_hardsuit"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRESUIT_max_heat_protection_temperature

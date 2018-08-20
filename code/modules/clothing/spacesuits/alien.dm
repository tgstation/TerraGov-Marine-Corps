//Skrell space gear. Sleek like a wetsuit.
/obj/item/clothing/head/helmet/space/skrell
	name = "Skrellian helmet"
	desc = "Smoothly contoured and polished to a shine. Still looks like a fishbowl."
	armor = list(melee = 20, bullet = 20, laser = 50,energy = 50, bomb = 50, bio = 100, rad = 100)
	max_heat_protection_temperature = SPACE_SUIT_max_heat_protection_temperature
	species_restricted = list("Skrell","Human")

/obj/item/clothing/head/helmet/space/skrell/white
	icon_state = "skrell_helmet_white"

/obj/item/clothing/head/helmet/space/skrell/black
	icon_state = "skrell_helmet_black"

/obj/item/clothing/suit/space/skrell
	name = "Skrellian hardsuit"
	desc = "Seems like a wetsuit with reinforced plating seamlessly attached to it. Very chic."
	armor = list(melee = 20, bullet = 20, laser = 50,energy = 50, bomb = 50, bio = 100, rad = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/tool/pickaxe, /obj/item/device/rcd)
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_max_heat_protection_temperature
	species_restricted = list("Skrell","Human")

/obj/item/clothing/suit/space/skrell/white
	icon_state = "skrell_suit_white"

/obj/item/clothing/suit/space/skrell/black
	icon_state = "skrell_suit_black"

//Unathi space gear. Huge and restrictive.
/obj/item/clothing/head/helmet/space/unathi
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 50)
	flags_heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_max_heat_protection_temperature
	var/up = 0 //So Unathi helmets play nicely with the weldervision check.
	species_restricted = list("Unathi")

/obj/item/clothing/head/helmet/space/unathi/helmet_cheap
	name = "NT breacher helmet"
	desc = "Hey! Watch it with that thing! It's a knock-off of a Unathi battle-helm, and that spike could put someone's eye out."
	icon_state = "unathi_helm_cheap"

/obj/item/clothing/suit/space/unathi
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/tool/pickaxe, /obj/item/device/rcd)
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_max_heat_protection_temperature
	species_restricted = list("Unathi")

/obj/item/clothing/suit/space/unathi/rig_cheap
	name = "NT breacher chassis"
	desc = "A cheap NT knock-off of a Unathi battle-rig. Looks like a fish, moves like a fish, steers like a cow."
	icon_state = "rig-unathi-cheap"
	item_state = "rig-unathi-cheap"
	slowdown = 3

/obj/item/clothing/head/helmet/space/unathi/breacher
	name = "breacher helm"
	desc = "Weathered, ancient and battle-scarred. The helmet is too."
	icon_state = "unathi_breacher"

/obj/item/clothing/suit/space/unathi/breacher
	name = "breacher chassis"
	desc = "Huge, bulky and absurdly heavy. It must be like wearing a tank."
	icon_state = "unathi_breacher"
	slowdown = 1

// Vox space gear (vaccuum suit, low pressure armour)
// Can't be equipped by any other species due to bone structure and vox cybernetics.
/obj/item/clothing/suit/space/vox
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/baton,/obj/item/weapon/energy/sword,/obj/item/handcuffs,/obj/item/tank)
	slowdown = 2
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0.6
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_max_heat_protection_temperature
	species_restricted = list("Vox", "Vox Armalis")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Vox Armalis" = 'icons/mob/species/armalis/suit.dmi',
		)

/obj/item/clothing/head/helmet/space/vox
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0.6
	flags_inventory = COVEREYES|NOPRESSUREDMAGE
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	species_restricted = list("Vox","Vox Armalis")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi',
		"Vox Armalis" = 'icons/mob/species/armalis/head.dmi',
		)

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	icon_state = "vox-pressure"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	icon_state = "vox-pressure"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	icon_state = "vox-carapace"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armour"
	icon_state = "vox-carapace"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."

/obj/item/clothing/head/helmet/space/vox/stealth
	name = "alien stealth helmet"
	icon_state = "vox-stealth"
	desc = "A smoothly contoured, matte-black alien helmet."

/obj/item/clothing/suit/space/vox/stealth
	name = "alien stealth suit"
	icon_state = "vox-stealth"
	desc = "A sleek black suit. It seems to have a tail, and is very heavy."

/obj/item/clothing/head/helmet/space/vox/medic
	name = "alien goggled helmet"
	icon_state = "vox-medic"
	desc = "An alien helmet with enormous goggled lenses."

/obj/item/clothing/suit/space/vox/medic
	name = "alien armour"
	icon_state = "vox-medic"
	desc = "An almost organic looking nonhuman pressure suit."

/obj/item/clothing/under/vox
	has_sensor = 0
	species_restricted = list("Vox")

/obj/item/clothing/under/vox/vox_casual
	name = "alien clothing"
	desc = "This doesn't look very comfortable."
	icon_state = "vox-casual-1"
	flags_armor_protection = LEGS

/obj/item/clothing/under/vox/vox_robes
	name = "alien robes"
	desc = "Weird and flowing!"
	icon_state = "vox-casual-2"

/obj/item/clothing/gloves/yellow/vox
	desc = "These bizarre gauntlets seem to be fitted for... bird claws?"
	name = "insulated gauntlets"
	icon_state = "gloves-vox"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	species_restricted = list("Vox","Vox Armalis")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/gloves.dmi',
		"Vox Armalis" = 'icons/mob/species/armalis/gloves.dmi',
		)
/obj/item/clothing/shoes/magboots/vox

	desc = "A pair of heavy, jagged armoured foot pieces, seemingly suitable for a velociraptor."
	name = "vox magclaws"
	item_state = "boots-vox"
	icon_state = "boots-vox"

	species_restricted = list("Vox","Vox Armalis")
	sprite_sheets = list(
		"Vox Armalis" = 'icons/mob/species/armalis/feet.dmi'
		)


/obj/item/clothing/shoes/magboots/vox/attack_self(mob/user)
	if(src.magpulse)
		flags_inventory &= ~NOSLIPPING
		flags_item &= ~NODROP
		magpulse = 0
		to_chat(user, "You relax your deathgrip on the flooring.")
	else
		//make sure these can only be used when equipped.
		if(!ishuman(user))
			return
		var/mob/living/carbon/human/H = user
		if (H.shoes != src)
			to_chat(user, "You will have to put on the [src] before you can do that.")
			return

		flags_inventory |= NOSLIPPING
		flags_item |= NODROP //kinda hard to take off magclaws when you are gripping them tightly.
		magpulse = 1
		to_chat(user, "You dig your claws deeply into the flooring, bracing yourself.")
		to_chat(user, "It would be hard to take off the [src] without relaxing your grip first.")

//In case they somehow come off while enabled.
/obj/item/clothing/shoes/magboots/vox/dropped(mob/user as mob)
	..()
	if(src.magpulse)
		user.visible_message("The [src] go limp as they are removed from [usr]'s feet.", "The [src] go limp as they are removed from your feet.")
		flags_inventory &= ~NOSLIPPING
		flags_item &= ~NODROP
		magpulse = 0

/obj/item/clothing/shoes/magboots/vox/examine(mob/user)
	..()
	if (magpulse)
		to_chat(user, "It would be hard to take these off without relaxing your grip first.")
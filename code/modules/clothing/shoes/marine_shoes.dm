

/obj/item/clothing/shoes/marine
	name = "marine combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "marine"
	item_state = "marine"
	flags_armor_protection = FEET
	soft_armor = list("melee" = 15, "bullet" = 20, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 25)
	flags_cold_protection = FEET
	flags_heat_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7
	var/obj/item/storage/internal/pockets = /obj/item/storage/internal/shoes/boot_knife

/obj/item/storage/internal/shoes/boot_knife
	max_storage_space = 3
	storage_slots = 1
	draw_mode = TRUE
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/weapon/gun/pistol/standard_pocketpistol,
		/obj/item/attachable/bayonetknife,
		/obj/item/weapon/throwing_knife
	)

/obj/item/clothing/shoes/marine/Initialize()
	. = ..()
	pockets = new pockets(src)

/obj/item/clothing/shoes/marine/attack_hand(mob/living/user)
	if(pockets.handle_attack_hand(user))
		return ..()


/obj/item/clothing/shoes/marine/MouseDrop(over_object, src_location, over_location)
	if(!pockets)
		return ..()
	if(pockets.handle_mousedrop(usr, over_object))
		return ..()


/obj/item/clothing/shoes/marine/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(!pockets)
		return

	return pockets.attackby(I, user, params)


/obj/item/clothing/shoes/marine/emp_act(severity)
	pockets?.emp_act(severity)
	return ..()

/obj/item/clothing/shoes/marine/update_icon()
	if(length(pockets.contents))
		icon_state = "[initial(icon_state)]-knife"
	else
		icon_state = initial(icon_state)


/obj/item/clothing/shoes/marine/pyro
	name = "flame-resistant combat boots"
	desc = "Protects you from fire and even contains a pouch for your knife!"
	icon_state = "marine_armored"
	hard_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 0)


/obj/item/clothing/shoes/marinechief
	name = "chief officer shoes"
	desc = "Only a small amount of monkeys, kittens, and orphans were killed in making this."
	icon_state = "laceups"
	soft_armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 25)
	flags_inventory = NOSLIPPING
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/marinechief/captain
	name = "captain's shoes"
	desc = "Has special soles for better trampling those underneath."

/obj/item/clothing/shoes/marinechief/sa
	name = "spatial agent's shoes"
	desc = "Shoes worn by a spatial agent."

/obj/item/clothing/shoes/veteran

/obj/item/clothing/shoes/veteran/PMC
	name = "polished shoes"
	desc = "The height of fashion, but these look to be woven with protective fiber."
	icon_state = "jackboots"
	item_state = "jackboots"
	flags_armor_protection = FEET
	soft_armor = list("melee" = 15, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 15)
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	flags_cold_protection = FEET
	flags_heat_protection = FEET
	flags_inventory = NOSLIPPING
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/veteran/PMC/commando
	name = "\improper PMC commando boots"
	desc = "A pair of heavily armored, acid-resistant boots."
	icon_state = "commando_boots"
	permeability_coefficient = 0.01
	flags_armor_protection = FEET
	soft_armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 25)
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	flags_cold_protection = FEET
	flags_heat_protection = FEET
	siemens_coefficient = 0.2
	resistance_flags = UNACIDABLE

//=========//Imperium\\=========\\

/obj/item/clothing/shoes/marine/imperial
	name = "guardsmen combat boots"
	desc = "A pair of boots issued to the Imperial Guard, just like anything else they use, they are mass produced."
	//icon_state = ""
	soft_armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 25)


/obj/item/clothing/shoes/marine/som
	name = "\improper S11 combat shoes"
	desc = "Shoes with origins dating back to the old mining colonies."
	icon_state = "som"
	item_state = "som"
	soft_armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 25)


/obj/item/clothing/shoes/sectoid
	name = "psionic field"
	desc = "A field of invisible energy, it protects the wearer but prevents any clothing from being worn."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-blue"
	flags_item = NODROP|DELONDROP
	soft_armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 25)
	flags_inventory = NOSLIPPING

/obj/item/clothing/shoes/marine/unscmarine
	name = "UNSC marine combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations."
	soft_armor = list("melee" = 50, "bullet" = 55, "laser" = 55, "energy" = 55, "bomb" = 55, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 25)
	icon_state = "unsc_marine"
	item_state = "unsc_marine"

/obj/item/clothing/shoes/marine/urf
	name = "combat boots (brown)"
	desc = "A pair of combat boots that provides minor protection. May protect against toe stubs."
	soft_armor = list("melee" = 50, "bullet" = 55, "laser" = 55, "energy" = 55, "bomb" = 55, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 25)
	icon_state = "urf_brown"
	item_state = "urf_brown"

/obj/item/clothing/shoes/marine/urf/black
	name = "combat boots (black)"
	desc = "A pair of combat boots that provides minor protection. May protect against toe stubs."
	soft_armor = list("melee" = 50, "bullet" = 55, "laser" = 55, "energy" = 55, "bomb" = 55, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 25)
	icon_state = "urf_black"
	item_state = "urf_black"

/obj/item/clothing/shoes/marine/urf/green
	name = "combat boots (green)"
	desc = "A pair of combat boots that provides minor protection. May protect against toe stubs."
	soft_armor = list("melee" = 50, "bullet" = 55, "laser" = 55, "energy" = 55, "bomb" = 55, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 25)
	icon_state = "urf_green"
	item_state = "urf_green"

/obj/item/clothing/shoes/marine/urf/white
	name = "combat boots (white)"
	desc = "A pair of combat boots that provides minor protection. May protect against toe stubs."
	soft_armor = list("melee" = 50, "bullet" = 55, "laser" = 55, "energy" = 55, "bomb" = 55, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 25)
	icon_state = "urf_white"
	item_state = "urf_white"

/obj/item/clothing/shoes/marine/urf/blue
	name = "combat boots (blue)"
	desc = "A pair of combat boots that provides minor protection. May protect against toe stubs.."
	soft_armor = list("melee" = 53, "bullet" = 58, "laser" = 58, "energy" = 58, "bomb" = 60, "bio" = 10, "rad" = 0, "fire" = 15, "acid" = 25)
	icon_state = "urf_blue"
	item_state = "urf_blue"

/obj/item/clothing/shoes/marine/urf/blue/traditional
	name = "traditonal combat boots"
	desc = "A pair of traditional combat boots that provides minor protection. May protect against toe stubs."
	icon_state = "innie_warlord"
	item_state = "innie_warlord"

//gcpd

/obj/item/clothing/shoes/marine/gcpd
	name = "Colonial Police patrol boots"
	desc = "A pair of Colonial Police patrol boots, they don't look like they offer much protection."
	icon_state = "gcpd_boots"
	item_state = "gcpd_boots"
	soft_armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 25)



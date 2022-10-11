

/obj/item/clothing/shoes/marine
	name = "marine combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "marine"
	item_state = "marine"
	flags_armor_protection = FEET
	soft_armor = list(MELEE = 25, BULLET = 15, LASER = 5, ENERGY = 5, BOMB = 5, BIO = 5, "rad" = 0, FIRE = 5, ACID = 20)
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
		/obj/item/weapon/gun/shotgun/double/derringer,
		/obj/item/attachable/bayonetknife,
		/obj/item/stack/throwing_knife,
		/obj/item/storage/box/MRE,
	)

/obj/item/clothing/shoes/marine/Initialize()
	. = ..()
	pockets = new pockets(src)
	RegisterSignal(pockets, COMSIG_ATOM_UPDATE_ICON, /atom/proc/update_icon)
	update_icon()

/obj/item/clothing/shoes/marine/Destroy()
	QDEL_NULL(pockets)
	return ..()


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

/obj/item/clothing/shoes/marine/update_icon_state()
	icon_state = initial(icon_state)
	for(var/atom/item_in_pocket AS in pockets.contents)
		if(istype(item_in_pocket, /obj/item/weapon/combat_knife) || istype(item_in_pocket, /obj/item/attachable/bayonetknife) || istype(item_in_pocket, /obj/item/stack/throwing_knife))
			icon_state += "-knife"

/obj/item/clothing/shoes/marine/full
	pockets = /obj/item/storage/internal/shoes/boot_knife/full

/obj/item/storage/internal/shoes/boot_knife/full/Initialize()
	. = ..()
	new /obj/item/attachable/bayonetknife(src)

/obj/item/clothing/shoes/marine/pyro
	name = "flame-resistant combat boots"
	desc = "Protects you from fire and even contains a pouch for your knife!"
	icon_state = "marine_armored"
	hard_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, "rad" = 0, FIRE = 100, ACID = 0)


/obj/item/clothing/shoes/marinechief
	name = "chief officer shoes"
	desc = "Only a small amount of monkeys, kittens, and orphans were killed in making this."
	icon_state = "laceups"
	soft_armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 20, "rad" = 20, FIRE = 20, ACID = 25)
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
	soft_armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 20, "rad" = 20, FIRE = 20, ACID = 15)
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
	soft_armor = list(MELEE = 40, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 20, "rad" = 20, FIRE = 20, ACID = 25)
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	flags_cold_protection = FEET
	flags_heat_protection = FEET
	siemens_coefficient = 0.2
	resistance_flags = UNACIDABLE

/*=========Imperium=========*/

/obj/item/clothing/shoes/marine/imperial
	name = "guardsmen combat boots"
	desc = "A pair of boots issued to the Imperial Guard, just like anything else they use, they are mass produced."
	//icon_state = ""
	soft_armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 20, "rad" = 20, FIRE = 20, ACID = 25)


/obj/item/clothing/shoes/marine/som
	name = "\improper S11 combat shoes"
	desc = "Shoes with origins dating back to the old mining colonies. These were made for more than just walking."
	icon_state = "som"
	item_state = "som"

/obj/item/clothing/shoes/marine/som/knife
	pockets = /obj/item/storage/internal/shoes/boot_knife/full

/obj/item/clothing/shoes/sectoid
	name = "psionic field"
	desc = "A field of invisible energy, it protects the wearer but prevents any clothing from being worn."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-blue"
	flags_item = NODROP|DELONDROP
	soft_armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 20, "rad" = 20, FIRE = 20, ACID = 25)
	flags_inventory = NOSLIPPING

/obj/item/clothing/shoes/cowboy
	name = "sturdy western boots"
	desc = "As sturdy as they are old fashioned these will keep your ankles from snake bites on any planet. These cannot store anything, but has extra fashion with those unneeded spurs on their heels."
	icon_state = "cboots"
	item_state = "cboots"

/obj/item/clothing/shoes/marine/clf
	name = "\improper frontier boots"
	desc = "A pair of well worn boots, commonly seen on most outer colonies."
	icon_state = "boots"
	item_state = "boots"

/obj/item/clothing/shoes/marine/clf/full
	pockets = /obj/item/storage/internal/shoes/boot_knife/full

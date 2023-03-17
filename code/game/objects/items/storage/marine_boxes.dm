/obj/item/storage/box/heavy_armor
	name = "\improper B-Series defensive armor crate"
	desc = "A large case containing an experiemental suit of B18 armor for the discerning specialist."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 3
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/heavy_armor/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/suit/storage/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/specialist(src)

/obj/item/storage/box/grenade_system
	name = "\improper M92 grenade launcher case"
	desc = "A large case containing a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 2
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/grenade_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/grenade_launcher/multinade_launcher(src)
	new /obj/item/storage/belt/grenade/b17(src)

/obj/item/storage/box/rocket_system
	name = "\improper M5 RPG crate"
	desc = "A large case containing a heavy-caliber antitank missile launcher and missiles. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/rocket_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/launcher/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar/ap(src)
	new /obj/item/ammo_magazine/rocket/sadar/ap(src)
	new /obj/item/ammo_magazine/rocket/sadar/wp(src)

/obj/item/storage/box/heavy_grenadier
	name = "\improper Heavy Grenadier case"
	desc = "A large case containing B17 Heavy Armor and a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/spec/heavy_grenadier/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/grenade_launcher/multinade_launcher(src)
	new /obj/item/storage/belt/grenade/b17(src)
	new /obj/item/clothing/suit/storage/marine/B17(src)
	new /obj/item/clothing/head/helmet/marine/grenadier(src)
	new /obj/item/storage/box/visual/grenade/frag(src)
	new /obj/item/storage/box/visual/grenade/frag(src)
	new /obj/item/storage/box/visual/grenade/incendiary(src)

/obj/item/storage/box/heavy_gunner
	name = "\improper Heavy Minigunner case"
	desc = "A large case containing B18 armor, munitions, and a goddamn minigun. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 16
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/heavy_gunner/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/suit/storage/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/specialist(src)
	new /obj/item/weapon/gun/minigun(src)
	new /obj/item/belt_harness/marine(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)

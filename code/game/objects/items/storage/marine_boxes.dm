/obj/item/storage/box/crate
	name = "crate"
	desc = "It's just an ordinary wooden crate."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "case"
	foldable = /obj/item/stack/sheet/wood

/obj/item/storage/box/crate/update_icon_state()
	icon_state = length(contents) ? initial(icon_state) : "empty_case"

/obj/item/storage/box/crate/heavy_armor
	name = "\improper B-Series defensive armor crate"
	desc = "A large case containing an experiemental suit of B18 armor for the discerning specialist."
	icon_state = "armor_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 3
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

/obj/item/storage/box/crate/heavy_armor/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/suit/storage/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/specialist(src)

/obj/item/storage/box/crate/grenade_system
	name = "\improper M92 grenade launcher case"
	desc = "A large case containing a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "grenade_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 2
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

/obj/item/storage/box/crate/grenade_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/grenade_launcher/multinade_launcher(src)
	new /obj/item/storage/belt/grenade/b17(src)

/obj/item/storage/box/crate/rocket_system
	name = "\improper M5 RPG crate"
	desc = "A large case containing a heavy-caliber antitank missile launcher and missiles. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "rocket_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

/obj/item/storage/box/crate/rocket_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/launcher/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar/ap(src)
	new /obj/item/ammo_magazine/rocket/sadar/ap(src)
	new /obj/item/ammo_magazine/rocket/sadar/wp(src)

/obj/item/storage/box/crate/heavy_grenadier
	name = "\improper Heavy Grenadier case"
	desc = "A large case containing B17 Heavy Armor and a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "grenade_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

/obj/item/storage/box/crate/heavy_grenadier/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/grenade_launcher/multinade_launcher(src)
	new /obj/item/storage/belt/grenade/b17(src)
	new /obj/item/clothing/suit/storage/marine/B17(src)
	new /obj/item/clothing/head/helmet/marine/grenadier(src)
	new /obj/item/storage/box/visual/grenade/frag(src)
	new /obj/item/storage/box/visual/grenade/frag(src)
	new /obj/item/storage/box/visual/grenade/incendiary(src)

/obj/item/storage/box/crate/heavy_gunner
	name = "\improper Heavy Minigunner case"
	desc = "A large case containing B18 armor, munitions, and a goddamn minigun. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "rocket_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 16
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

/obj/item/storage/box/crate/heavy_gunner/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/suit/storage/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/specialist(src)
	new /obj/item/weapon/gun/minigun(src)
	new /obj/item/belt_harness/marine(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)

/obj/item/storage/box/crate/m42c_system
	name = "\improper antimaterial scoped rifle system (recon set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "sniper_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 12
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

/obj/item/storage/box/crate/m42c_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/modular/xenonauten/light(src)
	new /obj/item/clothing/head/modular/m10x(src)
	new /obj/item/clothing/glasses/night/m42_night_goggles(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/ammo_magazine/sniper/flak(src)
	new /obj/item/binoculars/tactical(src)
	new /obj/item/storage/backpack/marine/smock(src)
	new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/weapon/gun/rifle/sniper/antimaterial(src)
	new /obj/item/bodybag/tarp(src)

/obj/item/storage/box/crate/m42c_system_Jungle
	name = "\improper antimaterial scoped rifle system (marksman set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "sniper_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 9
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

/obj/item/storage/box/crate/m42c_system_Jungle/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/modular/xenonauten/light(src)
	new /obj/item/clothing/head/modular/m10x(src)
	new /obj/item/clothing/glasses/m42_goggles(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/weapon/gun/rifle/sniper/antimaterial(src)
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new /obj/item/clothing/under/marine/camo/snow(src)
		new /obj/item/storage/backpack/marine/satchel(src)
		new /obj/item/bodybag/tarp/snow(src)
	else
		new /obj/item/facepaint/sniper(src)
		new /obj/item/storage/backpack/marine/smock(src)
		new /obj/item/bodybag/tarp(src)

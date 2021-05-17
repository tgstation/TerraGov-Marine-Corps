

/obj/item/storage/large_holster
	name = "\improper Rifle Holster"
	desc = "holster"
	icon = 'icons/obj/items/storage/storage.dmi'
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	max_w_class = 4
	storage_slots = 1
	max_storage_space = 4
	draw_mode = 1
	var/base_icon = "m37_holster"
	var/drawSound = 'sound/weapons/guns/misc/rifle_draw.ogg'


/obj/item/storage/large_holster/update_icon()
	var/mob/user = loc
	icon_state = "[base_icon][contents.len?"_full":""]"
	item_state = icon_state
	if(istype(user)) user.update_inv_back()
	if(istype(user)) user.update_inv_s_store()


/obj/item/storage/large_holster/equipped(mob/user, slot)
	if(slot == SLOT_BACK || slot == SLOT_BELT || slot == SLOT_S_STORE)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
	..()

/obj/item/storage/large_holster/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()

/obj/item/storage/large_holster/handle_item_insertion(obj/item/W, prevent_warning = 0)
	. = ..()
	if(. && drawSound)
		playsound(src,drawSound, 15, 1)
	return 1

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/storage/large_holster/remove_from_storage(obj/item/W, atom/new_location)
	. = ..()
	if(. && drawSound)
		playsound(src,drawSound, 15, 1)

/obj/item/storage/large_holster/m37
	name = "\improper L44 shotgun scabbard"
	desc = "A large leather holster allowing the storage of any shotgun. It contains harnesses that allow it to be secured to the back for easy storage."
	icon_state = "m37_holster"
	can_hold = list(
		/obj/item/weapon/gun/shotgun/combat,
		/obj/item/weapon/gun/shotgun/pump,
	)

/obj/item/storage/large_holster/m37/full/Initialize()
	. = ..()
	icon_state = "m37_holster_full"
	new /obj/item/weapon/gun/shotgun/pump(src)
	base_icon = icon_state

/obj/item/storage/large_holster/machete
	name = "\improper H5 pattern M2132 machete scabbard"
	desc = "A large leather scabbard used to carry a M2132 machete. It can be strapped to the back, waist or armor."
	base_icon = "machete_holster"
	icon_state = "machete_holster"
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	can_hold = list(/obj/item/weapon/claymore/mercsword/machete, /obj/item/weapon/claymore/harvester)

/obj/item/storage/large_holster/machete/full/Initialize()
	. = ..()
	icon_state = "machete_holster_full"
	new /obj/item/weapon/claymore/mercsword/machete(src)

/obj/item/storage/large_holster/machete/full_harvester
	name = "H5 Pattern M2132 harvester scabbard"

/obj/item/storage/large_holster/machete/full_harvester/Initialize()
	. = ..()
	icon_state = "machete_holster_full"
	new /obj/item/weapon/claymore/harvester(src)

/obj/item/storage/large_holster/katana
	name = "\improper katana scabbard"
	desc = "A large, vibrantly colored katana scabbard used to carry a japanese sword. It can be strapped to the back, waist or armor. Because of the sturdy wood casing of the scabbard, it makes an okay defensive weapon in a pinch."
	base_icon = "katana_holster"
	icon_state = "katana_holster"
	force = 12
	attack_verb = list("bludgeoned", "struck", "cracked")
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	can_hold = list(/obj/item/weapon/katana)

/obj/item/storage/large_holster/katana/full/Initialize()
	. = ..()
	icon_state = "katana_holster_full"
	new /obj/item/weapon/katana(src)

/obj/item/storage/large_holster/officer
	name = "\improper officer sword scabbard"
	desc = "A large leather scabbard used to carry a sword. Appears to be a reproduction, rather than original. It can be strapped to the waist or armor."
	base_icon = "officer_sheath"
	icon_state = "officer_sheath"
	flags_equip_slot = ITEM_SLOT_BELT
	can_hold = list(/obj/item/weapon/claymore/mercsword/officersword)

/obj/item/storage/large_holster/officer/full/Initialize()
	. = ..()
	icon_state = "officer_sheath_full"
	new /obj/item/weapon/claymore/mercsword/officersword(src)

/obj/item/storage/large_holster/t35
	name = "\improper L44 T-35 scabbard"
	desc = "A large leather holster allowing the storage of an T-35 Shotgun. It contains harnesses that allow it to be secured to the back for easy storage."
	icon_state = "t35_holster"
	can_hold = list(
		/obj/item/weapon/gun/shotgun/pump/t35,
	)

/obj/item/storage/large_holster/t35/full/Initialize()
	. = ..()
	icon_state = "t35_holster_full"
	new /obj/item/weapon/gun/shotgun/pump/t35(src)
	base_icon = icon_state

/obj/item/storage/large_holster/m25
	name = "\improper M276 pattern M25 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is designed for the M25 SMG, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	icon_state = "m25_holster"
	icon = 'icons/obj/clothing/belts.dmi'
	base_icon = "m25_holster"
	flags_equip_slot = ITEM_SLOT_BELT
	can_hold = list(/obj/item/weapon/gun/smg/m25)

/obj/item/storage/large_holster/m25/update_icon_state()
	if(contents.len)
		var/obj/I = contents[1]
		icon_state = "[base_icon]_full_[I.icon_state]"
		item_state = "[base_icon]_full"
	else
		icon_state = base_icon
		item_state = base_icon
	if(ismob(loc))
		var/mob/user = loc
		user.update_inv_belt()

/obj/item/storage/large_holster/m25/full/Initialize()
	. = ..()
	new /obj/item/weapon/gun/smg/m25(src)
	update_icon()

/obj/item/storage/large_holster/t19
	name = "\improper M276 pattern T-19 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is designed for the T-19 SMG, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	icon_state = "t19_holster"
	icon = 'icons/obj/clothing/belts.dmi'
	base_icon = "t19_holster"
	flags_equip_slot = ITEM_SLOT_BELT
	can_hold = list(/obj/item/weapon/gun/smg/standard_smg)

/obj/item/storage/large_holster/t19/update_icon()
	var/mob/user = loc
	if(contents.len)
		var/obj/I = contents[1]
		icon_state = "[base_icon]_full_[I.icon_state]"
		item_state = "[base_icon]_full"
	else
		icon_state = base_icon
		item_state = base_icon
	if(istype(user)) user.update_inv_belt()

/obj/item/storage/large_holster/t19/full/Initialize()
	. = ..()
	new /obj/item/weapon/gun/smg/standard_smg(src)
	update_icon()

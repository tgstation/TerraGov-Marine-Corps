

/obj/item/storage/large_holster
	name = "\improper Rifle Holster"
	desc = "holster"
	icon = 'icons/obj/items/storage/storage.dmi'
	w_class = 4
	flags_equip_slot = SLOT_BACK
	max_w_class = 4
	storage_slots = 1
	max_storage_space = 4
	draw_mode = 1
	var/base_icon = "m37_holster"
	var/drawSound = 'sound/weapons/gun_rifle_draw.ogg'


/obj/item/storage/large_holster/update_icon()
	var/mob/user = loc
	icon_state = "[base_icon][contents.len?"_full":""]"
	item_state = icon_state
	if(istype(user)) user.update_inv_back()
	if(istype(user)) user.update_inv_s_store()


/obj/item/storage/large_holster/equipped(mob/user, slot)
	if(slot == WEAR_BACK || slot == WEAR_WAIST || slot == WEAR_J_STORE)
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
	name = "\improper L44 M37A2 scabbard"
	desc = "A large leather holster allowing the storage of an M37A2 Shotgun. It contains harnesses that allow it to be secured to the back for easy storage."
	icon_state = "m37_holster"
	can_hold = list(
		"/obj/item/weapon/gun/shotgun/pump",
		"/obj/item/weapon/gun/shotgun/combat"
		)

/obj/item/storage/large_holster/m37/New()
	select_gamemode_skin(/obj/item/storage/large_holster/m37)
	base_icon = icon_state
	..()


/obj/item/storage/large_holster/m37/full/New()
	..()
	icon_state = "m37_holster_full"
	new /obj/item/weapon/gun/shotgun/pump(src)

/obj/item/storage/large_holster/machete
	name = "\improper H5 pattern M2132 machete scabbard"
	desc = "A large leather scabbard used to carry a M2132 machete. It can be strapped to the back or the armor."
	base_icon = "machete_holster"
	icon_state = "machete_holster"
	can_hold = list("/obj/item/weapon/claymore/mercsword/machete")

/obj/item/storage/large_holster/machete/full/New()
	..()
	icon_state = "machete_holster_full"
	new /obj/item/weapon/claymore/mercsword/machete(src)

/obj/item/storage/large_holster/katana
	name = "\improper katana scabbard"
	desc = "A large, vibrantly colored katana scabbard used to carry a japanese sword. It can be strapped to the back or the armor. Because of the sturdy wood casing of the scabbard, it makes an okay defensive weapon in a pinch."
	base_icon = "katana_holster"
	icon_state = "katana_holster"
	force = 12
	attack_verb = list("bludgeoned", "struck", "cracked")
	flags_equip_slot = SLOT_WAIST|SLOT_BACK
	can_hold = list("/obj/item/weapon/katana")

/obj/item/storage/large_holster/katana/full/New()
	..()
	icon_state = "katana_holster_full"
	new /obj/item/weapon/katana(src)


/obj/item/storage/large_holster/m39
	name = "\improper M276 pattern M39 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is designed for the M39 SMG, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	icon_state = "m39_holster"
	icon = 'icons/obj/clothing/belts.dmi'
	base_icon = "m39_holster"
	flags_equip_slot = SLOT_WAIST
	can_hold = list("/obj/item/weapon/gun/smg/m39")

/obj/item/storage/large_holster/m39/update_icon()
	var/mob/user = loc
	if(contents.len)
		var/obj/I = contents[1]
		icon_state = "[base_icon]_full_[I.icon_state]"
		item_state = "[base_icon]_full"
	else
		icon_state = base_icon
		item_state = base_icon
	if(istype(user)) user.update_inv_belt()

/obj/item/storage/large_holster/m39/full/New()
	..()
	new /obj/item/weapon/gun/smg/m39(src)
	update_icon()

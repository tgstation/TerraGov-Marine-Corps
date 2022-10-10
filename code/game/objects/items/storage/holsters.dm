///Parent item for all holster type storage items

/obj/item/storage/holster
	name = "holster"
	desc = "Holds stuff, and sometimes goes swoosh."
	icon_state = "backpack"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = 4 ///normally the special item will be larger than what should fit. Child items will have lower limits and an override
	storage_slots = 1
	max_storage_space = 4
	flags_equip_slot = ITEM_SLOT_BACK
	draw_mode = 1
	allow_drawing_method = TRUE
	///is used to store the 'empty' sprite name
	var/base_icon = "m37_holster"
	///the sound produced when the special item is drawn
	var/draw_sound = 'sound/weapons/guns/misc/rifle_draw.ogg'
	///the sound produced when the special item is sheathed
	var/sheathe_sound = 'sound/weapons/guns/misc/rifle_draw.ogg'
	///the snowflake item(s) that will update the sprite.
	var/list/holsterable_allowed = list()
	///records the specific special item currently in the holster
	var/holstered_item = null

/obj/item/storage/holster/equipped(mob/user, slot)
	if (slot == SLOT_BACK || slot == SLOT_BELT || slot == SLOT_S_STORE)	//add more if needed
		mouse_opacity = MOUSE_OPACITY_OPAQUE //so it's easier to click when properly equipped.
	return ..()

/obj/item/storage/holster/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	return ..()

/obj/item/storage/holster/should_access_delay(obj/item/item, mob/user, taking_out) //defaults to 0
	if (!taking_out) // Always allow items to be tossed in instantly
		return FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.back == src)
			return TRUE
	return FALSE

/obj/item/storage/holster/handle_item_insertion(obj/item/W, prevent_warning = 0)
	. = ..()
	if (!. || !(W.type in holsterable_allowed) ) //check to see if the item being inserted is the snowflake item
		return
	holstered_item = W
	playsound(src, sheathe_sound, 15, 1)
	update_icon()

/obj/item/storage/holster/remove_from_storage(obj/item/W, atom/new_location, mob/user)
	. = ..()
	if (!. || !(W.type in holsterable_allowed) ) //check to see if the item being removed is the snowflake item
		return
	holstered_item = null
	playsound(src, draw_sound, 15, 1)
	update_icon()

/obj/item/storage/holster/update_icon_state()
	//sets the icon to full or empty
	if (holstered_item)
		icon_state = base_icon + "_full"
	else
		icon_state = base_icon
	//sets the item state to match the icon state
	item_state = icon_state

/obj/item/storage/holster/update_icon()
	. = ..() //calls update_icon_state to change the icon/item state
	var/mob/user = loc
	if (!istype(user))
		return
	user.update_inv_back()
	user.update_inv_belt()
	user.update_inv_s_store()

//Will only draw the specific holstered item, not ammo etc.
/obj/item/storage/holster/do_quick_equip()
	if(!holstered_item)
		return FALSE
	var/obj/item/W = holstered_item
	remove_from_storage(W, user = src)
	return W

//backpack type holster items
/obj/item/storage/holster/backholster
	name = "backpack holster"
	desc = "You wear this on your back and put items into it. Usually one special item too."
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/backpack.dmi')
	max_w_class = 3 //normal items
	max_storage_space = 24
	access_delay = 1.5 SECONDS ///0 out for satchel types

//only applies on storage of all items, not withdrawal
/obj/item/storage/holster/backholster/attackby(obj/item/I, mob/user, params)
	. = ..()
	if (use_sound)
		playsound(loc, use_sound, 15, 1, 6)

/obj/item/storage/holster/backholster/equipped(mob/user, slot)
	if (slot == SLOT_BACK)
		mouse_opacity = MOUSE_OPACITY_OPAQUE //so it's easier to click when properly equipped.
		if(use_sound)
			playsound(loc, use_sound, 15, 1, 6)
	return ..()

///RR bag
/obj/item/storage/holster/backholster/rpg
	name = "\improper TGMC rocket bag"
	desc = "This backpack can hold 4 67mm shells, in addition to a recoiless launcher."
	icon_state = "marine_rocket"
	item_state = "marine_rocket"
	base_icon = "marine_rocket"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 5
	max_w_class = 4
	access_delay = 0.5 SECONDS
	holsterable_allowed = list(
		/obj/item/weapon/gun/launcher/rocket/recoillessrifle,
		/obj/item/weapon/gun/launcher/rocket/recoillessrifle/low_impact,
	)
	bypass_w_limit = list(/obj/item/weapon/gun/launcher/rocket/recoillessrifle,)
	///only one RR per bag
	storage_type_limits = list(/obj/item/weapon/gun/launcher/rocket/recoillessrifle = 1,)
	can_hold = list(
		/obj/item/ammo_magazine/rocket,
		/obj/item/weapon/gun/launcher/rocket/recoillessrifle,
	)
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/backpack.dmi') //robots have their own snowflake back sprites

/obj/item/storage/holster/backholster/rpg/full/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rocket/recoilless/light(src)
	new /obj/item/ammo_magazine/rocket/recoilless/light(src)
	new /obj/item/ammo_magazine/rocket/recoilless(src)
	new /obj/item/ammo_magazine/rocket/recoilless(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/recoillessrifle(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_item)

/obj/item/storage/holster/backholster/rpg/low_impact/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/recoillessrifle/low_impact(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_item)

/obj/item/storage/holster/backholster/rpg/som
	name = "\improper SOM RPG bag"
	desc = "This backpack can hold 4 RPGs, in addition to a RPG launcher."
	icon_state = "som_rocket"
	item_state = "som_rocket"
	base_icon = "som_rocket"
	holsterable_allowed = list(
		/obj/item/weapon/gun/launcher/rocket/som,
		/obj/item/weapon/gun/launcher/rocket/som/rad,
	)
	bypass_w_limit = list(/obj/item/weapon/gun/launcher/rocket/som)
	storage_type_limits = list(/obj/item/weapon/gun/launcher/rocket/som = 1)
	can_hold = list(
		/obj/item/ammo_magazine/rocket,
		/obj/item/weapon/gun/launcher/rocket/som,
	)

/obj/item/storage/holster/backholster/rpg/som/war_crimes/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rocket/som/incendiary(src)
	new /obj/item/ammo_magazine/rocket/som/incendiary(src)
	new /obj/item/ammo_magazine/rocket/som/rad(src)
	new /obj/item/ammo_magazine/rocket/som/rad(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/som/rad(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_item)

//one slot holsters

///swords
/obj/item/storage/holster/blade
	///used only for storage path purposes
	name = "\improper default holster"
	desc = "You shouldn't see this."

/obj/item/storage/holster/blade/machete
	name = "\improper H5 pattern M2132 machete scabbard"
	desc = "A large leather scabbard used to carry a M2132 machete. It can be strapped to the back, waist or armor."
	icon_state = "machete_holster"
	base_icon = "machete_holster"
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	holsterable_allowed = list(
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/claymore/harvester,
	)
	can_hold = list(
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/claymore/harvester,
	)

/obj/item/storage/holster/blade/machete/full/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/claymore/mercsword/machete(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_item)

/obj/item/storage/holster/blade/machete/full_harvester
	name = "H5 Pattern M2132 harvester scabbard"

/obj/item/storage/holster/blade/machete/full_harvester/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/claymore/harvester(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_item)

/obj/item/storage/holster/blade/katana
	name = "\improper katana scabbard"
	desc = "A large, vibrantly colored katana scabbard used to carry a japanese sword. It can be strapped to the back, waist or armor. Because of the sturdy wood casing of the scabbard, it makes an okay defensive weapon in a pinch."
	icon_state = "katana_holster"
	base_icon = "katana_holster"
	force = 12
	attack_verb = list("bludgeoned", "struck", "cracked")
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	holsterable_allowed = list(/obj/item/weapon/katana)
	can_hold = list(/obj/item/weapon/katana)

/obj/item/storage/holster/blade/katana/full/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/katana(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_item)

/obj/item/storage/holster/blade/officer
	name = "\improper officer sword scabbard"
	desc = "A large leather scabbard used to carry a sword. Appears to be a reproduction, rather than original. It can be strapped to the waist or armor."
	icon_state = "officer_sheath"
	base_icon = "officer_sheath"
	flags_equip_slot = ITEM_SLOT_BELT
	holsterable_allowed = list(/obj/item/weapon/claymore/mercsword/officersword)
	can_hold = list(/obj/item/weapon/claymore/mercsword/officersword)

/obj/item/storage/holster/blade/officer/full/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/claymore/mercsword/officersword(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_item)

//guns

/obj/item/storage/holster/m37
	name = "\improper L44 shotgun scabbard"
	desc = "A large leather holster allowing the storage of any shotgun. It contains harnesses that allow it to be secured to the back for easy storage."
	icon_state = "m37_holster"
	base_icon = "m37_holster"
	holsterable_allowed = list(
		/obj/item/weapon/gun/shotgun/combat,
		/obj/item/weapon/gun/shotgun/pump,
	)
	can_hold = list(
		/obj/item/weapon/gun/shotgun/combat,
		/obj/item/weapon/gun/shotgun/pump,
	)

/obj/item/storage/holster/m37/full/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/gun/shotgun/pump(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_item)

/obj/item/storage/holster/t35
	name = "\improper L44 SH-35 scabbard"
	desc = "A large leather holster allowing the storage of an SH-35 Shotgun. It contains harnesses that allow it to be secured to the back for easy storage."
	icon_state = "t35_holster"
	base_icon = "t35_holster"
	holsterable_allowed = list(/obj/item/weapon/gun/shotgun/pump/t35)
	can_hold = list(
		/obj/item/weapon/gun/shotgun/pump/t35,
	)

/obj/item/storage/holster/t35/full/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/gun/shotgun/pump/t35(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_item)

/obj/item/storage/holster/m25
	name = "\improper M276 pattern M25 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is designed for the M25 SMG, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	icon_state = "m25_holster"
	icon = 'icons/obj/clothing/belts.dmi'
	base_icon = "m25_holster"
	flags_equip_slot = ITEM_SLOT_BELT
	holsterable_allowed = list(
		/obj/item/weapon/gun/smg/m25,
		/obj/item/weapon/gun/smg/m25/holstered,
	)
	can_hold = list(/obj/item/weapon/gun/smg/m25)

/obj/item/storage/holster/m25/full/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/gun/smg/m25(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_item)

/obj/item/storage/holster/t19
	name = "\improper M276 pattern MP-19 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is designed for the MP-19 SMG, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	icon_state = "t19_holster"
	icon = 'icons/obj/clothing/belts.dmi'
	base_icon = "t19_holster"
	flags_equip_slot = ITEM_SLOT_BELT
	holsterable_allowed = list(
		/obj/item/weapon/gun/smg/standard_machinepistol,
		/obj/item/weapon/gun/smg/standard_machinepistol/compact,
		/obj/item/weapon/gun/smg/standard_machinepistol/vgrip,
	)
	can_hold = list(/obj/item/weapon/gun/smg/standard_machinepistol)

/obj/item/storage/holster/t19/full/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/gun/smg/standard_machinepistol(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_item)

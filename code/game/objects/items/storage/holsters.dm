///Parent item for all holster type storage items

/obj/item/storage/holster
	name = "holster"
	desc = "Holds stuff, and sometimes goes swoosh."
	icon_state = "backpack"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_BULKY ///normally the special item will be larger than what should fit. Child items will have lower limits and an override
	storage_slots = 1
	max_storage_space = 4
	flags_equip_slot = ITEM_SLOT_BACK
	draw_mode = 1
	allow_drawing_method = TRUE
	storage_type_limits = list(/obj/item/weapon/gun = 1) //Any holster can only hold 1 gun in it
	///is used to store the 'empty' sprite name
	var/base_icon = "m37_holster"
	///the sound produced when the special item is drawn
	var/draw_sound = 'sound/weapons/guns/misc/rifle_draw.ogg'
	///the sound produced when the special item is sheathed
	var/sheathe_sound = 'sound/weapons/guns/misc/rifle_draw.ogg'
	///the snowflake item(s) that will update the sprite.
	var/list/holsterable_allowed = list()
	///records the specific special item currently in the holster
	var/obj/holstered_item = null
	///Image of the pistol that gets overlay'd over the belt sprite
	var/image/gun_underlay

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
	if(!. || !is_type_in_list(W,holsterable_allowed)) //check to see if the item being inserted is the snowflake item
		return
	holstered_item = W
	playsound(src, sheathe_sound, 15, 1)
	if(istype(src, /obj/item/storage/holster/belt)) //Belt holsters have a pistol-in-belt sprite to overlay over the belt
		update_gun_icon()
	else
		update_icon()

/obj/item/storage/holster/remove_from_storage(obj/item/W, atom/new_location, mob/user)
	. = ..()
	if(!. || !is_type_in_list(W,holsterable_allowed)) //check to see if the item being removed is the snowflake item
		return
	holstered_item = null
	playsound(src, draw_sound, 15, 1)
	if(istype(src, /obj/item/storage/holster/belt)) //Belt holsters have a pistol-in-belt sprite to overlay over the belt
		update_gun_icon()
	else
		update_icon()

/obj/item/storage/holster/update_icon_state()
	//sets the icon to full or empty
	if(holstered_item)
		icon_state = base_icon + "_full"
	else
		icon_state = base_icon
	//sets the item state to match the icon state
	item_state = icon_state

/obj/item/storage/holster/update_icon()
	. = ..() //calls update_icon_state to change the icon/item state
	var/mob/user = loc
	if(!istype(user))
		return
	user.update_inv_back()
	user.update_inv_belt()
	user.update_inv_s_store()

///We do not want to use regular update_icon as it's called for every item inserted. Not worth the icon math.
/obj/item/storage/holster/proc/update_gun_icon()
	var/mob/user = loc
	if(holstered_item) //So it has a gun, let's make an icon.
		/*
		Have to use a workaround here, otherwise images won't display properly at all times.
		Reason being, transform is not displayed when right clicking/alt+clicking an object,
		so it's necessary to pre-load the potential states so the item actually shows up
		correctly without having to rotate anything. Preloading weapon icons also makes
		sure that we don't have to do any extra calculations.
		*/
		playsound(src,draw_sound, 15, 1)
		gun_underlay = image(icon, src, holstered_item.icon_state)
		icon_state = base_icon + "_full"
		item_state = icon_state
		underlays += gun_underlay
	else
		playsound(src,sheathe_sound, 15, 1)
		underlays -= gun_underlay
		icon_state = base_icon
		item_state = icon_state
		qdel(gun_underlay)
		gun_underlay = null
	if(istype(user)) user.update_inv_belt()
	if(istype(user)) user.update_inv_s_store()

///Will only draw the specific holstered item, not ammo etc.
/obj/item/storage/holster/do_quick_equip(mob/user)
	if(!holstered_item)
		return FALSE
	var/obj/item/W = holstered_item
	if(!remove_from_storage(W, null, user))
		return FALSE
	return W

/obj/item/storage/holster/attack_hand(mob/living/user) //If your holstered item is in the storage, clicking the holster will always draw it
	if(holstered_item && ishuman(user) && loc == user)
		holstered_item.attack_hand(user)
	else
		return ..()

/obj/item/storage/holster/vendor_equip(mob/user)
	..()
	return user.equip_to_appropriate_slot(src)

//backpack type holster items
/obj/item/storage/holster/backholster
	name = "backpack holster"
	desc = "You wear this on your back and put items into it. Usually one special item too."
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/backpacks_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/backpacks_right.dmi',
	)
	sprite_sheets = list(
		"Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Sterling Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Chilvaris Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Hammerhead Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Ratcher Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		)
	max_w_class = WEIGHT_CLASS_NORMAL //normal items
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
	max_w_class = WEIGHT_CLASS_BULKY
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
	sprite_sheets = list(
		"Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Sterling Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Chilvaris Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Hammerhead Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Ratcher Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		)

/obj/item/storage/holster/backholster/rpg/full/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rocket/recoilless/light(src)
	new /obj/item/ammo_magazine/rocket/recoilless/light(src)
	new /obj/item/ammo_magazine/rocket/recoilless(src)
	new /obj/item/ammo_magazine/rocket/recoilless(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/recoillessrifle(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/backholster/rpg/low_impact/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/recoillessrifle/low_impact(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

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
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/backholster/rpg/som/ert/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rocket/som/thermobaric(src)
	new /obj/item/ammo_magazine/rocket/som/thermobaric(src)
	new /obj/item/ammo_magazine/rocket/som/heat(src)
	new /obj/item/ammo_magazine/rocket/som/rad(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/som/rad(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

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
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/blade/machete/full_harvester
	name = "H5 Pattern M2132 harvester scabbard"

/obj/item/storage/holster/blade/machete/full_harvester/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/claymore/harvester(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

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
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

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
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

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
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

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
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

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
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

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

	storage_slots = 4
	max_storage_space = 10
	max_w_class = WEIGHT_CLASS_BULKY

	can_hold = list(
		/obj/item/weapon/gun/smg/standard_machinepistol,
		/obj/item/ammo_magazine/smg/standard_machinepistol,
	)

/obj/item/storage/holster/t19/full/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/gun/smg/standard_machinepistol(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

////////////////////////////// GUN BELTS /////////////////////////////////////

/obj/item/storage/holster/belt
	name = "pistol belt"
	desc = "A belt-holster assembly that allows one to hold a pistol and two magazines."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "m4a3_holster"
	base_icon = "m4a3_holster"
	item_state = "m4a3_holster"
	flags_equip_slot = ITEM_SLOT_BELT
	use_sound = null
	storage_slots = 7
	max_storage_space = 15
	max_w_class = WEIGHT_CLASS_NORMAL
	sheathe_sound = 'sound/weapons/guns/misc/pistol_sheathe.ogg'
	draw_sound = 'sound/weapons/guns/misc/pistol_draw.ogg'
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta,
		/obj/item/cell/lasgun/lasrifle,
		/obj/item/cell/lasgun/volkite/small,
	)
	holsterable_allowed = list(
		/obj/item/weapon/gun,
	) //Any pistol you add to a holster should update the sprite. Ammo/Magazines dont update any sprites

/obj/item/storage/holster/belt/Destroy()
	if(gun_underlay)
		qdel(gun_underlay)
		gun_underlay = null
	if(holstered_item)
		qdel(holstered_item)
		holstered_item = null
	return ..()

//This deliniates between belt/gun/pistol and belt/gun/revolver
/obj/item/storage/holster/belt/pistol
	name = "generic pistol belt"
	desc = "A pistol belt that is not a revolver belt"

/obj/item/storage/holster/belt/pistol/attackby_alternate(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/weapon/gun/pistol))
		return ..()
	var/obj/item/weapon/gun/pistol/gun = I
	for(var/obj/item/ammo_magazine/mag in contents)
		if(!(mag.type in gun.allowed_ammo_types))
			continue
		if(user.l_hand && user.r_hand || length(gun.chamber_items))
			gun.tactical_reload(mag, user)
		else
			gun.reload(mag, user)
		orient2hud()
		return

/obj/item/storage/holster/belt/pistol/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += span_notice("To perform a reload with the amunition inside, disable right click and right click on the belt with an empty pistol.")

/obj/item/storage/holster/belt/pistol/m4a3
	name = "\improper M4A3 holster rig"
	desc = "The M4A3 is a common holster belt. It consists of a modular belt with various clips. This version has a holster assembly that allows one to carry a handgun. It also contains side pouches that can store 9mm or .45 magazines."
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/cell/lasgun/lasrifle,
	)

/obj/item/storage/holster/belt/pistol/m4a3/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/rt3(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/officer/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/rt3(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/fieldcommander/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/m1911/custom(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/vp70/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/vp70_pmc/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/vp70/tactical(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/vp78/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/som
	name = "\improper S19 holster rig"
	desc = "A belt with origins dating back to old colony security holster rigs."
	icon_state = "som_belt_pistol"
	base_icon = "som_belt_pistol"
	item_state = "som_belt_pistol"
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta,
		/obj/item/cell/lasgun/lasrifle,
		/obj/item/cell/lasgun/volkite/small,
	)

/obj/item/storage/holster/belt/pistol/m4a3/som/fancy
	name = "\improper S19-B holster rig"
	desc = "A quality pistol belt of a style typically seen worn by SOM officers. It looks old, but well looked after."
	icon_state = "som_belt_pistol_fancy"
	base_icon = "som_belt_pistol_fancy"
	item_state = "som_belt_pistol_fancy"

/obj/item/storage/holster/belt/pistol/stand
	name = "\improper M276 pattern M4A3 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version has a holster assembly that allows one to carry the M4A3 comfortably secure. It also contains side pouches that can store 9mm or .45 magazines."
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
	)

/obj/item/storage/holster/belt/pistol/standard_pistol
	name = "\improper T457 pattern pistol holster rig"
	desc = "The T457 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips."
	icon_state = "tp14_holster"
	base_icon = "tp14_holster"
	item_state = "tp14_holster"

/obj/item/storage/holster/belt/revolver/standard_revolver
	name = "\improper T457 pattern revolver holster rig"
	desc = "The T457 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips."
	icon_state = "tp44_holster"
	base_icon = "tp44_holster"
	item_state = "tp44_holster"
	bypass_w_limit = list(
		/obj/item/weapon/gun/revolver,
	)
	can_hold = list(
		/obj/item/weapon/gun/revolver,
		/obj/item/ammo_magazine/revolver,
	)

/obj/item/storage/holster/belt/m44
	name = "\improper M276 pattern M44 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is for the M44 magnum revolver, along with three pouches for speedloaders."
	icon_state = "m44_holster"
	base_icon = "m44_holster"
	item_state = "m44_holster"
	max_storage_space = 16
	max_w_class = WEIGHT_CLASS_BULKY
	can_hold = list(
		/obj/item/weapon/gun/revolver,
		/obj/item/ammo_magazine/revolver,
	)

/obj/item/storage/holster/belt/m44/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/single_action/m44(src)
	new /obj/item/ammo_magazine/revolver/heavy(src)
	new /obj/item/ammo_magazine/revolver/marksman(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/revolver(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/mateba
	name = "\improper M276 pattern Mateba holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is for the powerful Mateba magnum revolver, along with three pouches for speedloaders."
	icon_state = "mateba_holster"
	base_icon = "mateba_holster"
	item_state = "mateba_holster"
	max_storage_space = 16
	bypass_w_limit = list(
		/obj/item/weapon/gun/revolver/mateba,
	)
	can_hold = list(
		/obj/item/weapon/gun/revolver/mateba,
		/obj/item/ammo_magazine/revolver/mateba,
	)

/obj/item/storage/holster/belt/mateba/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/mateba/officer
	icon_state = "c_mateba_holster"
	base_icon = "c_mateba_holster"
	item_state = "c_mateba_holster"

/obj/item/storage/holster/belt/mateba/officer/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba/custom(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/mateba/notmarine/Initialize()
	. = ..()
	icon_state = "a_mateba_holster"
	base_icon = "a_mateba_holster"
	item_state = "a_mateba_holster"
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba/(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/korovin
	name = "\improper Type 41 pistol holster rig"
	desc = "A modification of the standard UPP pouch rig to carry a single Korovin PK-9 pistol. It also contains side pouches that can store .22 magazines, either hollowpoints or tranquilizers."
	icon_state = "korovin_holster"
	base_icon = "korovin_holster"
	item_state = "korovin_holster"
	can_hold = list(
		/obj/item/weapon/gun/pistol/c99,
		/obj/item/ammo_magazine/pistol/c99,
		/obj/item/ammo_magazine/pistol/c99t,
	)

/obj/item/storage/holster/belt/korovin/standard/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/korovin/tranq/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/c99/tranq(src)
	new /obj/item/ammo_magazine/pistol/c99t(src)
	new /obj/item/ammo_magazine/pistol/c99t(src)
	new /obj/item/ammo_magazine/pistol/c99t(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/ts34
	name = "\improper M276 pattern SH-34 shotgun holster rig"
	desc = "A purpose built belt-holster assembly that holds a SH-34 shotgun and one shell box or 2 handfuls."
	icon_state = "ts34_holster"
	base_icon = "ts34_holster"
	item_state = "ts34_holster"
	max_w_class = WEIGHT_CLASS_BULKY //So it can hold the shotgun.
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 3
	max_storage_space = 8
	can_hold = list(
		/obj/item/weapon/gun/shotgun/double/marine,
		/obj/item/ammo_magazine/shotgun,
		/obj/item/ammo_magazine/handful,
	)
	holsterable_allowed = list(/obj/item/weapon/gun/shotgun/double/marine)

/obj/item/storage/holster/belt/ts34/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/shotgun/double/marine(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/smart_pistol
	name = "\improper SP-13 holster rig"
	desc = "A holster belt, which holds SP-13 smartpistol and magazines for it."
	can_hold = list(
		/obj/item/weapon/gun/pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
	)

/obj/item/storage/holster/belt/pistol/smart_pistol/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

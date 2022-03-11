///Parent item for all holster type storage items

/obj/item/storage/holster
	name = "Holster"
	desc = "holds stuff, and sometimes goes swoosh."
	icon_state = "backpack"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = 4 ///normally the special item will be larger than what should fit. Child items will have lower limits and an override
	storage_slots = 1
	max_storage_space = 4
	draw_mode = 1
	var/base_icon = "m37_holster" ///what is this used for in large_holster code?
	var/drawSound = 'sound/weapons/guns/misc/rifle_draw.ogg'
	var/sheatheSound = 'sound/weapons/guns/misc/rifle_draw.ogg'
	///the snowflake item(s) that will update the sprite. ///currently setup for a single item, or item and it's children in the case of belt holsters. Lists could be used for various items, but would require more work.
	var/holsterable_allowed = NULL
	///starts empty - need to check out shit that starts full to see what happens
	var/holstered = FALSE

/obj/item/storage/holster/equipped(mob/user, slot)
	if(slot == SLOT_BACK || slot == SLOT_BELT || slot == SLOT_S_STORE)	///add more if needed
		mouse_opacity = 2 //so it's easier to click when properly equipped.
	..()

/obj/item/storage/holster/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()

////draw delay code, might not need to be in the parent, but probably doesn't hurt?
/obj/item/storage/holster/should_access_delay(obj/item/item, mob/user, taking_out) ///defaults to 0
	if(!taking_out) // Always allow items to be tossed in instantly
		return FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.back == src)
			return TRUE
	return FALSE

///if the item being inserted is the snowflake item, update sprite and make it swoosh
/obj/item/storage/holster/handle_item_insertion(obj/item/W, prevent_warning = 0)
	. = ..()
	if(. && W == holsterable_allowed)
		holstered = TRUE
		update_holster_icon()
	return

///if the item being removed is the snowflake item, update sprite and make it swoosh
/obj/item/storage/holster/remove_from_storage(obj/item/W, atom/new_location, mob/user)
	. = ..()
	if(. && W == holsterable_allowed)
		holstered = FALSE
		update_holster_icon()

///only called when the snowflake item is put in or removed. What actually updates the icon
/obj/item/storage/holster/proc/update_holster_icon()
	var/mob/user = loc
	if(holstered) 	///sheathe the snowflake item ///may need to inverse the holstered code to make it actually make sense
		playsound(src,sheatheSound, 15, 1)
		icon_state += "_g"
		item_state = icon_state
	else			///draws the snowflake item
		playsound(src,drawSound, 15, 1)
		icon_state = copytext(icon_state,1,-2)
		item_state = icon_state

	if(istype(user)) 			///is there a way to tell it what slot src is in and only update that?
		user.update_inv_back()
		user.update_inv_belt()
		user.update_inv_s_store()

/obj/item/storage/holster/update_icon()
	. = ..()
	var/mob/user = loc
	if(istype(user))
		user.update_inv_back()
		user.update_inv_belt()
		user.update_inv_s_store()


//////actual backpack holster items////////
/obj/item/storage/holster/backholster
	name = "Backpack holster"
	desc = "You wear this on your back and put items into it. Usually one special item too"
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/backpack.dmi') ///robots have snowflake backpack icons
	flags_equip_slot = ITEM_SLOT_BACK
	max_w_class = 3 //normal items
	max_storage_space = 24
	access_delay = 1.5 SECONDS ///0 out for satchel types

///only applies on storage, not withdrawal. All items
/obj/item/storage/holster/backholster/attackby(obj/item/I, mob/user, params)
	. = ..()

	if (use_sound)
		playsound(loc, use_sound, 15, 1, 6)

///just need the sound bit, not sure if I can . = ..() the rest due to the nested if
/obj/item/storage/holster/backholster/equipped(mob/user, slot)
	if(slot == SLOT_BACK)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
		if(use_sound)
			playsound(loc, use_sound, 15, 1, 6)
	..()


///test rpg bag///
/obj/item/storage/holster/backholster/rpg
	name = "\improper TGMC rocket bag"
	desc = "This backpack can hold 5 67mm shells or 80mm rockets."
	icon_state = "marine_rocket"
	item_state = "marine_rocket"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 5 //It can hold 5 rockets.
	max_w_class = 4
	access_delay = 0
	holsterable_allowed = /obj/item/weapon/gun/launcher/rocket/recoillessrifle
	bypass_w_limit = list(
		/obj/item/weapon/gun/launcher/rocket/recoillessrifle,
	)
	storage_type_limits = list(
		/obj/item/weapon/gun/launcher/rocket/recoillessrifle = 1,
	)
	can_hold = list(
		/obj/item/ammo_magazine/rocket,
		/obj/item/weapon/gun/launcher/rocket/recoillessrifle,
	)
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/backpack.dmi') //robots have their own damn sprites, pls.
	flags_equip_slot = ITEM_SLOT_BACK

/obj/item/storage/holster/blade/officer
	draw_sound = 'modular_RUtgmc/sound/items/unsheath.ogg'
	sheathe_sound = 'modular_RUtgmc/sound/items/sheath.ogg'

/obj/item/storage/holster/blade/officer/valirapier
	name = "\improper HP-C vali rapier sheath"
	desc = "An exquisite ceremonial sheat for an even more expensive rapier."
	icon = 'modular_RUtgmc/icons/obj/items/storage/storage.dmi'
	item_icons = list(
		slot_l_hand_str = 'modular_RUtgmc/icons/mob/inhands/items/containers_left.dmi',
		slot_r_hand_str = 'modular_RUtgmc/icons/mob/inhands/items/containers_right.dmi',
	)
	icon_state = "rapier_holster"
	base_icon = "rapier_holster"
	holsterable_allowed = list(/obj/item/weapon/claymore/mercsword/officersword/valirapier)
	can_hold = list(/obj/item/weapon/claymore/mercsword/officersword/valirapier)

/obj/item/storage/holster/blade/officer/valirapier/full/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/claymore/mercsword/officersword/valirapier(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

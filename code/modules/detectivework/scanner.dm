/obj/item/detective_scanner
	name = "forensic scanner"
	desc = "Used to scan objects for DNA and fingerprints."
	icon = 'icons/obj/device.dmi'
	icon_state = "forensic1"
	var/list/stored = list()
	w_class = WEIGHT_CLASS_NORMAL
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/engineering_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/engineering_right.dmi',
	)
	worn_icon_state = "electronic"
	atom_flags = CONDUCT
	item_flags = NOBLUDGEON
	equip_slot_flags = ITEM_SLOT_BELT

/obj/item/detective_scanner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	to_chat(user, span_warning("This device is non-functional."))

/obj/item/detective_scanner/afterattack(atom/A as obj|turf, mob/user, proximity)
	to_chat(user, span_warning("This device is non-functional."))

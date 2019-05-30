/obj/item/detective_scanner
	name = "forensic scanner"
	desc = "Used to scan objects for DNA and fingerprints."
	icon_state = "forensic1"
	var/list/stored = list()
	w_class = 3.0
	item_state = "electronic"
	flags_atom = CONDUCT
	flags_item = NOBLUDGEON
	flags_equip_slot = ITEM_SLOT_BELT

/obj/item/detective_scanner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	to_chat(user, "<span class='warning'>This device is non-functional.</span>")

/obj/item/detective_scanner/afterattack(atom/A as obj|turf, mob/user, proximity)
	to_chat(user, "<span class='warning'>This device is non-functional.</span>")

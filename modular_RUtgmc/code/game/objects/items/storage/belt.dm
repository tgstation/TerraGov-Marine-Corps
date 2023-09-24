/obj/item/storage/belt/gun/revolver/t500
	name = "\improper BM500 pattern BF revolver holster rig"
	desc = "The BM500 is the special modular belt for R-500 BF revolver."
	icon = 'modular_RUtgmc/icons/obj/clothing/belts.dmi'
	icon_state = "belt"
	max_w_class = 3.5
	can_hold = list(
		/obj/item/weapon/gun/revolver/t500,
		/obj/item/ammo_magazine/revolver/t500,
		/obj/item/ammo_magazine/packet/t500,
	)

/obj/item/storage/belt/mortar_belt
	name = "TA-10 mortar belt"
	desc = "A belt that holds a TA-10 50mm Mortar, rangefinder and a lot of ammo for it."
	icon = 'modular_RUtgmc/icons/obj/clothing/belts.dmi'
	icon_state = "kneemortar_holster"
	item_state = "m4a3_holster"
	use_sound = null
	w_class = WEIGHT_CLASS_BULKY
	storage_type_limits = list(
		/obj/item/mortar_kit/knee = 1,
		/obj/item/binoculars = 1,
		/obj/item/compass = 1,
	)
	storage_slots = 24
	max_storage_space = 49
	max_w_class = 3

	can_hold = list(
		/obj/item/mortar_kit/knee,
		/obj/item/mortal_shell/knee,
		/obj/item/compass,
		/obj/item/binoculars,
	)

/obj/item/storage/belt/mortar_belt/full/Initialize()
	. = ..()
	new /obj/item/mortar_kit/knee(src)
	new /obj/item/binoculars/tactical/range(src)

/obj/item/storage/belt/lifesaver
	bypass_w_limit = list(
		/obj/item/stack/medical/heal_pack/advanced/burn_pack/combat,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack/combat,
	)

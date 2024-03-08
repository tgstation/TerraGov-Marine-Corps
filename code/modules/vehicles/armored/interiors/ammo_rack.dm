
/obj/structure/ammo_rack
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	///ref to the actual internal storage
	var/obj/item/storage/internal/storage = /obj/item/storage/internal

/obj/structure/ammo_rack/Initialize(mapload)
	. = ..()
	storage = new storage(src)
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/ammo_rack/examine(mob/user)
	. = ..()
	. += "Right click to remove the topmost object."

/obj/structure/ammo_rack/attack_hand(mob/living/user)
	return storage.open(user)

/obj/structure/ammo_rack/MouseDrop(obj/over_object)
	if(storage.handle_mousedrop(usr, over_object))
		return ..()

/obj/structure/ammo_rack/attackby(obj/item/I, mob/user, params)
	..()
	return storage.attackby(I, user, params)

/obj/structure/ammo_rack/attack_hand_alternate(mob/user)
	..()
	return storage.attack_hand_alternate(user)

/obj/structure/ammo_rack/update_overlays()
	. = ..()
	if(length(storage.contents))
		var/atom/bottommost = storage.contents[1]
		var/total_w = 0
		for(var/obj/item/I AS in storage)
			total_w += I.w_class
		var/thirds = clamp(round(3 * (total_w / storage.max_storage_space)), 1, 3)
		. += image(icon, src, bottommost.icon_state + "_" + "[thirds]") // "ltb_3"/"ltb_2"/"ltb_1"

/obj/structure/ammo_rack/on_pocket_insertion()
	update_appearance()

/obj/structure/ammo_rack/on_pocket_removal()
	update_appearance()

/obj/structure/ammo_rack/primary
	name = "primary ammo rack"
	icon_state = "primaryrack"
	storage = /obj/item/storage/internal/ammorack_primary

/obj/structure/ammo_rack/primary/update_overlays()
	. = ..()
	. += image(icon, src, "primaryrack_overlay")

/obj/structure/ammo_rack/secondary
	name = "secondary ammo rack"
	icon_state = "secondaryrack"
	storage = /obj/item/storage/internal/ammorack_secondary

/obj/item/storage/internal/ammorack_primary
	max_storage_space = 120 //they're all WEIGHT_CLASS_GIGANTIC which is 6
	storage_slots = 20
	max_w_class = WEIGHT_CLASS_GIGANTIC
	can_hold = list(
		/obj/item/ammo_magazine/tank/ltb_cannon,
		/obj/item/ammo_magazine/tank/ltaap_minigun,
	)

/obj/item/storage/internal/ammorack_secondary
	max_storage_space = 120
	storage_slots = 20
	max_w_class = WEIGHT_CLASS_GIGANTIC
	can_hold = list(
		/obj/item/ammo_magazine/tank/secondary_cupola,
	)

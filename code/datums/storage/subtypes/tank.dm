/*!
 * Anything tank related
 * Basically ammo racks
 */
/datum/storage/tank
	allow_drawing_method = FALSE /// Unable to set draw_mode ourselves
	max_w_class = WEIGHT_CLASS_GIGANTIC //they're all WEIGHT_CLASS_GIGANTIC which is 6
	max_storage_space = 120
	storage_slots = 20

/datum/storage/tank/on_attack_hand(datum/source, mob/living/user) //Override for tank subtype since this is deployed storage
	if(parent.Adjacent(user))
		open(user)

/datum/storage/tank/ammorack_primary/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/ammo_magazine/tank/ltb_cannon,
		/obj/item/ammo_magazine/tank/ltaap_chaingun,
	))

/datum/storage/tank/ammorack_secondary/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/ammo_magazine/tank/secondary_cupola,
	))

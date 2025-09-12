/*!
 * Anything tank related
 * Basically ammo racks
 */
/datum/storage/tank
	allow_drawing_method = FALSE /// Unable to set draw_mode ourselves
	max_w_class = WEIGHT_CLASS_GIGANTIC //they're all WEIGHT_CLASS_GIGANTIC which is 6
	max_storage_space = 120
	storage_slots = 40

/datum/storage/tank/on_attack_hand(datum/source, mob/living/user) //Override for tank subtype since this is deployed storage
	if(parent.Adjacent(user))
		open(user)

/datum/storage/tank/ammorack_primary/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/ammo_magazine/tank/ltb_cannon,
		/obj/item/ammo_magazine/tank/ltaap_chaingun,
		/obj/item/ammo_magazine/tank/ltaap_chaingun/hv,
		/obj/item/ammo_magazine/tank/ltb_cannon/heavy,
		/obj/item/ammo_magazine/tank/ltb_cannon/apfds,
		/obj/item/ammo_magazine/tank/ltb_cannon/canister,
		/obj/item/ammo_magazine/tank/ltb_cannon/canister/incendiary,
		/obj/item/ammo_magazine/tank/volkite_carronade,
		/obj/item/ammo_magazine/tank/particle_lance,
		/obj/item/ammo_magazine/tank/coilgun,
		/obj/item/ammo_magazine/tank/icc_lowvel_cannon,
		/obj/item/ammo_magazine/tank/icc_lowvel_cannon/high_explosive,
		/obj/item/ammo_magazine/tank/sarden_clip,
		/obj/item/ammo_magazine/tank/sarden_clip/high_explosive,
		/obj/item/ammo_magazine/tank/bfg,
		/obj/item/ammo_magazine/tank/autocannon,
		/obj/item/ammo_magazine/tank/autocannon/high_explosive,
	))

/datum/storage/tank/ammorack_secondary/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/ammo_magazine/tank/secondary_cupola,
		/obj/item/ammo_magazine/tank/secondary_flamer_tank,
		/obj/item/ammo_magazine/tank/secondary_mlrs,
		/obj/item/ammo_magazine/icc_mg,
		/obj/item/ammo_magazine/tank/microrocket_rack,
		/obj/item/ammo_magazine/tank/tow_missile,
	))

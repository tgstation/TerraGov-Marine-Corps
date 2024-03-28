/datum/storage/holster
	max_w_class = WEIGHT_CLASS_BULKY ///normally the special item will be larger than what should fit. Child items will have lower limits and an override
	storage_slots = 1
	max_storage_space = 4
	draw_mode = 1
	allow_drawing_method = TRUE
	storage_type_limits = list(/obj/item/weapon = 1)

/datum/storage/holster/should_access_delay(obj/item/item, mob/user, taking_out) //defaults to 0
	if(!taking_out) // Always allow items to be tossed in instantly
		return FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.back == src)
			return TRUE
	return FALSE

/datum/storage/holster/handle_item_insertion(obj/item/W, prevent_warning = 0)
	. = ..()
	var/obj/item/storage/holster/holster = parent
	if(!. || !is_type_in_list(W, holster.holsterable_allowed)) //check to see if the item being inserted is the snowflake item
		return
	holster.holstered_item = W
	holster.update_icon() //So that the icon actually updates after we've assigned our holstered_item
	playsound(parent, sheathe_sound, 15, 1)

/datum/storage/holster/remove_from_storage(obj/item/W, atom/new_location, mob/user)
	. = ..()
	var/obj/item/storage/holster/holster = parent
	if(!. || !is_type_in_list(W, holster.holsterable_allowed)) //check to see if the item being removed is the snowflake item
		return
	holster.holstered_item = null
	holster.update_icon() //So that the icon actually updates after we've assigned our holstered_item
	playsound(parent, draw_sound, 15, 1)

/datum/storage/holster/backholster
	max_w_class = WEIGHT_CLASS_NORMAL //normal items
	max_storage_space = 24
	access_delay = 1.5 SECONDS ///0 out for satchel types

/datum/storage/holster/backholster/rpg
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_BULKY
	access_delay = 0.5 SECONDS
	bypass_w_limit = list(/obj/item/weapon/gun/launcher/rocket/recoillessrifle)
	///only one RR per bag
	storage_type_limits = list(/obj/item/weapon/gun/launcher/rocket/recoillessrifle = 1)
	can_hold = list(
		/obj/item/ammo_magazine/rocket,
		/obj/item/weapon/gun/launcher/rocket/recoillessrifle,
	)

/datum/storage/holster/backholster/rpg/som
	bypass_w_limit = list(/obj/item/weapon/gun/launcher/rocket/som)
	storage_type_limits = list(/obj/item/weapon/gun/launcher/rocket/som = 1)
	can_hold = list(
		/obj/item/ammo_magazine/rocket,
		/obj/item/weapon/gun/launcher/rocket/som,
	)

/datum/storage/holster/backholster/mortar
	max_w_class = WEIGHT_CLASS_NORMAL
	storage_slots = null
	max_storage_space = 30
	access_delay = 0
	bypass_w_limit = list(/obj/item/mortar_kit)
	storage_type_limits = list(/obj/item/mortar_kit = 1)
	can_hold = list(
		/obj/item/mortal_shell/he,
		/obj/item/mortal_shell/incendiary,
		/obj/item/mortal_shell/smoke,
		/obj/item/mortal_shell/flare,
		/obj/item/mortal_shell/plasmaloss,
		/obj/item/mortar_kit,
	)

/datum/storage/holster/backholster/flamer
	storage_slots = null
	max_storage_space = 16
	max_w_class = WEIGHT_CLASS_NORMAL
	access_delay = 0
	bypass_w_limit = list(/obj/item/weapon/gun/flamer/big_flamer/marinestandard/engineer)
	storage_type_limits = list(/obj/item/weapon/gun/flamer/big_flamer/marinestandard/engineer = 1)

/datum/storage/holster/backholster/flamer/handle_item_insertion(obj/item/item, prevent_warning = 0, mob/user)
	. = ..()
	var/obj/item/storage/holster/backholster/flamer/holster = parent
	if(holster.holstered_item == item)
		var/obj/item/weapon/gun/flamer/big_flamer/marinestandard/engineer/flamer = item
		holster.refuel(flamer.chamber_items[1], user)
		flamer.update_ammo_count()

/datum/storage/holster/t19
	storage_slots = 4
	max_storage_space = 10
	max_w_class = WEIGHT_CLASS_BULKY

	can_hold = list(
		/obj/item/weapon/gun/smg/standard_machinepistol,
		/obj/item/ammo_magazine/smg/standard_machinepistol,
	)

/datum/storage/holster/flarepouch
	storage_slots = 28
	max_storage_space = 28
	storage_type_limits = list(/obj/item/weapon/gun/grenade_launcher/single_shot/flare = 1)
	can_hold = list(
		/obj/item/explosive/grenade/flare/civilian,
		/obj/item/weapon/gun/grenade_launcher/single_shot/flare,
		/obj/item/explosive/grenade/flare,
	)
	refill_types = list(/obj/item/storage/box/m94)
	refill_sound = "rustle"

/datum/storage/holster/icc_mg
	storage_slots = 5
	max_storage_space = 16
	can_hold = list(
		/obj/item/weapon/gun/rifle/icc_mg,
		/obj/item/ammo_magazine/icc_mg/packet,
	)

/datum/storage/holster/belt
	use_sound = null
	storage_slots = 7
	max_storage_space = 15
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/cell/lasgun/plasma,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta,
		/obj/item/cell/lasgun/lasrifle,
		/obj/item/cell/lasgun/volkite/small,
	)

/datum/storage/holster/belt/m44
	max_storage_space = 16
	max_w_class = WEIGHT_CLASS_BULKY
	can_hold = list(
		/obj/item/weapon/gun/revolver,
		/obj/item/ammo_magazine/revolver,
	)

/datum/storage/holster/belt/mateba
	max_storage_space = 16
	bypass_w_limit = list(
		/obj/item/weapon/gun/revolver/mateba,
	)
	can_hold = list(
		/obj/item/weapon/gun/revolver/mateba,
		/obj/item/ammo_magazine/revolver/mateba,
	)

/datum/storage/holster/belt/korovin
	can_hold = list(
		/obj/item/weapon/gun/pistol/c99,
		/obj/item/ammo_magazine/pistol/c99,
		/obj/item/ammo_magazine/pistol/c99t,
	)

/datum/storage/holster/belt/ts34
	max_w_class = WEIGHT_CLASS_BULKY //So it can hold the shotgun.
	storage_slots = 3
	max_storage_space = 8
	can_hold = list(
		/obj/item/weapon/gun/shotgun/double/marine,
		/obj/item/ammo_magazine/shotgun,
		/obj/item/ammo_magazine/handful,
	)










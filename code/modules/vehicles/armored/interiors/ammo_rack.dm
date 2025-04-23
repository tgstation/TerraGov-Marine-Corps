/*!
 * Contains ammo racks for tank ammo storage
 */
/obj/structure/ammo_rack //Parent type, only used as a template
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	resistance_flags = RESIST_ALL
	///Determines what subtype of storage is on our item, see datums\storage\subtypes
	var/storage_type = /datum/storage/tank

/obj/structure/ammo_rack/Initialize(mapload)
	. = ..()
	create_storage(storage_type)
	PopulateContents()
	update_appearance(UPDATE_OVERLAYS)

///Use this to fill your storage with items. USE THIS INSTEAD OF NEW/INIT
/obj/structure/ammo_rack/proc/PopulateContents()
	return

/obj/structure/ammo_rack/examine(mob/user)
	. = ..()
	. += "Right click to remove the topmost object."

/obj/structure/ammo_rack/update_overlays()
	. = ..()
	if(length(contents))
		var/atom/bottommost = contents[1]
		var/total_w = 0
		for(var/obj/item/I AS in contents)
			total_w += I.w_class
		var/thirds = clamp(round(3 * (total_w / storage_datum.max_storage_space)), 1, 3)
		. += image(icon, src, bottommost.icon_state + "_" + "[thirds]") // "ltb_3"/"ltb_2"/"ltb_1"

/obj/structure/ammo_rack/primary
	name = "primary ammo rack"
	icon_state = "primaryrack"
	storage_type = /datum/storage/tank/ammorack_primary

/obj/structure/ammo_rack/primary/update_overlays()
	. = ..()
	. += image(icon, src, "primaryrack_overlay")

/obj/structure/ammo_rack/secondary
	name = "secondary ammo rack"
	plane = WALL_PLANE
	icon_state = "secondaryrack"
	storage_type = /datum/storage/tank/ammorack_secondary


/obj/structure/ammo_rack/primary/som
	icon_state = "primary"
	icon = 'icons/obj/armored/3x4/som_ammo_rack.dmi'
	pixel_y = -20
	pixel_x = -34

/obj/structure/ammo_rack/secondary/som
	icon_state = "secondary"
	icon = 'icons/obj/armored/3x4/som_ammo_rack.dmi'
	pixel_x = -18
	pixel_y = -5

/obj/structure/ammo_rack/primary/icc
	icon_state = "primaryrack"
	icon = 'icons/obj/armored/2x2/icc_lvrt.dmi'
	pixel_y = -20
	pixel_x = -34

/obj/structure/ammo_rack/secondary/icc
	icon_state = "secondaryrack"
	icon = 'icons/obj/armored/2x2/icc_lvrt.dmi'
	pixel_x = -18
	pixel_y = -5

/obj/item/gun/ballistic/automatic/pistol
	name = "stechkin pistol"
	desc = ""
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/m10mm
	can_suppress = TRUE
	burst_size = 1
	fire_delay = 0
	actions_types = list()
	bolt_type = BOLT_TYPE_LOCKING
	fire_sound = 'sound/blank.ogg'
	dry_fire_sound = 'sound/blank.ogg'
	suppressed_sound = 'sound/blank.ogg'
	load_sound = 'sound/blank.ogg'
	load_empty_sound = 'sound/blank.ogg'
	eject_sound = 'sound/blank.ogg'
	eject_empty_sound = 'sound/blank.ogg'
	vary_fire_sound = FALSE
	rack_sound = 'sound/blank.ogg'
	lock_back_sound = 'sound/blank.ogg'
	bolt_drop_sound = 'sound/blank.ogg'
	fire_sound_volume = 90
	bolt_wording = "slide"

/obj/item/gun/ballistic/automatic/pistol/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)

/obj/item/gun/ballistic/automatic/pistol/m1911
	name = "\improper M1911"
	desc = ""
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE
	fire_sound = 'sound/blank.ogg'
	rack_sound = 'sound/blank.ogg'
	lock_back_sound = 'sound/blank.ogg'
	bolt_drop_sound = 'sound/blank.ogg'

/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/deagle
	name = "\improper Desert Eagle"
	desc = ""
	icon_state = "deagle"
	force = 14
	mag_type = /obj/item/ammo_box/magazine/m50
	can_suppress = FALSE
	mag_display = TRUE
	fire_sound = 'sound/blank.ogg'
	rack_sound = 'sound/blank.ogg'
	lock_back_sound = 'sound/blank.ogg'
	bolt_drop_sound = 'sound/blank.ogg'

/obj/item/gun/ballistic/automatic/pistol/deagle/gold
	desc = ""
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/deagle/camo
	desc = ""
	icon_state = "deaglecamo"
	item_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/APS
	name = "stechkin APS pistol"
	desc = ""
	icon_state = "aps"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/gun/ballistic/automatic/pistol/stickman
	name = "flat gun"
	desc = ""
	icon_state = "flatgun"

/obj/item/gun/ballistic/automatic/pistol/stickman/pickup(mob/living/user)
	SHOULD_CALL_PARENT(0)
	to_chat(user, "<span class='notice'>As you try to pick up [src], it slips out of your grip..</span>")
	if(prob(50))
		to_chat(user, "<span class='notice'>..and vanishes from your vision! Where the hell did it go?</span>")
		qdel(src)
		user.update_icons()
	else
		to_chat(user, "<span class='notice'>..and falls into view. Whew, that was a close one.</span>")
		user.dropItemToGround(src)


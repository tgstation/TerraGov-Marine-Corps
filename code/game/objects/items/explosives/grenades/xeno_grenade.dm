/obj/item/explosive/grenade/sticky/xeno
	name = "slime grenade"
	desc = "A fleshy mass oozing acid. It appears to be rapidly decomposing."
	greyscale_colors = "#42A500"
	greyscale_config = /datum/greyscale_config/xenogrenade
	arm_sound = 'sound/voice/alien/yell_alt.ogg'
	worn_icon_state = null
	worn_icon_list = null

/obj/item/explosive/grenade/sticky/xeno/update_overlays()
	. = ..()
	if(active)
		. += image('icons/obj/items/grenade.dmi', "xenonade_active")

/obj/item/explosive/grenade/sticky/xeno/give_component()
	AddComponent(/datum/component/sticky_item/move_behaviour, icon, initial(icon_state) + "_stuck")

/// Lets xenomorphs pick up this type of grenade.
/obj/item/explosive/grenade/sticky/xeno/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE
	attack_hand(xeno_attacker)

/obj/item/explosive/grenade/sticky/xeno/resin
	desc = "A fleshy mass oozing resin. It appears to be rapidly decomposing."
	greyscale_colors = "#a200ff"

/obj/item/explosive/grenade/sticky/xeno/resin/prime()
	for(var/turf/sticky_tile AS in RANGE_TURFS(1, loc))
		if(!locate(/obj/alien/resin/sticky/thin) in sticky_tile.contents)
			new /obj/alien/resin/sticky/thin(sticky_tile)
	playsound(loc, SFX_ALIEN_RESIN_MOVE, 35)
	qdel(src)

/obj/item/explosive/grenade/sticky/xeno/resin/stuck_to(atom/hit_atom)
	. = ..()
	if(!locate(/obj/alien/resin/sticky/thin) in loc.contents)
		new /obj/alien/resin/sticky/thin(get_turf(src))

/obj/item/explosive/grenade/sticky/xeno/resin/on_move_sticky()
	if(!locate(/obj/alien/resin/sticky/thin) in loc.contents)
		new /obj/alien/resin/sticky/thin(get_turf(src))

/obj/item/explosive/grenade/sticky/xeno/acid
	self_sticky = TRUE
	/// The amount of deciseconds that the acid lasts.
	var/acid_duration = 5 SECONDS
	/// The amount of damage that the acid does.
	var/acid_damage = 15

/obj/item/explosive/grenade/sticky/xeno/acid/prime()
	for(var/turf/acid_tile AS in RANGE_TURFS(1, loc))
		xenomorph_spray(acid_tile, acid_duration, acid_damage, null, TRUE)
	playsound(loc, SFX_ACID_BOUNCE, 35)
	qdel(src)

/obj/item/explosive/grenade/sticky/xeno/acid/stuck_to(atom/hit_atom)
	. = ..()
	xenomorph_spray(get_turf(src), acid_duration, acid_damage)

/obj/item/explosive/grenade/sticky/xeno/acid/on_move_sticky()
	xenomorph_spray(get_turf(src), acid_duration, acid_damage)

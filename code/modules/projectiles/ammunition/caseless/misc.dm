/obj/item/ammo_casing/caseless/laser
	name = "laser casing"
	desc = ""
	caliber = "laser"
	icon_state = "s-casing-live"
	projectile_type = /obj/projectile/beam
	fire_sound = 'sound/blank.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy

/obj/item/ammo_casing/caseless/laser/gatling
	projectile_type = /obj/projectile/beam/weak/penetrator
	variance = 0.8
	click_cooldown_override = 1

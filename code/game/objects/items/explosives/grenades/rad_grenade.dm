/obj/item/explosive/grenade/rad
	name = "\improper V-40 rad grenade"
	desc = "Rad grenades release an extremely potent but short lived burst of radiation, debilitating organic life and frying electronics in a moderate radius. After the initial detonation, the radioactive effects linger for a time. Handle with extreme care."
	icon_state = "grenade_rad"
	worn_icon_state = "grenade_rad"
	icon_state_mini = "grenade_red"
	hud_state = "grenade_he"
	///The range for the grenade's full effect
	var/inner_range = 4
	///The range range for the grenade's weak effect
	var/outer_range = 7
	///The potency of the grenade
	var/rad_strength = 16

/obj/item/explosive/grenade/rad/prime()
	var/turf/impact_turf = get_turf(src)

	playsound(impact_turf, 'sound/effects/portal_opening.ogg', 50, 1)
	for(var/mob/living/victim in hearers(outer_range, src))
		var/strength
		var/sound_level
		if(get_dist(victim, impact_turf) <= inner_range)
			strength = rad_strength
			sound_level = 3
		else
			strength = rad_strength * 0.6
			sound_level = 2

		strength = victim.modify_by_armor(strength, BIO, 25)
		victim.apply_radiation(strength, sound_level)
	qdel(src)

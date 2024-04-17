/mob/living/regenerate_icons()
	if(notransform)
		return 1
	update_inv_hands()
	update_inv_handcuffed()
	update_inv_legcuffed()

/mob/living/update_fire(fire_icon = "Generic_mob_burning")
	remove_overlay(FIRE_LAYER)
	if(on_fire || islava(loc))
		var/mutable_appearance/new_fire_overlay = mutable_appearance('icons/mob/OnFire.dmi', fire_icon, -FIRE_LAYER)
		new_fire_overlay.appearance_flags = RESET_COLOR
		overlays_standing[FIRE_LAYER] = new_fire_overlay

	apply_overlay(FIRE_LAYER)

/mob/living/proc/update_turflayer(input)
	return

/mob/living/update_turflayer(input)
	return
	remove_overlay(TURF_LAYER)

	if(input)
		var/mutable_appearance/new_fire_overlay = mutable_appearance('icons/turf/mob_overlay.dmi', input, -TURF_LAYER)
		new_fire_overlay.appearance_flags = RESET_COLOR
		overlays_standing[TURF_LAYER] = new_fire_overlay

	apply_overlay(TURF_LAYER)
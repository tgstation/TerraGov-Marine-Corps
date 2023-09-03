/obj/machinery/atmospherics/components/unary/vent_scrubber/attack_facehugger(mob/living/carbon/xenomorph/facehugger/F, damage_amount = F.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(F.status_flags & INCORPOREAL)
		return
	if(!welded || !(do_after(F, 3 SECONDS, FALSE, src, BUSY_ICON_HOSTILE)))
		return
	F.visible_message("[F] furiously claws at [src]!", "We manage to clear away the stuff blocking the scrubber.", "You hear loud scraping noises.")
	welded = FALSE
	update_icon()
	pipe_vision_img = image(src, loc, layer = ABOVE_HUD_LAYER, dir = dir)
	pipe_vision_img.plane = ABOVE_HUD_PLANE
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, 1)

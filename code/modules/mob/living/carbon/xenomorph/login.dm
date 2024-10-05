/mob/living/carbon/xenomorph/Login()
	. = ..()

	if(lighting_alpha == LIGHTING_PLANE_ALPHA_NV_TRAIT)
		ENABLE_BITFIELD(sight, SEE_MOBS)
		ENABLE_BITFIELD(sight, SEE_OBJS)
		ENABLE_BITFIELD(sight, SEE_TURFS)
		update_sight()

	if(client.prefs?.xeno_name != "Undefined" && !is_banned_from(ckey, "Appearance"))
		nicknumber = client.prefs.xeno_name
	else
		//Reset the nicknumber, otherwise we could keep the old minds custom name/random number
		nicknumber = 0
		generate_nicknumber()

	if(client.prefs?.xeno_desc)
		xeno_desc = client.prefs.xeno_desc
	if(client.prefs?.xenoprofile_pic)
		xenoprofile_pic = client.prefs.xenoprofile_pic

	hud_update_rank()
	generate_name()

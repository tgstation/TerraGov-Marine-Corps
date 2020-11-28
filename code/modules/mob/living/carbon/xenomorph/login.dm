/mob/living/carbon/xenomorph/Login()
	. = ..()

	hive.on_xeno_login(src)

	if(lighting_alpha == LIGHTING_PLANE_ALPHA_NV_TRAIT)
		ENABLE_BITFIELD(sight, SEE_MOBS)
		ENABLE_BITFIELD(sight, SEE_OBJS)
		ENABLE_BITFIELD(sight, SEE_TURFS)
		update_sight()

	if(client.prefs?.xeno_name != "Undefined")
		nicknumber = client.prefs.xeno_name
	else
		//Reset the nicknumber, otherwise we could keep the old minds custom name/random number
		nicknumber = 0
		generate_nicknumber()

	generate_name()

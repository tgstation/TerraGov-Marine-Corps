/datum/unit_test/spawn_gun/Run()
	for(var/gun_to_test in subtypesof(/obj/item/weapon/gun))
		var/obj/item/weapon/gun/gun = allocate(gun_to_test, TRUE)
		for(var/attachment_type in gun.starting_attachment_types)
			if(!(attachment_type in gun.attachable_allowed))
				Fail("[attachment_type] is specified as a starting attachment, however it is not an allowed attachment. Called from [gun].")
		if(!CHECK_BITFIELD(gun.reciever_flags, AMMO_RECIEVER_HANDFULS) && gun.default_ammo_type && !(gun.default_ammo_type in gun.allowed_ammo_types))
			Fail("[gun] has a specified default_ammo_type that is not present in the allowed_ammo_types.")
		if(CHECK_BITFIELD(gun.reciever_flags, AMMO_RECIEVER_MAGAZINES))
			for(var/allowed_ammo_type in gun.allowed_ammo_types)
				var/obj/item/ammo = allocate(allowed_ammo_type)
				var/test_var
				if(gun.current_rounds_var)
					test_var = ammo.vars[gun.current_rounds_var]
				if(gun.max_rounds_var)
					test_var = ammo.vars[gun.max_rounds_var]
				if(gun.magazine_flags_var)
					test_var = ammo.vars[gun.magazine_flags_var]
				if(gun.ammo_type_var)
					test_var = ammo.vars[gun.ammo_type_var]
				if(gun.reload_delay_var)
					test_var = ammo.vars[gun.reload_delay_var]
				if(gun.magazine_overlay_var)
					test_var = ammo.vars[gun.magazine_overlay_var]

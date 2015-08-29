/mob/living/carbon/Xenomorph/emote(var/act,var/m_type=1,var/message = null)
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		act = copytext(act, 1, t1)

	// if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
	// 	act = copytext(act,1,length(act))
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)

	switch(act)
		if ("me")
			if(silent)
				return
			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					src << "\red You cannot send IC messages (muted)."
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if ("custom")
			return custom_emote(m_type, message)
		if("roar")
			if (!muzzled)
				m_type = 2
				message = "<B>The [src.name]</B> roars!"
				if(!adjust_pixel_x)
					playsound(src.loc, 'sound/voice/alien_roar_small.ogg', 100, 1, 1)
				else
					playsound(src.loc, 'sound/voice/alien_roar_large.ogg', 100, 1, 1)
		if("growl")
			if (!muzzled)
				m_type = 2
				message = "<B>The [src.name]</B> growls."
				if(!adjust_pixel_x)
					playsound(src.loc, 'sound/voice/alien_growl_small.ogg', 30, 1, 1)
				else
					playsound(src.loc, 'sound/voice/alien_growl_large.ogg', 30, 1, 1)
		if("hiss")
			if (!muzzled)
				m_type = 2
				message = "<B>The [src.name]</B> hisses."
				if(!adjust_pixel_x)
					playsound(src.loc, 'sound/voice/alien_hiss_small.ogg', 100, 1, 1)
				else
					playsound(src.loc, 'sound/voice/alien_hiss_large.ogg', 100, 1, 1)
		if("tail")
			if (!muzzled)
				m_type = 2
				message = "<B>The [src.name]</B> lashes its tail."
				playsound(src.loc, 'sound/voice/alien_tail.ogg', 100, 1, 1)
		if("dance")
			if (!src.restrained())
				message = "<B>The [src.name]</B> dances around!"
				m_type = 1
				spawn(0)
					for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
						dir = i
						sleep(1)
		if("help")
			src << "Available emotes: *roar, *growl, *hiss, *tail, *dance"
		else
			src << text("Invalid Emote: []", act)
	if ((message && src.stat == 0))
		log_emote("[name]/[key] : [message]")
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return
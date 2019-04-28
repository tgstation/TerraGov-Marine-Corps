/mob/Logout()
	SSnano.user_logout(src) // this is used to clean up (remove) this user's Nano UIs
	if(interactee) 
		unset_interaction()
	GLOB.player_list -= src
	log_access("Logout: [key_name(src)]")
	log_message("[key_name(src)] has logged out.", LOG_OOC)
	if(s_active)
		s_active.hide_from(src)
	if(client)
		for(var/foo in client.player_details.post_logout_callbacks)
			var/datum/callback/CB = foo
			CB.Invoke()
	return ..()
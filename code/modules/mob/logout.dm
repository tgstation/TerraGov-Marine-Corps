/mob/Logout()
	nanomanager.user_logout(src) // this is used to clean up (remove) this user's Nano UIs
	if(interactee) unset_interaction()
	GLOB.player_list -= src
	log_access("Logout: [key_name(src)]")
	if(s_active)
		s_active.hide_from(src)
	..()
	return 1

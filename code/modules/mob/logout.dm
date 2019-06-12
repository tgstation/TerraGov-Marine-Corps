/mob/Logout()
	SSnano.user_logout(src) // this is used to clean up (remove) this user's Nano UIs
	if(interactee) 
		unset_interaction()	
	if(typing)
		remove_emote_overlay(null, typing, viewers())
		typing = null
	GLOB.player_list -= src
	log_message("[key_name(src)] has left mob [src]([type]).", LOG_OOC)
	if(s_active)
		s_active.hide_from(src)
	if(client)
		for(var/foo in client.player_details.post_logout_callbacks)
			var/datum/callback/CB = foo
			CB.Invoke()
	return ..()

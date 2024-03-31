#ifdef TESTING
/mob/living/carbon/key_down(_key, client/user)
	switch(_key)
		if("B")
			client.set_context_menu_enabled(1)
	return ..()
#endif
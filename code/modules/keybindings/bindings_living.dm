/mob/living/key_down(_key, client/user, action)
	switch(action)
		if("resist")
			resist()
			return

	return ..()
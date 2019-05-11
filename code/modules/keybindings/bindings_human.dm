/mob/living/carbon/human/key_down(_key, client/user, action)
	switch(action)
		if("quick-equip")
			quick_equip()
			return
		if("holster")
			holster()
			return
		if("unique-action")
			unique_action()
			return

	return ..()
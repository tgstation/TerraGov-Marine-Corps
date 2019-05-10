/mob/living/carbon/human/key_down(_key, client/user)
	switch(_key)
		if("E")
			quick_equip()
			return
		if("H")
			holster()
			return
		if("Space")
			unique_action()
			return

	return ..()
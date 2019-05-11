/mob/living/carbon/key_down(_key, client/user, action)
	switch(action)
		if("toggle-throw-mode") // Southwest is End
			toggle_throw_mode()
			return
		if("select-intent-help")
			a_intent_change(INTENT_HELP)
			return
		if("select-intent-disarm")
			a_intent_change(INTENT_DISARM)
			return
		if("select-intent-grab")
			a_intent_change(INTENT_GRAB)
			return
		if("select-intent-harm")
			a_intent_change(INTENT_HARM)
			return
	return ..()
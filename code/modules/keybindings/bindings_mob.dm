// Technically the client argument is unncessary here since that SHOULD be src.client but let's not assume things
// All it takes is one badmin setting their focus to someone else's client to mess things up
// Or we can have NPC's send actual keypresses and detect that by seeing no client
/mob/key_down(_key, client/user, action)

	switch(action)
		if("stop-pulling")
			if(!pulling)
				to_chat(src, "<span class='notice'>You are not pulling anything.</span>")
			else
				stop_pulling()
			return
		if("intent-right")
			a_intent_change(INTENT_HOTKEY_RIGHT)
			return
		if("intent-left")
			a_intent_change(INTENT_HOTKEY_LEFT)
			return
		if("swap-hands") // Northeast is Page-up
			user.swap_hand()
			return
		if("attack-self")	// Southeast is Page-down
			mode()					// attack_self(). No idea who came up with "mode()"
			return
		if("drop-item") // Northwest is Home
			var/obj/item/I = get_active_held_item()
			if(!I)
				to_chat(src, "<span class='warning'>You have nothing to drop in your hand!</span>")
			else
				dropItemToGround(I)
			return
		if("toggle-move-intent")
			toggle_move_intent()
			return
		//Bodypart selections
		if("select-body-toggle_head")
			user.body_toggle_head()
			return
		if("select-body-r_arm")
			user.body_r_arm()
			return
		if("select-body-chest")
			user.body_chest()
			return
		if("select-body-l_arm")
			user.body_l_arm()
			return
		if("select-body-r_leg")
			user.body_r_leg()
			return
		if("select-body-groin")
			user.body_groin()
			return
		if("select-body-l_leg")
			user.body_l_leg()
			return

	if(client.keys_held["Shift"])
		switch(SSinput.movement_keys[_key])
			if(NORTH)
				northface()
				return
			if(SOUTH)
				southface()
				return
			if(WEST)
				westface()
				return
			if(EAST)
				eastface()
				return
	return ..()


/mob/key_up(_key, client/user, action)
	switch(action)
		if("toggle-move-intent")
			toggle_move_intent()
			return
	return ..()
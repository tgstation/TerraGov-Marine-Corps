/mob
	var/hud_typing = FALSE //set when typing in an input window instead of chatline
	var/typing
	var/last_typed
	var/last_typed_time

	var/static/mutable_appearance/typing_indicator

/mob/proc/set_typing_indicator(var/state, hudt)
	if(!typing_indicator)
		typing_indicator = mutable_appearance('icons/mob/talk.dmi', "default0", FLY_LAYER)
		typing_indicator.alpha = 175

	if(state)
		if(!typing)
			if(hudt)
				hud_typing = TRUE
			add_overlay(typing_indicator)
			typing = TRUE
			update_vision_cone()
		if(hudt)
			hud_typing = TRUE
	else
		if(typing)
			cut_overlay(typing_indicator)
			typing = FALSE
			hud_typing = FALSE
			update_vision_cone()
	return state

/mob/living/key_down(_key, client/user)
	if(stat == CONSCIOUS)
//		var/list/binds = user.prefs?.key_bindings[_key]
//		if(binds)
/*			if("Say" in binds)
				set_typing_indicator(TRUE, TRUE)
			if("Me" in binds)
				set_typing_indicator(TRUE, TRUE)*/
		if(_key == "T")
			set_typing_indicator(TRUE, TRUE)
		if(_key == "M")
			set_typing_indicator(TRUE, TRUE)
	return ..()

/mob/proc/handle_typing_indicator()
	if(!client || stat)
		set_typing_indicator(FALSE)
		return

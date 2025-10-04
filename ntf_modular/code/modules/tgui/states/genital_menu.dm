GLOBAL_DATUM_INIT(genital_menu_state, /datum/ui_state/genital_menu, new)

/datum/ui_state/genital_menu/can_use_topic(src_object, mob/user)
	. = UI_CLOSE
	if(check_rights_for(user.client, R_ADMIN))
		. = UI_INTERACTIVE
	else if(istype(src_object, /datum/genital_menu))
		var/datum/genital_menu/GM = src_object
		if(GM.human == user)
			. = UI_INTERACTIVE

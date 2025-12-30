ADMIN_VERB(toggle_war_mode, R_ADMIN, "Toggle War Mode", "Toggles pop locks etc, use when war is happening.", ADMIN_CATEGORY_MAIN)
	if(istype(SSticker.mode, /datum/game_mode/infestation/extended_plus/secret_of_life))
		var/datum/game_mode/infestation/extended_plus/secret_of_life/gaymode = SSticker.mode
		gaymode.toggle_pop_locks()
	else
		to_chat(usr, span_notice("Need to be in SOL mode to toggle war mode."))


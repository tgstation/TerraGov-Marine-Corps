/mob/proc/can_use_codex()
	return TRUE
/*

Set the above can_use_codex() return FALSE if you want to limit codex use.

/mob/new_player/can_use_codex()
	return TRUE

/mob/living/silicon/can_use_codex()
	return TRUE

/mob/observer/can_use_codex()
	return TRUE

/mob/living/carbon/human/can_use_codex()
	return TRUE //has_implant(/obj/item/implant/codex, functioning = TRUE)
*/

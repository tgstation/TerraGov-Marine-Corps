/// for chair handcuffs
/mob/living/carbon/proc/update_abstract_handcuffed()
	if(handcuffed)
		drop_all_held_items()
		stop_pulling()
		update_handcuffed(handcuffed)

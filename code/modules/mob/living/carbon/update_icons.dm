
/mob/living/carbon/proc/apply_overlay(cache_index)
	return

/mob/living/carbon/proc/remove_overlay(cache_index)
	return

/mob/living/carbon/update_transform()
	if(lying != lying_prev )
		lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
		update_icons()
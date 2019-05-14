/datum/keybinding/human
    category = CATEGORY_HUMAN
    weight = WEIGHT_MOB



    /*Human*/
    /*/mob/living/carbon/human/down(_key, client/user, action)
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
    */




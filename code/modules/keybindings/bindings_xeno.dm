/mob/living/carbon/Xenomorph/key_down(_key, client/user, action)
	switch(action)
		if("drop-weeds")
			var/datum/action/xeno_action/plant_weeds/ability = locate() in actions
			if (!ability)
				to_chat(user, "<span class='notice'>You don't have this ability.</span>") // TODO Is this spammy?
				return

			if(ability.can_use_action(FALSE, null, TRUE))
				ability.action_activate()
			else
				ability.fail_activate()
			return

	return ..()
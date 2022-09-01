/mob/var/suiciding = 0

/mob/living/carbon/human/verb/suicide()
	set hidden = 1

	if (stat == DEAD)
		to_chat(src, "You're already dead!")
		return

	if (!SSticker)
		to_chat(src, "You can't commit suicide before the game starts!")
		return

	if (suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = tgui_alert(usr, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))

	if(confirm == "Yes")
		if(!canmove || restrained())	//just while I finish up the new 'fun' suiciding verb. This is to prevent metagaming via suicide
			to_chat(src, "You can't commit suicide whilst restrained! ((You can type Ghost instead however.))")
			return
		var/obj/item/held_item = get_active_held_item()
		if(held_item)
			var/damagetype = held_item.suicide_act(src)
			if(!damagetype)	//Check if the item has suicide_act, because doing this as a separate check makes it run twice resulting in 2 suicide messages
				to_chat(src, span_notice("You're going to have to do it the old fashioned way."))
			else
				suiciding = TRUE
				var/damage_mod = 1
				switch(damagetype) //Sorry about the magic numbers.
								//brute = 1, burn = 2, tox = 4, oxy = 8
					if(15) //4 damage types
						damage_mod = 4

					if(6, 11, 13, 14) //3 damage types
						damage_mod = 3

					if(3, 5, 7, 9, 10, 12) //2 damage types
						damage_mod = 2

					if(1, 2, 4, 8) //1 damage type
						damage_mod = 1

					else //This should not happen, but if it does, everything should still work
						damage_mod = 1

				//Do 175 damage divided by the number of damage types applied.
				if(damagetype & BRUTELOSS)
					adjustBruteLoss(30/damage_mod)	//hack to prevent gibbing
					adjustOxyLoss(145/damage_mod)

				if(damagetype & FIRELOSS)
					adjustFireLoss(175/damage_mod)

				if(damagetype & TOXLOSS)
					adjustToxLoss(175/damage_mod)

				if(damagetype & OXYLOSS)
					adjustOxyLoss(175/damage_mod)

				//If something went wrong, just do normal oxyloss
				if(!(damagetype|BRUTELOSS) && !(damagetype|FIRELOSS) && !(damagetype|TOXLOSS) && !(damagetype|OXYLOSS))
					adjustOxyLoss(max(175 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))

				updatehealth()

				suiciding = FALSE	//Should have been set to FALSE because if you were revived or healed, you could not suicide again
		else	//What happens if you have no item
			to_chat(src, span_notice("What are you going to do? Hold your breath?"))

/mob/living/brain/verb/suicide()
	set hidden = 1

	if (stat == 2)
		to_chat(src, "You're already dead!")
		return

	if (!SSticker)
		to_chat(src, "You can't commit suicide before the game starts!")
		return

	if (suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = tgui_alert(usr, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))

	if(confirm == "Yes")
		suiciding = 1
		viewers(loc) << span_danger("[src]'s brain is growing dull and lifeless. It looks like it's lost the will to live.")
		spawn(50)
			death()
			suiciding = 0


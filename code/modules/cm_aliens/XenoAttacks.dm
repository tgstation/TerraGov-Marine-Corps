//There has to be a better way to define this shit. ~ Z
//can't equip anything
/mob/living/carbon/Xenomorph/attack_ui(slot_id)
	return

/mob/living/carbon/Xenomorph/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		adjustBruteLoss((istype(O, /obj/effect/meteor/small) ? 10 : 25))
		adjustFireLoss(30)

		updatehealth()
	return

/mob/living/carbon/Xenomorph/attack_animal(mob/living/M as mob)

	if(istype(M,/mob/living/simple_animal))
		var/mob/living/simple_animal/S = M
		if(S.melee_damage_upper == 0)
			S.emote("[S.friendly] [src]")
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <B>[S]</B> [S.attacktext] [src]!", 1)
			var/damage = rand(S.melee_damage_lower, S.melee_damage_upper)
			adjustBruteLoss(damage)
			S.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [S.name] ([S.ckey])</font>")
			updatehealth()

/mob/living/carbon/Xenomorph/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!(istype(M, /mob/living/carbon/monkey)))	return//Fix for aliens receiving double messages when attacking other aliens.

	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return
	..()

	switch(M.a_intent)

		if ("help")
			help_shake_act(M)
		else
			if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
				return
			if (health > 0)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has bit [src]!</B>"), 1)
				adjustBruteLoss(rand(1, 3))
				updatehealth()
	return


/mob/living/carbon/Xenomorph/attack_slime(mob/living/carbon/slime/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if(M.Victim) return // can't attack while eating!

	if (health > -100)

		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>The [M.name] glomps []!</B>", src), 1)

		var/damage = rand(1, 3)

		if(M.is_adult)
			damage = rand(20, 40)
		else
			damage = rand(5, 35)

		adjustBruteLoss(damage)


		updatehealth()

	return

/mob/living/carbon/Xenomorph/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	..()
	M.next_move += 7 //Adds some lag to the 'attack'. This will add up to 10
	switch(M.a_intent)

		if ("help")
			if(src.stat == DEAD)
				M << "You poke [src] but nothing happens."
			else
				M << "You poke [src]."
				src << "[M] pokes you."

		if ("grab")
			if (M == src || src.anchored)
				return

			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M, src )

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

		else
			var/damage = rand(1, 2)
			if (prob(90))
				if (HULK in M.mutations)
					damage += 5
					spawn(0)
						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)
				playsound(loc, "punch", 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
	return

//Hot hot Aliens on Aliens action.
//Actually just used for eating people.
/mob/living/carbon/Xenomorph/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(src != M)
		if(istype(M,/mob/living/carbon/Xenomorph/Larva))
			visible_message("\red <B>[M] nudges its head against [src].</B>")
			return 0

		switch(M.a_intent)
			if ("help")
				visible_message(text("\blue [M] caresses [src] with its scythe like arm."))

			if ("grab")
				if(M == src || anchored)
					return

				if(Adjacent(M)) //Logic!
					M.start_pulling(src)
					update_icons(M) //To immediately show the grab
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message(text("\red \The [] has grabbed []!", M, src), "\red You grab [M]!")

			if("hurt")//Can't slash other xenos for now. SORRY
				if(istype(src,/mob/living/carbon/Xenomorph))
					visible_message("\red \The [M] nibbles at [src].")
					return
				var/damage = rand(5,20) //Who cares, it's just Ian and the Monkeys (that would make a great band name)
				visible_message("\red \The [M] bites at \the [src]!")
				apply_damage(damage, BRUTE)

			if("disarm")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1, -1)
				visible_message(text("\red [] shoves [].", M, src))
				if(ismonkey(src))
					src.Weaken(8)
		return
	//Clicked on self.
	if(pulling)
		var/mob/living/carbon/pulled = pulling
		if(!istype(pulled)) return
		if(istype(pulled,/mob/living/carbon/Xenomorph))
			src << "Nice try! That wouldn't taste very good."
			return
		src.visible_message("\red <B>[src] starts to devour [pulled]!</b>","\red <b>You start to devour [pulled]!</b>")
		if(do_after(src,50))
			src.visible_message("\red [src] devours [pulled]!","\red You devour [pulled]!")
			src.stop_pulling()
			pulled.loc = src
			src.stomach_contents.Add(pulled)
		else
			src << "You stop devouring. [pulled] probably tastes gross anyway."
			return
//There has to be a better way to define this shit. ~ Z
//can't equip anything
/mob/living/carbon/Xenomorph/attack_ui(slot_id)
	return

/mob/living/carbon/Xenomorph/meteorhit(O as obj)
	visible_message("<span class='warning'>\The [src] is hit by \the [O].</span>", \
	"<span class='warning'>You are hit by \the [O].</span>")
	if(health > 0)
		adjustBruteLoss((istype(O, /obj/effect/meteor/small) ? 10 : 25))
		adjustFireLoss(30)
		updatehealth()

/mob/living/carbon/Xenomorph/attack_animal(mob/living/M as mob)

	if(isanimal(M))
		var/mob/living/simple_animal/S = M
		if(!S.melee_damage_upper)
			S.emote("[S.friendly] [src]")
		else
			visible_message("<span class='danger'>[S] [S.attacktext] [src]!</span>")
			var/damage = rand(S.melee_damage_lower, S.melee_damage_upper)
			adjustBruteLoss(damage)
			S.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
			attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [S.name] ([S.ckey])</font>")
			updatehealth()

/mob/living/carbon/Xenomorph/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!ismonkey(M)) //Fix for aliens receiving double messages when attacking other aliens
		return 0

	..()

	switch(M.a_intent)

		if("help")
			help_shake_act(M)
		else
			if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
				return 0
			if(health > 0)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				visible_message("<span class='danger'>\The [M] bites \the [src].</span>", \
				"<span class='danger'>You are bit by \the [M].</span>")
				adjustBruteLoss(rand(1, 3))
				updatehealth()

/mob/living/carbon/Xenomorph/attack_slime(mob/living/carbon/slime/M as mob)

	if(M.Victim) //Can't attack while eating!
		return 0

	if(health > -100)

		visible_message("<span class='danger'>\The [M] glomps \the [src].</span>", \
		"<span class='danger'>You are glomped by \the [M].</span>")

		var/damage = rand(1, 3)

		if(M.is_adult)
			damage = rand(20, 40)
		else
			damage = rand(5, 35)

		adjustBruteLoss(damage)
		updatehealth()

/mob/living/carbon/Xenomorph/attack_hand(mob/living/carbon/human/M)

	..()
	M.next_move += 7 //Adds some lag to the 'attack'. This will add up to 10
	switch(M.a_intent)

		if("help")
			if(stat == DEAD)
				M.visible_message("<span class='warning'>\The [M] pokes \the [src], but nothing happens.</span>", \
				"<span class='warning'>You poke \the [src], but nothing happens.</span>")
			else
				M.visible_message("<span class='warning'>\The [M] pokes \the [src].</span>", \
				"<span class='warning'>You poke \the [src].</span>")

		if("grab")
			if(M == src || anchored)
				return 0

			if(!isXenoLarva(src))
				if(stat != DEAD && has_species(M, "Human")) //If the Xeno is alive, fight back against a grab/pull
					M.Weaken(rand(tacklemin, tacklemax))
					playsound(M.loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
					visible_message("<span class='danger'>\The [M] receives a vicious tail swipe to the head as \he tries to grab \the [src]!</span>", \
					"<span class='danger'>You receive a vicious tail swipe to the head as you try to grab \the [src]!</span>")
					return 1

			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)
			M.put_in_active_hand(G)
			grabbed_by += G
			G.synch()
			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			M.visible_message("<span class='warning'>\The [M] has grabbed \the [src] passively!</span>", \
			"<span class='warning'>You grab \the [src] passively!</span>")

		else
			var/datum/unarmed_attack/attack = M.species.unarmed
			if(!attack.is_usable(M)) attack = M.species.secondary_unarmed
			if(!attack.is_usable(M))
				return 0

			var/damage = rand(1, 3)
			if(prob(85))
				if(HULK in M.mutations)
					damage += 5
					spawn(0)
						step_away(src, M, 15)
						sleep(3)
						step_away(src, M, 15)
				damage += attack.damage > 5 ? attack.damage : 0

				playsound(loc, attack.attack_sound, 25, 1, -1)
				visible_message("<span class='danger'>[M] [pick(attack.attack_verb)]ed [src]!</span>")
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, attack.miss_sound, 25, 1, -1)
				visible_message("<span class='danger'>[M] tried to [pick(attack.attack_verb)] [src]!</span>")

	return

//Hot hot Aliens on Aliens action.
//Actually just used for eating people.
/mob/living/carbon/Xenomorph/attack_alien(mob/living/carbon/Xenomorph/M)
	if(src != M)
		if(isXenoLarva(M)) //Larvas can't eat people
			M.visible_message("<span class='danger'>[M] nudges its head against \the [src].</span>", \
			"<span class='danger'>You nudge your head against \the [src].</span>")
			return 0

		switch(M.a_intent)
			if("help")
				M.visible_message("<span class='notice'>\The [M] caresses \the [src] with its scythe-like arm.</span>", \
				"<span class='notice'>You caress \the [src] with your scythe-like arm.</span>")

			if("grab")
				if(M == src || anchored)
					return 0

				if(Adjacent(M)) //Logic!
					M.start_pulling(src)
					M.update_icons() //To immediately show the grab

					M.visible_message("<span class='warning'>[M] grabs \the [src]!</span>", \
					"<span class='warning'>You grab \the [src]!</span>")
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

			if("hurt")//Can't slash other xenos for now. SORRY
				if(isXeno(src)) //Can't slash other xenos for now
					M.visible_message("<span class='warning'>\The [M] nibbles \the [src].</span>", \
					"<span class='warning'>You nibble \the [src].</span>")
					return 1
				var/damage = (rand(M.melee_damage_lower, M.melee_damage_upper) + 3)
				M.visible_message("<span class='danger'>\The [M] bites \the [src]!</span>", \
				"<span class='danger'>You bite \the [src]!</span>")
				apply_damage(damage, BRUTE)

			if("disarm")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				M.visible_message("<span class='warning'>\The [M] shoves \the [src]!</span>", \
				"<span class='warning'>You shove \the [src]!</span>")
				if(ismonkey(src))
					Weaken(8)
		return 1

	//Clicked on self.
	if(pulling)
		var/mob/living/carbon/pulled = pulling
		if(!istype(pulled))
			return
		if(isXeno(pulled))
			src << "<span class='warning'>That wouldn't taste very good.</span>"
			return 0
		if(pulled.stat == DEAD)
			src << "<span class='warning'>Ew, \the [pulled] is already starting to rot.</span>"
			return 0
			/* Saving this in case we want to allow devouring of dead bodies UNLESS their client is still online somewhere
			if(pulled.client) //The client is still inside the body
			else // The client is observing
				for(var/mob/dead/observer/G in player_list)
					if(ckey(G.mind.original.ckey) == pulled.ckey)
						src << "You start to devour [pulled] but realize \he is already dead."
						return */
		visible_message("<span class='danger'>\The [src] starts to devour \the [pulled]!</span>", \
		"<span class='danger'>You start to devour \the [pulled]!</span>")
		if(do_after(src, 50))
			visible_message("<span class='warning'>\The [src] devours \the [pulled]!</span>", \
			"<span class='warning'>You devour \the [pulled]!</span>")
			stop_pulling()

			//IMPORTANT CODER NOTE: Due to us using the old lighting engine, we need to hacky hack hard to get this working properly
			//So we're just going to get the lights out of here by forceMoving them to a far-away place
			//They will be recovered when regurgitating, since this also calls forceMove
			pulled.x = 1
			pulled.y = 1
			pulled.z = 2 //Centcomm
			pulled.forceMove(pulled.loc)

			//Then, we place the mob where it ought to be
			pulled.forceMove(src)
			src.stomach_contents.Add(pulled)
		else
			src << "<span class='warning'>You stop devouring \the [pulled]. \He probably tasted gross anyways.</span>"
			return 0

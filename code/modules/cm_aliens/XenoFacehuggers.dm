//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//TODO: Make these simple_animals

var/const/MIN_IMPREGNATION_TIME = 300 //time it takes to impregnate someone
var/const/MAX_IMPREGNATION_TIME = 450

var/const/MIN_ACTIVE_TIME = 150 //time between being dropped and going idle
var/const/MAX_ACTIVE_TIME = 200

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = 1 //note: can be picked up by aliens unlike most other items of w_class below 4
	flags = FPRINT | TABLEPASS | MASKCOVERSMOUTH | MASKCOVERSEYES | MASKINTERNALS
	body_parts_covered = FACE|EYES
	throw_range = 1

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case
	var/sterile = 0
	var/strength = 5
	var/attached = 0

	ex_act(severity)
		Die()
		return

	Del()
		if(istype(src.loc,/mob/living/carbon))
			var/mob/living/carbon/M = src.loc
			M.drop_from_inventory(src)
		return ..()

	dropped()
		spawn(2)
			var/obj/item/clothing/mask/facehugger/F
			var/count = 0
			for(F in get_turf(src))
				if(F.stat == CONSCIOUS) count++
			if(count > 5)
				src.visible_message("\red The facehugger is furiously cannibalized by the nearby horde of other ones!")
				del(src)
				return


/obj/item/clothing/mask/facehugger/attack_paw(user as mob) //can be picked up by aliens
	attack_hand(user)
	return

/obj/item/clothing/mask/facehugger/attack_hand(user as mob)
	if((stat == CONSCIOUS && !sterile))
		if(CanHug(user))
			Attach(user) //If we're conscious, don't let them pick us up even if this fails. Just return.
		return
	if(ishuman(user))
		if(stat == DEAD)
			return ..()
		else
			return //Can't pick up live ones.

	return ..()

//Deal with picking up facehuggers. "attack_alien" is the universal 'xenos click something while unarmed' proc.
/obj/item/clothing/mask/facehugger/attack_alien(mob/living/carbon/Xenomorph/user as mob)
	if(isXenoLarva(user)) return
	if(istype(user,/mob/living/carbon/Xenomorph/Carrier)) //Deal with carriers grabbing huggies
		var/mob/living/carbon/Xenomorph/Carrier/C = user
		if(C.huggers_cur < C.huggers_max)
			if(src.stat == CONSCIOUS)
				C.huggers_cur++
				user << "You scoop up the facehugger and carry it for safekeeping. Now sheltering: [C.huggers_cur] / [C.huggers_max]."
				del(src)
			else
				user << "That one looks unhealthy."
			return
	user.put_in_active_hand(src) //Not a carrier, or already full? Just pick it up.

/obj/item/clothing/mask/facehugger/attack(mob/M as mob, mob/user as mob)
	if(CanHug(M))
		Attach(M)
		user.update_icons()
	else
		user << "\red The facehugger refuses to attach."
		..()

/obj/item/clothing/mask/facehugger/examine()
	..()
	switch(stat)
		if(DEAD,UNCONSCIOUS)
			usr << "\red \b [src] is not moving."
		if(CONSCIOUS)
			usr << "\red \b [src] seems to be active."
	if (sterile)
		usr << "\red \b It looks like the proboscis has been removed."
	return

/obj/item/clothing/mask/facehugger/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/clothing/mask/facehugger))
		return
	Die()
	return

/obj/item/clothing/mask/facehugger/bullet_act()
	Die()
	return 1

/obj/item/clothing/mask/facehugger/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()
	return

/obj/item/clothing/mask/facehugger/equipped(mob/M)
	return

/obj/item/clothing/mask/facehugger/Crossed(atom/target)
	HasProximity(target)
	return

/obj/item/clothing/mask/facehugger/on_found(mob/finder as mob)
	if(stat == CONSCIOUS)
		HasProximity(finder)
		return 1
	return

/obj/item/clothing/mask/facehugger/HasProximity(atom/movable/AM as mob|obj)
	if(CanHug(AM))
		Attach(AM)

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]_thrown"
		spawn(15)
			if(icon_state == "[initial(icon_state)]_thrown")
				icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]"
		if(CanHug(hit_atom))
			Attach(hit_atom)
		throwing = 0

/obj/item/clothing/mask/facehugger/proc/Attach(M as mob)

	if((!iscorgi(M) && !iscarbon(M)))
		return 0

	if(attached)
		return 0

	if(istype(M,/mob/living))
		if(M:status_flags & XENO_HOST) return 0

	if(ishuman(M))
		if(!M:has_organ("head"))
			visible_message("\red [src] looks for a face to hug, but finds none!")
			return 0

	if(istype(M,/mob/living/carbon/Xenomorph))
		return 0

	attached++
	spawn(MAX_IMPREGNATION_TIME)
		attached = 0

	var/mob/living/L = M //just so I don't need to use :

	if(loc == L) return 0
	if(stat != CONSCIOUS)	return 0
//	if(!sterile) L.take_organ_damage(strength,0) //done here so that even borgs and humans in helmets take damage

	L.visible_message("\red \b [src] leaps at [L]'s face!")
	if(throwing)
		throwing = 0

	if(isYautja(M))
		var/mob/living/carbon/human/Y = M
		var/catch_chance = 50
		if(Y.dir == reverse_dir[src.dir]) catch_chance += 20
		if(Y.lying) catch_chance -= 50
		catch_chance -= ((Y.maxHealth - Y.health) / 3)
		if(!isnull(Y.get_active_hand())) catch_chance  -= 25
		if(!isnull(Y.get_inactive_hand())) catch_chance  -= 25

		if(!Y.stat && Y.dir != src.dir && prob(catch_chance)) //Not facing away
			Y.visible_message("\blue [Y] snatches \the [src.name] out of the air and squashes it!")
			src.Die()
			src.throwing = 0
			src.loc = Y.loc
			return 0

	if(istype(src.loc,/mob/living/carbon/Xenomorph)) //Being carried? Drop it
		var/mob/living/carbon/Xenomorph/X = src.loc
		X.drop_from_inventory(src)
		X.update_icons()

	if(isturf(L.loc))
		src.loc = L.loc //Just checkin

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.head && H.head.canremove)
			var/obj/item/clothing/head/D = H.head
			if(istype(D))
				if(D.anti_hug > 1)
					H.visible_message("\red \b [src] smashes against [H]'s [D] and bounces off!")
					D.anti_hug--
					if(rand(50))
						src.Die()
					else
						src.GoIdle()
					return 0
				else if(D.anti_hug == 1)
					H.visible_message("\red \b [src] smashes against [H]'s [D] and rips it off!")
					H.drop_from_inventory(D)
					if(istype(D,/obj/item/clothing/head/helmet/marine)) //Marine helmets now get a fancy overlay.
						D:add_hugger_damage() //We know this proc is okay.
					D.anti_hug--
					if(rand(50))
						src.GoIdle()
					else
						src.Die()
					H.update_icons()
					return 0
	if(iscarbon(M))
		var/mob/living/carbon/target = L

		if(target.wear_mask)
			var/obj/item/clothing/mask/W = target.wear_mask
			if(istype(W))
				if(!W.canremove)
					return 0
				if(istype(W,/obj/item/clothing/mask/facehugger))
					return 0
				if(W.anti_hug > 1)
					target.visible_message("\red \b [src] smashes against [target]'s [W] and bounces off!")
					W.anti_hug--
					if(rand(50))
						Die()
					else
						GoIdle()
					return 0
				else if(W.anti_hug == 1)
					target.visible_message("\red \b [src] smashes against [target]'s [W] and rips it off!")
					target.drop_from_inventory(W)
					W.anti_hug--
					if(rand(50))
						Die()
					else
						GoIdle()
					target.update_icons()
					return 0
			target.drop_from_inventory(W)
			target.visible_message("\red \b [src] tears [W] off of [target]'s face!")
		src.loc = target
		icon_state = initial(icon_state)
		target.equip_to_slot(src, slot_wear_mask)
		target.contents += src // Monkey sanity check - Snapshot
		target.update_inv_wear_mask()
		if(!sterile) L.Paralyse(MAX_IMPREGNATION_TIME/12) //THIS MIGHT NEED TWEAKS
	else if (iscorgi(M))
		var/mob/living/simple_animal/corgi/corgi = M
		if(corgi.wear_mask || corgi.facehugger) return 0
		src.loc = corgi
		corgi.facehugger = src
		corgi.wear_mask = src
		//C.regenerate_icons()

	GoIdle() //so it doesn't jump the people that tear it off

	spawn(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
		if(src.stat != 2)
			Impregnate(L)

	return 1

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/target as mob)
	if(!target || target.wear_mask != src || target.stat == DEAD) //was taken off or something
		return

	if(istype(target,/mob/living/carbon/Xenomorph))
		return

	if(!sterile)
		var/obj/item/alien_embryo/E = new (target)
		target.status_flags |= XENO_HOST
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/T = target
			var/datum/organ/external/chest/affected = T.get_organ("chest")
			affected.implants += E
		target.visible_message("\red \b [src] falls limp after violating [target]'s face!")

		Die()
		icon_state = "[initial(icon_state)]_impregnated"

		if(iscorgi(target))
			var/mob/living/simple_animal/corgi/C = target
			src.loc = get_turf(C)
			C.facehugger = null
	else
		target.visible_message("\red \b [src] violates [target]'s face!")
	return

/obj/item/clothing/mask/facehugger/proc/GoActive()
	if(stat == DEAD || stat == CONSCIOUS)
		return

	stat = CONSCIOUS
	icon_state = "[initial(icon_state)]"

	return

/obj/item/clothing/mask/facehugger/proc/GoIdle()
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

/*		RemoveActiveIndicators()	*/

	stat = UNCONSCIOUS
	icon_state = "[initial(icon_state)]_inactive"

	spawn(rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))
		GoActive()
	return

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD)
		return

/*		RemoveActiveIndicators()	*/

	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD

	src.visible_message("\icon[src] \red <B>The [src] curls up into a ball!</b>")
	spawn(3000) //3 minute timer for it to decay
		src.visible_message("\icon[src] \red <B>The dead [src] decays into a mass of acid and chitin.</b>")
		if(ismob(src.loc)) //Make it fall off the person so we can update their icons. Won't update if they're in containers thou
			var/mob/M = src.loc
			M.drop_from_inventory(src)
			M.update_icons()
		spawn(0)
			del(src)
	return

/proc/CanHug(var/mob/living/M)

	if(!istype(M)) return 0 //No ghosts?

	if(M.stat == DEAD) return 0 //No deads.

	if(!iscarbon(M)) return 0 //No simple animals at all. Including Mr. Wiggles. His cuteness is his helmet.

	if(istype(M,/mob/living/carbon/Xenomorph)) return 0 //No xenos, hurr

	if(M.status_flags & XENO_HOST) return 0 //No hosts.

	if(istype(M,/mob/living/carbon/hellhound)) return 0

	//Already have a hugger? NOPE
	//This is to prevent eggs from bursting all over if you walk around with one on your face,
	//or an unremovable mask.
	if(iscarbon(M))
		if(M.wear_mask)
			var/obj/item/W = M.wear_mask
			if(!W.canremove)
				return 0
			if(istype(W,/obj/item/clothing/mask/facehugger))
				return 0

	if(iscorgi(M))
		if(M.wear_mask) return 0

	return 1


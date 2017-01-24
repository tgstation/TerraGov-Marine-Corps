//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//TODO: Make these simple_animals

var/const/MIN_IMPREGNATION_TIME = 300 //Time it takes to impregnate someone
var/const/MAX_IMPREGNATION_TIME = 450

var/const/MIN_ACTIVE_TIME = 150 //Time between being dropped and going idle
var/const/MAX_ACTIVE_TIME = 200

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = 1 //Note: can be picked up by aliens unlike most other items of w_class below 4
	flags_inventory = COVEREYES|ALLOWINTERNALS|COVERMOUTH|ALLOWREBREATH
	flags_armor_protection = FACE|EYES
	throw_range = 1

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case
	var/sterile = 0
	var/strength = 5
	var/attached = 0

/obj/item/clothing/mask/facehugger/ex_act(severity)
	Die()
	return

/obj/item/clothing/mask/facehugger/Del()
	if(istype(src.loc,/mob/living/carbon))
		var/mob/living/carbon/M = loc
		M.drop_from_inventory(src)
	return ..()

/obj/item/clothing/mask/facehugger/dropped()
	spawn(2)
		var/obj/item/clothing/mask/facehugger/F
		var/count = 0
		for(F in get_turf(src))
			if(F.stat == CONSCIOUS)
				count++
		if(count > 2) //Was 5, our rules got much tighter
			visible_message("<span class='warning'>The facehugger is furiously cannibalized by the nearby horde of other ones!</span>")
			del(src)

//Can be picked up by aliens
/obj/item/clothing/mask/facehugger/attack_paw(user as mob)
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
	if(isXenoLarva(user))
		return
	if(isXenoCarrier(user)) //Deal with carriers grabbing huggies
		var/mob/living/carbon/Xenomorph/Carrier/C = user
		if(C.huggers_cur < C.huggers_max)
			if(stat == CONSCIOUS)
				C.huggers_cur++
				user.visible_message("<span class='warning'>\The [user] scoops up the facehugger.</span>", \
				"<span class='notice'>You scoop up the facehugger and carry it for safekeeping. Now sheltering: [C.huggers_cur] / [C.huggers_max].</span>")
				del(src)
			else
				user << "<span class='warning'>This [src.name] looks too unhealthy.</span>"
			return
	user.put_in_active_hand(src) //Not a carrier, or already full? Just pick it up.

/obj/item/clothing/mask/facehugger/attack(mob/M as mob, mob/user as mob)
	if(CanHug(M))
		Attach(M)
		user.update_icons()
	else
		user << "<span class='warning'>The facehugger refuses to attach.</span>"
		..()

/obj/item/clothing/mask/facehugger/examine()
	..()
	switch(stat)
		if(DEAD, UNCONSCIOUS)
			usr << "<span class='danger'>\The [src] is not moving.</span>"
		if(CONSCIOUS)
			usr << "<span class='danger'>\The [src] seems to be active.</span>"
	if(sterile)
		usr << "<span class='danger'>It looks like the proboscis has been removed.</span>"

/obj/item/clothing/mask/facehugger/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/clothing/mask/facehugger))
		return
	Die()

/obj/item/clothing/mask/facehugger/bullet_act()
	Die()
	return 1

/obj/item/clothing/mask/facehugger/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()

/obj/item/clothing/mask/facehugger/equipped(mob/M)
	return

/obj/item/clothing/mask/facehugger/Crossed(atom/target)
	HasProximity(target)

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

/obj/item/clothing/mask/facehugger/proc/Attach(var/mob/living/M)

	if((!iscorgi(M) && !iscarbon(M)))
		return 0

	if(attached)
		return 0

	if(M.status_flags & XENO_HOST)
		return 0

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.has_organ("head"))
			visible_message("<span class='warning'>\The [src] looks for a face to hug on \the [H], but finds none!</span>")
			return 0

	if(istype(M, /mob/living/carbon/Xenomorph))
		return 0

	attached++
	spawn(MAX_IMPREGNATION_TIME)
		attached = 0

	if(loc == M)
		return 0
	if(stat != CONSCIOUS)
		return 0
//	if(!sterile) L.take_organ_damage(strength,0) //done here so that even borgs and humans in helmets take damage

	M.visible_message("<span class='danger'>\The [src] leaps at \the [M]'s face!</span>")
	if(throwing)
		throwing = 0

	if(isYautja(M))
		var/mob/living/carbon/human/Y = M
		var/catch_chance = 50
		if(Y.dir == reverse_dir[dir])
			catch_chance += 20
		if(Y.lying)
			catch_chance -= 50
		catch_chance -= ((Y.maxHealth - Y.health) / 3)
		if(!isnull(Y.get_active_hand()))
			catch_chance  -= 25
		if(!isnull(Y.get_inactive_hand()))
			catch_chance  -= 25

		if(!Y.stat && Y.dir != dir && prob(catch_chance)) //Not facing away
			Y.visible_message("<span class='notice'>\The [Y] snatches \the [src] out of the air and squashes it!")
			Die()
			throwing = 0
			loc = Y.loc
			return 0

	if(isXeno(loc)) //Being carried? Drop it
		var/mob/living/carbon/Xenomorph/X = loc
		X.drop_from_inventory(src)
		X.update_icons()

	if(isturf(M.loc))
		loc = M.loc //Just checkin

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.head && H.head.canremove)
			var/obj/item/clothing/head/D = H.head
			if(istype(D))
				if(D.anti_hug > 1)
					H.visible_message("<span class='danger'>\The [src] smashes against \the [H]'s [D.name] and bounces off!")
					D.anti_hug--
					if(rand(50))
						Die()
					else
						GoIdle()
					return 0
				else if(D.anti_hug == 1)
					H.visible_message("<span class='danger'>\The [src] smashes against \the [H]'s [D.name] and rips it off!")
					H.drop_from_inventory(D)
					if(istype(D, /obj/item/clothing/head/helmet/marine)) //Marine helmets now get a fancy overlay.
						var/obj/item/clothing/head/helmet/marine/m_helmet = D
						m_helmet.add_hugger_damage()
					D.anti_hug--
					if(rand(50))
						GoIdle()
					else
						Die()
					H.update_icons()
					return 0
	if(iscarbon(M))
		var/mob/living/carbon/target = M

		if(target.wear_mask)
			var/obj/item/clothing/mask/W = target.wear_mask
			if(istype(W))
				if(!W.canremove)
					return 0
				if(istype(W, /obj/item/clothing/mask/facehugger))
					var/obj/item/clothing/mask/facehugger/hugger = W
					if(hugger.stat != DEAD)
						return 0
				if(W.anti_hug > 1)
					target.visible_message("<span class='danger'>\The [src] smashes against \the [target]'s [W.name] and bounces off!</span>")
					W.anti_hug--
					if(rand(50))
						Die()
					else
						GoIdle()
					return 0
				else if(W.anti_hug == 1)
					target.visible_message("<span class='danger'>\The [src] smashes against \the [target]'s [W.name] and rips it off!</span>")
					target.drop_from_inventory(W)
					W.anti_hug--
					if(rand(50))
						Die()
					else
						GoIdle()
					target.update_icons()
					return 0
			target.drop_from_inventory(W)
			target.visible_message("<span class='danger'>\The [src] tears \the [W] off of \the [target]'s face!</span>")
		loc = target
		icon_state = initial(icon_state)
		target.equip_to_slot(src, WEAR_FACE)
		target.contents += src //Monkey sanity check - Snapshot
		target.update_inv_wear_mask()
		if(ishuman(target))
			if(target.gender == "male")
				playsound(loc, 'sound/misc/facehugged_male.ogg', 50, 0)
			if(target.gender == "female")
				playsound(loc, 'sound/misc/facehugged_female.ogg', 50, 0)
		if(!sterile)
			target.Paralyse(MAX_IMPREGNATION_TIME / 12) //THIS MIGHT NEED TWEAKS
	else if(iscorgi(M))
		var/mob/living/simple_animal/corgi/corgi = M
		if(corgi.wear_mask || corgi.facehugger)
			return 0
		loc = corgi
		corgi.facehugger = src
		corgi.wear_mask = src
		//C.regenerate_icons()

	GoIdle() //so it doesn't jump the people that tear it off

	spawn(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
		if(stat != DEAD)
			Impregnate(M)

	return 1

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/target as mob)
	if(!target || target.wear_mask != src || target.stat == DEAD) //Was taken off or something
		return

	if(isXeno(target))
		return

	if(!sterile)
		var/obj/item/alien_embryo/E = new (target)
		target.status_flags |= XENO_HOST
		if(ishuman(target))
			var/mob/living/carbon/human/T = target
			var/datum/organ/external/chest/affected = T.get_organ("chest")
			affected.implants += E
		target.visible_message("<span class='danger'>\The [src] falls limp after violating \the [target]'s face!</span>")

		Die()
		icon_state = "[initial(icon_state)]_impregnated"

		if(iscorgi(target))
			var/mob/living/simple_animal/corgi/C = target
			loc = get_turf(C)
			C.facehugger = null
	else
		target.visible_message("<span class='danger'>\The [src] violates \the [target]'s face!</span>")

/obj/item/clothing/mask/facehugger/proc/GoActive()
	if(stat == DEAD || stat == CONSCIOUS)
		return

	stat = CONSCIOUS
	icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/proc/GoIdle()
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

	stat = UNCONSCIOUS
	icon_state = "[initial(icon_state)]_inactive"

	spawn(rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))
		GoActive()

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD)
		return

	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD

	visible_message("\icon[src] <span class='danger'>\The [src] curls up into a ball!</span>")
	playsound(src.loc, 'sound/voice/alien_facehugger_dies.ogg', 100, 1)
	spawn(3000) //3 minute timer for it to decay
		visible_message("\icon[src] <span class='danger'>\The [src] decays into a mass of acid and chitin.</span>")
		if(ismob(loc)) //Make it fall off the person so we can update their icons. Won't update if they're in containers thou
			var/mob/M = src.loc
			M.drop_from_inventory(src)
			M.update_icons()
		spawn(0)
			del(src)

/proc/CanHug(var/mob/living/M)

	if(!istype(M))
		return 0 //No ghosts?

	if(M.stat == DEAD)
		return 0 //No deads.

	if(!iscarbon(M))
		return 0 //No simple animals at all. Including Mr. Wiggles. His cuteness is his helmet.

	if(isXeno(M))
		return 0 //No xenos, hurr

	if(M.status_flags & XENO_HOST)
		return 0 //No hosts.

	if(isHellhound(M))
		return 0

	//Already have a hugger? NOPE
	//This is to prevent eggs from bursting all over if you walk around with one on your face,
	//or an unremovable mask.
	if(iscarbon(M))
		if(M.wear_mask)
			var/obj/item/W = M.wear_mask
			if(!W.canremove)
				return 0
			if(istype(W, /obj/item/clothing/mask/facehugger))
				var/obj/item/clothing/mask/facehugger/hugger = W
				if(hugger.stat != DEAD)
					return 0

	if(iscorgi(M))
		if(M.wear_mask)
			return 0

	return 1

/obj/item/clothing/mask/facehugger/flamer_fire_act()
	Die()
	return
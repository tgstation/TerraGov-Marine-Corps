//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//TODO: Make these simple_animals

#define MIN_IMPREGNATION_TIME 100 //Time it takes to impregnate someone
#define MAX_IMPREGNATION_TIME 150

#define MIN_ACTIVE_TIME 50 //Time between being dropped and going idle
#define MAX_ACTIVE_TIME 150

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = 1 //Note: can be picked up by aliens unlike most other items of w_class below 4
	flags_inventory = COVEREYES|ALLOWINTERNALS|COVERMOUTH|ALLOWREBREATH|CANTSTRIP
	flags_armor_protection = FACE|EYES
	flags_atom = NOFLAGS
	flags_item = NOBLUDGEON
	throw_range = 1
	layer = MOB_LAYER

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case
	var/sterile = 0
	var/strength = 5
	var/attached = 0
	var/lifecycle = 300 //How long the hugger will survive outside of the egg, or carrier.
	var/leaping = 0 //Is actually attacking someone?
	var/hivenumber = XENO_HIVE_NORMAL

	New()
		..()
		GoActive()

	Dispose()
		. = ..()
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.temp_drop_inv_item(src)

/obj/item/clothing/mask/facehugger/ex_act(severity)
	Die()

/obj/item/clothing/mask/facehugger/dropped()
	set waitfor = 0
	sleep(2)
	var/obj/item/clothing/mask/facehugger/F
	var/count = 0
	for(F in get_turf(src))
		if(F.stat == CONSCIOUS) count++
		if(count > 2) //Was 5, our rules got much tighter
			visible_message("<span class='xenowarning'>The facehugger is furiously cannibalized by the nearby horde of other ones!</span>")
			cdel(src)
			return
	if(stat == CONSCIOUS && loc) //Make sure we're conscious and not idle or dead.
		if(check_lifecycle())
			GoIdle()

//Can be picked up by aliens
/obj/item/clothing/mask/facehugger/attack_paw(user as mob)
	attack_hand(user)

/obj/item/clothing/mask/facehugger/attack_hand(user as mob)

	if((stat == CONSCIOUS && !sterile))
		if(CanHug(user))
			Attach(user) //If we're conscious, don't let them pick us up even if this fails. Just return.
			return
	if(!isXeno(user) && stat != DEAD) return

	return ..()

//Deal with picking up facehuggers. "attack_alien" is the universal 'xenos click something while unarmed' proc.
/obj/item/clothing/mask/facehugger/attack_alien(mob/living/carbon/Xenomorph/user)

	if(user.hivenumber != hivenumber)
		user.animation_attack_on(src)
		user.visible_message("<span class='xenowarning'>[user] crushes \the [src]","<span class='xenowarning'>You crush \the [src]")
		Die()
		return

	switch(user.caste)
		if("Queen","Drone","Hivelord","Carrier")
			attack_hand(user)//Not a carrier, or already full? Just pick it up.

/obj/item/clothing/mask/facehugger/attack(mob/M, mob/user)
	if(CanHug(M))
		Attach(M)
		user.update_icons()
	else
		user << "<span class='warning'>The facehugger refuses to attach.</span>"
		..()

/obj/item/clothing/mask/facehugger/attack_self(mob/user)
	if(isXenoCarrier(user))
		var/mob/living/carbon/Xenomorph/Carrier/C = user
		C.store_hugger(src)

/obj/item/clothing/mask/facehugger/examine(mob/user)
	..()
	switch(stat)
		if(DEAD, UNCONSCIOUS) user << "<span class='danger'>[src] is not moving.</span>"
		if(CONSCIOUS) user << "<span class='danger'>[src] seems to be active.</span>"
	if(sterile)
		user << "<span class='danger'>It looks like the proboscis has been removed.</span>"

/obj/item/clothing/mask/facehugger/attackby(obj/item/W, mob/user)
	if(W.flags_item & NOBLUDGEON) return
	Die()

/obj/item/clothing/mask/facehugger/bullet_act(obj/item/projectile/P)
	..()
	if(P.ammo.flags_ammo_behavior & (AMMO_XENO_ACID|AMMO_XENO_TOX)) return //Xeno spits ignore huggers.
	if(P.damage) Die()
	P.ammo.on_hit_obj(src,P)
	return 1

/obj/item/clothing/mask/facehugger/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()

/obj/item/clothing/mask/facehugger/equipped(mob/M)
	return

/obj/item/clothing/mask/facehugger/Crossed(atom/target)
	HasProximity(target)

/obj/item/clothing/mask/facehugger/on_found(mob/finder)
	if(stat == CONSCIOUS)
		HasProximity(finder)
		return 1
	return

/obj/item/clothing/mask/facehugger/HasProximity(atom/movable/AM)
	if(CanHug(AM))
		Attach(AM)

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]_thrown"
		reset_thrown_icon(range)
		if(range < 2)
			if(check_lifecycle()) GoIdle() //To prevent throwing huggers, then having them leap out.
			//Otherwise it will just die.

/obj/item/clothing/mask/facehugger/proc/reset_thrown_icon(range)
	set waitfor = 0
	sleep(range * 3 + 1)
	if(loc && icon_state == "[initial(icon_state)]_thrown")
		icon_state = "[initial(icon_state)]"
	leaping = 0

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom, speed)
	set waitfor = 0
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]"
	if(ismob(hit_atom) && stat != DEAD)
		if(stat == CONSCIOUS)
			if(leaping && CanHug(hit_atom))
				Attach(hit_atom)
			else if(hit_atom.density)
				stat = UNCONSCIOUS //Giving it some brief downtime before jumping on someone via movement.
				icon_state = "[initial(icon_state)]_inactive"
				step(src, turn(dir, 180)) //We want the hugger to bounce off if it hits a mob.
				throwing = 0
				sleep(15) //1.5 seconds.
				if(loc && stat != DEAD)
					stat = CONSCIOUS
					icon_state = "[initial(icon_state)]"
				return
		throwing = 0
		return
	else
		..()


/obj/item/clothing/mask/facehugger/proc/reset_attach_status()
	set waitfor = 0
	sleep(MAX_IMPREGNATION_TIME)
	attached = 0

/obj/item/clothing/mask/facehugger/proc/leap_at_nearest_target()
	if(isturf(loc))
		var/mob/living/M
		var/i = 10//So if we have a pile of dead bodies around, it doesn't scan everything, just ten iterations.
		for(M in view(4,src))
			if(!i) break
			if(CanHug(M))
				M.visible_message("<span class='warning'>\The scuttling [src] leaps at [M]!</span>", \
				"<span class='warning'>The scuttling [src] leaps at [M]!</span>")
				leaping = 1
				throw_at(M, 4, 1)
				break
			i--
		if(!attached) //Didn't hit anything?
			i = 5
			for(M in loc)
				if(!i) break
				if(CanHug(M))
					Attach(M)
					break
				i--

/obj/item/clothing/mask/facehugger/proc/Attach(mob/living/M)
	set waitfor = 0

	if(attached || M.status_flags & XENO_HOST || isXeno(M) || loc == M || stat != CONSCIOUS) return

	attached++

	reset_attach_status()

	M.visible_message("<span class='danger'>[src] leaps at [M]'s face!</span>")
	if(throwing) throwing = 0

	if(isXeno(loc)) //Being carried? Drop it
		var/mob/living/carbon/Xenomorph/X = loc
		X.drop_inv_item_on_ground(src)
		X.update_icons()

	if(isturf(M.loc)) loc = M.loc //Just checkin

	var/cannot_infect //To determine if the hugger just rips off the protection or can infect.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(!H.has_limb("head"))
			visible_message("<span class='warning'>[src] looks for a face to hug on [H], but finds none!</span>")
			GoIdle()
			return

		if(isYautja(M))
			var/catch_chance = 50
			if(H.dir == reverse_dir[dir]) catch_chance += 20
			if(H.lying) catch_chance -= 50
			catch_chance -= ((H.maxHealth - H.health) / 3)
			if(H.get_active_hand()) catch_chance  -= 25
			if(H.get_inactive_hand()) catch_chance  -= 25

			if(!H.stat && H.dir != dir && prob(catch_chance)) //Not facing away
				H.visible_message("<span class='notice'>[H] snatches [src] out of the air and squashes it!")
				Die()
				loc = H.loc
				return

		if(H.head && !(H.head.flags_item & NODROP))
			var/obj/item/clothing/head/D = H.head
			if(istype(D))
				if(D.anti_hug > 1)
					H.visible_message("<span class='danger'>[src] smashes against [H]'s [D.name]!")
					cannot_infect = 1
				else
					H.visible_message("<span class='danger'>[src] smashes against [H]'s [D.name] and rips it off!")
					H.drop_inv_item_on_ground(D)
					if(istype(D, /obj/item/clothing/head/helmet/marine)) //Marine helmets now get a fancy overlay.
						var/obj/item/clothing/head/helmet/marine/m_helmet = D
						m_helmet.add_hugger_damage()
					H.update_inv_head()

				if(D.anti_hug && prob(15)) //15% chance the hugger will go idle after ripping off a helmet. Otherwise it will keep going.
					D.anti_hug = max(0, --D.anti_hug)
					GoIdle()
					return
				D.anti_hug = max(0, --D.anti_hug)

	if(iscarbon(M))
		var/mob/living/carbon/target = M

		if(target.wear_mask)
			var/obj/item/clothing/mask/W = target.wear_mask
			if(istype(W))
				if(W.flags_item & NODROP) return

				if(istype(W, /obj/item/clothing/mask/facehugger))
					var/obj/item/clothing/mask/facehugger/hugger = W
					if(hugger.stat != DEAD) return

				if(W.anti_hug > 1)
					target.visible_message("<span class='danger'>[src] smashes against [target]'s [W.name]!</span>")
					cannot_infect = 1
				else
					target.visible_message("<span class='danger'>[src] smashes against [target]'s [W.name] and rips it off!</span>")
					target.drop_inv_item_on_ground(W)
				if(W.anti_hug && prob(15)) //15% chance the hugger will go idle after ripping off a helmet. Otherwise it will keep going.
					W.anti_hug = max(0, --W.anti_hug)
					GoIdle()
					return
				W.anti_hug = max(0, --W.anti_hug)

		if(!cannot_infect)
			loc = target
			icon_state = initial(icon_state)
			target.equip_to_slot(src, WEAR_FACE)
			target.contents += src //Monkey sanity check - Snapshot
			target.update_inv_wear_mask()

			var/mob/living/carbon/human/H
			if(ishuman(target))
				H = target
				H.disable_lights()
				playsound(loc, (target.gender == "male"?'sound/misc/facehugged_male.ogg' : 'sound/misc/facehugged_female.ogg') , 25, 0)
			if(!sterile)
				if(!H || !H.species || !(H.species.flags & IS_SYNTHETIC)) //synthetics aren't paralyzed
					target.KnockOut(MIN_IMPREGNATION_TIME * 0.5) //THIS MIGHT NEED TWEAKS

	GoIdle()

	sleep(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
	Impregnate(M)

	return 1

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/carbon/target)
	if(!target || target.wear_mask != src || isXeno(target)) //Was taken off or something
		return

	var/mob/living/carbon/human/H
	if(ishuman(target))
		H = target
		if(H.species && (H.species.flags & IS_SYNTHETIC)) return //can't impregnate synthetics

	if(!sterile)
		var/embryos = 0
		for(var/obj/item/alien_embryo/embryo in target) // already got one, stops doubling up
			embryos++
		if(!embryos)
			var/obj/item/alien_embryo/embryo = new /obj/item/alien_embryo(target)
			embryo.hivenumber = hivenumber
			icon_state = "[initial(icon_state)]_impregnated"
		target.visible_message("<span class='danger'>[src] falls limp after violating [target]'s face!</span>")
		Die()

	else
		target.visible_message("<span class='danger'>[src] violates [target]'s face!</span>")

/obj/item/clothing/mask/facehugger/proc/check_lifecycle()
	if(lifecycle - 50 <= 0)
		if(isturf(loc))
			var/obj/effect/alien/egg/E = locate() in loc
			if(E && E.status == BURST)
				visible_message("<span class='xenowarning'>[src] crawls back into [E]!</span>")
				E.status = GROWN
				E.icon_state = "Egg"
				E.deploy_egg_triggers()
				cdel(src)
				return
			var/obj/effect/alien/resin/trap/T = locate() in loc
			if(T && !T.hugger)
				visible_message("<span class='xenowarning'>[src] crawls into [T]!</span>")
				T.hugger = TRUE
				T.icon_state = "trap1"
				cdel(src)
				return
		Die()
	else if(!attached || !ishuman(loc)) //doesn't age while attached
		lifecycle -= 50
		return 1

/obj/item/clothing/mask/facehugger/proc/GoActive(var/delay = 50)
	set waitfor = 0

	if(stat == DEAD) return

	if(stat != CONSCIOUS) icon_state = "[initial(icon_state)]"
	stat = CONSCIOUS

	sleep(delay) //Every 5 seconds.
	if(stat == CONSCIOUS && loc) //Make sure we're conscious and not idle or dead.
		if(check_lifecycle())
			leap_at_nearest_target()
			.()

/obj/item/clothing/mask/facehugger/proc/GoIdle() //Idle state does not count toward the death timer.
	set waitfor = 0

	if(stat == DEAD || stat == UNCONSCIOUS) return

	stat = UNCONSCIOUS
	icon_state = "[initial(icon_state)]_inactive"

	sleep(rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))
	GoActive()

/obj/item/clothing/mask/facehugger/proc/Die()
	set waitfor = 0

	if(stat == DEAD) return

	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD

	visible_message("\icon[src] <span class='danger'>\The [src] curls up into a ball!</span>")
	playsound(src.loc, 'sound/voice/alien_facehugger_dies.ogg', 25, 1)

	if(ismob(loc)) //Make it fall off the person so we can update their icons. Won't update if they're in containers thou
		var/mob/M = loc
		M.drop_inv_item_on_ground(src)

	layer = BELOW_MOB_LAYER //so dead hugger appears below live hugger if stacked on same tile.

	sleep(1800) //3 minute timer for it to decay
	visible_message("\icon[src] <span class='danger'>\The [src] decays into a mass of acid and chitin.</span>")
	cdel(src)

/proc/CanHug(mob/living/carbon/M)

	if(!istype(M) || isXeno(M) || isSynth(M) || iszombie(M) || isHellhound(M) || M.stat == DEAD || M.status_flags & XENO_HOST) return

	//Already have a hugger? NOPE
	//This is to prevent eggs from bursting all over if you walk around with one on your face,
	//or an unremovable mask.
	if(M.wear_mask)
		var/obj/item/W = M.wear_mask
		if(W.flags_item & NODROP) return
		if(istype(W, /obj/item/clothing/mask/facehugger))
			var/obj/item/clothing/mask/facehugger/hugger = W
			if(hugger.stat != DEAD) return

	return 1

/obj/item/clothing/mask/facehugger/flamer_fire_act()
	Die()

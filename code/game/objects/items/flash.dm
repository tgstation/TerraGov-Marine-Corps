/obj/item/flash
	name = "flash"
	desc = "Used for blinding and being an asshole."
	icon_state = "flash"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	throwforce = 5
	w_class = 2.0
	throw_speed = 4
	throw_range = 10
	flags_atom = CONDUCT
	origin_tech = "magnets=2;combat=1"

	var/times_used = 0 //Number of times it's been used.
	var/broken = 0     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.

/obj/item/flash/proc/clown_check(var/mob/user)
	if(user && (CLUMSY in user.mutations) && prob(50))
		if(user.drop_held_item())
			to_chat(user, "<span class='warning'>\The [src] slips out of your hand.</span>")
		return 0
	return 1

/obj/item/flash/proc/flash_recharge()
	//capacitor recharges over time
	for(var/i=0, i<3, i++)
		if(last_used+600 > world.time)
			break
		last_used += 600
		times_used -= 2
	last_used = world.time
	times_used = max(0,round(times_used)) //sanity


/obj/item/flash/attack(mob/living/M, mob/user)
	if(!user || !M)	return	//sanity
	if(!ishuman(M)) return

	log_combat(user, M, "attempted to flash", src)
	msg_admin_attack("[ADMIN_TPMONTY(usr)] used the [src.name] to flash [ADMIN_TPMONTY(M)].")

	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.police < SKILL_POLICE_FLASH)
		to_chat(user, "<span class='warning'>You don't seem to know how to use [src]...</span>")
		return

	if(!clown_check(user))	return
	if(broken)
		to_chat(user, "<span class='warning'>\The [src] is broken.</span>")
		return

	flash_recharge()
	if(isxeno(M))
		to_chat(user, "You can't find any eyes!")
		return

	//spamming the flash before it's fully charged (60seconds) increases the chance of it  breaking
	//It will never break on the first use.
	switch(times_used)
		if(0 to 5)
			last_used = world.time
			if(prob(times_used))	//if you use it 5 times in a minute it has a 10% chance to break!
				broken = 1
				to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
				icon_state = "flashburnt"
				return
			times_used++
		else	//can only use it  5 times a minute
			to_chat(user, "<span class='warning'>*click* *click*</span>")
			return
	playsound(src.loc, 'sound/weapons/flash.ogg', 25, 1)
	var/flashfail = 0

	if(iscarbon(M))
		flashfail = !M.flash_eyes()
		if(!flashfail)
			M.KnockDown(10)

	else if(issilicon(M))
		M.KnockDown(rand(5,10))
	else
		flashfail = 1

	if(!flashfail)
	//	flick("flash2", src)
		if(!issilicon(M))

			user.visible_message("<span class='disarm'>[user] blinds [M] with the flash!</span>")
		else

			user.visible_message("<span class='notice'>[user] overloads [M]'s sensors with the flash!</span>")
	else

		user.visible_message("<span class='notice'>[user] fails to blind [M] with the flash!</span>")

	return




/obj/item/flash/attack_self(mob/living/carbon/user as mob, flag = 0, emp = 0)
	if(!user || !clown_check(user)) 	return

	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.police < SKILL_POLICE_FLASH)
		to_chat(user, "<span class='warning'>You don't seem to know how to use [src]...</span>")
		return

	if(broken)
		user.show_message("<span class='warning'>The [src.name] is broken</span>", 2)
		return

	flash_recharge()

	//spamming the flash before it's fully charged (60seconds) increases the chance of it  breaking
	//It will never break on the first use.
	switch(times_used)
		if(0 to 5)
			if(prob(2*times_used))	//if you use it 5 times in a minute it has a 10% chance to break!
				broken = 1
				to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
				icon_state = "flashburnt"
				return
			times_used++
		else	//can only use it  5 times a minute
			user.show_message("<span class='warning'>*click* *click*</span>", 2)
			return
	playsound(src.loc, 'sound/weapons/flash.ogg', 25, 1)
	user.log_message("flashed an area with [key_name(src)]", LOG_ATTACK)
	//flick("flash2", src)

	for(var/mob/living/carbon/human/M in oviewers(3, null))
		if(prob(50))
			if (locate(/obj/item/cloaking_device, M))
				for(var/obj/item/cloaking_device/S in M)
					S.active = 0
					S.icon_state = "shield0"
		M.flash_eyes()

	return

/obj/item/flash/emp_act(severity)
	if(broken)	return
	flash_recharge()
	switch(times_used)
		if(0 to 5)
			if(prob(2*times_used))
				broken = 1
				icon_state = "flashburnt"
				return
			times_used++
			if(iscarbon(loc))
				var/mob/living/carbon/M = loc
				if(M.flash_eyes())
					M.KnockDown(10)
					M.visible_message("<span class='disarm'>[M] is blinded by the flash!</span>")
	..()

/obj/item/flash/synthetic
	name = "synthetic flash"
	desc = "When a problem arises, SCIENCE is the solution."
	icon_state = "sflash"
	origin_tech = "magnets=2;combat=1"
	var/construction_cost = list("metal"=750,"glass"=750)
	var/construction_time=100

/obj/item/flash/synthetic/attack(mob/living/M as mob, mob/user as mob)
	..()
	if(!broken)
		broken = 1
		to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
		icon_state = "flashburnt"

/obj/item/flash/synthetic/attack_self(mob/living/carbon/user as mob, flag = 0, emp = 0)
	..()
	if(!broken)
		broken = 1
		to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
		icon_state = "flashburnt"

/obj/item/weapon/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	item_state = "baton"
	flags_equip_slot = ITEM_SLOT_BELT
	force = 15
	sharp = 0
	edge = 0
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=2"
	attack_verb = list("beaten")
	req_one_access = list(ACCESS_MARINE_BRIG, ACCESS_MARINE_ARMORY, ACCESS_MARINE_CAPTAIN, ACCESS_NT_CORPORATE, ACCESS_NT_PMC_GREEN)
	var/stunforce = 10
	var/agonyforce = 80
	var/status = 0		//whether the thing is on or not
	var/obj/item/cell/bcell = null
	var/hitcost = 1000	//oh god why do power cells carry so much charge? We probably need to make a distinction between "industrial" sized power cells for APCs and power cells for everything else.
	var/has_user_lock = TRUE //whether the baton prevents people without correct access from using it.

/obj/item/weapon/baton/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return (FIRELOSS)

/obj/item/weapon/baton/New()
	..()
	bcell = new/obj/item/cell/high(src) //Fuckit lets givem all the good cells
	update_icon()
	return

/obj/item/weapon/baton/loaded/New() //this one starts with a cell pre-installed.
	..()
	bcell = new/obj/item/cell/high(src)
	update_icon()
	return

/obj/item/weapon/baton/proc/deductcharge(chrgdeductamt)
	if(bcell)
		if(bcell.use(chrgdeductamt))
			return 1
		else
			status = 0
			update_icon()
			return 0

/obj/item/weapon/baton/update_icon()
	if(status)
		icon_state = "[initial(name)]_active"
	else if(!bcell)
		icon_state = "[initial(name)]_nocell"
	else
		icon_state = "[initial(name)]"

/obj/item/weapon/baton/examine(mob/user)
	..()
	if(bcell)
		to_chat(user, "<span class='notice'>The baton is [round(bcell.percent())]% charged.</span>")
	else
		to_chat(user, "<span class='warning'>The baton does not have a power source installed.</span>")

/obj/item/weapon/baton/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	check_user_auth(user)


/obj/item/weapon/baton/equipped(mob/user, slot)
	..()
	check_user_auth(user)


//checks if the mob touching the baton has proper access
/obj/item/weapon/baton/proc/check_user_auth(mob/user)
	if(!has_user_lock)
		return TRUE
	var/mob/living/carbon/human/H = user
	if(istype(H))
		var/obj/item/card/id/I = H.wear_id
		if(!istype(I) || !check_access(I))
			H.visible_message("<span class='notice'> [src] beeeps as [H] picks it up</span>", "<span class='danger'>WARNING: Unauthorized user detected. Denying access...</span>")
			H.knock_down(20)
			H.visible_message("<span class='warning'>[src] beeps and sends a shock through [H]'s body!</span>")
			deductcharge(hitcost)
			return FALSE
	return TRUE

/obj/item/weapon/baton/pull_response(mob/puller)
	return check_user_auth(puller)

/obj/item/weapon/baton/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/cell))
		if(bcell)
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
			return

		if(!user.drop_held_item())
			return

		I.forceMove(src)
		bcell = I
		to_chat(user, "<span class='notice'>You install a cell in [src].</span>")

	else if(isscrewdriver(I))
		if(!bcell)
			return

		bcell.update_icon()
		bcell.forceMove(loc)
		to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
		status = 0

	update_icon()

/obj/item/weapon/baton/attack_self(mob/user)
	if(has_user_lock && user.mind && user.mind.cm_skills && user.mind.cm_skills.police < SKILL_POLICE_MP)
		to_chat(user, "<span class='warning'>You don't seem to know how to use [src]...</span>")
		return
	if(bcell && bcell.charge > hitcost)
		status = !status
		to_chat(user, "<span class='notice'>[src] is now [status ? "on" : "off"].</span>")
		playsound(loc, "sparks", 25, 1, 6)
		update_icon()
	else
		status = 0
		if(!bcell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is out of charge.</span>")


/obj/item/weapon/baton/attack(mob/M, mob/user)
	if(has_user_lock && user.mind && user.mind.cm_skills && user.mind.cm_skills.police < SKILL_POLICE_MP)
		to_chat(user, "<span class='warning'>You don't seem to know how to use [src]...</span>")
		return

	var/agony = agonyforce
	var/stun = stunforce
	var/mob/living/L = M

	var/target_zone = check_zone(user.zone_selected)
	if(user.a_intent == INTENT_HARM)
		if (!..())	//item/attack() does it's own messaging and logs
			return 0	// item/attack() will return 1 if they hit, 0 if they missed.
		agony *= 0.5	//whacking someone causes a much poorer contact than prodding them.
		stun *= 0.5
		//we can't really extract the actual hit zone from ..(), unfortunately. Just act like they attacked the area they intended to.
	else
		//copied from human_defense.dm - human defence code should really be refactored some time.
		if (ishuman(L))

			if (user != L) // Attacking yourself can't miss
				target_zone = get_zone_with_miss_chance(user.zone_selected, L)

			if(!target_zone)
				L.visible_message("<span class='danger'>[user] misses [L] with \the [src]!</span>")
				return 0

			var/mob/living/carbon/human/H = L
			var/datum/limb/affecting = H.get_limb(target_zone)
			if (affecting)
				if(!status)
					L.visible_message("<span class='warning'>[L] has been prodded in the [affecting.display_name] with [src] by [user]. Luckily it was off.</span>")
					return 1
				else
					H.visible_message("<span class='danger'>[L] has been prodded in the [affecting.display_name] with [src] by [user]!</span>")
		else
			if(!status)
				L.visible_message("<span class='warning'>[L] has been prodded with [src] by [user]. Luckily it was off.</span>")
				return 1
			else
				L.visible_message("<span class='danger'>[L] has been prodded with [src] by [user]!</span>")

	//stun effects
	if(!istype(L,/mob/living/carbon/xenomorph)) //Xenos are IMMUNE to all baton stuns.
		L.stun_effect_act(stun, agony, target_zone, src)
		if(!L.knocked_down)
			L.knock_down(4)

	playsound(loc, 'sound/weapons/egloves.ogg', 25, 1, 6)
	msg_admin_attack("[key_name(user)] stunned [key_name(L)] with the [src].")

	deductcharge(hitcost)

	return 1

/obj/item/weapon/baton/emp_act(severity)
	if(bcell)
		bcell.emp_act(severity)	//let's not duplicate code everywhere if we don't have to please.
	..()

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/weapon/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod_nocell"
	item_state = "prod"
	force = 3
	throwforce = 5
	stunforce = 0
	agonyforce = 60	//same force as a stunbaton, but uses way more charge.
	hitcost = 2500
	attack_verb = list("poked")
	flags_equip_slot = NONE
	has_user_lock = FALSE


/obj/item/weapon/stunprod
	name = "electrified prodder"
	desc = "A specialised prod designed for incapacitating xenomorphic lifeforms with."
	icon_state = "stunbaton"
	item_state = "baton"
	flags_equip_slot = ITEM_SLOT_BELT
	force = 12
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	var/charges = 12
	var/status = 0
	origin_tech = "combat=2"


/obj/item/weapon/stunprod/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is putting the live [src] in [user.p_their()] mouth! It looks like [p_theyre()] trying to commit suicide.</span>")
	return FIRELOSS


/obj/item/weapon/stunprod/update_icon()
	if(status)
		icon_state = "stunbaton_active"
	else
		icon_state = "stunbaton"


/obj/item/weapon/stunprod/attack_self(mob/user)
	if(charges > 0)
		status = !status
		to_chat(user, "<span class='notice'>\The [src] is now [status ? "on" : "off"].</span>")
		playsound(loc, "sparks", 15, 1)
		update_icon()
	else
		status = 0
		to_chat(user, "<span class='warning'>\The [src] is out of charge.</span>")


/obj/item/weapon/stunprod/attack(mob/M, mob/user)
	if(user.a_intent == INTENT_HARM)
		return

	else if(!status)
		M.visible_message("<span class='warning'>[M] has been poked with [src] whilst it's turned off by [user].</span>")
		return

	if(status && isliving(M))
		var/mob/living/L = M
		L.knock_down(6)
		charges -= 2
		L.visible_message("<span class='danger'>[L] has been prodded with the [src] by [user]!</span>")

		log_combat(user, L, "stunned", src)

		playsound(loc, 'sound/weapons/egloves.ogg', 25, 1)
		if(charges < 1)
			status = 0
			update_icon()



/obj/item/weapon/stunprod/emp_act(severity)
	switch(severity)
		if(1)
			charges = 0
		if(2)
			charges = max(0, charges - 5)
	if(charges < 1)
		status = 0
		update_icon()


/obj/item/weapon/stunprod/improved
	charges = 30
	name = "improved electrified prodder"
	desc = "A specialised prod designed for incapacitating xenomorphic lifeforms with. This one seems to be much more effective than its predecessor."
	color = "#FF6666"

	
/obj/item/weapon/stunprod/improved/attack(mob/M, mob/user)
	. = ..()
	if(!isliving(M))
		return
	var/mob/living/L = M
	L.knock_down(14)


/obj/item/weapon/stunprod/improved/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It has [charges] charges left.</span>")

/obj/item/weapon/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	item_state = "baton"
	flags_equip_slot = SLOT_WAIST
	force = 15
	sharp = 0
	edge = 0
	throwforce = 7
	w_class = 3
	origin_tech = "combat=2"
	attack_verb = list("beaten")
	req_one_access = list(ACCESS_MARINE_BRIG, ACCESS_MARINE_ARMORY, ACCESS_MARINE_COMMANDER, ACCESS_WY_CORPORATE, ACCESS_WY_PMC_GREEN)
	var/stunforce = 10
	var/agonyforce = 80
	var/status = 0		//whether the thing is on or not
	var/obj/item/cell/bcell = null
	var/hitcost = 1000	//oh god why do power cells carry so much charge? We probably need to make a distinction between "industrial" sized power cells for APCs and power cells for everything else.
	var/has_user_lock = TRUE //whether the baton prevents people without correct access from using it.

/obj/item/weapon/baton/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting the live [name] in \his mouth! It looks like \he's trying to commit suicide.</span>")
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

/obj/item/weapon/baton/proc/deductcharge(var/chrgdeductamt)
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
		user <<"<span class='notice'>The baton is [round(bcell.percent())]% charged.</span>"
	else
		user <<"<span class='warning'>The baton does not have a power source installed.</span>"

/obj/item/weapon/baton/attack_hand(mob/user)
	if(check_user_auth(user))
		..()


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
			H.visible_message("\blue [src] beeeps as [H] picks it up", "<span class='danger'>WARNING: Unauthorized user detected. Denying access...</span>")
			H.KnockDown(20)
			H.visible_message("<span class='warning'>[src] beeps and sends a shock through [H]'s body!</span>")
			deductcharge(hitcost)
			add_fingerprint(user)
			return FALSE
	return TRUE

/obj/item/weapon/baton/pull_response(mob/puller)
	return check_user_auth(puller)

/obj/item/weapon/baton/attackby(obj/item/W, mob/user)

	if(istype(W, /obj/item/cell))
		if(!bcell)
			if(user.drop_held_item())
				W.forceMove(src)
				bcell = W
				user << "<span class='notice'>You install a cell in [src].</span>"
				update_icon()
		else
			user << "<span class='notice'>[src] already has a cell.</span>"

	else if(istype(W, /obj/item/tool/screwdriver))
		if(bcell)
			bcell.updateicon()
			bcell.loc = get_turf(src.loc)
			bcell = null
			user << "<span class='notice'>You remove the cell from the [src].</span>"
			status = 0
			update_icon()
			return
		..()

/obj/item/weapon/baton/attack_self(mob/user)
	if(has_user_lock && user.mind && user.mind.cm_skills && user.mind.cm_skills.police < SKILL_POLICE_MP)
		user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
		return
	if(bcell && bcell.charge > hitcost)
		status = !status
		user << "<span class='notice'>[src] is now [status ? "on" : "off"].</span>"
		playsound(loc, "sparks", 25, 1, 6)
		update_icon()
	else
		status = 0
		if(!bcell)
			user << "<span class='warning'>[src] does not have a power source!</span>"
		else
			user << "<span class='warning'>[src] is out of charge.</span>"
	add_fingerprint(user)


/obj/item/weapon/baton/attack(mob/M, mob/user)
	if(has_user_lock && user.mind && user.mind.cm_skills && user.mind.cm_skills.police < SKILL_POLICE_MP)
		user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
		return
	if(status && (CLUMSY in user.mutations) && prob(50))
		user << "span class='danger'>You accidentally hit yourself with the [src]!</span>"
		user.KnockDown(30)
		deductcharge(hitcost)
		return

	if(isrobot(M))
		..()
		return

	var/agony = agonyforce
	var/stun = stunforce
	var/mob/living/L = M

	var/target_zone = check_zone(user.zone_selected)
	if(user.a_intent == "hurt")
		if (!..())	//item/attack() does it's own messaging and logs
			return 0	// item/attack() will return 1 if they hit, 0 if they missed.
		agony *= 0.5	//whacking someone causes a much poorer contact than prodding them.
		stun *= 0.5
		//we can't really extract the actual hit zone from ..(), unfortunately. Just act like they attacked the area they intended to.
	else
		//copied from human_defense.dm - human defence code should really be refactored some time.
		if (ishuman(L))
			user.lastattacked = L	//are these used at all, if we have logs?
			L.lastattacker = user

			if (user != L) // Attacking yourself can't miss
				target_zone = get_zone_with_miss_chance(user.zone_selected, L)

			if(!target_zone)
				L.visible_message("\red <B>[user] misses [L] with \the [src]!")
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
	if(!istype(L,/mob/living/carbon/Xenomorph)) //Xenos are IMMUNE to all baton stuns.
		L.stun_effect_act(stun, agony, target_zone, src)
		if(!L.knocked_down)
			L.KnockDown(4)

	playsound(loc, 'sound/weapons/Egloves.ogg', 25, 1, 6)
	msg_admin_attack("[key_name(user)] stunned [key_name(L)] with the [src].")

	deductcharge(hitcost)

	return 1

/obj/item/weapon/baton/emp_act(severity)
	if(bcell)
		bcell.emp_act(severity)	//let's not duplicate code everywhere if we don't have to please.
	..()

//secborg stun baton module
/obj/item/weapon/baton/robot/attack_self(mob/user)
	//try to find our power cell
	var/mob/living/silicon/robot/R = loc
	if (istype(R))
		bcell = R.cell
	return ..()

/obj/item/weapon/baton/robot/attackby(obj/item/W, mob/user)
	return

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
	flags_equip_slot = NOFLAGS
	has_user_lock = FALSE

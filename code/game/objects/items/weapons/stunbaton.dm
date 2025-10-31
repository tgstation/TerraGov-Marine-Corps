/obj/item/weapon/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	worn_icon_state = "baton"
	icon = 'icons/obj/items/weapons/batons.dmi'
	equip_slot_flags = ITEM_SLOT_BELT
	force = 15
	sharp = 0
	edge = 0
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("beats")
	req_one_access = list(ACCESS_MARINE_BRIG, ACCESS_MARINE_ARMORY, ACCESS_MARINE_CAPTAIN, ACCESS_NT_CORPORATE, ACCESS_NT_PMC_GREEN)
	var/stunforce = 10
	var/agonyforce = 80
	var/status = 0		//whether the thing is on or not
	var/obj/item/cell/bcell = null
	var/hitcost = 1000	//oh god why do power cells carry so much charge? We probably need to make a distinction between "industrial" sized power cells for APCs and power cells for everything else.
	var/has_user_lock = TRUE //whether the baton prevents people without correct access from using it.

/obj/item/weapon/baton/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide."))
	return (FIRELOSS)

/obj/item/weapon/baton/Initialize(mapload)
	. = ..()
	bcell = new/obj/item/cell/high(src)
	update_icon()

/obj/item/weapon/baton/proc/deductcharge(chrgdeductamt)
	if(bcell)
		if(bcell.use(chrgdeductamt))
			return 1
		else
			status = 0
			update_icon()
			return 0

/obj/item/weapon/baton/update_icon_state()
	. = ..()
	if(status)
		icon_state = "[initial(icon_state)]_active"
	else if(!bcell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/weapon/baton/examine(mob/user)
	. = ..()
	if(bcell)
		. += span_notice("The baton is [round(bcell.percent())]% charged.")
	else
		. += span_warning("The baton does not have a power source installed.")

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
			H.visible_message(span_notice("[src] beeeps as [H] picks it up"), span_danger("WARNING: Unauthorized user detected. Denying access..."))
			H.Paralyze(5 SECONDS)
			H.visible_message(span_warning("[src] beeps and sends a shock through [H]'s body!"))
			deductcharge(hitcost)
			return FALSE
	return TRUE

/obj/item/weapon/baton/pull_response(mob/puller)
	return check_user_auth(puller)

/obj/item/weapon/baton/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/cell))
		if(bcell)
			to_chat(user, span_notice("[src] already has a cell."))
			return

		if(!user.drop_held_item())
			return

		I.forceMove(src)
		bcell = I
		to_chat(user, span_notice("You install a cell in [src]."))

	else if(isscrewdriver(I))
		if(!bcell)
			return

		bcell.forceMove(get_turf(src))
		bcell.update_icon()
		bcell = null
		to_chat(user, span_notice("You remove the cell from the [src]."))
		status = 0

	update_icon()

/obj/item/weapon/baton/attack_self(mob/user)
	if(has_user_lock && user.skills.getRating(SKILL_POLICE) < SKILL_POLICE_MP)
		to_chat(user, span_warning("You don't seem to know how to use [src]..."))
		return
	if(bcell?.charge > hitcost)
		status = !status
		to_chat(user, span_notice("[src] is now [status ? "on" : "off"]."))
		playsound(loc, SFX_SPARKS, 25, 1, 6)
		update_icon()
	else
		status = 0
		if(!bcell)
			to_chat(user, span_warning("[src] does not have a power source!"))
		else
			to_chat(user, span_warning("[src] is out of charge."))

/obj/item/weapon/baton/attack(mob/M, mob/user)
	if(M.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL) //Incorporeal beings cannot attack or be attacked
		return

	if(has_user_lock && user.skills.getRating(SKILL_POLICE) < SKILL_POLICE_MP)
		to_chat(user, span_warning("You don't seem to know how to use [src]..."))
		return

	var/stamloss_applied = agonyforce
	var/stun_applied = stunforce
	var/mob/living/L = M

	var/target_zone = check_zone(user.zone_selected)
	if(user.a_intent == INTENT_HARM)
		if (!..())	//item/attack() does it's own messaging and logs
			return 0	// item/attack() will return 1 if they hit, 0 if they missed.
		stamloss_applied *= 0.5	//whacking someone causes a much poorer contact than prodding them.
		stun_applied *= 0.5
		//we can't really extract the actual hit zone from ..(), unfortunately. Just act like they attacked the area they intended to.
	else
		//copied from human_defense.dm - human defence code should really be refactored some time.
		if (ishuman(L))

			if (user != L) // Attacking yourself can't miss
				target_zone = get_zone_with_miss_chance(user.zone_selected, L)

			if(!target_zone)
				L.visible_message(span_danger("[user] misses [L] with \the [src]!"))
				return 0

			var/mob/living/carbon/human/H = L
			var/datum/limb/affecting = H.get_limb(target_zone)
			if (affecting)
				if(!status)
					L.visible_message(span_warning("[L] has been prodded in the [affecting.display_name] with [src] by [user]. Luckily it was off."))
					return 1
				else
					H.visible_message(span_danger("[L] has been prodded in the [affecting.display_name] with [src] by [user]!"))
		else
			if(!status)
				L.visible_message(span_warning("[L] has been prodded with [src] by [user]. Luckily it was off."))
				return 1
			else
				L.visible_message(span_danger("[L] has been prodded with [src] by [user]!"))

	//stun effects
	if(!HAS_TRAIT(L, TRAIT_BATONIMMUNE))
		L.apply_effects(stun = stun_applied, stutter = stamloss_applied * 0.1, eye_blur = stamloss_applied * 0.1, stamloss = stamloss_applied)
		L.ParalyzeNoChain(8 SECONDS)

	playsound(loc, 'sound/weapons/egloves.ogg', 25, 1, 6)
	log_combat(user, L, "stunned", src)

	deductcharge(hitcost)

	return 1

/obj/item/weapon/baton/emp_act(severity)
	. = ..()
	if(bcell)
		bcell.emp_act(severity)	//let's not duplicate code everywhere if we don't have to please.

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/weapon/baton/cattleprod
	name = "cattle prod"
	desc = "An improvised stun baton."
	icon_state = "stunprod"
	worn_icon_state = "prod"
	force = 3
	throwforce = 5
	stunforce = 0
	agonyforce = 60	//same force as a stunbaton, but uses way more charge.
	hitcost = 2500
	attack_verb = list("pokes")
	equip_slot_flags = NONE
	has_user_lock = FALSE

/obj/item/weapon/baton/stunprod
	name = "electrified prodder"
	desc = "A specialised prod designed for incapacitating xenomorphic lifeforms with."
	icon = 'icons/obj/items/weapons/batons.dmi'
	icon_state = "stunprod"
	worn_icon_state = "baton"
	equip_slot_flags = ITEM_SLOT_BELT
	force = 12
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	var/charges = 12
	status = 0

/obj/item/weapon/baton/stunprod/attack(mob/M, mob/user)
	if(isxeno(user))
		return

	if(user.a_intent == INTENT_HARM)
		return

	else if(!status)
		M.visible_message(span_warning("[M] has been poked with [src] whilst it's turned off by [user]."))
		return

	var/mob/living/L = M
	if(status && isliving(M))
		L.set_slowdown(0.5,2)
		if(isxeno(L))
			var/drain_multiplier = 0.30
			var/mob/living/carbon/xenomorph/X = M
			if(!(X.xeno_caste.caste_flags & CASTE_PLASMADRAIN_IMMUNE))
				X.use_plasma(drain_multiplier * X.xeno_caste.plasma_max * X.xeno_caste.plasma_regen_limit)
				//X.use_plasma(plasma_drain)
			else
				X.do_jitter_animation(25, 3 SECONDS)
				X.ParalyzeNoChain(4 SECONDS)
				to_chat(X, span_xenowarning("We feel our energy zapped out of us, maybe it's best we stop to talk?"))
			if(X.plasma_stored <= 1)
				X.do_jitter_animation(50, 11 SECONDS)
				X.ParalyzeNoChain(12 SECONDS)//can now be used to riot control xenos when they abuse the hospitality of NTC
				to_chat(X, span_xenowarning("We feel our energy zapped out of us, maybe it's best we stop to talk?"))

		if(ishuman(L))
			var/mob/living/carbon/human/H = M
			H.apply_damage(50, STAMINA)
			if(H.getStaminaLoss() > 150)
				H.ParalyzeNoChain(50 SECONDS)
				H.do_jitter_animation(50, 12 SECONDS)
			H.visible_message(span_danger("[H] has been prodded with the [src] by [user]!"))

		charges -= 1
		log_combat(user, L, "stunned", src)
		playsound(loc, 'sound/weapons/egloves.ogg', 25, 1)
		if(charges < 1)
			status = 0
			update_icon()

/obj/item/weapon/baton/stunprod/improved
	charges = 30
	name = "improved electrified prodder"
	desc = "A specialised prod designed for incapacitating xenomorphic lifeforms with. This one seems to be much more effective than its predecessor."
	color = "#FF6666"

/obj/item/weapon/baton/stunprod/improved/attack(mob/M, mob/user)
	. = ..()
	if(!isliving(M))
		return
	var/mob/living/L = M
	L.Paralyze(28 SECONDS)

/obj/item/weapon/baton/stunprod/improved/examine(mob/user)
	. = ..()
	. += span_notice("It has [charges] charges left.")

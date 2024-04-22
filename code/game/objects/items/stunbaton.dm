/obj/item/melee/baton
	name = "stun baton"
	desc = ""
	icon_state = "stunbaton"
	item_state = "baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("beaten")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)

	var/cooldown_check = 0

	var/cooldown = (2.5 SECONDS)
	var/stunforce = (5 SECONDS)
	var/status = 0
	var/obj/item/stock_parts/cell/cell
	var/hitcost = 1000
	var/throw_hit_chance = 35
	var/preload_cell_type //if not empty the baton starts with this type of cell

/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)

/obj/item/melee/baton/Initialize()
	. = ..()
	if(preload_cell_type)
		if(!ispath(preload_cell_type,/obj/item/stock_parts/cell))
			log_mapping("[src] at [AREACOORD(src)] had an invalid preload_cell_type: [preload_cell_type].")
		else
			cell = new preload_cell_type(src)
	update_icon()

/obj/item/melee/baton/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	//Only mob/living types have stun handling
	if(status && prob(throw_hit_chance) && iscarbon(hit_atom))
		baton_effect(hit_atom)

/obj/item/melee/baton/loaded //this one starts with a cell pre-installed.
	preload_cell_type = /obj/item/stock_parts/cell/high

/obj/item/melee/baton/proc/deductcharge(chrgdeductamt)
	if(cell)
		//Note this value returned is significant, as it will determine
		//if a stun is applied or not
		. = cell.use(chrgdeductamt)
		if(status && cell.charge < hitcost)
			//we're below minimum, turn off
			status = 0
			update_icon()
			playsound(loc, "sparks", 75, TRUE, -1)


/obj/item/melee/baton/update_icon()
	if(status)
		icon_state = "[initial(icon_state)]_active"
	else if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/melee/baton/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>\The [src] is [round(cell.percent())]% charged.</span>"
	else
		. += "<span class='warning'>\The [src] does not have a power source installed.</span>"

/obj/item/melee/baton/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, "<span class='warning'>[src] already has a cell!</span>")
		else
			if(C.maxcharge < hitcost)
				to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, "<span class='notice'>I install a cell in [src].</span>")
			update_icon()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(cell)
			cell.update_icon()
			cell.forceMove(get_turf(src))
			cell = null
			to_chat(user, "<span class='notice'>I remove the cell from [src].</span>")
			status = 0
			update_icon()
	else
		return ..()

/obj/item/melee/baton/attack_self(mob/user)
	if(cell && cell.charge > hitcost)
		status = !status
		to_chat(user, "<span class='notice'>[src] is now [status ? "on" : "off"].</span>")
		playsound(loc, "sparks", 75, TRUE, -1)
	else
		status = 0
		if(!cell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is out of charge.</span>")
	update_icon()
	add_fingerprint(user)

/obj/item/melee/baton/attack(mob/M, mob/living/carbon/human/user)
	if(status && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits [user.p_them()]self with [src]!</span>", \
							"<span class='danger'>I accidentally hit myself with [src]!</span>")
		user.Knockdown(stunforce*3)
		deductcharge(hitcost)
		return

	if(iscyborg(M))
		..()
		return


	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(check_martial_counter(L, user))
			return

	if(user.used_intent.type != INTENT_HARM)
		if(status)
			if(cooldown_check <= world.time)
				if(baton_effect(M, user))
					user.do_attack_animation(M)
					return
			else
				to_chat(user, "<span class='danger'>The baton is still charging!</span>")
		else
			M.visible_message("<span class='warning'>[user] has prodded [M] with [src]. Luckily it was off.</span>", \
							"<span class='warning'>[user] has prodded you with [src]. Luckily it was off</span>")
	else
		if(status)
			if(cooldown_check <= world.time)
				baton_effect(M, user)
		..()


/obj/item/melee/baton/proc/baton_effect(mob/living/L, mob/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(L, 'sound/blank.ogg', 50, TRUE)
			return 0
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(hitcost))
			return 0
	else
		if(!deductcharge(hitcost))
			return 0

	/// After a target is hit, we do a chunk of stamina damage, along with other effects.
	/// After a period of time, we then check to see what stun duration we give.
	L.Jitter(20)
	L.confused = max(10, L.confused)
	L.stuttering = max(8, L.stuttering)
	L.adjustStaminaLoss(60)

	SEND_SIGNAL(L, COMSIG_LIVING_MINOR_SHOCK)
	addtimer(CALLBACK(src, PROC_REF(apply_stun_effect_end), L), 2 SECONDS)

	if(user)
		L.lastattacker = user.real_name
		L.lastattackerckey = user.ckey
		L.visible_message("<span class='danger'>[user] has stunned [L] with [src]!</span>", \
								"<span class='danger'>[user] has stunned you with [src]!</span>")
		log_combat(user, L, "stunned")

	playsound(loc, 'sound/blank.ogg', 50, TRUE, -1)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(GLOB.hit_appends)

	cooldown_check = world.time + cooldown

	return 1

/// After the initial stun period, we check to see if the target needs to have the stun applied.
/obj/item/melee/baton/proc/apply_stun_effect_end(mob/living/target)
	var/trait_check = HAS_TRAIT(target, TRAIT_STUNRESISTANCE) //var since we check it in out to_chat as well as determine stun duration
	if(trait_check)
		target.Knockdown(stunforce * 0.1)
	else
		target.Knockdown(stunforce)
	if(!target.IsKnockdown())
		to_chat(target, "<span class='warning'>I muscles seize, making you collapse[trait_check ? ", but your body quickly recovers..." : "!"]</span>")

/obj/item/melee/baton/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		deductcharge(1000 / severity)

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = ""
	icon_state = "stunprod"
	item_state = "prod"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	throwforce = 5
	stunforce = (5 SECONDS)
	hitcost = 2000
	throw_hit_chance = 10
	slot_flags = ITEM_SLOT_BACK
	var/obj/item/assembly/igniter/sparkler = 0

/obj/item/melee/baton/cattleprod/Initialize()
	. = ..()
	sparkler = new (src)

/obj/item/melee/baton/cattleprod/baton_effect()
	if(sparkler.activate())
		..()

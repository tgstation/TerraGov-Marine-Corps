/obj/item/restraints
	breakouttime = 600

/obj/item/restraints/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(OXYLOSS)

/obj/item/restraints/Destroy()
	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		if(M.handcuffed == src)
			M.handcuffed = null
			M.update_handcuffed()
			if(M.buckled && M.buckled.buckle_requires_restraints)
				M.buckled.unbuckle_mob(M)
		if(M.legcuffed == src)
			M.legcuffed = null
			M.update_inv_legcuffed()
	return ..()

//Handcuffs

/obj/item/restraints/handcuffs
	name = "handcuffs"
	desc = ""
	gender = PLURAL
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "handcuff"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 5
	custom_materials = list(/datum/material/iron=500)
	breakouttime = 1 MINUTES
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	var/cuffsound = 'sound/blank.ogg'
	var/trashtype = null //for disposable cuffs
	max_integrity = 1000

/obj/item/restraints/handcuffs/cable/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if (R.use(1))
			var/obj/item/wirerod/W = new /obj/item/wirerod
			remove_item_from_storage(user)
			user.put_in_hands(W)
			to_chat(user, "<span class='notice'>I wrap [src] around the top of [I].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>I need one rod to make a wired rod!</span>")
			return
	else if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.get_amount() < 6)
			to_chat(user, "<span class='warning'>I need at least six metal sheets to make good enough weights!</span>")
			return
		to_chat(user, "<span class='notice'>I begin to apply [I] to [src]...</span>")
		if(do_after(user, 35, target = src))
			if(M.get_amount() < 6 || !M)
				return
			var/obj/item/restraints/legcuffs/bola/S = new /obj/item/restraints/legcuffs/bola
			M.use(6)
			user.put_in_hands(S)
			to_chat(user, "<span class='notice'>I make some weights out of [I] and tie them to [src].</span>")
			remove_item_from_storage(user)
			qdel(src)
	else
		return ..()

/obj/item/restraints/handcuffs/attack(mob/living/carbon/C, mob/living/user)
	if(!istype(C))
		return

	if(iscarbon(user) && (HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50)))
		to_chat(user, "<span class='warning'>Uh... how do those things work?!</span>")
		apply_cuffs(user,user)
		return

	// chance of monkey retaliation
	if(ismonkey(C) && prob(MONKEY_CUFF_RETALIATION_PROB))
		var/mob/living/carbon/monkey/M
		M = C
		M.retaliate(user)

	if(!C.handcuffed)
		if(C.get_num_arms(FALSE) >= 2 || C.get_arm_ignore())
			C.visible_message("<span class='danger'>[user] is trying to put [src.name] on [C]!</span>", \
								"<span class='danger'>[user] is trying to put [src.name] on you!</span>")

			playsound(loc, cuffsound, 30, TRUE, -2)
			if(do_mob(user, C, 30) && (C.get_num_arms(FALSE) >= 2 || C.get_arm_ignore()))
				if(iscyborg(user))
					apply_cuffs(C, user, TRUE)
				else
					apply_cuffs(C, user)
				C.visible_message("<span class='notice'>[user] handcuffs [C].</span>", \
									"<span class='danger'>[user] handcuffs you.</span>")
				SSblackbox.record_feedback("tally", "handcuffs", 1, type)

				log_combat(user, C, "handcuffed")
			else
				to_chat(user, "<span class='warning'>I fail to handcuff [C]!</span>")
		else
			to_chat(user, "<span class='warning'>[C] doesn't have two hands...</span>")

/obj/item/restraints/handcuffs/proc/apply_cuffs(mob/living/carbon/target, mob/user, dispense = 0)
	if(target.handcuffed)
		return

	if(!user.temporarilyRemoveItemFromInventory(src) && !dispense)
		return

	var/obj/item/restraints/handcuffs/cuffs = src
	if(trashtype)
		cuffs = new trashtype()
	else if(dispense)
		cuffs = new type()

	cuffs.forceMove(target)
	target.handcuffed = cuffs

	target.update_handcuffed()
	if(trashtype && !dispense)
		qdel(src)
	return

/obj/item/restraints/handcuffs/cable/sinew
	name = "sinew restraints"
	desc = ""
	icon = 'icons/obj/mining.dmi'
	icon_state = "sinewcuff"
	item_state = "sinewcuff"
	custom_materials = null
	color = null

/obj/item/restraints/handcuffs/cable
	name = "cable restraints"
	desc = ""
	icon_state = "cuff"
	item_state = "coil"
	color = "#ff0000"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_materials = list(/datum/material/iron=150, /datum/material/glass=75)
	breakouttime = 30 SECONDS
	cuffsound = 'sound/blank.ogg'

/obj/item/restraints/handcuffs/cable/red
	color = "#ff0000"

/obj/item/restraints/handcuffs/cable/yellow
	color = "#ffff00"

/obj/item/restraints/handcuffs/cable/blue
	color = "#1919c8"

/obj/item/restraints/handcuffs/cable/green
	color = "#00aa00"

/obj/item/restraints/handcuffs/cable/pink
	color = "#ff3ccd"

/obj/item/restraints/handcuffs/cable/orange
	color = "#ff8000"

/obj/item/restraints/handcuffs/cable/cyan
	color = "#00ffff"

/obj/item/restraints/handcuffs/cable/white
	color = null

/obj/item/restraints/handcuffs/alien
	icon_state = "handcuffAlien"

/obj/item/restraints/handcuffs/fake
	name = "fake handcuffs"
	desc = ""
	breakouttime = 1 SECONDS

/obj/item/restraints/handcuffs/cable/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if (R.use(1))
			var/obj/item/wirerod/W = new /obj/item/wirerod
			remove_item_from_storage(user)
			user.put_in_hands(W)
			to_chat(user, "<span class='notice'>I wrap [src] around the top of [I].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>I need one rod to make a wired rod!</span>")
			return
	else if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.get_amount() < 6)
			to_chat(user, "<span class='warning'>I need at least six metal sheets to make good enough weights!</span>")
			return
		to_chat(user, "<span class='notice'>I begin to apply [I] to [src]...</span>")
		if(do_after(user, 35, target = src))
			if(M.get_amount() < 6 || !M)
				return
			var/obj/item/restraints/legcuffs/bola/S = new /obj/item/restraints/legcuffs/bola
			M.use(6)
			user.put_in_hands(S)
			to_chat(user, "<span class='notice'>I make some weights out of [I] and tie them to [src].</span>")
			remove_item_from_storage(user)
			qdel(src)
	else
		return ..()

/obj/item/restraints/handcuffs/cable/zipties
	name = "zipties"
	desc = ""
	icon_state = "cuff"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	custom_materials = null
	breakouttime = 45 SECONDS
	trashtype = /obj/item/restraints/handcuffs/cable/zipties/used
	color = null

/obj/item/restraints/handcuffs/cable/zipties/used
	desc = ""
	icon_state = "cuff_used"
	item_state = "cuff"

/obj/item/restraints/handcuffs/cable/zipties/used/attack()
	return

//Legcuffs

/obj/item/restraints/legcuffs
	name = "leg cuffs"
	desc = ""
	gender = PLURAL
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "handcuff"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	flags_1 = CONDUCT_1
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	slowdown = 7
	breakouttime = 30 SECONDS

/obj/item/restraints/legcuffs/beartrap
	icon = 'icons/roguetown/items/misc.dmi'
	name = "mantrap"
	gender = NEUTER
	throw_speed = 1
	throw_range = 1
	icon_state = "beartrap"
	desc = ""
	var/armed = 0
	var/trap_damage = 90
	embedding = list("embedded_unsafe_removal_time" = 40, "embedded_pain_chance" = 10, "embedded_pain_multiplier" = 1, "embed_chance" = 0, "embedded_fall_chance" = 0)
	max_integrity = 100

/obj/item/restraints/legcuffs/beartrap/attack_hand(mob/user)
	if(iscarbon(user) && armed && isturf(loc))
		var/mob/living/carbon/C = user
		var/def_zone = "[(C.active_hand_index == 2) ? "r" : "l" ]_arm"
		var/obj/item/bodypart/BP = C.get_bodypart(def_zone)
		if(!BP)
			return FALSE
		if(C.badluck(5))
			add_mob_blood(C)
			if(!locate(/obj/item/restraints/legcuffs/beartrap) in BP.embedded_objects)
				BP.embedded_objects |= src
				forceMove(C)
			close_trap()
			C.visible_message("<span class='boldwarning'>[C] triggers \the [src].</span>", \
					"<span class='userdanger'>I trigger \the [src]!</span>")
			C.emote("agony")
			C.Stun(80)
			BP.add_wound(/datum/wound/fracture)
			C.apply_damage(trap_damage, BRUTE, def_zone)
			C.consider_ambush()
			return FALSE
		else
			var/used_time = 10 SECONDS
			if(C.mind)
				used_time -= max((C.mind.get_skill_level(/datum/skill/craft/traps) * 2 SECONDS), 2 SECONDS)
			if(do_after(user, used_time, target = src))
				armed = FALSE
				update_icon()
				alpha = 255
				C.visible_message("<span class='notice'>[C] disarms \the [src].</span>", \
						"<span class='notice'>I disarm \the [src].</span>")
				return FALSE
			else
				add_mob_blood(C)
				if(!locate(/obj/item/restraints/legcuffs/beartrap) in BP.embedded_objects)
					BP.embedded_objects |= src
					forceMove(C)
				close_trap()
				C.visible_message("<span class='boldwarning'>[C] triggers \the [src].</span>", \
						"<span class='userdanger'>I trigger \the [src]!</span>")
				C.emote("agony")
				BP.add_wound(/datum/wound/fracture)
				C.apply_damage(trap_damage, BRUTE, def_zone)
				C.consider_ambush()
				return FALSE
	..()

/obj/item/restraints/legcuffs/beartrap/attackby(obj/item/W, mob/user)
	if(W.force && armed)
		user.visible_message("<span class='warning'>[user] triggers \the [src] with [W].</span>", \
				"<span class='danger'>I trigger \the [src] with [W]!</span>")
		W.take_damage(20)
		close_trap()
		if(isliving(user))
			var/mob/living/L = user
			L.consider_ambush()
		return
	..()

/obj/item/restraints/legcuffs/beartrap/armed
	armed = TRUE

/obj/item/restraints/legcuffs/beartrap/armed/camouflage
	armed = TRUE
	alpha = 80

/obj/item/restraints/legcuffs/beartrap/Initialize()
	. = ..()
	update_icon()

/obj/item/restraints/legcuffs/beartrap/update_icon()
	. = ..()
	icon_state = "[initial(icon_state)][armed]"

/obj/item/restraints/legcuffs/beartrap/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is sticking [user.p_their()] head in the [src.name]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/blank.ogg', 50, TRUE, -1)
	return (BRUTELOSS)

/obj/item/restraints/legcuffs/beartrap/attack_self(mob/user)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		var/mob/living/L = user
		if(do_after(user, 50 - (L.STASTR*2), target = user))
			if(prob(50))
				armed = !armed
				update_icon()
				to_chat(user, "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"]</span>")
			else
				user.visible_message("<span class='warning'>The rusty [src.name] breaks under stress!</span>")
				playsound(src.loc, 'sound/foley/breaksound.ogg', 100, TRUE, -1)
				qdel(src)
/obj/item/restraints/legcuffs/beartrap/proc/close_trap()
	armed = FALSE
	alpha = 255
	update_icon()
	playsound(src.loc, 'sound/items/beartrap.ogg', 300, TRUE, -1)

/obj/item/restraints/legcuffs/beartrap/Crossed(AM as mob|obj)
	if(armed && isturf(loc))
		if(isliving(AM))
			var/mob/living/L = AM
			var/snap = TRUE
			if(istype(L.buckled, /obj/vehicle))
				var/obj/vehicle/ridden_vehicle = L.buckled
				if(!ridden_vehicle.are_legs_exposed) //close the trap without injuring/trapping the rider if their legs are inside the vehicle at all times.
					close_trap()
					ridden_vehicle.visible_message("<span class='danger'>[ridden_vehicle] triggers \the [src].</span>")
					return ..()
			if(L.throwing)
				return ..()

			if(L.movement_type & (FLYING|FLOATING)) //don't close the trap if they're flying/floating over it.
				return ..()

			var/def_zone = BODY_ZONE_CHEST
			if(snap && iscarbon(L))
				var/mob/living/carbon/C = L
				if(C.mobility_flags & MOBILITY_STAND)
					def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
					var/obj/item/bodypart/BP = C.get_bodypart(def_zone)
					if(BP)
						add_mob_blood(C)
						if(!locate(/obj/item/restraints/legcuffs/beartrap) in BP.embedded_objects)
							BP.embedded_objects |= src
							forceMove(C)
						C.emote("agony")
						//BP.set_disabled(BODYPART_DISABLED_CRIT)
						//BP.add_wound(/datum/wound/fracture)
			else if(snap && isanimal(L))
				var/mob/living/simple_animal/SA = L
				if(SA.mob_size <= MOB_SIZE_TINY) //don't close the trap if they're as small as a mouse.
					snap = FALSE
			if(snap)
				close_trap()
				L.visible_message("<span class='danger'>[L] triggers \the [src].</span>", \
						"<span class='danger'>I trigger \the [src]!</span>")
				L.apply_damage(trap_damage, BRUTE, def_zone)
				L.Stun(80)
				L.consider_ambush()
	..()

/obj/item/restraints/legcuffs/beartrap/energy
	name = "energy snare"
	armed = 1
	icon_state = "e_snare"
	trap_damage = 0
	breakouttime = 30
	item_flags = DROPDEL
	flags_1 = NONE

/obj/item/restraints/legcuffs/beartrap/energy/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/dissipate), 100)

/obj/item/restraints/legcuffs/beartrap/energy/proc/dissipate()
	if(!ismob(loc))
		do_sparks(1, TRUE, src)
		qdel(src)

/obj/item/restraints/legcuffs/beartrap/energy/attack_hand(mob/user)
	Crossed(user) //honk
	return ..()

/obj/item/restraints/legcuffs/beartrap/energy/cyborg
	breakouttime = 20 // Cyborgs shouldn't have a strong restraint

/obj/item/restraints/legcuffs/bola
	name = "bola"
	desc = ""
	icon_state = "bola"
	breakouttime = 35//easy to apply, easy to break out of
	gender = NEUTER
	var/knockdown = 0

/obj/item/restraints/legcuffs/bola/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	if(!..())
		return
	playsound(src.loc,'sound/blank.ogg', 75, TRUE)

/obj/item/restraints/legcuffs/bola/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..() || !iscarbon(hit_atom))//if it gets caught or the target can't be cuffed,
		return//abort
	ensnare(hit_atom)

/**
  * Attempts to legcuff someone with the bola
  *
  * Arguments:
  * * C - the carbon that we will try to ensnare
  */
/obj/item/restraints/legcuffs/bola/proc/ensnare(mob/living/carbon/C)
	if(!C.legcuffed && C.get_num_legs(FALSE) >= 2)
		visible_message("<span class='danger'>\The [src] ensnares [C]!</span>")
		C.legcuffed = src
		forceMove(C)
		C.update_inv_legcuffed()
		SSblackbox.record_feedback("tally", "handcuffs", 1, type)
		to_chat(C, "<span class='danger'>\The [src] ensnares you!</span>")
		C.Knockdown(knockdown)
		playsound(src, 'sound/blank.ogg', 50, TRUE)

/obj/item/restraints/legcuffs/bola/tactical//traitor variant
	name = "reinforced bola"
	desc = ""
	icon_state = "bola_r"
	breakouttime = 70
	knockdown = 35

/obj/item/restraints/legcuffs/bola/energy //For Security
	name = "energy bola"
	desc = ""
	icon_state = "ebola"
	hitsound = list('sound/blank.ogg')
	w_class = WEIGHT_CLASS_SMALL
	breakouttime = 60

/obj/item/restraints/legcuffs/bola/energy/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(iscarbon(hit_atom))
		var/obj/item/restraints/legcuffs/beartrap/B = new /obj/item/restraints/legcuffs/beartrap/energy/cyborg(get_turf(hit_atom))
		B.Crossed(hit_atom)
		qdel(src)
	..()

/obj/item/restraints/legcuffs/bola/gonbola
	name = "gonbola"
	desc = ""
	icon_state = "gonbola"
	breakouttime = 300
	slowdown = 0
	var/datum/status_effect/gonbolaPacify/effectReference

/obj/item/restraints/legcuffs/bola/gonbola/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(iscarbon(hit_atom))
		var/mob/living/carbon/C = hit_atom
		effectReference = C.apply_status_effect(STATUS_EFFECT_GONBOLAPACIFY)

/obj/item/restraints/legcuffs/bola/gonbola/dropped(mob/user)
	. = ..()
	if(effectReference)
		QDEL_NULL(effectReference)

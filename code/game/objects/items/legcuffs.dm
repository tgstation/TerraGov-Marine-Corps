
/obj/item/restraints/legcuffs
	name = "legcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"
	flags_atom = CONDUCT
	throwforce = 0
	w_class = 3.0
	origin_tech = "materials=1"
	breakouttime = 30 SECONDS


/obj/item/restraints/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 2
	throw_range = 1
	icon_state = "beartrap0"
	desc = "A trap used to catch bears and other legged creatures."
	var/armed = 0

/obj/item/restraints/legcuffs/beartrap/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is putting the [name] on [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return (BRUTELOSS)

/obj/item/restraints/legcuffs/beartrap/attack_self(mob/user as mob)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "beartrap[armed]"
		to_chat(user, "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"]</span>")

/obj/item/restraints/legcuffs/beartrap/Crossed(atom/movable/AM)
	if(armed)
		if(ismob(AM))
			var/mob/M = AM
			if(!M.buckled)
				if(ishuman(AM))
					if(isturf(src.loc))
						var/mob/living/carbon/H = AM
						if(H.m_intent == MOVE_INTENT_RUN)
							if(!H.legcuffed)
								forceMove(H)
								H.update_legcuffed(src)
							armed = 0
							icon_state = "beartrap0"
							playsound(loc, 'sound/effects/snap.ogg', 25, 1)
							to_chat(H, "<span class='danger'>You step on \the [src]!</span>")
							for(var/mob/O in viewers(H, null))
								if(O == H)
									continue
								O.show_message("<span class='danger'>[H] steps on \the [src].</span>", 1)
				if(isanimal(AM))
					armed = FALSE
					var/mob/living/simple_animal/SA = AM
					SA.health -= 20
	..()
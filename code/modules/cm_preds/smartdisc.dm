/obj/item/explosive/grenade/spawnergrenade/smartdisc
	name = "smart-disc"
	spawner_type = /mob/living/simple_animal/hostile/smartdisc
	deliveryamt = 1
	desc = "A strange piece of alien technology. It has many jagged, whirring blades and bizarre writing."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "disk"
	item_state = "pred_disk"
	force = 15
	throwforce = 35
	w_class = 1.0
	det_time = 30
	unacidable = TRUE

	attack_self(mob/user as mob)
		if(!active)
			if(!isYautja(user))
				if(prob(75))
					user << "You fiddle with the disc, but nothing happens. Try again maybe?"
					return
			user << "<span class='warning'>You activate the smart-disc and it whirrs to life!</span>"
			activate(user)
			add_fingerprint(user)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
		return

	activate(mob/user as mob)
		if(active)
			return

		if(user)
			msg_admin_attack("[user.name] ([user.ckey]) primed \a [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		icon_state = initial(icon_state) + "_active"
		active = 1
		playsound(loc, 'sound/items/countdown.ogg', 25, 1)
		if(dangerous)
			updateicon()
		spawn(det_time)
			prime()
			return

	prime()
		if(spawner_type && deliveryamt)
			// Make a quick flash
			var/turf/T = get_turf(src)
			var/atom/movable/x = new spawner_type
			x.loc = T

		cdel(src)
		return

	throw_impact(atom/hit_atom)
		if(isYautja(hit_atom) && istype(hit_atom,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = hit_atom
			if(H.put_in_hands(src))
				hit_atom.visible_message("[hit_atom] expertly catches [src] out of the air.","You catch [src] easily.")
				return
			//if(isnull(H.get_active_hand()))
			//
			//	H.put_in_active_hand(src)
			//	return

		..()

/mob/living/simple_animal/hostile/smartdisc
	name = "smart-disc"
	desc = "A furious, whirling array of blades and alien technology."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "disk_active"
	icon_living = "disk_active"
	icon_dead = "disk"
	icon_gib = "disk"
	speak_chance = 0
	turns_per_move = 1
	response_help = "stares at the"
	response_disarm = "bats aside the"
	response_harm = "hits the"
	speed = -2
	maxHealth = 60
	health = 60
	attack_same = 0
	density = 0
	mob_size = MOB_SIZE_SMALL

	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 30
	attacktext = "slices"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 5000

	break_stuff_probability = 0
	destroy_surroundings = 0

	faction = "yautja"
	var/lifetime = 8 //About 15 seconds.
	var/time_idle = 0

	Process_Spacemove(var/check_drift = 0)
		return 1

	Bumped()
		return

	bullet_act(var/obj/item/projectile/Proj)
		if(prob(60 - Proj.damage))
			return 0

		if(!Proj || Proj.damage <= 0)
			return 0

		adjustBruteLoss(Proj.damage)
		return 1

	death()
		visible_message("\The [src] stops whirring and spins out onto the floor.")
		new /obj/item/explosive/grenade/spawnergrenade/smartdisc(src.loc)
		..()
		spawn(1)
			if(src) cdel(src)

	gib()
		visible_message("\The [src] explodes!")
		..(icon_gib,1)
		spawn(1)
			if(src)
				cdel(src)

	FindTarget()
		var/atom/T = null
		stop_automated_movement = 0

		for(var/atom/A in ListTargets(5))
			if(A == src)
				continue

			if(isliving(A))
				var/mob/living/L = A
				if(L.faction == src.faction && !attack_same)
					continue
				else if(L in friends)
					continue
				else if(isYautja(L))
					continue
				else if (L.stat == DEAD)
					continue
				else
					if(!L.stat)
						stance = HOSTILE_STANCE_ATTACK
						T = L
						break
		return T

	ListTargets(var/dist = 7)
		var/list/L = hearers(src, dist)
		return L

	Life()
		. = ..()
		if(!.)
			walk(src, 0)
			return 0
		if(client)
			return 0

		if(stance == HOSTILE_STANCE_IDLE)
			time_idle++
		else
			time_idle = 0

		lifetime--
		if(lifetime <= 0 || time_idle > 3)
			visible_message("\The [src] stops whirring and spins out onto the floor.")
			new /obj/item/explosive/grenade/spawnergrenade/smartdisc(src.loc)
			cdel(src)
			return

		for(var/mob/living/carbon/C in range(6))
			if(C.target_locked)
				var/image/I = C.target_locked
				if(I.icon_state == "locked-y" && !isYautja(C) && C.stat != DEAD)
					stance = HOSTILE_STANCE_ATTACK
					target_mob = C
					break

		if(!stat)
			switch(stance)
				if(HOSTILE_STANCE_IDLE)
					target_mob = FindTarget()

				if(HOSTILE_STANCE_ATTACK)
					MoveToTarget()

				if(HOSTILE_STANCE_ATTACKING)
					AttackTarget()

	AttackTarget()
		stop_automated_movement = 1
		if(!target_mob || SA_attackable(target_mob))
			LoseTarget()
			return 0
		if(!(target_mob in ListTargets(5)) || prob(20) || target_mob.stat)
			stance = HOSTILE_STANCE_IDLE
			sleep(1)
			return 0
		if(get_dist(src, target_mob) <= 1)	//Attacking
			AttackingTarget()
			return 1

	AttackingTarget()
		if(isnull(target_mob) || !target_mob)  return
		if(!Adjacent(target_mob))  return
		if(isliving(target_mob))
			var/mob/living/L = target_mob
			L.attack_animal(src)
			if(prob(5))
				L.KnockDown(3)
				L.visible_message("<span class='danger'>\The [src] viciously slashes at \the [L]!</span>")
			return L
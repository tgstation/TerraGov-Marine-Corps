/obj/item/weapon/grenade/spawnergrenade/smartdisc
	name = "smart-disc"
	spawner_type = /mob/living/simple_animal/hostile/smartdisc
	deliveryamt = 1
	desc = "A strange piece of alien technology. It has many jagged, whirring blades and bizarre writing."
	icon = 'icons/Predator/items.dmi'
	icon_state = "disk"
	force = 25
	throwforce = 55
	w_class = 1.0
	det_time = 30

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
		playsound(loc, 'sound/items/countdown.ogg', 50, 1, -3)
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

		del(src)
		return

	throw_impact(atom/hit_atom)
		if(isYautja(hit_atom) && istype(hit_atom,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = hit_atom
			if(isnull(H.get_active_hand()))
				hit_atom.visible_message("[hit_atom] expertly catches the [src] out of the air.","You catch the [src] easily.")
				H.put_in_active_hand(src)
				return

		..()

/mob/living/simple_animal/hostile/smartdisc
	name = "Smart-Disc"
	desc = "A furious, whirling array of blades and alien technology."
	icon = 'icons/Predator/items.dmi'
	icon_state = "disk_active"
	icon_living = "disk_active"
	icon_dead = "disk"
	icon_gib = "disk"
	speak_chance = 0
	turns_per_move = 3
	response_help = "stares at the"
	response_disarm = "bats aside the"
	response_harm = "hits the"
	speed = 2
	maxHealth = 80
	health = 80
	attack_same = 0

	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 50
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
	var/lifetime = 16 //About 20 seconds.
	var/time_idle = 0

	Process_Spacemove(var/check_drift = 0)
		return 1

	Bumped()
		return

	bullet_act(var/obj/item/projectile/Proj)
		if(prob(100 - Proj.damage))
			return 0

		if(!Proj || Proj.nodamage)
			return 0

		adjustBruteLoss(Proj.damage)
		return 0

	gib()
		visible_message("\The [src] explodes!")
		..(icon_gib,1)
		spawn(1)
			if(src)
				del(src)

	FindTarget()
		var/atom/T = null
		stop_automated_movement = 0

		for(var/atom/A in ListTargets(5))
			if(A == src)
				continue

			var/atom/F = Found(A)
			if(F)
				T = F
				break

			if(isliving(A))
				var/mob/living/L = A
				if(L.faction == src.faction && !attack_same)
					continue
				else if(L in friends)
					continue
				else if(isYautja(L))
					continue
				else
					if(!L.stat)
						stance = HOSTILE_STANCE_ATTACK
						T = L
						break

			else if(istype(A, /obj/mecha)) // Our line of sight stuff was already done in ListTargets().
				var/obj/mecha/M = A
				if (M.occupant)
					stance = HOSTILE_STANCE_ATTACK
					T = M
					break

			if(istype(A, /obj/machinery/bot))
				var/obj/machinery/bot/B = A
				if (B.health > 0)
					stance = HOSTILE_STANCE_ATTACK
					T = B
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
		if(lifetime <= 0 || time_idle > 5)
			visible_message("\The [src] stops whirring and spins out onto the floor.")
			new /obj/item/weapon/grenade/spawnergrenade/smartdisc(src.loc)
			del(src)
			return

		for(var/mob/living/carbon/C in range(12))
			if(C.target_locked)
				var/image/I = C.target_locked
				if(I.icon_state == "locked-y" && !isYautja(C) && C.stat != DEAD)
					stance = HOSTILE_STANCE_ATTACK
					target_mob = C

		if(!stat)
			switch(stance)
				if(HOSTILE_STANCE_IDLE)
					target_mob = FindTarget()

				if(HOSTILE_STANCE_ATTACK)
					MoveToTarget()

				if(HOSTILE_STANCE_ATTACKING)
					AttackTarget()

	AttackingTarget()
		. =..()
		var/mob/living/L = .
		if(istype(L))
			if(prob(5))
				L.Weaken(3)
				L.visible_message("<span class='danger'>\the [src] viciously slashes at \the [L]!</span>")
				L.attack_animal(src)

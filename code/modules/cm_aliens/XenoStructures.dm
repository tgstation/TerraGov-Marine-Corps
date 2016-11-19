
/*
 * effect/alien
 */
/obj/effect/alien
	name = "alien thing"
	desc = "theres something alien about this"
	icon = 'icons/Xeno/Effects.dmi'
	unacidable = 1
/*
 * Resin
 */
/obj/effect/alien/resin
	name = "resin"
	desc = "Looks like some kind of slimy growth."
	icon_state = "Resin1"

	density = 1
	opacity = 1
	anchored = 1
	var/health = 200
	layer = 2.8
	unacidable = 1

/obj/effect/alien/resin/wall
	name = "resin wall"
	desc = "Weird slime solidified into a wall."
	icon_state = "ResinWall1" //same as resin, but consistency ho!
	layer = 3.1

/obj/effect/alien/resin/membrane
	name = "resin membrane"
	desc = "Weird slime just translucent enough to let light pass through."
	icon_state = "Resin Membrane"
	opacity = 0
	health = 120
	layer = 3

/obj/effect/alien/resin/sticky
	name = "sticky resin"
	desc = "Some disgusting sticky slime. Gross!."
	icon_state = "sticky"
	density = 0
	opacity = 0
	health = 150
	layer = 2.9

/obj/effect/alien/resin/proc/healthcheck()
	if(health <= 0)
		density = 0
		del(src)

/obj/effect/alien/resin/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return 1

/obj/effect/alien/resin/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= 500
		if(2.0)
			health -= (rand(140, 300))
		if(3.0)
			health -= (rand(50, 100))
	healthcheck()
	return

/obj/effect/alien/resin/blob_act()
	health -= 50
	healthcheck()
	return

/obj/effect/alien/resin/meteorhit()
	health -= 50
	healthcheck()
	return

/obj/effect/alien/resin/hitby(AM as mob|obj)
	..()
	if(istype(AM,/mob/living/carbon/Xenomorph))
		return
	visible_message("<span class='danger'>\The [src] was hit by \the [AM].</span>", \
	"<span class='danger'>You hit \the [src].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health = max(0, health - tforce)
	healthcheck()

/obj/effect/alien/resin/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoLarva(M)) //Larvae can't do shit
		return 0
	M.visible_message("<span class='xenonotice'>\The [M] claws \the [src]!</span>", \
	"<span class='xenonotice'>You claw \the [src].</span>")
	playsound(loc, 'sound/effects/attackblob.ogg', 30, 1)
	health -= (M.melee_damage_upper + 50) //Beef up the damage a bit
	healthcheck()

/obj/effect/alien/resin/attack_animal(mob/living/M as mob)
	M.visible_message("<span class='danger'>[M] tears \the [src]!</span>", \
	"<span class='danger'>You tear \the [name].</span>")
	playsound(loc, 'sound/effects/attackblob.ogg', 30, 1)
	health -= 40
	healthcheck()

/obj/effect/alien/resin/attack_hand()
	usr << "<span class='warning'>You scrape ineffectively at \the [src].</span>"

/obj/effect/alien/resin/attack_paw()
	return attack_hand()

/obj/effect/alien/resin/attackby(obj/item/W as obj, mob/user as mob)
	health = health - W.force
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	return ..(W, user)

/obj/effect/alien/resin/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(air_group)
		return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density

/*
 * Weeds
 */
#define NODERANGE 3

/obj/effect/alien/weeds
	name = "weeds"
	desc = "Weird black weeds..."
	icon_state = "weeds"

	anchored = 1
	density = 0
	layer = 2
	unacidable = 1
	var/health = 1
	var/obj/effect/alien/weeds/node/linked_node = null
	var/on_fire = 0

/obj/effect/alien/weeds/node
	icon_state = "weednode"
	name = "purple sac"
	desc = "Weird black octopus-like thing."
	layer = 2.7
	var/node_range = NODERANGE
	health = 15


/obj/effect/alien/weeds/node/New()
	..(loc, src)
	new /obj/effect/alien/weeds(loc)

/obj/effect/alien/weeds/New(pos, node)
	..()
	if(istype(loc, /turf/space))
		del(src)
		return
	linked_node = node
	if(icon_state == "weeds")
		icon_state = pick("weeds", "weeds1", "weeds2")
	spawn(rand(150, 200))
		if(src)
			Life()

/obj/effect/alien/weeds/proc/Life()
	set background = 1
	var/turf/U = get_turf(src)

	if(istype(U, /turf/space) || isnull(U))
		del(src)
		return

	if(!linked_node || (get_dist(linked_node, src) > linked_node.node_range) )
		return

	direction_loop:
		for(var/dirn in cardinal)
			var/turf/T = get_step(src, dirn)

			if(!istype(T) || T.density || locate(/obj/effect/alien/weeds) in T || istype(T.loc, /area/arrival) || istype(T, /turf/space))
				continue

			if(istype(T, /turf/unsimulated/floor/gm/grass) || istype(T, /turf/unsimulated/floor/gm/river) || istype(T, /turf/unsimulated/floor/gm/coast) || T.slayer > 0)
				continue

			for(var/obj/O in T)
				if(O.density)
					continue direction_loop

			new /obj/effect/alien/weeds(T, linked_node)

/obj/effect/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if(prob(70))
				del(src)
		if(3.0)
			if(prob(50))
				del(src)

/obj/effect/alien/weeds/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!W || !user || isnull(W))
		return 0

	if(W.attack_verb.len)
		visible_message("<span class='danger'>\The [src] have been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]</span>")
	else
		visible_message("<span class='danger'>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]</span>")

	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	healthcheck()

/obj/effect/alien/weeds/proc/healthcheck()
	if(health <= 0)
		del(src)

/obj/effect/alien/weeds/update_icon()
	overlays.Cut()
	if(on_fire)
		overlays += "alien_fire"

/obj/effect/alien/weeds/fire_act()
	on_fire = 1
	if(on_fire)
		update_icon()
		spawn(rand(100,175))
			del(src)

#undef NODERANGE

/* //It turns out this is cloned in xenoprocs.dm. Wonderful.
 * Acid
 */
/obj/effect/alien/acid
	name = "acid"
	desc = "Bubling corrosive stuff. I wouldn't want to touch it."
	icon_state = "acid"

	density = 0
	opacity = 0
	anchored = 1
	var/ticks = 0

/obj/effect/alien/acid/New(loc, acid_t)
	..(loc)
	world << "acid was SPAWNEDDDs"
	var/strength_t = isturf(acid_t) ? 8:4 // Turf take twice as long to take down.
	tick(acid_t,strength_t)

/obj/effect/alien/acid/proc/tick(atom/acid_t,strength_t)
	set waitfor = 0
	if(!acid_t || !acid_t.loc)
		cdel(src)
		return

	if(++ticks >= strength_t)
		visible_message("<span class='xenodanger'>\The [acid_t] collapses under its own weight into a puddle of goop and undigested debris!</span>")

		if(istype(acid_t, /turf/simulated/wall)) // I hate turf code.
			var/turf/simulated/wall/W = acid_t
			W.dismantle_wall(1)
		else
			if(acid_t.contents) //Hopefully won't auto-delete things inside melted stuff..
				for(var/mob/M in acid_t.contents)
					if(acid_t.loc) M.loc = acid_t.loc
			del(acid_t)
		cdel(src)
		return

	switch(strength_t - ticks)
		if(6) visible_message("<span class='xenowarning'>\The [acid_t] is barely holding up against the acid!</span>")
		if(4) visible_message("<span class='xenowarning'>\The [acid_t]\s structure is being melted by the acid!</span>")
		if(2) visible_message("<span class='xenowarning'>\The [acid_t] is struggling to withstand the acid!</span>")
		if(0 to 1) visible_message("<span class='xenowarning'>\The [acid_t] begins to crumble under the acid!</span>")
	sleep(rand(150, 200))
	.()

/*
 * Egg
 */
/var/const //for the status var
	BURST = 0
	BURSTING = 1
	GROWING = 2
	GROWN = 3

	MIN_GROWTH_TIME = 1800 //time it takes to grow a hugger
	MAX_GROWTH_TIME = 3000

/obj/effect/alien/egg
	desc = "It looks like a weird egg"
	name = "egg"
	icon_state = "Egg Growing"
	density = 0
	anchored = 1

	var/health = 80
	var/status = GROWING //can be GROWING, GROWN or BURST; all mutually exclusive
	var/on_fire = 0

/obj/effect/alien/egg/New()
	..()
	spawn(rand(MIN_GROWTH_TIME,MAX_GROWTH_TIME))
		if(status == GROWING)
			Grow()

/obj/effect/alien/egg/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= rand(50, 100)
		if(2.0)
			health -= rand(40, 95)
		if(3.0)
			health -= rand(20, 81)
	healthcheck()

/obj/effect/alien/egg/attack_alien(mob/living/carbon/Xenomorph/M)

	if(!istype(M) || !isXeno(M))
		return attack_hand(M)

	switch(status)
		if(BURST)
			M.visible_message("<span class='xenonotice'>\The [M] clears the hatched egg.</span>", \
			"<span class='xenonotice'>You clear the hatched egg.</span>")
			M.storedplasma++
			if(isXenoLarva(M)) M.amount_grown++
			del(src)
			return
		if(GROWING)
			M << "<span class='warning'>The child is not developed yet.</span>"
			return
		if(GROWN)
			if(isXenoLarva(M))
				M << "<span class='warning'>You nudge the egg, but nothing happens.</span>"
				return
			M << "<span class='warning'>You retrieve the child.</span>"
			Burst(0)

/obj/effect/alien/egg/proc/Grow()
	icon_state = "Egg"
	status = GROWN

/obj/effect/alien/egg/proc/Burst(var/kill = 1) //drops and kills the hugger if any is remaining
	if(status == GROWN || status == GROWING)
		icon_state = "Egg Opened"
		flick("Egg Opening", src)
		status = BURSTING
		spawn(10)
			status = BURST
			if(loc)
				var/obj/item/clothing/mask/facehugger/child = new (src.loc)
				if(kill && istype(child)) //Make sure it's still there
					child.Die()
				else
					if(istype(child))
						for(var/mob/living/carbon/human/F in view(2, src))
							if(CanHug(F) && !isYautja(F) && get_dist(src, F) <= 1)
								F.visible_message("<span class='warning'>\The scuttling [child] leaps at \the [F]!</span>", \
								"<span class='warning'>The scuttling [child] leaps at \the [F]!</span>")
								HasProximity(F)
								break

/obj/effect/alien/egg/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	if(Proj.ammo.damage_type == BURN)
		health -= round(Proj.damage * 0.3)
	..()
	healthcheck()
	return 1

/obj/effect/alien/egg/update_icon()
	overlays.Cut()
	if(on_fire)
		overlays += "alienegg_fire"

/obj/effect/alien/egg/fire_act()
	on_fire = 1
	if(on_fire)
		update_icon()
		spawn(rand(125, 200))
			del(src)

/obj/effect/alien/egg/attackby(obj/item/W as obj, mob/user as mob)
	if(health <= 0)
		return
	if(W.attack_verb.len)
		visible_message("<span class='danger'>\The [src] has been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]</span>")
	else
		visible_message("<span class='danger'>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]</span>")
	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	healthcheck()

/obj/effect/alien/egg/proc/healthcheck()
	if(health <= 0)
		Burst(1)

/obj/effect/alien/egg/HasProximity(atom/movable/AM as mob|obj)
	if(status == GROWN)
		if(!CanHug(AM) || isYautja(AM)) //Predators are too stealthy to trigger eggs to burst. Maybe the huggers are afraid of them.
			return
		Burst(0)

/obj/structure/tunnel
	name = "tunnel"
	desc = "A tunnel entrance. Looks like it was dug by some kind of clawed beast."
	icon = 'icons/Xeno/effects.dmi'
	icon_state = "hole"

	density = 0
	opacity = 0
	anchored = 1
	unacidable = 1

	var/health = 140
	var/obj/structure/tunnel/other = null
	var/id = null //For mapping

	New()
		if(id)
			spawn(5)
				if(other == null)
					for(var/obj/structure/tunnel/T in world)
						if(T.id == id && T != src && T.other == null) //Found a matching tunnel
							T.other = src
							src.other = T //Link them!
							break

	examine()
		if(!usr || !isXeno(usr))
			return ..()

		if(!other)
			usr << "It does not seem to lead anywhere."
		else
			var/area/A = get_area(other)
			usr << "It seems to lead to <b>[A.name]</b>."

/obj/structure/tunnel/proc/healthcheck()
	if(health <= 0)
		visible_message("<span class='danger'>The [src] suddenly collapses!</span>")
		if(other && isturf(other.loc))
			visible_message("<span class='danger'>The [other] suddenly collapses!</span>")
			del(other)
		del(src)

/obj/structure/tunnel/bullet_act(var/obj/item/projectile/Proj)
	return 0

/obj/structure/tunnel/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= 200
		if(2.0)
			health -= 120
		if(3.0)
			if(prob(50))
				health -= 50
			else
				health -= 25
	healthcheck()

/obj/structure/tunnel/blob_act()
	health -= 50
	healthcheck()

/obj/structure/tunnel/meteorhit()
	health -= 50
	healthcheck()

/obj/structure/tunnel/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!isXeno(user))
		return ..()
	attack_alien(user)

/obj/structure/tunnel/attack_alien(mob/living/carbon/Xenomorph/M)
	if(!istype(M) || M.stat || M.health < 1)
		return
	var/tunnel_time = 40

	if(M.big_xeno) //Big xenos take WAY longer
		tunnel_time = 120

	if(isXenoLarva(M)) //Larva can zip through near-instantly, they are wormlike after all
		tunnel_time = 5

	if(!other || !isturf(other.loc))
		M << "<span class='warning'>\The [src] doesn't seem to lead anywhere.</span>"
		return
	if(tunnel_time <= 50)
		M.visible_message("<span class='xenonotice'>\The [M] begins crawling down into \the [src].</span>", \
		"<span class='xenonotice'>You begin crawling down into \the [src].</span>")
	else
		M.visible_message("<span class='xenonotice'>[M] begins heaving their huge bulk down into \the [src].</span>", \
		"<span class='xenonotice'>You begin heaving your monstrous bulk into \the [src].</span>")

	if(do_after(M, tunnel_time))
		if(other && isturf(other.loc)) //Make sure the end tunnel is still there
			M.loc = other.loc
			M.visible_message("<span class='xenonotice'>\The [M] pops out of \the [src].</span>", \
			"<span class='xenonotice'>You pop out through the other side!</span>")
		else
			M << "<span class='warning'>\The [src] ended unexpectedly, so you return back up.</span>"
	else
		M << "<span class='warning'>Your crawling was interrupted!</span>"


/obj/structure/tunnel/attack_hand()
	usr << "<span class='notice'>No way are you going down there! 2spooky!</span>"

/obj/structure/tunnel/attack_paw()
	return attack_hand()


//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.
/obj/structure/stool/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "nest"
	var/health = 100
	var/on_fire = 0
	var/resisting = 0
	var/resisting_ready = 0
	var/nest_resist_time = 1200
	layer = 2.9 //Just above weeds.

/obj/structure/stool/bed/nest/manual_unbuckle(mob/user as mob)
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			if(buckled_mob != user)
				if(user.stat || user.restrained())
					user << "<span class='warning'>Nice try.</span>"
					return
				buckled_mob.visible_message("<span class='notice'>\The [user] pulls \the [buckled_mob] free from \the [src]!</span>",\
				"<span class='notice'>\The [user] pulls you free from \the [src].</span>",\
				"<span class='notice'>You hear squelching.</span>")
				if(ishuman(buckled_mob))
					var/mob/living/carbon/human/H = buckled_mob
					H.recently_unbuckled = 1
					spawn(300)
						if(H) //Make sure the mob reference still exists.
							H.recently_unbuckled = 0

				unbuckle()
			else
				if(buckled_mob.stat)
					buckled_mob << "<span class='warning'>You're a little too unconscious to try that.</span>"
					return
				if(resisting_ready && buckled_mob && buckled_mob.stat != DEAD && buckled_mob.loc == loc)
					buckled_mob.visible_message("<span class='danger'>\The [buckled_mob] breaks free from \the [src]!</span>",\
					"<span class='danger'>You pull yourself free from \the [src]!</span>",\
					"<span class='notice'>You hear squelching.</span>")
					unbuckle()
					resisting_ready = 0
				if(resisting)
					buckled_mob << "<span class='warning'>You're already trying to free yourself. Give it some time.</span>"
					return
				if(buckled_mob && buckled_mob.name)
					buckled_mob.visible_message("<span class='warning'>\The [buckled_mob] struggles to break free of \the [src].</span>",\
					"<span class='warning'>You struggle to break free from \the [src].</span>",\
					"<span class='notice'>You hear squelching.</span>")
				resisting = 1
				spawn(nest_resist_time)
					if(resisting && buckled_mob && buckled_mob.stat != DEAD && buckled_mob.loc == loc) //Must be alive and conscious
						resisting = 0
						resisting_ready = 1
						if(ishuman(usr))
							var/mob/living/carbon/human/H = usr
							if(H.handcuffed)
								buckled_mob << "<span class='danger'>You are ready to break free of the nest, but your limbs are still secured. Resist once more to pop up, then resist again to break your limbs free!</span>"
							else
								buckled_mob << "<span class='danger'>You are ready to break free! Resist once more to free yourself!</span>"
			src.add_fingerprint(user)

/obj/structure/stool/bed/nest/buckle_mob(mob/M as mob, mob/user as mob)

	if(!ismob(M) || (get_dist(src, user) > 1) || (M.loc != src.loc) || user.restrained() || usr.stat || M.buckled || user.buckled || istype(user, /mob/living/silicon/pai))
		return

	unbuckle()

	if(isXeno(M))
		user << "<span class='warning'>\The [M] is too big to shove in the nest.</span>"
		return

	if(!isXeno(user))
		user << "<span class='warning'>Gross! You're not touching that stuff.</span>"
		return

	if(isYautja(M))
		user << "<span class='warning'>\The [M] seems to be wearing some kind of resin-resistant armor!</span>"
		return

	if(buckled_mob)
		user << "<span class='warning'>There's already someone in that nest.</span>"
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.recently_unbuckled)
			user << "<span class='warning'>\The [M] was recently recently unbuckled. Wait a bit.</span>"
			return

	if(M == usr)
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.lying) //Don't ask me why is has to be
			user << "<span class='warning'>\The [M] is resisting, tackle them first.</span>"
			return

	M.visible_message("<span class='xenonotice'>\The [user] secretes a thick, vile resin, securing \the [M] into \the [src]!</span>", \
	"<span class='xenonotice'>\The [user] drenches you in a foul-smelling resin, trapping you in \the [src]!</span>", \
	"<span class='notice'>You hear squelching.</span>")

	M.buckled = src
	M.loc = loc
	M.dir = dir
	M.update_canmove()
	M.pixel_y = 6
	M.old_y = 6
	resisting = 0
	buckled_mob = M
	add_fingerprint(user)

//COMMENTED BY APOP
/*/obj/item/weapon/handcuffs/xeno
	name = "hardened resin"
	desc = "A thick, nasty resin. You could probably resist out of this."
	breakouttime = 200
	cuff_sound = 'sound/effects/blobattack.ogg'
	icon = 'icons/xeno/effects.dmi'
	icon_state = "sticky2"

	dropped()
		del(src)
		return*/

/obj/item/weapon/legcuffs/xeno
	name = "sticky resin"
	desc = "A thick, nasty resin. You could probably resist out of this."
	breakouttime = 100
	icon = 'icons/xeno/effects.dmi'
	icon_state = "sticky2"

/obj/item/weapon/legcuffs/xeno/dropped()
	del(src)

/obj/structure/stool/bed/nest/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W]!</span>", \
	"<span class='warning'>You hit \the [src] with \the [W]!</span>")
	healthcheck()

/obj/structure/stool/bed/nest/proc/healthcheck()
	if(health <= 0)
		density = 0
		del(src)

/obj/structure/stool/bed/nest/update_icon()
	overlays.Cut()
	if(on_fire)
		overlays += "alien_fire"

/obj/structure/stool/bed/nest/fire_act()
	on_fire = 1
	if(on_fire)
		update_icon()
		spawn(rand(225, 400))
			del(src)

/obj/structure/stool/bed/nest/unbuckle(mob/user as mob)
	if(!buckled_mob)
		return
	resisting = 0
	buckled_mob.pixel_y = 0
	buckled_mob.old_y = 0
	..()

/obj/structure/stool/bed/nest/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoLarva(M)) //Larvae can't do shit
		return
	if(M.a_intent == "hurt")
		M.visible_message("<span class='danger'>\The [M] claws at \the [src]!</span>", \
		"<span class='danger'>You claw at \the [src].</span>")
		playsound(loc, 'sound/effects/attackblob.ogg', 30, 1)
		health -= (M.melee_damage_upper + 25) //Beef up the damage a bit
		healthcheck()
	else
		attack_hand(M)

/obj/structure/stool/bed/nest/attack_animal(mob/living/M as mob)
	M.visible_message("<span class='danger'>\The [M] tears at \the [src]!", \
	"<span class='danger'>You tear at \the [src].")
	playsound(loc, 'sound/effects/attackblob.ogg', 30, 1)
	health -= 40
	healthcheck()

//Alien blood effects.
/obj/effect/decal/cleanable/blood/xeno
	name = "sizzling blood"
	desc = "It's yellow and acidic. It looks like... <i>blood?</i>"
	icon = 'icons/effects/blood.dmi'
	basecolor = "#dffc00"
	amount = 0

/obj/effect/decal/cleanable/blood/gibs/xeno
	name = "steaming gibs"
	desc = "Gnarly..."
	icon_state = "xgib1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6")
	basecolor = "#dffc00"
	amount = 0

/obj/effect/decal/cleanable/blood/gibs/xeno/update_icon()
	color = "#FFFFFF"

/obj/effect/decal/cleanable/blood/gibs/xeno/up
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibup1","xgibup1","xgibup1")

/obj/effect/decal/cleanable/blood/gibs/xeno/down
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibdown1","xgibdown1","xgibdown1")

/obj/effect/decal/cleanable/blood/gibs/xeno/body
	random_icon_states = list("xgibhead", "xgibtorso")

/obj/effect/decal/cleanable/blood/gibs/xeno/limb
	random_icon_states = list("xgibleg", "xgibarm")

/obj/effect/decal/cleanable/blood/gibs/xeno/core
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/obj/effect/decal/cleanable/blood/xtracks
	basecolor = "#dffc00"

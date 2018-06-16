#define DROPSHIP_CHAIR_UNFOLDED 1
#define DROPSHIP_CHAIR_FOLDED 2
#define DROPSHIP_CHAIR_BROKEN 3

/obj/structure/bed/chair //YES, chairs are a type of bed, which are a type of stool. This works, believe me.	-Pete
	name = "chair"
	desc = "A rectangular metallic frame sitting on four legs with a back panel. Designed to fit the sitting position, more or less comfortably."
	icon_state = "chair"
	buckle_lying = FALSE
	var/propelled = 0 //Check for fire-extinguisher-driven chairs

/obj/structure/bed/chair/New()
	if(anchored)
		src.verbs -= /atom/movable/verb/pull
	..()
	spawn(3) //Sorry. i don't think there's a better way to do this.
		handle_rotation()
	return

/obj/structure/bed/chair/attack_tk(mob/user as mob)
	if(buckled_mob)
		..()
	else
		rotate()
	return

/obj/structure/bed/chair/handle_rotation() //Making this into a seperate proc so office chairs can call it on Move()
	if(src.dir == NORTH)
		src.layer = FLY_LAYER
	else
		src.layer = OBJ_LAYER
	if(buckled_mob)
		buckled_mob.dir = dir

/obj/structure/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(config.ghost_interaction)
		src.dir = turn(src.dir, 90)
		handle_rotation()
		return
	else
		if(istype(usr, /mob/living/simple_animal/mouse))
			return
		if(!usr || !isturf(usr.loc))
			return
		if(usr.stat || usr.is_mob_restrained())
			return

		dir = turn(src.dir, 90)
		handle_rotation()
		return

//Chair types
/obj/structure/bed/chair/wood
	buildstacktype = /obj/item/stack/sheet/wood
	hit_bed_sound = 'sound/effects/woodhit.ogg'

/obj/structure/bed/chair/wood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/wood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair"
	color = rgb(255,255,255)
	hit_bed_sound = 'sound/weapons/bladeslice.ogg'

/obj/structure/bed/chair/comfy/brown
	color = rgb(255,113,0)

/obj/structure/bed/chair/comfy/beige
	color = rgb(255,253,195)

/obj/structure/bed/chair/comfy/teal
	color = rgb(0,255,255)

/obj/structure/bed/chair/comfy/black
	color = rgb(167,164,153)

/obj/structure/bed/chair/comfy/lime
	color = rgb(255,251,0)

/obj/structure/bed/chair/office
	anchored = 0
	drag_delay = 1 //Pulling something on wheels is easy

/obj/structure/bed/chair/office/Bump(atom/A)
	..()
	if(!buckled_mob) return

	if(propelled)
		var/mob/living/occupant = buckled_mob
		unbuckle()

		var/def_zone = ran_zone()
		var/blocked = occupant.run_armor_check(def_zone, "melee")
		occupant.throw_at(A, 3, propelled)
		occupant.apply_effect(6, STUN, blocked)
		occupant.apply_effect(6, WEAKEN, blocked)
		occupant.apply_effect(6, STUTTER, blocked)
		occupant.apply_damage(10, BRUTE, def_zone, blocked)
		playsound(src.loc, 'sound/weapons/punch1.ogg', 25, 1)
		if(istype(A, /mob/living))
			var/mob/living/victim = A
			def_zone = ran_zone()
			blocked = victim.run_armor_check(def_zone, "melee")
			victim.apply_effect(6, STUN, blocked)
			victim.apply_effect(6, WEAKEN, blocked)
			victim.apply_effect(6, STUTTER, blocked)
			victim.apply_damage(10, BRUTE, def_zone, blocked)
		occupant.visible_message("<span class='danger'>[occupant] crashed into \the [A]!</span>")

/obj/structure/bed/chair/office/light
	icon_state = "officechair_white"
	anchored = 0

/obj/structure/bed/chair/office/dark
	icon_state = "officechair_dark"
	anchored = 0

/obj/structure/bed/chair/dropship/pilot
	icon_state = "pilot_chair"
	anchored = 1
	name = "pilot's chair"
	desc = "A specially designed chair for pilots to sit in."

/obj/structure/bed/chair/dropship/pilot/rotate()
	return // no

/obj/structure/bed/chair/dropship/passenger
	name = "passenger seat"
	desc = "Holds you in place during high altitude drops."
	icon_state = "shuttle_chair"
	var/image/chairbar = null
	var/chair_state = DROPSHIP_CHAIR_UNFOLDED
	buildstacktype = 0
	unacidable = 1
	var/is_animating = 0

/obj/structure/bed/chair/dropship/passenger/CanPass(var/atom/movable/mover, var/turf/target, var/height = 0, var/air_group = 0)
	if(chair_state == DROPSHIP_CHAIR_UNFOLDED && istype(mover, /obj/vehicle/multitile) && !is_animating)
		visible_message("<span class='danger'>[mover] slams into [src] and breaks it!</span>")
		spawn(0)
			fold_down(1)
		return 0
	return ..()

/obj/structure/bed/chair/dropship/passenger/ex_act(severity)
	return

/obj/structure/bed/chair/dropship/passenger/New()
	chairbar = image("icons/obj/objects.dmi", "shuttle_bars")
	chairbar.layer = ABOVE_MOB_LAYER

	return ..()

/obj/structure/bed/chair/dropship/passenger/afterbuckle()
	if(buckled_mob)
		icon_state = "shuttle_chair_buckled"
		overlays += chairbar
	else
		icon_state = "shuttle_chair"
		overlays -= chairbar

/obj/structure/bed/chair/dropship/passenger/buckle_mob(mob/M, mob/user)
	if(chair_state != DROPSHIP_CHAIR_UNFOLDED)
		return
	..()

/obj/structure/bed/chair/dropship/passenger/proc/fold_down(var/break_it = 0)
	if(chair_state == DROPSHIP_CHAIR_UNFOLDED)
		is_animating = 1
		flick("shuttle_chair_new_folding", src)
		is_animating = 0
		unbuckle()
		if(break_it)
			chair_state = DROPSHIP_CHAIR_BROKEN
		else
			chair_state = DROPSHIP_CHAIR_FOLDED
		sleep(5) // animation length
		icon_state = "shuttle_chair_new_folded"

/obj/structure/bed/chair/dropship/passenger/proc/unfold_up()
	if(chair_state == DROPSHIP_CHAIR_BROKEN)
		return
	is_animating = 1
	flick("shuttle_chair_new_unfolding", src)
	is_animating = 0
	chair_state = DROPSHIP_CHAIR_UNFOLDED
	sleep(5)
	icon_state = "shuttle_chair"

/obj/structure/bed/chair/dropship/passenger/rotate()
	return // no

/obj/structure/bed/chair/dropship/passenger/buckle_mob(mob/living/M, mob/living/user)
	if(chair_state != DROPSHIP_CHAIR_UNFOLDED)
		return
	..()

/obj/structure/bed/chair/dropship/passenger/attack_alien(mob/living/user)
	if(chair_state != DROPSHIP_CHAIR_BROKEN)
		user.visible_message("<span class='warning'>[user] smashes \the [src], shearing the bolts!</span>",
		"<span class='warning'>You smash \the [src], shearing the bolts!</span>")
		fold_down(1)

/obj/structure/bed/chair/dropship/passenger/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/tool/wrench))
		switch(chair_state)
			if(DROPSHIP_CHAIR_UNFOLDED)
				user.visible_message("<span class='warning'>[user] begins loosening the bolts on \the [src].</span>",
				"<span class='warning'>You begin loosening the bolts on \the [src].</span>")
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
					user.visible_message("<span class='warning'>[user] loosens the bolts on \the [src], folding it into the decking.</span>",
					"<span class='warning'>You loosen the bolts on \the [src], folding it into the decking.</span>")
					fold_down()
					return
			if(DROPSHIP_CHAIR_FOLDED)
				user.visible_message("<span class='warning'>[user] begins unfolding \the [src].</span>",
				"<span class='warning'>You begin unfolding \the [src].</span>")
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
					user.visible_message("<span class='warning'>[user] unfolds \the [src] from the floor and tightens the bolts.</span>",
					"<span class='warning'>You unfold \the [src] from the floor and tighten the bolts.</span>")
					unfold_up()
					return
			if(DROPSHIP_CHAIR_BROKEN)
				user << "<span class='warning'>\The [src] appears to be broken and needs welding.</span>"
				return
	else if((istype(W, /obj/item/tool/weldingtool) && chair_state == DROPSHIP_CHAIR_BROKEN))
		var/obj/item/tool/weldingtool/C = W
		if(C.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/weldingtool_weld.ogg', 25)
			user.visible_message("<span class='warning'>[user] begins repairing \the [src].</span>",
			"<span class='warning'>You begin repairing \the [src].</span>")
			if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
				user.visible_message("<span class='warning'>[user] repairs \the [src].</span>",
				"<span class='warning'>You repair \the [src].</span>")
				chair_state = DROPSHIP_CHAIR_FOLDED
				return
	else
		..()



/obj/structure/bed/chair/ob_chair
	name = "seat"
	desc = "A comfortable seat."
	icon_state = "ob_chair"
	buildstacktype = null
	unacidable = 1
	dir = WEST

#define DROPSHIP_CHAIR_UNFOLDED 1
#define DROPSHIP_CHAIR_FOLDED 2
#define DROPSHIP_CHAIR_BROKEN 3

/obj/structure/bed/chair //YES, chairs are a type of bed, which are a type of stool. This works, believe me.	-Pete
	name = "chair"
	desc = "A rectangular metallic frame sitting on four legs with a back panel. Designed to fit the sitting position, more or less comfortably."
	icon_state = "chair"
	buckle_lying = FALSE
	max_integrity = 100
	var/propelled = 0 //Check for fire-extinguisher-driven chairs

/obj/structure/bed/chair/Initialize()
	. = ..()
	handle_rotation()

/obj/structure/bed/chair/setDir(newdir)
	. = ..()
	handle_rotation()

/obj/structure/bed/chair/handle_rotation() //Making this into a seperate proc so office chairs can call it on Move()
	if(src.dir == NORTH)
		src.layer = FLY_LAYER
	else
		src.layer = OBJ_LAYER
	if(buckled_mob)
		buckled_mob.setDir(dir)

/obj/structure/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in view(0)

	var/mob/living/carbon/user = usr

	if(!istype(user) || !isturf(user.loc) || user.incapacitated())
		return FALSE

	if(world.time <= user.next_move)
		return FALSE
	user.next_move = world.time + 3

	setDir(turn(dir, 90))

//Chair types
/obj/structure/bed/chair/reinforced
	name = "reinforced chair"
	desc = "Some say that the TGMC shouldn't spent this much money on reinforced chairs, but the documents from briefing riots prove otherwise."
	buildstackamount = 2


/obj/structure/bed/chair/reinforced/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		to_chat(user, "<span class='warning'>You can only deconstruct this by welding it down!</span>")

	else if(iswelder(I))
		if(user.action_busy)
			return
		var/obj/item/tool/weldingtool/WT = I

		if(user.mind?.cm_skills?.engineer && user.mind.cm_skills.engineer < SKILL_ENGINEER_METAL)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out how to weld down \the [src].</span>",
			"<span class='notice'>You fumble around figuring out how to weld down \the [src].</span>")
			var/fumbling_time = 50 * (SKILL_ENGINEER_METAL - user.mind.cm_skills.engineer)
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
				return

		if(!WT.remove_fuel(0, user))
			return

		user.visible_message("<span class='notice'>[user] begins welding down \the [src].</span>",
		"<span class='notice'>You begin welding down \the [src].</span>")
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		if(!do_after(user, 50, TRUE, src, BUSY_ICON_FRIENDLY))
			to_chat(user, "<span class='warning'>You need to stand still!</span>")
			return
		user.visible_message("<span class='notice'>[user] welds down \the [src].</span>",
		"<span class='notice'>You weld down \the [src].</span>")
		if(buildstacktype)
			new buildstacktype(loc, buildstackamount)
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		qdel(src)


/obj/structure/bed/chair/wood
	buildstacktype = /obj/item/stack/sheet/wood
	hit_sound = 'sound/effects/woodhit.ogg'

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
	hit_sound = 'sound/weapons/bladeslice.ogg'

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

/obj/structure/bed/chair/sofa
	name = "comfy sofa"
	desc = "It looks comfy."
	icon_state = "sofamiddle"


/obj/structure/bed/chair/sofa/left
	icon_state = "sofaend_left"

/obj/structure/bed/chair/sofa/right
	icon_state = "sofaend_right"

/obj/structure/bed/chair/sofa/corner
	icon_state = "sofacorner"

/obj/structure/bed/chair/office
	anchored = FALSE
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
		if(isliving(A))
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
	anchored = FALSE

/obj/structure/bed/chair/office/dark
	icon_state = "officechair_dark"
	anchored = FALSE

/obj/structure/bed/chair/dropship/pilot
	icon_state = "pilot_chair"
	anchored = TRUE
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
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	var/is_animating = 0

/obj/structure/bed/chair/dropship/passenger/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(chair_state == DROPSHIP_CHAIR_UNFOLDED && istype(mover, /obj/vehicle/multitile) && !is_animating)
		visible_message("<span class='danger'>[mover] slams into [src] and breaks it!</span>")
		INVOKE_ASYNC(src, .proc/fold_down, TRUE)
		return FALSE
	return ..()

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

/obj/structure/bed/chair/dropship/passenger/proc/fold_down(break_it = FALSE)
	if(chair_state == DROPSHIP_CHAIR_UNFOLDED)
		is_animating = 1
		flick("shuttle_chair_new_folding", src)
		is_animating = 0
		if(buckled_mob)
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
		"<span class='warning'>We smash \the [src], shearing the bolts!</span>")
		fold_down(1)

/obj/structure/bed/chair/dropship/passenger/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		switch(chair_state)
			if(DROPSHIP_CHAIR_UNFOLDED)
				user.visible_message("<span class='warning'>[user] begins loosening the bolts on \the [src].</span>",
				"<span class='warning'>You begin loosening the bolts on \the [src].</span>")
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

				if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
					return

				user.visible_message("<span class='warning'>[user] loosens the bolts on \the [src], folding it into the decking.</span>",
				"<span class='warning'>You loosen the bolts on \the [src], folding it into the decking.</span>")
				fold_down()

			if(DROPSHIP_CHAIR_FOLDED)
				user.visible_message("<span class='warning'>[user] begins unfolding \the [src].</span>",
				"<span class='warning'>You begin unfolding \the [src].</span>")
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

				if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
					return

				user.visible_message("<span class='warning'>[user] unfolds \the [src] from the floor and tightens the bolts.</span>",
				"<span class='warning'>You unfold \the [src] from the floor and tighten the bolts.</span>")
				unfold_up()

			if(DROPSHIP_CHAIR_BROKEN)
				to_chat(user, "<span class='warning'>\The [src] appears to be broken and needs welding.</span>")
				return

	else if(iswelder(I) && chair_state == DROPSHIP_CHAIR_BROKEN)
		var/obj/item/tool/weldingtool/C = I
		if(!C.remove_fuel(0, user))
			return

		playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
		user.visible_message("<span class='warning'>[user] begins repairing \the [src].</span>",
		"<span class='warning'>You begin repairing \the [src].</span>")
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			return

		user.visible_message("<span class='warning'>[user] repairs \the [src].</span>",
		"<span class='warning'>You repair \the [src].</span>")
		chair_state = DROPSHIP_CHAIR_FOLDED


/obj/structure/bed/chair/ob_chair
	name = "seat"
	desc = "A comfortable seat."
	icon_state = "ob_chair"
	buildstacktype = null
	resistance_flags = UNACIDABLE
	dir = WEST

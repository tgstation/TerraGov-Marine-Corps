/obj/structure/girder
	icon_state = "girder"
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER
	var/state = 0
	var/dismantlectr = 0
	var/buildctr = 0
	max_integrity = 125
	var/repair_state = 0
	// To store what type of wall it used to be
	var/original



/obj/structure/girder/bullet_act(obj/item/projectile/Proj)
	//Tasers and the like should not damage girders.
	if(Proj.ammo.damage_type == HALLOSS || Proj.ammo.damage_type == TOX || Proj.ammo.damage_type == CLONE || Proj.damage == 0)
		return 0

	if(Proj.ammo.damage_type == BURN)
		obj_integrity -= Proj.damage
		if(obj_integrity <= 0)
			update_state()
	else
		if(prob(50))
			obj_integrity -= round(Proj.ammo.damage / 2)
			if(obj_integrity <= 0)
				update_state()
	return 1

/obj/structure/girder/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.mob_size != MOB_SIZE_BIG || CHECK_BITFIELD(resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
		to_chat(M, "<span class='warning'>Your claws aren't sharp enough to damage \the [src].</span>")
		return FALSE
	else
		M.animation_attack_on(src)
		obj_integrity -= round(rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper) / 2)
		if(obj_integrity <= 0)
			M.visible_message("<span class='danger'>\The [M] smashes \the [src] apart!</span>", \
			"<span class='danger'>You slice \the [src] apart!</span>", null, 5)
			playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)
			dismantle()
		else
			M.visible_message("<span class='danger'>[M] smashes \the [src]!</span>", \
			"<span class='danger'>You slash \the [src]!</span>", null, 5)
			playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)

/obj/structure/girder/attackby(obj/item/I, mob/user, params)
	. = ..()

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(user.action_busy)
		return TRUE //no afterattack

	else if(obj_integrity <= 0)
		if(repair_state == 0 && istype(I, /obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/metal/M = I
			if(M.amount < 2)
				return
			to_chat(user, "<span class='notice'>Now adding plating...</span>")
			if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
				return

			if(repair_state != 0 || !M || M.amount < 2) 
				return
				
			M.use(2)
			to_chat(user, "<span class='notice'>You added the metal to the girder!</span>")
			repair_state = 1

		else if(repair_state == 1 && iswelder(I))
			if(!do_after(user, 30, TRUE, src, BUSY_ICON_BUILD))
				return
			if(!I || repair_state != 1) 
				return
			to_chat(user, "<span class='notice'>You weld the girder together!</span>")
			repair()

	else if(iswrench(I))
		if(!anchored)
			if(istype(get_area(loc), /area/shuttle || istype(get_area(loc),/area/sulaco/hangar)))
				to_chat(user, "<span class='warning'>No. This area is needed for the dropships and personnel.</span>")
				return

			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			to_chat(user, "<span class='notice'>Now securing the girder</span>")

			if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
				return

			to_chat(user, "<span class='notice'>You secured the girder!</span>")
			new /obj/structure/girder(loc)
			qdel(src)

		else if(dismantlectr % 2 == 0)
			if(!do_after(user, 15, TRUE, src, BUSY_ICON_BUILD))
				return

			dismantlectr++
			obj_integrity -= 15
			to_chat(user, "<span class='notice'>You unfasten a bolt from the girder!</span>")

	else if(isscrewdriver(I) && state == 2 && istype(src, /obj/structure/girder/reinforced))
		playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
		to_chat(user, "<span class='notice'>Now unsecuring support struts</span>")
		if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
			return

		to_chat(user, "<span class='notice'>You unsecured the support struts!</span>")
		state = 1

	else if(iswirecutter(I) && istype(src, /obj/structure/girder/reinforced) && state == 1)
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		to_chat(user, "<span class='notice'>Now removing support struts</span>")
		
		if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
			return

		to_chat(user, "<span class='notice'>You removed the support struts!</span>")
		new /obj/structure/girder(loc)
		qdel(src)

	else if(iscrowbar(I) && state == 0 && anchored)
		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
		to_chat(user, "<span class='notice'>Now dislodging the girder...</span>")

		if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
			return

		to_chat(user, "<span class='notice'>You dislodged the girder!</span>")
		new /obj/structure/girder/displaced(loc)
		qdel(src)

	else if(istype(I, /obj/item/stack/sheet) && buildctr % 2 == 0)
		if(istype(get_area(loc), /area/shuttle || istype(get_area(loc), /area/sulaco/hangar)))
			to_chat(user, "<span class='warning'>No. This area is needed for the dropships and personnel.</span>")
			return

		var/old_buildctr = buildctr

		var/obj/item/stack/sheet/S = I
		if(istype(S, /obj/item/stack/sheet/metal))
			if(!anchored)
				return

			if(S.get_amount() < 1) 
				return
				
			to_chat(user, "<span class='notice'>Now adding plating...</span>")
				
			if(!do_after(user, 60, TRUE, src, BUSY_ICON_BUILD))
				return

			if(buildctr != old_buildctr) 
				return

			if(!S.use(1))
				return

			to_chat(user, "<span class='notice'>You added the plating!</span>")
			buildctr++


		else if(istype(S, /obj/item/stack/sheet/plasteel) && anchored)
			to_chat(user, "<span class='notice'>It doesn't look like the plasteel will do anything. Try metal.</span>")
			return

		if(S.sheettype)
			var/M = S.sheettype
			if(!anchored)
				return

			if(S.amount < 2)
				return

			to_chat(user, "<span class='notice'>Now adding plating...</span>")
			if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
				return

			if(!src || buildctr != old_buildctr) 
				return

			if(!S.use(2))
				return
				
			to_chat(user, "<span class='notice'>You added the plating!</span>")
			var/turf/Tsrc = get_turf(src)
			Tsrc.ChangeTurf(text2path("/turf/closed/wall/mineral/[M]"))
			qdel(src)

	else if(iswelder(I) && buildctr % 2 != 0)
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.remove_fuel(0,user))
			return

		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		if(!do_after(user, 30, TRUE, src, BUSY_ICON_BUILD))
			return

		if(!WT.isOn()) 
			return

		if(buildctr >= 5)
			build_wall()
			return

		buildctr++
		to_chat(user, "<span class='notice'>You weld the metal to the girder!</span>")

	else if(iswirecutter(I) && dismantlectr % 2 != 0)
		if(!do_after(user, 15, TRUE, src, BUSY_ICON_BUILD))
			return

		if(dismantlectr >= 5)
			dismantle()
			dismantlectr = 0
			return

		obj_integrity -= 15
		dismantlectr++
		to_chat(user, "<span class='notice'>You cut away from structural piping!</span>")

	else if(istype(I, /obj/item/pipe))
		var/obj/item/pipe/P = I
		if(P.pipe_type in list(0, 1, 5))	//simple pipes, simple bends, and simple manifolds.
			user.drop_held_item()
			P.forceMove(loc)
			to_chat(user, "<span class='notice'>You fit the pipe into the [src]!</span>")



/obj/structure/girder/proc/build_wall()
	if (buildctr == 5)
		var/turf/Tsrc = get_turf(src)
		if (original)
			Tsrc.ChangeTurf(text2path("[original]"))
		else
			Tsrc.ChangeTurf(/turf/closed/wall)
		for(var/turf/closed/wall/X in Tsrc.loc)
		qdel(src)

/obj/structure/girder/examine(mob/user)
	..()
	if (obj_integrity <= 0)
		to_chat(user, "It's broken, but can be mended by applying a metal plate then welding it together.")
	else
	//Build wall
		if (buildctr%2 == 0)
			to_chat(user, "To continue building the wall, add a metal plate to the girder.")
		else if (buildctr%2 != 0)
			to_chat(user, "Secure the metal plates to the wall by welding.")
		if (buildctr < 1)
			to_chat(user, "It needs 3 more metal plates.")
		else if (buildctr < 3)
			to_chat(user, "It needs 2 more metal plates.")
		else if (buildctr < 5)
			to_chat(user, "It needs 1 more metal plate.")
	//Decon girder
		if (dismantlectr%2 == 0)
			to_chat(user, "To continue dismantling the girder, unbolt a nut with the wrench.")
		else if (dismantlectr%2 != 0)
			to_chat(user, "To continue dismantling the girder, cut through some of structural piping with a wirecutter.")
		if (dismantlectr < 1)
			to_chat(user, "It needs 3 bolts removed.")
		else if (dismantlectr < 3)
			to_chat(user, "It needs 2 bolts removed.")
		else if (dismantlectr < 5)
			to_chat(user, "It needs 1 bolt removed.")

/obj/structure/girder/proc/dismantle()
	new /obj/item/stack/sheet/metal(src)
	qdel(src)

/obj/structure/girder/proc/repair()
	obj_integrity = 200
	update_state()

/obj/structure/girder/proc/update_state()
	if (obj_integrity <= 0)
		icon_state = "[icon_state]_damaged"
		ENABLE_BITFIELD(resistance_flags, UNACIDABLE)
		density = 0
	else
		var/underscore_position =  findtext(icon_state,"_")
		var/new_state = copytext(icon_state, 1, underscore_position)
		icon_state = new_state
		DISABLE_BITFIELD(resistance_flags, UNACIDABLE)
		density = TRUE
	buildctr = 0
	repair_state = 0

/obj/structure/girder/attack_animal(mob/living/simple_animal/user)
	if(user.wall_smash)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		dismantle()
		return
	return ..()

/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(1)
			obj_integrity = 0
			update_state()
		if(2)
			if (prob(30))
				obj_integrity = 0
				update_state()
		if(3)
			if(prob(5))
				obj_integrity = 0
				update_state()




/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = 0
	max_integrity = 50

/obj/structure/girder/reinforced
	icon_state = "reinforced"
	state = 2
	max_integrity = 500

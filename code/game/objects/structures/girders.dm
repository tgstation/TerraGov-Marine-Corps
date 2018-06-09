/obj/structure/girder
	icon_state = "girder"
	anchored = 1
	density = 1
	layer = OBJ_LAYER
	unacidable = 0
	var/state = 0
	var/dismantlectr = 0
	var/buildctr = 0
	var/health = 125
	var/repair_state = 0
	// To store what type of wall it used to be
	var/original



/obj/structure/girder/bullet_act(var/obj/item/projectile/Proj)
	//Tasers and the like should not damage girders.
	if(Proj.ammo.damage_type == HALLOSS || Proj.ammo.damage_type == TOX || Proj.ammo.damage_type == CLONE || Proj.damage == 0)
		return 0

	if(Proj.ammo.damage_type == BURN)
		health -= Proj.damage
		if(health <= 0)
			update_state()
	else
		if(prob(50))
			health -= round(Proj.ammo.damage / 2)
			if(health <= 0)
				update_state()
	return 1


/obj/structure/girder/attackby(obj/item/W, mob/user)
	for(var/obj/effect/xenomorph/acid/A in src.loc)
		if(A.acid_t == src)
			user << "You can't get near that, it's melting!"
			return
	if(user.action_busy)
		return TRUE //no afterattack
	if(health > 0)
		if(istype(W, /obj/item/tool/wrench))
			if(!anchored)
				if(istype(get_area(src.loc),/area/shuttle || istype(get_area(src.loc),/area/sulaco/hangar)))
					user << "<span class='warning'>No. This area is needed for the dropships and personnel.</span>"
					return
				playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
				user << "\blue Now securing the girder"
				if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
					user << "\blue You secured the girder!"
					new/obj/structure/girder( src.loc )
					cdel(src)
			else if (dismantlectr %2 == 0)
				if(do_after(user,15, TRUE, 5, BUSY_ICON_BUILD))
					dismantlectr++
					health -= 15
					user << "\blue You unfasten a bolt from the girder!"
				return


		else if(istype(W, /obj/item/tool/pickaxe/plasmacutter))
			user << "\blue Now slicing apart the girder"
			if(do_after(user,30, TRUE, 5, BUSY_ICON_HOSTILE))
				if(!src) return
				user << "\blue You slice apart the girder!"
				health = 0
				update_state()
		else if(istype(W, /obj/item/tool/pickaxe/diamonddrill))
			user << "\blue You drill through the girder!"
			dismantle()

		else if(istype(W, /obj/item/tool/screwdriver) && state == 2 && istype(src,/obj/structure/girder/reinforced))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
			user << "\blue Now unsecuring support struts"
			if(do_after(user,40, TRUE, 5, BUSY_ICON_BUILD))
				if(!src) return
				user << "\blue You unsecured the support struts!"
				state = 1

		else if(istype(W, /obj/item/tool/wirecutters) && istype(src,/obj/structure/girder/reinforced) && state == 1)
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 25, 1)
			user << "\blue Now removing support struts"
			if(do_after(user,40, TRUE, 5, BUSY_ICON_BUILD))
				if(!src) return
				user << "\blue You removed the support struts!"
				new/obj/structure/girder( src.loc )
				cdel(src)

		else if(istype(W, /obj/item/tool/crowbar) && state == 0 && anchored )
			playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
			user << "\blue Now dislodging the girder..."
			if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
				if(!src) return
				user << "\blue You dislodged the girder!"
				new/obj/structure/girder/displaced( src.loc )
				cdel(src)

		else if(istype(W, /obj/item/stack/sheet) && buildctr %2 == 0)
			if(istype(get_area(src.loc),/area/shuttle || istype(get_area(src.loc),/area/sulaco/hangar)))
				user << "<span class='warning'>No. This area is needed for the dropships and personnel.</span>"
				return

			var/old_buildctr = buildctr

			var/obj/item/stack/sheet/S = W
			if(S.stack_id == "metal")
				if (anchored)
					if(S.get_amount() < 1) return ..()
					user << "<span class='notice'>Now adding plating...</span>"
					if (do_after(user,60, TRUE, 5, BUSY_ICON_BUILD))
						if(disposed || buildctr != old_buildctr) return
						if (S.use(1))
							user << "<span class='notice'>You added the plating!</span>"
							buildctr++
					return
			else if(S.stack_id == "plasteel")
				if (anchored)
					user << "<span class='notice'>It doesn't look like the plasteel will do anything. Try metal.</span>"
					return

			if(S.sheettype)
				var/M = S.sheettype
				if (anchored)
					if(S.amount < 2)
						return ..()
					user << "<span class='notice'>Now adding plating...</span>"
					if (do_after(user,40, TRUE, 5, BUSY_ICON_BUILD))
						if(disposed || buildctr != old_buildctr || S.amount < 2) return
						S.use(2)
						user << "<span class='notice'>You added the plating!</span>"
						var/turf/Tsrc = get_turf(src)
						Tsrc.ChangeTurf(text2path("/turf/closed/wall/mineral/[M]"))
						for(var/turf/closed/wall/mineral/X in Tsrc.loc)
							if(X)	X.add_hiddenprint(usr)
						cdel(src)
					return

			add_hiddenprint(usr)

		else if(istype(W, /obj/item/tool/weldingtool) && buildctr %2 != 0)
			var/obj/item/tool/weldingtool/WT = W
			if (WT.remove_fuel(0,user))
				playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
				if(do_after(user,30, TRUE, 5, BUSY_ICON_BUILD))
					if(!WT.isOn()) return
					if (buildctr >= 5)
						build_wall()
						return
					buildctr++
					user << "\blue You weld the metal to the girder!"
			return
		else if(istype(W, /obj/item/tool/wirecutters) && dismantlectr %2 != 0)
			if(do_after(user,15, TRUE, 5, BUSY_ICON_BUILD))
				if (dismantlectr >= 5)
					dismantle()
					dismantlectr = 0
					return
				health -= 15
				dismantlectr++
				user << "\blue You cut away from structural piping!"
			return

		else if(istype(W, /obj/item/pipe))
			var/obj/item/pipe/P = W
			if (P.pipe_type in list(0, 1, 5))	//simple pipes, simple bends, and simple manifolds.
				user.drop_held_item()
				P.loc = src.loc
				user << "\blue You fit the pipe into the [src]!"
		else
	else
		if (repair_state == 0)
			if(istype(W, /obj/item/stack/sheet/metal))

				var/obj/item/stack/sheet/metal/M = W
				if(M.amount < 2)
					return ..()
				user << "<span class='notice'>Now adding plating...</span>"
				if (do_after(user,40, TRUE, 5, BUSY_ICON_BUILD))
					if(disposed || repair_state != 0 || !M || M.amount < 2) return
					M.use(2)
					user << "<span class='notice'>You added the metal to the girder!</span>"
					repair_state = 1
				return
		if (repair_state == 1)
			if(istype(W, /obj/item/tool/weldingtool))
				if(do_after(user,30, TRUE, 5, BUSY_ICON_BUILD))
					if(disposed || repair_state != 1) return
					user << "\blue You weld the girder together!"
					repair()
				return
		..()

/obj/structure/girder/proc/build_wall()
	if (buildctr == 5)
		var/turf/Tsrc = get_turf(src)
		if (original)
			Tsrc.ChangeTurf(text2path("[original]"))
		else
			Tsrc.ChangeTurf(/turf/closed/wall)
		for(var/turf/closed/wall/X in Tsrc.loc)
			if(X)	X.add_hiddenprint(usr)
		cdel(src)

/obj/structure/girder/examine(mob/user)
	..()
	if (health <= 0)
		user << "It's broken, but can be mended by applying a metal plate then welding it together."
	else
	//Build wall
		if (buildctr%2 == 0)
			user << "To continue building the wall, add a metal plate to the girder."
		else if (buildctr%2 != 0)
			user << "Secure the metal plates to the wall by welding."
		if (buildctr < 1)
			user << "It needs 3 more metal plates."
		else if (buildctr < 3)
			user << "It needs 2 more metal plates."
		else if (buildctr < 5)
			user << "It needs 1 more metal plate."
	//Decon girder
		if (dismantlectr%2 == 0)
			user << "To continue dismantling the girder, unbolt a nut with the wrench."
		else if (dismantlectr%2 != 0)
			user << "To continue dismantling the girder, cut through some of structural piping with a wirecutter."
		if (dismantlectr < 1)
			user << "It needs 3 bolts removed."
		else if (dismantlectr < 3)
			user << "It needs 2 bolts removed."
		else if (dismantlectr < 5)
			user << "It needs 1 bolt removed."

/obj/structure/girder/proc/dismantle()
	health = 0
	update_state()

/obj/structure/girder/proc/repair()
	health = 200
	update_state()

/obj/structure/girder/proc/update_state()
	if (health <= 0)
		icon_state = "[icon_state]_damaged"
		unacidable = 1
		density = 0
	else
		var/underscore_position =  findtext(icon_state,"_")
		var/new_state = copytext(icon_state, 1, underscore_position)
		icon_state = new_state
		unacidable = 0
		density = 1
	buildctr = 0
	repair_state = 0


/obj/structure/girder/attack_hand(mob/user as mob)
	if (HULK in user.mutations)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		dismantle()
		return
	return ..()

/obj/structure/girder/attack_animal(mob/living/simple_animal/user)
	if(user.wall_smash)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		dismantle()
		return
	return ..()

/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(1)
			health = 0
			update_state()
		if(2)
			if (prob(30))
				health = 0
				update_state()
		if(3)
			if(prob(5))
				health = 0
				update_state()




/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = 0
	health = 50

/obj/structure/girder/reinforced
	icon_state = "reinforced"
	state = 2
	health = 500

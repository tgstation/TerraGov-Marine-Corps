
// the cable coil object, used for laying cable

#define MAXCOIL 30
/obj/item/stack/cable_coil
	name = "cable coil"
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	amount = MAXCOIL
	max_amount = MAXCOIL
	color = COLOR_RED
	desc = "A coil of power cable."
	throwforce = 10
	w_class = 2
	throw_speed = 2
	throw_range = 5
	matter = list("metal" = 50, "glass" = 20)
	flags_equip_slot = SLOT_WAIST
	item_state = "coil"
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	stack_id = "cable coil"

	suicide_act(mob/user)
		viewers(user) << "<span class='warning'><b>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</b></span>"
		return(OXYLOSS)


/obj/item/stack/cable_coil/New(loc, length = MAXCOIL, var/param_color = null)
	..()
	src.amount = length
	if (param_color) // It should be red by default, so only recolor it if parameter was specified.
		color = param_color
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	updateicon()
	update_wclass()

/obj/item/stack/cable_coil/proc/updateicon()
	if (!color)
		color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_ORANGE, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	if(amount == 1)
		icon_state = "coil1"
		name = "cable piece"
	else if(amount == 2)
		icon_state = "coil2"
		name = "cable piece"
	else
		icon_state = "coil"
		name = "cable coil"

/obj/item/stack/cable_coil/proc/update_wclass()
	if(amount == 1)
		w_class = 1.0
	else
		w_class = 2.0

/obj/item/stack/cable_coil/examine(mob/user)
	if(amount == 1)
		user << "A short piece of power cable."
	else if(amount == 2)
		user << "A piece of power cable."
	else
		user << "A coil of power cable. There are [amount] lengths of cable in the coil."

/obj/item/stack/cable_coil/verb/make_restraint()
	set name = "Make Cable Restraints"
	set category = "Object"
	var/mob/M = usr

	if(ishuman(M) && !M.is_mob_incapacitated())
		if(!istype(usr.loc,/turf)) return
		if(src.amount <= 14)
			usr << "<span class='warning'>You need at least 15 lengths to make restraints!</span>"
			return
		var/obj/item/handcuffs/cable/B = new /obj/item/handcuffs/cable(usr.loc)
		B.color = color
		usr << "<span class='notice'>You wind some cable together to make some restraints.</span>"
		src.use(15)
	else
		usr << "<span class='notice'>\blue You cannot do that.</span>"
	..()

/obj/item/stack/cable_coil/attackby(obj/item/W, mob/user)
	if( istype(W, /obj/item/tool/wirecutters) && src.amount > 1)
		src.amount--
		new/obj/item/stack/cable_coil(user.loc, 1,color)
		user << "<span class='notice'>You cut a piece off the cable coil.</span>"
		src.updateicon()
		src.update_wclass()
		return

	else if( istype(W, /obj/item/stack/cable_coil) )
		var/obj/item/stack/cable_coil/C = W
		if(C.amount >= MAXCOIL)
			user << "The coil is too long, you cannot add any more cable to it."
			return

		if( (C.amount + src.amount <= MAXCOIL) )
			user << "You join the cable coils together."
			C.add(src.amount) // give it cable
			src.use(src.amount) // make sure this one cleans up right

		else
			var/amt = MAXCOIL - C.amount
			user << "You transfer [amt] length\s of cable from one coil to the other."
			C.add(amt)
			src.use(amt)
		return
	..()

/obj/item/stack/cable_coil/attack_hand(mob/user as mob)
	if (user.get_inactive_hand() == src)
		var/obj/item/stack/cable_coil/F = new /obj/item/stack/cable_coil(user, 1, color)
		F.copy_evidences(src)
		user.put_in_hands(F)
		src.add_fingerprint(user)
		F.add_fingerprint(user)
		use(1)
	else
		..()
	return

/obj/item/stack/cable_coil/use(var/used)
	if( ..() )
		updateicon()
		update_wclass()
		return 1

/obj/item/stack/cable_coil/add(var/extra)
	if( ..() )
		updateicon()
		update_wclass()
		return 1

// called when cable_coil is clicked on a turf/open/floor

/obj/item/stack/cable_coil/proc/turf_place(turf/open/floor/F, mob/user)

	if(!isturf(user.loc))
		return

	if(get_dist(F,user) > 1)
		user << "<span class='warning'>You can't lay cable at a place that far away.</span>"
		return

	if(F.intact_tile)		// if floor is intact, complain
		user << "<span class='warning'>You can't lay cable there unless the floor tiles are removed.</span>"
		return

	else
		var/dirn

		if(user.loc == F)
			dirn = user.dir			// if laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(F, user)

		for(var/obj/structure/cable/LC in F)
			if((LC.d1 == dirn && LC.d2 == 0 ) || ( LC.d2 == dirn && LC.d1 == 0))
				user << "<span class='warning'>There's already a cable at that position.</span>"
				return

		for(var/obj/structure/cable/LC in F)
			if((LC.d1 == dirn && LC.d2 == 0 ) || ( LC.d2 == dirn && LC.d1 == 0))
				user << "There's already a cable at that position."
				return

		var/obj/structure/cable/C = new(F)

		C.cableColor(color)

		C.d1 = 0
		C.d2 = dirn
		C.add_fingerprint(user)
		C.updateicon()

		C.powernet = new()
		powernets += C.powernet
		C.powernet.cables += C

		C.mergeConnectedNetworks(C.d2)
		C.mergeConnectedNetworksOnTurf()


		use(1)
		if (C.shock(user, 50))
			if (prob(50)) //fail
				new/obj/item/stack/cable_coil(C.loc, 1, C.color)
				cdel(C)
		//src.laying = 1
		//last = C


// called when cable_coil is click on an installed obj/cable

/obj/item/stack/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user)

	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact_tile)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		user << "<span class='warning'>You can't lay cable at a place that far away.</span>"
		return


	if(U == T)		// do nothing if we clicked a cable we're standing on
		return		// may change later if can think of something logical to do

	var/dirn = get_dir(C, user)

	if(C.d1 == dirn || C.d2 == dirn)		// one end of the clicked cable is pointing towards us
		if(U.intact_tile)						// can't place a cable if the floor is complete
			user << "<span class='warning'>You can't lay cable there unless the floor tiles are removed.</span>"
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for(var/obj/structure/cable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					user << "<span class='warning'>There's already a cable at that position.</span>"
					return

			var/obj/structure/cable/NC = new(U)
			NC.cableColor(color)

			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint()
			NC.updateicon()

			if(C.powernet)
				NC.powernet = C.powernet
				NC.powernet.cables += NC
				NC.mergeConnectedNetworks(NC.d2)
				NC.mergeConnectedNetworksOnTurf()
			use(1)
			if (NC.shock(user, 50))
				if (prob(50)) //fail
					new/obj/item/stack/cable_coil(NC.loc, 1, NC.color)
					cdel(NC)

			return
	else if(C.d1 == 0)		// exisiting cable doesn't point at our position, so see if it's a stub
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn


		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/structure/cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				user << "<span class='warning'>There's already a cable at that position.</span>"
				return


		C.cableColor(color)

		C.d1 = nd1
		C.d2 = nd2

		C.add_fingerprint()
		C.updateicon()


		C.mergeConnectedNetworks(C.d1)
		C.mergeConnectedNetworks(C.d2)
		C.mergeConnectedNetworksOnTurf()

		use(1)
		if (C.shock(user, 50))
			if (prob(50)) //fail
				new/obj/item/stack/cable_coil(C.loc, 2, C.color)
				cdel(C)



/obj/item/stack/cable_coil/cut
	item_state = "coil2"

/obj/item/stack/cable_coil/cut/New(loc)
	..()
	src.amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	updateicon()
	update_wclass()

/obj/item/stack/cable_coil/yellow
	color = "#ffe28a"

/obj/item/stack/cable_coil/blue
	color = "#a8c1dd"

/obj/item/stack/cable_coil/green
	color = "#589471"

/obj/item/stack/cable_coil/pink
	color = "#6fcb9f"

/obj/item/stack/cable_coil/orange
	color = "#ff9845"

/obj/item/stack/cable_coil/cyan
	color = "#a8c1dd"

/obj/item/stack/cable_coil/white
	color = "#FFFFFF"

/obj/item/stack/cable_coil/random/New()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	..()

/obj/item/stack/cable_coil/attack(mob/M as mob, mob/user as mob)
	if(hasorgans(M))

		var/datum/limb/S = M:get_limb(user.zone_selected)
		if(!(S.status & LIMB_ROBOT) || user.a_intent != "help")
			return ..()

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.flags & IS_SYNTHETIC)
				if(M == user)
					user << "\red You can't repair damage to your own body - it's against OH&S."
					return

		if(S.burn_dam > 0 && use(1))
			S.heal_damage(0,15,0,1)
			user.visible_message("\red \The [user] repairs some burn damage on \the [M]'s [S.display_name] with \the [src].")
			return
		else
			user << "Nothing to fix!"

	else
		return ..()

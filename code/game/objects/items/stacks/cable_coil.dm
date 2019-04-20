// the cable coil object, used for laying cable
#define MAXCOIL 30

/obj/item/stack/cable_coil
	name = "cable coil"
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	amount = MAXCOIL
	max_amount = MAXCOIL
	var/item_color = "red"
	desc = "A coil of power cable."
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 5
	matter = list("metal" = 50, "glass" = 20)
	flags_equip_slot = ITEM_SLOT_BELT
	item_state = "coil"
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")


/obj/item/stack/cable_coil/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is strangling [p_them()]self with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return(OXYLOSS)

/obj/item/stack/cable_coil/Initialize(mapload, new_amount = MAXCOIL, param_color = null)
	. = ..()

	var/list/cable_colors = GLOB.cable_colors
	item_color = param_color || item_color || pick(cable_colors)
	if(cable_colors[item_color])
		color = cable_colors[item_color]
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()
	update_wclass()

/obj/item/stack/cable_coil/proc/updateicon()
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
		w_class = WEIGHT_CLASS_TINY
	else
		w_class = WEIGHT_CLASS_SMALL

/obj/item/stack/cable_coil/examine(mob/user)
	if(amount == 1)
		to_chat(user, "A short piece of power cable.")
	else if(amount == 2)
		to_chat(user, "A piece of power cable.")
	else
		to_chat(user, "A coil of power cable. There are [amount] lengths of cable in the coil.")

/obj/item/stack/cable_coil/verb/make_restraint()
	set name = "Make Cable Restraints"
	set category = "Object"
	var/mob/M = usr

	if(ishuman(M) && !M.incapacitated())
		if(!istype(usr.loc,/turf)) return
		if(amount <= 14)
			to_chat(usr, "<span class='warning'>You need at least 15 lengths to make restraints!</span>")
			return
		var/obj/item/handcuffs/cable/B = new /obj/item/handcuffs/cable(usr.loc)
		B.color = color
		to_chat(usr, "<span class='notice'>You wind some cable together to make some restraints.</span>")
		use(15)
	else
		to_chat(usr, "<span class='notice'><span class='notice'> You cannot do that.</span>")
	..()

/obj/item/stack/cable_coil/attackby(obj/item/W, mob/user)
	if(iswirecutter(W) && amount > 1)
		src.amount--
		new/obj/item/stack/cable_coil(user.loc, 1,item_color)
		to_chat(user, "<span class='notice'>You cut a piece off the cable coil.</span>")
		updateicon()
		update_wclass()
		return

	else if(iscablecoil(W))
		var/obj/item/stack/cable_coil/C = W
		if(C.amount >= MAXCOIL)
			to_chat(user, "The coil is too long, you cannot add any more cable to it.")
			return

		if( (C.amount + src.amount <= MAXCOIL) )
			to_chat(user, "You join the cable coils together.")
			C.add(src.amount) // give it cable
			use(src.amount) // make sure this one cleans up right

		else
			var/amt = MAXCOIL - C.amount
			to_chat(user, "You transfer [amt] length\s of cable from one coil to the other.")
			C.add(amt)
			use(amt)
		return
	..()

/obj/item/stack/cable_coil/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if (user.get_inactive_held_item() == src)
		var/obj/item/stack/cable_coil/F = new /obj/item/stack/cable_coil(user, 1, item_color)
		transfer_fingerprints_to(F)
		user.put_in_hands(F)
		use(1)
	else
		..()
    
/obj/item/stack/cable_coil/attack(mob/M as mob, mob/user as mob)
	if(hasorgans(M))
		var/datum/limb/S = M:get_limb(user.zone_selected)
		if(!(S.limb_status & LIMB_ROBOT) || user.a_intent == INTENT_HARM)
			return ..()

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.species_flags & IS_SYNTHETIC)
				if(M == user)
					to_chat(user, "<span class='warning'>You can't repair damage to your own body - it's against OH&S.</span>")
					return

		if(S.burn_dam > 0 && use(1))
			S.heal_damage(0,15,0,1)
			user.visible_message("<span class='warning'> \The [user] repairs some burn damage on \the [M]'s [S.display_name] with \the [src].</span>")
			return
		else
			to_chat(user, "Nothing to fix!")

	else
		return ..()

/obj/item/stack/cable_coil/proc/get_new_cable(location)
	var/path = /obj/structure/cable
	return new path(location, item_color)


/obj/item/stack/cable_coil/use(var/used)
	if( ..() )
		updateicon()
		update_wclass()
		return TRUE

/obj/item/stack/cable_coil/add(var/extra)
	if( ..() )
		updateicon()
		update_wclass()
		return TRUE

// called when cable_coil is clicked on a turf
/obj/item/stack/cable_coil/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || T.intact_tile || !T.can_have_cabling())
		to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
		return

	if(get_amount() < 1) // Out of cable
		to_chat(user, "<span class='warning'>There is no cable left!</span>")
		return

	if(get_dist(T,user) > 1) // Too far
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return

	var/dirn
	if(!dirnew) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == T)
			dirn = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(T, user)
	else
		dirn = dirnew

	for(var/obj/structure/cable/LC in T)
		if(LC.d2 == dirn && LC.d1 == CABLE_NODE)
			to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
			return

	var/obj/structure/cable/C = get_new_cable(T)

	//set up the new cable
	C.d1 = CABLE_NODE
	C.d2 = dirn
	C.add_fingerprint(user)
	C.update_icon()

	//create a new powernet with the cable, if needed it will be merged later
	var/datum/powernet/PN = new()
	PN.add_cable(C)

	C.mergeConnectedNetworks(C.d2) //merge the powernet with adjacents powernets
	C.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

	if(ISDIAGONALDIR(C.d2))// if the cable is layed diagonally, check the others 2 possible directions
		C.mergeDiagonalsNetworks(C.d2)

	use(1)

	if(C.shock(user, 50))
		if(prob(50)) //fail
			new /obj/item/stack/cable_coil(get_turf(C), 1, C.cable_color)
			C.deconstruct()

	return C

// called when cable_coil is click on an installed obj/cable
// or click on a turf that already contains a "node" cable
/obj/item/stack/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user, var/showerror = TRUE)
	var/turf/U = get_turf(user)
	if(!isturf(U))
		return

	var/turf/T = get_turf(C)

	if(!isturf(T) || T.intact_tile)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return


	if(U == T) //if clicked on the turf we're standing on, try to put a cable in the direction we're facing
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)

	// one end of the clicked cable is pointing towards us
	if(C.d1 == dirn || C.d2 == dirn)
		if(!U.can_have_cabling())						//checking if it's a plating or catwalk
			if (showerror)
				to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
			return
		if(U.intact_tile)						//can't place a cable if it's a plating with a tile on it
			to_chat(user, "<span class='warning'>You can't lay cable there unless the floor tiles are removed!</span>")
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for(var/obj/structure/cable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					if (showerror)
						to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
					return

			var/obj/structure/cable/NC = get_new_cable(U)

			NC.d1 = CABLE_NODE
			NC.d2 = fdirn
			NC.add_fingerprint(user)
			NC.update_icon()

			//create a new powernet with the cable, if needed it will be merged later
			var/datum/powernet/newPN = new()
			newPN.add_cable(NC)

			NC.mergeConnectedNetworks(NC.d2) //merge the powernet with adjacents powernets
			NC.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

			if(ISDIAGONALDIR(NC.d2))// if the cable is layed diagonally, check the others 2 possible directions
				NC.mergeDiagonalsNetworks(NC.d2)

			use(1)

			if (NC.shock(user, 50))
				if (prob(50)) //fail
					NC.deconstruct()

			return

	// exisiting cable doesn't point at our position, so see if it's a stub
	else if(C.d1 == CABLE_NODE)
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
				if (showerror)
					to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")

				return

		C.d1 = nd1
		C.d2 = nd2

		//updates the stored cable coil
		C.update_stored(2, item_color)
		C.cable_color = item_color

		C.add_fingerprint(user)
		C.update_icon()


		C.mergeConnectedNetworks(C.d1) //merge the powernets...
		C.mergeConnectedNetworks(C.d2) //...in the two new cable directions
		C.mergeConnectedNetworksOnTurf()

		if(ISDIAGONALDIR(C.d1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d1)

		if(ISDIAGONALDIR(C.d2))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)

		use(1)

		if (C.shock(user, 50))
			if (prob(50)) //fail
				C.deconstruct()
				return

		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.
	return

/obj/item/stack/cable_coil/single
	amount = 1

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
	item_color = "yellow"
	color = "#FFFF00"

/obj/item/stack/cable_coil/blue
	item_color = "blue"
	color = "#1919C8"

/obj/item/stack/cable_coil/green
	item_color = "green"
	color = "#00AA00"

/obj/item/stack/cable_coil/pink
	item_color = "pink"
	color = "#FF3CCD"

/obj/item/stack/cable_coil/orange
	item_color = "orange"
	color = "#FF8000"

/obj/item/stack/cable_coil/cyan
	item_color = "cyan"
	color = "#00FFFF"

/obj/item/stack/cable_coil/white
	item_color = "white"
	color = "#FFFFFF"

/obj/item/stack/cable_coil/random/New()
	item_color = pick("red", "blue", "green", "white", "pink", "yellow", "cyan")
	..()

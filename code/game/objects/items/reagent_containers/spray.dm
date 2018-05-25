/obj/item/reagent_container/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/items/spray.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	flags_atom = OPENCONTAINER|FPRINT
	flags_item = NOBLUDGEON
	flags_equip_slot = SLOT_WAIST
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10) //Set to null instead of list, if there is only one.
	var/spray_size = 3
	var/list/spray_sizes = list(1,3)
	var/safety = FALSE
	volume = 250


/obj/item/reagent_container/spray/New()
	..()
	src.verbs -= /obj/item/reagent_container/verb/set_APTFT

/obj/item/reagent_container/spray/afterattack(atom/A, mob/user, proximity)
	//this is what you get for using afterattack() TODO: make is so this is only called if attackby() returns 0 or something
	if(istype(A, /obj/item/storage) || istype(A, /obj/structure/table) || istype(A, /obj/structure/rack) || istype(A, /obj/structure/closet) \
	|| istype(A, /obj/item/reagent_container) || istype(A, /obj/structure/sink) || istype(A, /obj/structure/janitorialcart || istype(A, /obj/structure/ladder)))
		return

	if(istype(A, /obj/effect/proc_holder/spell))
		return

	if(istype(A, /obj/structure/reagent_dispensers) && get_dist(src,A) <= 1) //this block copypasted from reagent_containers/glass, for lack of a better solution
		if(!A.reagents.total_volume && A.reagents)
			user << "<span class='notice'>\The [A] is empty.</span>"
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			user << "<span class='notice'>\The [src] is full.</span>"
			return

		var/trans = A.reagents.trans_to(src, A:amount_per_transfer_from_this)
		user << "<span class='notice'>You fill \the [src] with [trans] units of the contents of \the [A].</span>"
		return

	if(reagents.total_volume < amount_per_transfer_from_this)
		user << "<span class='notice'>\The [src] is empty!</span>"
		return

	if(safety)
		user << "<span class = 'warning'>The safety is on!</span>"
		return

	Spray_at(A)

	playsound(src.loc, 'sound/effects/spray2.ogg', 25, 1, 3)

	for(var/X in reagents.reagent_list)
		var/datum/reagent/R = X
		if(R.spray_warning)
			message_admins("[key_name_admin(user)] fired [R.name] from \a [src].")
			log_game("[key_name(user)] fired [R.name] from \a [src].")

/obj/item/reagent_container/spray/proc/Spray_at(atom/A)
	var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(src))
	D.create_reagents(amount_per_transfer_from_this)
	reagents.trans_to(D, amount_per_transfer_from_this, 1/spray_size)
	D.color = mix_color_from_reagents(D.reagents.reagent_list)

	var/turf/A_turf = get_turf(A)//BS12

	var/spray_dist = spray_size
	spawn(0)
		for(var/i=0, i<spray_dist, i++)
			step_towards(D,A)
			D.reagents.reaction(get_turf(D))
			for(var/atom/T in get_turf(D))
				D.reagents.reaction(T)

				// When spraying against the wall, also react with the wall, but
				// not its contents. BS12
				if(get_dist(D, A_turf) == 1 && A_turf.density)
					D.reagents.reaction(A_turf)
				sleep(2)
			sleep(3)
		cdel(D)


/obj/item/reagent_container/spray/attack_self(var/mob/user)
	if(!possible_transfer_amounts)
		return
	amount_per_transfer_from_this = next_in_list(amount_per_transfer_from_this, possible_transfer_amounts)
	spray_size = next_in_list(spray_size, spray_sizes)
	user << "<span class='notice'>You adjusted the pressure nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>"


/obj/item/reagent_container/spray/examine(mob/user)
	..()
	user << "[round(reagents.total_volume)] units left."

/obj/item/reagent_container/spray/verb/empty()

	set name = "Empty Spray Bottle"
	set category = "Object"
	set src in usr

	if (alert(usr, "Are you sure you want to empty that?", "Empty Bottle:", "Yes", "No") != "Yes")
		return
	if(isturf(usr.loc))
		usr << "<span class='notice'>You empty \the [src] onto the floor.</span>"
		reagents.reaction(usr.loc)
		spawn(5) src.reagents.clear_reagents()

//space cleaner
/obj/item/reagent_container/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"

/obj/item/reagent_container/spray/cleaner/drone
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	volume = 50

/obj/item/reagent_container/spray/cleaner/New()
	..()
	reagents.add_reagent("cleaner", src.volume)
//pepperspray
/obj/item/reagent_container/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly."
	icon_state = "pepperspray"
	item_state = "pepperspray"
	possible_transfer_amounts = null
	volume = 40
	safety = TRUE


/obj/item/reagent_container/spray/pepper/New()
	..()
	reagents.add_reagent("condensedcapsaicin", 40)

/obj/item/reagent_container/spray/pepper/examine(mob/user)
	..()
	if(get_dist(user,src) <= 1)
		user << "The safety is [safety ? "on" : "off"]."

/obj/item/reagent_container/spray/pepper/attack_self(mob/user)
	safety = !safety
	user << "<span class = 'notice'>You switch the safety [safety ? "on" : "off"].</span>"

//water flower
/obj/item/reagent_container/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = null
	volume = 10

/obj/item/reagent_container/spray/waterflower/New()
	..()
	reagents.add_reagent("water", 10)

//chemsprayer
/obj/item/reagent_container/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagent in a given area."
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 3
	w_class = 3.0
	possible_transfer_amounts = null
	volume = 600
	origin_tech = "combat=3;materials=3;engineering=3"


//this is a big copypasta clusterfuck, but it's still better than it used to be!
/obj/item/reagent_container/spray/chemsprayer/Spray_at(atom/A as mob|obj)
	var/Sprays[3]
	for(var/i=1, i<=3, i++) // intialize sprays
		if(src.reagents.total_volume < 1) break
		var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(src))
		D.create_reagents(amount_per_transfer_from_this)
		src.reagents.trans_to(D, amount_per_transfer_from_this)

		D.color = mix_color_from_reagents(D.reagents.reagent_list)

		Sprays[i] = D

	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)

	for(var/i=1, i<=Sprays.len, i++)
		spawn()
			var/obj/effect/decal/chempuff/D = Sprays[i]
			if(!D) continue

			// Spreads the sprays a little bit
			var/turf/my_target = pick(the_targets)
			the_targets -= my_target

			for(var/j=1, j<=rand(6,8), j++)
				step_towards(D, my_target)
				D.reagents.reaction(get_turf(D))
				for(var/atom/t in get_turf(D))
					D.reagents.reaction(t)
				sleep(2)
			cdel(D)

	return

// Plant-B-Gone
/obj/item/reagent_container/spray/plantbgone // -- Skie
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon_state = "plantbgone"
	item_state = "plantbgone"
	volume = 100


/obj/item/reagent_container/spray/plantbgone/New()
	..()
	reagents.add_reagent("plantbgone", 100)


/obj/item/reagent_container/spray/plantbgone/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	..()

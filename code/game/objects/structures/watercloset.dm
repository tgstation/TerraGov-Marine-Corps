//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos

/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = FALSE
	anchored = TRUE
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie

/obj/structure/toilet/Initialize()
	. = ..()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(swirlie)
		user.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie.name]'s head!</span>", "<span class='notice'>You slam the toilet seat onto [swirlie.name]'s head!</span>", "You hear reverberating porcelain.")
		swirlie.apply_damage(8, BRUTE)
		UPDATEHEALTH(swirlie)
		return

	if(cistern && !open)
		if(!contents.len)
			to_chat(user, "<span class='notice'>The cistern is empty.</span>")
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.loc = get_turf(src)
			to_chat(user, "<span class='notice'>You find \an [I] in the cistern.</span>")
			w_items -= I.w_class
			return

	open = !open
	update_icon()

/obj/structure/toilet/update_icon()
	icon_state = "toilet[open][cistern]"

/obj/structure/toilet/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iscrowbar(I))
		to_chat(user, "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"].</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 25, 1)

		if(!do_after(user, 30, TRUE, src, BUSY_ICON_BUILD))
			return

		user.visible_message("<span class='notice'>[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!</span>", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "You hear grinding porcelain.")
		cistern = !cistern
		update_icon()

	else if(istype(I, /obj/item/grab))
		if(isxeno(user))
			return
		var/obj/item/grab/G = I

		if(!iscarbon(G.grabbed_thing))
			return

		var/mob/living/carbon/C = G.grabbed_thing

		if(user.grab_state <= GRAB_PASSIVE)
			to_chat(user, "<span class='notice'>You need a tighter grip.</span>")
			return

		if(!C.loc == get_turf(src))
			to_chat(user, "<span class='notice'>[C] needs to be on the toilet.</span>")
			return

		if(open && !swirlie)
			user.visible_message("<span class='danger'>[user] starts to give [C] a swirlie!</span>", "<span class='notice'>You start to give [C] a swirlie!</span>")
			swirlie = C
			if(!do_after(user, 30, TRUE, src, BUSY_ICON_HOSTILE))
				return

			user.visible_message("<span class='danger'>[user] gives [C] a swirlie!</span>", "<span class='notice'>You give [C] a swirlie!</span>", "You hear a toilet flushing.")
			log_combat(user, C, "given a swirlie")
			if(!C.internal)
				C.adjustOxyLoss(5)
			swirlie = null
		else
			user.visible_message("<span class='danger'>[user] slams [C] into the [src]!</span>", "<span class='notice'>You slam [C] into the [src]!</span>")
			log_combat(user, C, "slammed", "", "into the \the [src]")
			C.apply_damage(8, BRUTE)
			UPDATEHEALTH(C)

	else if(cistern && !issilicon(user)) //STOP PUTTING YOUR MODULES IN THE TOILET.
		if(I.w_class > 3)
			to_chat(user, "<span class='notice'>\The [I] does not fit.</span>")
			return

		if(w_items + I.w_class > 5)
			to_chat(user, "<span class='notice'>The cistern is full.</span>")
			return

		user.drop_held_item()
		I.forceMove(src)
		w_items += I.w_class
		to_chat(user, "You carefully place \the [I] into the cistern.")

/obj/structure/toilet/alternate
	icon_state = "toilet200"

/obj/structure/toilet/alternate/update_icon()
	icon_state = "toilet2[open][cistern]"

/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = FALSE
	anchored = TRUE

/obj/structure/urinal/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/grab))
		if(isxeno(user))
			return
		var/obj/item/grab/G = I
		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/GM = G.grabbed_thing
		if(user.grab_state <= GRAB_PASSIVE)
			to_chat(user, "<span class='notice'>You need a tighter grip.</span>")
			return

		if(!GM.loc == get_turf(src))
			to_chat(user, "<span class='notice'>[GM] needs to be on the urinal.</span>")
			return

		user.visible_message("<span class='danger'>[user] slams [GM] into the [src]!</span>", "<span class='notice'>You slam [GM] into the [src]!</span>")
		GM.apply_damage(8, BRUTE)
		UPDATEHEALTH(GM)


/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2050s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	anchored = TRUE
	use_power = 0
	var/on = 0
	var/obj/effect/mist/mymist = null
	var/ismist = 0				//needs a var so we can make it linger~
	var/watertemp = "normal"	//freezing, normal, or boiling
	var/mobpresent = 0		//true if there is a mob on the shower's loc, this is to ease process()
	var/is_washing = 0

/obj/machinery/shower/Initialize()
	. = ..()
	create_reagents(2)


/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = 0

/obj/machinery/shower/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	on = !on
	update_icon()
	if(on)
		start_processing()
		if (user.loc == loc)
			wash(user)
			check_heat(user)
		for (var/atom/movable/G in src.loc)
			G.clean_blood()
	else
		stop_processing()

/obj/machinery/shower/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(I.type == /obj/item/analyzer)
		to_chat(user, "<span class='notice'>The water temperature seems to be [watertemp].</span>")

	else if(iswrench(I))
		to_chat(user, "<span class='notice'>You begin to adjust the temperature valve with \the [I].</span>")

		if(!do_after(user, 50, TRUE, src, BUSY_ICON_BUILD))
			return

		switch(watertemp)
			if("normal")
				watertemp = "freezing"
			if("freezing")
				watertemp = "boiling"
			if("boiling")
				watertemp = "normal"
		user.visible_message("<span class='notice'>[user] adjusts the shower with \the [I].</span>", "<span class='notice'>You adjust the shower with \the [I].</span>")

/obj/machinery/shower/update_icon()	//this is terribly unreadable, but basically it makes the shower mist up
	overlays.Cut()					//once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		qdel(mymist)
		mymist = null

	if(on)
		overlays += image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir)
		if(watertemp == "freezing")
			return
		if(!ismist)
			spawn(50)
				if(src && on)
					ismist = 1
					mymist = new /obj/effect/mist(loc)
		else
			ismist = 1
			mymist = new /obj/effect/mist(loc)
	else if(ismist)
		ismist = 1
		mymist = new /obj/effect/mist(loc)
		spawn(250)
			if(src && !on)
				qdel(mymist)
				mymist = null
				ismist = 0

/obj/machinery/shower/Crossed(atom/movable/O)
	..()
	wash(O)
	if(ismob(O))
		mobpresent += 1
		check_heat(O)

/obj/machinery/shower/Uncrossed(atom/movable/O)
	if(ismob(O))
		mobpresent -= 1
	..()

//Yes, showers are super powerful as far as washing goes.
/obj/machinery/shower/proc/wash(atom/movable/O as obj|mob)
	if(!on) return


	if(isliving(O))
		var/mob/living/L = O
		L.ExtinguishMob()
		L.fire_stacks = -20 //Douse ourselves with water to avoid fire more easily
		to_chat(L, "<span class='warning'>You've been drenched in water!</span>")
		if(iscarbon(O))
			var/mob/living/carbon/M = O
			if(M.r_hand)
				M.r_hand.clean_blood()
			if(M.l_hand)
				M.l_hand.clean_blood()
			if(M.back)
				if(M.back.clean_blood())
					M.update_inv_back(0)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/washgloves = 1
				var/washshoes = 1
				var/washmask = 1
				var/washears = 1
				var/washglasses = 1

				if(H.wear_suit)
					washgloves = !(H.wear_suit.flags_inv_hide & HIDEGLOVES)
					washshoes = !(H.wear_suit.flags_inv_hide & HIDESHOES)

				if(H.head)
					washmask = !(H.head.flags_inv_hide & HIDEMASK)
					washglasses = !(H.head.flags_inv_hide & HIDEEYES)
					washears = !(H.head.flags_inv_hide & HIDEEARS)

				if(H.wear_mask)
					if (washears)
						washears = !(H.wear_mask.flags_inv_hide & HIDEEARS)
					if (washglasses)
						washglasses = !(H.wear_mask.flags_inv_hide & HIDEEYES)

				if(H.head)
					if(H.head.clean_blood())
						H.update_inv_head()
				if(H.wear_suit)
					if(H.wear_suit.clean_blood())
						H.update_inv_wear_suit()
				else if(H.w_uniform)
					if(H.w_uniform.clean_blood())
						H.update_inv_w_uniform()
				if(H.gloves && washgloves)
					if(H.gloves.clean_blood())
						H.update_inv_gloves()
				if(H.shoes && washshoes)
					if(H.shoes.clean_blood())
						H.update_inv_shoes()
				if(H.wear_mask && washmask)
					if(H.wear_mask.clean_blood())
						H.update_inv_wear_mask()
				if(H.glasses && washglasses)
					if(H.glasses.clean_blood())
						H.update_inv_glasses()
				if(H.wear_ear && washears)
					if(H.wear_ear.clean_blood())
						H.update_inv_ears()
				if(H.belt)
					if(H.belt.clean_blood())
						H.update_inv_belt()
				H.clean_blood(washshoes)
			else
				if(M.wear_mask)						//if the mob is not human, it cleans the mask without asking for bitflags
					if(M.wear_mask.clean_blood())
						M.update_inv_wear_mask()
				M.clean_blood()
		else
			O.clean_blood()

	if(isturf(loc))
		var/turf/tile = loc
		loc.clean_blood()
		for(var/obj/effect/E in tile)
			if(istype(E,/obj/effect/rune) || istype(E,/obj/effect/decal/cleanable) || istype(E,/obj/effect/overlay))
				qdel(E)

/obj/machinery/shower/process()
	if(!on) return
	wash_floor()
	if(!mobpresent)	return
	for(var/mob/living/carbon/C in loc)
		check_heat(C)

/obj/machinery/shower/proc/wash_floor()
	if(!ismist && is_washing)
		return
	is_washing = 1
	var/turf/T = get_turf(src)
//	reagents.add_reagent(/datum/reagent/water, 2)
	T.clean(src)
	spawn(100)
		is_washing = 0

/obj/machinery/shower/proc/check_heat(mob/M as mob)
	if(!on || watertemp == "normal") return
	if(iscarbon(M))
		var/mob/living/carbon/C = M

		if(watertemp == "freezing")
			C.adjust_bodytemperature(C.bodytemperature - 80, 80)
			to_chat(C, "<span class='warning'>The water is freezing!</span>")
			return
		if(watertemp == "boiling")
			C.adjust_bodytemperature(C.bodytemperature + 35, 0, 500)
			to_chat(C, "<span class='danger'>The water is searing!</span>")
			return



/obj/item/toy/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"



/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = TRUE
	var/busy = 0 	//Something's being washed at the moment

/obj/structure/sink/Initialize()
	. = ..()
	switch(dir)
		if(WEST)
			pixel_x = -12
		if(NORTH)
			pixel_y = -10
		if(EAST)
			pixel_x = 12

/obj/structure/sink/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(isAI(user))
		return

	if(!Adjacent(user))
		return

	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here.</span>")
		return

	to_chat(usr, "<span class='notice'>You start washing your hands.</span>")

	busy = 1
	sleep(40)
	busy = 0

	if(!Adjacent(user)) return		//Person has moved away from the sink

	user.clean_blood()
	if(ishuman(user))
		user:update_inv_gloves()
	visible_message("<span class='notice'>[user] washes their hands using \the [src].</span>")


/obj/structure/sink/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here.</span>")
		return

	var/obj/item/reagent_containers/RG = I
	if(istype(RG) && RG.is_open_container() && RG.reagents.total_volume < RG.reagents.maximum_volume)
		RG.reagents.add_reagent(/datum/reagent/water, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message("<span class='notice'> [user] fills \the [RG] using \the [src].</span>","<span class='notice'> You fill \the [RG] using \the [src].</span>")
		return

	else if(istype(I, /obj/item/weapon/baton))
		var/obj/item/weapon/baton/B = I
		if(!B.bcell)
			return

		if(B.bcell.charge <= 0 || B.status != 1)
			return

		if(!isliving(user))
			return

		var/mob/living/L = user

		flick("baton_active", src)
		L.Stun(20 SECONDS)
		L.stuttering = 10
		L.Paralyze(20 SECONDS)
		L.visible_message("<span class='danger'>[L] was stunned by [L.p_their()] wet [I]!</span>")

	if(I.flags_item & ITEM_ABSTRACT)
		return

	var/turf/location = user.loc
	if(!isturf(location))
		return

	to_chat(usr, "<span class='notice'>You start washing \the [I].</span>")

	if(!do_after(user, 30, TRUE, src, BUSY_ICON_BUILD))
		return

	if(user.loc != location || user.get_active_held_item() != I)
		return

	I.clean_blood()
	user.visible_message( \
		"<span class='notice'> [user] washes \a [I] using \the [src].</span>", \
		"<span class='notice'> You wash \a [I] using \the [src].</span>")


/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink2"

/obj/structure/sink/bathroom
	name = "bathroom sink"
	icon_state = "sink3"

/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	icon_state = "puddle"

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/sink/puddle/attack_hand(mob/living/user)
	icon_state = "puddle-splash"
	. = ..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/I, mob/user, params)
	icon_state = "puddle-splash"
	. = ..()
	icon_state = "puddle"

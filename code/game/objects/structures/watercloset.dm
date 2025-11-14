#define WATER_TEMP_NORMAL "normal"
#define WATER_TEMP_FREEZING "freezing"
#define WATER_TEMP_BOILING "boiling"
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

/obj/structure/toilet/Initialize(mapload)
	. = ..()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(swirlie)
		user.visible_message(span_danger("[user] slams the toilet seat onto [swirlie.name]'s head!"), span_notice("You slam the toilet seat onto [swirlie.name]'s head!"), "You hear reverberating porcelain.")
		swirlie.apply_damage(8, BRUTE, blocked = MELEE, updating_health = TRUE, attacker = user)
		return

	if(cistern && !open)
		if(!length(contents))
			to_chat(user, span_notice("The cistern is empty."))
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.forceMove(drop_location())
			to_chat(user, span_notice("You find \an [I] in the cistern."))
			w_items -= I.w_class
			return

	open = !open
	update_icon()

/obj/structure/toilet/update_icon_state()
	. = ..()
	icon_state = "toilet[open][cistern]"

/obj/structure/toilet/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(iscrowbar(I))
		to_chat(user, span_notice("You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]."))
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 25, 1)

		if(!do_after(user, 3 SECONDS, NONE, src, BUSY_ICON_BUILD))
			return

		user.visible_message(span_notice("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!"), span_notice("You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!"), "You hear grinding porcelain.")
		cistern = !cistern
		update_icon()

	else if(cistern && !issilicon(user)) //STOP PUTTING YOUR MODULES IN THE TOILET.
		if(I.w_class > 3)
			to_chat(user, span_notice("\The [I] does not fit."))
			return

		if(w_items + I.w_class > 5)
			to_chat(user, span_notice("The cistern is full."))
			return

		user.drop_held_item()
		I.forceMove(src)
		w_items += I.w_class
		to_chat(user, "You carefully place \the [I] into the cistern.")

/obj/structure/toilet/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	. = ..()
	if(.)
		return
	if(isxeno(user))
		return
	if(!iscarbon(grab.grabbed_thing))
		return
	if(!open || swirlie)
		return

	var/mob/living/carbon/grabbed_mob = grab.grabbed_thing

	if(user.grab_state <= GRAB_PASSIVE)
		to_chat(user, span_notice("You need a tighter grip."))
		return

	if(!grabbed_mob.loc == get_turf(src))
		to_chat(user, span_notice("[grabbed_mob] needs to be on the toilet."))
		return

	user.visible_message(span_danger("[user] starts to give [grabbed_mob] a swirlie!"), span_notice("You start to give [grabbed_mob] a swirlie!"))
	swirlie = grabbed_mob
	if(!do_after(user, 3 SECONDS, NONE, src, BUSY_ICON_HOSTILE))
		return

	user.visible_message(span_danger("[user] gives [grabbed_mob] a swirlie!"), span_notice("You give [grabbed_mob] a swirlie!"), "You hear a toilet flushing.")
	log_combat(user, grabbed_mob, "given a swirlie")
	if(!grabbed_mob.internal)
		grabbed_mob.adjustOxyLoss(5)
	swirlie = null

/obj/structure/toilet/alternate
	icon_state = "toilet200"

/obj/structure/toilet/alternate/update_icon_state()
	. = ..()
	icon_state = "toilet2[open][cistern]"

/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = FALSE
	anchored = TRUE

/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2050s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	anchored = TRUE
	use_power = NO_POWER_USE
	var/on = FALSE
	var/obj/effect/mist/mymist = null
	var/ismist = FALSE //needs a var so we can make it linger~
	/// freezing, normal, or boiling
	var/watertemp = WATER_TEMP_NORMAL
	/// Count of mobs present under the shower, this is to ease process()
	var/mobpresent = 0
	var/is_washing = FALSE

/obj/machinery/shower/Initialize(mapload)
	. = ..()
	create_reagents(2)
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, connections)


/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/machinery/shower/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	on = !on
	update_mist()
	if(on)
		start_processing()
		if (user.loc == loc)
			wash_atom(user)
			check_heat(user)
		for (var/atom/movable/G in src.loc)
			G.wash()
	else
		stop_processing()

/obj/machinery/shower/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(I.type == /obj/item/tool/analyzer)
		to_chat(user, span_notice("The water temperature seems to be [watertemp]."))

	else if(iswrench(I))
		to_chat(user, span_notice("You begin to adjust the temperature valve with \the [I]."))

		if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_BUILD))
			return

		switch(watertemp)
			if(WATER_TEMP_NORMAL)
				watertemp = "freezing"
			if(WATER_TEMP_FREEZING)
				watertemp = "boiling"
			if(WATER_TEMP_BOILING)
				watertemp = "normal"
		user.visible_message(span_notice("[user] adjusts the shower with \the [I]."), span_notice("You adjust the shower with \the [I]."))

/obj/machinery/shower/proc/update_mist()
//this is terribly unreadable, but basically it makes the shower mist up once it's been on for a while
	update_icon()
	if(mymist)
		qdel(mymist)
		mymist = null

	if(on)
		overlays += image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir)
		if(watertemp == WATER_TEMP_FREEZING)
			return
		if(!ismist)
			spawn(50)
				if(src && on)
					ismist = TRUE
					mymist = new /obj/effect/mist(loc)
		else
			ismist = TRUE
			mymist = new /obj/effect/mist(loc)
	else if(ismist)
		ismist = TRUE
		mymist = new /obj/effect/mist(loc)
		spawn(250)
			if(src && !on)
				qdel(mymist)
				mymist = null
				ismist = FALSE

/obj/machinery/shower/update_overlays()
	. = ..()
	if(on)
		. += image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir)

/obj/machinery/shower/proc/on_cross(datum/source, atom/movable/O, oldloc, oldlocs)
	SIGNAL_HANDLER
	wash_atom(O)
	if(ismob(O))
		mobpresent += 1
		check_heat(O)

/obj/machinery/shower/proc/on_exited(datum/source, atom/movable/O, direction)
	if(ismob(O))
		mobpresent -= 1

//Yes, showers are super powerful as far as washing goes.
/obj/machinery/shower/proc/wash_atom(atom/movable/O as obj|mob)
	if(!on)
		return

	if(isliving(O))
		var/mob/living/L = O
		L.ExtinguishMob()
		L.fire_stacks = -20 //Douse ourselves with water to avoid fire more easily
		to_chat(L, span_warning("You've been drenched in water!"))
		L.wash()
	else
		O.wash()

/obj/machinery/shower/process()
	if(!on)
		return
	wash_floor()
	if(!mobpresent)
		return
	for(var/mob/living/carbon/C in loc)
		check_heat(C)

/obj/machinery/shower/proc/wash_floor()
	if(!ismist && is_washing)
		return
	is_washing = TRUE
	addtimer(VARSET_CALLBACK(src, is_washing, FALSE), 10 SECONDS)
	var/turf/T = get_turf(src)
	T.wash()

/obj/machinery/shower/proc/check_heat(mob/M)
	if(!on || watertemp == WATER_TEMP_NORMAL)
		return
	if(iscarbon(M))
		var/mob/living/carbon/C = M

		if(watertemp == WATER_TEMP_FREEZING)
			C.adjust_bodytemperature(-80, 80)
			to_chat(C, span_warning("The water is freezing!"))
			return
		if(watertemp == WATER_TEMP_BOILING)
			C.adjust_bodytemperature(35, 0, 500)
			to_chat(C, span_danger("The water is searing!"))
			return



/obj/item/toy/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	worn_icon_state = "rubberducky"



/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	///is someone currently washing at this sink?
	var/busy = FALSE

/obj/structure/sink/Initialize(mapload)
	. = ..()
	switch(dir)
		if(WEST)
			pixel_x = -11
		if(NORTH)
			pixel_y = -9
		if(EAST)
			pixel_x = 11
		if(SOUTH)
			pixel_y = 25

/obj/structure/sink/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!ishuman(user) || !Adjacent(user))
		return

	if(busy)
		balloon_alert_to_viewers("someone else is washing!")
		return

	balloon_alert_to_viewers("washing hands...")
	playsound(loc, 'sound/effects/sink_long.ogg', 25, 1)

	busy = TRUE
	if(!do_after(user, 4 SECONDS, NONE, src, BUSY_ICON_GENERIC))
		busy = FALSE
		balloon_alert_to_viewers("stops washing")
		return
	busy = FALSE

	user.wash()
	user:update_inv_gloves()
	balloon_alert_to_viewers("washes their hands")


/obj/structure/sink/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(busy)
		to_chat(user, span_warning("Someone's already washing here."))
		return

	var/obj/item/reagent_containers/RG = I
	if(istype(RG) && RG.is_open_container() && RG.reagents.total_volume < RG.reagents.maximum_volume)
		RG.reagents.add_reagent(/datum/reagent/water, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message(span_notice("[user] fills \the [RG] using \the [src]."),span_notice("You fill \the [RG] using \the [src]."))
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
		L.set_timed_status_effect(20 SECONDS, /datum/status_effect/speech/stutter)
		L.Paralyze(20 SECONDS)
		L.visible_message(span_danger("[L] was stunned by [L.p_their()] wet [I]!"))

	if(I.item_flags & ITEM_ABSTRACT)
		return

	var/turf/location = user.loc
	if(!isturf(location))
		return

	to_chat(usr, span_notice("You start washing \the [I]."))

	if(!do_after(user, 3 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return

	if(user.loc != location || user.get_active_held_item() != I)
		return

	I.wash()
	user.visible_message( \
		span_notice("[user] washes \a [I] using \the [src]."), \
		span_notice("You wash \a [I] using \the [src]."))


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


#undef WATER_TEMP_NORMAL
#undef WATER_TEMP_FREEZING
#undef WATER_TEMP_BOILING

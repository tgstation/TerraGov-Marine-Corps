
/obj/machinery/gibber
	name = "Gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	anchored = TRUE
	density = TRUE
	coverage = 25
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/mob/living/occupant // Mob who has been put inside
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 1000


/obj/machinery/gibber/Initialize(mapload)
	. = ..()
	overlays += image('icons/obj/kitchen.dmi', "grjam")

/obj/machinery/gibber/update_overlays()
	. = ..()
	if(dirty)
		. += image('icons/obj/kitchen.dmi', "grbloody")

	if(machine_stat & (NOPOWER|BROKEN))
		return

	if (!occupant)
		. += image('icons/obj/kitchen.dmi', "grjam")
	else if (operating)
		. += image('icons/obj/kitchen.dmi', "gruse")
	else
		. += image('icons/obj/kitchen.dmi', "gridle")

/obj/machinery/gibber/relaymove(mob/user)
	if(user.incapacitated(TRUE))
		return
	go_out()


/obj/machinery/gibber/interact(mob/user)
	. = ..()
	if(.)
		return
	if(operating)
		to_chat(user, span_warning("It's locked and running"))
		return

	activate_gibber(user)

/obj/machinery/gibber/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	if(!is_operational())
		return ..()
	if(occupant)
		to_chat(user, span_warning("The gibber is full, empty it first!"))
		return
	var/mob/living/grabbed_mob = grab.grabbed_thing
	if(!iscarbon(grabbed_mob) && !istype(grabbed_mob, /mob/living/simple_animal))
		to_chat(user, span_warning("This item is not suitable for the gibber!"))
		return
	if(user.grab_state < GRAB_AGGRESSIVE)
		to_chat(user, span_warning("You need a better grip to do that!"))
		return
	if(grabbed_mob.abiotic(TRUE))
		to_chat(user, span_warning("Subject may not have abiotic items on."))
		return
	user.visible_message(span_danger("[user] starts to put [grabbed_mob] into the gibber!"))

	if(!do_after(user, 30, NONE, grabbed_mob, BUSY_ICON_DANGER) || QDELETED(src) || occupant)
		return

	user.visible_message(span_danger("[user] stuffs [grabbed_mob] into the gibber!"))
	grabbed_mob.forceMove(src)
	occupant = grabbed_mob
	update_icon()
	return TRUE

/obj/machinery/gibber/verb/eject()
	set category = "IC.Object"
	set name = "Empty Gibber"
	set src in oview(1)

	if (usr.stat != 0)
		return
	go_out()

/obj/machinery/gibber/proc/go_out()
	if (!occupant)
		return
	for(var/obj/O in src)
		O.loc = loc
	if (occupant.client)
		occupant.client.set_eye(occupant.client.mob)
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant.loc = loc
	occupant = null
	update_icon()


///Gibs the victim, and sets the output
/obj/machinery/gibber/proc/activate_gibber(mob/user as mob)
	if(operating)
		return
	if(!occupant)
		visible_message(span_warning("You hear a loud metallic grinding sound."))
		return
	use_power(active_power_usage)
	visible_message(span_warning("You hear a loud squelchy grinding sound."))
	playsound(loc, 'sound/machines/juicer.ogg', 50, TRUE)
	operating = TRUE
	update_icon()

	var/totalslabs = 3
	var/typeofmeat = /obj/item/reagent_containers/food/snacks/meat
	var/list/allmeat = list()
	var/sourcename = occupant.name
	var/sourcenutriment = 0
	var/sourcetotalreagents = 0
	var/gibtype = /obj/effect/decal/cleanable/blood/gibs

	if(iscarbon(occupant))
		var/mob/living/carbon/C = occupant
		sourcenutriment = C.nutrition / 15
		sourcetotalreagents = occupant.reagents.total_volume

		if(ishuman(occupant))
			typeofmeat = /obj/item/reagent_containers/food/snacks/meat/human
			sourcename = occupant.real_name
		else if(ismonkey(occupant))
			typeofmeat = /obj/item/reagent_containers/food/snacks/meat/monkey
		else if(isxeno(occupant))
			totalslabs = 4
			typeofmeat = /obj/item/reagent_containers/food/snacks/meat/xeno
			gibtype = /obj/effect/decal/cleanable/blood/gibs/xeno
	else
		if(istype(occupant, /mob/living/simple_animal/cow) || istype(occupant, /mob/living/simple_animal/hostile/bear))
			totalslabs = 4
			sourcenutriment = 26
		else //whatever else
			totalslabs = 1
			sourcenutriment = 13

	for(var/i=1 to totalslabs)
		var/obj/item/reagent_containers/food/snacks/meat/newmeat = new typeofmeat
		newmeat.name = "[sourcename]-[newmeat.name]"
		newmeat.reagents.add_reagent(/datum/reagent/consumable/nutriment, sourcenutriment / totalslabs)
		if(iscarbon(occupant))
			occupant.reagents.trans_to(newmeat, round (sourcetotalreagents / totalslabs, 1))
		allmeat += newmeat

	if(occupant.client)
		log_combat(occupant, user, "gibbed")

	occupant.death(silent = TRUE)
	occupant.ghostize()
	qdel(occupant)
	occupant = null

	addtimer(CALLBACK(src, PROC_REF(make_meat), allmeat, totalslabs, gibtype), gibtime)

///Creates the output
/obj/machinery/gibber/proc/make_meat(list/meatlist, meat_produced, gibtype)
	var/turf/T = get_turf(src)
	var/list/turf/nearby_turfs = RANGE_TURFS(3, T) - T

	if(meat_produced)
		for(var/i=1 to meat_produced)
			var/obj/item/meatslab = meatlist[i]
			meatslab.forceMove(loc)
			meatslab.throw_at(pick(nearby_turfs),i,3)
			for(var/turfs=1 to meat_produced)
				var/turf/gibturf = pick(nearby_turfs)
				if(!gibturf.density && (src in view(gibturf)))
					new gibtype(gibturf,i)

	playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
	operating = FALSE
	update_icon()

/obj/machinery/gibber/nopower
	use_power = NO_POWER_USE

/obj/machinery/gibber/apc
	use_power = NO_POWER_USE
	var/obj/item/reagent_containers/glass/beaker/bluespace/internal_beaker

/obj/machinery/gibber/apc/Initialize(mapload)
	. = ..()
	internal_beaker = new(src)

/obj/machinery/gibber/apc/Destroy()
	qdel(internal_beaker)
	return ..()

/obj/machinery/gibber/apc/make_meat(list/meatlist, meat_produced, gibtype)
	if(!internal_beaker)
		return ..()

	for(var/obj/item/meatslab AS in meatlist)
		var/biomass_amount = 0
		biomass_amount += 1 + floor(meatslab.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment) * 0.5)
		meatlist -= meatslab
		meat_produced --
		internal_beaker.reagents.add_reagent(/datum/reagent/medicine/biomass, biomass_amount)
		if(internal_beaker.reagents.holder_full())
			break

	return ..()

/obj/machinery/gibber/apc/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(internal_beaker)
		return
	if(!istype(I, /obj/item/reagent_containers/glass/beaker))
		balloon_alert(user, "not a beaker!")
		return
	user.transferItemToLoc(I, src)
	internal_beaker = I
	balloon_alert(user, "beaker added")

/obj/machinery/gibber/apc/interact(mob/user)
	. = ..()
	if(.)
		return
	if(operating)
		return
	if(!internal_beaker)
		return
	internal_beaker.forceMove(drop_location())
	if(user && Adjacent(user) && !issiliconoradminghost(user))
		user.put_in_hands(internal_beaker)
	internal_beaker = null

/obj/machinery/gibber/apc/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	if(HAS_TRAIT(grab.grabbed_thing, TRAIT_MAPSPAWNED))
		balloon_alert(user, "bad meat!")
		return FALSE
	return ..()

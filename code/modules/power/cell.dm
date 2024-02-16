// the power cell
// charge from 0 to 100%
// fits in APC to provide backup power

/obj/item/cell/Initialize(mapload)
	. = ..()
	charge = maxcharge
	if(self_recharge)
		START_PROCESSING(SSobj, src)

	update_icon()

/obj/item/cell/Destroy()
	if(self_recharge)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/cell/process()
	if(self_recharge)
		if(world.time >= last_use + charge_delay)
			give(charge_amount)
			update_icon()
	else
		return PROCESS_KILL

/obj/item/cell/update_overlays()
	. = ..()
	if(charge < 0.01)
		return
	var/remaining = CEILING((charge / max(maxcharge, 1)) * 100, 25)
	. += "[charge_overlay]_[remaining]"

/obj/item/cell/proc/percent()		// return % charge of cell
	return 100 * (charge / maxcharge)

/obj/item/cell/proc/fully_charged()
	return (charge == maxcharge)

// use power from a cell
/obj/item/cell/use(amount)
	if(rigged && amount > 0)
		explode()
		return FALSE
	last_use = world.time

	if(charge < amount)
		return FALSE
	charge = (charge - amount)
	return TRUE

// recharge the cell
/obj/item/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return 0

	if(maxcharge < amount)	return 0
	var/amount_used = min(maxcharge-charge,amount)
	if(crit_fail)	return 0
	if(!prob(reliability))
		minor_fault++
		if(prob(minor_fault))
			crit_fail = 1
			return 0
	charge += amount_used
	return amount_used


/obj/item/cell/examine(mob/user)
	. = ..()
	if(maxcharge <= 2500)
		. += "The manufacturer's label states this cell has a power rating of [maxcharge], and that you should not swallow it.\nThe charge meter reads [round(src.percent() )]%."
	else
		. += "This power cell has an exciting chrome finish, as it is an uber-capacity cell type! It has a power rating of [maxcharge]!\nThe charge meter reads [round(src.percent() )]%."
	if(crit_fail)
		. += span_warning("This power cell seems to be faulty.")
	if(rigged)
		if(get_dist(user,src) < 3) //Have to be close to make out the *DANGEROUS* details
			. += span_danger("This power cell looks jury rigged to explode!")


/obj/item/cell/attack_self(mob/user as mob)
	if(rigged)
		if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
			to_chat(user, span_warning("Your programming restricts using rigged power cells."))
			return
		log_bomber(user, "primed a rigged", src)
		user.visible_message(span_danger("[user] destabilizes [src]; it will detonate shortly!"),
		span_danger("You destabilize [src]; it will detonate shortly!"))
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start(src)
		playsound(loc, 'sound/items/welder2.ogg', 25, 1, 6)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.throw_mode_on()
		overlays += new/obj/effect/overlay/danger
		spawn(rand(3,50))
			spark_system.start(src)
			explode()

	return ..()

/obj/item/cell/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = I

		if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
			to_chat(user, span_warning("Your programming restricts rigging of power cells."))
			return

		to_chat(user, "You inject the solution into the power cell.")

		if(S.reagents.has_reagent(/datum/reagent/toxin/phoron, 5))
			rigged = TRUE
		S.reagents.clear_reagents()

	else if(ismultitool(I))
		if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
			to_chat(user, span_warning("Your programming restricts rigging of power cells."))
			return
		var/skill = user.skills.getRating(SKILL_ENGINEER)
		var/delay = SKILL_TASK_EASY - (5 + skill * 1.25)

		if(user.do_actions)
			return
		var/obj/effect/overlay/sparks/spark_overlay = new

		if(!rigged)
			if(skill < SKILL_ENGINEER_ENGI) //Field engi skill or better or ya fumble.
				user.visible_message(span_notice("[user] fumbles around figuring out how to manipulate [src]."),
				span_notice("You fumble around, trying to figure out how to rig [src] to explode."))
				if(!do_after(user, delay, NONE, src, BUSY_ICON_UNSKILLED))
					return

			user.visible_message(span_notice("[user] begins manipulating [src] with [I]."),
			span_notice("You begin rigging [src] to detonate with [I]."))
			if(!do_after(user, delay, NONE, src, BUSY_ICON_BUILD))
				return
			rigged = TRUE
			overlays += spark_overlay
			user.visible_message(span_notice("[user] finishes manipulating [src] with [I]."),
			span_notice("You rig [src] to explode on use with [I]."))
		else
			if(skill < SKILL_ENGINEER_ENGI)
				user.visible_message(span_notice("[user] fumbles around figuring out how to manipulate [src]."),
				span_notice("You fumble around, trying to figure out how to stabilize [src]."))
				var/fumbling_time = SKILL_TASK_EASY
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
				if(prob((SKILL_ENGINEER_PLASTEEL - skill) * 20))
					to_chat(user, "<font color='danger'>After several seconds of your clumsy meddling [src] buzzes angrily as if offended. You have a <b>very</b> bad feeling about this.</font>")
					rigged = TRUE
					explode() //Oops. Now you fucked up (or succeeded only too well). Immediate detonation.
			user.visible_message(span_notice("[user] begins manipulating [src] with [I]."),
			span_notice("You begin stabilizing [src] with [I] so it won't detonate on use."))
			if(skill > SKILL_ENGINEER_ENGI)
				delay = max(delay - 10, 0)
			if(!do_after(user, delay, NONE, src, BUSY_ICON_BUILD))
				return
			rigged = FALSE
			overlays -= spark_overlay
			user.visible_message(span_notice("[user] finishes manipulating [src] with [I]."),
			span_notice("You stabilize the [src] with [I]; it will no longer detonate on use."))


/obj/item/cell/proc/explode()
	var/turf/T = get_turf(src.loc)
/*
* 1000-cell	explosion(T, 0, 0, 1, 1)
* 2500-cell	explosion(T, 0, 0, 1, 1)
* 10000-cell	explosion(T, 0, 1, 3, 3)
* 15000-cell	explosion(T, 0, 2, 4, 4)
* */
	var/devastation_range = 0 //round(charge/11000)
	var/heavy_impact_range = clamp(round(sqrt(charge) * 0.01), 0, 3)
	var/light_impact_range = clamp(round(sqrt(charge) * 0.15), 0, 4)
	var/flash_range = clamp(round(sqrt(charge) * 0.15), -1, 4)

	explosion(T, devastation_range, heavy_impact_range, light_impact_range, 0, flash_range)

	QDEL_IN(src, 1)

/obj/item/cell/proc/corrupt()
	charge /= 2
	maxcharge /= 2
	if (prob(10))
		rigged = 1 //broken batterys are dangerous

/obj/item/cell/emp_act(severity)
	charge -= 1000 / severity
	if (charge < 0)
		charge = 0
	if(reliability != 100 && prob(50/severity))
		reliability -= 10 / severity
	..()

/obj/item/cell/ex_act(severity)

	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)
				return
			if (prob(50))
				corrupt()
		if(EXPLODE_LIGHT)
			if (prob(25))
				qdel(src)
				return
			if (prob(25))
				corrupt()
		if(EXPLODE_WEAK)
			if (prob(25))
				corrupt()


/obj/item/cell/proc/get_electrocute_damage()
	switch (charge)
		if (1000000 to INFINITY)
			return min(rand(50,160),rand(50,160))
		if (200000 to 1000000-1)
			return min(rand(25,80),rand(25,80))
		if (100000 to 200000-1)//Ave powernet
			return min(rand(20,60),rand(20,60))
		if (50000 to 100000-1)
			return min(rand(15,40),rand(15,40))
		if (1000 to 50000-1)
			return min(rand(10,20),rand(10,20))
		else
			return 0

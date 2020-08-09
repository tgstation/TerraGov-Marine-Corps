/obj/item/stock_parts/cell
	name = "power cell"
	desc = "A rechargeable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	// custom_materials = list(/datum/material/iron=700, /datum/material/glass=50)
	// grind_results = list(/datum/reagent/lithium = 15, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	var/rigged = FALSE	/// If the cell has been booby-trapped by injecting it with plasma. Chance on use() to explode.
	var/corrupted = FALSE /// If the power cell was damaged by an explosion, chance for it to become corrupted and function the same as rigged.
	var/chargerate = 100 //how much power is given every tick in a recharger
	var/self_recharge = 0 //does it self recharge, over time, or not?
	var/ratingdesc = TRUE
	var/grown_battery = FALSE // If it's a grown that acts as a battery, add a wire overlay to it.

/obj/item/stock_parts/cell/get_cell()
	return src

/obj/item/stock_parts/cell/Initialize(mapload, override_maxcharge)
	. = ..()
	START_PROCESSING(SSobj, src)
	create_reagents(5, INJECTABLE | DRAINABLE)
	if (override_maxcharge)
		maxcharge = override_maxcharge
	charge = maxcharge
	if(ratingdesc)
		desc += " This one has a rating of [DisplayEnergy(maxcharge)], and you should not swallow it."
	update_icon()

/obj/item/stock_parts/cell/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/stock_parts/cell/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, self_recharge))
			if(var_value)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/stock_parts/cell/process()
	if(self_recharge)
		give(chargerate * 0.25)
	else
		return PROCESS_KILL

/obj/item/stock_parts/cell/update_overlays()
	. = ..()
	if(grown_battery)
		. += mutable_appearance('icons/obj/power.dmi', "grown_wires")
	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		. += mutable_appearance('icons/obj/power.dmi', "cell-o2")
	else
		. += mutable_appearance('icons/obj/power.dmi', "cell-o1")

/obj/item/stock_parts/cell/proc/percent()		// return % charge of cell
	return 100*charge/maxcharge

// use power from a cell
/obj/item/stock_parts/cell/use(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(charge < amount)
		return 0
	charge = (charge - amount)
	if(!istype(loc, /obj/machinery/power/apc))
		SSblackbox.record_feedback("tally", "cell_used", 1, type)
	return 1

// recharge the cell
/obj/item/stock_parts/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(maxcharge < amount)
		amount = maxcharge
	var/power_used = min(maxcharge-charge,amount)
	charge += power_used
	return power_used

/obj/item/stock_parts/cell/examine(mob/user)
	. = ..()
	if(rigged)
		. += "<span class='danger'>This power cell seems to be faulty!</span>"
	else
		. += "The charge meter reads [round(src.percent() )]%."

/obj/item/stock_parts/cell/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is licking the electrodes of [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)

/obj/item/stock_parts/cell/on_reagent_change(changetype)
	rigged = (corrupted || reagents.has_reagent(/datum/reagent/toxin/phoron, 5)) //has_reagent returns the reagent datum
	return ..()


/obj/item/stock_parts/cell/proc/explode()
	var/turf/T = get_turf(src.loc)
	if (charge==0)
		return
	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = round(sqrt(charge)/60)
	var/light_impact_range = round(sqrt(charge)/30)
	var/flash_range = light_impact_range
	if (light_impact_range==0)
		rigged = FALSE
		corrupt()
		return
	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	qdel(src)

/obj/item/stock_parts/cell/proc/corrupt()
	charge /= 2
	maxcharge = max(maxcharge/2, chargerate)
	if (prob(10))
		rigged = TRUE //broken batterys are dangerous
		corrupted = TRUE

/obj/item/stock_parts/cell/emp_act(severity)
	. = ..()
	charge -= 1000 / severity
	if (charge < 0)
		charge = 0

/obj/item/stock_parts/cell/ex_act(severity, target)
	..()
	if(!QDELETED(src))
		switch(severity)
			if(2)
				if(prob(50))
					corrupt()
			if(3)
				if(prob(25))
					corrupt()

/obj/item/stock_parts/cell/proc/get_electrocute_damage()
	if(charge >= 1000)
		return clamp(20 + round(charge/25000), 20, 195) + rand(-5,5)
	else
		return 0

/obj/item/stock_parts/cell/get_part_rating()
	return rating * maxcharge

/* Cell variants*/
/obj/item/stock_parts/cell/empty/Initialize()
	. = ..()
	charge = 0

/obj/item/stock_parts/cell/crap
	name = "\improper Nanotrasen brand rechargeable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	maxcharge = 500
	// custom_materials = list(/datum/material/glass=40)

/obj/item/stock_parts/cell/crap/empty/Initialize()
	. = ..()
	charge = 0
	update_icon()

/obj/item/stock_parts/cell/upgraded
	name = "upgraded power cell"
	desc = "A power cell with a slightly higher capacity than normal!"
	maxcharge = 2500
	// custom_materials = list(/datum/material/glass=50)
	chargerate = 1000

/obj/item/stock_parts/cell/upgraded/plus
	name = "upgraded power cell+"
	desc = "A power cell with an even higher capacity than the base model!"
	maxcharge = 5000

/obj/item/stock_parts/cell/secborg
	name = "security borg rechargeable D battery"
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots
	// custom_materials = list(/datum/material/glass=40)

/obj/item/stock_parts/cell/secborg/empty/Initialize()
	. = ..()
	charge = 0
	update_icon()

/obj/item/stock_parts/cell/mini_egun
	name = "miniature energy gun power cell"
	maxcharge = 600

/obj/item/stock_parts/cell/hos_gun
	name = "X-01 multiphase energy gun power cell"
	maxcharge = 1200

/obj/item/stock_parts/cell/pulse //200 pulse shots
	name = "pulse rifle power cell"
	maxcharge = 40000
	chargerate = 1500

/obj/item/stock_parts/cell/pulse/carbine //25 pulse shots
	name = "pulse carbine power cell"
	maxcharge = 5000

/obj/item/stock_parts/cell/pulse/pistol //10 pulse shots
	name = "pulse pistol power cell"
	maxcharge = 2000

/obj/item/stock_parts/cell/high
	name = "high-capacity power cell"
	icon_state = "hcell"
	maxcharge = 10000
	// custom_materials = list(/datum/material/glass=60)
	chargerate = 1500

/obj/item/stock_parts/cell/high/plus
	name = "high-capacity power cell+"
	desc = "Where did these come from?"
	icon_state = "h+cell"
	maxcharge = 15000
	chargerate = 2250
	rating = 2

/obj/item/stock_parts/cell/high/empty/Initialize()
	. = ..()
	charge = 0
	update_icon()

/obj/item/stock_parts/cell/super
	name = "super-capacity power cell"
	icon_state = "scell"
	maxcharge = 20000
	// custom_materials = list(/datum/material/glass=300)
	chargerate = 2000
	rating = 3

/obj/item/stock_parts/cell/super/empty/Initialize()
	. = ..()
	charge = 0
	update_icon()

/obj/item/stock_parts/cell/hyper
	name = "hyper-capacity power cell"
	icon_state = "hpcell"
	maxcharge = 30000
	// custom_materials = list(/datum/material/glass=400)
	chargerate = 3000
	rating = 4

/obj/item/stock_parts/cell/hyper/empty/Initialize()
	. = ..()
	charge = 0
	update_icon()

/obj/item/stock_parts/cell/bluespace
	name = "bluespace power cell"
	desc = "A rechargeable transdimensional power cell."
	icon_state = "bscell"
	maxcharge = 40000
	// custom_materials = list(/datum/material/glass=600)
	chargerate = 4000
	rating = 5

/obj/item/stock_parts/cell/bluespace/empty/Initialize()
	. = ..()
	charge = 0
	update_icon()

/obj/item/stock_parts/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	maxcharge = 30000
	// custom_materials = list(/datum/material/glass=1000)
	rating = 100
	chargerate = 30000

/obj/item/stock_parts/cell/infinite/use()
	return 1

// /obj/item/stock_parts/cell/infinite/abductor
// 	name = "void core"
// 	desc = "An alien power cell that produces energy seemingly out of nowhere."
// 	icon = 'icons/obj/abductor.dmi'
// 	icon_state = "cell"
// 	maxcharge = 50000
// 	ratingdesc = FALSE

// /obj/item/stock_parts/cell/infinite/abductor/ComponentInitialize()
// 	. = ..()
// 	AddElement(/datum/element/update_icon_blocker)

// /obj/item/stock_parts/cell/potato
// 	name = "potato battery"
// 	desc = "A rechargeable starch based power cell."
// 	icon = 'icons/obj/hydroponics/harvest.dmi'
// 	icon_state = "potato"
// 	charge = 100
// 	maxcharge = 300
// 	// custom_materials = null
// 	grown_battery = TRUE //it has the overlays for wires

// /obj/item/stock_parts/cell/high/slime
// 	name = "charged slime core"
// 	desc = "A yellow slime core infused with plasma, it crackles with power."
// 	icon = 'icons/mob/slimes.dmi'
// 	icon_state = "yellow slime extract"
// 	// custom_materials = null
// 	rating = 5 //self-recharge makes these desirable
// 	self_recharge = 1 // Infused slime cores self-recharge, over time

/*Hypercharged slime cell - located in /code/modules/research/xenobiology/crossbreeding/_misc.dm
/obj/item/stock_parts/cell/high/slime/hypercharged */

// /obj/item/stock_parts/cell/emproof
// 	name = "\improper EMP-proof cell"
// 	desc = "An EMP-proof cell."
// 	maxcharge = 500
// 	rating = 3

// /obj/item/stock_parts/cell/emproof/empty/Initialize()
// 	. = ..()
// 	charge = 0
// 	update_icon()

// /obj/item/stock_parts/cell/emproof/empty/ComponentInitialize()
// 	. = ..()
// 	AddComponent(/datum/component/empprotection, EMP_PROTECT_SELF)

// /obj/item/stock_parts/cell/emproof/corrupt()
// 	return

/obj/item/stock_parts/cell/beam_rifle
	name = "beam rifle capacitor"
	desc = "A high powered capacitor that can provide huge amounts of energy in an instant."
	maxcharge = 50000
	chargerate = 5000	//Extremely energy intensive

/obj/item/stock_parts/cell/beam_rifle/corrupt()
	return

/obj/item/stock_parts/cell/beam_rifle/emp_act(severity)
	. = ..()
	charge = clamp((charge-(10000/severity)),0,maxcharge)

/obj/item/stock_parts/cell/emergency_light
	name = "miniature power cell"
	desc = "A tiny power cell with a very low power capacity. Used in light fixtures to power them in the event of an outage."
	maxcharge = 120 //Emergency lights use 0.2 W per tick, meaning ~10 minutes of emergency power from a cell
	// custom_materials = list(/datum/material/glass = 20)
	w_class = WEIGHT_CLASS_TINY

/obj/item/stock_parts/cell/emergency_light/Initialize()
	. = ..()
	var/area/A = get_area(src)
	if(!A.lightswitch || !A.light_power)
		charge = 0 //For naturally depowered areas, we start with no power


// the power cell
// charge from 0 to 100%
// fits in APC to provide backup power

/obj/item/cell/Initialize()
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
	else
		return PROCESS_KILL

/obj/item/cell/update_icon()
	cut_overlays()
	if(charge < 0.01)
		return
	else if(charge / maxcharge >= 0.995)
		add_overlay("cell-o2")
	else
		add_overlay("cell-o1")

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
		to_chat(user, "The manufacturer's label states this cell has a power rating of [maxcharge], and that you should not swallow it.\nThe charge meter reads [round(src.percent() )]%.")
	else
		to_chat(user, "This power cell has an exciting chrome finish, as it is an uber-capacity cell type! It has a power rating of [maxcharge]!\nThe charge meter reads [round(src.percent() )]%.")
	if(crit_fail)
		to_chat(user, "<span class='warning'>This power cell seems to be faulty.</span>")
	if(rigged)
		if(get_dist(user,src) < 3) //Have to be close to make out the *DANGEROUS* details
			to_chat(user, "<span class='danger'>This power cell looks jury rigged to explode!</span>")


/obj/item/cell/attack_self(mob/user as mob)
	if(rigged)
		if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
			to_chat(user, "<span class='warning'>Your programming restricts using rigged power cells.</span>")
			return
		log_explosion("[key_name(user)] primed a rigged [src] at [AREACOORD(user.loc)].")
		log_combat(user, src, "primed a rigged")
		user.visible_message("<span class='danger'>[user] destabilizes [src]; it will detonate shortly!</span>",
		"<span class='danger'>You destabilize [src]; it will detonate shortly!</span>")
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
			to_chat(user, "<span class='warning'>Your programming restricts rigging of power cells.</span>")
			return

		to_chat(user, "You inject the solution into the power cell.")

		if(S.reagents.has_reagent(/datum/reagent/toxin/phoron, 5))
			rigged = TRUE
		S.reagents.clear_reagents()

	else if(ismultitool(I))
		if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
			to_chat(user, "<span class='warning'>Your programming restricts rigging of power cells.</span>")
			return
		var/skill = user.skills.getRating("engineer")
		var/delay = SKILL_TASK_EASY - (5 + skill * 1.25)

		if(user.action_busy)
			return
		var/obj/effect/overlay/sparks/spark_overlay = new

		if(!rigged)
			if(skill < SKILL_ENGINEER_ENGI) //Field engi skill or better or ya fumble.
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to manipulate [src].</span>",
				"<span class='notice'>You fumble around, trying to figure out how to rig [src] to explode.</span>")
				if(!do_after(user, delay, TRUE, src, BUSY_ICON_UNSKILLED))
					return

			user.visible_message("<span class='notice'>[user] begins manipulating [src] with [I].</span>",
			"<span class='notice'>You begin rigging [src] to detonate with [I].</span>")
			if(!do_after(user, delay, TRUE, src, BUSY_ICON_BUILD))
				return
			rigged = TRUE
			overlays += spark_overlay
			user.visible_message("<span class='notice'>[user] finishes manipulating [src] with [I].</span>",
			"<span class='notice'>You rig [src] to explode on use with [I].</span>")
		else
			if(skill < SKILL_ENGINEER_ENGI)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to manipulate [src].</span>",
				"<span class='notice'>You fumble around, trying to figure out how to stabilize [src].</span>")
				var/fumbling_time = SKILL_TASK_EASY
				if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
					return
				if(prob((SKILL_ENGINEER_PLASTEEL - skill) * 20))
					to_chat(user, "<font color='danger'>After several seconds of your clumsy meddling [src] buzzes angrily as if offended. You have a <b>very</b> bad feeling about this.</font>")
					rigged = TRUE
					explode() //Oops. Now you fucked up (or succeeded only too well). Immediate detonation.
			user.visible_message("<span class='notice'>[user] begins manipulating [src] with [I].</span>",
			"<span class='notice'>You begin stabilizing [src] with [I] so it won't detonate on use.</span>")
			if(skill > SKILL_ENGINEER_ENGI)
				delay = max(delay - 10, 0)
			if(!do_after(user, delay, TRUE, src, BUSY_ICON_BUILD))
				return
			rigged = FALSE
			overlays -= spark_overlay
			user.visible_message("<span class='notice'>[user] finishes manipulating [src] with [I].</span>",
			"<span class='notice'>You stabilize the [src] with [I]; it will no longer detonate on use.</span>")


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

	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)

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

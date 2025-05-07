/obj/item/cell
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/tools_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/tools_right.dmi',
	)
	worn_icon_state = "cell"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	/// note %age conveted to actual charge in New
	var/charge = 0
	/// maximum amount of charge the cell can hold
	var/maxcharge = 1000
	/// BOOL, true if rigged to explode
	var/rigged = FALSE
	///If not 100% reliable, it will build up faults.
	var/minor_fault = 0
	/// BOOL, If true, the cell will recharge itself.
	var/self_recharge = FALSE
	/// How much power to give, if self_recharge is true. The number is in absolute cell charge, as it gets divided by CELLRATE later.
	var/charge_amount = 25
	/// A tracker for use in self-charging
	var/last_use = 0
	/// How long it takes for the cell to start recharging after last use
	var/charge_delay = 0
	///used to track what set of overlays to use to display charge level
	var/charge_overlay = "cell"

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
			SEND_SIGNAL(src, COMSIG_CELL_SELF_RECHARGE, charge_amount)
	else
		return PROCESS_KILL

/obj/item/cell/update_overlays()
	. = ..()
	if(charge < 0.01 || !charge_overlay)
		return
	var/remaining = CEILING((charge / max(maxcharge, 1)) * 100, 25)
	. += "[charge_overlay]_[remaining]"

/obj/item/cell/examine(mob/user)
	. = ..()
	if(maxcharge <= 2500)
		. += "The manufacturer's label states this cell has a power rating of [maxcharge], and that you should not swallow it.\nThe charge meter reads [round(src.percent() )]%."
	else
		. += "This power cell has an exciting chrome finish, as it is an uber-capacity cell type! It has a power rating of [maxcharge]!\nThe charge meter reads [round(src.percent() )]%."
	if(rigged)
		if(get_dist(user,src) < 3) //Have to be close to make out the *DANGEROUS* details
			. += span_danger("This power cell looks jury rigged to explode!")

/obj/item/cell/attack_self(mob/user as mob) // todo shitcode fixme
	if(!rigged)
		return ..()

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
	overlays += mutable_appearance('icons/obj/items/grenade.dmi', "danger", ABOVE_ALL_MOB_LAYER, src)
	spawn(rand(3,50))
		spark_system.start(src)
		explode()

/obj/item/cell/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

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

/obj/item/cell/emp_act(severity)
	. = ..()
	charge = max(charge - ((maxcharge * 0.5) / severity), 0)
	update_appearance(UPDATE_ICON)

/obj/item/cell/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)
				return
			if(prob(50))
				corrupt()
		if(EXPLODE_LIGHT)
			if(prob(25))
				qdel(src)
				return
			if(prob(25))
				corrupt()
		if(EXPLODE_WEAK)
			if(prob(25))
				corrupt()

/obj/item/cell/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is licking the electrodes of the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."))
	return (FIRELOSS)

/obj/item/cell/use(amount) // use power from a cell
	if(rigged && amount > 0)
		explode()
		return FALSE
	last_use = world.time

	if(charge < amount)
		return FALSE
	charge = (charge - amount)
	return TRUE

///Adds power to the cell
/obj/item/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return FALSE

	if(maxcharge < amount)
		return FALSE
	var/amount_used = min(maxcharge-charge,amount)
	charge += amount_used
	return amount_used

///return % charge of cell
/obj/item/cell/proc/percent()
	return 100 * (charge / maxcharge)

///Returns TRUE if charge is equal to maxcharge
/obj/item/cell/proc/is_fully_charged()
	return charge == maxcharge

///Explodes, scaling with cell charge
/obj/item/cell/proc/explode()

	var/heavy_impact_range = clamp(round(sqrt(charge) * 0.01), 0, 3)
	var/light_impact_range = clamp(round(sqrt(charge) * 0.15), 0, 4)
	var/flash_range = clamp(round(sqrt(charge) * 0.05), -1, 4)

	explosion(src, 0, heavy_impact_range, light_impact_range, 0, flash_range)

	QDEL_IN(src, 1)

///Divides charge and maxcharge, then has a 10% chance to be rigged to explode
/obj/item/cell/proc/corrupt()
	charge /= 2
	maxcharge /= 2
	if(prob(10))
		rigged = TRUE //broken batterys are dangerous

///Returns a number based on the current charge of the power cell
/obj/item/cell/proc/get_electrocute_damage()
	switch(charge)
		if(1000000 to INFINITY)
			return min(rand(50,160),rand(50,160))
		if(200000 to 1000000-1)
			return min(rand(25,80),rand(25,80))
		if(100000 to 200000-1)//Ave powernet
			return min(rand(20,60),rand(20,60))
		if(50000 to 100000-1)
			return min(rand(15,40),rand(15,40))
		if(1000 to 50000-1)
			return min(rand(10,20),rand(10,20))
		else
			return 0

/obj/item/cell/crap
	name = "\improper Nanotrasen brand rechargable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	maxcharge = 500

/obj/item/cell/crap/empty/Initialize(mapload)
	. = ..()
	charge = 0

/obj/item/cell/secborg
	name = "security borg rechargable D battery"
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots

/obj/item/cell/secborg/empty/Initialize(mapload)
	. = ..()
	charge = 0

/obj/item/cell/apc
	name = "heavy-duty power cell"
	maxcharge = 5000

/obj/item/cell/high
	name = "high-capacity power cell"
	icon_state = "hcell"
	maxcharge = 10000

/obj/item/cell/high/empty/Initialize(mapload)
	. = ..()
	charge = 0

/obj/item/cell/super
	name = "super-capacity power cell"
	icon_state = "scell"
	maxcharge = 20000

/obj/item/cell/super/empty/Initialize(mapload)
	. = ..()
	charge = 0

/obj/item/cell/hyper
	name = "hyper-capacity power cell"
	icon_state = "hpcell"
	maxcharge = 30000

/obj/item/cell/hyper/empty/Initialize(mapload)
	. = ..()
	charge = 0

/obj/item/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	maxcharge = 30000

/obj/item/cell/infinite/use()
	return TRUE

/obj/item/cell/potato
	name = "potato battery"
	desc = "A rechargable starch based power cell."
	icon = 'icons/obj/power.dmi' //'icons/obj/items/harvest.dmi'
	icon_state = "potato_cell" //"potato_battery"
	charge = 100
	maxcharge = 300
	minor_fault = 1

/obj/item/cell/rtg // todo should kill this subtype
	charge_overlay = null

/obj/item/cell/rtg/small
	name = "recharger cell"
	desc = "This is a miniature radioisotope generator that can fit into APC's, but not laser-based weapory. The needed shielding lowers the maximum capacity significantly."
	icon = 'icons/obj/items/stock_parts.dmi'
	icon_state = "capacitor"
	worn_icon_state = "capacitor"
	maxcharge = 2000
	self_recharge = TRUE
	charge_amount = 25
	charge_delay = 2 SECONDS //One hit on a resin thingy every 8 seconds, or one actual wall every 80 seconds.

/obj/item/cell/rtg/plasma_cutter
	name = "plasma cutter cell"
	desc = "You shouldn't be seeing this"
	maxcharge = 7500
	self_recharge = TRUE
	charge_amount = 25
	charge_delay = 2 SECONDS //One hit on a resin thingy every 8 seconds, or one actual wall every 80 seconds.

/obj/item/cell/rtg/large
	name = "large recharger cell"
	desc = "This is a radioisotope generator that can fit into APC's, but not laser-based weapory. It is too hot to be easily stored and cannot be handcharged."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "trashmelt"
	worn_icon_state = "trashmelt"
	w_class = WEIGHT_CLASS_HUGE
	maxcharge = 5000
	self_recharge = TRUE
	charge_amount = 50
	charge_delay = 2 SECONDS //One hit on a resin thingy every 4 seconds, or one actual wall every 40 seconds.

/obj/item/cell/mecha
	name = "small radiotope cell"
	desc = "A large twisting piece of metal that acts as the power core of a mecha. You probably shouldn't lick it, despite the blue glow."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "trashmelt"
	worn_icon_state = "trashmelt"
	w_class = WEIGHT_CLASS_HUGE
	charge_overlay = null
	self_recharge = TRUE
	maxcharge = 1400
	charge_amount = 150

/obj/item/cell/mecha/medium
	name = "medium radiotope cell"
	maxcharge = 650
	charge_amount = 200

/obj/item/cell/night_vision_battery
	name = "night vision goggle battery"
	desc = "A small, non-rechargable, proprietary battery for night vision goggles."
	icon_state = "night_vision"
	maxcharge = 500
	w_class = WEIGHT_CLASS_TINY
	charge_overlay = ""

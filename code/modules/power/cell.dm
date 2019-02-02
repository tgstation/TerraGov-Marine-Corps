// the power cell
// charge from 0 to 100%
// fits in APC to provide backup power

/obj/item/cell/Initialize()
	. = ..()
	charge = maxcharge

	updateicon()

/obj/item/cell/proc/updateicon()
	overlays.Cut()

	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		overlays += image('icons/obj/power.dmi', "cell-o2")
	else
		overlays += image('icons/obj/power.dmi', "cell-o1")

/obj/item/cell/proc/percent()		// return % charge of cell
	return 100.0*charge/maxcharge

/obj/item/cell/proc/fully_charged()
	return (charge == maxcharge)

// use power from a cell
/obj/item/cell/proc/use(var/amount)
	if(rigged && amount > 0)
		explode()
		return 0

	if(charge < amount)	return 0
	charge = (charge - amount)
	return 1

// recharge the cell
/obj/item/cell/proc/give(var/amount)
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
	if(maxcharge <= 2500)
		to_chat(user, "[desc]\nThe manufacturer's label states this cell has a power rating of [maxcharge], and that you should not swallow it.\nThe charge meter reads [round(src.percent() )]%.")
	else
		to_chat(user, "This power cell has an exciting chrome finish, as it is an uber-capacity cell type! It has a power rating of [maxcharge]!\nThe charge meter reads [round(src.percent() )]%.")
	if(crit_fail)
		to_chat(user, "<span class='warning'>This power cell seems to be faulty.</span>")
	if(rigged)
		if(get_dist(user,src) < 3) //Have to be close to make out the *DANGEROUS* details
			to_chat(user, "<span class='danger'>This power cell looks jury rigged to explode!</span>")

/*
/obj/item/cell/attack_self(mob/user as mob)
	src.add_fingerprint(user)
//	if(ishuman(user))
//		var/mob/living/carbon/human/H = user
//		var/obj/item/clothing/gloves/space_ninja/SNG = H.gloves
//		if(!istype(SNG) || !SNG.candrain || !SNG.draining) return
//
//		SNG.drain("CELL",src,H.wear_suit)
	return ..()
*/

/obj/item/cell/attack_self(mob/user as mob)
	add_fingerprint(user)
	if(rigged)
		if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
			to_chat(user, "<span class='warning'>Your programming restricts using rigged power cells.</span>")
			return
		log_combat(user, src, "primed a rigged")
		user.visible_message("<span class='danger'>[user] destabilizes [src]; it will detonate shortly!</span>",
		"<span class='danger'>You destabilize [src]; it will detonate shortly!</span>")
		msg_admin_attack("[key_name(user)] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[user.y];Z=[user.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[usr]'>FLW</a>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) primed \a [src].")
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start(src)
		playsound(loc, 'sound/items/Welder2.ogg', 25, 1, 6)
		overlays += new/obj/effect/overlay/danger
		spawn(rand(10,50))
			spark_system.start(src)
			explode()

	return ..()

/obj/item/cell/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/reagent_container/syringe))
		if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
			to_chat(user, "<span class='warning'>Your programming restricts rigging of power cells.</span>")
			return
		var/obj/item/reagent_container/syringe/S = W

		to_chat(user, "You inject the solution into the power cell.")

		if(S.reagents.has_reagent("phoron", 5))

			rigged = 1

			log_admin("[key_name(usr)] injected a power cell with phoron, rigging it to explode.")
			message_admins("[ADMIN_TPMONTY(usr)] injected a power cell with phoron, rigging it to explode.")

		S.reagents.clear_reagents()
	else if(ismultitool(W))
		if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
			to_chat(user, "<span class='warning'>Your programming restricts rigging of power cells.</span>")
			return
		var/delay = SKILL_TASK_EASY
		var/skill
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer) //Higher skill lowers the delay.
			skill = user.mind.cm_skills.engineer
			delay -= 5 + skill * 1.25

		if(!rigged)
			if(skill < SKILL_ENGINEER_ENGI) //Field engi skill or better or ya fumble.
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to manipulate [src].</span>",
				"<span class='notice'>You fumble around, trying to figure out how to rig [src] to explode.</span>")
				if(!do_after(user, delay, TRUE, 5, BUSY_ICON_BUILD, null, TRUE))
					return
				//if(prob((SKILL_ENGINEER_PLASTEEL - skill) * 20)) //Not sure if I want to keep this as I do like encouraging out of the box thinking/improvisation; let's test it
				//	to_chat(user, "<font color='danger'>After several seconds of your clumsy meddling [src] buzzes angrily as if offended. You have a <b>very</b> bad feeling about this.</font>")
				//	rigged = TRUE
				//	explode() //Oops. Now you fucked up (or succeeded only too well). Immediate detonation.
			user.visible_message("<span class='notice'>[user] begins manipulating [src] with [W].</span>",
			"<span class='notice'>You begin rigging [src] to detonate with [W].</span>")
			if(!do_after(user, delay, TRUE, 5, BUSY_ICON_BUILD, null, TRUE))
				return
			rigged = TRUE
			user.visible_message("<span class='notice'>[user] finishes manipulating [src] with [W].</span>",
			"<span class='notice'>You rig [src] to explode on use with [W].</span>")
		else
			if(skill < SKILL_ENGINEER_ENGI)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to manipulate [src].</span>",
				"<span class='notice'>You fumble around, trying to figure out how to stabilize [src].</span>")
				var/fumbling_time = SKILL_TASK_EASY
				if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD, null, TRUE))
					return
				if(prob((SKILL_ENGINEER_PLASTEEL - skill) * 20))
					to_chat(user, "<font color='danger'>After several seconds of your clumsy meddling [src] buzzes angrily as if offended. You have a <b>very</b> bad feeling about this.</font>")
					rigged = TRUE
					explode() //Oops. Now you fucked up (or succeeded only too well). Immediate detonation.
			user.visible_message("<span class='notice'>[user] begins manipulating [src] with [W].</span>",
			"<span class='notice'>You begin stabilizing [src] with [W] so it won't detonate on use.</span>")
			if(skill > SKILL_ENGINEER_ENGI)
				delay = max(delay - 10, 0)
			if(!do_after(user, delay, TRUE, 5, BUSY_ICON_BUILD, null, TRUE))
				return
			rigged = FALSE
			user.visible_message("<span class='notice'>[user] finishes manipulating [src] with [W].</span>",
			"<span class='notice'>You stabilize the [src] with [W]; it will no longer detonate on use.</span>")


/obj/item/cell/proc/explode()
	var/turf/T = get_turf(src.loc)
/*
 * 1000-cell	explosion(T, -1, 0, 1, 1)
 * 2500-cell	explosion(T, -1, 0, 1, 1)
 * 10000-cell	explosion(T, -1, 1, 3, 3)
 * 15000-cell	explosion(T, -1, 2, 4, 4)
 * */
	if (charge==0)
		return
	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = max(2,round(sqrt(charge)/100))
	var/light_impact_range = max(3,round(sqrt(charge)/30))
	var/flash_range = light_impact_range
	if (light_impact_range==0)
		rigged = 0
		corrupt()
		return
	//explosion(T, 0, 1, 2, 2)

	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)

	spawn(1)
		qdel(src)

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
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
			if (prob(50))
				corrupt()
		if(3.0)
			if (prob(25))
				qdel(src)
				return
			if (prob(25))
				corrupt()
	return

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

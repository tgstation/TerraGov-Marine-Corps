#define MINER_RUNNING	0
#define MINER_SMALL_DAMAGE	1
#define MINER_MEDIUM_DAMAGE	2
#define MINER_DESTROYED	3

/obj/machinery/miner
	name = "\improper Nanotransen phoron Mining Well"
	desc = "Top-of-the-line Nanotransen research drill, used to extract phoron in vast quantities. Selling the phoron mined by these would net a nice profit..."
	icon = 'icons/obj/mining_drill.dmi'
	density = TRUE
	icon_state = "mining_drill_active"
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/stored_mineral = 0
	var/miner_status = MINER_RUNNING
	var/add_tick = 0
	var/required_ticks = 3  //make one phoron per 3 seconds.
	var/mineral_produced = /obj/item/stack/sheet/mineral/phoron

/obj/machinery/miner/damaged	//mapping and all that shebang
	miner_status = MINER_DESTROYED
	icon_state = "mining_drill_error"

/obj/machinery/miner/damaged/platinum
	name = "\improper Nanotransen platinum Mining Well"
	desc = "A Nanotransen platinum drill. Produces even more valuable materials than it's phoron counterpart"		
	mineral_produced = /obj/item/stack/sheet/mineral/platinum

/obj/machinery/miner/Initialize()
	. = ..()
	start_processing()

/obj/machinery/miner/update_icon()
	switch(miner_status)
		if(MINER_RUNNING)
			icon_state = "mining_drill_active"
		if(MINER_SMALL_DAMAGE)
			icon_state = "mining_drill_braced"
		if(MINER_MEDIUM_DAMAGE)
			icon_state = "mining_drill"
		if(MINER_DESTROYED)
			icon_state = "mining_drill_error"
	

/obj/machinery/miner/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(miner_status == MINER_DESTROYED)
		var/obj/item/tool/weldingtool/W= I
		if(W.remove_fuel(1, user))
			if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s internals.</span>",
				"<span class='notice'>You fumble around figuring out [src]'s internals.</span>")
				var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("engineer")
				if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(W, /obj/item/tool/weldingtool/proc/isOn)))
					return FALSE
			playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
			user.visible_message("<span class='notice'>[user] starts welding [src]'s internal damage.</span>",
			"<span class='notice'>You start welding [src]'s internal damage.</span>")
			if(do_after(user, 200, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(W, /obj/item/tool/weldingtool/proc/isOn)))
				if(miner_status != MINER_DESTROYED )
					return FALSE
				playsound(loc, 'sound/items/welder2.ogg', 25, 1)
				miner_status = MINER_MEDIUM_DAMAGE
				user.visible_message("<span class='notice'>[user] welds [src]'s internal damage.</span>",
				"<span class='notice'>You weld [src]'s internal damage.</span>")
				start_processing()
				update_icon()
				return TRUE
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return FALSE

/obj/machinery/miner/wirecutter_act(mob/living/user, obj/item/I)
	if(miner_status == MINER_MEDIUM_DAMAGE)
		if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s wiring.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s wiring.</span>")
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("engineer")
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return FALSE
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] starts securing [src]'s wiring.</span>",
		"<span class='notice'>You start securing [src]'s wiring.</span>")
		if(!do_after(user, 120, TRUE, src, BUSY_ICON_BUILD) || miner_status != MINER_MEDIUM_DAMAGE)
			return FALSE
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		miner_status = MINER_SMALL_DAMAGE
		user.visible_message("<span class='notice'>[user] secures [src]'s wiring.</span>",
		"<span class='notice'>You secure [src]'s wiring.</span>")
		update_icon()
		return TRUE

/obj/machinery/miner/wrench_act(mob/living/user, obj/item/I)
	if(miner_status == MINER_SMALL_DAMAGE)
		if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s tubing and plating.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s tubing and plating.</span>")
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("engineer")
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return FALSE
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] starts repairing [src]'s tubing and plating.</span>",
		"<span class='notice'>You start repairing [src]'s tubing and plating.</span>")
		if(do_after(user, 150, TRUE, src, BUSY_ICON_BUILD) && miner_status == MINER_SMALL_DAMAGE)
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			miner_status = MINER_RUNNING
			user.visible_message("<span class='notice'>[user] repairs [src]'s tubing and plating.</span>",
			"<span class='notice'>You repair [src]'s tubing and plating.</span>")
			update_icon()
			return TRUE

/obj/machinery/miner/examine(mob/user)
	..()
	if(ishuman(user))
		switch(miner_status)
			if(MINER_DESTROYED)
				to_chat(user, "<span class='info'>It's heavily damaged, and you can see internal workings.</span>")
				to_chat(user, "<span class='info'>Use a blowtorch, then wirecutters, then wrench to repair it.</span>")
			if(MINER_MEDIUM_DAMAGE)
				to_chat(user, "<span class='info'>It's damaged, and there are broken wires hanging out.</span>")
				to_chat(user, "<span class='info'>Use a wirecutters, then wrench to repair it.</span>")
			if(MINER_SMALL_DAMAGE)
				to_chat(user, "<span class='info'>It's lightly damaged, and you can see some dents and loose piping.</span>")
				to_chat(user, "<span class='info'>Use a wrench to repair it.</span>")
			if(MINER_RUNNING)
				to_chat(user, "<span class='info'>[src]'s internal storage currently has [stored_mineral] sheets stored.</span>")

/obj/machinery/miner/attack_hand(mob/living/user)
	var/mob/living/L = user
	if(miner_status != MINER_RUNNING)
		to_chat(L, "<span class='warning'>[src] is damaged!</span>")
		return
	if(stored_mineral != 0)
		if(stored_mineral >= 50)	//We shouldnt get more, but just in case
			stop_processing()
		new mineral_produced(L.loc, stored_mineral)
		stored_mineral = 0
	else
		to_chat(L, "<span class='warning'>[src]'s internal storage currently has no minerals stored!</span>")

/obj/machinery/miner/process()
	if(miner_status == MINER_RUNNING)
		if(add_tick >= required_ticks && stored_mineral <= 49)	//make one phoron per 60 ticks, or 3 seconds.
			stored_mineral += 1			
			add_tick = 0
		else if(stored_mineral >= 50)
			stop_processing()
		else
			add_tick += 1

/obj/machinery/miner/attack_alien(mob/living/carbon/xenomorph/M)
	M.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	M.visible_message("<span class='danger'>[M] slashes \the [src]!</span>", \
	"<span class='danger'>We slash \the [src]!</span>", null, 5)
	playsound(loc, "alien_claw_metal", 25, 1)
	switch(miner_status)
		if(MINER_RUNNING)
			stop_processing()
			stored_mineral = 0
			miner_status = MINER_SMALL_DAMAGE
		if(MINER_SMALL_DAMAGE)
			miner_status = MINER_MEDIUM_DAMAGE
		if(MINER_MEDIUM_DAMAGE)
			miner_status = MINER_DESTROYED
		if(MINER_DESTROYED)
			to_chat(M, "<span class='warning'>[src] is already destroyed!</span>")
	update_icon()

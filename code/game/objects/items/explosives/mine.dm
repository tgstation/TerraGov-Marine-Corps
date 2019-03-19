#define DEBUG_MINES		0

///***MINES***///
//Mines have an invisible "tripwire" atom that explodes when crossed
//Stepping directly on the mine will also blow it up
/obj/item/explosive/mine
	name = "\improper M20 Claymore anti-personnel mine"
	desc = "The M20 Claymore is a directional, programmable proximity triggered anti-personnel mine and detection device designed by MIC Industries for use by the TerraGov Marine Corps."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "m20"
	force = 5.0
	w_class = 2
	//layer = MOB_LAYER - 0.1 //You can't just randomly hide claymores under boxes. Booby-trapping bodies is fine though
	throwforce = 5.0
	throw_range = 6
	throw_speed = 3
	unacidable = 1
	flags_atom = CONDUCT

	var/list/obj/alert_list = list()
	var/last_alert = 0
	var/obj/machinery/camera/camera = null
	var/iff_signal = ACCESS_IFF_MARINE
	var/triggered = 0
	var/armed = 0 //Will the mine explode or not
	var/trigger_type = "Concussive" //Calls that proc
	var/alarm_mode = TRUE //Noisy vs silent alarm when tripped
	var/obj/effect/mine_tripwire/tripwire
	var/camera_number
	/*
		"explosive"
		//"incendiary" //New bay//
	*/

	ex_act() trigger_explosion() //We don't care about how strong the explosion was.
	emp_act() trigger_explosion() //Same here. Don't care about the effect strength.

/obj/item/explosive/mine/Destroy()
	if(tripwire)
		QDEL_NULL(tripwire)
		tripwire = null
	if(camera)
		QDEL_NULL(camera)
		camera = null
	. = ..()

/obj/item/explosive/mine/pmc
	name = "\improper M20P Claymore anti-personnel mine"
	desc = "The M20P Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the TerraGov Marine Corps. It has been modified for use by the NT PMC forces."
	icon_state = "m20p"
	iff_signal = ACCESS_IFF_PMC

//Arming
/obj/item/explosive/mine/attack_self(mob/living/user)
	if(locate(/obj/item/explosive/mine) in get_turf(src))
		to_chat(user, "<span class='warning'>There already is a mine at this position!</span>")
		return

	if(user.loc && user.loc.density)
		to_chat(user, "<span class='warning'>You can't plant a mine here.</span>")
		return

	/*if(is_mainship_or_low_orbit_level(user.z)) // Theseus or dropship transit level
		to_chat(user, "<span class='warning'>You can't plant a mine on a spaceship!</span>")
		return*/

	if(!armed)
		user.visible_message("<span class='notice'>[user] starts deploying [src].</span>", \
		"<span class='notice'>You start deploying [src].</span>")
		if(!do_after(user, 40, TRUE, 5, BUSY_ICON_HOSTILE))
			user.visible_message("<span class='notice'>[user] stops deploying [src].</span>", \
		"<span class='notice'>You stop deploying \the [src].</span>")
			return
		user.visible_message("<span class='notice'>[user] finishes deploying [src].</span>", \
		"<span class='notice'>You finish deploying [src].</span>")
		anchored = 1
		armed = 1
		playsound(src.loc, 'sound/weapons/mine_armed.ogg', 25, 1)
		icon_state += "_armed"
		user.drop_held_item()
		setDir(user.dir) //The direction it is planted in is the direction the user faces at that time
		camera = new (src)
		camera.network = list("LEADER")
		camera.c_tag = "M20 Mine: [get_area(src)] | X: [x] | Y: [y]| [camera_number]" //Update Camera name
		var/tripwire_loc = get_turf(get_step(loc, dir))
		tripwire = new /obj/effect/mine_tripwire(tripwire_loc)
		tripwire.linked_claymore = src

//Disarming
/obj/item/explosive/mine/attackby(obj/item/W, mob/user)
	if(ismultitool(W))
		if(anchored)
			user.visible_message("<span class='notice'>[user] starts disarming [src].</span>", \
			"<span class='notice'>You start disarming [src].</span>")
			if(!do_after(user, SKILL_TASK_AVERAGE, TRUE, 5, BUSY_ICON_FRIENDLY))
				user.visible_message("<span class='warning'>[user] stops disarming [src].", \
				"<span class='warning'>You stop disarming [src].")
				return
			user.visible_message("<span class='notice'>[user] finishes disarming [src].", \
			"<span class='notice'>You finish disarming [src].")
			anchored = 0
			armed = 0
			icon_state = copytext(icon_state,1,-6)
			if(tripwire)
				qdel(tripwire)
				tripwire = null

		else //Multitool allows us to program the claymore otherwise.
			interface(user)

/obj/item/explosive/mine/proc/interface(mob/living/carbon/user)
	if(!istype(user))
		return
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to use [src].</span>",
		"<span class='notice'>You fumble around figuring out how to use [src].</span>")
		var/fumbling_time = SKILL_TASK_VERY_EASY
		if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD))
			return
	user.set_interaction(src)
	var/dat = {"<TT>
<B>Current Detonation Mode:</B> [trigger_type]<BR>
<A href='?src=\ref[src];trigger_type=Concussive'><B>Set to Concussive Blast Mode</B></A><BR>
<A href='?src=\ref[src];trigger_type=Incendiary'><B>Set to Incendiary Mode</B></A><BR>
<A href='?src=\ref[src];trigger_type=Monitoring'><B>Set to Monitoring Mode</B></A><BR>
<BR>
<B>Current Alarm Mode:</B> [alarm_mode ? "Siren" : "Silent"]<BR>
<A href='?src=\ref[src];alarm_mode=1'><B>Set Alarm Mode:</B> [alarm_mode ? "Silent" : "Siren"]</A><BR>

</TT>"}

	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/explosive/mine/Topic(href, href_list)
	//..()
	if(usr.stat || usr.is_mob_restrained())
		return
	if((iscarbon(usr) && usr.contents.Find(src)) || (usr.contents.Find(master) || (in_range(src, usr) && istype(loc, /turf))))
		usr.set_interaction(src)
		if(href_list["trigger_type"])
			trigger_type = href_list["trigger_type"]
			to_chat(usr, "<font color='warning'>You set [src] to [trigger_type] mode.</font>")

		else if(href_list["alarm_mode"])
			alarm_mode = !( alarm_mode )

		if(!( master ))
			if(iscarbon(loc))
				interface(loc)
			else
				for(var/mob/living/carbon/C in viewers(1, src))
					if(C.client)
						interface(C)
		else
			if(iscarbon(master.loc))
				interface(master.loc)
			else
				for(var/mob/living/carbon/C in viewers(1, master))
					if(C.client)
						interface(C)
	else
		usr << browse(null, "window=radio")

//Mine can also be triggered if you "cross right in front of it" (same tile)
/obj/item/explosive/mine/Crossed(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(!L.lying)//so dragged corpses don't trigger mines.
			Bumped(A)

/obj/item/explosive/mine/Bumped(mob/M)
	if(!armed || triggered || iscyborg(M))
		return

	if(istype(M, /mob/living/carbon/human) )
		var/mob/living/carbon/human/H = M
		if(H.get_target_lock(iff_signal) )
			return

	M.visible_message("<span class='danger'>[icon2html(src, viewers(M))] The [name] clicks as [M] moves in front of it.</span>", \
	"<span class='danger'>[icon2html(src, viewers(M))] The [name] clicks as you move in front of it.</span>", \
	"<span class='danger'>You hear a click.</span>")

	if(trigger_type != "Monitoring")
		triggered = 1
	playsound(loc, 'sound/weapons/mine_tripped.ogg', 25, 1)
	trigger_explosion(M)

//Note : May not be actual explosion depending on linked method
/obj/item/explosive/mine/proc/trigger_explosion(mob/M)
	set waitfor = 0

	if(M)
		mine_alert(M)

/obj/item/explosive/mine/attack_alien(mob/living/carbon/Xenomorph/M)
	if(triggered) //Mine is already set to go off
		return

	if(M.a_intent == INTENT_HELP)
		return
	M.visible_message("<span class='danger'>[M] has slashed [src]!</span>", \
	"<span class='danger'>You slash [src]!</span>")
	playsound(loc, 'sound/weapons/slice.ogg', 25, 1)

	//We move the tripwire randomly in either of the four cardinal directions
	triggered = 1
	if(tripwire)
		var/direction = pick(cardinal)
		var/step_direction = get_step(src, direction)
		tripwire.forceMove(step_direction)
		if(trigger_type == "Monitoring")
			trigger_type = "Concussive" //It defaults to boom if in monitoring mode
	trigger_explosion(M)

/obj/item/explosive/mine/flamer_fire_act() //adding mine explosions
	var/turf/T = loc
	qdel(src)
	explosion(T, -1, -1, 2)


/obj/effect/mine_tripwire
	name = "claymore tripwire"
	anchored = 1
	mouse_opacity = 0
	invisibility = INVISIBILITY_MAXIMUM
	unacidable = 1 //You never know
	var/obj/item/explosive/mine/linked_claymore

/obj/effect/mine_tripwire/Destroy()
	if(linked_claymore)
		linked_claymore = null
	. = ..()

/obj/effect/mine_tripwire/Crossed(atom/A)
	if(!linked_claymore)
		qdel(src)
		return

	if(linked_claymore.triggered) //Mine is already set to go off
		return

	if(linked_claymore && ismob(A))
		linked_claymore.Bumped(A)

/obj/item/explosive/mine/proc/mine_alert(mob/M)
	set waitfor = FALSE

	if(!M)
		return

	if(world.time > (last_alert + CLAYMORE_ALERT_DELAY) || !(M in alert_list)) //if we're not on cooldown or the target isn't in the list, sound the alarm
		alert_list.Add(M)
		last_alert = world.time
		var/notice = "<b>ALERT! [src] detonated. Hostile/unknown: [M] Detected at: [get_area(M)]. Coordinates: (X: [M.x], Y: [M.y]).</b>"
		var/mob/living/silicon/ai/AI = new/mob/living/silicon/ai(src, null, null, 1)
		AI.SetName("Smartmine Alert System")
		AI.aiRadio.talk_into(AI,"[notice]","Theseus","announces")
		qdel(AI)

		if(alarm_mode) //Play an audible alarm if toggled on.
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)

	#if DEBUG_MINES
	to_chat(world, "DEBUG CLAYMORE MINE_ALERT: tripwire: [tripwire] target: [M] trigger_type: [trigger_type]")
	#endif

	if(!tripwire)
		return

	if(!trigger_type || trigger_type == "Monitoring")
		return

	switch(trigger_type) //Makes sure we announce first before detonation.
		if("Concussive")
			explosion(tripwire.loc, -1, -1, 2)
			qdel(src)

		if("Incendiary")
			flame_radius(2, tripwire.loc, 50, 50, 45, 15) //powerful
			qdel(src)



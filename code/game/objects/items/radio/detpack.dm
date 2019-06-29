/obj/item/radio/detpack
	name = "detonation pack"
	desc = "Programmable remotely triggered 'smart' explosive used for demolitions and impromptu booby traps. Can be set to breach or demolition detonation patterns."
	gender = PLURAL
	icon = 'icons/obj/det.dmi'
	icon_state = "detpack_off"
	item_state = "plasticx"
	flags_item = NOBLUDGEON
	frequency = 1457
	w_class = 2.0
	origin_tech = "syndicate=2"
	on = FALSE
	layer = MOB_LAYER - 0.1
	var/armed = FALSE
	var/timer = 5.0
	var/code = 2
	var/det_mode = FALSE //FALSE for breach, TRUE for demolition.
	var/atom/plant_target = null //which atom the detpack is planted on
	var/target_drag_delay = null //store this for restoration later
	var/boom = FALSE //confirms whether we actually detted.
	var/detonation_pending
	var/sound_timer
	var/datum/radio_frequency/radio_connection

/obj/item/radio/detpack/examine(mob/user)
	. = ..()
	var/list/details = list()
	if(on)
		details +=("It's turned on.")
	if(timer)
		details +=("Its timer has [timer] seconds left.")
	if(det_mode)
		details +=("It appears set to demolition mode.")
	else
		details +=("It appears set to breaching mode.")
	if(armed)
		details +=("<b>It is armed!</b>")
	to_chat(user, "<span class='warning'>[details.Join(" ")]</span>")


/obj/item/radio/detpack/Destroy()
	if(sound_timer)
		deltimer(sound_timer)
	if(detonation_pending)
		deltimer(detonation_pending)
	if(plant_target && !boom) //whatever name you give it
		loc = get_turf(src)
		nullvars()
	else
		nullvars()
		return ..()


/obj/item/radio/detpack/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)


/obj/item/radio/detpack/update_icon()
	icon_state = "detpack_[plant_target ? "set_" : ""]"
	if(on)
		icon_state = "[icon_state][armed ? "armed" : "on"]"
	else
		icon_state = "[icon_state]off"


/obj/item/radio/detpack/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ismultitool(I) && armed)
		if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_METAL)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out how to use the [src].</span>",
			"<span class='notice'>You fumble around figuring out how to use [src].</span>")
			var/fumbling_time = 30
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return

			if(prob((SKILL_ENGINEER_METAL - user.mind.cm_skills.engineer) * 20))
				to_chat(user, "<font color='danger'>After several seconds of your clumsy meddling the [src] buzzes angrily as if offended. You have a <b>very</b> bad feeling about this.</font>")
				timer = 0 //Oops. Now you fucked up. Immediate detonation.
		
		user.visible_message("<span class='notice'>[user] begins disarming [src] with [I].</span>",
		"<span class='notice'>You begin disarming [src] with [I].</span>")
		
		if(!do_after(user, 30, TRUE, src, BUSY_ICON_FRIENDLY))
			return

		user.visible_message("<span class='notice'>[user] disarms [src].</span>",
		"<span class='notice'>You disarm [src].</span>")
		armed = FALSE
		update_icon()


/obj/item/radio/detpack/attack_hand(mob/user as mob)
	if(armed)
		to_chat(user, "<font color='warning'>Active anchor bolts are holding it in place! Disarm [src] first to remove it!</font>")
		return
	if(plant_target)
		user.visible_message("<span class='notice'>[user] begins unsecuring [src] from [plant_target].</span>",
		"<span class='notice'>You begin unsecuring [src] from [plant_target].</span>")
		if(!do_after(user, 30, TRUE, src, BUSY_ICON_BUILD))
			return
		user.visible_message("<span class='notice'>[user] unsecures [src] from [plant_target].</span>",
		"<span class='notice'>You unsecure [src] from [plant_target].</span>")
		nullvars()
	return ..()

/obj/item/radio/detpack/proc/nullvars()
	if(ismovableatom(plant_target) && plant_target.loc)
		var/atom/movable/T = plant_target
		if(T.drag_delay == 3)
			T.drag_delay = target_drag_delay //reset the drag delay of whatever we attached the detpack to
		T.vis_contents -= src
	plant_target = null //null everything out now
	target_drag_delay = null
	armed = FALSE
	boom = FALSE
	update_icon()

/obj/item/radio/detpack/receive_signal(datum/signal/signal)
	if(!signal || !on)
		return

	if(signal.data["code"] != code)
		return

	if(!armed)
		if(!plant_target) //has to be planted on something to begin detonating.
			return
		armed = TRUE
		//bombtick()
		log_explosion("[key_name(usr)] triggered [src] explosion at [AREACOORD(loc)].")
		detonation_pending = addtimer(CALLBACK(src, .proc/do_detonate), timer SECONDS, TIMER_STOPPABLE)
		if(timer > 10)
			sound_timer = addtimer(CALLBACK(src, .proc/do_play_sound_normal), 1 SECONDS, TIMER_LOOP)
			addtimer(CALLBACK(src, .proc/change_to_loud_sound), timer-10)
		else
			sound_timer = addtimer(CALLBACK(src, .proc/do_play_sound_loud), 1 SECONDS, TIMER_LOOP)
		update_icon()
	else
		armed = FALSE
		disarm()
		update_icon()

	if(master && !wires.is_cut(WIRE_RX))
		master.receive_signal()
	return

/obj/item/radio/detpack/Topic(href, href_list)
	//..()
	if(usr.stat || usr.restrained())
		return
	if((ishuman(usr) && usr.contents.Find(src)) || (usr.contents.Find(master) || (in_range(src, usr) && istype(loc, /turf))))
		usr.set_interaction(src)
		if(href_list["freq"])
			var/new_frequency = (frequency + text2num(href_list["freq"]))
			if(new_frequency < 1200 || new_frequency > 1600)
				new_frequency = sanitize_frequency(new_frequency)
			set_frequency(new_frequency)
		else
			if(href_list["code"])
				code += text2num(href_list["code"])
				code = round(code)
				code = min(100, code)
				code = max(1, code)
			else if(href_list["det_mode"])
				det_mode = !( det_mode )
				update_icon()
			else if(href_list["power"])
				on = !( on )
				update_icon()
			else
				if(href_list["timer"])
					timer += text2num(href_list["timer"])
					timer = round(timer)
					timer = CLAMP(timer,DETPACK_TIMER_MIN,DETPACK_TIMER_MAX)
		if(!( master ))
			if(istype(loc, /mob))
				attack_self(loc)
			else
				for(var/mob/M in viewers(1, src))
					if(M.client)
						attack_self(M)
		else
			if(istype(master.loc, /mob))
				attack_self(master.loc)
			else
				for(var/mob/M in viewers(1, master))
					if(M.client)
						attack_self(M)
	else
		usr << browse(null, "window=radio")


/obj/item/radio/detpack/attack_self(mob/user as mob, flag1)

	if(!ishuman(user))
		return
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to use [src].</span>",
		"<span class='notice'>You fumble around figuring out how to use [src].</span>")
		var/fumbling_time = 20
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
			return
	user.set_interaction(src)
	var/dat = {"<TT>
<A href='?src=\ref[src];power=1'>Turn [on ? "Off" : "On"]</A><BR>
<B>Current Detonation Mode:</B> [det_mode ? "Demolition" : "Breach"]<BR>
<A href='?src=\ref[src];det_mode=1'><B>Set Detonation Mode:</B> [det_mode ? "Breach" : "Demolition"]</A><BR>
<B>Frequency/Code for Detpack:</B><BR>
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A>
[format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
<B>Signal Code:</B><BR>
<A href='byond://?src=\ref[src];code=-5'>-</A>
<A href='byond://?src=\ref[src];code=-1'>-</A> [code]
<A href='byond://?src=\ref[src];code=1'>+</A>
<A href='byond://?src=\ref[src];code=5'>+</A><BR>
<B>Timer (Max 300 seconds, Min 5 seconds):</B><BR>
<A href='byond://?src=\ref[src];timer=-50'>-</A>
<A href='byond://?src=\ref[src];timer=-10'>-</A>
<A href='byond://?src=\ref[src];timer=-5'>-</A>
<A href='byond://?src=\ref[src];timer=-1'>-</A> [timer]
<A href='byond://?src=\ref[src];timer=1'>+</A>
<A href='byond://?src=\ref[src];timer=5'>+</A>
<A href='byond://?src=\ref[src];timer=10'>+</A>
<A href='byond://?src=\ref[src];timer=50'>+</A><BR>
</TT>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return


/obj/item/radio/detpack/afterattack(atom/target, mob/user, flag)
	if(!flag)
		return FALSE
	if(istype(target, /obj/item) || istype(target, /mob))
		return FALSE
	if(isobj(target))
		var/obj/O = target
		if(CHECK_BITFIELD(O.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
			return FALSE
	if(iswallturf(target))
		var/turf/closed/wall/W = target
		if(W.hull)
			return FALSE
	if(istype(target, /obj/structure/window))
		var/obj/structure/window/W = target
		if(!W.damageable)
			to_chat(user, "<span class='warning'>[W] is much too tough for you to do anything to it with [src]</span>.")
			return FALSE

	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to use [src].</span>",
		"<span class='notice'>You fumble around figuring out how to use [src].</span>")
		var/fumbling_time = 50
		if(!do_after(user, fumbling_time, TRUE, target, BUSY_ICON_UNSKILLED))
			return

	user.visible_message("<span class='warning'>[user] is trying to plant [name] on [target]!</span>",
	"<span class='warning'>You are trying to plant [name] on [target]!</span>")

	if(do_after(user, 3 SECONDS, TRUE, target, BUSY_ICON_HOSTILE))
		user.drop_held_item()
		playsound(src.loc, 'sound/weapons/mine_armed.ogg', 25, 1)
		var/location
		location = target
		forceMove(location)

		log_game("[key_name(user)] planted [src.name] on [target.name] at [AREACOORD(target.loc)] with [timer] second fuse.")
		message_admins("[ADMIN_TPMONTY(user)] planted [src.name] on [target.name] at [ADMIN_VERBOSEJMP(target.loc)] with [timer] second fuse.")
	
		notify_ghosts("<b>[user]</b> has planted \a <b>[name]</b> on <b>[target.name]</b> with a <b>[timer]</b> second fuse!", source = user, action = NOTIFY_ORBIT)

		//target.overlays += image('icons/obj/items/assemblies.dmi', "plastic-explosive2")
		user.visible_message("<span class='warning'>[user] plants [name] on [target]!</span>",
		"<span class='warning'>You plant [name] on [target]! Timer set for [timer] seconds.</span>")

		plant_target = target
		if(ismovableatom(plant_target))
			var/atom/movable/T = plant_target
			T.vis_contents += src
			if(T.drag_delay < 3) //Anything with a fast drag delay we need to modify to avoid kamikazi tactics
				target_drag_delay = T.drag_delay
				T.drag_delay = 3
		update_icon()

/obj/item/radio/detpack/proc/change_to_loud_sound()
	if(sound_timer)
		deltimer(sound_timer)
		sound_timer = addtimer(CALLBACK(src, .proc/do_play_sound_loud), 1 SECONDS, TIMER_LOOP)

/obj/item/radio/detpack/proc/do_play_sound_normal()
	timer--
	playsound(loc, 'sound/weapons/mine_tripped.ogg', 50, FALSE)

/obj/item/radio/detpack/proc/do_play_sound_loud()
	timer--
	playsound(loc, 'sound/weapons/mine_tripped.ogg', 160 + (timer-timer*2)*10, FALSE) //Gets louder as we count down to armaggedon

/obj/item/radio/detpack/proc/disarm()
	if(timer < DETPACK_TIMER_MIN) //reset to minimum 5 seconds; no 'cooking' with aborted detonations.
		timer = DETPACK_TIMER_MIN
	deltimer(sound_timer)
	if(detonation_pending)
		deltimer(detonation_pending)
	sound_timer = null
	update_icon()

/obj/item/radio/detpack/proc/do_detonate()
	detonation_pending = null
	if(plant_target == null || !plant_target.loc) //need a target to be attached to
		if(timer < DETPACK_TIMER_MIN) //reset to minimum 5 seconds; no 'cooking' with aborted detonations.
			timer = DETPACK_TIMER_MIN
		deltimer(sound_timer)
		sound_timer = null
		nullvars()
		return
	if(!on) //need to be active and armed.
		armed = FALSE
		if(timer < DETPACK_TIMER_MIN) //reset to minimum 5 seconds; no 'cooking' with aborted detonations.
			timer = DETPACK_TIMER_MIN
		deltimer(sound_timer)
		sound_timer = null
		update_icon()
		return
	if(!armed)
		disarm()

	//Time to go boom
	playsound(src.loc, 'sound/weapons/ring.ogg', 200, FALSE)
	boom = TRUE
	if(det_mode == TRUE) //If we're on demolition mode, big boom.
		explosion(get_turf(plant_target), 2, 4, 5, 6)
	else //if we're not, focused boom.
		explosion(get_turf(plant_target), 1, 1, 2, 3)
	if(plant_target)
		if(isobj(plant_target))
			plant_target = null
			if(!istype(plant_target,/obj/vehicle/multitile/root/cm_armored))
				qdel(plant_target)
	qdel(src)


/obj/item/radio/detpack/attack(mob/M as mob, mob/user as mob, def_zone)
	return

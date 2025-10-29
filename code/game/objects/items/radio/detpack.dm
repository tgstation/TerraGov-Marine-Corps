/obj/item/detpack
	name = "detonation pack"
	desc = "Programmable remotely triggered 'smart' explosive controlled via a signaler, used for demolitions and impromptu booby traps. Can be set to breach or demolition detonation patterns. Unique action to arm. Click on it with a signaler to copy over the signal code."
	gender = PLURAL
	icon = 'icons/obj/det.dmi'
	icon_state = "detpack_off"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/explosives_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/explosives_right.dmi',
		)
	worn_icon_state = "plasticx"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	layer = MOB_LAYER - 0.1
	var/frequency = 1457
	var/on = FALSE
	var/armed = FALSE
	var/timer = 5
	var/code = 2
	var/det_mode = FALSE //FALSE for breach, TRUE for demolition.
	var/atom/plant_target = null //which atom the detpack is planted on
	var/target_drag_delay = null //store this for restoration later
	var/boom = FALSE //confirms whether we actually detted.
	var/boom_direction //which direction we were planted in; determines which way breach detpacks blast through walls
	var/detonation_pending
	var/sound_timer
	var/datum/radio_frequency/radio_connection


/obj/item/detpack/Initialize(mapload)
	. = ..()
	set_frequency(frequency)
	code = rand(1, 100)


/obj/item/detpack/examine(mob/user)
	. = ..()
	if(on)
		. += "It's turned on."
	if(timer)
		. += "Its timer has [timer] seconds left."
	if(det_mode)
		. += "It appears set to demolition mode, providing a wider explosion with little damage to walls."
	else
		. += "It appears set to breaching mode, providing a focused explosion which breaches through walls."

	if(armed)
		. += "<b>It is armed!</b>"

/obj/item/detpack/Destroy()
	if(sound_timer)
		deltimer(sound_timer)
		sound_timer = null
	if(detonation_pending)
		deltimer(detonation_pending)
		detonation_pending = null
	if(plant_target && !boom) //whatever name you give it
		loc = get_turf(src)
		nullvars()
	else
		nullvars()
	return ..()

/obj/item/detpack/ex_act()
	return

/obj/item/detpack/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)


/obj/item/detpack/update_icon_state()
	. = ..()
	icon_state = "detpack_[plant_target ? "set_" : ""]"
	if(on)
		icon_state = "[icon_state][armed ? "armed" : "on"]"
	else
		icon_state = "[icon_state]off"


/obj/item/detpack/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(issignaler(I))
		var/obj/item/assembly/signaler/signaler = I
		code = signaler.code
		set_frequency(signaler.frequency)
		balloon_alert(user, "frequency copied")

/obj/item/detpack/unique_action(mob/user, special_treatment)
	. = ..()
	on = !on
	update_icon()

/obj/item/detpack/attack_hand(mob/living/user)
	if(armed)
		balloon_alert(user, "disarm it first!")
		return
	if(plant_target)
		user.visible_message(span_notice("[user] begins unsecuring [src] from [plant_target]."),
		span_notice("You begin unsecuring [src] from [plant_target]."))
		if(!do_after(user, 3 SECONDS, NONE, src, BUSY_ICON_BUILD))
			return
		user.visible_message(span_notice("[user] unsecures [src] from [plant_target]."),
		span_notice("You unsecure [src] from [plant_target]."))
		nullvars()
	return ..()

/obj/item/detpack/multitool_act(mob/living/user, obj/item/I)
	if(!armed && !on)
		balloon_alert(user, "inactive!")
		return
	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_METAL)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use the [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		var/fumbling_time = 3 SECONDS
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return

		if(prob((SKILL_ENGINEER_METAL - user.skills.getRating(SKILL_ENGINEER)) * 20))
			to_chat(user, span_userdanger("After several seconds of your clumsy meddling the [src] buzzes angrily as if offended. You have a <i>very</i> bad feeling about this."))
			timer = 0 //Oops. Now you fucked up. Immediate detonation.

	user.visible_message(span_notice("[user] begins disarming [src] with [I]."),
	span_notice("You begin disarming [src] with [I]."))

	if(!do_after(user, 3 SECONDS, NONE, src, BUSY_ICON_FRIENDLY))
		return

	balloon_alert_to_viewers("disarmed")
	disarm()

/obj/item/detpack/proc/nullvars()
	if(ismovable(plant_target) && plant_target.loc)
		var/atom/movable/T = plant_target
		if(T.drag_delay == 3)
			T.drag_delay = target_drag_delay //reset the drag delay of whatever we attached the detpack to
		T.vis_contents -= src
	plant_target = null //null everything out now
	target_drag_delay = null
	armed = FALSE
	boom = FALSE
	SSradio.remove_object(src, frequency)
	radio_connection = null
	update_icon()

/obj/item/detpack/receive_signal(datum/signal/signal)
	if(!signal || !on)
		return

	var/turf/source_location = get_turf(signal.source)
	var/turf/det_location = get_turf(src)
	if(source_location.z != det_location.z)
		return

	if(signal.data["code"] != code)
		return

	if(armed)
		disarm(FALSE)
		return
	if(!plant_target) //has to be planted on something to begin detonating.
		return
	armed = TRUE
	log_bomber(usr, "triggered", src)
	detonation_pending = addtimer(CALLBACK(src, PROC_REF(do_detonate)), timer SECONDS, TIMER_STOPPABLE)
	if(timer > 10)
		sound_timer = addtimer(CALLBACK(src, PROC_REF(do_play_sound_normal)), 1 SECONDS, TIMER_LOOP|TIMER_STOPPABLE)
		addtimer(CALLBACK(src, PROC_REF(change_to_loud_sound)), timer-10)
	else
		sound_timer = addtimer(CALLBACK(src, PROC_REF(do_play_sound_loud)), 1 SECONDS, TIMER_LOOP|TIMER_STOPPABLE)
	update_icon()

/obj/item/detpack/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		set_frequency(new_frequency)

	else if(href_list["code"])
		code += text2num(href_list["code"])
		code = clamp(round(code), 1, 100)

	else if(href_list["det_mode"])
		det_mode = !det_mode
		update_icon()

	else if(href_list["power"])
		on = !on
		update_icon()

	else if(href_list["timer"])
		timer += text2num(href_list["timer"])
		timer = clamp(round(timer), DETPACK_TIMER_MIN, DETPACK_TIMER_MAX)

	updateUsrDialog()



/obj/item/detpack/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_METAL)
		if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE

	return TRUE


/obj/item/detpack/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = {"
<A href='byond://?src=[text_ref(src)];power=1'>Turn [on ? "Off" : "On"]</A><BR>
<B>Current Detonation Mode:</B> [det_mode ? "Demolition" : "Breach"]<BR>
<A href='byond://?src=[text_ref(src)];det_mode=1'><B>Set Detonation Mode:</B> [det_mode ? "Breach" : "Demolition"]</A><BR>
<B>Frequency/Code for Detpack:</B><BR>
<A href='byond://?src=[text_ref(src)];freq=-10'>-</A>
<A href='byond://?src=[text_ref(src)];freq=-2'>-</A>
[format_frequency(src.frequency)]
<A href='byond://?src=[text_ref(src)];freq=2'>+</A>
<A href='byond://?src=[text_ref(src)];freq=10'>+</A><BR>
<B>Signal Code:</B><BR>
<A href='byond://?src=[text_ref(src)];code=-5'>-</A>
<A href='byond://?src=[text_ref(src)];code=-1'>-</A> [code]
<A href='byond://?src=[text_ref(src)];code=1'>+</A>
<A href='byond://?src=[text_ref(src)];code=5'>+</A><BR>
<B>Timer (Max 300 seconds, Min 5 seconds):</B><BR>
<A href='byond://?src=[text_ref(src)];timer=-50'>-</A>
<A href='byond://?src=[text_ref(src)];timer=-10'>-</A>
<A href='byond://?src=[text_ref(src)];timer=-5'>-</A>
<A href='byond://?src=[text_ref(src)];timer=-1'>-</A> [timer]
<A href='byond://?src=[text_ref(src)];timer=1'>+</A>
<A href='byond://?src=[text_ref(src)];timer=5'>+</A>
<A href='byond://?src=[text_ref(src)];timer=10'>+</A>
<A href='byond://?src=[text_ref(src)];timer=50'>+</A><BR>"}

	var/datum/browser/popup = new(user, "detpack")
	popup.set_content(dat)
	popup.open()


/obj/item/detpack/afterattack(atom/target, mob/user, flag)
	if(!flag)
		return FALSE
	if(issignaler(target))
		var/obj/item/assembly/signaler/signaler = target
		code = signaler.code
		set_frequency(signaler.frequency)
		to_chat(user, "You transfer the frequency and code of [signaler] to [src].")
		return
	if(istype(target, /obj/item) || istype(target, /mob))
		return FALSE
	if(target.resistance_flags & INDESTRUCTIBLE)
		return FALSE
	if(istype(target, /obj/vehicle/unmanned))
		var/obj/vehicle/unmanned/unmanned_target = target
		if(!unmanned_target.allow_explosives)
			to_chat(user, "[span_warning("[src] doesnt fit on [unmanned_target]")]!")
			return FALSE
	if(istype(target, /obj/structure/window))
		var/obj/structure/window/W = target
		if(!(W.resistance_flags & INDESTRUCTIBLE))
			to_chat(user, "[span_warning("[W] is much too tough for you to do anything to it with [src]")].")
			return FALSE
	if((locate(/obj/item/detpack) in target) || (locate(/obj/item/explosive/plastique) in target)) //This needs a refactor.
		to_chat(user, "[span_warning("There is already a device attached to [target]")].")
		return FALSE

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_METAL)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		if(!do_after(user, 5 SECONDS, NONE, target, BUSY_ICON_UNSKILLED))
			return

	user.visible_message(span_warning("[user] is trying to plant [name] on [target]!"),
	span_warning("You are trying to plant [name] on [target]!"))

	if(do_after(user, 3 SECONDS, NONE, target, BUSY_ICON_HOSTILE))
		if((locate(/obj/item/detpack) in target) || (locate(/obj/item/explosive/plastique) in target)) //This needs a refactor.
			to_chat(user, "[span_warning("There is already a device attached to [target]")].")
			return
		user.drop_held_item()
		playsound(src.loc, 'sound/weapons/mine_armed.ogg', 25, 1)
		var/location
		location = target
		forceMove(location)
		boom_direction = get_dir(user, location)

		log_game("[key_name(user)] planted [src.name] on [target.name] at [AREACOORD(target.loc)] with [timer] second fuse.")
		message_admins("[ADMIN_TPMONTY(user)] planted [src.name] on [target.name] at [ADMIN_VERBOSEJMP(target.loc)] with [timer] second fuse.")

		notify_ghosts("<b>[user]</b> has planted \a <b>[name]</b> on <b>[target.name]</b> with a <b>[timer]</b> second fuse!", source = user, action = NOTIFY_ORBIT)

		target.balloon_alert_to_viewers("[timer] seconds", vision_distance = COMBAT_MESSAGE_RANGE)

		plant_target = target
		if(ismovable(plant_target))
			var/atom/movable/T = plant_target
			T.vis_contents += src
			if(T.drag_delay < 3) //Anything with a fast drag delay we need to modify to avoid kamikazi tactics
				target_drag_delay = T.drag_delay
				T.drag_delay = 3
		if(radio_connection == null)
			set_frequency(frequency)
		update_icon()

/obj/item/detpack/proc/change_to_loud_sound()
	if(sound_timer)
		deltimer(sound_timer)
		sound_timer = addtimer(CALLBACK(src, PROC_REF(do_play_sound_loud)), 1 SECONDS, TIMER_LOOP|TIMER_STOPPABLE)

/obj/item/detpack/proc/do_play_sound_normal()
	timer--
	playsound(loc, 'sound/weapons/mine_tripped.ogg', 50, FALSE)

/obj/item/detpack/proc/do_play_sound_loud()
	timer--
	playsound(loc, 'sound/weapons/mine_tripped.ogg', 160 + (timer-timer*2)*10, FALSE) //Gets louder as we count down to armaggedon

/obj/item/detpack/proc/disarm(turn_off = TRUE)
	if(timer < DETPACK_TIMER_MIN) //reset to minimum 5 seconds; no 'cooking' with aborted detonations.
		timer = DETPACK_TIMER_MIN
	if(sound_timer)
		deltimer(sound_timer)
		sound_timer = null
	if(detonation_pending)
		deltimer(detonation_pending)
		detonation_pending = null
	armed = FALSE
	if(turn_off)
		on = FALSE
	update_icon()

/obj/item/detpack/proc/do_detonate()
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
	var/turf/det_location = get_turf(plant_target)
	plant_target.ex_act(EXPLODE_DEVASTATE)
	plant_target = null
	if(det_mode == TRUE) //If we're on demolition mode, big boom.
		explosion(det_location, 0, 7, 9, 0, 7, explosion_cause=src) // TODO PASS THE USER HERE
	else //if we're not, focused boom.
		if(iswallturf(det_location)) //Breach the other side of the wall if planted on one
			det_location = get_step(det_location, boom_direction)
		explosion(det_location, 3, 4, 4, 0, 4, explosion_cause=src) // TODO PASS THE USER HERE
	qdel(src)

/obj/item/detpack/attack(mob/M as mob, mob/user as mob, def_zone)
	return

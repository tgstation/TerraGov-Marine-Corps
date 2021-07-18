//Deployable turrets. They can be either automated, manually fired, or installed with a pAI.
//They are built in stages, and only engineers have access to them.

/obj/item/ammo_magazine/sentry
	name = "\improper M30 box magazine (10x28mm Caseless)"
	desc = "A box of 500 10x28mm caseless rounds for the UA 571-C sentry gun. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "ammo_can"
	flags_magazine = NONE //can't be refilled or emptied by hand
	caliber = CALIBER_10X28
	max_rounds = 500
	default_ammo = /datum/ammo/bullet/turret
	gun_type = null


/obj/item/storage/box/sentry
	name = "\improper UA 571-C sentry crate"
	desc = "A large case containing all you need to set up an automated sentry, minus the tools."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE
	max_w_class = 5
	storage_slots = 4
	max_storage_space = 16
	bypass_w_limit = list(
		/obj/item/turret_top,
		/obj/item/turret_tripod,
		/obj/item/cell,
		/obj/item/ammo_magazine/sentry,
	)

/obj/item/storage/box/sentry/Initialize()
	. = ..()
	new /obj/item/turret_top(src)
	new /obj/item/turret_tripod(src)
	new /obj/item/cell/high(src)
	new /obj/item/ammo_magazine/sentry(src)


/obj/item/turret_top
	name = "\improper UA 571-C turret"
	desc = "The turret part of an automated sentry turret."
	resistance_flags = UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "sentry_head"


/obj/item/turret_tripod
	name = "\improper UA 571-C turret tripod"
	desc = "The tripod part of an automated sentry turret. You should deploy it first."
	resistance_flags = UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "sentry_tripod_folded"

/obj/item/turret_tripod/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/turf/target = get_step(user.loc,user.dir)
	if(!target)
		return

	if(check_blocked_turf(target)) //check if blocked
		to_chat(user, "<span class='warning'>There is insufficient room to deploy [src]!</span>")
		return

	user.visible_message("<span class='notice'>[user] starts unfolding \the [src].</span>",
			"<span class='notice'>You start unfolding \the [src].</span>")

	if(do_after(user, 30, TRUE, src, BUSY_ICON_BUILD))
		var/obj/machinery/turret_tripod_deployed/S = new /obj/machinery/turret_tripod_deployed/(target)
		S.setDir(user.dir)
		user.visible_message("<span class='notice'>[user] unfolds \the [S].</span>",
			"<span class='notice'>You unfold \the [S].</span>")
		playsound(target, 'sound/weapons/mine_armed.ogg', 25)
		S.update_icon()
		qdel(src)


/obj/machinery/turret_tripod_deployed
	name = "\improper UA 571-C turret tripod"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an M30 Autocannon and a 500-round drum magazine."
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "sentry_tripod"
	anchored = FALSE
	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
	density = TRUE
	layer = ABOVE_MOB_LAYER //So you can't hide it under corpses
	use_power = 0
	var/has_top = FALSE

/obj/machinery/turret_tripod_deployed/examine(mob/user as mob)
	. = ..()
	if(!anchored)
		to_chat(user, "<span class='info'>It must be <B>wrenched</B> to the floor.</span>")
	else if(!has_top)
		to_chat(user, "<span class='info'>The <B>main turret</B> is not installed.</span>")
	else if(has_top && anchored)
		to_chat(user, "<span class='info'>It must be <B>screwed</B> to finish it.</span>")

/obj/machinery/turret_tripod_deployed/MouseDrop(over_object, src_location, over_location) //Drag the tripod onto you to fold it.
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr //this is us
	if(!over_object == user || !in_range(src, user))
		return

	if(anchored)
		to_chat(user, "<span class='warning'>You must unanchor \the [src] to retrieve it!</span>")
		return

	else if(has_top)
		to_chat(user, "<span class='warning'>You must remove the turret top first!</span>")
		return

	user.visible_message("<span class='notice'>[user] begins to fold up and retrieve \the [src].</span>",
	"<span class='notice'>You begin to fold up and retrieve \the [src].</span>")
	if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD) || !anchored)
		return
	user.visible_message("<span class='notice'>[user] folds up and retrieves \the [src].</span>",
	"<span class='notice'>You fold up and retrieve \the [src].</span>")
	var/obj/item/turret_tripod/T = new(loc)
	user.put_in_hands(T)
	qdel(src)

/obj/machinery/turret_tripod_deployed/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		if(anchored)
			user.visible_message("<span class='notice'>[user] begins unsecuring \the [src] from the ground.</span>",
			"<span class='notice'>You begin unsecuring \the [src] from the ground.</span>")

			if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
				return

			user.visible_message("<span class='notice'>[user] unsecures \the [src] from the ground.</span>",
			"<span class='notice'>You unsecure \the [src] from the ground.</span>")
			anchored = FALSE
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		else
			user.visible_message("<span class='notice'>[user] begins securing \the [src] to the ground.</span>",
			"<span class='notice'>You begin securing \the [src] to the ground.</span>")

			if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
				return

			user.visible_message("<span class='notice'>[user] secures \the [src] to the ground.</span>",
			"<span class='notice'>You secure \the [src] to the ground.</span>")
			anchored = TRUE
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

	else if(istype(I, /obj/item/turret_top))
		var/obj/item/turret_top/T = I
		if(!anchored)
			to_chat(user, "<span class='warning'>You must wrench \the [src] to the ground first!</span>")
			return
		if(has_top)
			to_chat(user, "<span class='warning'>\The [src] already has a top attached! Use a screwdriver to secure it.</span>")
			return

		user.visible_message("<span class='notice'>[user] begins attaching the turret top to \the [src].</span>",
		"<span class='notice'>You begin attaching the turret top to \the [src].</span>")

		if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
			return

		user.visible_message("<span class='notice'>[user] attaches the turret top to \the [src].</span>",
		"<span class='notice'>You attach the turret top to \the [src].</span>")
		has_top = TRUE
		icon_state = "sentry_base"
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		qdel(T)

	else if(isscrewdriver(I))
		if(!anchored)
			to_chat(user, "<span class='warning'>You must wrench \the [src] to the ground first!</span>")
			return

		if(!has_top)
			to_chat(user, "<span class='warning'>You must attach a top to \the [src] first!.</span>")
			return

		user.visible_message("<span class='notice'>[user] begins finalizing \the [src].</span>",
		"<span class='notice'>You begin finalizing \the [src].</span>")

		if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
			return

		var/obj/machinery/marine_turret/S = new /obj/machinery/marine_turret(loc)
		S.setDir(dir)
		user.visible_message("<span class='notice'>[user] finishes \the [S].</span>",
			"<span class='notice'>You finish \the [S].</span>")
		playsound(S.loc, 'sound/weapons/mine_armed.ogg', 25)
		S.update_icon()
		qdel(src)

	else if(iscrowbar(I))
		if(!has_top)
			to_chat(user, "<span class='warning'>You cannot remove the top if \the [src] doesn't have any yet!</span>")
			return

		user.visible_message("<span class='notice'>[user] begins removing the turret top from \the [src].</span>",
		"<span class='notice'>You begin removing the turret top from \the [src].</span>")

		if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
			return

		user.visible_message("<span class='notice'>[user] removes turret top from \the [src].</span>",
		"<span class='notice'>You remove the turret top from \the [src].</span>")
		has_top = FALSE
		icon_state = "sentry_tripod"
		new /obj/item/turret_top(loc)
		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)

/obj/machinery/marine_turret
	name = "\improper UA 571-C sentry gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with a M30 autocannon and a 500-round drum magazine."
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "sentry_base"
	anchored = TRUE
	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
	density = TRUE
	layer = ABOVE_MOB_LAYER //So you can't hide it under corpses
	use_power = 0
	req_one_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_LEADER)
	hud_possible = list(MACHINE_HEALTH_HUD, SENTRY_AMMO_HUD)
	var/turret_flags = TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS
	/// The iff bitfield used to determine friendlies from hostiles
	var/iff_signal = NONE
	var/rounds = 500
	var/rounds_max = 500
	var/burst_size = 5
	var/max_burst = 6
	var/min_burst = 2
	var/atom/target = null
	obj_integrity = 150
	max_integrity = 150
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 0, "fire" = 80, "acid" = 50)
	machine_stat = 0 //Used just like mob.stat
	var/datum/effect_system/spark_spread/spark_system //The spark system, used for generating... sparks?
	var/obj/item/cell/cell
	var/initial_cell_type = /obj/item/cell/high
	var/obj/machinery/camera/camera
	var/fire_delay = 3
	var/burst_delay = 5
	var/range = 7
	var/muzzle_flash_lum = 3 //muzzle flash brightness
	var/obj/item/turret_laptop/laptop = null
	var/datum/ammo/bullet/turret/ammo = /datum/ammo/bullet/turret
	var/obj/projectile/in_chamber = null
	var/last_alert = 0
	var/last_damage_alert = 0
	var/list/obj/alert_list = list()
	var/knockdown_threshold = 150
	var/work_time = 40 //Defines how long it takes to do most maintenance actions
	var/magazine_type = /obj/item/ammo_magazine/sentry
	var/obj/item/radio/radio

/obj/machinery/marine_turret/examine(mob/user)
	. = ..()
	if(isxeno(user))
		to_chat(user, "<span class='warning'>There's many strange numbers and indicators on this device we don't understand.</span>")
		return

	var/list/details = list()

	if(CHECK_BITFIELD(turret_flags, TURRET_ON))
		details +=("Its diagnostic display reads <b>([obj_integrity]/[max_integrity])</b> integrity.</br>")
		details +=("Its ammo counter reads <b>([rounds]/[rounds_max])</b>.</br>")
		details +=("It's turned on.</br>")

	if(CHECK_BITFIELD(turret_flags, TURRET_SAFETY))
		details +=("Its safeties are on.</br>")

	if(CHECK_BITFIELD(turret_flags, TURRET_MANUAL))
		details +=("Its manual override is active.</br>")
	else
		details += ("It's set to [CHECK_BITFIELD(turret_flags, TURRET_RADIAL) ? "360" : "directional targeting"] mode.</br>")

	if(CHECK_BITFIELD(turret_flags, TURRET_ALERTS))
		details +=("Its alert mode is active.</br>")

	if(!ammo || !rounds)
		details +=("<span class='danger'>It has no ammo!</br></span>")

	if(!cell || cell.charge == 0)
		details +=("<span class='danger'>It is unpowered!</br></span>")

	to_chat(user, "<span class='warning'>[details.Join(" ")]</span>")


/obj/machinery/marine_turret/Initialize()
	. = ..()
	radio = new(src)
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(initial_cell_type)
		cell = new initial_cell_type(src)
	if(CHECK_BITFIELD(turret_flags, TURRET_HAS_CAMERA))
		camera = new (src)
		camera.network = list("military")
		camera.c_tag = "[name] ([rand(0, 1000)])"
	machine_stat = NONE
	//START_PROCESSING(SSobj, src)
	ammo = GLOB.ammo_list[ammo]
	update_icon()
	GLOB.marine_turrets += src
	prepare_huds() //Set up HUDS
	for(var/datum/atom_hud/squad/sentry_status_hud in GLOB.huds) //Add to the squad HUD
		sentry_status_hud.add_to_hud(src)
	hud_set_machine_health()
	hud_set_sentry_ammo()

/obj/machinery/marine_turret/proc/turn_off() //We turn the turret off
	if(!CHECK_BITFIELD(turret_flags, TURRET_ON)) //We're already off
		return
	visible_message("<span class='notice'>The [name] powers down and goes silent.</span>")
	DISABLE_BITFIELD(turret_flags, TURRET_ON)
	target = null
	alert_list = list()
	set_light(0)
	update_icon()
	stop_processing()

/obj/machinery/marine_turret/Destroy() //Clear these for safety's sake.
	QDEL_NULL(radio)
	operator?.unset_interaction()
	QDEL_NULL(camera)
	QDEL_NULL(cell)
	target = null
	alert_list = list()
	stop_processing()
	GLOB.marine_turrets -= src
	. = ..()

/obj/machinery/marine_turret/obj_destruction(damage_amount, damage_type, damage_flag)
	sentry_alert(SENTRY_ALERT_DESTROYED)
	. = ..()

/obj/machinery/marine_turret/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!cell || cell.charge <= 0)
		to_chat(user, "<span class='warning'>You try to activate [src] but nothing happens. The cell must be empty.</span>")
		return

	if(!anchored)
		to_chat(user, "<span class='warning'>It must be anchored to the ground before you can activate it.</span>")
		return

	if(CHECK_BITFIELD(turret_flags, TURRET_IMMOBILE))
		to_chat(user, "<span class='warning'>[src]'s panel is completely locked, you can't do anything.</span>")
		return

	if(machine_stat)
		user.visible_message("<span class='notice'>[user] begins to set [src] upright.</span>",
		"<span class='notice'>You begin to set [src] upright.</span>")
		if(do_after(user,20, TRUE, src, BUSY_ICON_BUILD))
			user.visible_message("<span class='notice'>[user] sets [src] upright.</span>",
			"<span class='notice'>You set [src] upright.</span>")
			machine_stat = 0
			update_icon()
		return

	if(CHECK_BITFIELD(turret_flags, TURRET_LOCKED))
		to_chat(user, "<span class='warning'>[src]'s control panel is locked! Only a Squad Leader or Engineer can unlock it now.</span>")
		return

	user.set_interaction(src)
	ui_interact(user)



/obj/machinery/marine_turret/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Sentry", "Sentry Gun")
		ui.open()

/obj/machinery/marine_turret/ui_data(mob/user)
	. = list(
		"name" = copytext(src.name, 2),
		"is_on" = CHECK_BITFIELD(turret_flags, TURRET_ON),
		"rounds" = rounds,
		"rounds_max" = rounds_max,
		"health" = obj_integrity,
		"health_max" = max_integrity,
		"has_cell" = (cell ? 1 : 0),
		"cell_charge" = cell ? cell.charge : 0,
		"cell_maxcharge" = cell ? cell.maxcharge : 0,
		"dir" = dir,
		"burst_fire" = CHECK_BITFIELD(turret_flags, TURRET_BURSTFIRE),
		"safety_toggle" = CHECK_BITFIELD(turret_flags, TURRET_SAFETY),
		"manual_override" = CHECK_BITFIELD(turret_flags, TURRET_MANUAL),
		"alerts_on" = CHECK_BITFIELD(turret_flags, TURRET_ALERTS),
		"radial_mode" = CHECK_BITFIELD(turret_flags, TURRET_RADIAL),
		"burst_size" = burst_size,
		"mini" = istype(src, /obj/machinery/marine_turret/mini)
	)

/obj/machinery/marine_turret/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return

	switch(action)

		if("burst")
			if(!cell || cell.charge <= 0 || !anchored || CHECK_BITFIELD(turret_flags, TURRET_IMMOBILE) || !CHECK_BITFIELD(turret_flags, TURRET_ON) || machine_stat)
				return

			if(CHECK_BITFIELD(turret_flags, TURRET_BURSTFIRE))
				DISABLE_BITFIELD(turret_flags, TURRET_BURSTFIRE)
				visible_message("A green light on [src] blinks slowly.")
				to_chat(usr, "<span class='notice'>You deactivate the burst fire mode.</span>")
			else
				ENABLE_BITFIELD(turret_flags, TURRET_BURSTFIRE)
				fire_delay = burst_delay
				user.visible_message("<span class='notice'>[user] activates [src]'s burst fire mode.</span>",
				"<span class='notice'>You activate [src]'s burst fire mode.</span>")
				visible_message("<span class='notice'>A green light on [src] blinks rapidly.</span>")
			. = TRUE

		if("burstup")
			if(!cell || cell.charge <= 0 || !anchored || CHECK_BITFIELD(turret_flags, TURRET_IMMOBILE) || !CHECK_BITFIELD(turret_flags, TURRET_ON) || machine_stat)
				return

			burst_size = clamp(burst_size + 1, min_burst, max_burst)
			user.visible_message("<span class='notice'>[user] increments the [src]'s burst count.</span>",
			"<span class='notice'>You increment [src]'s burst fire count.</span>")
			. = TRUE

		if("burstdown")
			if(!cell || cell.charge <= 0 || !anchored || CHECK_BITFIELD(turret_flags, TURRET_IMMOBILE) || !CHECK_BITFIELD(turret_flags, TURRET_ON) || machine_stat)
				return

			burst_size = clamp(burst_size - 1, min_burst, max_burst)
			user.visible_message("<span class='notice'>[user] decrements the [src]'s burst count.</span>",
			"<span class='notice'>You decrement [src]'s burst fire count.</span>")
			. = TRUE

		if("safety")
			if(!cell || cell.charge <= 0 || !anchored || CHECK_BITFIELD(turret_flags, TURRET_IMMOBILE) || !CHECK_BITFIELD(turret_flags, TURRET_ON) || machine_stat)
				return

			TOGGLE_BITFIELD(turret_flags, TURRET_SAFETY)
			var/safe = CHECK_BITFIELD(turret_flags, TURRET_SAFETY)
			user.visible_message("<span class='warning'>[user] [safe ? "" : "de"]activates [src]'s safety lock.</span>",
			"<span class='warning'>You [safe ? "" : "de"]activate [src]'s safety lock.</span>")
			visible_message("<span class='warning'>A red light on [src] blinks brightly!")
			. = TRUE

		if("manual") //Alright so to clean this up, fuck that manual control pop up. Its a good idea but its not working out in practice.
			if(!CHECK_BITFIELD(turret_flags, TURRET_MANUAL))
				if(operator != user && operator) //Don't question this. If it has operator != user it wont fucken work. Like for some reason this does it proper.
					to_chat(user, "<span class='warning'>Someone is already controlling [src].</span>")
					return
				if(!operator) //Make sure we can use it.
					operator = user
					user.visible_message("<span class='notice'>[user] takes manual control of [src]</span>",
					"<span class='notice'>You take manual control of [src]</span>")
					visible_message("<span class='warning'>The [name] buzzes: <B>WARNING!</B> MANUAL OVERRIDE INITIATED.</span>")
					user.set_interaction(src)
					ENABLE_BITFIELD(turret_flags, TURRET_MANUAL)
				else
					if(user.interactee)
						user.visible_message("<span class='notice'>[user] lets go of [src]</span>",
						"<span class='notice'>You let go of [src]</span>")
						visible_message("<span class='notice'>The [name] buzzes: AI targeting re-initialized.</span>")
						user.unset_interaction()
					else
						to_chat(user, "<span class='warning'>You are not currently overriding this turret.</span>")
				if(machine_stat == 2)
					machine_stat = 0 //Weird bug goin on here
			else //Seems to be a bug where the manual override isn't properly deactivated; this toggle should fix that.
				visible_message("<span class='notice'>The [name] buzzes: AI targeting re-initialized.</span>")
				DISABLE_BITFIELD(turret_flags, TURRET_MANUAL)
				operator = null
				user.unset_interaction()
			. = TRUE

		if("power")
			if(!CHECK_BITFIELD(turret_flags, TURRET_ON))
				user.visible_message("<span class='notice'>[user] activates [src].</span>",
				"<span class='notice'>You activate [src].</span>")
				visible_message("<span class='notice'>The [name] hums to life and emits several beeps.</span>")
				visible_message("<span class='notice'>The [name] buzzes in a monotone voice: 'Default systems initiated'.</span>'")
				target = null
				ENABLE_BITFIELD(turret_flags, TURRET_ON)
				set_light(SENTRY_LIGHT_POWER)
				var/obj/item/card/id/id = user.get_idcard()
				iff_signal = id?.iff_signal
				if(!camera && CHECK_BITFIELD(turret_flags, TURRET_HAS_CAMERA))
					camera = new /obj/machinery/camera(src)
					camera.network = list("military")
					camera.c_tag = src.name
				update_icon()
			else
				user.visible_message("<span class='notice'>[user] deactivates [src].</span>",
				"<span class='notice'>You deactivate [src].</span>")
				turn_off()
			. = TRUE

		if("toggle_alert")
			TOGGLE_BITFIELD(turret_flags, TURRET_ALERTS)
			var/alert = CHECK_BITFIELD(turret_flags, TURRET_ALERTS)
			user.visible_message("<span class='notice'>[user] [alert ? "" : "de"]activates [src]'s alert notifications.</span>",
			"<span class='notice'>You [alert ? "" : "de"]activate [src]'s alert notifications.</span>")
			visible_message("<span class='notice'>The [name] buzzes in a monotone voice: 'Alert notification system [alert ? "initiated" : "deactivated"]'.</span>")
			update_icon()
			. = TRUE

		if("toggle_radial")
			TOGGLE_BITFIELD(turret_flags, TURRET_RADIAL)
			var/rad_msg = CHECK_BITFIELD(turret_flags, TURRET_RADIAL) ? "activate" : "deactivate"
			user.visible_message("<span class='notice'>[user] [rad_msg]s [src]'s radial mode.</span>", "<span class='notice'>You [rad_msg] [src]'s radial mode.</span>")
			visible_message("The [name] buzzes in a monotone voice: 'Radial mode [rad_msg]d'.'")
			range = CHECK_BITFIELD(turret_flags, TURRET_RADIAL) ? 3 : 7
			update_icon()
			. = TRUE

	attack_hand(user)

//Manual override turns off automatically once the user no longer interacts with the turret.
/obj/machinery/marine_turret/on_unset_interaction(mob/user)
	..()
	if(CHECK_BITFIELD(turret_flags, TURRET_MANUAL) && operator == user)
		operator = null
		DISABLE_BITFIELD(turret_flags, TURRET_MANUAL)

/obj/machinery/marine_turret/check_eye(mob/user)
	if(user.incapacitated() || get_dist(user, src) > 1 || is_blind(user) || user.lying_angle || !user.client)
		user.unset_interaction()

/obj/machinery/marine_turret/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ishuman(user))
		return

	//Panel access
	else if(istype(I, /obj/item/card/id))
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return

		TOGGLE_BITFIELD(turret_flags, TURRET_LOCKED)
		user.visible_message("<span class='notice'>[user] [CHECK_BITFIELD(turret_flags, TURRET_LOCKED) ? "locks" : "unlocks"] [src]'s panel.</span>",
		"<span class='notice'>You [CHECK_BITFIELD(turret_flags, TURRET_LOCKED) ? "lock" : "unlock"] [src]'s panel.</span>")
		if(CHECK_BITFIELD(turret_flags, TURRET_LOCKED))
			if(user.interactee == src)
				user.unset_interaction()
				DIRECT_OUTPUT(user, browse(null, "window=turret"))
		else
			if(user.interactee == src)
				attack_hand(user)

	//Securing/Unsecuring
	else if(iswrench(I))
		if(CHECK_BITFIELD(turret_flags, TURRET_IMMOBILE))
			to_chat(user, "<span class='warning'>[src] is completely welded in place. You can't move it without damaging it.</span>")
			return

		//Unsecure
		if(anchored)
			if(CHECK_BITFIELD(turret_flags, TURRET_ON))
				to_chat(user, "<span class='warning'>You depower [src] to unanchor it safely.</span>")
				turn_off()

			user.visible_message("<span class='notice'>[user] begins unanchoring [src] from the ground.</span>",
			"<span class='notice'>You begin unanchoring [src] from the ground.</span>")

			if(!do_after(user, work_time, TRUE, src, BUSY_ICON_BUILD))
				return

			user.visible_message("<span class='notice'>[user] unanchors [src] from the ground.</span>",
			"<span class='notice'>You unanchor [src] from the ground.</span>")
			anchored = FALSE
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		else
			user.visible_message("<span class='notice'>[user] begins securing [src] to the ground.</span>",
			"<span class='notice'>You begin securing [src] to the ground.</span>")

			if(!do_after(user, work_time, TRUE, src, BUSY_ICON_BUILD))
				return

			user.visible_message("<span class='notice'>[user] secures [src] to the ground.</span>",
			"<span class='notice'>You secure [src] to the ground.</span>")
			anchored = TRUE
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

	// Rotation
	else if(isscrewdriver(I))
		if(CHECK_BITFIELD(turret_flags, TURRET_IMMOBILE))
			to_chat(user, "<span class='warning'>[src] is completely welded in place. You can't move it without damaging it.</span>")
			return

		if(CHECK_BITFIELD(turret_flags, TURRET_ON))
			to_chat(user, "<span class='warning'>You deactivate [src] to prevent its motors from interfering with your rotation.</span>")
			turn_off()

		playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] rotates [src].</span>",
		"<span class='notice'>You rotate [src].</span>")
		if(dir == NORTH)
			setDir(EAST)
		else if(dir == EAST)
			setDir(SOUTH)
		else if(dir == SOUTH)
			setDir(WEST)
		else if(dir == WEST)
			setDir(NORTH)

	else if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(obj_integrity < 0 || machine_stat)
			to_chat(user, "<span class='warning'>[src]'s internal circuitry is ruined, there's no way you can salvage this on the go.</span>")
			return

		if(obj_integrity >= max_integrity)
			to_chat(user, "<span class='warning'>[src] isn't in need of repairs.</span>")
			return

		if(!WT.remove_fuel(0, user))
			return

		user.visible_message("<span class='notice'>[user] begins repairing [src].</span>",
		"<span class='notice'>You begin repairing [src].</span>")
		if(!do_after(user, 50, TRUE, src, BUSY_ICON_FRIENDLY))
			return

		user.visible_message("<span class='notice'>[user] repairs [src].</span>",
		"<span class='notice'>You repair [src].</span>")
		repair_damage(50)
		hud_set_machine_health() //Update our HUD health
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)

	else if(iscrowbar(I))

		//Remove battery if possible
		if(!anchored && !CHECK_BITFIELD(turret_flags, TURRET_IMMOBILE))
			return

		if(!cell)
			to_chat(user, "<span class='warning'>There's no power cell to remove!</span>")
			return

		if(CHECK_BITFIELD(turret_flags, TURRET_ON))
			to_chat(user, "<span class='warning'>You depower [src] to safely remove the battery.</span>")
			turn_off()

		user.visible_message("<span class='notice'>[user] begins removing [src]'s [cell.name].</span>",
		"<span class='notice'>You begin removing [src]'s [cell.name].</span>")

		if(!do_after(user, work_time, TRUE, src, BUSY_ICON_BUILD))
			return

		user.visible_message("<span class='notice'>[user] removes [src]'s [cell.name].</span>",
		"<span class='notice'>You remove [src]'s [cell.name].</span>")
		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
		user.put_in_hands(cell)
		cell.update_icon()
		cell = null
		update_icon()

	else if(istype(I, /obj/item/cell))
		if(cell)
			to_chat(user, "<span class='warning'>There is already \a [cell.name] installed in [src]! Remove it with a crowbar first!</span>")
			return

		user.visible_message("<span class='notice'>[user] begins installing \a [I] into [src].</span>",
		"<span class='notice'>You begin installing \a [I] into [src].</span>")
		if(!do_after(user, work_time, TRUE, src, BUSY_ICON_BUILD))
			return

		user.transferItemToLoc(I, src)
		user.visible_message("<span class='notice'>[user] installs \a [I] into [src].</span>",
		"<span class='notice'>You install \a [I] into [src].</span>")
		cell = I
		update_icon()

	else if(istype(I, magazine_type))
		var/obj/item/ammo_magazine/M = I
		if(user.skills.getRating("heavy_weapons") < SKILL_HEAVY_WEAPONS_TRAINED)
			user.visible_message("<span class='notice'>[user] begins fumbling about, swapping a new [I] into [src].</span>",
			"<span class='notice'>You begin fumbling about, swapping a new [I] into [src].</span>")
			if(user.do_actions)
				return
			if(!do_after(user, work_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return

		playsound(loc, 'sound/weapons/guns/interact/smartgun_unload.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] swaps a new [I] into [src].</span>",
		"<span class='notice'>You swap a new [I] into [src].</span>")
		user.drop_held_item()
		update_icon()

		if(rounds)
			var/obj/item/ammo_magazine/S = new magazine_type(user.loc)
			S.current_rounds = rounds
		rounds = min(M.current_rounds, rounds_max)
		hud_set_sentry_ammo()
		qdel(I)


/obj/machinery/marine_turret/update_icon_state()
	if(machine_stat && obj_integrity > 0) //Knocked over
		density = FALSE
		icon_state = "sentry_fallen"
		turn_off()
		stop_processing()
		return
	density = initial(density)
	icon_state = "sentry_base"


/obj/machinery/marine_turret/update_overlays()
	. = ..()
	if(rounds)
		. += image('icons/Marine/sentry.dmi', src, "sentry_ammo")
	else
		. += image('icons/Marine/sentry.dmi', src, "sentry_ammo_empty")

	if(!cell || cell.charge <= 0)
		turn_off()
		. += image('icons/Marine/sentry.dmi', src, "sentry_batt_black")
		return

	switch(CEILING(((cell.charge / max(cell.maxcharge, 1)) * 100), 25))
		if(100)
			. += image('icons/Marine/sentry.dmi', src, "sentry_batt_green")
		if(75)
			. += image('icons/Marine/sentry.dmi', src, "sentry_batt_yellow")
		if(50)
			. += image('icons/Marine/sentry.dmi', src, "sentry_batt_orange")
		if(25)
			. += image('icons/Marine/sentry.dmi', src, "sentry_batt_red")

	if(CHECK_BITFIELD(turret_flags, TURRET_ON))
		start_processing()
		. += image('icons/Marine/sentry.dmi', src, "sentry_active")
	else
		stop_processing()

/obj/machinery/marine_turret/deconstruct(disassembled = TRUE)
	if(!disassembled)
		explosion(loc, light_impact_range = 3)
	return ..()



/obj/machinery/marine_turret/take_damage(dam)
	if(!machine_stat && dam > 0 && !CHECK_BITFIELD(turret_flags, TURRET_IMMOBILE))
		if(prob(10))
			spark_system.start()
		if(dam > knockdown_threshold) //Knockdown is certain if we deal this much in one hit; no more RNG nonsense, the fucking thing is bolted.
			visible_message("<span class='danger'>The [name] is knocked over!</span>")
			machine_stat = 1
			if(CHECK_BITFIELD(turret_flags, TURRET_ALERTS) && CHECK_BITFIELD(turret_flags, TURRET_ON))
				sentry_alert(SENTRY_ALERT_FALLEN)

	..()

	if(dam > 0 && CHECK_BITFIELD(turret_flags, TURRET_ON) && CHECK_BITFIELD(turret_flags, TURRET_ALERTS) && (world.time > (last_damage_alert + SENTRY_DAMAGE_ALERT_DELAY))) //Alert friendlies
		sentry_alert(SENTRY_ALERT_DAMAGE)
		last_damage_alert = world.time

	hud_set_machine_health() //Update our HUD health


/obj/machinery/marine_turret/proc/check_power(power)
	if (!cell || !CHECK_BITFIELD(turret_flags, TURRET_ON) || machine_stat)
		update_icon()
		return FALSE

	if(cell.charge - power <= 0)
		cell.charge = 0
		sentry_alert(SENTRY_ALERT_BATTERY)
		visible_message("<span class='warning'>[src] emits a low power warning and immediately shuts down!</span>")
		playsound(loc, 'sound/weapons/guns/misc/empty_alarm.ogg', 50, 1)
		turn_off()
		return FALSE

	cell.charge -= power
	return TRUE

/obj/machinery/marine_turret/emp_act(severity)
	if(cell)
		check_power(-(rand(100, 500)))
	if(CHECK_BITFIELD(turret_flags, TURRET_ON))
		if(prob(50))
			visible_message("<span class='danger'>[src] beeps and buzzes wildly, flashing odd symbols on its screen before shutting down!</span>")
			playsound(loc, 'sound/mecha/critdestrsyndi.ogg', 25, 1)
			for(var/i in 1 to 6)
				setDir(pick(NORTH, SOUTH, EAST, WEST))
				sleep(2)
			turn_off()
	take_damage(25)


/obj/machinery/marine_turret/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(rand(90, 150))
		if(EXPLODE_HEAVY)
			take_damage(rand(50, 150))
		if(EXPLODE_LIGHT)
			take_damage(rand(30, 100))


/obj/machinery/marine_turret/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_SENTRY)
	return ..()

/obj/machinery/marine_turret/process()

	if(obj_integrity > 0 && machine_stat != 1)
		machine_stat = 0
	if(!anchored)
		return

	if(!CHECK_BITFIELD(turret_flags, TURRET_ON) || machine_stat == 1 || !cell)
		turn_off()
		return

	if(!check_power(2))
		return

	if(operator || CHECK_BITFIELD(turret_flags, TURRET_MANUAL)) //If someone's firing it manually.
		return

	if(rounds == 0)
		update_icon()
		return

	//Clear the target list after the delay
	if(world.time > last_alert + SENTRY_ALERT_DELAY)
		alert_list = list()

	if(CHECK_BITFIELD(turret_flags, TURRET_RADIAL)) //Little hint for the xenos.
		playsound(loc, 'sound/items/tick.ogg', 25, FALSE)
	else
		playsound(loc, 'sound/items/detector.ogg', 25, FALSE)

	DISABLE_BITFIELD(turret_flags, TURRET_MANUAL)
	target = get_target()
	if(QDELETED(target))
		return
	process_shot()


/obj/machinery/marine_turret/proc/load_into_chamber()
	if(in_chamber)
		return TRUE //Already set!
	if(!CHECK_BITFIELD(turret_flags, TURRET_ON) || !cell || rounds == 0 || machine_stat & (NOPOWER|BROKEN))
		return FALSE

	create_bullet()
	return TRUE


/obj/machinery/marine_turret/proc/create_bullet()
	in_chamber = new /obj/projectile(src) //New bullet!
	in_chamber.generate_bullet(ammo)


/obj/machinery/marine_turret/proc/process_shot()
	set waitfor = 0

	if(isnull(target)) return //Acquire our victim.

	if(!ammo) return

	if(CHECK_BITFIELD(turret_flags, TURRET_BURSTFIRE) && target && !CHECK_BITFIELD(turret_flags, TURRET_COOLDOWN))
		if(rounds >= burst_size)
			ENABLE_BITFIELD(turret_flags, TURRET_BURSTFIRING)
			for(var/i = 1 to burst_size)
				if(fire_shot())
					sleep(1)
				else
					break
			spawn(0)
				ENABLE_BITFIELD(turret_flags, TURRET_COOLDOWN)
			spawn(fire_delay)
				DISABLE_BITFIELD(turret_flags, TURRET_COOLDOWN)
		else
			DISABLE_BITFIELD(turret_flags, TURRET_BURSTFIRE)
		DISABLE_BITFIELD(turret_flags, TURRET_BURSTFIRING)

	if(!CHECK_BITFIELD(turret_flags, TURRET_BURSTFIRE) && target && !CHECK_BITFIELD(turret_flags, TURRET_COOLDOWN))
		fire_shot()

	target = null

/obj/machinery/marine_turret/proc/fire_shot()
	if(!target || !CHECK_BITFIELD(turret_flags, TURRET_ON) || !ammo || CHECK_BITFIELD(turret_flags, TURRET_COOLDOWN))
		return

	if(!CHECK_BITFIELD(turret_flags, TURRET_BURSTFIRING))
		ENABLE_BITFIELD(turret_flags, TURRET_COOLDOWN)
		spawn(fire_delay)
			DISABLE_BITFIELD(turret_flags, TURRET_COOLDOWN)

	var/turf/my_loc = get_turf(src)
	var/turf/targloc = get_turf(target)

	if(!istype(my_loc) || !istype(target))
		return

	if(!check_power(2))
		return

	var/target_dir = get_dir(src, targloc)
	if( ( target_dir & turn(dir, 180) ) && !CHECK_BITFIELD(turret_flags, TURRET_RADIAL))
		return

	if(CHECK_BITFIELD(turret_flags, TURRET_RADIAL) && !CHECK_BITFIELD(turret_flags, TURRET_MANUAL))
		setDir(target_dir)


	if(!load_into_chamber())
		return

	var/obj/projectile/proj_to_fire = in_chamber
	in_chamber = null //Projectiles live and die fast. It's better to null the reference early so the GC can handle it immediately.

	if (CHECK_BITFIELD(turret_flags, TURRET_BURSTFIRE))
		//Apply scatter
		var/scatter_chance = proj_to_fire.ammo.scatter
		var/burst_value = clamp(burst_size - 1, 1, 5)
		scatter_chance += (burst_value * burst_value * 2)
		proj_to_fire.accuracy = round(proj_to_fire.accuracy - (burst_value * burst_value * 1.2), 0.01) //Accuracy penalty scales with burst count.

		if (prob(scatter_chance))
			var/scatter_x = rand(-1, 1)
			var/scatter_y = rand(-1, 1)
			var/turf/new_target = locate(targloc.x + round(scatter_x), targloc.y + round(scatter_y), targloc.z) //Locate an adjacent turf.
			if(new_target) //Looks like we found a turf.
				target = new_target

	else //gains +50% accuracy, damage, and penetration on singlefire, and no spread.
		proj_to_fire.accuracy = round(proj_to_fire.accuracy * 1.5, 0.01)
		proj_to_fire.damage = round(proj_to_fire.damage * 1.5, 0.01)
		proj_to_fire.ammo.penetration = round(proj_to_fire.ammo.penetration * 1.5, 0.01)

	//Setup projectile
	proj_to_fire.original_target = target
	proj_to_fire.setDir(dir)
	proj_to_fire.def_zone = pick("chest", "chest", "chest", "head")
	proj_to_fire.iff_signal = iff_signal

	//Shoot at the thing
	playsound(loc, 'sound/weapons/guns/fire/smg_heavy.ogg', 75, TRUE)

	proj_to_fire.fire_at(target, src, null, ammo.max_range, ammo.shell_speed)
	if(target)
		var/angle = round(Get_Angle(src, target))
		muzzle_flash(angle)
	rounds--
	if(rounds == 0)
		visible_message("<span class='warning'>The [name] beeps steadily and its ammo light blinks red.</span>")
		playsound(loc, 'sound/weapons/guns/misc/empty_alarm.ogg', 50, FALSE)
		if(CHECK_BITFIELD(turret_flags, TURRET_ALERTS))
			sentry_alert(SENTRY_ALERT_AMMO)

	hud_set_sentry_ammo()
	return TRUE

/obj/machinery/marine_turret/proc/muzzle_flash(angle)
	if(isnull(angle)) return

	var/prev_light = light_power
	if(light_power <= muzzle_flash_lum)
		set_light_range(muzzle_flash_lum)
		set_light_color(COLOR_VERY_SOFT_YELLOW)
		addtimer(CALLBACK(src, .proc/reset_light_range, prev_light), 1 SECONDS)

	if(prob(65))
		var/layer = MOB_LAYER - 0.1

		var/image/I = image('icons/obj/items/projectiles.dmi',src,"muzzle_flash",layer)
		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(0, 5)
		rotate.Turn(angle)
		I.transform = rotate
		flick_overlay_view(I, src, 3)

/obj/machinery/marine_turret/proc/reset_light_range(lightrange)
	set_light_range(initial(light_power))
	set_light_color(initial(light_color))
	if(CHECK_BITFIELD(turret_flags, TURRET_ON))
		set_light(SENTRY_LIGHT_POWER)

/obj/machinery/marine_turret/proc/get_target()
	var/list/targets = list()

	var/list/turf/path = list()
	var/turf/T
	var/mob/living/M

	for(M in oview(range, src))
		if(M.stat == DEAD) //No dead, robots, or incorporeal.
			continue
		if(CHECK_BITFIELD(turret_flags, TURRET_SAFETY) && !isxeno(M)) //When safeties are on, Xenos only.
			continue

		var/mob/living/carbon/human/H = M
		if(istype(H) && H.wear_id.iff_signal & iff_signal)
			continue

		var/angle = get_dir(src, M)
		if(angle & dir || CHECK_BITFIELD(turret_flags, TURRET_RADIAL))
			path = getline(src, M)
			path -= get_turf(src)
			if(CHECK_BITFIELD(turret_flags, TURRET_ALERTS)) //They're within our field of detection and thus can trigger the alarm
				if(world.time > (last_alert + SENTRY_ALERT_DELAY) || !(M in alert_list)) //if we're not on cooldown or the target isn't in the list, sound the alarm
					sentry_alert(SENTRY_ALERT_HOSTILE, M)
					alert_list.Add(M)
					last_alert = world.time
		else
			continue

		if(path.len)
			var/blocked = FALSE
			for(T in path)
				if(IS_OPAQUE_TURF(T) || T.density && T.throwpass == FALSE)
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.

				for(var/obj/machinery/MA in T)
					if(MA.opacity || MA.density && MA.throwpass == FALSE)
						blocked = TRUE
						break //LoF Broken; stop checking; we can't proceed further.

				for(var/obj/structure/S in T)
					if(S.opacity || S.density && S.throwpass == FALSE )
						blocked = TRUE
						break //LoF Broken; stop checking; we can't proceed further.
			if(!blocked && !(M.status_flags & INCORPOREAL)) //Don't target incorporeals; we can't actually shoot them
				targets += M

	if(targets.len) . = pick(targets)


/obj/machinery/marine_turret/premade
	name = "UA-577 Gauss Turret"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an armor penetrating MIC Gauss Cannon and a high-capacity drum magazine."
	ammo = /datum/ammo/bullet/turret/gauss //This is a gauss cannon; it will be significantly deadlier
	turret_flags = TURRET_HAS_CAMERA|TURRET_ON|TURRET_BURSTFIRE|TURRET_IMMOBILE|TURRET_SAFETY
	rounds_max = 50000
	icon_state = "sentry_base"
	initial_cell_type = /obj/item/cell/super
	iff_signal = TGMC_LOYALIST_IFF

/obj/machinery/marine_turret/premade/Initialize()
	. = ..()
	rounds = 50000

/obj/machinery/marine_turret/premade/dumb
	name = "\improper Modified UA 571-C sentry gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an M30 Autocannon and a 500-round drum magazine. This one's IFF system has been disabled, and it will open fire on any targets within range."
	iff_signal = NONE
	ammo = /datum/ammo/bullet/turret/dumb
	magazine_type = /obj/item/ammo_magazine/sentry/premade/dumb
	rounds_max = 500
	turret_flags = TURRET_ON|TURRET_BURSTFIRE|TURRET_IMMOBILE|TURRET_SAFETY

/obj/machinery/marine_turret/premade/dumb/Initialize()
	. = ..()
	rounds = 500

/obj/machinery/marine_turret/premade/dumb/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!cell || cell.charge <= 0)
		to_chat(user, "<span class='warning'>You try to activate [src] but nothing happens. The cell must be empty.</span>")
		return

	if(!anchored)
		to_chat(user, "<span class='warning'>It must be anchored to the ground before you can activate it.</span>")
		return

	if(!CHECK_BITFIELD(turret_flags, TURRET_ON))
		to_chat(user, "You turn on the [src].")
		visible_message("<span class='notice'> [src] hums to life and emits several beeps.</span>")
		visible_message("[src] buzzes in a monotone: 'Default systems initiated.'")
		target = null
		ENABLE_BITFIELD(turret_flags, TURRET_ON)
		set_light(SENTRY_LIGHT_POWER)
		update_icon()
	else
		user.visible_message("<span class='notice'>[user] deactivates [src].</span>",
		"<span class='notice'>You deactivate [src].</span>")
		turn_off()

/obj/machinery/marine_turret/premade/dumb/hostile
	name = "malfunctioning UA 571-C sentry gun"
	desc = "Oh god oh fuck."
	turret_flags = TURRET_LOCKED|TURRET_ON|TURRET_BURSTFIRE|TURRET_IMMOBILE
	iff_signal = SON_OF_MARS_IFF

/obj/machinery/marine_turret/premade/dumb/hostile/attack_hand(mob/living/user)
	to_chat(user,"<span class='warning'>\The [src.name] refuses to cooperate!</span>")
	return FALSE

/obj/item/ammo_magazine/sentry/premade/dumb
	name = "M30 box magazine (10x28mm Caseless)"
	desc = "A box of 500 10x28mm caseless rounds for the UA 571-C Sentry Gun. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "ammo_can"
	flags_magazine = NONE //can't be refilled or emptied by hand
	caliber = CALIBER_10X28
	max_rounds = 500
	default_ammo = /datum/ammo/bullet/turret/dumb
	gun_type = null

//the turret inside the sentry deployment system
/obj/machinery/marine_turret/premade/dropship
	name = "UA-577 Gauss Dropship Turret"
	density = FALSE
	turret_flags = TURRET_HAS_CAMERA|TURRET_BURSTFIRE|TURRET_IMMOBILE
	burst_size = 10
	burst_delay = 15
	var/obj/structure/dropship_equipment/sentry_holder/deployment_system
	magazine_type = /obj/item/ammo_magazine/sentry/premade/dropship

/obj/machinery/marine_turret/premade/dropship/Destroy()
	if(deployment_system)
		deployment_system.deployed_turret = null
		deployment_system = null
	. = ..()

/obj/machinery/marine_turret/premade/canterbury
	name = "UA-577 Gauss Dropship Turret"
	burst_size = 6
	burst_delay = 15
	ammo = /datum/ammo/bullet/turret

/obj/machinery/marine_turret/premade/canterbury/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	if(SSmapping.level_has_any_trait(z, list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND)))
		ENABLE_BITFIELD(turret_flags, TURRET_ON)
		update_icon()

/obj/item/ammo_magazine/sentry/premade/dropship
	name = "UA-577 box magazine (12x40mm Gauss Slugs)"
	desc = "A box of 50000 12x40mm gauss slugs for the UA-577 Gauss Turret. Just feed it into the turret's ammo port when its ammo is depleted."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "ammo_can"
	flags_magazine = NONE //can't be refilled or emptied by hand
	caliber = CALIBER_12X40
	default_ammo = /datum/ammo/bullet/turret/gauss
	gun_type = null
	max_rounds = 50000

/obj/machinery/marine_turret/proc/sentry_alert(alert_code, mob/M)
	if(!alert_code)
		return
	var/notice
	switch(alert_code)
		if(SENTRY_ALERT_AMMO)
			notice = "<b>ALERT! [src]'s ammo depleted at: [AREACOORD_NO_Z(src)].</b>"
		if(SENTRY_ALERT_HOSTILE)
			notice = "<b>ALERT! [src] detected Hostile/Unknown: [M.name] at: [AREACOORD_NO_Z(src)].</b>"
		if(SENTRY_ALERT_FALLEN)
			notice = "<b>ALERT! [src] has been knocked over at: [AREACOORD_NO_Z(src)].</b>"
		if(SENTRY_ALERT_DAMAGE)
			notice = "<b>ALERT! [src] has taken damage at: [AREACOORD_NO_Z(src)]. Remaining Structural Integrity: ([obj_integrity]/[max_integrity])[obj_integrity < 50 ? " CONDITION CRITICAL!!" : ""]</b>"
		if(SENTRY_ALERT_DESTROYED)
			notice = "<b>ALERT! [src] at: [AREACOORD_NO_Z(src)] has been destroyed!</b>"
		if(SENTRY_ALERT_BATTERY)
			notice = "<b>ALERT! [src]'s battery depleted at: [AREACOORD_NO_Z(src)].</b>"

	playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
	radio.talk_into(src, "[notice]", FREQ_COMMON)

/obj/machinery/marine_turret/mini
	name = "\improper UA-580 point defense sentry"
	desc = "A deployable, automated turret with AI targeting capabilities. This is a lightweight portable model meant for rapid deployment and point defense. Armed with an light, high velocity machine gun and a 500-round drum magazine."
	icon = 'icons/Marine/miniturret.dmi'
	icon_state = "minisentry_on"
	anchored = FALSE
	turret_flags = TURRET_HAS_CAMERA|TURRET_BURSTFIRE|TURRET_SAFETY
	burst_size = 3
	min_burst = 2
	max_burst = 5
	obj_integrity = 100
	max_integrity = 100
	rounds = 500
	rounds_max = 500
	knockdown_threshold = 100 //lighter, not as well secured.
	work_time = 10 //significantly faster than the big sentry
	ammo = /datum/ammo/bullet/turret/mini //Similar to M25 AP rounds.
	magazine_type = /obj/item/ammo_magazine/minisentry
	initial_cell_type = null

/obj/item/storage/box/sentry/Initialize(mapload, ...)
	. = ..()
	update_icon()

/obj/machinery/marine_turret/mini/MouseDrop(over_object, src_location, over_location) //Drag the tripod onto you to fold it.
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr //this is us
	if(!over_object == user || !in_range(src, user))
		return

	if(anchored)
		to_chat(user, "<span class='warning'>The [src] disengages its anchor bolts as you initiate the retrieval process.</span>")
		anchored = FALSE
		update_icon()

	if(CHECK_BITFIELD(turret_flags, TURRET_ON))
		to_chat(user, "<span class='warning'>You depower [src] to facilitate its retrieval.</span>")
		turn_off()

	user.visible_message("<span class='notice'>[user] begins to fold up and retrieve [src].</span>",
	"<span class='notice'>You begin to fold up and retrieve [src].</span>")
	if(!do_after(user, work_time * 3, TRUE, src, BUSY_ICON_BUILD) || CHECK_BITFIELD(turret_flags, TURRET_ON) || anchored)
		return
	to_chat(user, "<span class='notice'>You fold up and retrieve [src].</span>")
	var/obj/item/marine_turret/mini/P = new(user.loc)
	user.put_in_hands(P)
	P.obj_integrity = obj_integrity
	P.rounds = rounds
	if(cell)
		cell.forceMove(P)
		P.cell = cell

	cell = null
	qdel(src)

/obj/machinery/marine_turret/mini/update_icon()
	if(machine_stat && obj_integrity > 0) //Knocked over
		density = FALSE
		icon_state = "minisentry_fallen"
		return
	else
		icon_state = "minisentry_off"
		density = initial(density)

	if(!cell)
		icon_state = "minisentry_nobat"
		return

	if(cell.charge <= 0)
		icon_state = "minisentry_nobat"
		return

	if(CHECK_BITFIELD(turret_flags, TURRET_ON))
		start_processing()
		if(!rounds)
			icon_state = "minisentry_noammo"
		else
			icon_state = "minisentry_on[CHECK_BITFIELD(turret_flags, TURRET_RADIAL) ? "_radial" : null]"

	else
		icon_state = "minisentry_off"


/obj/item/marine_turret/mini
	name = "\improper UA-580 point defense sentry (folded)"
	desc = "A deployable, automated turret with AI targeting capabilities. This is a lightweight portable model meant for rapid deployment and point defense. Armed with an light, high velocity machine gun and a 500-round drum magazine. It is currently folded up."
	icon = 'icons/Marine/miniturret.dmi'
	icon_state = "minisentry_packed"
	item_state = "minisentry_packed"
	w_class = WEIGHT_CLASS_BULKY
	max_integrity = 100
	var/rounds = 500
	var/obj/item/cell/cell
	flags_equip_slot = ITEM_SLOT_BACK

/obj/item/marine_turret/mini/attack_self(mob/user) //click the sentry to deploy it.
	if(!ishuman(usr))
		return
	var/turf/target = get_step(user.loc,user.dir)
	if(!target)
		return

	if(check_blocked_turf(target)) //check if blocked
		to_chat(user, "<span class='warning'>There is insufficient room to deploy [src]!</span>")
		return
	if(do_after(user, 30, TRUE, src, BUSY_ICON_BUILD))
		var/obj/machinery/marine_turret/mini/M = new /obj/machinery/marine_turret/mini(target)
		M.setDir(user.dir)
		user.visible_message("<span class='notice'>[user] deploys [M].</span>",
		"<span class='notice'>You deploy [M]. The [M]'s securing bolts automatically anchor it to the ground.</span>")
		playsound(target, 'sound/weapons/mine_armed.ogg', 25)
		M.obj_integrity = obj_integrity
		M.anchored = TRUE
		M.rounds = rounds
		if(cell) //Inherit the power cell of the source item if any
			cell.forceMove(M)
			M.cell = cell

		cell = null
		M.activate_turret()
		qdel(src)

/obj/item/ammo_magazine/minisentry
	name = "\improper M30 box magazine (10x20mm Caseless)"
	desc = "A box of 500 10x20mm caseless rounds for the UA-580 point defense sentry. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "ua580"
	flags_magazine = NONE //can't be refilled or emptied by hand
	caliber = CALIBER_10X20
	max_rounds = 500
	default_ammo = /datum/ammo/bullet/turret/mini
	gun_type = null

/obj/item/storage/box/minisentry
	name = "\improper UA-580 point defense sentry crate"
	desc = "A large case containing all you need to set up an UA-580 point defense sentry."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 4
	can_hold = list(
		/obj/item/marine_turret/mini, //gun itself
		/obj/item/tool/wrench, //wrench to hold it down into the ground
		/obj/item/tool/screwdriver, //screw the gun onto the post.
		/obj/item/ammo_magazine/minisentry)

/obj/item/storage/box/minisentry/Initialize(mapload, ...)
	. = ..()
	var/obj/item/marine_turret/mini/sentry = new /obj/item/marine_turret/mini(src) //gun itself
	new /obj/item/tool/wrench(src) //wrench to hold it down into the ground
	new /obj/item/tool/screwdriver(src) //screw the gun onto the post.
	new /obj/item/ammo_magazine/minisentry(src)
	var/obj/item/cell/new_cell = new /obj/item/cell/high(sentry) //give it the cell here
	sentry.cell = new_cell

/obj/machinery/marine_turret/proc/activate_turret()
	if(!anchored)
		return FALSE
	if(!cell)
		return FALSE
	if(!cell.charge)
		return FALSE
	target = null
	ENABLE_BITFIELD(turret_flags, TURRET_ON)
	set_light(SENTRY_LIGHT_POWER)
	if(!camera && CHECK_BITFIELD(turret_flags, TURRET_HAS_CAMERA))
		camera = new /obj/machinery/camera(src)
		camera.network = list("military")
		camera.c_tag = src.name
	update_icon()
	return TRUE

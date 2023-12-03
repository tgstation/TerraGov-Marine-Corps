
//TANKS, HURRAY
//Read the documentation in cm_armored.dm and multitile.dm before trying to decipher this stuff


/obj/vehicle/multitile/root/cm_armored/tank
	name = "\improper M34A2 Longstreet Light Tank"
	desc = "A giant piece of armor with a big gun, you know what to do. Entrance in the back."

	icon = 'icons/obj/vehicles/tank_NS.dmi'
	icon_state = "tank_base"
	pixel_x = -32
	pixel_y = -32

	var/mob/gunner
	var/mob/driver

	var/mob/occupant_exiting
	var/next_sound_play = 0

	var/is_zoomed = FALSE

	req_access = list()

/obj/effect/multitile_spawner/cm_armored/tank

	width = 3
	height = 3
	spawn_dir = EAST
	var/list/spawn_hardpoints = list()

/obj/effect/multitile_spawner/cm_armored/tank/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_QDEL

//Spawns a tank that has a bunch of broken hardpoints
/obj/effect/multitile_spawner/cm_armored/tank/decrepit
	spawn_hardpoints = list(HDPT_PRIMARY = /obj/item/hardpoint/primary/cannon/broken,
							HDPT_SECDGUN = /obj/item/hardpoint/secondary/m56cupola/broken,
							HDPT_SUPPORT = /obj/item/hardpoint/support/smoke_launcher/broken,
							HDPT_ARMOR = /obj/item/hardpoint/armor/ballistic/broken,
							HDPT_TREADS = /obj/item/hardpoint/treads/standard/broken)

/obj/effect/multitile_spawner/cm_armored/tank/fixed
	spawn_hardpoints = list(HDPT_PRIMARY = /obj/item/hardpoint/primary/cannon,
							HDPT_SECDGUN = /obj/item/hardpoint/secondary/m56cupola,
							HDPT_SUPPORT = /obj/item/hardpoint/support/smoke_launcher,
							HDPT_ARMOR = /obj/item/hardpoint/armor/ballistic,
							HDPT_TREADS = /obj/item/hardpoint/treads/standard)

//For the tank, start forcing people out if everything is broken
/obj/vehicle/multitile/root/cm_armored/tank/handle_all_modules_broken()
	deactivate_all_hardpoints()

	if(driver)
		to_chat(driver, span_danger("You dismount to as the smoke and flames start to choke you!"))
		driver.Move(entrance.loc)
		driver.unset_interaction()
		driver = null
	else if(gunner)
		to_chat(gunner, span_danger("You dismount to as the smoke and flames start to choke you!"))
		gunner.Move(entrance.loc)
		gunner.unset_interaction()
		gunner = null

/obj/vehicle/multitile/root/cm_armored/tank/remove_all_players()
	deactivate_all_hardpoints()
	for(var/mob/living/L in (contents + loc.contents))
		if(!entrance) //Something broke, uh oh
			forceMove(get_turf(src))
		else
			forceMove(get_turf(entrance))
	gunner = null
	driver = null

//Let's you switch into the other seat, doesn't work if it's occupied
/obj/vehicle/multitile/root/cm_armored/tank/verb/switch_seats()
	set name = "Swap Seats"
	set category = "Vehicle"
	set src in view(0)

	if(usr.incapacitated())
		return

	var/wannabe_trucker = (usr == gunner) ? TRUE : FALSE
	var/neighbour = wannabe_trucker ? driver : gunner
	if(neighbour)
		to_chat(usr, span_notice("There's already someone in the other seat."))
		return

	to_chat(usr, span_notice("You start getting into the other seat."))
	addtimer(CALLBACK(src, PROC_REF(seat_switched), wannabe_trucker, usr), 3 SECONDS)

/obj/vehicle/multitile/root/cm_armored/tank/proc/seat_switched(wannabe_trucker, mob/living/user)

	var/player = wannabe_trucker ? gunner : driver
	var/challenger = wannabe_trucker ? driver : gunner
	if(QDELETED(user) || user.incapacitated() || player != user)
		return

	if(challenger)
		to_chat(usr, span_notice("Someone beat you to the other seat!"))
		return

	to_chat(usr, span_notice("You man up the [wannabe_trucker ? "driver" : "gunner"]'s seat."))

	if(wannabe_trucker)
		deactivate_all_hardpoints()
	driver = wannabe_trucker ? user : null
	gunner = wannabe_trucker ? null : user

/obj/vehicle/multitile/root/cm_armored/tank/can_use_hp(mob/M)
	if(!M || M != gunner)
		return FALSE
	if(!M.dextrous)
		to_chat(M, span_warning("You don't have the dexterity to do this!"))
		return FALSE
	return !M.incapacitated()

/obj/vehicle/multitile/root/cm_armored/tank/handle_harm_attack(mob/M, mob/occupant)
	. = ..()
	if(!.)
		return
	if(!occupant)
		to_chat(M, span_warning("There is no one on that seat."))
		return
	M.visible_message(span_warning("[M] starts pulling [occupant] out of \the [src]."),
	span_warning("You start pulling [occupant] out of \the [src]. (this will take a while...)"), null, 6)
	var/fumbling_time = 20 SECONDS - 2 SECONDS * M.skills.getRating(SKILL_POLICE) - 2 SECONDS * M.skills.getRating(SKILL_LARGE_VEHICLE)
	if(!do_after(M, fumbling_time, NONE, src, BUSY_ICON_HOSTILE))
		return
	exit_tank(occupant, TRUE, TRUE)
	M.visible_message(span_warning("[M] forcibly pulls [occupant] out of [src]."),
					span_notice("you forcibly pull [occupant] out of [src]."), null, 6)
	if(!isliving(occupant))
		return
	var/mob/living/L = occupant
	L.Paralyze(8 SECONDS)

//Two seats, gunner and driver
//Must have the skills to do so
/obj/vehicle/multitile/root/cm_armored/tank/handle_player_entrance(mob/living/carbon/M)
	. = ..()
	if(!. || !istype(M) || M.do_actions)
		return

	var/slot = tgui_alert(M, "Select a seat", null, list("Driver", "Gunner"))
	if(!Adjacent(M))
		return

	var/occupant = (slot == "Driver") ? driver : gunner
	if((M.a_intent == INTENT_HARM || isxeno(M)) && occupant)
		handle_harm_attack(M, occupant)
		return

	if(!M.dextrous)
		to_chat(M, span_warning("You don't have the dexterity to drive [src]!"))
		return
	if(!allowed(M))
		to_chat(M, span_warning("Access denied."))
		return
	if(occupant)
		to_chat(M, span_warning("That seat is already taken."))
		return
	var/obj/item/offhand = M.get_inactive_held_item()
	if(offhand && !(HAS_TRAIT(offhand, TRAIT_NODROP) || (offhand.flags_item & (DELONDROP|ITEM_ABSTRACT))))
		to_chat(M, span_warning("You need your hands free to climb on [src]."))
		return

	if(M.skills.getRating(SKILL_LARGE_VEHICLE) < SKILL_LARGE_VEHICLE_TRAINED)
		M.visible_message(span_notice("[M] fumbles around figuring out how to get into the [src]."),
		span_notice("You fumble around figuring out how to get into [src]."))
		var/fumbling_time = 10 SECONDS - 2 SECONDS * M.skills.getRating(SKILL_LARGE_VEHICLE)
		if(!do_after(M, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED) || \
			(offhand && !(HAS_TRAIT(offhand, TRAIT_NODROP) || (offhand.flags_item & DELONDROP))))
			return

	to_chat(M, span_notice("You start climbing into [src]."))
	if(!do_after(M, 10 SECONDS, NONE, src, BUSY_ICON_GENERIC) || \
		(offhand && !(HAS_TRAIT(offhand, TRAIT_NODROP) || (offhand.flags_item & DELONDROP))))
		return
	if(occupant)
		to_chat(M, span_warning("Someone got into the [lowertext(slot)]'s seat before you could."))
		return

	if(slot == "Driver")
		driver = M
	else
		gunner = M
	M.forceMove(src)
	to_chat(M, span_notice("You enter into the [lowertext(slot)]'s seat."))
	M.set_interaction(src)

//Deposits you onto the exit marker
/obj/vehicle/multitile/root/cm_armored/tank/handle_player_exit(mob/M)

	if(!(M in list(gunner, driver))) //someone whom isn't supposed to be here to begin with.
		exit_tank(M, TRUE)
		return

	if(!M.do_actions)
		if(occupant_exiting)
			to_chat(M, span_notice("Someone is already getting out of [src]."))
			return
		occupant_exiting = M

	to_chat(M, span_notice("You start climbing out of [src]."))

	addtimer(CALLBACK(src, PROC_REF(exit_tank), M), 5 SECONDS)

/obj/vehicle/multitile/root/cm_armored/tank/proc/exit_tank(mob/M, forced = FALSE, silent = FALSE)
	if(!forced)
		occupant_exiting = null

	if(!M || get_turf(M) != get_turf(src) || (M.incapacitated() && !forced))
		return

	var/turf/T = get_turf(entrance)
	if(!forced)
		if(!T.CanPass(M, T))
			if(!silent)
				to_chat(M, span_notice("Something is blocking you from exiting."))
			return
		for(var/atom/A in T)
			if(A.CanPass(M, T))
				continue
			if(!silent)
				to_chat(M, span_notice("Something is blocking you from exiting."))
			return
	M.forceMove(T)

	if(M == gunner)
		deactivate_all_hardpoints()
		gunner = null
	else if(M == driver)
		driver = null
	M.unset_interaction()
	if(!silent)
		to_chat(M, span_notice("You climb out of [src]."))

//No one but the driver can drive
/obj/vehicle/multitile/root/cm_armored/tank/relaymove(mob/user, direction)
	if(user != driver || user.incapacitated())
		return

	. = ..(user, direction)



	if(next_sound_play < world.time)
		playsound(src, 'sound/ambience/tank_driving.ogg', vol = 20, sound_range = 30)
		next_sound_play = world.time + 21

//No one but the driver can turn
/obj/vehicle/multitile/root/cm_armored/tank/try_rotate(deg, mob/user, force = FALSE)

	if(user != driver || user.incapacitated())
		return

	. = ..(deg, user, force)

	if(. && istype(hardpoints[HDPT_SUPPORT], /obj/item/hardpoint/support/artillery_module) && gunner?.client)
		var/client/C = gunner.client
		var/old_x = C.pixel_x
		var/old_y = C.pixel_y
		C.pixel_x = old_x*cos(deg) - old_y*sin(deg)
		C.pixel_y = old_x*sin(deg) + old_y*cos(deg)

/obj/vehicle/multitile/hitbox/cm_armored/tank/get_driver()
	var/obj/vehicle/multitile/root/cm_armored/tank/T = root
	return T?.driver


/obj/vehicle/multitile/root/cm_armored/tank/take_damage_type(damage, type, atom/attacker)
	. = ..()

	if(istype(attacker, /mob))
		var/mob/M = attacker
		log_combat(M, src, "damaged [src] with [damage] [type] damage.")

	if(gunner)
		log_combat(gunner, null, "[src] took [damage] [type] damage [ismob(attacker) ? "from [key_name(attacker)]" : ""].")
	if(driver)
		log_combat(driver, null, "[src] took [damage] [type] damage [ismob(attacker) ? "from [key_name(attacker)]" : ""].")


/obj/vehicle/multitile/root/cm_armored/proc/click_action(A, mob/user, params)
	if(istype(A, /atom/movable/screen) || A == src)
		return FALSE

	if(!can_use_hp(user))
		return TRUE

	if(!hardpoints.Find(active_hp))
		to_chat(user, span_warning("Please select an active hardpoint first."))
		return TRUE

	var/obj/item/hardpoint/HP = hardpoints[active_hp]

	if(!HP?.is_ready())
		return TRUE

	if(!HP.firing_arc(A))
		to_chat(user, span_warning("The target is not within your firing arc."))
		return TRUE

	HP.active_effect(A)
	return TRUE

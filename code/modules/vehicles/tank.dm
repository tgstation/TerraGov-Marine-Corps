


//TANKS, HURRAY
//Read the documentation in cm_armored.dm and multitile.dm before trying to decipher this stuff


/obj/vehicle/multitile/root/cm_armored/tank
	name = "\improper M34A2 Longstreet Light Tank"
	desc = "A giant piece of armor with a big gun, you know what to do. Entrance in the back."

	icon = 'icons/obj/tank_NS.dmi'
	icon_state = "tank_base"
	pixel_x = -32
	pixel_y = -32

	var/mob/gunner
	var/mob/driver

	var/occupant_exiting = null
	var/next_sound_play = 0

	var/is_zoomed = FALSE

	luminosity = 7

	req_access = list(ACCESS_MARINE_TANK)

/obj/effect/multitile_spawner/cm_armored/tank

	width = 3
	height = 3
	spawn_dir = EAST
	var/list/spawn_hardpoints = list()

/obj/effect/multitile_spawner/cm_armored/tank/New()

	var/obj/vehicle/multitile/root/cm_armored/tank/R = new(src.loc)
	R.setDir(EAST)

	var/datum/coords/dimensions = new
	dimensions.x_pos = width
	dimensions.y_pos = height
	var/datum/coords/root_pos = new
	root_pos.x_pos = 1
	root_pos.y_pos = 1

	//Entrance relative to the root object. The tank spawns with the root centered on the marker
	var/datum/coords/entr_mark = new
	entr_mark.x_pos = -2
	entr_mark.y_pos = 0

	R.load_hitboxes(dimensions, root_pos)
	R.load_entrance_marker(entr_mark)

	var/hardpoint_path
	for(var/slot in spawn_hardpoints)
		hardpoint_path = spawn_hardpoints[slot]
		R.add_hardpoint(new hardpoint_path)
	R.healthcheck()

	qdel(src)

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
		to_chat(driver, "<span class='danger'>You dismount to as the smoke and flames start to choke you!</span>")
		driver.Move(entrance.loc)
		driver.unset_interaction()
		driver = null
	else if(gunner)
		to_chat(gunner, "<span class='danger'>You dismount to as the smoke and flames start to choke you!</span>")
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
		to_chat(usr, "<span class='notice'>There's already someone in the other seat.</span>")
		return

	to_chat(usr, "<span class='notice'>You start getting into the other seat.</span>")
	addtimer(CALLBACK(src, .proc/seat_switched, wannabe_trucker, usr), 3 SECONDS)

/obj/vehicle/multitile/root/cm_armored/tank/proc/seat_switched(wannabe_trucker, mob/living/user)

	var/player = wannabe_trucker ? gunner : driver
	var/challenger = wannabe_trucker ? driver : gunner
	if(QDELETED(user) || user.incapacitated() || player != user)
		return

	if(challenger)
		to_chat(usr, "<span class='notice'>Someone beat you to the other seat!</span>")
		return

	to_chat(usr, "<span class='notice'>You man up the [wannabe_trucker ? "driver" : "gunner"]'s seat.</span>")

	if(wannabe_trucker)
		deactivate_all_hardpoints()
	driver = wannabe_trucker ? user : null
	gunner = wannabe_trucker ? null : user

/obj/vehicle/multitile/root/cm_armored/tank/can_use_hp(mob/M)
	if(!M || M != gunner)
		return FALSE
	if(!M.IsAdvancedToolUser())
		to_chat(M, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	return !M.incapacitated()

/obj/vehicle/multitile/root/cm_armored/tank/handle_harm_attack(mob/M, mob/occupant)
	. = ..()
	if(!.)
		return
	if(!occupant)
		to_chat(M, "<span class='warning'>There is no one on that seat.</span>")
		return
	var/turf/hatch = get_step_towards(entrance.loc, src)
	M.visible_message("<span class='warning'>[M] starts pulling [occupant] out of \the [src].</span>",
	"<span class='warning'>You start pulling [occupant] out of \the [src]. (this will take a while...)</span>", null, 6)
	var/fumbling_time = 20 SECONDS
	if(M.mind?.cm_skills?.police)
		fumbling_time -= 2 SECONDS * M.mind.cm_skills.police
	if(M.mind?.cm_skills?.large_vehicle)
		fumbling_time -= 2 SECONDS * M.mind.cm_skills.large_vehicle
	if(!do_after(M, fumbling_time, TRUE, 5, BUSY_ICON_HOSTILE) || !M.Adjacent(hatch))
		return
	exit_tank(occupant, TRUE, TRUE)
	M.visible_message("<span class='warning'>[M] forcibly pulls [occupant] out of [src].</span>",
					"<span class='notice'>you forcibly pull [occupant] out of [src].</span>", null, 6)
	occupant.KnockDown(4)

//Two seats, gunner and driver
//Must have the skills to do so
/obj/vehicle/multitile/root/cm_armored/tank/handle_player_entrance(mob/living/carbon/M)
	. = ..()
	if(!. || !istype(M) || M.action_busy)
		return

	var/slot = input("Select a seat") in list("Driver", "Gunner")
	var/turf/hatch = get_step_towards(entrance.loc, src)
	if(!M.Adjacent(hatch))
		return

	var/occupant = (slot == "Driver") ? driver : gunner
	if((M.a_intent == INTENT_HARM || isxeno(M)) && occupant)
		handle_harm_attack(M, occupant)
		return

	if(!M.IsAdvancedToolUser())
		to_chat(M, "<span class='warning'>You don't have the dexterity to drive [src]!</span>")
		return
	if(!allowed(M))
		to_chat(M, "<span class='warning'>Access denied.</span>")
		return
	if(occupant)
		to_chat(M, "<span class='warning'>That seat is already taken.</span>")
		return
	var/obj/item/offhand = M.get_inactive_held_item()
	if(offhand && !(offhand.flags_item & (NODROP|DELONDROP)))
		to_chat(M, "<span class='warning'>You need your hands free to climb on [src].</span>")
		return

	if(!M.mind || !(!M.mind.cm_skills || M.mind.cm_skills.large_vehicle >= SKILL_LARGE_VEHICLE_TRAINED))
		M.visible_message("<span class='notice'>[M] fumbles around figuring out how to get into the [src].</span>",
		"<span class='notice'>You fumble around figuring out how to get into [src].</span>")
		var/fumbling_time = 10 SECONDS - 2 SECONDS * M.mind.cm_skills.large_vehicle
		if(!do_after(M, fumbling_time, TRUE, 5, BUSY_ICON_BUILD) || !M.Adjacent(hatch) || (offhand && !(offhand.flags_item & (NODROP|DELONDROP))))
			return

	to_chat(M, "<span class='notice'>You start climbing into [src].</span>")
	if(!do_after(M, 10 SECONDS, TRUE, show_busy_icon = TRUE) || !M.Adjacent(hatch) || (offhand && !(offhand.flags_item & (NODROP|DELONDROP))))
		return
	if(occupant)
		to_chat(M, "<span class='warning'>Someone got into the [lowertext(slot)]'s seat before you could.</span>")
		return

	if(slot == "Driver")
		driver = M
	else
		gunner = M
	M.forceMove(src)
	to_chat(M, "<span class='notice'>You enter into the [lowertext(slot)]'s seat.</span>")
	M.set_interaction(src)

//Deposits you onto the exit marker
/obj/vehicle/multitile/root/cm_armored/tank/handle_player_exit(mob/M)

	if(!(M in list(gunner, driver))) //someone whom isn't supposed to be here to begin with.
		exit_tank(M, TRUE)
		return

	if(!M.action_busy)
		if(occupant_exiting)
			to_chat(M, "<span class='notice'>Someone is already getting out of the vehicle.</span>")
			return
		occupant_exiting = M

	to_chat(M, "<span class='notice'>You start climbing out of [src].</span>")

	addtimer(CALLBACK(src, .proc/exit_tank, M), 5 SECONDS)

/obj/vehicle/multitile/root/cm_armored/tank/proc/exit_tank(mob/M, forced = FALSE, silent = FALSE)
	if(!forced)
		occupant_exiting = null

	if(!M || get_turf(M) != get_turf(src) || (M.incapacitated() && !forced))
		return

	if(forced)
		M.forceMove(get_turf(entrance))
	else if(!M.Move(get_turf(entrance)))
		if(!silent)
			to_chat(M, "<span class='notice'>Something is blocking you from exiting.</span>")
		return

	if(M == gunner)
		deactivate_all_hardpoints()
		gunner = null
	else if(M == driver)
		driver = null
	M.unset_interaction()
	if(!silent)
		to_chat(M, "<span class='notice'>You climb out of [src].</span>")

//No one but the driver can drive
/obj/vehicle/multitile/root/cm_armored/tank/relaymove(var/mob/user, var/direction)
	if(user != driver || user.incapacitated())
		return

	. = ..(user, direction)

	//Someone remind me to fix this fucking snow code --MadSnailDisease
	//The check is made here since the snowplow won't fit on the APC
	if(. && istype(hardpoints[HDPT_ARMOR], /obj/item/hardpoint/armor/snowplow) && direction == dir)
		var/obj/item/hardpoint/armor/snowplow/SP = hardpoints[HDPT_ARMOR]
		if(SP.health > 0)
			for(var/datum/coords/C in linked_objs)
				var/turf/T = locate(src.x + C.x_pos, src.y + C.y_pos, src.z + C.z_pos)
				if(!istype(T, /turf/open/snow)) continue
				var/turf/open/snow/ST = T
				if(!ST || !ST.slayer)
					continue
				new /obj/item/stack/snow(ST, ST.slayer)
				ST.slayer = 0
				ST.update_icon(1, 0)

	if(next_sound_play < world.time)
		if(!CONFIG_GET(flag/tank_mouth_noise))
			playsound(src, 'sound/ambience/tank_driving.ogg', vol = 20, sound_range = 30)
		else
			playsound(src, 'sound/ambience/tank_driving_joke.ogg', vol = 20, sound_range = 30)
		next_sound_play = world.time + 21

//No one but the driver can turn
/obj/vehicle/multitile/root/cm_armored/tank/try_rotate(var/deg, var/mob/user, var/force = 0)

	if(user != driver || user.incapacitated())
		return

	. = ..(deg, user, force)

	if(. && istype(hardpoints[HDPT_SUPPORT], /obj/item/hardpoint/support/artillery_module) && gunner && gunner.client)
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
	var/list/mods = params2list(params)
	if(istype(A, /obj/screen) || A == src || mods["middle"] || mods["shift"] || mods["alt"])
		return FALSE

	if(!can_use_hp(user))
		return TRUE

	if(!hardpoints.Find(active_hp))
		to_chat(user, "<span class='warning'>Please select an active hardpoint first.</span>")
		return TRUE

	var/obj/item/hardpoint/HP = hardpoints[active_hp]

	if(!HP?.is_ready())
		return TRUE

	if(!HP.firing_arc(A))
		to_chat(user, "<span class='warning'>The target is not within your firing arc.</span>")
		return TRUE

	HP.active_effect(A)
	return TRUE
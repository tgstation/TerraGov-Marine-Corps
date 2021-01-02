/obj/vehicle/armored/attackby(obj/item/I, mob/user) //This handles reloading weapons, or changing what kind of mags they'll accept
	. = ..()
	if(user.loc == src) //Gotta get out to reload
		to_chat(user, "<span class='warning'>You can't reach [src]'s hardpoints while you're seated in it.</span>")
		return

	if(is_type_in_list(I, primary_weapon?.accepted_ammo))
		var/mob/living/M = user
		var/time = 8 SECONDS - (1 SECONDS * M.skills.getRating("large_vehicle"))
		to_chat(user, "You start to swap out [primary_weapon]'s magazine...")
		if(!do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE
		if(!Adjacent(M))//second check in case the target moves
			return
		playsound(get_turf(src), 'sound/weapons/guns/interact/working_the_bolt.ogg', 100, TRUE)
		primary_weapon.ammo.forceMove(get_turf(user))
		primary_weapon.ammo.update_icon()
		primary_weapon.ammo = I
		to_chat(user, "You load [I] into [primary_weapon] with a satisfying click.")
		user.transferItemToLoc(I,src)
		return TRUE

	if(is_type_in_list(I, secondary_weapon?.accepted_ammo))
		var/mob/living/M = user
		var/time = 8 SECONDS - (1 SECONDS * M.skills.getRating("large_vehicle"))
		to_chat(user, "You start to swap out [secondary_weapon]'s magazine...")
		if(!do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE
		if(!Adjacent(M))
			return
		playsound(get_turf(src), 'sound/weapons/guns/interact/working_the_bolt.ogg', 100, 1)
		secondary_weapon.ammo.forceMove(get_turf(user))
		secondary_weapon.ammo.update_icon()
		secondary_weapon.ammo = I
		to_chat(user, "You load [I] into [secondary_weapon] with a satisfying click.")
		user.transferItemToLoc(I,src)
		return TRUE

	if(istype(I, /obj/item/tank_weapon))
		if(LAZYLEN(operators))
			to_chat(user, "<span class = 'warning'> You cannot attach modules when there are crewmembers inside!</span>")
			return TRUE
		var/obj/item/tank_weapon/W = I
		var/mob/living/M = user
		var/slotchoice = alert("What weapon would you like to attach?.", name, MODULE_PRIMARY, MODULE_SECONDARY, "Cancel")
		if(!slotchoice || slotchoice == "Cancel")
			return TRUE
		var/time = 8 SECONDS - (1 SECONDS * M.skills.getRating("large_vehicle"))
		if(!do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE
		if(!Adjacent(M))
			return
		if((slotchoice == MODULE_SECONDARY) && !istype(W, /obj/item/tank_weapon/secondary_weapon))
			to_chat(user, "<span class='warning'>You can't attach non-secondary weapons to secondary weapon slots!</span>")
			return TRUE
		attach_weapon(W, slotchoice)
		to_chat(user, "You attach [W] to the [src].")
		user.transferItemToLoc(W,src)
		return TRUE

	if(istype(I, /obj/item/tank_module))
		var/obj/item/tank_module/M = I
		if(utility_module)
			to_chat(user, "There's already a utility module attached, remove it with a crowbar first!")
			return TRUE
		utility_module = M
		to_chat(user, "You attach [M] to the tank.")
		utility_module.on_equip(src)
		user.transferItemToLoc(M,src)

/obj/vehicle/armored/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.loc == src) //Nice try
		to_chat(user, "<span class='warning'>You can't reach [src]'s hardpoints while youre seated in it.</span>")
		return TRUE
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='warning'>You can't see any visible dents on [src].</span>")
		return TRUE
	var/obj/item/tool/weldingtool/WT = I
	if(!WT.isOn())
		to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
		return TRUE

	user.visible_message("<span class='notice'>[user] starts repairing [src].</span>",
	"<span class='notice'>You start repairing [src].</span>")
	if(!do_after(user, 20 SECONDS, TRUE, src, BUSY_ICON_BUILD, extra_checks = iswelder(I) ? CALLBACK(I, /obj/item/tool/weldingtool/proc/isOn) : null))
		return TRUE
	if(!Adjacent(user))
		return

	WT.remove_fuel(3, user) //3 Welding fuel to repair the tank. To repair a small tank, it'd take 4 goes AKA 12 welder fuel and 1 minute
	obj_integrity += 100
	if(obj_integrity > max_integrity)
		obj_integrity = max_integrity //Prevent overheal

	user.visible_message("<span class='notice'>[user] welds out a few of the dents on [src].</span>",
	"<span class='notice'>You weld out a few of the dents on [src].</span>")
	update_icon() //Check damage overlays

/obj/vehicle/armored/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(LAZYLEN(operators))
		to_chat(user, "<span class = 'warning'> You cannot remove modules when there are crewmembers inside!</span>")
		return TRUE
	var/position = alert("What module would you like to remove?", name, MODULE_PRIMARY, MODULE_SECONDARY, MODULE_UTILITY, "Cancel")
	if(!position || position == "Cancel")
		return TRUE
	var/time = 5 SECONDS - (1 SECONDS * user.skills.getRating("large_vehicle"))
	if(position == MODULE_PRIMARY)
		to_chat(user, "You begin detaching \the [primary_weapon]")
		if(!do_after(user, time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE
		if(!Adjacent(user))
			return
		primary_weapon.forceMove(get_turf(user))
		to_chat(user, "You detach \the [primary_weapon].")
		turret_overlay.cut_overlays()
		primary_weapon = null
		return TRUE
	if(position == MODULE_SECONDARY)
		to_chat(user, "You begin detaching \the [secondary_weapon]")
		if(!do_after(user, time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE
		if(!Adjacent(user))
			return
		secondary_weapon.forceMove(get_turf(user))
		to_chat(user, "You detach \the [secondary_weapon]")
		secondary_weapon_overlay.icon = null
		secondary_weapon_overlay.icon_state = null
		secondary_weapon = null
		return TRUE
	if(position == MODULE_UTILITY)
		to_chat(user, "You begin detaching \the [utility_module]")
		if(!do_after(user, time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE
		if(!Adjacent(user))
			return
		utility_module.forceMove(get_turf(user))
		utility_module.on_unequip(src)
		to_chat(user, "You detach \the [utility_module]")
		utility_module = null
		return TRUE


#define POSITION_DRIVER "Driver"
#define POSITION_GUNNER "Gunner"
#define POSITION_PASSENGER "Passenger"

/*
\\\\\\\\ATTACKHAND STUFF////////
This handles stuff like getting in, pulling people out of the tank, all that stuff.
*/
/obj/vehicle/armored/attack_hand(mob/living/user)
	if(!ishuman(user)) // Aliens can't get in a tank...as hilarious as that would be
		return

	// Exiting the tank
	if(user in operators)
		exit_tank(user)
		return

	// Putting someone inside the tank
	if(user.pulling && ismob(user.pulling)) //If theyre pulling someone and click the tank, load that person into a passenger seat first. This allows for medics to put marines into the tank / apc safely
		if(LAZYLEN(passengers) >= max_passengers) //We have a few slots for people to enter as passengers without gunning / driving.
			to_chat(user, "[user.pulling] won't fit in because [src] is already full!")
			return

		user.visible_message("<span class='notice'>[user] starts to load [user.pulling] into [src].</span>",
		"<span class='notice'>You start to load [user.pulling] into [src].</span>")
		var/time = 10 SECONDS - (2 SECONDS * user.skills.getRating("large_vehicle"))
		if(!do_after(user, time, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(src, /datum.proc/Adjacent, user)))
			return
		enter_tank(user.pulling, POSITION_PASSENGER)

	// Removing someone from the tank
	if(user.a_intent == INTENT_GRAB) //Grab the tank to rip people out of it. Use this if someone dies in it.
		if(!allowed(user))
			to_chat(user, "<span class='warning'>[src]'s hatch won't budge!.</span>")	//DOOR STUCK
			return FALSE

		var/list/occupants = list()
		for(var/mob/living/L as() in operators)
			occupants["[L.name] [L.stat == DEAD ? "(DEAD)" :""]"] += L
		if(!length(occupants))
			to_chat(user, "<span class='warning'>No one is currently occupying [src]!.</span>")
			return
		var/choice = input(user, "Who do you want to forcibly remove from [src]?", "Your violent tendencies") as null|anything in occupants
		if(!choice)
			return
		var/mob/living/L = choice
		user.visible_message("<span class='warning'>[user] starts to force their way through [src]'s hatch!.</span>",
		"<span class='notice'>You start to force your way through [src]'s hatch to grab [L].</span>")
		var/time = 6 SECONDS - (1 SECONDS * user.skills.getRating("large_vehicle"))
		if(!do_after(user, time, TRUE, src, BUSY_ICON_BUILD))
			return
		if(!get_door_location(user))//in case the tank moves
			return
		exit_tank(L)
		L.SpinAnimation(1,1)
		L.throw_at(user, 3)
		// Applying STUN, WEAKEN and STUTTER
		L.apply_effects(6, 6, 0, 0, 6, 0, 0, 0, 0)
		user.visible_message("<span class='warning'>[user] rips [L] out of [src] and bodyslams them!.</span>",
		"<span class='notice'>You rip [L] out of [src] and bodyslam them!.</span>")
		playsound(get_turf(src), 'sound/effects/throw.ogg', 100, 1)
		return

	// Entering the tank
	var/position = alert("What seat would you like to enter?", name, POSITION_DRIVER, POSITION_GUNNER, POSITION_PASSENGER, "Cancel")
	if(!position || position == "Cancel")
		return
	if(pilot && position == POSITION_DRIVER)
		to_chat(user, "[pilot] is already piloting [src]!")
		return
	if(gunner && position == POSITION_GUNNER)
		to_chat(user, "[gunner] is already gunning [src]!")
		return
	if(LAZYLEN(passengers) >= max_passengers && position == POSITION_PASSENGER) //We have a few slots for people to enter as passengers without gunning / driving.
		to_chat(user, "[src] is full! There isn't enough space for you")
		return
	if(!can_enter(user, position)) //OWO can they enter us????	//what the fuck kmc
		return
	to_chat(user, "You climb into [src] as a [position]!")
	enter_tank(user, position)

/obj/vehicle/armored/proc/can_enter(mob/living/carbon/M, position) //NO BENOS ALLOWED
	if(!istype(M))
		return
	if(!M.dextrous)
		to_chat(M, "<span class='warning'>You don't have the dexterity to drive [src]!</span>")
		return FALSE
	if(!open && !allowed(M) && position != POSITION_PASSENGER)
		to_chat(M, "<span class='warning'>Access denied.</span>")
		return FALSE
	var/obj/item/offhand = M.get_inactive_held_item()
	if(offhand && !(offhand.flags_item & (NODROP|DELONDROP)))
		to_chat(M, "<span class='warning'>You need your hands free to climb into [src].</span>")
		return FALSE
	if(M.skills?.getRating("large_vehicle") < SKILL_LARGE_VEHICLE_TRAINED)
		M.visible_message("<span class='notice'>[M] fumbles around figuring out how to get into the [src].</span>",
		"<span class='notice'>You fumble around figuring out how to get into [src].</span>")
	var/time = 10 SECONDS - (2 SECONDS * M.skills.getRating("large_vehicle"))
	if(!do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
		return FALSE
	if(offhand && !(offhand.flags_item & (NODROP|DELONDROP)))
		to_chat(M, "<span class='warning'>You need your hands free to climb into [src].</span>")
		return FALSE
	if(!Adjacent(M))
		return FALSE//in case the tank moves
	return TRUE


///attempt to enter the vehicle with a mob
/obj/vehicle/armored/proc/enter_tank(mob/user, position) //By this point, we've checked that the seats are actually empty, so we won't need to do that again HOPEFULLY
	user.forceMove(src)
	LAZYADD(operators, user)
	switch(position)
		if(POSITION_DRIVER)
			pilot = user
		if(POSITION_GUNNER)
			RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, /obj/vehicle/armored.proc/on_mouse_down)
			gunner = user
			if(secondary_weapon)
				SEND_SIGNAL(secondary_weapon, COMSIG_TANK_ENTERED, GUN_FIREMODE_AUTOMATIC, user.client)
		if(POSITION_PASSENGER)
			LAZYADD(passengers, user)
	RegisterSignal(user, COMSIG_PARENT_QDELETING, .proc/on_occupant_qdel)

///Handles ref cleanup on accupant qdeletion
/obj/vehicle/armored/proc/on_occupant_qdel(datum/source)
	LAZYREMOVE(operators, source)
	LAZYREMOVE(passengers, source)
	if(gunner == source)
		if(secondary_weapon)
			SEND_SIGNAL(secondary_weapon, COMSIG_TANK_EXITED)
		gunner = null
	if(pilot == source)
		pilot = null

///Throws EVERYONE in the tank out
/obj/vehicle/armored/proc/remove_all_players()
	for(var/M in operators)
		exit_tank(M, TRUE)

///Proc thats called when someone tries to get out the vehicle
/obj/vehicle/armored/proc/exit_tank(mob/living/leaver, force = FALSE) //By this point, we've checked that the seats are actually empty, so we won't need to do that again HOPEFULLY
	var/turf/T = get_step(src, REVERSE_DIR(dir))
	if(!force && !T.CanPass(leaver, T))
		to_chat(leaver, "<span class='warning'>You can't exit right now, there is something blocking the exit.</span>")
		return

	LAZYREMOVE(operators, leaver)
	if(leaver == pilot)
		pilot = null
	else if(leaver == gunner)
		UnregisterSignal(gunner, COMSIG_MOB_MOUSEDOWN)
		UnregisterSignal(gunner, COMSIG_MOB_MOUSEUP)
		if(secondary_weapon)
			SEND_SIGNAL(secondary_weapon, COMSIG_TANK_EXITED)
		gunner = null
	else if(leaver in passengers)
		LAZYREMOVE(passengers, leaver)
	else
		stack_trace("Mob exited tank without being in its occupants list")
	UnregisterSignal(leaver, COMSIG_PARENT_QDELETING)
	leaver.forceMove(T)
	to_chat(leaver, "<span class='notice'>You hop out of [src] and slam its hatch shut behind you.</span>")

///violently ejects all occupants
/obj/vehicle/armored/proc/remove_mobs()
	for(var/mob/living/M as() in operators) //Yeet the occupants out so they arent deleted
		var/turf/T = get_turf(pick(orange(src,5)))
		M.forceMove(get_turf(src))
		M.SpinAnimation(1,1)
		M.throw_at(T, 3)
		// Applying STUN, WEAKEN and STUTTER
		M.apply_effects(6, 6, 0, 0, 6, 0, 0, 0, 0)
		to_chat(M, "<span class='warning'>You violently dive out of [src] as it explodes behind you!</span>")

/*
\\\\\\\\TANK VERBS////////
This handles stuff like swapping seats, pulling people out of the tank, all that stuff.
tbh this should be actions but that needs sprites and muh effort
*/

/obj/vehicle/armored/verb/exit_tank_verb()
	set name = "Exit vehicle"
	set category = "Vehicle"
	set src in view(0)
	if(usr)
		exit_tank(usr)

/obj/vehicle/armored/verb/toggle_light()
	set name = "Toggle floodlights"
	set category = "Vehicle"
	set src in view(0)

	if(!ishuman(usr))
		return
	if(CHECK_BITFIELD(flags_armored, LIGHTS_ON))
		to_chat(usr, "<span class='notice'>You turn off [src]'s floodlights.</span>")
		set_light(0)
	else
		to_chat(usr, "<span class='notice'>You turn [src]'s floodlights on.</span>")
		set_light(10)
	TOGGLE_BITFIELD(flags_armored, LIGHTS_ON)


/obj/vehicle/armored/verb/switch_seats()
	set name = "Swap Seats"
	set category = "Vehicle"
	set src in view(0)

	if(!ishuman(usr))
		return

	if(usr.incapacitated())
		return

	var/wannabe_trucker = (usr == gunner) ? TRUE : FALSE
	var/neighbour = wannabe_trucker ? pilot : gunner
	if(neighbour)
		to_chat(usr, "<span class='notice'>There's already someone in the other seat.</span>")
		return
	if(usr in passengers)
		to_chat(usr, "<span class='notice'>You can't get to the front seats from back here, try getting out of [src]?.</span>")
		return
	to_chat(usr, "<span class='notice'>You start getting into the other seat.</span>")
	addtimer(CALLBACK(src, .proc/seat_switched, wannabe_trucker, usr), 3 SECONDS)

///Called when the gunner or driver finishes swapping seats
/obj/vehicle/armored/proc/seat_switched(wannabe_trucker, mob/living/user)

	var/player = wannabe_trucker ? gunner : pilot
	var/challenger = wannabe_trucker ? pilot : gunner
	if(QDELETED(user) || user.incapacitated() || player != user)
		return

	if(challenger)
		to_chat(user, "<span class='notice'>Someone beat you to the other seat!</span>")
		return

	to_chat(user, "<span class='notice'>You man up the [wannabe_trucker ? "driver" : "gunner"]'s seat.</span>")

	pilot = wannabe_trucker ? user : null
	gunner = wannabe_trucker ? null : user

	if(!secondary_weapon)
		return
	if(pilot)
		SEND_SIGNAL(secondary_weapon, COMSIG_TANK_EXITED)
		UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)
		UnregisterSignal(user, COMSIG_MOB_MOUSEUP)
		return
	if(gunner)
		SEND_SIGNAL(secondary_weapon, COMSIG_TANK_ENTERED, GUN_FIREMODE_AUTOMATIC, user.client)
		RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, /obj/vehicle/armored.proc/on_mouse_down)

#undef POSITION_DRIVER
#undef POSITION_PASSENGER
#undef POSITION_GUNNER

/*
Armored vehicles by Tivi, Psykzz and KMC

THIS IS LIKE REGULAR CM tank BUT IT'S LESS SHIT
WHOEVER MADE CM TANKS: YOU ARE A BAD CODER!!!!!
*/

#define POSITION_DRIVER "Driver"
#define POSITION_GUNNER "Gunner"
#define POSITION_PASSENGER "Passenger"

/* TIVIS GUIDE TO MAKING VEHICLES, OR THE DUMMIES GUIDE TO TANK MAKING
  *
  * First get your sprites in
  * You must manually set the offsets for your tank subtypes so that they move correctly, VV them in game to find the perfect values for it
  * add default weapons and decide whether it should move diagonally or not
  * add a doorpoint for where you want people to get in from using get_door_location()
  *
  * MULTITILE EXTRAS:
  * Set the hitbox_type to your hitbox, /hitbox is 3x3 and /hitbox/medium is 2x2 so make custom ones as required
  * you can also layer multiple hitboxes to make ... special shapes
  * REMEMBER, USE ONLY BOUNDS DIVISIBLE BY 32 OR GLIDING WILL BREAK
  * Set doorpoints for where you want access from, set this in the get_door_location() proc
  * Set relaymove like this:
  * First check if we can move in the first place
  * Then calculate centerturf and the rest of the tiles that need to be rammed using get_steps() and turns()
  * Then do do_move(), which handles ramming of the actual turfs
  * This part is specifically not split up into procs because holy FUCK byond proc overhead
  */

/** Armored vehicles
  * HOW DOES IT WORK
  *
  * Each vehicle can hold at least a gunner and a driver and optionally can carry passengers
  * Bump will cause damage to things and do the ramming effect
  * The weapons have a overlay that is updated when the gunner does stuff and will rotate accordingly
  * The layers set this high because multitile sprites have issues with lighting otherwise
  * Also % damage overlays are calculated on damage so remember to add those
  *
  * MULTITILE:
  * Since we cant make non 1x1 vehicles move normally we instead make a hitbox that is forcemoved onto the location of the tank,
  * creating a dense area while allowing the tank to move. The Hitbox also acts as a relay for projectiles, all other interactions are handled
  * by Adjacent().
  * Doorpoints exist for both multitile and 1x1 and determine the location where the humans are allowed to go in
  * Both doorpoints and multitile are tracked in a list meaning that you can make non-rectangular vehicles by layering hitboxes
  * And multiple enterances through which humans can get in
  * Crushing is calculated on relaymove, where we select a main "centerturf" ahead that we can then calculate the rest of the tiles from,
  * Although you can alter the exact method to suit your needs
  */
/obj/vehicle/armored
	name = "\improper TAV - Shortstreet MK4"	//PEAK PERFORMANCE MINITANK
	desc = "An adorable chunk of metal with an alarming amount of firepower designed to crush, immolate, destroy and maim anything that Nanotrasen wants it to. This model contains advanced Bluespace technology which allows a TARDIS-like amount of room on the inside."
	icon = 'icons/obj/tinytank.dmi'
	icon_state = "tank"
	pixel_x = -16
	pixel_y = -8
	layer = ABOVE_MOB_LAYER
	anchored = FALSE
	req_access = list(ACCESS_MARINE_TANK)
	move_delay = 0.7 SECONDS
	obj_integrity = 1000 //Friendly fire resistant
	max_integrity = 1000
	flags_atom = PREVENT_CONTENTS_EXPLOSION
	anchored = TRUE //No bumping / pulling the tank
	demolish_on_ram = TRUE
	soft_armor = list("melee" = 50, "bullet" = 60, "laser" = 30, "energy" = 20, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 50, "acid" = 20)
	open = TRUE //whether we need access in order to go in, false is we do NOT need it
	COOLDOWN_DECLARE(tank_move_cooldown)
	COOLDOWN_DECLARE(drive_sound_cooldown)
	///The max amount of passangers this vehcle can hold
	var/max_passengers = 0
	///Icon for the secondary rotating turret
	var/secondary_turret_icon = null
	///The mob in the drivers seat
	var/mob/living/carbon/human/pilot
	///The mob in the gunner seat
	var/mob/living/carbon/human/gunner
	///Who's in this tank? Prevents you from entering the tank again
	var/list/operators

	//////////Health and combat shit\\\\\\\\\\\\\\

	///Cool and good turret overlay that allows independently swiveling guns
	var/atom/movable/vis_obj/turret_overlay/turret_overlay
	///secondary independently rotating overlay
	var/atom/movable/vis_obj/turret_overlay/secondary_weapon_overlay/secondary_weapon_overlay
	///Damage overlay for when the vehicle gets damaged
	var/atom/movable/vis_obj/damage_overlay
	///For larger vehicles that need seperately overlaying parts.
	var/has_underlay = FALSE
	///Overlay for larger vehicles that need under parts
	var/image/underlay = null


	///What weapon we have in our primary slot
	var/obj/item/tank_weapon/primary_weapon //What we use to shoot big shells
	///What weapon we have in our secondary slot
	var/obj/item/tank_weapon/secondary_weapon
	///Our utility module
	var/obj/item/tank_module/utility_module
	//What kind of primary tank weaponry we start with. Defaults to a tank gun.
	var/primary_weapon_type = /obj/item/tank_weapon
	//What kind of secondary tank weaponry we start with. Default minigun as standard.
	var/secondary_weapon_type = /obj/item/tank_weapon/secondary_weapon
	///Icon for the rotating turret
	var/turret_icon = 'icons/obj/tinytank_gun.dmi'
	///Iconstate for the rotating main turret
	var/turret_icon_state = "turret"
	///Icon pathing for the secondary turret
	var/secondary_turret_icon_state = "m56cupola"
	///Main weapon shooting code, at whom are we firing?
	var/atom/firing_target = null

	///Used to check whether we can play the next engine sound
	var/drive_sound_cooldown_length = 2 SECONDS
	///Lazylist of people who are in the tank without gunning or driving. This allows for things like jeeps and APCs
	var/list/passengers
	///Tracks whether the lights are on or off
	var/lights_on = FALSE
	///For smaller vehicles like a jeep you may want this. This forbids / allows you to move diagonally in these vehicles
	var/allow_diagonal_movement = TRUE

/obj/vehicle/armored/multitile
	name = "TAV - Rhino"
	desc = "A gigantic wall of metal designed for maximum Xeno destruction. Click it with an open hand to enter as a pilot or a gunner."
	icon = 'icons/obj/tank/tank.dmi'
	turret_icon = 'icons/obj/tank/tank_gun.dmi'
	secondary_turret_icon = 'icons/obj/tank/tank_secondary_gun.dmi'
	icon_state = "tank"
	pixel_x = -48
	pixel_y = -48
	obj_integrity = 2000
	max_integrity = 2000
	max_passengers = 2
	allow_diagonal_movement = FALSE
	move_delay = 0.8 SECONDS
	///The hitbox default type(size) for this vehicle
	var/hitbox_type = /obj/vehicle/hitbox
	///List of doors and hitboxes we need to be moved when we move
	var/list/linked_hitboxes

/obj/vehicle/armored/multitile/get_door_location(atom/user)
	if(user.loc == get_step_away(get_step(src,turn(dir, 180)), src, 2))
		return TRUE
	return FALSE

/obj/vehicle/armored/apc //smol apc
	name = "TAV - Nike"
	desc = "A miniaturized replica of a popular personnel carrier. For ages 5 and up."
	icon = 'icons/obj/tinytank.dmi'
	turret_icon = 'icons/obj/tinytank_gun.dmi'
	turret_icon_state = "apc_turret"
	icon_state = "apc"
	move_delay = 0.3 SECONDS
	pixel_x = -16
	pixel_y = -8
	max_passengers = 1
	primary_weapon_type = null
	secondary_weapon_type = null

/obj/vehicle/armored/multitile/medium //Its a smaller tank, we had sprites for it so whoo
	name = "THV - Hades"
	desc = "A metal behemoth which is designed to cleave through enemy lines. It comes pre installed with a main tank cannon capable of deploying heavy payloads, as well as a minigun which can tear through multiple targets in quick succession."
	icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon_state = "tank_turret"
	secondary_turret_icon = null
	icon_state = "tank"
	pixel_x = -16
	pixel_y = -32
	obj_integrity = 1300 //Heavily armoured. Will take a lot of friendly fire to kill it.
	max_integrity = 1300
	max_passengers = 1 //Seats 3 total. It's designed to cut through enemy lines with 1 gunner, 1 pilot and 1 commander to oversee operations
	has_underlay = TRUE
	hitbox_type = /obj/vehicle/hitbox/medium

/obj/vehicle/armored/multitile/medium/get_door_location(atom/user)
	if(dir == NORTH || dir == WEST)
		if(user.loc == get_step_away(get_step(src,turn(dir, 180)), src, 3))//Because haha funny byond sprite rotations funny
			return TRUE
	else if(user.loc == get_step(src,turn(dir, 180)))
		return TRUE
	return FALSE

/obj/vehicle/armored/multitile/medium/apc //BIG APC
	name = "TAV - Athena"
	desc = "A heavily armoured vehicle with light armaments designed to ferry troops around the battlefield, or assist with search and rescue (SAR) operations."
	icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon_state = "apc_turret"
	icon_state = "apc"
	move_delay = 0.25 SECONDS //Fast as fuck boiii
	max_passengers = 3 //Enough to ferry wounded men to and fro without being stupidly tardis like. Seats 5 total
	primary_weapon_type = /obj/item/tank_weapon/apc_cannon //Only has a utility launcher, no offense as standard.
	secondary_weapon_type = null
	has_underlay = TRUE

/obj/vehicle/armored/examine(mob/user)
	. = ..()
	to_chat(user, "<b><span class='notice'>To fire its main cannon, <i>middle</i> click a tile.</b></span> \n <span class='notice'><b>To fire its secondary weapon, click a tile.</b></span>")
	to_chat(user, "<b><span class='notice'>To forcibly remove someone from it, use grab intent.</b></span> \n <i><span class='notice'>It's currently holding [LAZYLEN(passengers)] / [max_passengers] passengers (excluding its gunner and pilot).</i></span>")
	to_chat(user, "<i><span class='notice'>There is [isnull(primary_weapon) ? "nothing" : "[primary_weapon]"] in the primary attachment point, [isnull(secondary_weapon) ? "nothing" : "[secondary_weapon]"] installed in the secondary slot and [isnull(utility_module) ? "nothing" : "[utility_module]"] in the utility slot.</i></span>")
	to_chat(user, "<b><span class='notice'>It is currently at <i>[PERCENT(max_integrity/obj_integrity)]%</i> health.</b></span>")

/atom/movable/vis_obj/turret_overlay
	name = "Tank gun turret"
	desc = "The shooty bit on a tank."
	icon = 'icons/obj/tank/tank_gun.dmi'
	icon_state = "turret"
	layer = ABOVE_ALL_MOB_LAYER
	animate_movement = TRUE //So it doesnt just ping back and forth and look all stupid
	mouse_opacity = FALSE //It's an overlay

/atom/movable/vis_obj/turret_overlay/secondary_weapon_overlay
	name = "Tank gun secondary turret"
	desc = "The shooty bit on a tank."
	icon = 'icons/obj/tank/tank_secondary_gun.dmi'
	icon_state = "m56cupola_2"


/*
\\\\\\\\TANK HITBOX////////
The core of multitile. Acts as a relay for damage and stops people from walking onto the tank sprite
*/

/obj/vehicle/hitbox
	///The "parent" that this hitbox is attached to and to whom it will relay damage
	var/obj/vehicle/armored/multitile/root = null
	density = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	max_integrity = 10000

/obj/vehicle/hitbox/medium
	bound_width = 64
	bound_height = 64
	bound_x = 0
	bound_y = -32

/obj/vehicle/hitbox/projectile_hit(obj/projectile/proj)
	. = ..()
	if(proj.firer == root)
		return FALSE

/obj/vehicle/hitbox/bullet_act(obj/projectile/P)
	root.bullet_act(P)

/obj/vehicle/hitbox/take_damage(amount)
	root.take_damage(amount)

/*
\\\\\\\\INITIALIZE STUFF////////
Init and destroy procs for both multitile and 1x1 vehicles.
*/

/obj/vehicle/armored/Initialize()
	. = ..()
	if(primary_weapon_type)
		primary_weapon = new primary_weapon_type(src) //Make our guns
		primary_weapon.owner = src
		turret_overlay = new()
		turret_overlay.icon = turret_icon
		turret_overlay.icon_state = turret_icon_state
		turret_overlay.setDir(dir)
		turret_overlay.pixel_x = 0
		vis_contents += turret_overlay
	if(secondary_weapon_type)
		secondary_weapon = new secondary_weapon_type(src)
		secondary_weapon.owner = src
		secondary_weapon_overlay = new()
		secondary_weapon_overlay.icon = secondary_turret_icon
		secondary_weapon_overlay.layer = layer+0.5
		vis_contents += secondary_weapon_overlay
	//Adding Normal overlays
	damage_overlay = new(src)
	add_overlay(damage_overlay)
	if(has_underlay)
		underlay = new(icon, layer = layer+0.1)
		add_overlay(underlay)
	GLOB.tank_list += src

///Proc to get the location of the door of the vehicle
/obj/vehicle/armored/proc/get_door_location(atom/user)
	if(user.loc == get_step(src,turn(dir, 180)))
		return TRUE
	return FALSE

/obj/vehicle/armored/multitile/Initialize()
	. = ..()
	LAZYADD(linked_hitboxes, new hitbox_type(loc))
	for(var/obj/vehicle/hitbox/hitbox as() in linked_hitboxes)	//We can have multiple different sized hitboxes if we wanna be funky and make a Tshaped tank
		hitbox.root = src

/obj/vehicle/armored/Destroy()
	obj_integrity = 10000 //Prevents this from being called over and over and over while we chuck the mobs out
	remove_mobs()
	QDEL_NULL(turret_overlay)
	QDEL_NULL(secondary_weapon_overlay)
	QDEL_NULL(primary_weapon)
	QDEL_NULL(secondary_weapon)
	QDEL_NULL(utility_module)
	QDEL_NULL(damage_overlay)
	underlay = null
	playsound(get_turf(src), 'sound/weapons/guns/fire/tank_cannon1.ogg', 100, TRUE) //Explosion sound
	GLOB.tank_list -= src
	return ..()

/obj/vehicle/armored/multitile/Destroy()
	for(var/k in linked_hitboxes)
		QDEL_NULL(k)
	return ..()

/*
\\\\\\\\GENERIC PROCS////////
Removing mobs, move and icon tuff.
*/

/obj/vehicle/armored/proc/remove_mobs()
	for(var/mob/living/M as() in operators) //Yeet the occupants out so they arent deleted
		var/turf/T = get_turf(pick(orange(src,5)))
		M.forceMove(get_turf(src))
		M.SpinAnimation(1,1)
		M.throw_at(T, 3)
		// Applying STUN, WEAKEN and STUTTER
		M.apply_effects(6, 6, 0, 0, 6, 0, 0, 0, 0)
		to_chat(M, "<span class='warning'>You violently dive out of [src] as it explodes behind you!</span>")

/obj/vehicle/armored/Move()
	. = ..()
	if(COOLDOWN_CHECK(src, drive_sound_cooldown))
		return
	COOLDOWN_START(src, drive_sound_cooldown, drive_sound_cooldown_length)
	playsound(src, 'sound/ambience/tank_driving.ogg', vol = 20, sound_range = 30)

/obj/vehicle/armored/multitile/Move()
	. = ..()
	for(var/obj/vehicle/hitbox/H as() in linked_hitboxes)
		H.forceMove(loc)

/obj/vehicle/armored/update_icon()
	//Updating normal overlays
	switch(PERCENT(obj_integrity / max_integrity))
		if(0 to 29)
			damage_overlay.icon_state = "damage_major"
		if(30 to 59)
			damage_overlay.icon_state = "damage_medium"
		if(60 to 70)
			damage_overlay.icon_state = "damage_minor_medium"
		if(71 to 90)
			damage_overlay.icon_state = "damage_minor"
		else
			damage_overlay.icon_state = null

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

/*
\\\\\\\\TANK MOVEMENT////////
Tank relaymove(), related checks and subsequent bumping.
*/

/obj/vehicle/armored/relaymove(mob/user, direction)
	if(!COOLDOWN_CHECK(src, tank_move_cooldown))
		return
	COOLDOWN_START(src, tank_move_cooldown, move_delay)
	if(!allow_diagonal_movement && ISDIAGONALDIR(direction))
		return
	if(user.incapacitated() || user != pilot)
		to_chat(user, "<span class ='notice'>You can't reach the gas pedal from down here, maybe try manning the driver's seat?</span>")
		return
	setDir(direction)//we can move, so lets start by pointing in that direction
	return step(src, direction)

/*
	3x3 vehicle relaymove
*/
/obj/vehicle/armored/multitile/relaymove(mob/user, direction)
	if(!COOLDOWN_CHECK(src, tank_move_cooldown))
		return FALSE
	COOLDOWN_START(src, tank_move_cooldown, move_delay)
	if(!allow_diagonal_movement && ISDIAGONALDIR(direction))
		return FALSE
	if(user.incapacitated() || user != pilot)
		to_chat(user, "<span class ='notice'>You can't reach the gas pedal from down here, maybe try manning the driver's seat?</span>")
		return FALSE
	setDir(direction)//we can move, so lets start by pointing in that direction
	//Due to this being a hot proc this part here is inlined and set on a by-vehicle basis
	/////////////////////////////
	var/turf/centerturf = get_step(get_step(src, direction), direction)
	var/list/enteringturfs = list(centerturf)
	enteringturfs += get_step(centerturf, turn(direction, 90))
	enteringturfs += get_step(centerturf, turn(direction, -90))
	/////////////////////////////
	var/canstep = TRUE
	for(var/turf/T as() in enteringturfs)	//No break because we want to crush all the turfs before we start trying to move
		if(T.Enter(src) == FALSE)	//Check if we can cross the turf first/bump the turf
			canstep = FALSE		//why "var == false" you ask? well its because its faster, thanks byond
		for(var/b in T.contents)
			var/atom/O = b
			if(O.CanPass(src))	// Then check for obstacles to crush
				continue
			Bump(O)
			canstep = FALSE
	if(canstep)
		return step(src, direction)
	return FALSE


///Rams all our obstacles and checks if we can keep moving
/obj/vehicle/armored/multitile/proc/do_move(enteringturfs)
	var/canstep = TRUE
	for(var/turf/T as() in enteringturfs)	//No break because we want to crush all the turfs before we start trying to move
		if(T.Enter(src) == FALSE)	//Check if we can cross the turf first/bump the turf
			canstep = FALSE
		for(var/atom/movable/item as() in T.contents)
			if(item.CanPass(src) == TRUE)	// Then check for obstacles to crush
				continue
			Bump(item)
			canstep = FALSE //Dont break so we hit everything
	return canstep

/obj/vehicle/hitbox/CanPass(atom/movable/mover, turf/target)
	. = ..()
	if(mover == root)//Bypass your own hitbox
		return TRUE

/obj/vehicle/armored/Bump(atom/A, yes)
	. = ..()
	var/facing = get_dir(src, A)
	var/turf/temp = get_turf(loc)
	var/turf/T = get_turf(loc)
	A.vehicle_collision(src, facing, T, temp, pilot)

/*
\\\\\\\\\\\\Seperate calculations for the different vehicles////////////
*/

/obj/vehicle/armored/multitile/medium/relaymove(mob/user, direction)
	if(!COOLDOWN_CHECK(src, tank_move_cooldown))
		return
	COOLDOWN_START(src, tank_move_cooldown, move_delay)
	if(!allow_diagonal_movement && ISDIAGONALDIR(direction))
		return FALSE
	if(user.incapacitated() || user != pilot)
		to_chat(user, "<span class ='notice'>You can't reach the gas pedal from down here, maybe try manning the driver's seat?</span>")
		return FALSE
	setDir(direction)//we can move, so lets start by pointing in that directionreturn
	///////////////////////////
	var/list/enteringturfs = list()
	var/turf/centerturf = get_step(src, direction)
	switch(direction)
		if(NORTH)
			enteringturfs += get_step(centerturf, turn(direction, -90))
		if(SOUTH)
			centerturf = get_step(get_step(src, direction), direction)
			enteringturfs += get_step(centerturf, turn(direction, 90))
		if(EAST)
			centerturf = get_step(get_step(src, direction), direction)
			enteringturfs += get_step(centerturf, turn(direction, -90))
		if(WEST)
			enteringturfs += get_step(centerturf, turn(direction, 90))
	enteringturfs += centerturf
	////////////////////////////////////
	var/canstep = TRUE
	for(var/i in enteringturfs)	//No break because we want to crush all the turfs before we start trying to move
		var/turf/T = i
		if(T.Enter(src) == FALSE)	//Check if we can cross the turf first/bump the turf
			canstep = FALSE
		for(var/b in T.contents)
			var/atom/O = b
			if(O.CanPass(src) == TRUE)	// Then check for obstacles to crush
				continue
			Bump(O)
			canstep = FALSE
	if(canstep)
		return step(src, direction)
	return FALSE
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
	if(lights_on)
		to_chat(usr, "<span class='notice'>You turn off [src]'s floodlights.</span>")
		set_light(0)
		lights_on = FALSE
	else
		to_chat(usr, "<span class='notice'>You turn [src]'s floodlights on.</span>")
		set_light(5)
		lights_on = TRUE


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

/obj/vehicle/armored/bullet_act(obj/projectile/Proj)
	. = ..()
	update_icon()

/obj/vehicle/armored/take_damage(amount)
	. = ..()
	update_icon() //Update damage overlays

#undef POSITION_DRIVER
#undef POSITION_PASSENGER
#undef POSITION_GUNNER

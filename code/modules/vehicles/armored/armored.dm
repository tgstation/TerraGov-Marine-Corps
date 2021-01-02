	/*
Armored vehicles by Tivi,
Psykzz and KMC (but mostly tivi)

THIS IS LIKE REGULAR CM tank BUT IT'S LESS SHIT
WHOEVER MADE CM TANKS: YOU ARE A BAD CODER!!!!!
^^ said KMC not realizing it was spooky
*/


/*! TIVIS GUIDE TO MAKING VEHICLES, OR THE DUMMIES GUIDE TO TANK MAKING
 *
 * First get your sprites in, create a new folder for them in the vehicles folder and set the .dmi values correctly
 * You can add:
 * * Main Turret
 * * Secondary turrets
 * * Underlays
 * * Map variations
 * * Damage overlays
 * * //todo Armor overlays
 *
 * You must manually set the offsets for your tank subtypes so that they move correctly, VV them in game to find the perfect values for it
 * add default weapons and decide whether it should move diagonally or not
 * add a doorpoint for where you want people to get in from using get_door_location()
 *
 * MULTITILE EXTRAS:
 * Set the hitbox_type to your hitbox, /hitbox is 3x3 and /hitbox/medium is 2x2 so make custom ones as required
 * you can also layer multiple hitboxes to make ... special shapes, though I really dont recomend that
 * REMEMBER, USE ONLY BOUNDS DIVISIBLE BY 32 OR GLIDING WILL BREAK
 *
 * Set doorpoints for where you want access from, set this in the get_door_location() proc
 *
 * Set relaymove like this for new vehicle sizes:
 *  * First check if we can move in the first place
 *  * //////
 *  * calculate enteringturfs or the movement
 *  * //////
 *  * Crush/try to move the vehicle
 *
 * This part is specifically not split up into procs because holy god FUCK byond proc overhead
 */

/** Armored vehicles
 * HOW DOES IT WORK
 *
 * Each vehicle can hold at least a gunner and a driver and optionally can carry passengers
 * Bump will cause damage to things and do the ramming effect
 * The weapons have a overlay that is updated when the gunner does stuff and will rotate accordingly
 * The layers set this high because multitile sprites have issues with mobs and so otherwise
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
 *
 * Theres some wack optimizations happening here too like using ```var == TRUE``` to ensure it doesnt lag the game so tread carefully when refactoring
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
	///The max amount of passangers this vehicle can hold
	var/max_passengers = 0
	///Icon for the secondary rotating turret
	var/secondary_turret_icon = null
	///The mob in the drivers seat
	var/mob/living/carbon/human/pilot
	///The mob in the gunner seat
	var/mob/living/carbon/human/gunner
	///Lazylist of mobs inside the tank
	var/list/operators

	///Tank bitflags
	var/flags_armored = HAS_PRIMARY_WEAPON|HAS_SECONDARY_WEAPON

	//////////Health and combat shit\\\\\\\\\\\\\\

	///Cool and good turret overlay that allows independently swiveling guns
	var/atom/movable/vis_obj/turret_overlay/turret_overlay
	///secondary independently rotating overlay
	var/atom/movable/vis_obj/turret_overlay/secondary_weapon_overlay/secondary_weapon_overlay
	///Damage overlay for when the vehicle gets damaged
	var/atom/movable/vis_obj/tank_damage/damage_overlay
	///Icon file path for the damage overlay
	var/damage_icon_path
	///Overlay for larger vehicles that need under parts
	var/image/underlay


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

	///Uwhen can play the next engine sound
	var/drive_sound_cooldown_length = 2 SECONDS
	///Lazylist of people who are in the tank without gunning or driving. This allows for things like jeeps and APCs
	var/list/passengers
	///For smaller vehicles like a jeep you may want this. This forbids / allows you to move diagonally in these vehicles
	var/allow_diagonal_movement = TRUE

/obj/vehicle/armored/apc //smol apc
	name = "TAV - Nike"
	desc = "A miniaturized replica of a popular personnel carrier. For ages 5 and up."
	icon = 'icons/obj/tinytank.dmi'
	turret_icon = 'icons/obj/tinytank_gun.dmi'
	turret_icon_state = "apc_turret"
	icon_state = "apc"
	move_delay = 0.3 SECONDS
	flags_armored = NONE
	pixel_x = -16
	pixel_y = -8
	max_passengers = 1
	primary_weapon_type = null
	secondary_weapon_type = null

/obj/vehicle/armored/multitile
	name = "TAV - Rhino"
	desc = "A gigantic wall of metal designed for maximum Xeno destruction. Click it with an open hand to enter as a pilot or a gunner."
	icon = 'icons/obj/tank/tank.dmi'
	turret_icon = 'icons/obj/tank/tank_gun.dmi'
	secondary_turret_icon = 'icons/obj/tank/tank_secondary_gun.dmi'
	damage_icon_path = 'icons/obj/tank/tank_damage.dmi'
	icon_state = "tank"
	flags_armored = HAS_PRIMARY_WEAPON|HAS_SECONDARY_WEAPON|HAS_UNDERLAY|HAS_MAP_VARIANTS
	pixel_x = -48
	pixel_y = -48
	obj_integrity = 2000
	max_integrity = 2000
	max_passengers = 2
	allow_diagonal_movement = FALSE
	move_delay = 0.7 SECONDS
	///The hitbox default type(size) for this vehicle
	var/hitbox_type = /obj/hitbox
	///hitbox we need to be moved when we move
	var/obj/hitbox/linked_hitbox

/obj/vehicle/armored/multitile/get_door_location(atom/user)
	if(user.loc == get_step_away(get_step(src,turn(dir, 180)), src, 2))
		return TRUE
	return FALSE

/obj/vehicle/armored/multitile/apc
	name = "TAV - Athena"
	desc = "An unarmed command APC designed to command and transport troops in the battlefield."
	icon = 'icons/obj/apc/apc.dmi'
	icon_state = "apc"
	damage_icon_path = 'icons/obj/apc/damage_overlay.dmi'
	turret_icon = null
	secondary_turret_icon = null
	primary_weapon_type = null
	secondary_weapon_type = null// this is a command apc
	flags_armored = NONE
	//pixel_x = -55
	//pixel_y = -40
	obj_integrity = 2000
	max_integrity = 2000
	max_passengers = 8 //Clown car? Clown car.
	move_delay = 0.5 SECONDS

/obj/vehicle/armored/multitile/medium //Its a smaller tank, we had sprites for it so whoo
	name = "THV - Hades"
	desc = "A metal behemoth which is designed to cleave through enemy lines. It comes pre installed with a main tank cannon capable of deploying heavy payloads, as well as a minigun which can tear through multiple targets in quick succession."
	icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon_state = "tank_turret"
	secondary_turret_icon = null
	damage_icon_path = null
	icon_state = "tank"
	flags_armored = HAS_PRIMARY_WEAPON|HAS_SECONDARY_WEAPON
	pixel_x = -16
	pixel_y = -32
	obj_integrity = 1300
	max_integrity = 1300
	max_passengers = 1
	hitbox_type = /obj/hitbox/medium

/obj/vehicle/armored/multitile/medium/get_door_location(atom/user)
	if(dir == NORTH || dir == WEST)
		if(user.loc == get_step_away(get_step(src,turn(dir, 180)), src, 3))//Because haha funny byond sprite rotations funny
			return TRUE
	else if(user.loc == get_step(src,turn(dir, 180)))
		return TRUE
	return FALSE

/obj/vehicle/armored/multitile/medium/apc //BIG APC
	name = "TAV - Nike"
	desc = "A heavily armoured vehicle with light armaments designed to ferry troops around the battlefield, or assist with search and rescue (SAR) operations."
	icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon_state = "apc_turret"
	damage_icon_path = null
	flags_armored = HAS_PRIMARY_WEAPON|HAS_SECONDARY_WEAPON|HAS_UNDERLAY
	icon_state = "apc"
	move_delay = 0.25 SECONDS
	max_passengers = 3 //Enough to ferry wounded men to and fro without being stupidly tardis like. Seats 5 total
	primary_weapon_type = /obj/item/tank_weapon/apc_cannon //Only has a utility launcher, no offense as standard.
	secondary_weapon_type = null


/obj/vehicle/armored/examine(mob/user)
	. = ..()
	if(!isxeno(user))
		to_chat(user, "<b><span class='notice'>To fire its main cannon, <i>middle</i> click a tile.</b></span> \n <span class='notice'><b>To fire its secondary weapon, click a tile.</b></span>")
		to_chat(user, "<b><span class='notice'>To forcibly remove someone from it, use grab intent.</b></span> \n <i><span class='notice'>It's currently holding [LAZYLEN(passengers)] / [max_passengers] passengers (excluding its gunner and pilot).</i></span>")
	to_chat(user, "<i><span class='notice'>There is [isnull(primary_weapon) ? "nothing" : "[primary_weapon]"] in the primary attachment point, [isnull(secondary_weapon) ? "nothing" : "[secondary_weapon]"] installed in the secondary slot and [isnull(utility_module) ? "nothing" : "[utility_module]"] in the utility slot.</i></span>")
	if(!isxeno(user))
		to_chat(user, "<b><span class='notice'>It is currently at <i>[PERCENT(obj_integrity / max_integrity)]%</i> health.</b></span>")

/atom/movable/vis_obj/turret_overlay
	name = "Tank gun turret"
	desc = "The shooty bit on a tank."
	icon = 'icons/obj/tank/tank_gun.dmi' //set by owner
	icon_state = "turret"
	layer = ABOVE_ALL_MOB_LAYER
	animate_movement = TRUE //So it doesnt just ping back and forth and look all stupid
	mouse_opacity = FALSE //It's an overlay

/atom/movable/vis_obj/turret_overlay/secondary_weapon_overlay
	name = "Tank gun secondary turret"
	desc = "The other shooty bit on a tank."
	icon = 'icons/obj/tank/tank_secondary_gun.dmi' //set by owner
	icon_state = "m56cupola_2"

/atom/movable/vis_obj/turret_overlay/proc/remove_fire_overlay(overlay)
	overlays -= overlay

/atom/movable/vis_obj/tank_damage
	name = "Tank damage overlay"
	desc = "ow."
	icon = 'icons/obj/tank/tank_damage.dmi' //set by tank
	icon_state = "null" // set on demand

///Wrapper for when the parent vehicles dir changes
/atom/movable/vis_obj/tank_damage/proc/changedir(datum/source, olddir, newdir)
	SIGNAL_HANDLER
	setDir(newdir)

/**
 * TANK HITBOX
 * The core of multitile. Acts as a relay for damage and stops people from walking onto the tank sprite
 * has changed bounds and as thus must always be forcemoved so it doesnt break everything
 * I would use pixel movement but the maptick caused by it is way too high and a fake tile based movement isnt performant either
 * Thus we just use this relay
 * For the sake of not making spagetti these should be square when possible
 */
/obj/hitbox
	///The "parent" that this hitbox is attached to and to whom it will relay damage
	var/obj/vehicle/armored/multitile/root = null
	density = TRUE
	anchored = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	max_integrity = 10000

/obj/hitbox/medium
	bound_width = 64
	bound_height = 64
	bound_x = 0
	bound_y = -32

/obj/hitbox/projectile_hit(obj/projectile/proj)
	if(proj.firer == root)
		return FALSE
	return ..()

/obj/hitbox/bullet_act(obj/projectile/P)
	root.bullet_act(P)

/obj/hitbox/take_damage(amount)
	root.take_damage(amount)

/*
\\\\\\\\INITIALIZE STUFF////////
Init and destroy procs for both multitile and 1x1 vehicles.
*/

/obj/vehicle/armored/Initialize()
	. = ..()
	if(CHECK_BITFIELD(flags_armored, HAS_UNDERLAY))
		underlay = new(icon, "underlay", layer = layer-0.1)
		add_overlay(underlay)
	if(damage_icon_path)
		damage_overlay = new()
		damage_overlay.icon = damage_icon_path
		damage_overlay.layer = layer+0.1
		vis_contents += damage_overlay
		damage_overlay.RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, /atom/movable/vis_obj/tank_damage.proc/changedir)
	if(CHECK_BITFIELD(flags_armored, HAS_PRIMARY_WEAPON))
		turret_overlay = new()
		turret_overlay.icon = turret_icon
		turret_overlay.icon_state = turret_icon_state
		turret_overlay.setDir(dir)
		turret_overlay.pixel_x = 0
		turret_overlay.layer = layer+0.2
		if(CHECK_BITFIELD(flags_armored, HAS_MAP_VARIANTS))
			switch(SSmapping.configs[GROUND_MAP].armor_style)
				if(MAP_ARMOR_STYLE_JUNGLE)
					turret_overlay.icon_state += "_jungle"
				if(MAP_ARMOR_STYLE_ICE)
					turret_overlay.icon_state += "_snow"
				if(MAP_ARMOR_STYLE_PRISON)
					turret_overlay.icon_state += "_urban"
				if(MAP_ARMOR_STYLE_DESERT)
					turret_overlay.icon_state += "_desert"
		vis_contents += turret_overlay
		if(primary_weapon_type)
			attach_weapon(new primary_weapon_type(src), MODULE_PRIMARY)
	if(CHECK_BITFIELD(flags_armored, HAS_SECONDARY_WEAPON))
		secondary_weapon_overlay = new()
		secondary_weapon_overlay.icon = secondary_turret_icon
		secondary_weapon_overlay.layer = layer+0.3
		vis_contents += secondary_weapon_overlay
		if(secondary_weapon_type)
			attach_weapon(new secondary_weapon_type(src), MODULE_SECONDARY)
	if(CHECK_BITFIELD(flags_armored, HAS_MAP_VARIANTS))
		switch(SSmapping.configs[GROUND_MAP].armor_style)
			if(MAP_ARMOR_STYLE_JUNGLE)
				icon_state += "_jungle"
			if(MAP_ARMOR_STYLE_ICE)
				icon_state += "_snow"
			if(MAP_ARMOR_STYLE_PRISON)
				icon_state += "_urban"
			if(MAP_ARMOR_STYLE_DESERT)
				icon_state += "_desert"
	GLOB.tank_list += src

///Proc to get the location of the door of the vehicle
/obj/vehicle/armored/proc/get_door_location(atom/user)
	if(user.loc == get_step(src,turn(dir, 180)))
		return TRUE
	return FALSE

/obj/vehicle/armored/multitile/Initialize()
	. = ..()
	linked_hitbox = new hitbox_type(loc)
	linked_hitbox.root = src

/obj/vehicle/armored/Destroy()
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
	QDEL_NULL(linked_hitbox)
	return ..()

/*
\\\\\\\\GENERIC PROCS////////
Move and icon tuff.
*/

/obj/vehicle/armored/Move()
	. = ..()
	if(COOLDOWN_CHECK(src, drive_sound_cooldown))
		return
	COOLDOWN_START(src, drive_sound_cooldown, drive_sound_cooldown_length)
	playsound(src, 'sound/ambience/tank_driving.ogg', vol = 20, sound_range = 30)

/obj/vehicle/armored/multitile/Move()
	. = ..()
	linked_hitbox.forceMove(loc)

/obj/vehicle/armored/update_icon()
	. = ..()
	if(!damage_overlay)
		return
	switch(PERCENT(obj_integrity / max_integrity))
		if(0 to 29)
			damage_overlay.icon_state = "damage_veryhigh"
		if(29 to 59)
			damage_overlay.icon_state = "damage_high"
		if(59 to 70)
			damage_overlay.icon_state = "damage_medium"
		if(70 to 90)
			damage_overlay.icon_state = "damage_small"
		else
			damage_overlay.icon_state = "null"


/*
\\\\\\\\TANK MOVEMENT////////
Tank relaymove(), related checks and subsequent bumping.
*/

/obj/vehicle/armored/Bump(atom/A, yes)
	. = ..()
	A.vehicle_collision(src, get_dir(src, A), get_turf(loc), get_turf(loc), pilot)


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
Theres copied parts here to avoid proc overhead, only the actual enteringturfs calculations are changed
Yes it shitty but thats what you get with byond
Read the file documentation to understand why this is this way
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
		for(var/atom/movable/O as() in T.contents)
			if(O.CanPass(src) == TRUE)	// Then check for obstacles to crush
				continue
			Bump(O) //manually call bump for accuracy
			canstep = FALSE
	if(canstep == TRUE)
		return step(src, direction)
	return FALSE
	/////////////////////////////////

/obj/hitbox/CanAllowThrough(atom/movable/mover, turf/target)
	if(mover == root)//Bypass your own hitbox
		return TRUE
	return ..()

/*
2x2 vehicle relaymove
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
	setDir(direction)//we can move, so lets start by pointing in that direction
	///////////////////////////
	var/turf/centerturf = get_step(src, direction)
	var/list/enteringturfs = list(centerturf)
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
	////////////////////////////////////
	var/canstep = TRUE
	for(var/turf/T as() in enteringturfs)	//No break because we want to crush all the turfs before we start trying to move
		if(T.Enter(src) == FALSE)	//Check if we can cross the turf first/bump the turf
			canstep = FALSE
		for(var/atom/movable/O as() in T.contents)
			if(O.CanPass(src) == TRUE)	// Then check for obstacles to crush
				continue
			Bump(O) //manually call bump for accuracy
			canstep = FALSE
	if(canstep == TRUE)
		return step(src, direction)
	return FALSE
	///////////////////////////////////////

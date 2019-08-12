/*
tankS BY KMC
THIS IS LIKE REGULAR CM tank BUT IT'S LESS SHIT
WHOEVER MADE CM TANKS: YOU ARE A BAD CODER!!!!!
*/

//generic component stuff

#define POSITION_DRIVER "Driver"
#define POSITION_GUNNER "Gunner"
#define POSITION_PASSENGER "Passenger"


/obj/item/tank_weapon //These are really just proof of concept weapons. You'll probably want to adapt them to use the hardpoint crap that CM has.
	name = "TGS 4 main tank cannon"
	desc = "A gun that works about 50% of the time, but at least it's open source! It fires tank shells."
	icon = 'icons/obj/hardpoint_modules.dmi'
	icon_state = "glauncher"
	var/obj/vehicle/tank/owner
	var/list/fire_sounds = list('sound/weapons/tank_cannon_fire1.ogg', 'sound/weapons/tank_cannon_fire2.ogg')
	var/obj/item/ammo_magazine/ammo
	var/default_ammo = /obj/item/ammo_magazine/tank/ltb_cannon //What do we start with?
	var/list/accepted_ammo = list( //Alternative ammo types that we'll accept. The default ammo is in this by default
		/obj/item/ammo_magazine/tank/tank_glauncher
	) 
	var/fire_delay
	var/cooldown = 6 SECONDS //6 second weapons cooldown
	var/lastfired = 0 //When were we last shot?
	var/range_safety_check = 3 //Stops marines form shooting their own tank. If your gun is geared for explosives, 3 tiles is good. Minigun and APC cannon don't have this.

/obj/item/tank_weapon/Initialize()
	. = ..()
	ammo = new default_ammo(src)
	accepted_ammo += default_ammo

/obj/item/tank_weapon/secondary_weapon
	name = "TGS 3 XENOCRUSHER tank machine gun"
	desc = "A much better gun that shits out bullets at ridiculous speeds, don't get in its way!"
	icon_state = "m56_cupola"
	fire_sounds = list('sound/weapons/tank_minigun_loop.ogg')
	default_ammo = /obj/item/ammo_magazine/tank/ltaaap_minigun
	accepted_ammo = list(
		/obj/item/ammo_magazine/tank/towlauncher,
		/obj/item/ammo_magazine/tank/m56_cupola,
		/obj/item/ammo_magazine/tank/flamer,
		/obj/item/ammo_magazine/tank/tank_slauncher
	)
	cooldown = 0.3 SECONDS //Minimal cooldown
	range_safety_check = 0

/obj/item/tank_weapon/apc_cannon
	name = "MKV-7 utility payload launcher"
	desc = "A double barrelled cannon which can rapidly deploy utility packages to the battlefield."
	icon_state = "APC uninstalled dualcannon" // TODO: Err?
	fire_sounds = list('sound/weapons/gun_shotgun_automatic.ogg', 'sound/weapons/gun_shotgun_light.ogg', 'sound/weapons/gun_shotgun_heavy.ogg')
	default_ammo = /obj/item/ammo_magazine/tank/tank_slauncher
	accepted_ammo = list(
		/obj/item/ammo_magazine/tank/towlauncher, 
		/obj/item/ammo_magazine/tank/flamer,
		/obj/item/ammo_magazine/tank/tank_glauncher
	)
	cooldown = 0.7 SECONDS //Minimal cooldown

/obj/item/tank_weapon/proc/fire(atom/T,mob/user)
	if(!can_fire(T))
		return FALSE
	lastfired = world.time
	var/obj/item/projectile/P = new
	P.generate_bullet(new ammo.default_ammo)
	log_combat(user, T, "fired the [src].")
	P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)

	// TODO: Fix this config?!
	// if(!CONFIG_GET(flag/tank_mouth_noise))
	// 	playsound(get_turf(owner), pick(fire_sounds), 60, 1)

	ammo.current_rounds--
	return TRUE

/obj/item/tank_weapon/proc/can_fire(turf/T)
	if(world.time < lastfired + cooldown)
		return FALSE
	if(get_dist(T, src) <= range_safety_check)
		to_chat(owner.gunner, "<span class='warning'>Firing [src] here would damage your vehicle!</span>")
		return FALSE
	if(ammo.current_rounds <= 0)
		playsound(get_turf(src), 'sound/weapons/gun_empty.ogg', 100, 1)
		return FALSE
	return TRUE

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// As standard, tank subtypes come with a primary and secondary, the primary is its big tank gun which fires explosive rounds, and its secondary is a rapid firing minigun. //
// You must manually set the offsets for your tank subtypes so that they move correctly, VV them in game to find the perfect values											//
// You can set max_passengers to something different (eg, 2 for a jeep) if you don't want loads of marines to pile in														//
// I have set the layer of this tank high so that it layers over lights. This is an issue with multi-tile sprites in byond 													//
// If you want to make a vehicle which is larger than 48x48 you'll need to make an underlay. See the APC for reference, but this makes seperate parts of the tank layer		//
// -differently so that you can get the effect of a large multi-tile vehicle without actually needing any multitile code.													//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/vehicle/tank
	name = "MK-1 'friendly fire' prototype tank"
	desc = "A gigantic wall of metal designed for maximum Xeno destruction. Click it with an open hand to enter as a pilot or a gunner."
	icon = 'icons/obj/tank.dmi'
	icon_state = "tank"
	layer = ABOVE_MOB_LAYER
	anchored = FALSE
	can_buckle = FALSE
	req_access = list(ACCESS_MARINE_TANK)
	move_delay = 0.8 SECONDS
	obj_integrity = 600 //Friendly fire resistant
	max_integrity = 600
	anchored = TRUE //No bumping / pulling the tank
	demolish_on_ram = TRUE
	pixel_x = -48
	pixel_y = -48
	//Who's driving the tank
	var/turret_icon = 'icons/obj/tank_gun.dmi'
	var/turret_icon_state = "turret"
	var/obj/effect/damage_overlay
	var/mob/living/carbon/human/pilot
	var/mob/living/carbon/human/gunner
	var/list/operators = list() //Who's in this tank? Prevents you from entering the tank again
	//Health and combat shit
	var/obj/turret_overlay/turret_overlay //Allows for independantly swivelling guns, wow!
	var/obj/item/tank_weapon/primary_weapon //What we use to shoot big shells
	var/obj/item/tank_weapon/secondary_weapon //What we use to shoot mini shells ((rapidfire xenocrusher 6000))
	var/primary_weapon_type = /obj/item/tank_weapon //What kind of tank weaponry we start with. Defaults to a tank gun and a small minigun as standard.
	var/secondary_weapon_type = /obj/item/tank_weapon/secondary_weapon
	var/primary_weapon_dir = null //So that the guns swivel independantly
	var/secondary_weapon_dir = null
	var/atom/firing_target = null //Shooting code, at whom are we firing?
	var/firing_primary_weapon = FALSE
	var/firing_secondary_weapon = FALSE
	var/last_drive_sound = 0 //Engine noises.
	var/list/passengers = list() //People who are in the tank without gunning / driving. This allows for things like jeeps and APCs in future
	var/max_passengers = 5 //This seems sane to me, change if you don't agree.
	var/lights_on = FALSE //Tanks start with lights off
	var/allow_diagonal_movement = FALSE //For smaller vehicles like a jeep you may want this. This forbids / allows you to move diagonally in these vehicles
	var/has_underlay = FALSE //For larger vehicles that need seperately overlaying parts.
	var/obj/effect/underlay = null

/obj/vehicle/tank/tiny //SQUEEEE
	name = "Mk-4 'shortstreet' tank"
	desc = "An adorable chunk of metal with an alarming amount of firepower designed to crush, immolate, destroy and maim anything that nanotrasen wants it to. This model contains advanced bluespace technology which allows a tardis like amount of room on the inside"
	icon = 'icons/obj/tinytank.dmi'
	turret_icon = 'icons/obj/tinytank_gun.dmi'
	icon_state = "tank"
	pixel_x = -16 //Stops marines from treading on it...d'aww
	pixel_y = -8
	max_passengers = 0 //Bluespace's one hell of a drug.

/obj/vehicle/tank/apc/mini //SQUEEEE
	name = "M157 Replica Armoured Personnel Carrier"
	desc = "A miniaturized replica of a popular personnel carrier. For ages 5 and up."
	icon = 'icons/obj/tinytank.dmi'
	turret_icon = 'icons/obj/tinytank_gun.dmi'
	turret_icon_state = "apc_turret"
	icon_state = "apc"
	move_delay = 0.1 SECONDS
	pixel_x = -16
	pixel_y = -8
	max_passengers = 1
	primary_weapon_type = null
	secondary_weapon_type = null

/obj/vehicle/tank/apc //Big boy troop carrier
	name = "M557 Armoured Personnel Carrier"
	desc = "A heavily armoured vehicle with light armaments designed to ferry troops around the battle field, or assist with search and rescue (SAR) operations."
	icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon_state = "apc_turret"
	icon_state = "apc"
	move_delay = 0.35 SECONDS //Bulky, but not as slow as the tank
	pixel_x = -32
	pixel_y = -20
	max_passengers = 3 //Enough to ferry wounded men to and fro without being stupidly tardis like. Seats 5 total
	primary_weapon_type = /obj/item/tank_weapon/apc_cannon //Only has a utility launcher, no offense as standard.
	secondary_weapon_type = null
	has_underlay = TRUE

/obj/vehicle/tank/medium //Bigass tank designed to cut through enemy lines
	name = "M74A4 'Baker Street' Heavy Tank"
	desc = "A metal behemoth which is designed to cleave through enemy lines. It comes pre installed with a main tank cannon capable of deploying heavy payloads, as well as a minigun which can tear through multiple targets in quick succession."
	icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon = 'icons/obj/medium_vehicles.dmi'
	turret_icon_state = "tank_turret"
	icon_state = "tank"
	pixel_x = -32
	pixel_y = -20
	obj_integrity = 750 //Heavily armoured. Will take a lot of friendly fire to kill it.
	max_integrity = 750
	max_passengers = 1 //Seats 3 total. It's designed to cut through enemy lines with 1 gunner, 1 pilot and 1 commander to oversee operations
	has_underlay = TRUE

/obj/vehicle/tank/examine(mob/user)
	. = ..()
	to_chat(user, "<b><span class='notice'>To fire its main cannon, <i>ctrl</i> click a tile.</b></span>")
	to_chat(user, "<b><span class='notice'>To fire its secondary weapon, click a tile.</b></span>")
	to_chat(user, "<b><span class='notice'>To forcibly remove someone from it, use grab intent.</b></span>")
	to_chat(user, "<i><span class='notice'>It's currently holding [passengers.len] / [max_passengers] passengers (excluding its gunner and pilot).</i></span>")

/obj/turret_overlay
	name = "Tank gun turret"
	desc = "The shooty bit on a tank."
	icon = 'icons/obj/tank_gun.dmi'
	icon_state = "turret"
	layer = ABOVE_ALL_MOB_LAYER
	animate_movement = TRUE //So it doesnt just ping back and forth and look all stupid
	mouse_opacity = FALSE //It's an overlay

/obj/vehicle/tank/Initialize()
	. = ..()
	turret_overlay = new()
	turret_overlay.icon = turret_icon
	turret_overlay.icon_state = turret_icon_state
	update_icon()
	if(primary_weapon_type)
		primary_weapon = new primary_weapon_type(src) //Make our guns
		primary_weapon.owner = src
	if(secondary_weapon_type)
		secondary_weapon = new secondary_weapon_type(src)
		secondary_weapon.owner = src
	GLOB.tank_list += src

/obj/vehicle/tank/Destroy()
	obj_integrity = 10000 //Prevents this from being called over and over and over while we chuck the mobs out
	remove_mobs()
	QDEL_NULL(turret_overlay)
	QDEL_NULL(primary_weapon)
	QDEL_NULL(secondary_weapon)
	playsound(get_turf(src), 'sound/weapons/tank_cannon_fire1.ogg', 100, 1) //Explosion sound
	return ..()

/obj/vehicle/tank/proc/remove_mobs()
	for(var/x in contents) //Yeet the occupants out so they arent deleted
		if(ismob(x))
			var/mob/living/mob = x
			var/turf/T = get_turf(pick(orange(src,5)))
			mob.forceMove(get_turf(src))
			mob.SpinAnimation(1,1)
			mob.throw_at(T, 3)
			mob.apply_effect(6, STUN,)
			mob.apply_effect(6, WEAKEN)
			mob.apply_effect(6, STUTTER)
			to_chat(mob, "<span class='warning'>You violently dive out of [src] as it explodes behind you!</span>")

/obj/vehicle/tank/Move()
	. = ..()
	update_icon()
	if(world.time < last_drive_sound + 2 SECONDS)
		return
	last_drive_sound = world.time
	playsound(src, 'sound/ambience/tank_driving.ogg', vol = 20, sound_range = 30)

/obj/vehicle/tank/update_icon() //To show damage, gun firing, whatever. We need to re apply the gun turret overlay.
	if(!turret_overlay)
		return
	handle_overlays()

/obj/vehicle/tank/proc/handle_overlays() //This code is vehicle specific and handles offsets + overlays for the tank's gun. Please change this accordingly.
	if(primary_weapon_dir)
		turret_overlay.setDir(primary_weapon_dir)
		turret_overlay.pixel_x = 0
	vis_contents += turret_overlay
	if(!damage_overlay)
		damage_overlay = new(src)
	cut_overlays()
	if(has_underlay && !underlay)
		underlay = new(src)
		underlay.icon = icon //Applies a damage effect
		underlay.icon_state = "[icon_state]_underlay"
		underlay.layer = OBJ_LAYER
	damage_overlay.icon = icon //Applies a damage effect
	damage_overlay.icon_state = null
	damage_overlay.layer = layer+0.1 //So it's always above the sprite
	switch(PERCENT(obj_integrity / max_integrity))
		if(0 to 29)
			damage_overlay.icon_state = "damage_major"
		if(30 to 59)
			damage_overlay.icon_state = "damage_medium"
		if(60 to 70)
			damage_overlay.icon_state = "damage_minor_medium"
		if(71 to 90)
			damage_overlay.icon_state = "damage_minor"
	add_overlay(damage_overlay)
	add_overlay(underlay)

/obj/vehicle/tank/attack_hand(mob/living/user)
	if(!ishuman(user)) //Aliens can't get in a tank...as hilarious as that would be
		return
	if(user.a_intent == INTENT_GRAB) //Grab the tank to rip people out of it. Use this if someone dies in it.
		if(!allowed(user))
			to_chat(user, "<span class='warning'>[src]'s hatch won't budge!.</span>")
			return FALSE
		var/list/mobs = list() //Mobs inside src
		for(var/x in contents)
			if(ismob(x))
				mobs += x
		if(!mobs.len)
			to_chat(user, "<span class='warning'>No one is currently occupying [src]!.</span>")
			return
		var/input
		input = input(user, "Who do you want to forcibly remove from [src]?", "Your violent tendencies", input) as null|anything in mobs
		var/mob/living/target = input
		user.visible_message("<span class='warning'>[user] starts to force their way through [src]'s hatch!.</span>",
		"<span class='notice'>You start to force your way through [src]'s hatch to grab [target].</span>")
		var/time = 6 SECONDS - (1 SECONDS * user.mind.cm_skills.large_vehicle)
		if(do_after(user, time, TRUE, src, BUSY_ICON_BUILD))
			exit_tank(target)
			target.SpinAnimation(1,1)
			target.throw_at(user, 3)
			target.apply_effect(6, STUN,)
			target.apply_effect(6, WEAKEN)
			target.apply_effect(6, STUTTER)
			user.visible_message("<span class='warning'>[user] rips [target] out of [src] and bodyslams them!.</span>",
			"<span class='notice'>You rip [target] out of [src] and bodyslam them!.</span>")
			playsound(get_turf(src), 'sound/effects/throw.ogg', 100, 1)
			return
	if(user in operators)
		exit_tank(user)
		return
	if(user.pulling && ismob(user.pulling)) //If theyre pulling someone and click the tank, load that person into a passenger seat first. This allows for medics to put marines into the tank / apc safely
		if(passengers.len >= max_passengers) //We have a few slots for people to enter as passengers without gunning / driving.
			to_chat(user, "[user.pulling] won't fit in because [src] is already full!")
			return

		user.visible_message("<span class='notice'>[user] starts to load [user.pulling] into [src].</span>",
		"<span class='notice'>You start to load [user.pulling] into [src].</span>")
		var/time = 10 SECONDS - (2 SECONDS * user.mind.cm_skills.large_vehicle)
		if(do_after(user, time, TRUE, src, BUSY_ICON_BUILD))
			return enter(user.pulling, POSITION_PASSENGER)
	var/position = alert("What seat would you like to enter?.", name, POSITION_DRIVER, POSITION_GUNNER, POSITION_PASSENGER, "Cancel") //God I wish I had radials to work with
	if(!position || position == "Cancel")
		return
	if(pilot && position == POSITION_DRIVER)
		to_chat(user, "[pilot] is already piloting [src]!")
		return
	if(gunner && position == POSITION_GUNNER)
		to_chat(user, "[gunner] is already gunning [src]!")
		return
	if(passengers.len >= max_passengers && position == POSITION_PASSENGER) //We have a few slots for people to enter as passengers without gunning / driving.
		to_chat(user, "[src] is full! There isn't enough space for you")
		return
	if(!can_enter(user, position)) //OWO can they enter us????
		return 
	to_chat(user, "You climb into [src] as a [position]!")
	enter(user, position) //Yeah i could do this with a define, but this way we're not using multiple things

/obj/vehicle/tank/proc/can_enter(mob/living/carbon/M, position) //NO BENOS ALLOWED
	if(!istype(M) || in_range(src, M))
		return
	if(!M.IsAdvancedToolUser())
		to_chat(M, "<span class='warning'>You don't have the dexterity to drive [src]!</span>")
		return FALSE
	if(!allowed(M) && position != POSITION_PASSENGER)
		to_chat(M, "<span class='warning'>Access denied.</span>")
		return FALSE
	var/obj/item/offhand = M.get_inactive_held_item()
	if(offhand && !(offhand.flags_item & (NODROP|DELONDROP)))
		to_chat(M, "<span class='warning'>You need your hands free to climb into [src].</span>")
		return FALSE
	if(M.mind?.cm_skills?.large_vehicle < SKILL_LARGE_VEHICLE_TRAINED)
		M.visible_message("<span class='notice'>[M] fumbles around figuring out how to get into the [src].</span>",
		"<span class='notice'>You fumble around figuring out how to get into [src].</span>")
	var/time = 10 SECONDS - (2 SECONDS * M.mind.cm_skills.large_vehicle)
	if(do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
		return TRUE


/obj/vehicle/tank/proc/enter(mob/user, position) //By this point, we've checked that the seats are actually empty, so we won't need to do that again HOPEFULLY
	user.forceMove(src)
	operators += user
	switch(position)
		if(POSITION_DRIVER)
			pilot = user
		if(POSITION_GUNNER)
			gunner = user
		if(POSITION_PASSENGER)
			passengers += user

/obj/vehicle/tank/proc/remove_all_players()
	for(var/M in operators)
		exit_tank(M)

/obj/vehicle/tank/proc/exit_tank(mob/user) //By this point, we've checked that the seats are actually empty, so we won't need to do that again HOPEFULLY
	if(user == pilot)
		user.forceMove(get_turf(src))
		pilot = null
		operators -= user
	else if(user == gunner)
		user.forceMove(get_turf(src))
		gunner = null
		operators -= user
	else if(user in passengers)
		user.forceMove(get_turf(src))
		passengers -= user
		operators -= user
	to_chat(user, "<span class ='notice'>You hop out of [src] and slam its hatch shut behind you.</span>")

/obj/vehicle/tank/relaymove(mob/user, direction)
	if(world.time < last_move_time + move_delay)
		return
	last_move_time = world.time
	if(!allow_diagonal_movement && direction in GLOB.diagonals)
		return
	if(user.incapacitated() || user != pilot)
		to_chat(user, "<span class ='notice'>You can't reach the gas pedal from down here, maybe try manning the driver's seat?</span>")
		return FALSE
	. = step(src, direction)
	update_icon()

/obj/vehicle/tank/Bump(atom/A, yes)
	. = ..()
	var/facing = get_dir(src, A)
	var/turf/temp = get_turf(loc)
	var/turf/T = get_turf(loc)
	A.tank_collision(src, facing, T, temp)
	if(isliving(A) && pilot)
		log_attack("[pilot] drove over [A] with [src]")

//Combat, tank guns, all that fun stuff
/obj/vehicle/tank/proc/onMouseDown(atom/A, mob/user, params)
	if(user != gunner) //Only the gunner can fire!
		return
	var/list/modifiers = params2list(params) //If they're CTRL clicking, for example, let's not have them accidentally shoot.
	if(modifiers["shift"])
		return
	if(modifiers["ctrl"])
		handle_fire_main(A) //CTRL click to fire your big tank gun you can change any of these parameters here to hotkey for other shit :)
		return
	if(modifiers["middle"])
		return
	if(modifiers["alt"])
		return
	handle_fire(A)

/obj/vehicle/tank/proc/handle_fire(atom/A)
	if(!secondary_weapon && gunner)
		to_chat(gunner, "[src]'s secondary weapon hardpoint spins pathetically. Maybe you should install a secondary weapon on this tank?")
		return FALSE
	firing_target = A
	playsound(get_turf(src), 'sound/weapons/tank_minigun_start.ogg', 60, 1)
	firing_secondary_weapon = TRUE
	START_PROCESSING(SSfastprocess, src)

/obj/vehicle/tank/proc/handle_fire_main(atom/A) //This is used to shoot your big ass tank cannon, rather than your small MG
	if(!primary_weapon && gunner)
		to_chat(gunner, "You look at the stump where [src]'s tank barrel should be and sigh.")
		return FALSE
	swivel_gun(A) //Special FX, makes the tank cannon visibly swivel round to aim at the target.
	firing_target = A
	firing_primary_weapon = TRUE
	START_PROCESSING(SSfastprocess, src)

/obj/vehicle/tank/proc/swivel_gun(atom/A)
	var/new_weapon_dir = get_dir(src, A) //Check that we're not already facing this way to avoid a double swivel when you fire.
	if(new_weapon_dir == primary_weapon_dir)
		return FALSE
	if(world.time > lastsound + 2 SECONDS) //Slight cooldown to avoid spam
		visible_message("<span class='danger'>[src] swings its turret round!</span>")
		playsound(src, 'sound/effects/tankswivel.ogg', 80,1)
		lastsound = world.time
		primary_weapon_dir = new_weapon_dir
		return TRUE

/obj/vehicle/tank/process()
	if(firing_primary_weapon && firing_target)
		if(primary_weapon.fire(firing_target, gunner))
			primary_weapon_dir = get_dir(src, firing_target) //For those instances when you've swivelled your gun round a lot when your main gun wasn't ready to fire. This ensures the gun always faces the desired target.
			update_icon()
		else
			stop_firing()
	if(firing_secondary_weapon)
		if(secondary_weapon.fire(firing_target, gunner))
			secondary_weapon_dir = get_dir(src, firing_target) //Set the gun dir
			update_icon()

/obj/vehicle/tank/proc/onMouseUp(atom/A, mob/user)
	stop_firing()

/obj/vehicle/tank/proc/stop_firing()
	firing_target = null
	firing_primary_weapon = FALSE
	firing_secondary_weapon = FALSE
	update_icon(icon_state, "turret", "secondary_weapon") //Stop firing animation
	STOP_PROCESSING(SSfastprocess,src)

/*

	\\\\\WARNING////
--ENTERING SHITCODE ZONE--
	/////WARNING\\\\


Tank interaction procs copied from tank.dm!

This handles stuff like swapping seats, pulling people out of the tank, all that stuff.


*/

/obj/vehicle/tank/verb/exit_tank_verb()
	set name = "Exit vehicle"
	set category = "Vehicle"
	set src in view(0)
	if(usr)
		exit_tank(usr)

/obj/vehicle/tank/verb/toggle_light()
	set name = "Toggle floodlights"
	set category = "Vehicle"
	set src in view(0)
	if(lights_on)
		to_chat(usr, "<span class='notice'>You turn off [src]'s floodlights.</span>")
		set_light(0)
		lights_on = FALSE
	else
		to_chat(usr, "<span class='notice'>You turn [src]'s floodlights on.</span>")
		set_light(5)
		lights_on = TRUE


/obj/vehicle/tank/verb/switch_seats()
	set name = "Swap Seats"
	set category = "Vehicle"
	set src in view(0)

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

/obj/vehicle/tank/proc/seat_switched(wannabe_trucker, mob/living/user)

	var/player = wannabe_trucker ? gunner : pilot
	var/challenger = wannabe_trucker ? pilot : gunner
	if(QDELETED(user) || user.incapacitated() || player != user)
		return

	if(challenger)
		to_chat(usr, "<span class='notice'>Someone beat you to the other seat!</span>")
		return

	to_chat(usr, "<span class='notice'>You man up the [wannabe_trucker ? "driver" : "gunner"]'s seat.</span>")

	pilot = wannabe_trucker ? user : null
	gunner = wannabe_trucker ? null : user

/obj/vehicle/tank/proc/handle_harm_attack(mob/living/M, mob/living/occupant)
	if(M.resting || M.buckled || M.incapacitated())
		return FALSE
	if(!occupant)
		to_chat(M, "<span class='warning'>There is no one on that seat.</span>")
		return
	var/turf/hatch = get_turf(src)
	M.visible_message("<span class='warning'>[M] starts pulling [occupant] out of \the [src].</span>",
	"<span class='warning'>You start pulling [occupant] out of \the [src]. (this will take a while...)</span>", null, 6)
	var/fumbling_time = 20 SECONDS
	if(M.mind?.cm_skills?.police)
		fumbling_time -= 2 SECONDS * M.mind.cm_skills.police
	if(M.mind?.cm_skills?.large_vehicle)
		fumbling_time -= 2 SECONDS * M.mind.cm_skills.large_vehicle
	if(!do_after(M, fumbling_time, TRUE, 5, BUSY_ICON_HOSTILE) || !M.Adjacent(hatch))
		return
	exit_tank(occupant)
	M.visible_message("<span class='warning'>[M] forcibly pulls [occupant] out of [src].</span>",
					"<span class='notice'>you forcibly pull [occupant] out of [src].</span>", null, 6)
	occupant.set_knocked_down(4)

/obj/vehicle/tank/Bumped(atom/A) //Don't ..() because then you can shove the tank into a wall.
	if(isliving(A))
		if(istype(A, /mob/living/carbon/xenomorph/crusher))
			var/mob/living/carbon/xenomorph/crusher/C = A
			take_damage(C.charge_speed * CRUSHER_CHARGE_TANK_MULTI)
		return
	else
		. = ..()

/obj/vehicle/tank/bullet_act(obj/item/projectile/Proj)
	. = ..()
	update_icon()

/obj/vehicle/tank/take_damage(amount)
	. = ..()
	update_icon() //Update damage overlays

#undef POSITION_DRIVER
#undef POSITION_PASSENGER
#undef POSITION_GUNNER
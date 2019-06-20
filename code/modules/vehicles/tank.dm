/*
tankS BY KMC
THIS IS LIKE REGULAR CM tank BUT IT'S LESS SHIT
WHOEVER MADE CM TANKS: YOU ARE A BAD CODER!!!!!
*/

//generic component stuff

/obj/item/tank_weapon //These are really just proof of concept weapons. You'll probably want to adapt them to use the hardpoint crap that CM has.
	name = "TGS 4 main tank cannon"
	desc = "A gun that works about 50% of the time, but at least it's open source! It fires tank shells."
	icon = 'icons/obj/hardpoint_modules.dmi'
	icon_state = "glauncher"
	var/obj/item/ammo_magazine/ammo
	var/obj/vehicle/tank/owner
	var/list/fire_sounds = list('sound/weapons/tank_cannon_fire1.ogg', 'sound/weapons/tank_cannon_fire2.ogg')
	var/default_ammo = /obj/item/ammo_magazine/tank/ltb_cannon //What do we start with?
	var/list/accepted_ammo = list(/obj/item/ammo_magazine/tank/tank_glauncher) //Alternative ammo types that we'll accept. The default ammo is in this by default
	var/fire_delay
	var/cooldown = 6 SECONDS //6 second weapons cooldown
	var/lastfired = 0 //When were we last shot?

/obj/item/tank_weapon/Initialize()
	. = ..()
	ammo = new default_ammo(src)
	accepted_ammo += default_ammo

/obj/item/tank_weapon/secondary_weapon
	name = "TGS 3 XENOCRUSHER tank machine gun"
	desc = "A much better gun that shits out bullets at ridiculous speeds, don't get in its way!"
	icon = 'icons/obj/hardpoint_modules.dmi'
	icon_state = "m56_cupola"
	default_ammo = /obj/item/ammo_magazine/tank/ltaaap_minigun
	fire_sounds = list('sound/weapons/tank_minigun_loop.ogg')
	cooldown = 0.3 SECONDS //Minimal cooldown
	accepted_ammo = list(/obj/item/ammo_magazine/tank/towlauncher,/obj/item/ammo_magazine/tank/m56_cupola,/obj/item/ammo_magazine/tank/flamer,/obj/item/ammo_magazine/tank/tank_slauncher)

/obj/item/tank_weapon/proc/fire(atom/T,mob/user)
	if(!can_fire(T))
		return FALSE
	if(world.time < lastfired + cooldown)
		return FALSE
	if(ammo.current_rounds <= 0)
		playsound(get_turf(src), 'sound/weapons/gun_empty.ogg', 100, 1)
		return FALSE
	lastfired = world.time
	var/obj/item/projectile/P = new
	P.generate_bullet(new ammo.default_ammo)
	log_combat(user, T, "fired the [src].")
	P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
	if(!CONFIG_GET(flag/tank_mouth_noise))
		playsound(get_turf(owner), pick(fire_sounds), 60, 1)
	ammo.current_rounds--
	return TRUE

/obj/item/tank_weapon/proc/can_fire(var/turf/T)
	if(get_dist(T, src) <= 3)
		to_chat(owner.gunner, "Firing your main gun here could damage the tank!")
		return FALSE
	return TRUE

/obj/item/tank_weapon/secondary_weapon/can_fire(var/turf/T)
	return TRUE //No loc check here

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// As standard, tank subtypes come with a primary and secondary, the primary is its big tank gun which fires explosive rounds, and its secondary is a rapid firing minigun. //
// You must manually set the offsets for your tank subtypes so that they move correctly, VV them in game to find the perfect values											//
// You can set max_passengers to something different (eg, 2 for a jeep) if you don't want loads of marines to pile in														//
// I have set the layer of this tank high so that it layers over lights. This is an issue with multi-tile sprites in byond 													//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/vehicle/tank
	name = "MK-1 'friendly fire' prototype tank"
	desc = "A gigantic wall of metal designed for maximum Xeno destruction. Click it with an open hand to enter as a pilot or a gunner."
	icon = 'icons/obj/tank.dmi'
	icon_state = "tank"
	layer = OBJ_LAYER
	anchored = FALSE
	can_buckle = FALSE
	req_access = list(ACCESS_MARINE_TANK)
	move_delay = 0.4 SECONDS
	obj_integrity = 600
	max_integrity = 600
	anchored = TRUE //No bumping / pulling the tank
	demolish_on_ram = TRUE
	pixel_x = -48
	pixel_y = -48
	//Who's driving the tank
	var/turret_icon = 'icons/obj/tank_gun.dmi'
	var/mob/living/carbon/human/pilot
	var/mob/living/carbon/human/gunner
	var/list/operators = list() //Who's in this tank? Prevents you from entering the tank again
	//Health and combat shit
	var/obj/turret_overlay/turret_overlay //Allows for independantly swivelling guns, wow!
	var/obj/item/tank_weapon/primary_weapon //What we use to shoot big shells
	var/obj/item/tank_weapon/secondary_weapon/secondary_weapon //What we use to shoot mini shells ((rapidfire xenocrusher 6000))
	var/primary_weapon_dir = null //So that the guns swivel independantly
	var/secondary_weapon_dir = null
	var/atom/firing_target = null //Shooting code, at whom are we firing?
	var/firing_primary_weapon = FALSE
	var/firing_secondary_weapon = FALSE
	var/last_drive_sound = 0 //Engine noises.
	var/list/passengers = list() //People who are in the tank without gunning / driving. This allows for things like jeeps and APCs in future
	var/max_passengers = 5 //This seems sane to me, change if you don't agree.


/obj/vehicle/tank/tiny //SQUEEEE
	name = "Mk-4 'pint pot' tank"
	desc = "An adorable chunk of metal with an alarming amount of firepower designed to crush, immolate, destroy and maim anything that nanotrasen wants it to. This model contains advanced bluespace technology which allows a tardis like amount of room on the inside"
	icon = 'icons/obj/tinytank.dmi'
	turret_icon = 'icons/obj/tinytank_gun.dmi'
	icon_state = "tank"
	pixel_x = -15 //Stops marines from treading on it...d'aww
	pixel_y = 0
	max_passengers = 3 //Bluespace's one hell of a drug.

/obj/vehicle/tank/examine(mob/user)
	. = ..()
	to_chat(user, "<b>To fire its main cannon, <i>ctrl</i> click a tile</b>")
	to_chat(user, "<b>To fire its secondary_weapon, click a tile</b>")
	to_chat(user, "<i>It's currently holding [passengers.len] / [max_passengers] passengers</i>")

/obj/turret_overlay
	name = "Tank gun turret"
	desc = "The shooty bit on a tank."
	icon = 'icons/obj/tank_gun.dmi'
	icon_state = "turret"
	layer = ABOVE_MOB_LAYER
	animate_movement = TRUE //So it doesnt just ping back and forth and look all stupid
	mouse_opacity = FALSE //It's an overlay

/obj/vehicle/tank/Initialize()
	. = ..()
	turret_overlay = new()
	turret_overlay.icon = turret_icon
	update_icon()
	primary_weapon = new(src) //Make our guns
	secondary_weapon = new(src)
	primary_weapon.owner = src
	secondary_weapon.owner = src
	GLOB.tank_list += src

/obj/vehicle/tank/Destroy()
	qdel(turret_overlay)
	qdel(primary_weapon)
	qdel(secondary_weapon)
	. = ..()

/obj/vehicle/tank/Move()
	. = ..()
	update_icon()
	if(world.time > last_drive_sound + 2 SECONDS)
		playsound(src, 'sound/ambience/tank_driving.ogg', vol = 20, sound_range = 30)
		last_drive_sound = world.time

/obj/vehicle/tank/update_icon() //To show damage, gun firing, whatever. We need to re apply the gun turret overlay.
	vis_contents = null
	if(!turret_overlay)
		return
	handle_overlays()

/obj/vehicle/tank/proc/handle_overlays() //This code is vehicle specific and handles offsets + overlays for the tank's gun. Please change this accordingly.
	if(primary_weapon_dir)
		turret_overlay.setDir(primary_weapon_dir)
		turret_overlay.pixel_x = 0
	vis_contents += turret_overlay

/obj/vehicle/tank/attack_hand(mob/user)
	if(user in operators)
		exit_tank(user)
		return
	if(pilot && gunner)
		to_chat(user, "You are unable to enter [src] because all of its seats are occupied!")
		return ..()
	var/position = alert("What seat would you like to enter?.",name,"pilot","gunner", "passenger") //God I wish I had radials to work with
	if(!position)
		return
	if(pilot && position == "pilot")
		to_chat(user, "[pilot] is already controlling [src]!")
		return
	if(gunner && position == "gunner")
		to_chat(user, "[gunner] is already controlling [src]!")
		return
	if(passengers.len >= max_passengers && position == "passenger") //We have a few slots for people to enter as passengers without gunning / driving.
		to_chat(user, "[src] is already full!")
		return
	if(can_enter(user)) //OWO can they enter us????
		to_chat(user, "You climb into [src] as a [position]!")
		return enter(user, position) //Yeah i could do this with a define, but this way we're not using multiple things

/obj/vehicle/tank/proc/can_enter(var/mob/living/carbon/M) //NO BENOS ALLOWED
	if(!M.IsAdvancedToolUser())
		to_chat(M, "<span class='warning'>You don't have the dexterity to drive [src]!</span>")
		return FALSE
	if(!allowed(M))
		to_chat(M, "<span class='warning'>Access denied.</span>")
		return FALSE
	var/obj/item/offhand = M.get_inactive_held_item()
	if(offhand && !(offhand.flags_item & (NODROP|DELONDROP)))
		to_chat(M, "<span class='warning'>You need your hands free to climb on [src].</span>")
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
		if("pilot")
			pilot = user
		if("gunner")
			gunner = user
		if("passenger")
			passengers += user


/obj/vehicle/tank/proc/remove_all_players()
	for(var/M in operators)
		exit_tank(M)

/obj/vehicle/tank/proc/exit_tank(mob/user) //By this point, we've checked that the seats are actually empty, so we won't need to do that again HOPEFULLY
	if(user == pilot)
		user.forceMove(get_turf(src))
		pilot = null
		operators -= user
	if(user == gunner)
		user.forceMove(get_turf(src))
		gunner = null
		operators -= user
	if(user in passengers)
		user.forceMove(get_turf(src))
		passengers -= user
		operators -= user
	to_chat(user, "You hop out of [src] and slam its hatch shut behind you")

/obj/vehicle/tank/relaymove(mob/user, direction)
	if(world.time < last_move_time + move_delay)
		return
	if(user.incapacitated() || user != pilot)
		to_chat(user, "You can't reach the gas pedal from down here, maybe try manning the driver's seat?")
		return FALSE
	last_move_time = world.time
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
		to_chat(gunner, "[src]'s secondary_weapon hardpoint spins pathetically. Maybe you should install a secondary_weapon on this tank?")
		return FALSE
	firing_target = A
	playsound(get_turf(src), 'sound/weapons/tank_minigun_start.ogg', 60, 1)
	firing_secondary_weapon = TRUE
	START_PROCESSING(SSfastprocess, src)

/obj/vehicle/tank/proc/handle_fire_main(atom/A) //This is used to shoot your big ass tank cannon, rather than your small MG
	if(!primary_weapon && gunner)
		to_chat(gunner, "You look at the stump where [src]'s tank barrel should be and sigh.'")
		return FALSE
	firing_target = A
	firing_primary_weapon = TRUE
	START_PROCESSING(SSfastprocess, src)

/obj/vehicle/tank/process()
	if(firing_primary_weapon && firing_target)
		if(primary_weapon.fire(firing_target, gunner))
			if(primary_weapon_dir != get_dir(src, firing_target)) //The turret has changed position, so we want it to play a swivelling noise.
				if(world.time > lastsound + 4 SECONDS)
					visible_message("<span class='danger'>[src] swings its turret round!</span>")
					playsound(src, 'sound/effects/tankswivel.ogg', 80)
					lastsound = world.time
			primary_weapon_dir = get_dir(src, firing_target)
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
	set name = "Exit tank"
	set category = "Vehicle"
	set src in view(0)
	if(usr)
		exit_tank(usr)

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
	occupant.KnockDown(4)

/obj/vehicle/tank/Bumped(var/atom/A) //Don't ..() because then you can shove the tank into a wall.
	if(isliving(A))
		if(istype(A, /mob/living/carbon/xenomorph/crusher))
			var/mob/living/carbon/xenomorph/crusher/C = A
			take_damage(C.charge_speed * CRUSHER_CHARGE_TANK_MULTI)
		return
	else
		. = ..()

/*
TONKS BY KMC
THIS IS LIKE REGULAR CM TONK BUT IT'S LESS SHIT
WHOEVER MADE CM TANKS: YOU ARE A BAD CODER!!!!!
*/

//generic component stuff

/obj/item/tank_weapon //These are really just proof of concept weapons. You'll probably want to adapt them to use the hardpoint crap that CM has.
	name = "TGS 4 main tank cannon"
	desc = "A gun that works about 50% of the time, but at least it's open source! It fires tank shells."
	icon = 'icons/obj/hardpoint_modules.dmi'
	icon_state = "glauncher"
	var/obj/item/ammo_magazine/ammo = new /obj/item/ammo_magazine/tank/ltb_cannon
	var/obj/vehicle/tonk/owner
	var/list/fire_sounds = list('sound/weapons/tank_cannon_fire1.ogg', 'sound/weapons/tank_cannon_fire2.ogg')
	var/fire_delay
	var/cooldown = 60 //6 second weapons cooldown
	var/lastfired = 0 //When were we last shot?

/obj/item/tank_weapon/minigun
	name = "TGS 3 XENOCRUSHER tank machine gun"
	desc = "A much better gun that shits out bullets at ridiculous speeds, don't get in its way!"
	icon = 'icons/obj/hardpoint_modules.dmi'
	icon_state = "m56_cupola"
	ammo = new /obj/item/ammo_magazine/tank/ltaaap_minigun
	fire_sounds = list('sound/weapons/tank_minigun_loop.ogg')
	cooldown = 2 //Minimal cooldown

/obj/item/tank_weapon/proc/fire(var/atom/T,var/mob/user)
	if(!can_fire(T))
		return FALSE
	if(ammo.current_rounds <= 0)
		return FALSE
	if(world.time < lastfired + cooldown)
		return FALSE
	lastfired = world.time
	var/obj/item/projectile/P = new
	P.generate_bullet(new ammo.default_ammo)
	log_combat(user, user, "fired the [src].")
	log_explosion("[user] fired the [src] at [AREACOORD(loc)].")
	P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
	if(!CONFIG_GET(flag/tank_mouth_noise))
		playsound(get_turf(owner), pick(fire_sounds), 60, 1)
	ammo.current_rounds--
	return TRUE

/obj/item/tank_weapon/proc/can_fire(var/turf/T)
	if(get_dist(T, src) <= 3 && owner.gunner)
		to_chat(owner.gunner, "Firing your main gun here could damage the tank!")
		return FALSE
	return TRUE

/obj/item/tank_weapon/minigun/can_fire(var/turf/T)
	return TRUE //No loc check here

/obj/vehicle/tonk
	name = "MK-1 aliensmasher x10"
	desc = "A gigantic wall of metal designed for maximum Xeno destruction. Click it with an open hand to enter as a pilot or a gunner."
	icon = 'icons/obj/tonk.dmi'
	icon_state = "tank"
	layer = OBJ_LAYER
	bound_width = 128
	bound_height = 128
	pixel_x = -32
	anchored = FALSE
	can_buckle = FALSE
	req_access = list(ACCESS_MARINE_TANK)
	move_delay = 4
	//Who's driving the tonk
	var/mob/living/carbon/human/pilot
	var/mob/living/carbon/human/gunner
	var/list/operators = list() //Who's in this tank? Prevents you from entering the tank again
	//Health and combat shit
	var/obj/turret_overlay/turret_overlay //Allows for independantly swivelling guns, wow!
	var/obj/turret_overlay/minigun/minigun_overlay
	var/max_health = 300 //i dunno what a good number for this is, change this maintainers!
	var/obj/item/tank_weapon/main_cannon //What we use to shoot big shells
	var/obj/item/tank_weapon/minigun/minigun //What we use to shoot mini shells ((rapidfire xenocrusher 6000))
	var/main_cannon_dir = null //So that the guns swivel independantly
	var/minigun_dir = null
	var/atom/firing_target = null //Shooting code, at whom are we firing?
	var/firing_main_cannon = FALSE
	var/firing_minigun = FALSE

/obj/turret_overlay
	name = "Tank gun turret"
	desc = "The shooty bit on a tank."
	icon = 'icons/obj/tonk_gun.dmi'
	icon_state = "turret"
	layer = ABOVE_OBJ_LAYER
	animate_movement = TRUE //So it doesnt just ping back and forth and look all stupid
	mouse_opacity = FALSE //It's an overlay

/obj/vehicle/tonk/Initialize()
	. = ..()
	turret_overlay = new()
	update_icon()
	health = max_health
	main_cannon = new(src) //Make our guns
	minigun = new(src)
	main_cannon.owner = src
	minigun.owner = src

/obj/vehicle/tonk/Destroy()
	qdel(turret_overlay)
	qdel(main_cannon)
	qdel(minigun)
	. = ..()

/obj/vehicle/tonk/Move()
	. = ..()
	update_icon()

/obj/vehicle/tonk/update_icon() //To show damage, gun firing, whatever. We need to re apply the gun turret overlay.
	var/icon/I = icon(icon,icon_state,dir)
	bound_width = I.Width() //Adjust the hitbox in case admins want to make an OMEGATONK
	bound_height = I.Height()
	vis_contents = null
	if(!turret_overlay) //We have to do this because of BYOND's innate dir setting habits, in byond, if you have an overlay'd object its direction can ONLY be which way the source is facing. So, we improvise.. ((yes this is kinda shit))
		return
	if(main_cannon_dir)
		turret_overlay.setDir(main_cannon_dir)
		if(main_cannon_dir == WEST || main_cannon_dir == SOUTHWEST|| main_cannon_dir == NORTHWEST)
			turret_overlay.pixel_x = pixel_x -19
		else
			turret_overlay.pixel_x = initial(turret_overlay.pixel_x)
	vis_contents += turret_overlay

/obj/vehicle/tonk/attack_hand(mob/user)
	if(pilot && gunner)
		to_chat(user, "You are unable to enter [src] because all of its seats are occupied!")
		return ..()
	if(user in operators)
		exit_tank(user)
		return
	var/position = alert("What seat would you like to enter?.",name,"pilot","gunner") //God I wish I had radials to work with
	if(!position)
		return
	if(pilot && position == "pilot")
		to_chat(user, "[pilot] is already controlling [src]!")
		return
	if(gunner && position == "gunner")
		to_chat(user, "[gunner] is already controlling [src]!")
		return
	if(can_enter(user)) //OWO can they enter us????
		to_chat(user, "You climb into [src] as a [position]!")
		return enter(user, position) //Yeah i could do this with a define, but this way we're not using multiple things

/obj/vehicle/tonk/proc/can_enter(var/mob/living/carbon/M) //NO BENOS ALLOWED
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

	if(!M.mind || !(!M.mind.cm_skills || M.mind.cm_skills.large_vehicle >= SKILL_LARGE_VEHICLE_TRAINED))
		M.visible_message("<span class='notice'>[M] fumbles around figuring out how to get into the [src].</span>",
		"<span class='notice'>You fumble around figuring out how to get into [src].</span>")
	var/time = 10 SECONDS - 2 SECONDS * M.mind.cm_skills.large_vehicle
	if(do_after(M, time, TRUE, 5, BUSY_ICON_BUILD) && M.Adjacent(src))
		return TRUE

/obj/vehicle/tonk/proc/enter(var/mob/user, var/position) //By this point, we've checked that the seats are actually empty, so we won't need to do that again HOPEFULLY
	if(!user || !position)
		return //Something fucked up. Whoops!
	user.forceMove(src)
	operators += user
	switch(position)
		if("pilot")
			pilot = user
		if("gunner")
			gunner = user

/obj/vehicle/tonk/proc/exit_tank(var/mob/user) //By this point, we've checked that the seats are actually empty, so we won't need to do that again HOPEFULLY
	if(!user)
		return //Something fucked up. Whoops!
	if(user == pilot)
		user.forceMove(get_turf(src))
		pilot = null
		operators -= user
	if(user == gunner)
		user.forceMove(get_turf(src))
		gunner = null
		operators -= user

/obj/vehicle/tonk/relaymove(mob/user, direction)
	if(user.incapacitated() || user != pilot)
		to_chat(user, "You can't reach the gas pedal from down here, maybe try manning the driver's seat?")
		return
	if(world.time > l_move_time + move_delay)
		. = step(src, direction)
	update_icon()

/obj/vehicle/tonk/Bump(atom/A, yes)
	. = ..()
	var/facing = get_dir(src, A)
	var/turf/temp = loc
	var/turf/T = loc
	A.tank_collision(src, facing, T, temp)
	if(isliving(A) && pilot)
		log_attack("[pilot] drove over [A] with [src]")

/client/MouseDown(object, location, control, params)
	. = ..()
	if(istype(mob.loc, /obj/vehicle/tonk)) //mob is a var that exists on all clients anyway
		var/obj/vehicle/tonk/our_tonk = mob.loc //I could refactor this to be a var on the mob, if you'd prefer
		our_tonk.onMouseDown(object,mob,params) //Alright, so as soon as they start clicking, this means they want to start firing. If we're in a tonk that means that they want to shoot the tonk gun
		//MAINTAINERS: You can easily refactor this to work with guns, just follow the above format.

/client/MouseUp(object, location, control, params) ///Oh boy click code, my favourite! This adds support for click n' hold gun firing action
	. = ..()
	if(istype(mob.loc, /obj/vehicle/tonk))
		var/obj/vehicle/tonk/our_tonk = mob.loc //I could refactor this to be a var on the mob, if you'd prefer
		our_tonk.onMouseUp(object,mob)


//Combat, tonk guns, all that fun stuff
/obj/vehicle/tonk/proc/onMouseDown(var/atom/A, mob/user, params)
	if(user != gunner) //Only the gunner can fire!
		return
	var/list/modifiers = params2list(params) //If they're CTRL clicking, for example, let's not have them accidentally shoot.
	if(modifiers["shift"])
		return
	if(modifiers["ctrl"])
		handle_fire_main(A) //CTRL click to fire your big tonk gun you can change any of these parameters here to hotkey for other shit :)
		return
	if(modifiers["middle"])
		return
	if(modifiers["alt"])
		return
	handle_fire(A)

/obj/vehicle/tonk/proc/handle_fire(var/atom/A)
	if(!minigun && gunner)
		to_chat(gunner, "[src]'s minigun hardpoint spins pathetically. Maybe you should install a minigun on this tank?")
		return FALSE
	firing_target = A
	playsound(get_turf(src), 'sound/weapons/tank_minigun_start.ogg', 60, 1)
	firing_minigun = TRUE
	START_PROCESSING(SSfastprocess, src)

/obj/vehicle/tonk/proc/handle_fire_main(var/atom/A) //This is used to shoot your big ass tank cannon, rather than your small MG
	if(!main_cannon && gunner)
		to_chat(gunner, "You look at the stump where [src]'s tank barrel should be and sigh.'")
		return FALSE
	firing_target = A
	firing_main_cannon = TRUE
	START_PROCESSING(SSfastprocess, src)

/obj/vehicle/tonk/process()
	if(firing_main_cannon && firing_target)
		if(main_cannon.fire(firing_target, gunner))
			main_cannon_dir = get_dir(src, firing_target)
			update_icon()
		else
			stop_firing()
	if(firing_minigun)
		if(minigun.fire(firing_target, gunner))
			minigun_dir = get_dir(src, firing_target) //Set the gun dir
			update_icon()

/obj/vehicle/tonk/proc/onMouseUp(var/atom/A, mob/user)
	stop_firing()

/obj/vehicle/tonk/proc/stop_firing()
	firing_target = null
	firing_main_cannon = FALSE
	firing_minigun = FALSE
	update_icon(icon_state, "turret", "minigun") //Stop firing animation
	STOP_PROCESSING(SSfastprocess,src)

/*

	\\\\\WARNING////
--ENTERING SHITCODE ZONE--
	/////WARNING\\\\


Tank interaction procs copied from tank.dm!

This handles stuff like swapping seats, pulling people out of the tank, all that stuff.


*/

/obj/vehicle/tonk/verb/exit_tank_verb()
	set name = "Exit tank"
	set category = "Vehicle"
	set src in view(0)
	if(usr)
		exit_tank(usr)

/obj/vehicle/tonk/verb/switch_seats()
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

	to_chat(usr, "<span class='notice'>You start getting into the other seat.</span>")
	addtimer(CALLBACK(src, .proc/seat_switched, wannabe_trucker, usr), 3 SECONDS)

/obj/vehicle/tonk/proc/seat_switched(wannabe_trucker, mob/living/user)

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

/obj/vehicle/tonk/proc/handle_harm_attack(mob/living/M, mob/occupant)
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

/obj/vehicle/tonk/Bumped(var/atom/A, yes)
	..()
	if(istype(A, /mob/living/carbon/Xenomorph/Crusher))

		var/mob/living/carbon/Xenomorph/Crusher/C = A

		if(C.charge_speed < CHARGE_SPEED_MAX/(1.1)) //Arbitrary ratio here, might want to apply a linear transformation instead
			return

		take_damage(C.charge_speed * CRUSHER_CHARGE_TANK_MULTI)
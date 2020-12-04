/obj/item/tank_weapon
	name = "LTB main battle tank cannon"
	desc = "A TGMC vehicle's main turret cannon. It fires 86mm rocket propelled shells"
	icon = 'icons/obj/vehicles/hardpoint_modules.dmi'
	icon_state = "ltb_cannon"
	COOLDOWN_DECLARE(fire_cooldown)
	///Who this weapon is attached to
	var/obj/vehicle/armored/owner
	///Pew pew sounds the gun makes
	var/list/fire_sounds = list('sound/weapons/guns/fire/tank_cannon1.ogg', 'sound/weapons/guns/fire/tank_cannon2.ogg')
	///Current active magazine
	var/obj/item/ammo_magazine/ammo
	///The default ammo we start with
	var/default_ammo = /obj/item/ammo_magazine/tank/ltb_cannon
	///Alt ammo we'll also accept alongside the default ammo
	var/list/accepted_ammo = list(
		/obj/item/ammo_magazine/tank/tank_glauncher
	)
	///Cooldown between shots
	var/cooldown = 6 SECONDS
	///Explosion safety check range to stop bald TCs from blowing themselves into orbit trying to kill a runner
	var/range_safety_check = 4
	///The turret icon if we equip the weapon in a secondary slot, you should null this if its unequippable as such
	var/secondary_equipped_icon
	///Used to build the icon name for the turret overlay, null if its unequipable as a secondary
	var/secondary_icon_name

/obj/item/tank_weapon/Initialize()
	. = ..()
	ammo = new default_ammo(src)
	accepted_ammo += default_ammo

/obj/item/tank_weapon/Destroy()
	QDEL_NULL(ammo)
	owner = null
	return ..()

/obj/vehicle/armored/proc/attach_weapon(obj/item/tank_weapon/target, slot)
	if(slot == MODULE_PRIMARY)
		primary_weapon = target
		turret_overlay.add_overlay(image(turret_overlay.icon, target.icon_state, pixel_x = -24))
		message_admins("[turret_overlay.icon] , [target.icon_state]")
	else if(slot == MODULE_SECONDARY)
		secondary_weapon = target
		secondary_turret_icon = target.secondary_equipped_icon
		secondary_turret_icon_state = target.secondary_icon_name
		secondary_weapon_overlay.icon = secondary_turret_icon
		secondary_weapon_overlay.icon_state = "[secondary_turret_icon_state]" + "_" + "[primary_weapon.dir]"
	target.owner = src

/obj/item/tank_weapon/secondary_weapon
	name = "Secondary minigun"
	desc = "A much better gun that shits out bullets at ridiculous speeds, don't get in its way!"
	icon_state = "m56_cupola"
	fire_sounds = list('sound/weapons/guns/fire/tank_minigun_loop.ogg')
	default_ammo = /obj/item/ammo_magazine/tank/ltaap_minigun
	accepted_ammo = list(
		/obj/item/ammo_magazine/tank/m56_cupola,
	)
	cooldown = 0.3 SECONDS //Minimal cooldown
	range_safety_check = 0
	secondary_equipped_icon = 'icons/obj/tank/tank_secondary_gun.dmi'
	secondary_icon_name = "m56cupola"

/obj/item/tank_weapon/secondary_weapon/Initialize()
	. = ..()
	AddComponent(/datum/component/automatic_fire, cooldown, 1, 3, GUN_FIREMODE_AUTOMATIC, owner, CALLBACK(src, .proc/autofire_bypass_check), CALLBACK(src, .proc/do_autofire), CALLBACK(src, .proc/on_autofire_stop))

/obj/item/tank_weapon/secondary_weapon/proc/on_autofire_stop(shots_fired)
	SIGNAL_HANDLER
	return

/obj/item/tank_weapon/secondary_weapon/proc/autofire_bypass_check(datum/source, client/clicker, atom/target, turf/location, control, params)
	SIGNAL_HANDLER
	return

/obj/item/tank_weapon/secondary_weapon/proc/do_autofire(datum/source, atom/target, mob/living/shooter, params, shots_fired)
	SIGNAL_HANDLER
	if(!COOLDOWN_CHECK(src, fire_cooldown))
		return COMPONENT_AUTOFIRE_SHOT_SUCCESS
	SEND_SIGNAL(src, COMSIG_GUN_AUTOFIRE, target, shooter)
	if(owner.gunner?.incapacitated())
		return NONE
	if(ammo.current_rounds <= 0)
		playsound(get_turf(src), 'sound/weapons/guns/fire/empty.ogg', 100, TRUE)
		to_chat(shooter, "<span class='warning'>[src] has no ammo left!</span>")
		return NONE
	var/obj/projectile/P = new

	var/list/mouse_control = params2list(params)
	if(mouse_control["icon-x"])
		P.p_x = text2num(mouse_control["icon-x"])
	if(mouse_control["icon-y"])
		P.p_y = text2num(mouse_control["icon-y"])

	log_combat(shooter, target, "fired the [src].")
	P.generate_bullet(new ammo.default_ammo)
	P.fire_at(target, owner, src, P.ammo.max_range, P.ammo.shell_speed)
	playsound(src, pick(fire_sounds), 50, TRUE)	//yatatatatata
	COOLDOWN_START(src, fire_cooldown, cooldown)
	SEND_SIGNAL(shooter, COMSIG_MOB_GUN_AUTOFIRED, target, src)
	owner.secondary_weapon_overlay.setDir(angle2dir_cardinal(Get_Angle(src, target)))
	ammo.current_rounds--
	return COMPONENT_AUTOFIRE_SHOT_SUCCESS

/obj/item/tank_weapon/apc_cannon
	name = "MKV-7 utility payload launcher"
	desc = "A double barrelled cannon which can rapidly deploy utility packages to the battlefield."
	icon_state = "APC uninstalled dualcannon"
	fire_sounds = list('sound/weapons/guns/fire/shotgun_automatic.ogg', 'sound/weapons/guns/fire/shotgun_light.ogg', 'sound/weapons/guns/fire/shotgun_heavy.ogg')
	default_ammo = /obj/item/ammo_magazine/tank/tank_slauncher
	accepted_ammo = list(
		/obj/item/ammo_magazine/tank/tank_glauncher
	)
	cooldown = 0.7 SECONDS //Minimal cooldown
	range_safety_check = 0

/obj/item/tank_weapon/proc/fire(atom/T,mob/user)
	if(!can_fire(T))
		return FALSE
	COOLDOWN_START(src, fire_cooldown, cooldown)
	var/obj/projectile/P = new
	P.generate_bullet(new ammo.default_ammo)
	log_combat(user, T, "fired the [src].")
	P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
	playsound(get_turf(src), pick(fire_sounds), 100, TRUE)

	//main gun weapon flash
	var/image/flash = image(owner.turret_overlay.icon, icon_state + "_fire", pixel_x = -54, pixel_y = -27)
	owner.turret_overlay.overlays += flash
	addtimer(CALLBACK(owner.turret_overlay, /atom/movable/vis_obj/turret_overlay.proc/remove_fire_overlay, flash), 6, TIMER_CLIENT_TIME) // fuck you

	ammo.current_rounds--
	return TRUE

/obj/item/tank_weapon/proc/can_fire(turf/T = null)
	if(owner.gunner?.incapacitated())
		return FALSE
	if(!COOLDOWN_CHECK(src, fire_cooldown))
		return FALSE
	if(ammo.current_rounds <= 0)
		playsound(get_turf(src), 'sound/weapons/guns/fire/empty.ogg', 100, TRUE)
		to_chat(owner.gunner, "<span class='warning'>[src] has no ammo left!</span>")
		return FALSE
	if(get_dist(T, src) <= range_safety_check)
		to_chat(owner.gunner, "<span class='warning'>Firing [src] here would damage your vehicle!</span>")
		return FALSE
	return TRUE

/*
\\\\\\\\TANK WEAPON PROCS////////
This handles stuff like rotating turrets and shooting.
*/
///Called when the gunner clicks on something
/obj/vehicle/armored/proc/on_mouse_down(mob/user, atom/A, targetturf, control, params)
	SIGNAL_HANDLER
	if(user != gunner) //Only the gunner can fire!
		CRASH("Non-gunner user someonehow could shoot the tank")
	var/list/modifiers = params2list(params) //If they're CTRL clicking, for example, let's not have them accidentally shoot.
	if(modifiers["shift"])
		return
	if(modifiers["ctrl"])
		return
	if(modifiers["alt"])
		return
	if(modifiers["middle"])
		handle_fire_main(A) //MMB to fire your big tank gun you can change any of these parameters here to hotkey for other shit :)
		return
	//normal clicks handled by autofire

///starts handling fire for the main weapon
/obj/vehicle/armored/proc/handle_fire_main(atom/A) //This is used to shoot your big ass tank cannon, rather than your small MG
	if(!primary_weapon && gunner)
		to_chat(gunner, "You look at the stump where [src]'s tank barrel should be and sigh.")
		return FALSE
	swivel_gun(A) //Special FX, makes the tank cannon visibly swivel round to aim at the target.
	firing_target = A
	RegisterSignal(gunner, COMSIG_MOB_MOUSEUP, .proc/stop_firing)
	START_PROCESSING(SSfastprocess, src)

///Rotates the cannon overlay
/obj/vehicle/armored/proc/swivel_gun(atom/A)
	var/new_weapon_dir = angle2dir_cardinal(Get_Angle(src, A)) //Check that we're not already facing this way to avoid a double swivel when you fire.
	if(turret_overlay.dir == new_weapon_dir)
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_TANK_SWIVEL)) //Slight cooldown to avoid spam
		return FALSE
	visible_message("<span class='danger'>[src] swings its turret round!</span>")
	playsound(src, 'sound/effects/tankswivel.ogg', 80,1)
	TIMER_COOLDOWN_START(src, COOLDOWN_TANK_SWIVEL, 2 SECONDS)
	turret_overlay.setDir(new_weapon_dir)
	secondary_weapon_overlay.icon_state = "[secondary_turret_icon_state]" + "_" + "[new_weapon_dir]"
	return TRUE

/obj/vehicle/armored/process()
	if(firing_target)
		if(primary_weapon.fire(firing_target, gunner))
			swivel_gun(firing_target) //For those instances when you've swivelled your gun round a lot when your main gun wasn't ready to fire. This ensures the gun always faces the desired target.
		else
			stop_firing()
	else
		CRASH("No firing target in armored vehicle main gun fire")


///Cleans up after we stop shooting
/obj/vehicle/armored/proc/stop_firing(mob/user, atom/A, targetturf, control, params)
	SIGNAL_HANDLER
	firing_target = null
	UnregisterSignal(gunner, COMSIG_MOB_MOUSEUP)
	STOP_PROCESSING(SSfastprocess,src)


/obj/vehicle/unmanned
	name = "unmanned vehicle"
	desc = "A small remote-controllable vehicle, usually owned by the TGMC and other major armies."
	icon = 'icons/obj/unmanned_vehicles.dmi'
	icon_state = "light_uv"
	anchored = FALSE
	buckle_flags = null
	light_range = 6
	light_power = 3
	light_system = MOVABLE_LIGHT
	move_delay = 1.8	//set this to limit the speed of the vehicle
	max_integrity = 300
	hud_possible = list(MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)
	resistance_flags = XENO_DAMAGEABLE
	flags_atom = BUMP_ATTACKABLE
	///Type of "turret" attached
	var/obj/item/turret_type
	///Turret types we're allowed to attach
	var/turret_pattern = PATTERN_TRACKED
	///Boolean: do we want this turret to draw overlays for itself?
	var/overlay_turret = TRUE
	///Delay in byond ticks between weapon fires
	var/fire_delay = 5
	///Ammo remaining for the robot
	var/current_rounds = 0
	///max ammo the robot can hold
	var/max_rounds = 300
	///Buller type we fire, declared as type but set to a reference in Initialize
	var/datum/ammo/bullet/ammo
	///The currently loaded and ready to fire projectile
	var/obj/projectile/in_chamber = null
	///Sound file or string type for playing the shooting sound
	var/gunnoise = "gun_smartgun"
	/// The camera attached to the vehicle
	var/obj/machinery/camera/camera
	/// Serial number of the vehicle
	var/static/serial = 1
	/// If the vehicle should spawn with a weapon allready installed
	var/obj/item/uav_turret/spawn_equipped_type = null
	COOLDOWN_DECLARE(fire_cooldown)

/obj/vehicle/unmanned/Initialize()
	. = ..()
	ammo = GLOB.ammo_list[ammo]
	name += " " + num2text(serial)
	serial++
	GLOB.unmanned_vehicles += src
	camera = new
	camera.network += list("marine")
	prepare_huds()
	for(var/datum/atom_hud/squad/sentry_status_hud in GLOB.huds) //Add to the squad HUD
		sentry_status_hud.add_to_hud(src)
	hud_set_machine_health()
	if(spawn_equipped_type)
		turret_type = spawn_equipped_type
		ammo = GLOB.ammo_list[initial(spawn_equipped_type.ammo_type)]
		fire_delay = initial(spawn_equipped_type.fire_delay)
		current_rounds = max_rounds
		update_icon()
	hud_set_uav_ammo()


/obj/vehicle/unmanned/Destroy()
	. = ..()
	QDEL_NULL(camera)
	GLOB.unmanned_vehicles -= src

/obj/vehicle/unmanned/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration)
	. = ..()
	hud_set_machine_health()

/obj/vehicle/unmanned/repair_damage(repair_amount)
	. = ..()
	hud_set_machine_health()

/obj/vehicle/unmanned/update_overlays()
	. = ..()
	if(!overlay_turret)
		return
	switch(turret_type)
		if(/obj/item/uav_turret/heavy)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "heavy_cannon")
		if(/obj/item/uav_turret)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "light_cannon")
		if(/obj/item/explosive/plastique)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "bomb")
		if(/obj/item/uav_turret/droid)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "droidlaser")

/obj/vehicle/unmanned/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(ishuman(user))
		to_chat(user, "It has [current_rounds] out of [max_rounds] ammo left.")

/obj/vehicle/unmanned/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/tool/wrench))
		return remove_turret(user)
	if(istype(I, /obj/item/uav_turret) || istype(I, /obj/item/explosive/plastique))
		return equip_turret(I, user)
	if(istype(I, /obj/item/ammo_magazine))
		return reload_turret(I, user)

///Try to desequip the turret
/obj/vehicle/unmanned/proc/remove_turret(mob/user)
	if(!turret_type)
		to_chat(user,"<span class='warning'>There is nothing to remove from [src]!</span>")
		return
	user.visible_message("<span class='notice'>[user] starts to remove [initial(turret_type.name)] from [src].</span>",
	"<span class='notice'>You start to remove [initial(turret_type.name)] from [src].</span>")
	if(!do_after(user, 3 SECONDS, TRUE, src))
		return
	var/obj/item/equipment = new turret_type
	user.visible_message("<span class='notice'>[user] removes [equipment] from [src].</span>",
	"<span class='notice'>You remove [equipment] from [src].</span>")
	user.put_in_hands(equipment)
	turret_type = null
	current_rounds = 0
	hud_set_uav_ammo()
	return

///Try to reload the turret of our vehicule
/obj/vehicle/unmanned/proc/reload_turret(obj/item/ammo_magazine/ammo, mob/user)
	if(!ispath(turret_type, ammo.gun_type))
		to_chat(user, "<span class='warning'>This is not the right ammo!</span>")
		return
	user.visible_message("<span class='notice'>[user] starts to reload [src] with [ammo].</span>",
	"<span class='notice'>You start to reload [src] with [ammo].</span>")
	if(!do_after(user, 3 SECONDS, TRUE, src))
		return
	user.visible_message("<span class='notice'>[user] reloads [src] with [ammo].</span>",
	"<span class='notice'>You reload [src] with [ammo].</span>")
	current_rounds = min(current_rounds + ammo.current_rounds, max_rounds)
	playsound(loc, 'sound/weapons/guns/interact/smartgun_unload.ogg', 25, 1)
	qdel(ammo)
	
/// Try to equip a turret on the vehicle
/obj/vehicle/unmanned/proc/equip_turret(obj/item/I, mob/user)
	if(turret_type)
		to_chat(user, "<span class='notice'>There's already something attached!</span>")
		return
	if(istype(I, /obj/item/uav_turret))
		var/obj/item/uav_turret/turret = I
		if(turret_pattern != turret.turret_pattern)
			to_chat(user, "<span class='notice'>You can't attach that type of turret!</span>")
			return
	user.visible_message("<span class='notice'>[user] starts to attach [I] to [src].</span>",
	"<span class='notice'>You start to attach [I] to [src].</span>")
	if(!do_after(user, 3 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return
	turret_type = I.type
	if(istype(I, /obj/item/uav_turret))
		var/obj/item/uav_turret/turret = I
		ammo = GLOB.ammo_list[turret.ammo_type]
		fire_delay = turret.fire_delay
		current_rounds = max_rounds
		hud_set_uav_ammo()
	user.visible_message("<span class='notice'>[user] attaches [I] to [src].</span>",
	"<span class='notice'>You attach [I] to [src].</span>")
	update_icon()
	SEND_SIGNAL(src, COMSIG_UNMANNED_TURRET_UPDATED, turret_type)
	qdel(I)

/**
 * Called when the drone is unlinked from a remote control
 */
/obj/vehicle/unmanned/proc/on_link()
	RegisterSignal(src, COMSIG_REMOTECONTROL_CHANGED, .proc/on_remote_toggle)

/**
 * Called when the drone is linked to a remote control
 */
/obj/vehicle/unmanned/proc/on_unlink()
	UnregisterSignal(src, COMSIG_REMOTECONTROL_CHANGED)

///Called when remote control is taken
/obj/vehicle/unmanned/proc/on_remote_toggle(datum/source, is_on, mob/user)
	SIGNAL_HANDLER
	set_light_on(is_on)

///Checks if we can or already have a bullet loaded that we can shoot
/obj/vehicle/unmanned/proc/load_into_chamber()
	if(in_chamber)
		return TRUE //Already set!
	if(current_rounds <= 0)
		return FALSE
	in_chamber = new /obj/projectile(src) //New bullet!
	in_chamber.generate_bullet(ammo)
	return TRUE


///Check if we have/create a new bullet and fire it at an atom target
/obj/vehicle/unmanned/proc/fire_shot(atom/target, mob/user)
	if(!COOLDOWN_CHECK(src, fire_cooldown))
		return FALSE
	if(load_into_chamber() && istype(in_chamber, /obj/projectile))
		//Setup projectile
		in_chamber.original_target = target
		in_chamber.def_zone = pick("chest","chest","chest","head")
		//Shoot at the thing
		playsound(loc, gunnoise, 75, 1)
		in_chamber.fire_at(target, src, null, ammo.max_range, ammo.shell_speed)
		in_chamber = null
		COOLDOWN_START(src, fire_cooldown, fire_delay)
		current_rounds--
		hud_set_uav_ammo()
	return TRUE

/obj/vehicle/unmanned/medium
	name = "medium unmanned vehicle"
	icon_state = "medium_uv"
	move_delay = 2.4
	max_rounds = 200
	max_integrity = 500

/obj/vehicle/unmanned/heavy
	name = "heavy unmanned vehicle"
	icon_state = "heavy_uv"
	move_delay = 3.5
	max_rounds = 200
	max_integrity = 700
	anchored = TRUE

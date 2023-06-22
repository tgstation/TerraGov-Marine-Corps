/obj/item/explosive/grenade/flare
	name = "\improper M40 FLDP grenade"
	desc = "A TGMC standard issue flare utilizing the standard DP canister chassis. Capable of being loaded in any grenade launcher, or thrown by hand."
	icon_state = "flare_grenade"
	item_state = "flare_grenade"
	det_time = 0
	throwforce = 1
	dangerous = FALSE
	w_class = WEIGHT_CLASS_TINY
	hud_state = "grenade_frag"
	light_system = MOVABLE_LIGHT
	light_range = 5
	light_power = 0.65
	light_color = LIGHT_COLOR_FLARE
	var/fuel = 0
	var/lower_fuel_limit = 13 MINUTES
	var/upper_fuel_limit = 15 MINUTES

/obj/item/explosive/grenade/flare/dissolvability(acid_strength)
	return 2

/obj/item/explosive/grenade/flare/Initialize(mapload)
	. = ..()
	fuel = rand(lower_fuel_limit, upper_fuel_limit)

/obj/item/explosive/grenade/flare/flamer_fire_act(burnlevel)
	if(!fuel) // it's out of fuel, an empty shell.
		return
	if(!active)
		turn_on()

/obj/item/explosive/grenade/flare/prime()
	return

/obj/item/explosive/grenade/flare/Destroy()
	turn_off()
	return ..()

/obj/item/explosive/grenade/flare/process()
	fuel = max(fuel - 1 SECONDS, 0)

	if(light_system != STATIC_LIGHT)
		switch(fuel)
			if(5 MINUTES, 3 MINUTES, 2 MINUTES, 1 MINUTES)
				set_light_range_power_color(light_range - 1, light_power, light_color)

	if(!fuel || !active)
		turn_off()

/obj/item/explosive/grenade/flare/proc/turn_off()
	active = FALSE
	fuel = 0
	heat = 0
	item_fire_stacks = 0
	force = initial(force)
	damtype = initial(damtype)
	update_icon()
	if(light_system == STATIC_LIGHT)
		set_light(FALSE)
	else
		set_light_on(FALSE)
	STOP_PROCESSING(SSobj, src)

/obj/item/explosive/grenade/flare/proc/turn_on()
	active = TRUE
	force = 5
	throwforce = 10
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)
	item_fire_stacks = 5
	heat = 1500
	damtype = BURN
	update_icon()
	update_brightness()
	if(light_system == STATIC_LIGHT)
		set_light(light_range)
	else
		set_light_on(TRUE)

	playsound(src,'sound/items/flare.ogg', 15, 1)
	START_PROCESSING(SSobj, src)

/obj/item/explosive/grenade/flare/attack_self(mob/user)
	// Usual checks
	if(!fuel)
		to_chat(user, span_notice("It's out of fuel."))
		return
	if(active)
		return

	// All good, turn it on.
	user.visible_message(span_notice("[user] activates the flare."), span_notice("You depress the ignition button, activating it!"))
	turn_on(user)

/obj/item/explosive/grenade/flare/activate(mob/user)
	if(!active)
		turn_on(user)

/obj/item/explosive/grenade/flare/update_icon_state()
	. = ..()
	if(active && fuel > 0)
		icon_state = "[initial(icon_state)]_active"
		item_state = "[initial(item_state)]_active"
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)

	if(!fuel)
		icon_state = "[initial(icon_state)]_empty"

/obj/item/explosive/grenade/flare/proc/update_brightness()
	if(light_system == STATIC_LIGHT)
		set_light(light_range)
	else
		set_light_range_power_color(light_range, light_power, light_color)

/obj/item/explosive/grenade/flare/throw_impact(atom/hit_atom, speed)
	. = ..()
	if(!active)
		return

	if(isliving(hit_atom))
		var/mob/living/L = hit_atom

		var/target_zone = check_zone(L.zone_selected)
		if(!target_zone || rand(40))
			target_zone = "chest"
		if(launched && CHECK_BITFIELD(resistance_flags, ON_FIRE) && !L.on_fire)
			L.apply_damage(rand(throwforce*0.75,throwforce*1.25), BURN, target_zone, FIRE, updating_health = TRUE) //Do more damage if launched from a proper launcher and active

	// Flares instantly burn out nodes when thrown at them.
	var/obj/alien/weeds/node/N = locate() in loc
	if(N)
		qdel(N)
		turn_off()

/obj/item/explosive/grenade/flare/on/Initialize(mapload)
	. = ..()
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)
	turn_on()
	START_PROCESSING(SSobj, src)

/obj/item/explosive/grenade/flare/civilian
	name = "flare"
	desc = "A NT standard emergency flare. There are instructions on the side, it reads 'pull cord, make light'."
	icon_state = "flare"
	item_state = "flare"

/obj/item/explosive/grenade/flare/cas
	name = "\improper M50 CFDP signal flare"
	desc = "A TGMC signal flare utilizing the standard DP canister chassis. Capable of being loaded in any grenade launcher, or thrown by hand. When activated, provides a target for CAS pilots."
	icon_state = "cas_flare_grenade"
	item_state = "cas_flare_grenade"
	hud_state = "grenade_frag"
	lower_fuel_limit = 25 SECONDS
	upper_fuel_limit = 30 SECONDS
	light_power = 3
	light_color = LIGHT_COLOR_GREEN
	var/datum/squad/user_squad
	var/obj/effect/overlay/temp/laser_target/cas/target

/obj/item/explosive/grenade/flare/cas/turn_on(mob/living/carbon/human/user)
	. = ..()
	if(!user)
		return
	if(user.assigned_squad)
		user_squad = user.assigned_squad
	var/turf/TU = get_turf(src)
	if(!istype(TU))
		return
	if(is_ground_level(TU.z))
		target = new(src, null, name, user_squad)//da lazer is stored in the grenade

/obj/item/explosive/grenade/flare/cas/process()
	. = ..()
	var/turf/TU = get_turf(src)
	if(is_ground_level(TU.z))
		if(!target && active)
			target = new(src, null, name, user_squad)

/obj/item/explosive/grenade/flare/cas/turn_off()
	QDEL_NULL(target)
	return ..()

///Flares that the tadpole flare launcher launches
/obj/item/explosive/grenade/flare/strongerflare
	icon_state = "stronger_flare_grenade"
	lower_fuel_limit = 10 SECONDS
	upper_fuel_limit = 20 SECONDS
	light_system = STATIC_LIGHT //movable light has a max range
	light_color = LIGHT_COLOR_CYAN
	light_range = 12

/obj/item/explosive/grenade/flare/strongerflare/throw_impact(atom/hit_atom, speed)
	. = ..()
	anchored = TRUE//prevents marines from picking up and running around with a stronger flare


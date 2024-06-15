// Used for objects created by ammo datums that tend to be more general and can be used in multiple ammo datum files.


/////////////////////////////
//          FIRE           //
/////////////////////////////
// Base type , meant to be overridden
/obj/fire
	name = "fire"
	desc = "Ouch!"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "red_2"
	layer = BELOW_OBJ_LAYER
	light_system = MOVABLE_LIGHT
	light_mask_type = /atom/movable/lighting_mask/flicker
	light_on = TRUE
	light_range = 3
	light_power = 3
	/// tracks for how many process ticks the fire will exist.Can be reduced by other sources
	var/burn_ticks = 10
	///The color the flames and associated particles appear
	var/flame_color = "red"
	///Tracks how HOT the fire is. This is basically the heat level of the fire and determines the temperature
	var/burn_level = 20
	/// How many burn ticks we lose per process
	var/burn_decay = 1

/obj/fire/Initialize(mapload, burn_ticks, burn_level, f_color, fire_stacks = 0, fire_damage = 0)
	. = ..()
	START_PROCESSING(SSobj, src)

	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)
	AddComponent(/datum/component/submerge_modifier, 10)
	set_fire(burn_ticks, burn_level, f_color, fire_stacks, fire_damage)

/obj/fire/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/fire/update_icon()
	. = ..()
	var/light_intensity = 3
	switch(burn_ticks)
		if(1 to 9)
			light_intensity = 2
		if(10 to 25)
			light_intensity = 4
		if(25 to INFINITY) //Change the icons and luminosity based on the fire_base's intensity
			light_intensity = 6
	set_light_range_power_color(light_intensity, light_power, light_color)

/obj/fire/update_icon_state()
	. = ..()
	switch(flame_color)
		if("red")
			light_color = LIGHT_COLOR_FLAME
		if("blue")
			light_color = LIGHT_COLOR_BLUE_FLAME
		if("green")
			light_color = LIGHT_COLOR_ELECTRIC_GREEN
	switch(burn_ticks)
		if(1 to 9)
			icon_state = "[flame_color]_1"
		if(10 to 25)
			icon_state = "[flame_color]_2"
		if(25 to INFINITY) //Change the icons and luminosity based on the fire_base's intensity
			icon_state = "[flame_color]_3"


///Sets the fire_base object to the correct colour and fire_base values, and applies the initial effects to any mob on the turf
/obj/fire/proc/set_fire(burn_ticks, burn_level, f_color, fire_stacks = 0, fire_damage = 0)
	if(burn_ticks < 0)
		qdel(src)
		return

	if(f_color && (flame_color != f_color))
		flame_color = f_color

	if(!GLOB.flamer_particles[flame_color])
		GLOB.flamer_particles[flame_color] = new /particles/flamer_fire(flame_color)

	particles = GLOB.flamer_particles[flame_color]
	if(burn_ticks)
		src.burn_ticks = burn_ticks
	if(burn_level)
		src.burn_level = burn_level
	update_appearance(UPDATE_ICON)

	if((fire_stacks+fire_damage)==0)
		return

	for(var/mob/living/C in get_turf(src))
		affect_mob(C)

///Effects applied to anything that crosses a burning turf
/obj/fire/proc/on_cross(datum/source, atom/movable/crosser, oldloc, oldlocs)
	SIGNAL_HANDLER
	return

/// Effects applied from smokes
/obj/fire/effect_smoke(obj/effect/particle_effect/smoke/affecting_smoke)
	if(!CHECK_BITFIELD(affecting_smoke.smoke_traits, SMOKE_EXTINGUISH)) //Fire suppressing smoke
		return
	burn_ticks -= 20 //Water level extinguish
	if(burn_ticks < 1) //Extinguish if our burn_ticks is less than 1
		playsound(affecting_smoke, 'sound/effects/smoke_extinguish.ogg', 20)
		qdel(src)
		return
	update_appearance(UPDATE_ICON)

/// Called on all objects on a turf on process(). Doesn't include the turf itself
/obj/fire/proc/affect_mob(mob/living/carbon/affected)
	return

/// Called on the turf we are currently burning
/obj/fire/proc/affect_turf(turf/affected)
	return

/// Called on all objs on the turf we are on
/obj/fire/proc/affect_obj(obj/affected)
	return

/obj/fire/process()
	var/turf/burn_turf = loc
	if(!istype(burn_turf)) //Is it a valid turf?
		qdel(src)
		return

	burn_ticks -= burn_decay
	if(burn_ticks <= 0)
		qdel(src)
		return PROCESS_KILL

	affect_turf(burn_turf)
	for(var/atom/thing AS in burn_turf)
		if(isliving(thing))
			affect_mob(thing)
			continue
		if(isobj(thing))
			affect_obj(thing)
			continue

	update_appearance(UPDATE_ICON)

/////////////////////////////
//      FLAMER FIRE        //
/////////////////////////////

/obj/fire/flamer
	icon_state = "red_2"
	burn_ticks = 12

///Effects applied to a mob that crosses a burning turf
/obj/fire/flamer/on_cross(datum/source, mob/living/crosser, oldloc, oldlocs)
	. = ..()
	if(istype(crosser) || isobj(crosser))
		crosser.fire_act(burn_level)

/obj/fire/flamer/affect_mob(mob/living/carbon/affected)
	. = ..()
	affected.fire_act(burn_level)

/obj/fire/flamer/affect_obj(obj/affected)
	. = ..()
	affected.fire_act(burn_level)

/obj/fire/flamer/affect_turf(turf/affected)
	. = ..()
	affected.fire_act(burn_level)

/obj/fire/flamer/process()
	. = ..()
	burn_level = max(0, burn_level - 2)
	if(burn_level == 0)
		qdel(src)
		return PROCESS_KILL

///////////////////////////////
//        MELTING FIRE       //
///////////////////////////////

/obj/fire/melting_fire
	name = "melting fire"
	desc = "It feels cold to the touch.. yet it burns."
	icon_state = "xeno_fire"
	flame_color = "purple"
	light_on = FALSE
	burn_ticks = 36
	burn_decay = 9

/// affecting mobs
/obj/fire/melting_fire/affect_mob(mob/living/carbon/target)
	if(isxeno(target))
		return
	if(target.stat == DEAD)
		return
	var/damage = PYROGEN_MELTING_FIRE_DAMAGE
	var/datum/status_effect/stacking/melting_fire/debuff = target.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
	if(debuff)
		debuff.add_stacks(PYROGEN_MELTING_FIRE_EFFECT_STACK)
	else
		target.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, PYROGEN_MELTING_FIRE_EFFECT_STACK)
	target.take_overall_damage(damage, BURN, FIRE, max_limbs = 2)

/obj/fire/melting_fire/on_cross(datum/source, mob/living/carbon/human/crosser, oldloc, oldlocs)
	if(istype(crosser))
		affect_mob(crosser)

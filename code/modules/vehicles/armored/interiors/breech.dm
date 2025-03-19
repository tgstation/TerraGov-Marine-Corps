
/obj/structure/gun_breech
	name = "gun breech"
	desc = "A gun breech used for loading large caliber rounds into the main gun."
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "breech"
	resistance_flags = RESIST_ALL
	///bool if this laods the secondary gun
	var/is_secondary = FALSE
	///owner of this object, assigned during interior linkage
	var/obj/vehicle/sealed/armored/owner

/obj/structure/gun_breech/Destroy()
	owner = null
	return ..()

/obj/structure/gun_breech/link_interior(datum/interior/link)
	if(!istype(link, /datum/interior/armored))
		CRASH("invalid interior [link.type] passed to [name]")
	var/datum/interior/armored/inside = link
	if(!is_secondary)
		inside.breech = src
	else
		inside.secondary_breech = src
	owner = inside.container

/obj/structure/gun_breech/attack_hand(mob/living/user)
	. = ..()
	var/obj/item/armored_weapon/weapon = is_secondary ? owner.secondary_weapon : owner.primary_weapon
	if(!weapon)
		balloon_alert(user, "no weapon")
		return
	if(!weapon.ammo)
		balloon_alert(user, "breech empty")
		return
	if(user.do_actions)
		balloon_alert(user, "busy")
		return
	if(!do_after(user, 1 SECONDS, NONE, src))
		return
	if(!weapon)
		balloon_alert(user, "no weapon")
		return
	if(!weapon.ammo)
		balloon_alert(user, "breech empty")
		return
	do_unload(user, weapon)

/obj/structure/gun_breech/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/ammo_magazine))
		return
	var/obj/item/ammo_magazine/mag = I
	var/obj/item/armored_weapon/weapon = is_secondary ? owner.secondary_weapon : owner.primary_weapon
	if(!reload_checks(user))
		return
	if(!(mag.type in weapon.accepted_ammo))
		balloon_alert(user, "not accepted ammo")
		return
	if(user.do_actions)
		balloon_alert(user, "busy")
		return
	var/channel = SSsounds.random_available_channel()
	var/sound = 'sound/weapons/guns/interact/working_the_bolt.ogg'
	if(istype(mag, /obj/item/ammo_magazine/tank))
		var/obj/item/ammo_magazine/tank/t_mag = mag
		sound = islist(t_mag.loading_sound)? pick(t_mag.loading_sound):t_mag.loading_sound
	playsound(src, sound, 20, channel = channel)
	if(!do_after(user, weapon.rearm_time, NONE, src, extra_checks=CALLBACK(src, PROC_REF(reload_checks), user)))
		for(var/mob/crew AS in owner.interior.occupants)
			crew.stop_sound_channel(channel)
		return
	if(!reload_checks(user))
		return

	do_load(user, weapon, mag)

///loads the weapon attached to the breech
/obj/structure/gun_breech/proc/do_load(mob/living/user, obj/item/armored_weapon/weapon, obj/item/ammo_magazine/mag)
	user.temporarilyRemoveItemFromInventory(mag)
	mag.forceMove(weapon)
	weapon.ammo_magazine +=mag
	if(weapon.ammo)
		return
	weapon.reload()
	update_appearance(UPDATE_ICON)
	var/obj/item/ammo_magazine/tank/callout = mag
	user.say(is_secondary ? "Loaded!" : (callout.callout_name ? "[callout.callout_name], Up!" : "Up!"))

///Unloads the weapon attached to the breech
/obj/structure/gun_breech/proc/do_unload(mob/living/user, obj/item/armored_weapon/weapon)
	owner.balloon_alert(user, "breech unloaded")
	user.put_in_hands(weapon.ammo)
	weapon.ammo.update_appearance()
	weapon.ammo = null
	weapon.reload()
	update_appearance(UPDATE_ICON)

///checks to perform while reloading
/obj/structure/gun_breech/proc/reload_checks(mob/user)
	var/obj/item/armored_weapon/weapon = is_secondary ? owner.secondary_weapon : owner.primary_weapon
	if(!weapon)
		balloon_alert(user, "no weapon")
		return FALSE
	if(weapon.ammo && length(weapon.ammo_magazine) >= weapon.maximum_magazines)
		balloon_alert(user, "already loaded")
		return FALSE
	return TRUE

///called every time the firing animation is refreshed, not every actual fire
/obj/structure/gun_breech/proc/on_main_fire(obj/item/ammo_magazine/owner_ammo)
	if(owner_ammo.default_ammo.ammo_behavior_flags & AMMO_ENERGY) // todo add puffs of smoke that fly out
		return
	if(owner_ammo.max_rounds == 1)
		return
	//todo get an animation for bullets flying out
	var/turf/eject_loc = get_step(src, WEST)
	var/obj/item/ammo_casing/cartridge/pile = locate(/obj/item/ammo_casing/cartridge) in eject_loc
	if(!pile)
		pile = new(eject_loc)
		return
	pile.current_casings += 1
	pile.update_appearance()

///when we run out of ammo; how do we eject the magazine?
/obj/structure/gun_breech/proc/do_eject_ammo(obj/item/ammo_magazine/old_ammo)
	old_ammo.forceMove(get_step(src, WEST))
	if(old_ammo.max_rounds != 1)
		//todo make non shell and energy ejection anim?
		return
	old_ammo.pixel_x = 20
	old_ammo.pixel_y = 4
	var/matrix/hit_back_transform = matrix()
	var/rand_spin = rand(-90, 90)
	hit_back_transform.Turn(rand_spin)
	var/hit_back_x = 6 + rand(-1, 1)
	var/hit_back_y = -4 + rand(-1, 1)

	var/matrix/rest_transform = matrix()
	rest_transform.Turn(rand_spin + rand(-45, 45))
	var/rest_x = 3 + rand(0, 10)
	var/rest_y = -17 + rand(-2, 2)

	animate(old_ammo, time=3, easing=CUBIC_EASING|EASE_OUT, transform = hit_back_transform, pixel_x = hit_back_x, pixel_y = hit_back_y)
	animate(time=3, easing=CUBIC_EASING|EASE_IN, transform = rest_transform, pixel_x = rest_x, pixel_y = rest_y)
	var/obj/effect/abstract/particle_holder/smoke_visuals = new(src, /particles/breech_smoke)
	QDEL_IN(smoke_visuals, 0.7 SECONDS)

///On attach effects
/obj/structure/gun_breech/proc/on_weapon_attach(obj/item/armored_weapon/new_weapon)
	return

///On detach effects
/obj/structure/gun_breech/proc/on_weapon_detach(obj/item/armored_weapon/old_weapon)
	return

/particles/breech_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 300
	height = 300
	count = 20
	spawning = 20
	lifespan = 1 SECONDS
	fade = 8 SECONDS
	grow = 0.1
	scale = 0.2
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(-4, 0)
	position = list(-2, 2)
	gravity = list(0, 2)
	friction = generator(GEN_NUM, 0.1, 0.5)

/obj/structure/gun_breech/secondary
	name = "secondary loading mechanism"
	desc = "A feeding mechanism for loading ammo into the secondary weapon."
	icon_state = "secondary_breech"
	is_secondary = TRUE

/obj/structure/gun_breech/secondary/do_eject_ammo(obj/item/ammo_magazine/old_ammo)
	old_ammo.forceMove(get_turf(src))
	old_ammo.pixel_x = rand(-10, 10)
	old_ammo.pixel_y = rand(-10, 10)

/obj/structure/gun_breech/som
	icon_state = null
	icon = 'icons/obj/armored/3x4/som_breech.dmi'
	density = FALSE
	layer = ABOVE_OBJ_LAYER
	var/obj/item/armored_weapon/weapon_type
	///overlay obj for for the attached gun
	var/atom/movable/vis_obj/internal_barrel/barrel_overlay
	///overlay obj for internal firing animation
	var/atom/movable/vis_obj/som_tank_ammo/ammo_overlay

/obj/structure/gun_breech/som/Initialize(mapload)
	. = ..()
	barrel_overlay = new()
	barrel_overlay.icon = icon
	barrel_overlay.icon_state = "[icon_state]_barrel"
	vis_contents += barrel_overlay

	ammo_overlay = new()
	ammo_overlay.icon = icon
	vis_contents += ammo_overlay

/obj/structure/gun_breech/som/Destroy()
	weapon_type = null
	QDEL_NULL(barrel_overlay)
	return ..()

/obj/structure/gun_breech/som/update_icon_state()
	. = ..()
	icon_state = weapon_type.icon_state

/obj/structure/gun_breech/som/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "[icon_state]_overlay", ABOVE_MOB_LAYER)

/obj/structure/gun_breech/som/on_weapon_attach(obj/item/armored_weapon/new_weapon)
	update_gun_appearance(new_weapon)

/obj/structure/gun_breech/som/on_weapon_detach(obj/item/armored_weapon/old_weapon)
	update_gun_appearance(old_weapon)

/obj/structure/gun_breech/som/do_load(mob/living/user, obj/item/armored_weapon/weapon, obj/item/ammo_magazine/mag)
	. = ..()
	update_gun_appearance(weapon_type)

/obj/structure/gun_breech/som/do_unload(mob/living/user, obj/item/armored_weapon/weapon)
	. = ..()
	update_gun_appearance(weapon_type)

/obj/structure/gun_breech/som/on_main_fire(obj/item/ammo_magazine/owner_ammo)
	update_gun_appearance(weapon_type)
	if(weapon_type.type == /obj/item/armored_weapon/coilgun)
		flick("[ammo_overlay.icon_state]_flick", ammo_overlay)

///Updates breech and barrel vis_obj appearance
/obj/structure/gun_breech/som/proc/update_gun_appearance(obj/item/armored_weapon/current_weapon)
	weapon_type = current_weapon
	if(!weapon_type)
		density = FALSE
		barrel_overlay.icon_state = null
		return

	density = TRUE
	update_appearance(UPDATE_ICON)
	barrel_overlay.icon_state = "[icon_state]_barrel"
	if(weapon_type.type == /obj/item/armored_weapon/volkite_carronade)
		pixel_x = 4
		pixel_y = -4
		barrel_overlay.pixel_y = 46
	else if(weapon_type.type == /obj/item/armored_weapon/coilgun)
		pixel_x = -12
		pixel_y = -32
		barrel_overlay.pixel_y = 76
		ammo_overlay.icon_state = "[icon_state]_[length(weapon_type?.ammo_magazine) + weapon_type.ammo.current_rounds]"
	else if(weapon_type.type == /obj/item/armored_weapon/particle_lance)
		pixel_x = -8
		pixel_y = -7
		barrel_overlay.pixel_y = 48

/atom/movable/vis_obj/internal_barrel
	name = "Tank weapon"
	mouse_opacity  = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER

/atom/movable/vis_obj/som_tank_ammo
	name = "Tank weapon"
	mouse_opacity  = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_PLATFORM_LAYER

/obj/structure/gun_breech/lvrt
	name = "gun breech"
	icon = 'icons/obj/armored/2x2/icc_lvrt.dmi'
	icon_state = "lvrt_breech"

/obj/structure/gun_breech/secondary/lvrt
	name = "coaxial loading mechanism"
	desc = "A feeding mechanism for loading ammo into the vehicle's coaxial feed."
	icon = 'icons/obj/armored/2x2/icc_lvrt.dmi'
	icon_state = "lvrt_secondary_breech"
	is_secondary = TRUE

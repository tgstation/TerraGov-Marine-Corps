
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
	owner.balloon_alert(user, "breech unloaded")
	user.put_in_hands(weapon.ammo)
	weapon.ammo.update_appearance()
	weapon.ammo = null

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
	user.temporarilyRemoveItemFromInventory(mag)
	mag.forceMove(weapon)
	weapon.ammo = mag
	balloon_alert(user, "loaded")
	if(!is_secondary)
		user.say("Up!")
	for(var/mob/occupant AS in owner.occupants)
		occupant.hud_used.update_ammo_hud(owner, list(
			mag.default_ammo.hud_state,
			mag.default_ammo.hud_state_empty),
			mag.current_rounds
		)

///checks to perform while reloading
/obj/structure/gun_breech/proc/reload_checks(mob/user)
	var/obj/item/armored_weapon/weapon = is_secondary ? owner.secondary_weapon : owner.primary_weapon
	if(!weapon)
		balloon_alert(user, "no weapon")
		return FALSE
	if(weapon.ammo)
		balloon_alert(user, "already loaded")
		return FALSE
	return TRUE

///called every time the firing animation is refreshed, not every actual fire
/obj/structure/gun_breech/proc/on_main_fire(obj/item/ammo_magazine/old_ammo)
	return

///when we run out of ammo; how do we eject the magazine?
/obj/structure/gun_breech/proc/do_eject_ammo(obj/item/ammo_magazine/old_ammo)
	old_ammo.forceMove(get_step(src, WEST))
	if(old_ammo.max_rounds != 1)
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

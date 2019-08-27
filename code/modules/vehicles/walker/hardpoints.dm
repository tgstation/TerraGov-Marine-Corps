/obj/item/walker_hardpoint
	name = "walker gun"
	icon = 'icons/obj/vehicles/mecha_guns.dmi'
	var/equip_state = ""
	w_class = WEIGHT_CLASS_BULKY
	var/obj/vehicle/walker/owner = null

/obj/item/walker_hardpoint/proc/get_icon_image(var/hardpoint=null)
	return image(owner.icon, equip_state + hardpoint)

/obj/item/walker_hardpoint/proc/active_effect(var/atom/target)
	return

///////////////////
// WEAPON MODULES//
///////////////////

/obj/item/walker_hardpoint/gun
	name = "walker gun"

	var/magazine_type = /obj/item/ammo_magazine/walker
	var/obj/item/ammo_magazine/walker/ammo = null
	var/fire_sound = 'sound/weapons/guns/fire/smartgun2.ogg'
	var/fire_delay = 0
	var/last_fire = 0
	var/burst = 1

	var/muzzle_flash 	= "muzzle_flash"
	var/muzzle_flash_lum = 3 //muzzle flash brightness
	var/muzzle_flash_lum_power = 2 //muzzle flash brightness


/obj/item/walker_hardpoint/gun/proc/can_fire()
	if(world.time < last_fire + fire_delay)
		return FALSE
	if(ammo.current_rounds <= 0)
		playsound(get_turf(src), 'sound/weapons/guns/fire/empty.ogg', 100, 1)
		return FALSE
	return TRUE


/obj/item/walker_hardpoint/gun/active_effect(var/atom/target)
	last_fire = world.time
	var/obj/item/projectile/P
	for(var/i = 1 to burst)
		if(!owner.firing_arc(target))
			return
		P = new
		P.generate_bullet(new ammo.default_ammo)
		playsound(src, fire_sound, 60)
		target = simulate_scatter(target, P)
		P.fire_at(target, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		ammo.current_rounds--
		if(ammo.current_rounds <= 0)
			ammo.loc = owner.loc
			ammo = null
			visible_message("[owner.name]'s systems deployed used magazine.","")
			break
		sleep(3)
	log_combat(owner.pilot, target, "fired the [src].")
	to_chat(owner.pilot , "<span class='warning'>[name] fired! [ammo.current_rounds]/[ammo.max_rounds] remaining!")
	visible_message("<span class='danger'>[owner.name] fires from [name]!</span>", "<span class='warning'>You hear [istype(P.ammo, /datum/ammo/bullet) ? "gunshot" : "blast"]!</span>")

	var/angle = round(Get_Angle(owner,target))
	muzzle_flash(angle)

	if(ammo.current_rounds <= 0)
		ammo.loc = owner.loc
		ammo = null
		visible_message("[owner.name]'s systems deployed used magazine.","")
	return TRUE

/obj/item/walker_hardpoint/gun/proc/muzzle_flash(angle, var/x_offset = 0, var/y_offset = 5)
	if(!muzzle_flash ||  isnull(angle))
		return //We have to check for null angle here, as 0 can also be an angle.
	if(!istype(owner) || !istype(owner.loc,/turf))
		return

	if(owner.light_power <= muzzle_flash_lum_power)
		owner.set_light(light_range + muzzle_flash_lum, light_power + muzzle_flash_lum_power)
		spawn(10)
			owner.set_light(light_range - muzzle_flash_lum, light_power - muzzle_flash_lum_power)

	if(prob(65)) //Not all the time.
		var/image_layer = (owner && owner.dir == SOUTH) ? MOB_LAYER+0.1 : MOB_LAYER-0.1
		var/image/I = image('icons/obj/items/projectiles.dmi',owner,muzzle_flash,image_layer)
		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(x,y)
		rotate.Turn(angle)
		I.transform = rotate

		flick_overlay_view(I, owner, 3)

/obj/item/walker_hardpoint/gun/proc/simulate_scatter(var/atom/target, obj/item/projectile/projectile_to_fire)
	var/total_chance = projectile_to_fire.scatter
	if(total_chance <= 0)
		return target
	var/targdist = get_dist(target, owner)
	if(targdist <= (4 + rand(-1, 1)))
		return target
	if(burst > 1)
		total_chance += burst * 2

	var/turf/targloc = get_turf(target)
	if(prob(total_chance)) //Scattered!
		var/scatter_x = rand(-1,1)
		var/scatter_y = rand(-1,1)
		var/turf/new_target = locate(targloc.x + round(scatter_x),targloc.y + round(scatter_y),targloc.z) //Locate an adjacent turf.
		if(new_target)
			target = new_target//Looks like we found a turf.
	return target

/obj/item/walker_hardpoint/gun/smartgun
	name = "M56 Double-Barrel Mounted Smartgun"
	desc = "Modifyed version of standart USCM Smartgun System, mounted on military walkers"
	icon_state = "mecha_smartgun"
	equip_state = "mech-shot"
	magazine_type = /obj/item/ammo_magazine/walker/smartgun
	burst = 2
	fire_delay = 6

/obj/item/walker_hardpoint/gun/hmg
	name = "M30 Machine Gun"
	desc = "High-caliber machine gun firing small bursts of AP bullets, tearing into shreds unfortunate fellas on its way."
	icon_state = "mecha_machinegun"
	equip_state = "mech-gatt"
	fire_sound = 'sound/weapons/guns/fire/minigun.ogg'
	magazine_type = /obj/item/ammo_magazine/walker/hmg
	fire_delay = 20
	burst = 3

/obj/item/walker_hardpoint/gun/flamer
	name = "F40 \"Hellfire\" Flamethower"
	desc = "Powerful flamethower, that can send any unprotected target straight to hell."
	icon_state = "mecha_flamer"
	equip_state = "mech-flam"
	fire_sound = 'sound/weapons/guns/fire/flamethrower2.ogg'
	magazine_type = /obj/item/ammo_magazine/walker/flamer
	var/burnlevel = 50
	var/burntime = 27
	var/max_range = 6
	fire_delay = 30

/obj/item/walker_hardpoint/gun/flamer/active_effect(var/atom/target)
	if(ammo.current_rounds <= 0 || !ammo)
		to_chat(owner.pilot, "<span class='warning'>WARNING! System report: ammunition is depleted!</span>")
		if(ammo)
			ammo.loc = owner.loc
			ammo = null
			visible_message("[owner.name]'s systems deployed used magazine.","")
		return
	if(world.time < last_fire + fire_delay)
		to_chat(owner.pilot, "<span class='warning'>WARNING! System report: weapon is not ready to fire again!</span>")
		return
	last_fire = world.time
	var/list/turf/turfs = getline(owner, target)
	playsound(owner, fire_sound, 50, 1)
	ammo.current_rounds--
	var/distance = 1
	var/turf/prev_T

	for(var/F in turfs)
		var/turf/T = F

		if(T == owner.loc)
			prev_T = T
			continue
		if((T.density && !istype(T, /turf/closed/wall/resin)) || isspaceturf(T))
			break
		if(distance > max_range)
			break

		var/blocked = FALSE
		for(var/obj/O in T)
			if(O.density && !O.throwpass && !(O.flags_atom & ON_BORDER))
				blocked = TRUE
				break

		var/turf/TF
		if(!prev_T.Adjacent(T) && (T.x != prev_T.x || T.y != prev_T.y)) //diagonally blocked, it will seek for a cardinal turf by the former target.
			blocked = TRUE
			var/turf/Ty = locate(prev_T.x, T.y, prev_T.z)
			var/turf/Tx = locate(T.x, prev_T.y, prev_T.z)
			for(var/turf/TB in shuffle(list(Ty, Tx)))
				if(prev_T.Adjacent(TB) && ((!TB.density && !isspaceturf(T)) || istype(T, /turf/closed/wall/resin)))
					TF = TB
					break
			if(!TF)
				break
		else
			TF = T

		flame_turf(TF,owner.pilot, burntime, burnlevel)
		if(blocked)
			break
		distance++
		prev_T = T
		sleep(1)

	to_chat(owner.pilot , "<span class='warning'>[name] fired! [ammo.current_rounds]/[ammo.max_rounds] charges remaining!")

	if(ammo.current_rounds <= 0 || !ammo)
		to_chat(owner.pilot, "<span class='warning'>WARNING! System report: ammunition is depleted!</span>")
		ammo.loc = owner.loc
		ammo = null
		visible_message("[owner.name]'s systems deployed used magazine.","")
		return

/obj/item/walker_hardpoint/gun/flamer/proc/flame_turf(turf/T, mob/living/user, heat, burn, f_color = "red")
	to_chat(user , "Flaming turf")
	if(!istype(T))
		return

	T.ignite(heat, burn, f_color)

	// Melt a single layer of snow
	if(istype(T, /turf/open/floor/plating/ground/snow))
		var/turf/open/floor/plating/ground/snow/S = T

		if (S.slayer > 0)
			S.slayer -= 1
			S.update_icon(1, 0)

	for(var/obj/structure/jungle/vines/V in T)
		qdel(V)

	var/fire_mod
	for(var/mob/living/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)
			continue

		fire_mod = 1

		if(isxeno(M))
			var/mob/living/carbon/xenomorph/X = M
			if(X.xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
				continue
			fire_mod = CLAMP(X.xeno_caste.fire_resist + X.fire_resist_modifier, 0, 1)
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M //fixed :s

			if(user)
				var/area/A = get_area(user)
				if(!user.mind?.bypass_ff && !H.mind?.bypass_ff && user.faction == H.faction)
					log_combat(user, H, "shot", src)
					msg_admin_ff("[ADMIN_TPMONTY(owner.pilot)] shot [ADMIN_TPMONTY(H)] with \a [name] in [ADMIN_VERBOSEJMP(A)].")
				else
					log_combat(user, H, "shot", src)
					msg_admin_attack("[ADMIN_TPMONTY(owner.pilot)] shot [ADMIN_TPMONTY(H)] with \a [name] in [ADMIN_VERBOSEJMP(A)].")

			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || (istype(H.wear_suit, /obj/item/clothing/suit/storage/marine/M35) && istype(H.head, /obj/item/clothing/head/helmet/marine/pyro)))
				continue

		var/armor_block = M.run_armor_check(null, "fire")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || (istype(H.wear_suit, /obj/item/clothing/suit/storage/marine/M35) && istype(H.head, /obj/item/clothing/head/helmet/marine/pyro)))
				H.show_message(text("Your suit protects you from most of the flames."), 1)
				armor_block = CLAMP(armor_block * 1.5, 0.75, 1) //Min 75% resist, max 100%
		M.apply_damage(rand(burn,(burn*2))* fire_mod, BURN, null, armor_block) // Make it so its the amount of heat or twice it for the initial blast.

		M.adjust_fire_stacks(rand(5,burn*2))
		M.IgniteMob()

		to_chat(M, "[isxeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!")

///////////////////
// WEAPON AMMO	 //
///////////////////

/obj/item/ammo_magazine/walker
	w_class = WEIGHT_CLASS_BULKY

/obj/item/ammo_magazine/walker/smartgun
	name = "M56 Double-Barrel Magazine (Standart)"
	desc = "A armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "big_ammo_box"
	default_ammo = /datum/ammo/bullet/smartgun/walker
	max_rounds = 700
	gun_type = /obj/item/walker_hardpoint/gun/smartgun

/obj/item/ammo_magazine/walker/smartgun/ap
	name = "M56 Double-Barrel Magazine (AP)"
	desc = "A armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "big_ammo_box_ap"
	default_ammo = /datum/ammo/bullet/smartgun/walker/ap
	max_rounds = 500
	gun_type = /obj/item/walker_hardpoint/gun/smartgun

/obj/item/ammo_magazine/walker/smartgun/incendiary
	name = "M56 Double-Barrel \"Scorcher\" Magazine"
	desc = "A armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "ammoboxslug"
	default_ammo = /datum/ammo/bullet/smartgun/walker/incendiary
	max_rounds = 500
	gun_type = /obj/item/walker_hardpoint/gun/smartgun

/obj/item/ammo_magazine/walker/hmg
	name = "M30 Machine Gun Magazine"
	desc = "A armament M30 magazine"
	icon_state = "ua571c"
	max_rounds = 300
	default_ammo = /datum/ammo/bullet/minigun
	gun_type = /obj/item/walker_hardpoint/gun/hmg

/obj/item/ammo_magazine/walker/flamer
	name = "F40 Canister"
	desc = "Canister for mounted flamethower"
	icon_state = "flametank_large"
	max_rounds = 40
	default_ammo = /datum/ammo/flamethrower
	gun_type = /obj/item/walker_hardpoint/gun/flamer

///////////////////
// WALKER ARMOR	 //
///////////////////

/obj/item/walker_hardpoint/armor
	name = "walker armor"
	w_class = WEIGHT_CLASS_BULKY

	var/move_delay = 0

	var/list/damage_thresholds = list(
		"face" = 0,
		"faceflank" = 0,
		"flank" = 0,
		"behind" = 0
		)
	var/list/dmg_multipliers = list(
		"all" = 0.0, //for when you want to make it invincible
		"acid" = 0.0,
		"slash" = 0.0,
		"bullet" = 0.0,
		"explosive" = 0.0,
		"blunt" = 0.0,
		"energy" = 0.0,
		"abstract" = 0.0) //abstract for when you just want to hurt it


/obj/item/walker_hardpoint/armor/proc/apply_effect()
	if(!owner)
		return

	owner.move_delay += move_delay

	owner.damage_threshold["face"] += damage_thresholds["face"]
	owner.damage_threshold["faceflank"] += damage_thresholds["faceflank"]
	owner.damage_threshold["flank"] += damage_thresholds["flank"]
	owner.damage_threshold["behind"] += damage_thresholds["behind"]

	owner.dmg_multipliers["acid"] += dmg_multipliers["acid"]
	owner.dmg_multipliers["slash"] += dmg_multipliers["slash"]
	owner.dmg_multipliers["bullet"] += dmg_multipliers["bullet"]
	owner.dmg_multipliers["explosive"] += dmg_multipliers["explosive"]
	owner.dmg_multipliers["blunt"] += dmg_multipliers["blunt"]
	owner.dmg_multipliers["energy"] += dmg_multipliers["energy"]

/obj/item/walker_hardpoint/armor/proc/remove_effect()
	if(!owner)
		return

	owner.move_delay -= move_delay

	owner.damage_threshold["face"] -= damage_thresholds["face"]
	owner.damage_threshold["faceflank"] -= damage_thresholds["faceflank"]
	owner.damage_threshold["flank"] -= damage_thresholds["flank"]
	owner.damage_threshold["behind"] -= damage_thresholds["behind"]

	owner.dmg_multipliers["acid"] -= dmg_multipliers["acid"]
	owner.dmg_multipliers["slash"] -= dmg_multipliers["slash"]
	owner.dmg_multipliers["bullet"] -= dmg_multipliers["bullet"]
	owner.dmg_multipliers["explosive"] -= dmg_multipliers["explosive"]
	owner.dmg_multipliers["blunt"] -= dmg_multipliers["blunt"]
	owner.dmg_multipliers["energy"] -= dmg_multipliers["energy"]

/obj/item/walker_hardpoint/armor/light
	name = "LA-14 \"Scatterpack\" Armor"
	desc = "Light armor, usually used for scout walkers"
	icon_state = "light"
	equip_state = "light"

	move_delay = -2

	damage_thresholds = list(
		"face" = -15,
		"faceflank" = -10,
		"flank" = 0,
		"behind" = 5
		)

	dmg_multipliers = list(
		"all" = 0.0, //for when you want to make it invincible
		"acid" = 0.2,
		"slash" = -0.2,
		"bullet" = 0.6,
		"explosive" = 2.0,
		"blunt" = 0.5,
		"energy" = 1.0,
		"abstract" = 0.0) //abstract for when you just want to hurt it

/obj/item/walker_hardpoint/armor/heavy
	name = "HA-2 \"Raptor\" Armor"
	desc = "Heavy armor, usually used for assault or defensive walkers"
	icon_state = "heavy"
	equip_state = "heavy"

	move_delay = 3

	damage_thresholds = list(
		"face" = 5,
		"faceflank" = 0,
		"flank" = 5,
		"behind" = 10
		)

	dmg_multipliers = list(
		"all" = 0.0, //for when you want to make it invincible
		"acid" = 0.4,
		"slash" = -0.4,
		"bullet" = -0.2,
		"explosive" = -2.0,
		"blunt" = -0.1,
		"energy" = -0.5,
		"abstract" = 0.0) //abstract for when you just want to hurt it

/obj/item/walker_hardpoint/armor/acid
	name = "Civilian-grade Hazmat Armor"
	desc = "Not armor per se, used mostly by civilian walkers. How this even got here?"
	icon_state = "chem"
	equip_state = "chem"

	move_delay = 2

	damage_thresholds = list(
		"face" = -5,
		"faceflank" = -5,
		"flank" = -5,
		"behind" = -15
		)

	dmg_multipliers = list(
		"all" = 0.0, //for when you want to make it invincible
		"acid" = -0.5,
		"slash" = 0.4,
		"bullet" = 0.2,
		"explosive" = 2.0,
		"blunt" = 0.8,
		"energy" = 1.5,
		"abstract" = 0.0) //abstract for when you just want to hurt it
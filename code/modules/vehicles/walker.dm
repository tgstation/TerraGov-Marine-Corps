/////////////////
// Walker
/////////////////

/obj/vehicle/walker
	name = "CW13 \"Megalodon\" Assault Walker"
	desc = "Relatively new combat walker of \"Megalodon\"-series. Unlike its predecessor, \"Carharodon\"-series, slower, but relays on its tough armor and rapid-firing weapons."
	icon = 'icons/obj/vehicles/Mecha.dmi'
	icon_state = "mecha-open"
	layer = LYING_MOB_LAYER
	opacity = TRUE
	can_buckle = FALSE
	move_delay = 4

	var/lights = FALSE
	var/lights_power = 8
	var/zoom = FALSE
	var/zoom_size = 14

	health = 400
	maxhealth = 400

	var/mob/pilot = null

	var/list/dmg_multipliers = list(
		"all" = 1.0, //for when you want to make it invincible
		"acid" = 1.0,
		"slash" = 0.9,
		"bullet" = 0.4,
		"explosive" = 5.0,
		"blunt" = 0.1,
		"energy" = 1.4,
		"abstract" = 1.0) //abstract for when you just want to hurt it

	var/max_angle = 45
	var/obj/item/walker_gun/left = null
	var/obj/item/walker_gun/right = null
	var/selected = 1					//0 - right, 1 - left

/obj/vehicle/walker/update_icon()
	if(!pilot)
		icon_state = "mecha-open"
	else
		icon_state = "mecha"

/obj/vehicle/walker/examine(mob/user)
	..()
	var/integrity = round(health/maxhealth*100)
	switch(integrity)
		if(85 to 100)
			to_chat(usr, "It's fully intact.")
		if(65 to 85)
			to_chat(usr, "It's slightly damaged.")
		if(45 to 65)
			to_chat(usr, "It's badly damaged.")
		if(25 to 45)
			to_chat(usr, "It's heavily damaged.")
		else
			to_chat(usr, "It's falling apart.")
	to_chat(usr, "[left ? left.name : "Nothing"] is placed on its left hardpoint.")
	to_chat(usr, "[right ? right.name : "Nothing"] is placed on its right hardpoint.")

/obj/vehicle/walker/relaymove(mob/user, direction)
	if(user.is_mob_incapacitated())
		return
	if(world.time > l_move_time + move_delay)
		if(dir != direction)
			l_move_time = world.time
			dir = direction
			pick(playsound(src.loc, 'sound/mecha/powerloader_turn.ogg', 25, 1), playsound(src.loc, 'sound/mecha/powerloader_turn2.ogg', 25, 1))
			. = TRUE
		else
			. = step(src, direction)
			if(.)
				pick(playsound(loc, 'sound/mecha/powerloader_step.ogg', 25), playsound(loc, 'sound/mecha/powerloader_step2.ogg', 25))

/obj/vehicle/walker/Bump(var/atom/obstacle)
	if(istype(obstacle, /obj/machinery/door))
		var/obj/machinery/door/door = obstacle
		if(door.allowed(pilot))
			door.open()
		else
			flick("door_deny", door)

//Breaking stuff
	else if(istype(obstacle, /obj/structure/fence))
		var/obj/structure/fence/F = obstacle
		F.visible_message("<span class='danger'>[src.name] smashes through [F]!</span>")
		F.health = 0
		F.healthcheck()
	else if(istype(obstacle, /obj/structure/table))
		var/obj/structure/table/T = obstacle
		T.visible_message("<span class='danger'>[src.name] crushes [T]!</span>")
		T.destroy_structure(TRUE)
	else if(istype(obstacle, /obj/structure/showcase))
		var/obj/structure/showcase/S = obstacle
		S.visible_message("<span class='danger'>[src.name] bulldozes over [S]!</span>")
		S.destroy_structure(TRUE)
	else if(istype(obstacle, /obj/structure/rack))
		var/obj/structure/rack/R = obstacle
		R.visible_message("<span class='danger'>[src.name] smashes through the [R]!</span>")
		R.destroy_structure(TRUE)
	else if(istype(obstacle, /obj/structure/window/framed))
		var/obj/structure/window/framed/W = obstacle
		W.visible_message("<span class='danger'>[src.name] crashes through the [W]!</span>")
		W.shatter_window(1)
	else if(istype(obstacle, /obj/structure/window_frame))
		var/obj/structure/window_frame/WF = obstacle
		WF.visible_message("<span class='danger'>[src.name] runs over the [WF]!</span>")
		WF.Destroy()
	else
		..()

/obj/vehicle/walker/Bumped(var/atom/A)
	..()

	if(istype(A, /mob/living/carbon/Xenomorph/Crusher))

		var/mob/living/carbon/Xenomorph/Crusher/C = A

		if(C.charge_speed < C.charge_speed_max/(1.1)) //Arbitrary ratio here, might want to apply a linear transformation instead
			return

		health -= 50 * dmg_multipliers["blunt"]
		healthcheck()

/obj/vehicle/walker/verb/enter_walker()
	set category = "Object"
	set name = "Enter Into Walker"
	set src in oview(1)

	if(usr.mind && usr.mind.cm_skills && usr.mind.cm_skills.powerloader)
		move_in(usr)
	else
		to_chat(usr, "How to operate it?")

/obj/vehicle/walker/proc/move_in(mob/living/carbon/user)
	if(!ishuman(user))
		return
	if(pilot)
		to_chat(user, "There is someone occupying mecha right now.")
		return
	var/mob/living/carbon/human/H = user
	for(var/ID in list(H.get_active_hand(), H.wear_id, H.belt))
		if(operation_allowed(ID))
			pilot = user
			user.loc = src
			pilot.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
			pilot.set_interaction(src)
			update_icon()
			return

	to_chat(user, "Access denied.")

/obj/vehicle/walker/proc/operation_allowed(obj/item/card/id/I)
	if(istype(I) && I.access && ACCESS_MARINE_TANK in I.access)
		return TRUE
	return FALSE

/obj/vehicle/walker/verb/eject()
	set name = "Eject"
	set category = "Walker Interface"
	set src = usr.loc

	move_out()

/obj/vehicle/walker/proc/move_out()
	if(!pilot)
		return FALSE
	if(health <= 0)
		to_chat(pilot, "<span class='danger'>ALERT! Chassis integrity failing. Systems shutting down.</span>")
	if(zoom)
		zoom_activate()
	pilot.client.mouse_pointer_icon = initial(pilot.client.mouse_pointer_icon)
	pilot.loc = src.loc
	pilot = null
	update_icon()
	return TRUE

/obj/vehicle/walker/verb/lights()
	set name = "Lights on/off"
	set category = "Walker Interface"
	set src = usr.loc

	handle_lights()

/obj/vehicle/walker/proc/handle_lights()
	if(lights)
		lights = FALSE
		SetLuminosity(lights_power)
	else
		lights = TRUE
		SetLuminosity(initial(luminosity))
	pilot << sound('sound/mecha/imag_enh.ogg',volume=50)

/obj/vehicle/walker/verb/deploy_magazine()
	set name = "Deploy Magazine"
	set category = "Walker Interface"
	set src = usr.loc

	if(selected)
		if(!left.ammo)
			return
		else
			left.ammo.loc = src.loc
			left.ammo = null
			to_chat(pilot, "<span class='warning'>WARNING! [left.name] ammo magazine deployed.</span>")
			visible_message("[name]'s systems deployed used magazine.","")
	else
		if(!right.ammo)
			return
		else
			right.ammo.loc = src.loc
			right.ammo = null
			to_chat(pilot, "<span class='warning'>WARNING! [right.name] ammo magazine deployed.</span>")
			visible_message("[name]'s systems deployed used magazine.","")

/obj/vehicle/walker/verb/get_stats()
	set name = "Status Display"
	set category = "Walker Interface"
	set src = usr.loc

	if(usr != pilot)
		return
	pilot << browse(get_stats_html(), "window=exosuit")

/obj/vehicle/walker/verb/select_weapon()
	set name = "Select Weapon"
	set category = "Walker Interface"
	set src = usr.loc

	if(selected)
		if(right == null)
			return
		selected = !selected
	else
		if(left == null)
			return
		selected = !selected
	to_chat(usr, "Selected [selected ? "left" : "right"] hardpoint")

/obj/vehicle/walker/handle_click(var/mob/living/user, var/atom/A, var/list/mods)
	if(!firing_arc(A))
		return
	if(left && right && istype(left, right))						//NEED MORE DAKKA
		left.active_effect(A)
		right.active_effect(A)
		return
	if(selected)
		if(!left)
			return
		left.active_effect(A)
	else
		if(!right)
			return
		right.active_effect(A)

/obj/vehicle/walker/proc/firing_arc(var/atom/A)
	var/turf/T = get_turf(A)
	var/dx = T.x - src.x
	var/dy = T.y - src.y
	var/deg = 0
	switch(dir)
		if(EAST) deg = 0
		if(NORTH) deg = -90
		if(WEST) deg = -180
		if(SOUTH) deg = -270

	var/nx = dx * cos(deg) - dy * sin(deg)
	var/ny = dx * sin(deg) + dy * cos(deg)
	if(nx == 0)
		return max_angle >= 90
	var/angle = arctan(ny/nx)
	if(nx < 0)
		angle += 180
	return abs(angle) <= max_angle

/obj/vehicle/walker/proc/zoom_activate()
	if(zoom)
		pilot.client.change_view(world.view)//world.view - default mob view size
		zoom = FALSE
	else
		pilot.client.change_view(world.view)//world.view - default mob view size
		pilot.client.change_view(zoom_size)
		pilot << sound('sound/mecha/imag_enh.ogg',volume=50)
		zoom = TRUE
	to_chat(pilot, "Notification. Cameras zooming [zoom ? "activated" : "deactivated"].")

/////////////////
// Attackby
/////////////////

/obj/vehicle/walker/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/ammo_magazine/walker))
		if(istype(W, left.magazine_type) && left && !left.ammo)
			if(!do_after(user, 10, needhand = FALSE, show_busy_icon = TRUE))
				to_chat(user, "Your action was interrupted.")
				return
			user.drop_held_item()
			W.loc = left
			left.ammo = W
			to_chat(user, "You install magazine in [left.name].")
			return
		else if(istype(W, right.magazine_type) && right && !right.ammo)
			if(!do_after(user, 10, needhand = FALSE, show_busy_icon = TRUE))
				to_chat(user, "Your action was interrupted.")
				return
			user.drop_held_item()
			W.loc = right
			right.ammo = W
			to_chat(user, "You install magazine in [right.name].")
			return
		else
			to_chat(user, "You cannot fit that magazine in any weapon.")
			return

	if(istype(W, /obj/item/walker_gun))
		if(!left)
			to_chat(user, "You start mounting [W.name] on left hardpoint.")
			if(do_after(user, 100, needhand = FALSE, show_busy_icon = TRUE))
				user.drop_held_item()
				W.loc = src
				left = W
				left.owner = src
				to_chat(user, "You mount [W.name] on left hardpoint.")
				return
			else
				to_chat(user, "Mounting has been interrupted.")
				return
		else if(!right)
			to_chat(user, "You start mounting [W.name] on right hardpoint.")
			if(do_after(user, 100, needhand = FALSE, show_busy_icon = TRUE))
				user.drop_held_item()
				W.loc = src
				right = W
				right.owner = src
				to_chat(user, "You mount [W.name] on right hardpoint.")
				return
			else
				to_chat(user, "Mounting has been interrupted.")
				return
		else
			to_chat(user, "All hardpoints already taken.")
			return

	if(iswelder(W))
		var/obj/item/tool/weldingtool/weld = W
		if(!weld.isOn())
			return
		if(health >= maxhealth)
			to_chat(user, "Armor seems fully intact.")
		to_chat(user, "You start repairing broken part of [src.name]'s armor...")
		if(do_after(user, 1000, needhand = FALSE, show_busy_icon = TRUE))
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer >= SKILL_ENGINEER_ENGI)
				to_chat(user, "You haphazardly weld together chunks of broken armor.")
				health += 10
				healthcheck()
			else
				health += 50
				healthcheck()
				to_chat(user, "You repair broken part of the armor.")
			playsound(src.loc, 'sound/items/weldingtool_weld.ogg', 25)
			if(pilot)
				to_chat(pilot, "Notification.Armor partly restored.")
			return


/obj/vehicle/walker/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.a_intent == "hurt")
		var/damage = round(rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper) * dmg_multipliers["slash"])
		M.animation_attack_on(src)
		playsound(loc, "alien_claw_metal", 25, 1)
		M.flick_attack_overlay(src, "slash")
		if(damage <= 5)
			visible_message("<span class='danger'>[M] slashes [src], but only manages scratch its armor!</span>", "You hear slash")
			to_chat(pilot, "<span class='danger'>ALERT! Hostile incursion detected. Deflected.</span>")
			return
		else
			visible_message("<span class='danger'>[M] slashes [src]</span>", "You hear slash")
			to_chat(pilot, "<span class='danger'>ALERT! Hostile incursion detected. Chassis taking damage.</span>")
			health -= damage
			healthcheck()
	else
		attack_hand(M)

/obj/vehicle/walker/healthcheck()
	if(health > maxhealth)
		health = maxhealth
		return
	if(health <= 0)
		move_out()
		if(istype(left, /obj/item/walker_gun/flamer) && left.ammo.current_rounds > 0 || istype(right, /obj/item/walker_gun/flamer) && right.ammo.current_rounds > 0)
			visible_message("[src] napalm exploded!", "You hear blast")
			explosion(get_turf(src), 0, 0, 1, 3)
			new /obj/flamer_fire(get_turf(src), 20, 20, fire_spread_amount = 2)
		new /obj/structure/walker_wreckage(src.loc)
		playsound(loc, 'sound/effects/metal_crash.ogg', 75)
		qdel(src)

/obj/vehicle/walker/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return

	var/damage = Proj.damage
	switch(Proj.ammo.damage_type)
		if(BRUTE)
			if(Proj.ammo.flags_ammo_behavior & AMMO_ROCKET)
				damage *= dmg_multipliers["exposive"]
			else
				damage *= dmg_multipliers["bullet"]
		if(BURN)
			if(Proj.ammo.flags_ammo_behavior & AMMO_XENO_ACID)
				damage *= dmg_multipliers["acid"]
			else
				damage *= dmg_multipliers["energy"]
		if(TOX, OXY, CLONE)
			return

	if(damage > 15)
		to_chat(pilot, "<span class='danger'>ALERT! Hostile incursion detected. Chassis taking damage.</span>")
		health -=damage
		healthcheck()
	else
		to_chat(pilot, "<span class='danger'>ALERT! Hostile incursion detected. Deflected.</span>")

/////////////////
// WEAPONS
/////////////////

/obj/item/walker_gun
	name = "walker gun"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_equip"
	var/obj/vehicle/walker/owner = null
	var/magazine_type = /obj/item/ammo_magazine/walker
	var/obj/item/ammo_magazine/walker/ammo = null
	var/fire_sound = "gun_smartgun"
	var/fire_delay = 0
	var/can_fire = TRUE
	var/burst = 1

	var/muzzle_flash 	= "muzzle_flash"
	var/muzzle_flash_lum = 3 //muzzle flash brightness

/obj/item/walker_gun/proc/handle_delay()
	can_fire = TRUE

/obj/item/walker_gun/proc/active_effect(var/atom/target)
	if(ammo.current_rounds <= 0 || !ammo)
		to_chat(owner.pilot, "<span class='warning'>WARNING! System report: ammunition is depleted!</span>")
		if(ammo)
			ammo.loc = owner.loc
			ammo = null
			visible_message("[owner.name]'s systems deployed used magazine.","")
		return
	if(!can_fire)
		to_chat(owner.pilot, "<span class='warning'>WARNING! System report: weapon is not ready to fire again!</span>")
		return
	if(fire_delay)
		can_fire = FALSE
		addtimer(CALLBACK(src, .proc/handle_delay), fire_delay)
	var/obj/item/projectile/P
	for(var/i = 1 to burst)
		if(!owner.firing_arc(target))
			if(i == 1)
				return
			to_chat(owner.pilot , "<span class='warning'>[name] fired! [ammo.current_rounds]/[ammo.max_rounds] remaining!")
			visible_message("<span class='danger'>[owner.name] fires from [name]!</span>", "<span class='warning'>You hear [istype(P.ammo, /datum/ammo/bullet) ? "gunshot" : "blast"]!</span>")
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
	to_chat(owner.pilot , "<span class='warning'>[name] fired! [ammo.current_rounds]/[ammo.max_rounds] remaining!")
	visible_message("<span class='danger'>[owner.name] fires from [name]!</span>", "<span class='warning'>You hear [istype(P.ammo, /datum/ammo/bullet) ? "gunshot" : "blast"]!</span>")

	var/angle = round(Get_Angle(owner,target))
	muzzle_flash(angle,owner)

	if(ammo.current_rounds <= 0)
		ammo.loc = owner.loc
		ammo = null
		visible_message("[owner.name]'s systems deployed used magazine.","")

/obj/item/walker_gun/smartgun
	name = "M56 Double-Barrel Mounted Smartgun"
	desc = "Modifyed version of standart USCM Smartgun System, mounted on military walkers"
	icon_state = "mecha_scatter"
	magazine_type = /obj/item/ammo_magazine/walker/smartgun
	burst = 2
	fire_delay = 6

/obj/item/walker_gun/hmg
	name = "M30 Machine Gun"
	desc = "High-caliber machine gun firing small bursts of AP bullets, tearing into shreds unfortunate fellas on its way."
	icon_state = "mecha_scatter"
	fire_sound = 'sound/weapons/gun_minigun.ogg'
	magazine_type = /obj/item/ammo_magazine/walker/hmg
	fire_delay = 20
	burst = 5

/obj/item/walker_gun/flamer
	name = "F40 \"Hellfire\" Flamethower"
	desc = "Powerful flamethower, that can send any unprotected target straight to hell."
	icon_state = "mecha_exting"
	fire_sound = 'sound/weapons/gun_flamethrower2.ogg'
	magazine_type = /obj/item/ammo_magazine/walker/flamer
	var/burnlevel = 24
	var/burntime = 17
	var/max_range = 6
	fire_delay = 30

/obj/item/walker_gun/flamer/active_effect(var/atom/target)
	if(ammo.current_rounds <= 0 || !ammo)
		to_chat(owner.pilot, "<span class='warning'>WARNING! System report: ammunition is depleted!</span>")
		if(ammo)
			ammo.loc = owner.loc
			ammo = null
			visible_message("[owner.name]'s systems deployed used magazine.","")
		return
	if(!can_fire)
		to_chat(owner.pilot, "<span class='warning'>WARNING! System report: weapon is not ready to fire again!</span>")
		return
	if(fire_delay)
		can_fire = FALSE
		addtimer(CALLBACK(src, .proc/handle_delay), fire_delay)
	var/list/turf/turfs = getline2(owner,target)
	playsound(owner, fire_sound, 50, 1)
	var/distance = 1
	var/turf/prev_T

	for(var/turf/T in turfs)
		if(T == owner.loc)
			prev_T = T
			continue
		if(loc != owner)
			break
		if(!ammo || !ammo.current_rounds)
			break
		if(distance > max_range)
			break
		if(prev_T && LinkPreBlocksFire(prev_T, T))
			break
		ammo.current_rounds--
		flame_turf(T,owner.pilot, burntime, burnlevel)
		if(PostBlocksFire(T))
			break
		distance++
		prev_T = T
		sleep(1)

	if(ammo.current_rounds <= 0 || !ammo)
		to_chat(owner.pilot, "<span class='warning'>WARNING! System report: ammunition is depleted!</span>")
		ammo.loc = owner.loc
		ammo = null
		visible_message("[owner.name]'s systems deployed used magazine.","")
		return

/obj/item/ammo_magazine/walker/smartgun
	name = "M56 Double-Barrel Magazine"
	desc = "A armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "big_ammo_box"
	w_class = 12
	default_ammo = /datum/ammo/bullet/smartgun
	max_rounds = 700
	gun_type = /obj/item/walker_gun/smartgun

/obj/item/ammo_magazine/walker/hmg
	name = "M30 Machine Gun Magazine"
	desc = "A armament M30 magazine"
	icon_state = "ua571c"
	max_rounds = 300
	default_ammo = /datum/ammo/bullet/minigun
	gun_type = /obj/item/walker_gun/hmg

/obj/item/ammo_magazine/walker/flamer
	name = "F40 Canister"
	desc = "Canister for mounted flamethower"
	icon_state = "flametank_large"
	max_rounds = 40
	default_ammo = /datum/ammo/flamethrower
	gun_type = /obj/item/walker_gun/flamer

/////////////////
// WEAPON RELATED PROCS
/////////////////
//Mostly copypastes

/obj/item/walker_gun/proc/muzzle_flash(angle, var/x_offset = 0, var/y_offset = 5)
	if(!muzzle_flash ||  isnull(angle))
		return //We have to check for null angle here, as 0 can also be an angle.
	if(!istype(owner) || !istype(owner.loc,/turf))
		return

	if(owner.luminosity <= muzzle_flash_lum)
		owner.SetLuminosity(muzzle_flash_lum)
		spawn(10)
			owner.SetLuminosity(-muzzle_flash_lum)

	if(prob(65)) //Not all the time.
		var/image_layer = (owner && owner.dir == SOUTH) ? MOB_LAYER+0.1 : MOB_LAYER-0.1
		var/image/I = image('icons/obj/items/projectiles.dmi',owner,muzzle_flash,image_layer)
		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(x,y)
		rotate.Turn(angle)
		I.transform = rotate

		flick_overlay_view(I, owner, 3)

/obj/item/walker_gun/proc/simulate_scatter(var/atom/target, obj/item/projectile/projectile_to_fire)
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

/obj/item/walker_gun/flamer/proc/flame_turf(turf/T, mob/living/user, heat, burn, f_color = "red")
	if(!istype(T))
		return

	for(var/obj/flamer_fire/F in T) // No stacking flames!
		qdel(F)

	new /obj/flamer_fire(T, heat, burn, f_color)

	// Melt a single layer of snow
	if(istype(T, /turf/open/snow))
		var/turf/open/snow/S = T

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

		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/X = M
			if(X.xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
				continue
			fire_mod = X.xeno_caste.fire_resist + X.fire_resist_modifier
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M //fixed :s

			if(user)
				if(user.mind && !user.mind.special_role && H.mind && !H.mind.special_role)
					log_combat(user, H, "shot", src)
					msg_admin_ff("[key_name(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[usr]'>FLW</a>) shot [key_name(H)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[H]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[H]'>FLW</a>) with \a [name] in [get_area(user)]")
				else
					log_combat(user, H, "shot", src)
					msg_admin_attack("[key_name(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[usr]'>FLW</a>) shot [key_name(H)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[H]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[H]'>FLW</a>) with \a [name] in [get_area(user)]")

			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || (istype(H.wear_suit, /obj/item/clothing/suit/storage/marine/M35) && istype(H.head, /obj/item/clothing/head/helmet/marine/pyro)))
				continue

		var/armor_block = M.run_armor_check(null, "energy")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || (istype(H.wear_suit, /obj/item/clothing/suit/storage/marine/M35) && istype(H.head, /obj/item/clothing/head/helmet/marine/pyro)))
				H.show_message(text("Your suit protects you from the flames."),1)
				armor_block = CLAMP(armor_block * 1.5, 0.75, 1) //Min 75% resist, max 100%
		M.apply_damage(rand(burn,(burn*2))* fire_mod, BURN, null, armor_block) // Make it so its the amount of heat or twice it for the initial blast.

		M.adjust_fire_stacks(rand(5,burn*2))
		M.IgniteMob()

		to_chat(M, "[isXeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!</span>")

/////////////////
// Stat menu
/////////////////
// Not a stat tab exactly, but just a menu

/obj/vehicle/walker/proc/get_stats_html()
	var/output = {"<html>
						<head><title>[src.name] data</title>
						<style>
						body {color: #00ff00; background: #000000; font-family:"Lucida Console",monospace; font-size: 12px;}
						hr {border: 1px solid #0f0; color: #0f0; background-color: #0f0;}
						a {padding:2px 5px;;color:#0f0;}
						.wr {margin-bottom: 5px;}
						.header {cursor:pointer;}
						.open, .closed {background: #32CD32; color:#000; padding:1px 2px;}
						.links a {margin-bottom: 2px;padding-top:3px;}
						.visible {display: block;}
						.hidden {display: none;}
						</style>
						<script language='javascript' type='text/javascript'>
						[js_byjax]
						[js_dropdowns]
						function ticker() {
						    setInterval(function(){
						        window.location='byond://?src=\ref[src]&update_content=1';
						    }, 1000);
						}

						window.onload = function() {
							dropdowns();
							ticker();
						}
						</script>
						</head>
						<body>
						<center><b>CW13 \"Megalodon\" System Console</b></center><hr>
						<b>Inner systems overview:</b><br><br>
						[get_stats_weapon()]<hr>
						<b>Auxillary systems overview:</b><br><br>
						[get_aux_systems()]<hr>
						</body>
						</html>
					 "}
	return output

/obj/vehicle/walker/proc/get_stats_weapon()
	var/integrity = round(health/maxhealth*100)
	var/left_mount = "LEFT MOUNT NOT FOUND"
	var/right_mount = "RIGHT MOUNT NOT FOUND"
	if(left)
		left_mount = "<b>[left.name]</b>: "
		if(left.ammo)
			left_mount += "[left.ammo.current_rounds]/[left.ammo.max_rounds] rounds"
		else
			left_mount += "AMMO NOT FOUND"
	if(right)
		right_mount = "<b>[right.name]</b>: "
		if(right.ammo)
			right_mount += "[right.ammo.current_rounds]/[right.ammo.max_rounds] rounds<br>"
		else
			right_mount += "AMMO NOT FOUND"
	var/output = {"
						[integrity<30?"<font color='red'><b>DAMAGE LEVEL CRITICAL</b></font><br>":null]
						<b>Integrity: </b> [integrity]%<br>
						[left_mount]<br>
						[right_mount]
					"}
	return output

/obj/vehicle/walker/proc/get_aux_systems()
	var/output = {"
						<b>Zoom:</b> <A href='?src=\ref[src];zoom=1'>[zoom ? "on" : "off"]</A><br>
						<b>Lights:</b> <A href='?src=\ref[src];lights=1'>[lights ? "on" : "off"]</A><br>
						<b><A href='?src=\ref[src];eject=1'>Eject</A></b>
					"}
	return output

/obj/vehicle/walker/Topic(href, href_list)
	..()
	if(href_list["update_content"])
		if(usr != pilot)	return
		send_byjax(pilot,"exosuit.browser","content",get_stats_weapon())
		return
	if(href_list["eject"])
		if(usr != pilot)
			return
		eject()
		return
	if(href_list["lights"])
		handle_lights()
		return
	if(href_list["zoom"])
		zoom_activate()
		return


/obj/structure/walker_wreckage
	name = "CW13 wreckage"
	desc = "Remains of some unfortunate walker. Completely unrepairable."
	icon = 'icons/obj/vehicles/Mecha.dmi'
	icon_state = "mecha-broken"
	density = TRUE
	anchored = TRUE
	opacity = FALSE
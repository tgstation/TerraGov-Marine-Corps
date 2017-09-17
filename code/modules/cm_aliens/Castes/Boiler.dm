//Boiler Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Boiler
	caste = "Boiler"
	name = "Boiler"
	desc = "A huge, grotesque xenomorph covered in glowing, oozing acid slime."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Boiler Walking"
	melee_damage_lower = 12
	melee_damage_upper = 15
	tacklemin = 2
	tacklemax = 4
	tackle_chance = 60
	health = 180
	maxHealth = 180
	storedplasma = 450
	plasma_gain = 30
	maxplasma = 800
	evolution_threshold = 800
	spit_delay = 40
	speed = 0.5
	pixel_x = -16
	caste_desc = "Gross!"
	evolves_to = list()
	mob_size = MOB_SIZE_BIG
	tier = 3
	upgrade = 0
	gib_chance = 100
	drag_delay = 6 //pulling a big dead xeno is hard
	armor_deflection = 20
	var/is_bombarding = 0
	var/obj/item/weapon/grenade/grenade_type = "/obj/item/weapon/grenade/xeno"
	var/bomb_cooldown = 0
	var/datum/effect_system/smoke_spread/xeno_acid/smoke
	var/acid_cooldown = 0
	var/turf/bomb_turf = null

	actions = list(
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid/Boiler,
		/datum/action/xeno_action/bombard,
		/datum/action/xeno_action/toggle_long_range,
		/datum/action/xeno_action/toggle_bomb,
		/datum/action/xeno_action/activable/spray_acid,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		)

	New()
		..()
		SetLuminosity(3)
		smoke = new /datum/effect_system/smoke_spread/xeno_acid
		smoke.attach(src)
		see_in_dark = 20
		ammo = ammo_list[/datum/ammo/xeno/boiler_gas]

	Dispose()
		SetLuminosity(0)
		if(smoke)
			cdel(smoke)
			smoke = null
		. = ..()







/mob/living/carbon/Xenomorph/Boiler/proc/bomb_turf(var/turf/T)
	if(!istype(T) || T.z != src.z || T == get_turf(src))
		src << "<span class='warning'>This is not a valid target.</span>"
		return

	if(!isturf(loc)) //In a locker
		return

	var/turf/U = get_turf(src)

	if(bomb_turf && bomb_turf != U)
		is_bombarding = 0
		if(client)
			client.mouse_pointer_icon = initial(client.mouse_pointer_icon) //Reset the mouse pointer.
		return

	if(!is_bombarding)
		src << "<span class='warning'>You must dig yourself in before you can do this.</span>"
		return

	if(bomb_cooldown)
		src << "<span class='warning'>You are still preparing another spit. Be patient!</span>"
		return

	if(get_dist(T, U) <= 5) //Magic number
		src << "<span class='warning'>You are too close! You must be at least 7 meters from the target due to the trajectory arc.</span>"
		return

	if(!check_plasma(200))
		return

	var/offset_x = rand(-1, 1)
	var/offset_y = rand(-1, 1)

	if(prob(30))
		offset_x = 0
	if(prob(30))
		offset_y = 0

	var/turf/target = locate(T.x + offset_x, T.y + offset_y, T.z)

	if(!istype(target))
		return

	src << "<span class='xenonotice'>You begin building up acid.</span>"
	if(client)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon) //Reset the mouse pointer.
	bomb_cooldown = 1
	is_bombarding = 0
	use_plasma(200)

	if(do_after(src, 50, FALSE))
		bomb_turf = null
		visible_message("<span class='xenowarning'>\The [src] launches a huge glob of acid hurling into the distance!</span>", \
		"<span class='xenowarning'>You launch a huge glob of acid hurling into the distance!</span>")

		var/obj/item/projectile/P = rnew(/obj/item/projectile, loc)
		P.generate_bullet(ammo)
		P.fire_at(target, src, null, ammo.max_range, ammo.shell_speed)
		playsound(src, 'sound/effects/blobattack.ogg', 25, 1)

		spawn(200) //20 seconds cooldown.
			bomb_cooldown = 0
			src << "<span class='notice'>You feel your toxin glands swell. You are able to bombard an area again.</span>"
			for(var/X in actions)
				var/datum/action/A = X
				A.update_button_icon()
		return
	else
		bomb_cooldown = 0
		src << "<span class='warning'>You decide not to launch any acid.</span>"
	return

//Yes, the mortar strikes are grenades. Deal with it (tm)
/obj/item/weapon/grenade/xeno
	desc = "Gross!"
	name = "acid glob"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "acidblob"
	det_time = 8
	flags_atom = FPRINT
	anchored = 1
	density = 0
	var/datum/effect_system/smoke_spread/xeno_acid/smoke

	New()
		..()
		smoke = new /datum/effect_system/smoke_spread/xeno_acid
		smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/blobattack.ogg', 25, 1)
		icon_state = "splatter"
		smoke.set_up(6, 0, usr.loc)
		spawn(0)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
		invisibility = 101
		sleep(20)
		cdel(src)
		return

/datum/effect_system/smoke_spread/xeno_acid
	smoke_type = /obj/effect/particle_effect/smoke/xeno_burn

//Xeno acid smoke.
/obj/effect/particle_effect/smoke/xeno_burn
	time_to_live = 180
	color = "#86B028" //Mostly green?
	anchored = 1

/obj/effect/particle_effect/smoke/xeno_burn/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		affect(M)
	for(var/obj/structure/barricade/B in get_turf(src))
		B.smoke_damage(src)

/obj/effect/particle_effect/smoke/xeno_burn/affect(var/mob/living/carbon/M)
	..()
	if(isXeno(M))
		return
	if(isYautja(M) && prob(75))
		return

	if(M.internal != null && M.wear_mask && (M.wear_mask.flags_inventory & ALLOWINTERNALS) && prob(40))
		M << "<span class='danger'>Your gas mask protects you!</span>"
		return
	else
		if(prob(20))
			M.drop_held_item()
		M.adjustOxyLoss(5)
		M.adjustFireLoss(rand(5,15))
		M.updatehealth()
		if(M.coughedtime != 1 && !M.stat)
			M.coughedtime = 1
			if(prob(50))
				M.emote("cough")
			else
				M.emote("gasp")
			spawn(15)
				M.coughedtime = 0
	M << "<span class='danger'>Your skin feels like it is melting away!</span>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.take_overall_damage(0, rand(10, 15)) //Burn damage, randomizes between various parts //Magic number
	else
		M.burn_skin(5)
	M.updatehealth()
	return

/obj/item/weapon/grenade/xeno_weaken
	desc = "Gross!"
	name = "acid glob"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "acidblob"
	det_time = 8
	flags_atom = FPRINT
	anchored = 1
	var/datum/effect_system/smoke_spread/xeno_weaken/smoke

	New()
		..()
		src.smoke = new /datum/effect_system/smoke_spread/xeno_weaken
		src.smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/blobattack.ogg', 25, 1)
		icon_state = "splatter"
		smoke.set_up(7, 0, usr.loc)
		spawn(0)
			smoke.start()
			sleep(10)
			smoke.start()
		invisibility = 101
		sleep(20)
		cdel(src)

/datum/effect_system/smoke_spread/xeno_weaken
	smoke_type = /obj/effect/particle_effect/smoke/xeno_weak

//Xeno acid smoke.
/obj/effect/particle_effect/smoke/xeno_weak
	time_to_live = 150
	color = "#90dd00" //Mostly light green?

/obj/effect/particle_effect/smoke/xeno_weak/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		affect(M)

/obj/effect/particle_effect/smoke/xeno_weak/affect(var/mob/living/carbon/M)
	..()
	if(isXeno(M))
		return
	if(isYautja(M) && prob(75))
		return

	if(M.stat)
		return

	if(M.internal != null && M.wear_mask && (M.wear_mask.flags_inventory & ALLOWINTERNALS) && prob(75))
		M << "<span class='danger'>Your gas mask protects you!</span>"
		return
	else
		if(M.coughedtime != 1)
			M.coughedtime = 1
			M.emote("gasp")
			M.adjustOxyLoss(1)
			M.KnockDown(2)
			spawn(15)
				M.coughedtime = 0
		if(!M.knocked_down && prob(75))
			spawn(rand(1, 5))
				if(M)
					M.KnockDown(20)
					M.visible_message("<span class='danger'>\The [M] collapses.</span>", \
					"<span class='danger'>You collapse as the gas scalds your nerves.</span>")


/mob/living/carbon/Xenomorph/Boiler/proc/acid_spray(atom/T)
	if(!T) return

	if(!check_state())
		return

	if(acid_cooldown)
		return

	if(!isturf(loc) || istype(loc, /turf/space))
		src << "<span class='warning'>You can't do that from there.</span>"
		return

	if(!check_plasma(10))
		return

	if(T)
		var/turf/target

		if(isturf(T))
			target = T
		else
			target = get_turf(T)

		if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
			return

		if(target == loc)
			src << "<span class='warning'>That's far too close!</span>"
			return

		acid_cooldown = 1
		use_plasma(10)
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1)
		visible_message("<span class='xenowarning'>\The [src] spews forth a virulent spray of acid!</span>", \
		"<span class='xenowarning'>You spew forth a spray of acid!</span>")
		var/turflist = getline(src, target)
		spray_turfs(turflist)
		spawn(90) //12 second cooldown.
			acid_cooldown = 0
			src << "<span class='warning'>You feel your acid glands refill. You can spray <B>acid</b> again.</span>"
			for(var/X in actions)
				var/datum/action/A = X
				A.update_button_icon()
	else
		src << "<span class='warning'>You see nothing to spit at!</span>"


/mob/living/carbon/Xenomorph/Boiler/proc/spray_turfs(turflist)
	if(isnull(turflist))
		return
	var/turf/prev_turf
	var/distance = 0

	for(var/turf/T in turflist)
		distance++
		if(T.density || istype(T, /turf/space))
			break
		if(distance > 7)
			break
		if(DirBlocked(T, dir))
			break
		else if(DirBlocked(T, turn(dir, 180)))
			break
		if(locate(/obj/structure/girder, T))
			break //Nope.avi
		var/obj/structure/mineral_door/resin/D = locate() in T
		if(D)
			if(D.density)
				break
		var/obj/machinery/M = locate() in T
		if(M)
			if(M.density)
				break
		var/obj/structure/window/W = locate() in T
		if(W)
			if(W.is_full_window())
				break
			if(prev_turf)
				if(get_dir(prev_turf,W) == W.dir)
					break

		if(!prev_turf && length(turflist) > 1)
			prev_turf = get_turf(src)
			continue //So we don't burn the tile we be standin on

		if(prev_turf && LinkBlocked(prev_turf, T))
			break

		if(!check_plasma(10))
			break
		storedplasma -= 10
		prev_turf = T
		splat_turf(T)
		sleep(2)


/mob/living/carbon/Xenomorph/Boiler/proc/splat_turf(var/turf/target)
	if(!istype(target) || istype(target,/turf/space))
		return

	if(!locate(/obj/effect/xenomorph/spray) in target) //No stacking flames!
		var/obj/effect/xenomorph/spray/S =  new(target)
		processing_objects.Add(S)
		for(var/mob/living/carbon/M in target)
			if(ishuman(M) || ismonkey(M))
				M.adjustFireLoss(rand(15, 30))
				M << "<span class='xenodanger'>\The [src] showers you in corrosive acid!</span>"
				M.radiation += rand(5, 50)
				if(!isYautja(M))
					if(prob(70))
						M.emote("scream")
					if(prob(40))
						M.KnockDown(rand(3, 8))


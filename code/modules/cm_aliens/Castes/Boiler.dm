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
	health = 190
	maxHealth = 190
	storedplasma = 350
	plasma_gain = 15
	maxplasma = 700
	jellyMax = 0
	spit_delay = 40
	speed = 3
	adjust_pixel_x = -16
	adjust_pixel_y = -6
//	adjust_size_x = 0.9
//	adjust_size_y = 0.8
	caste_desc = "Gross!"
	evolves_to = list()
	var/zoom_timer = 0
	var/is_bombarding = 0
	var/obj/item/weapon/grenade/grenade_type = null
	var/bombard_type = 0
	var/readying_bombard = 0
	var/bomb_cooldown = 0
	var/datum/effect/effect/system/smoke_spread/xeno_acid/smoke
	var/acid_cooldown = 0
	var/prev_turf = null

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/shift_spits,
		/mob/living/carbon/Xenomorph/Boiler/proc/bombard,
		/mob/living/carbon/Xenomorph/Boiler/proc/longrange,
		/mob/living/carbon/Xenomorph/Boiler/proc/toggle_bomb,
		/mob/living/carbon/Xenomorph/Boiler/proc/acid_spray,
		)

	New()
		..()
		SetLuminosity(2)
		smoke = new /datum/effect/effect/system/smoke_spread/xeno_acid
		smoke.attach(src)
		see_in_dark = 20

/mob/living/carbon/Xenomorph/Boiler/ClickOn(var/atom/A, params)
	if(is_zoomed && !is_bombarding && !istype(A,/obj/screen))
		zoom_out()

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		if(A)
			face_atom(A)
			acid_spray(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		if(A)
			face_atom(A)
			acid_spray(A)
		return
	..()

/mob/living/carbon/Xenomorph/Boiler/proc/longrange()
	set name = "Toggle Long Range Sight (20)"
	set desc = "Examines terrain at a distance."
	set category = "Alien"

	if(!check_state()) return

	if(zoom_timer)
		return

	if(is_zoomed)
		zoom_out()
		visible_message("\blue [src] stops looking in the distance.","\blue You stop peering into the distance.")
		return

	if(!check_plasma(20)) return

	zoom_timer = 1
	visible_message("\blue [src] begins looking off into the distance.","\blue You start looking off into the distance.. Hold still!")
	if(do_after(src,20))
		zoom_in()
		spawn(0)
			zoom_timer = 0 //Just so they don't spam it and weird things out
		return
	else
		storedplasma += 50 //Since we stole some already.
	return

/mob/living/carbon/Xenomorph/Boiler/proc/toggle_bomb()
	set name = "Toggle Bombard Type"
	set desc = "Swap between different area attack types."
	set category = "Alien"

	if(!check_state()) return

	switch(bombard_type)
		if(0)
			src << "\blue You will now fire gaseous acid."
			bombard_type = 1
			grenade_type = "/obj/item/weapon/grenade/xeno"
			return
		if(1)
			src << "\blue You will now fire neurotoxic gas."
			bombard_type = 0
			grenade_type = "/obj/item/weapon/grenade/xeno_weaken"
			return

	bombard_type = 0 //Shouldn't really ever happen
	return

/mob/living/carbon/Xenomorph/Boiler/proc/bombard()
	set name = "Bombard (100-200)"
	set desc = "Bombard an area. Use 'Toggle bombard types' to change the effect."
	set category = "Alien"

	if(!check_state()) return

	if(readying_bombard)
		return

	if(is_bombarding)
		if(client)
			client.mouse_pointer_icon = initial(client.mouse_pointer_icon) //Reset the mouse pointer.
		is_bombarding = 0
		return

	if(bomb_cooldown)
		src << "You need to wait 60 seconds in between launches for your acid to refill."
		return

	if(src.z == 0)
		src << "You can't do that from in here."
		return

	if(!istype(get_turf(src),/turf/simulated/floor/gm) || !istype(get_area(src),/area/ground))
		src << "You can only prepare a bombardment from outside."
		return

	if(!check_plasma(100 + (50 * bombard_type)))
		return

	readying_bombard = 1
	visible_message("\blue [src] begins digging their claws into the ground.","\blue You begin preparing a bombardment..")
	if(do_after(src,60))
		readying_bombard = 0
		is_bombarding = 1
		visible_message("\blue [src] digs in!","\blue You get ready to bomb an area! If you move, you must wait again to fire.")
		if(client)
			client.mouse_pointer_icon = file("icons/Xeno/mouse_pointer.dmi") //Sure, why not.
	else
		readying_bombard = 0
		is_bombarding = 0
		if(client)
			client.mouse_pointer_icon = initial(client.mouse_pointer_icon)
		storedplasma += (75 + (25 * bombard_type)) //Refund half the cost if we moved.
	return

/mob/living/carbon/Xenomorph/Boiler/proc/bomb_turf(var/turf/T)
	if(!istype(T) || T.z != src.z || T == get_turf(src))
		src << "That is not a valid target."
		return

	if(src.z == 0) //In a locker
		return

	var/turf/U = get_turf(src)

	if(!is_bombarding)
		src << "You must prepare your stance using Bombard before you can do this."
		return

	if(get_dist(T,U) <= 6)
		src << "You are too close! You must be at least 7 meters from the target, due to the trajectory arc."
		return

	if((!istype(T,/turf/simulated/floor/gm) && !istype(get_area(T),/area/ground)) || istype(get_area(T),/area/ground/caves))
		src << "There's not enough space to launch from in here."
		return

	var/offset_x = rand(-1,1)
	var/offset_y = rand(-1,1)

	if(prob(30))
		offset_x = 0
	if(prob(30))
		offset_y = 0

	var/turf/target = locate(T.x + offset_x, T.y + offset_y, T.z)

	if(!istype(target))
		return

	src << "<B>You begin building up acid..</B>"
	if(client)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon) //Reset the mouse pointer.
	if(do_after(src,70))
		visible_message("\green <B>The [src] launches a huge glob of acid into the distance!</b>","\green <B>You spit a huge glob of acid!</b>")
		target.visible_message("\green <B>A glob of acid falls from the sky!</b>")
		new /obj/effect/xenomorph/splatter(target)
		playsound(target, 'sound/effects/blobattack.ogg', 60, 1)
		if(grenade_type)
			var/obj/item/weapon/grenade/G = new grenade_type(target)
			spawn(7)
				G.prime()
		is_bombarding = 0
		bomb_cooldown = 1
		spawn(600) //60 seconds cooldown.
			bomb_cooldown = 0
			src << "You feel your toxin glands swell. You are able to bombard an area again."
		return
	src << "You decide not to launch any acid."
	return
/*
/mob/living/carbon/Xenomorph/Boiler/proc/splashdown(var/turf/T)
	if(!istype(T)) return

	new /obj/effect/xenomorph/splatterblob(T) //do a splatty splat
	playsound(src.loc, 'sound/effects/blobattack.ogg', 60, 1)
	if(istype(T,/turf/simulated/floor/gm) || istype(get_area(T),/area/ground)) //Rare outdoor nonground turfs.
		for(var/mob/living/carbon/M in orange(2,T))
			spawn(0)
				if(!isXeno(M) && !M.stat && !isYautja(M) && prob(75))
					if(!locate(/obj/effect/xenomorph/splatter) in get_turf(M))
						new /obj/effect/xenomorph/splatter(get_turf(M))
					M.visible_message("\green [M.name] is spattered with acid!","\green <B>You are spattered with vile acid!")
					M.apply_damage(rand(10,30),BURN)
					M.apply_effect(5,IRRADIATE)
	else
		T.visible_message("\green <b>Acid begins to melt through the ceiling!</b>")
		spawn(10)
			for(var/mob/living/carbon/M in T)
				spawn(0)
					if(!isXeno(M) && !M.stat && !isYautja(M) && prob(75))
						if(!locate(/obj/effect/xenomorph/splatter) in get_turf(M))
							new /obj/effect/xenomorph/splatter(get_turf(M))
						M.visible_message("\green [M.name] is spattered with acid!","\green <B>You are spattered with acid!")
						M.apply_damage(rand(5,15),BURN)
						M.apply_effect(5,IRRADIATE)
	return
*/
//Yes, the mortar strikes are grenades. Deal with it (tm)
/obj/item/weapon/grenade/xeno
	desc = "Gross!"
	name = "acid glob"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "splatter"
	det_time = 8
	flags = FPRINT | TABLEPASS
	anchored = 1
	var/datum/effect/effect/system/smoke_spread/xeno_acid/smoke

	New()
		..()
		src.smoke = new /datum/effect/effect/system/smoke_spread/xeno_acid
		src.smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/blobattack.ogg', 50, 1)
		src.smoke.set_up(5, 0, usr.loc)
		spawn(0)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
		invisibility = 101
		sleep(20)
		del(src)
		return

/datum/effect/effect/system/smoke_spread/xeno_acid
	smoke_type = /obj/effect/effect/smoke/xeno_burn

//Xeno acid smoke.
/obj/effect/effect/smoke/xeno_burn
	time_to_live = 150
	color = "#AC8A28" //Mostly green?

/obj/effect/effect/smoke/xeno_burn/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		affect(M)

/obj/effect/effect/smoke/xeno_burn/affect(var/mob/living/carbon/M)
	..()
	if(isXeno(M))
		return
	if(isYautja(M) && prob(50))
		return
	if(M.stat)
		return

	if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS) && prob(40))
		M << "<b>Your gas mask protects you!</b>"
		return
	else
		if (prob(20))
			M.drop_item()
		M.adjustOxyLoss(10)
		M.updatehealth()
		if (M.coughedtime != 1)
			M.coughedtime = 1
			if(prob(50))
				M.emote("cough")
			else
				M.emote("gasp")
			spawn (15)
				M.coughedtime = 0
	M << "\green <b>Your skin burns!</b>"
	if(ishuman(M))
		M:take_overall_damage(0,rand(20,35)) //burn damage, randomizes between various parts
	else
		M.burn_skin(5)
	M.updatehealth()
	return

/obj/item/weapon/grenade/xeno_weaken
	desc = "Gross!"
	name = "acid glob"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "splatter"
	det_time = 8
	flags = FPRINT | TABLEPASS
	anchored = 1
	var/datum/effect/effect/system/smoke_spread/xeno_weaken/smoke

	New()
		..()
		src.smoke = new /datum/effect/effect/system/smoke_spread/xeno_weaken
		src.smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/blobattack.ogg', 50, 1)
		src.smoke.set_up(5, 0, usr.loc)
		spawn(0)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
		invisibility = 101
		sleep(20)
		del(src)
		return

/datum/effect/effect/system/smoke_spread/xeno_weaken
	smoke_type = /obj/effect/effect/smoke/xeno_weak

//Xeno acid smoke.
/obj/effect/effect/smoke/xeno_weak
	time_to_live = 100
	color = "#82BA13" //Mostly green?

/obj/effect/effect/smoke/xeno_weak/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		affect(M)

/obj/effect/effect/smoke/xeno_weak/affect(var/mob/living/carbon/M)
	..()
	if(isXeno(M))
		return
	if(isYautja(M) && prob(75))
		return

	if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
		M << "<b>Your gas mask protects you!</b>"
		return
	else
		if (M.coughedtime != 1)
			M.coughedtime = 1
			M.emote("gasp")
			M.adjustOxyLoss(18)
			spawn (15)
				M.coughedtime = 0
		if(!M.weakened)
			spawn(5)
				if(M)
					M.Weaken(6)
					M << "<B>You feel woozy from the gas.</B>"
	return

/mob/living/carbon/Xenomorph/Boiler/proc/acid_spray(var/atom/T)
	set name = "Spray Acid (10+)"
	set desc = "Hose down an area with corrosive acid. Use middle mouse for best results."
	set category = "Alien"

	if(!check_state()) return

	if(acid_cooldown)
		return

	if(!istype(src.loc,/turf) || istype(src.loc,/turf/space))
		src << "Not here!"
		return

	if(storedplasma < 10)
		src << "Not enough plasma."
		return

	if(!T)
		var/list/victims = list()
		for(var/mob/living/carbon/human/C in oview(7))
			if(C && istype(C) && !C.stat && !C.lying )
				victims += C
		T = input(src, "Who should you spit towards?") as null|anything in victims

	if(T)
		var/turf/target

		if(isturf(T))
			target = T
		else
			target = get_turf(T)

		if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
			return

		if(target == src.loc)
			src << "That's too close!"
			return

		playsound(src.loc, 'sound/effects/refill.ogg', 100, 1)
		visible_message("\green <B>[src] spews forth a virulent spray of acid!</B>")

		var/turflist = getline(src, target)
		spray_turfs(turflist)
		acid_cooldown = 1
		spawn(160) //16 second cooldown.
			acid_cooldown = 0
			src << "You feel your acid glands refill. You can spray acid again."
	else
		src << "\blue You cannot spit at nothing!"
	return

/mob/living/carbon/Xenomorph/Boiler/proc/spray_turfs(turflist)
	if(isnull(turflist)) return
	var/distance = 0

	for(var/turf/T in turflist)
		distance++
		if(T.density || istype(T, /turf/space))
			break

		if(distance > 7)
			break
		if(!isnull(src))
			if(DirBlocked(T,src.dir))
				break
			else if(DirBlocked(T,turn(src.dir,180)))
				break
		if(locate(/obj/effect/alien/resin/wall,T) || locate(/obj/structure/mineral_door,T) || locate(/obj/effect/alien/resin/membrane,T))
			break //Nope.avi

		var/obj/structure/window/W = locate() in T
		if(W)
			if(W.is_full_window()) break
			if(prev_turf)
				if(get_dir(prev_turf,W) == W.dir)
					break

		if(!prev_turf && length(turflist)>1)
			prev_turf = get_turf(src)
			continue	//so we don't burn the tile we be standin on

		if(prev_turf && LinkBlocked(prev_turf, T))
			break

		if(!check_plasma(10))
			break
		prev_turf = T
		splat_turf(T)
		sleep(2)

	prev_turf = null
	return

/mob/living/carbon/Xenomorph/Boiler/proc/splat_turf(var/turf/target)
	if(!istype(target) || istype(target,/turf/space)) return

	if(!locate(/obj/effect/xenomorph/spray) in target) // No stacking flames!
		var/obj/effect/xenomorph/spray/S =  new(target)
		processing_objects.Add(S)
		for(var/mob/living/carbon/M in target)
			if(istype(M,/mob/living/carbon/human) || istype(M,/mob/living/carbon/monkey))
				M.adjustFireLoss(rand(12,20))
				M.show_message(text("\green [src] showers you in corrosive acid!"),1)
				if(prob(50))
					M.emote("scream")
				if(prob(30))
					M.Weaken(rand(3,4))

	return

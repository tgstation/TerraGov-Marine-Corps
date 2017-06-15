


//endless reagents!
/obj/item/weapon/reagent_containers/glass/replenishing
	var/spawning_id

/obj/item/weapon/reagent_containers/glass/replenishing/New()
	..()
	processing_objects.Add(src)
	spawning_id = pick("blood","holywater","lube","stoxin","ethanol","ice","glycerol","fuel","cleaner")

/obj/item/weapon/reagent_containers/glass/replenishing/process()
	reagents.add_reagent(spawning_id, 0.3)



//a talking gas mask!
/obj/item/clothing/mask/gas/poltergeist
	var/list/heard_talk = list()
	var/last_twitch = 0
	var/max_stored_messages = 100

/obj/item/clothing/mask/gas/poltergeist/New()
	processing_objects.Add(src)

/obj/item/clothing/mask/gas/poltergeist/process()
	if(heard_talk.len && istype(src.loc, /mob/living) && prob(10))
		var/mob/living/M = src.loc
		M.say(pick(heard_talk))

/obj/item/clothing/mask/gas/poltergeist/hear_talk(mob/M as mob, text)
	..()
	if(heard_talk.len > max_stored_messages)
		heard_talk.Remove(pick(heard_talk))
	heard_talk.Add(text)
	if(istype(src.loc, /mob/living) && world.time - last_twitch > 50)
		last_twitch = world.time



//a vampiric statuette, usually put into a mimic for maximum fun. Perfectly harmless until picked up.
/obj/item/weapon/vampiric
	name = "statuette"
	desc = "An odd looking statuette made up of what appears to be carved from crimson stone. It's grinning..."
	icon_state = "statuette1"
	icon = 'icons/obj/xenoarchaeology.dmi'
	var/stored_blood = 0
	var/maximum_blood = 0 //How much blood is needed before the thing despawns. 100 for right now.
	var/current_bloodcall = 0
	var/current_consume = 0
	var/interval_bloodcall = 50
	var/interval_consume = 35
	var/shadow_wights[]

	Dispose()
		. = ..()
		for(var/mob/W in shadow_wights) cdel(W)
		shadow_wights = null
		processing_objects -= src

	attack_hand(mob/M) //You dun goofed now, goofy.
		M << "<span class='danger'>The strange thing in your hand begins to move around! You suddenly get a very bad feeling about this!</span>"
		icon_state = "statuette2"
		mouse_opacity = 0 //Can't be interacted with again.
		shadow_wights = new
		processing_objects += src

/obj/item/weapon/vampiric/process()
	if(!isturf(loc))
		if(!get_teleport_loc())
			teleport(get_turf(src))
			return

	// Grab some blood from a nearby mob, if possible.
	if(world.time - current_bloodcall > interval_bloodcall)
		var/mob/L[] = new
		var/mob/M
		var/mob/living/carbon/human/H
		for(M in view(7,src))
			H = M
			if(istype(H) && prob(50) && H.stat != DEAD && H.species != "Horror") L += H
		if(L.len) bloodcall(pick(L))
		else
			get_teleport_loc()
			return

	// Suck up any blood, if possible.
	if(world.time - current_consume > interval_consume)
		var/obj/effect/decal/cleanable/blood/B = locate() in range(2,src)
		if(B)
			var/blood_absorbed
			if(istype(B, /obj/effect/decal/cleanable/blood/drip)) blood_absorbed = 0.25
			else
				blood_absorbed = 1
				playsound(loc, 'sound/effects/splat.ogg', 15, 1)
			stored_blood += blood_absorbed
			maximum_blood += blood_absorbed
			current_consume = world.time
			cdel(B,,animation_destruction_fade(B))

	switch(stored_blood)
		if(10 to INFINITY)
			stored_blood -= 10
			new /obj/effect/spider/eggcluster(pick(view(1,src)))
		if(3 to 9)
			if(prob(5))
				stored_blood -= 1
				new /mob/living/simple_animal/hostile/creature(pick(view(1,src)))
				playsound(loc, pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg'), 50, 1, 12)
		if(1 to 2)
			if(shadow_wights.len < 5 && prob(5))
				var/obj/effect/shadow_wight/W = new(get_turf(src))
				shadow_wights += W
				W.master_doll = src
				playsound(loc, 'sound/effects/ghost.ogg', 25, 1, 12)
				stored_blood -= 0.1
		if(0.1 to 0.9)
			if(prob(5))
				visible_message("<span class='warning'>\icon[src] [src]'s eyes glow ruby red for a moment!</span>")
				stored_blood -= 0.1

	//Check the shadow wights and auto-remove them if they get too far.
	for(var/mob/W in shadow_wights)
		if(get_dist(W, src) > 10)
			cdel(W)

	if(maximum_blood >= 100) cdel(src,,animation_destruction_long_fade(src))

/obj/item/weapon/vampiric/proc/get_teleport_loc()
	var/i = 1
	var/mob/living/carbon/human/H
	while(++i < 4)
		H = pick(player_list)
		if(istype(H) && H.stat != DEAD && H.species != "Horror")
			teleport(get_turf(H))
			return 1

/obj/item/weapon/vampiric/proc/teleport(turf/location)
	set waitfor = 0
	var/L = locate(location.x + rand(-1,1), location.y + rand(-1,1), location.z)
	location = L ? L : location
	sleep(animation_teleport_spooky_out(src)) // We need to sleep so that the animation has a chance to finish.
	loc = location
	animation_teleport_spooky_in(src)

/obj/item/weapon/vampiric/hear_talk(mob/M)
	..()
	if(ishuman(M) && world.time - current_bloodcall >= interval_bloodcall && M in view(7, src)) bloodcall(M)

/obj/item/weapon/vampiric/proc/bloodcall(mob/living/carbon/human/H)
	if(H.species != "Horror")
		playsound(loc, pick('sound/hallucinations/wail.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/far_noise.ogg'), 25, 1, 12)

		var/target = pick("chest","groin","head","l_arm","r_arm","r_leg","l_leg","l_hand","r_hand","l_foot","r_foot")
		H.apply_damage(rand(5, 10), BRUTE, target)
		H.visible_message("<span class='danger'>A stream of blood flies out of [H]!</span>","<span class='danger'>The skin on your [parse_zone(target)] feels like it's ripping apart, and a stream of blood flies out!</span>")
		var/obj/effect/decal/cleanable/blood/splatter/animated/B = new(get_turf(H))
		B.target_turf = pick(range(1, src))
		B.blood_DNA = new
		B.blood_DNA[H.dna.unique_enzymes] = H.dna.b_type
		H.vessel.remove_reagent("blood",rand(25,50))
		animation_blood_spatter(H)
	current_bloodcall = world.time

//animated blood 2 SPOOKY
/obj/effect/decal/cleanable/blood/splatter/animated
	var/turf/target_turf
	var/loc_last_process

	New()
		..()
		processing_objects += src
		loc_last_process = loc

	Dispose()
		animation_destruction_fade(src)
		. = ..()
		processing_objects -= src

/obj/effect/decal/cleanable/blood/splatter/animated/process()
	if(target_turf && loc != target_turf)
		step_towards(src,target_turf)
		if(loc == loc_last_process) target_turf = null
		loc_last_process = loc

		//Leaves drips.
		if(prob(50))
			var/obj/effect/decal/cleanable/blood/drip/D = new(get_turf(src))
			var/i = 0
			while(++i < 3)
				if(prob(50))
					D = new(get_turf(src))
					D.blood_DNA = blood_DNA
	else ..()


/obj/effect/shadow_wight
	name = "shadow wight"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost2"
	mouse_opacity = 0
	var/obj/item/weapon/vampiric/master_doll

	Dispose()
		. = ..()
		processing_objects -= src
		if(master_doll && master_doll.loc) master_doll.shadow_wights -= src

/obj/effect/shadow_wight/New()
	animation_teleport_spooky_in(src)
	processing_objects += src

/obj/effect/shadow_wight/process()
	if(loc)
		loc = get_turf(pick(orange(1,src)))
		var/mob/living/carbon/M = locate() in loc
		if(M)
			playsound(loc, pick('sound/hallucinations/behind_you1.ogg',\
			'sound/hallucinations/behind_you2.ogg',\
			'sound/hallucinations/i_see_you1.ogg',\
			'sound/hallucinations/i_see_you2.ogg',\
			'sound/hallucinations/im_here1.ogg',\
			'sound/hallucinations/im_here2.ogg',\
			'sound/hallucinations/look_up1.ogg',\
			'sound/hallucinations/look_up2.ogg',\
			'sound/hallucinations/over_here1.ogg',\
			'sound/hallucinations/over_here2.ogg',\
			'sound/hallucinations/over_here3.ogg',\
			'sound/hallucinations/turn_around1.ogg',\
			'sound/hallucinations/turn_around2.ogg',\
			), 25, 1, 12)
			M.sleeping = max(M.sleeping,rand(5,10))
			cdel(src,,animation_destruction_fade(src))

/obj/effect/shadow_wight/Bump(atom/A)
	A << "<span class='warning'>You feel a chill run down your spine!</span>"

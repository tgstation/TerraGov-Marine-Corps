
/mob/living/simple_animal/construct
	name = "Construct"
	real_name = "Construct"
	desc = ""
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon_dead = "shade_dead"
	speed = -1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/weapons/punch1.ogg'
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	faction = "cult"
	var/list/construct_spells = list()

/mob/living/simple_animal/construct/Initialize()
	. = ..()
	name = text("[initial(name)] ([rand(1, 1000)])")
	real_name = name

/mob/living/simple_animal/construct/death()
	new /obj/item/ectoplasm (src.loc)
	. = ..(null,"collapses in a shattered heap.")
	ghostize()
	qdel(src)

/mob/living/simple_animal/construct/examine(mob/user)
	var/msg = "<span cass='info'>*---------*\nThis is [icon2html(src, user)] \a <EM>[src]</EM>!\n"
	if (health < maxHealth)
		msg += "<span class='warning'>"
		if (health >= maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	to_chat(user, msg)


/mob/living/simple_animal/construct/attack_animal(mob/living/M as mob)
	if(istype(M, /mob/living/simple_animal/construct/builder))
		health += 5
		M.emote("mends some of \the <EM>[src]'s</EM> wounds.")
	else
		if(M.melee_damage_upper <= 0)
			M.emote("[M.friendly] \the <EM>[src]</EM>")
		else
			if(M.attack_sound)
				playsound(loc, M.attack_sound, 25, 1)
			for(var/mob/O in viewers(src, null))
				O.show_message("<span class='attack'>\The <EM>[M]</EM> [M.attacktext] \the <EM>[src]</EM>!</span>", 1)
			log_combat(M, src, "attacked")

			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
			adjustBruteLoss(damage)


/////////////////Juggernaut///////////////



/mob/living/simple_animal/construct/armoured
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "A possessed suit of armour driven by the will of the restless dead"
	icon = 'icons/mob/mob.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	maxHealth = 250
	health = 250
	response_harm   = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "smashes their armoured gauntlet into"
	speed = 3
	wall_smash = 1
	attack_sound = 'sound/weapons/punch3.ogg'
	status_flags = 0


/mob/living/simple_animal/construct/armoured/Life()
	knocked_down = 0
	..()

/mob/living/simple_animal/construct/armoured/bullet_act(var/obj/item/projectile/P)
	var/reflectchance = 80 - round(P.damage/3)
	if(prob(reflectchance))
		adjustBruteLoss(P.damage * 0.5)
		visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s shell!</span>", \
						"<span class='userdanger'>The [P.name] gets reflected by [src]'s shell!</span>")

		// Find a turf near or on the original location to bounce to
		if(P.starting)
			var/new_x = P.starting.x + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
			var/new_y = P.starting.y + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
			var/turf/curloc = get_turf(src)

			// redirect the projectile
			P.original = locate(new_x, new_y, P.z)
			P.starting = curloc
			P.current = curloc
			P.firer = src
			P.yo = new_y - curloc.y
			P.xo = new_x - curloc.x

		return -1 // complete projectile permutation

	return (..(P))



////////////////////////Wraith/////////////////////////////////////////////



/mob/living/simple_animal/construct/wraith
	name = "Wraith"
	real_name = "Wraith"
	desc = "A wicked bladed shell contraption piloted by a bound spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "floating"
	icon_living = "floating"
	maxHealth = 75
	health = 75
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	speed = -1
	see_in_dark = 7
	attack_sound = 'sound/weapons/bladeslice.ogg'



/////////////////////////////Artificer/////////////////////////



/mob/living/simple_animal/construct/builder
	name = "Artificer"
	real_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining The Cult of Nar-Sie's armies"
	icon = 'icons/mob/mob.dmi'
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 50
	health = 50
	response_harm = "viciously beats"
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "rams"
	speed = 0
	wall_smash = 1
	attack_sound = 'sound/weapons/punch2.ogg'


/////////////////////////////Behemoth/////////////////////////


/mob/living/simple_animal/construct/behemoth
	name = "Behemoth"
	real_name = "Behemoth"
	desc = "The pinnacle of occult technology, Behemoths are the ultimate weapon in the Cult of Nar-Sie's arsenal."
	icon = 'icons/mob/mob.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	maxHealth = 750
	health = 750
	speak_emote = list("rumbles")
	response_harm   = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage_lower = 50
	melee_damage_upper = 50
	attacktext = "brutally crushes"
	speed = 5
	wall_smash = 1
	attack_sound = 'sound/weapons/punch4.ogg'
	var/energy = 0
	var/max_energy = 1000


////////////////Powers//////////////////


/*
/client/proc/summon_cultist()
	set category = "Behemoth"
	set name = "Summon Cultist (300)"
	set desc = "Teleport a cultist to your location"
	if (istype(usr,/mob/living/simple_animal/constructbehemoth))

		if(usr.energy<300)
			to_chat(usr, "<span class='warning'>You do not have enough power stored!</span>")
			return

		if(usr.stat)
			return

		usr.energy -= 300
	var/list/mob/living/cultists = new
	for(var/datum/mind/H in SSticker.mode.cult)
		if (istype(H.current,/mob/living))
			cultists+=H.current
			var/mob/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - usr)
			if(!cultist)
				return
			if (cultist == usr) //just to be sure.
				return
			cultist.loc = usr.loc
			usr.visible_message("/red [cultist] appears in a flash of red light as [usr] glows with power")*/

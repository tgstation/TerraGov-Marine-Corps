/mob/living/simple_animal/hostile/netherworld
	name = "creature"
	desc = ""
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 80
	maxHealth = 80
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 50
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/blank.ogg'
	faction = list("nether")
	speak_emote = list("screams")
	gold_core_spawnable = HOSTILE_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

/mob/living/simple_animal/hostile/netherworld/migo
	name = "mi-go"
	desc = ""
	speak_emote = list("screams", "clicks", "chitters", "barks", "moans", "growls", "meows", "reverberates", "roars", "squeaks", "rattles", "exclaims", "yells", "remarks", "mumbles", "jabbers", "stutters", "seethes")
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	attack_verb_continuous = "lacerates"
	attack_verb_simple = "lacerate"
	speed = -0.5
	var/static/list/migo_sounds
	deathmessage = "wails as its form turns into a pulpy mush."
	deathsound = 'sound/blank.ogg'

/mob/living/simple_animal/hostile/netherworld/migo/Initialize()
	. = ..()
	migo_sounds = list('sound/blank.ogg') //hahahaha fuck you code divers

/mob/living/simple_animal/hostile/netherworld/migo/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(stat)
		return
	var/chosen_sound = pick(migo_sounds)
	playsound(src, chosen_sound, 50, TRUE)

/mob/living/simple_animal/hostile/netherworld/migo/Life()
	..()
	if(stat)
		return
	if(prob(10))
		var/chosen_sound = pick(migo_sounds)
		playsound(src, chosen_sound, 50, TRUE)

/mob/living/simple_animal/hostile/netherworld/blankbody
	name = "blank body"
	desc = ""
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	gold_core_spawnable = NO_SPAWN
	health = 100
	maxHealth = 100
	melee_damage_lower = 5
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	deathmessage = "falls apart into a fine dust."

/obj/structure/spawner/nether
	name = "netherworld link"
	desc = null //see examine()
	icon_state = "nether"
	max_integrity = 50
	spawn_time = 600 //1 minute
	max_mobs = 15
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls through"
	mob_types = list(/mob/living/simple_animal/hostile/netherworld/migo, /mob/living/simple_animal/hostile/netherworld, /mob/living/simple_animal/hostile/netherworld/blankbody)
	faction = list("nether")

/obj/structure/spawner/nether/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/spawner/nether/examine(mob/user)
	. = ..()
	if(isskeleton(user) || iszombie(user))
		. += "A direct link to another dimension full of creatures very happy to see you. <span class='nicegreen'>I can see your house from here!</span>"
	else
		. += "A direct link to another dimension full of creatures not very happy to see you. <span class='warning'>Entering the link would be a very bad idea.</span>"

/obj/structure/spawner/nether/attack_hand(mob/user)
	. = ..()
	if(isskeleton(user) || iszombie(user))
		to_chat(user, "<span class='notice'>I don't feel like going home yet...</span>")
	else
		user.visible_message("<span class='warning'>[user] is violently pulled into the link!</span>", \
							"<span class='danger'>Touching the portal, you are quickly pulled through into a world of unimaginable horror!</span>")
		contents.Add(user)

/obj/structure/spawner/nether/process()
	for(var/mob/living/M in contents)
		if(M)
			playsound(src, 'sound/blank.ogg', 50, TRUE)
			M.adjustBruteLoss(60)
			new /obj/effect/gibspawner/generic(get_turf(M), M)
			if(M.stat == DEAD)
				var/mob/living/simple_animal/hostile/netherworld/blankbody/blank
				blank = new(loc)
				blank.name = "[M]"
				blank.desc = ""
				src.visible_message("<span class='warning'>[M] reemerges from the link!</span>")
				qdel(M)

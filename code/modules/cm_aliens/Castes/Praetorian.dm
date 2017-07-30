//Praetorian Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Praetorian
	caste = "Praetorian"
	name = "Praetorian"
	desc = "A huge, looming beast of an alien."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Praetorian Walking"
	melee_damage_lower = 15
	melee_damage_upper = 25
	tacklemin = 3
	tacklemax = 8
	tackle_chance = 75
	health = 200
	maxHealth = 200
	storedplasma = 200
	plasma_gain = 25
	maxplasma = 800
	evolution_threshold = 800
	spit_delay = 20
	speed = 0.1
	pixel_x = -16
	caste_desc = "Ptui!"
	evolves_to = list()
	armor_deflection = 35
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = 3
	upgrade = 0
	aura_strength = 1.5 //Praetorian's aura starts strong. They are the Queen's right hand. Climbs by 1 to 4.5
	var/sticky_cooldown = 0

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/shift_spits,
		/mob/living/carbon/Xenomorph/proc/toggle_auras,
		/mob/living/carbon/Xenomorph/proc/neurotoxin, //Stronger version
		/mob/living/carbon/Xenomorph/Praetorian/proc/resin_spit
		)

/mob/living/carbon/Xenomorph/Praetorian/proc/resin_spit(var/atom/T)
	set name = "Spit Sticky Resin (250)"
	set desc = "Spits a glob a sticky resin. Use Shift+Click for better results."
	set category = "Alien"

	if(!check_state())
		return

	if(sticky_cooldown)
		return

	if(!isturf(loc))
		src << "<span class='warning'>You can't spit from here!</span>"
		return

	if(!T)
		var/list/victims = list()
		for(var/mob/living/carbon/human/C in oview(7))
			if(!C.stat)
				victims += C
		victims += "Cancel"
		T = input(src, "Who should you spit towards?") as null|anything in victims

	if(!client || !loc || T == "Cancel")
		return

	if(T)
		if(!check_plasma(250))
			return

		var/turf/current_turf = get_turf(src)

		if(!current_turf)
			return

		sticky_cooldown = 1
		visible_message("<span class='xenowarning'>[src] spits at [T]!</span>", \
		"<span class='xenowarning'>You spit at [T]!</span>" )
		var/sound_to_play = pick(1, 2) == 1 ? 'sound/voice/alien_spitacid.ogg' : 'sound/voice/alien_spitacid2.ogg'
		playsound(loc, sound_to_play, 25, 1)

		var/obj/item/projectile/A = rnew(/obj/item/projectile, current_turf)
		A.generate_bullet(ammo_list[/datum/ammo/xeno/sticky])
		A.permutated += src
		A.def_zone = get_organ_target()
		A.fire_at(T, src, null, ammo.max_range, ammo.shell_speed)

		spawn(90) //12 second cooldown.
			sticky_cooldown = 0
			src << "<span class='xenowarning'>You feel your resin glands refill. You can spit <B>resin</b> again.</span>"
	else
		src << "<span class='warning'>You have nothing to spit at!</span>"

/obj/resin_glob
	name = "glob of sticky resin"
	desc = "Gooey."

/obj/resin_glob/proc/splatter(turf/T)

		do_safe_splatter(T)
		do_safe_splatter(get_step(T, NORTH))
		do_safe_splatter(get_step(T, NORTHEAST))
		do_safe_splatter(get_step(T, EAST))
		do_safe_splatter(get_step(T, SOUTHEAST))
		do_safe_splatter(get_step(T, SOUTH))
		do_safe_splatter(get_step(T, SOUTHWEST))
		do_safe_splatter(get_step(T, WEST))
		do_safe_splatter(get_step(T, NORTHWEST))
		del(src)

/obj/resin_glob/proc/do_safe_splatter(turf/T)
	if (istype(T, /turf/simulated/wall) || istype(T, /turf/unsimulated/wall))
		return

	for(var/obj/O in T.contents)
		if(istype(O, /obj/effect/alien/resin/sticky))
			return

		if(O.density) //We can't grow if something dense is here
			return

	new /obj/effect/alien/resin/sticky(T)
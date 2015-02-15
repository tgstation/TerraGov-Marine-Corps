//Xenomorph - Queen- Colonial Marines - Apophis775 - Last Edit: 24JAN2015

/mob/living/carbon/Xenomorph/Queen
	caste = "Queen"
	name = "Queen"
	desc = "A sexy Alien queen"
	icon = 'icons/xeno/Colonial_Queen.dmi'
	icon_state = "Queen Walking"
	pass_flags = PASSTABLE
	melee_damage_lower = 30
	melee_damage_upper = 35
	attacktext = "Bites"
	attack_sound = null
	friendly = "Nuzzles"
	wall_smash = 0
	health = 700
	maxHealth = 700
	amount_grown = 0
	max_grown = 10
	storedplasma = 300
	maxplasma = 700

/mob/living/carbon/Xenomorph/Queen/New()
	..()
	for(var/mob/living/carbon/Xenomorph/Queen/Q in living_mob_list)
		if(Q == src)		continue
		if(Q.stat == DEAD)	continue
		if(Q.client)
			name = "Alien Queen"
			break

/* Old queen code and Notes from CM - REFERENCE ONLY

/mob/living/carbon/alien/humanoid/queen

	status_flags = CANPARALYSE
	heal_rate = 4
	plasma_rate = 20
	var/usedscreech = 0
	tacklemin = 4
	tacklemax = 8
	tackle_chance = 90 //Should not be above 100%

/datum/hive_controller
	var/mob/living/carbon/alien/humanoid/queen/active_queen
	var/psychicstrength = 5
	var/psychicstrengthmax = 500
	var/psychicstrengthused = 0
	var/list/mob/living/carbon/alien/xenos = list()
	var/count = 0

	New()
		process_controller()

	proc/process_controller()
		spawn while(1)
			count += 1
			if(count >= 3 && active_queen && psychicstrength < psychicstrengthmax)
				psychicstrength += 1
				count = 0
			if(istype(active_queen))
				if(active_queen.stat == DEAD)
					psychicstrength = round(psychicstrength / 2)
					for(var/mob/xeno in xenos)
						xeno << "\red The queen has died! You feel the strength of your hivemind decrease greatly."
					active_queen = null
			sleep(50)

/var/global/datum/hive_controller/hive_controller = new()

/mob/living/carbon/alien/proc/hivemind_check(var/amt)

	if(hive_controller)
		if(( hive_controller.psychicstrengthused + (amt/2)) <= hive_controller.psychicstrength )
			return 1
		else
			return 0

/mob/living/carbon/alien/New()
	..()
	if(hive_controller)
		hive_controller.psychicstrengthused += src.psychiccost / 2

/mob/living/carbon/alien/Del()
	if(hive_controller)
		hive_controller.psychicstrengthused -= src.psychiccost / 2
	..()


/mob/living/carbon/alien/death(gibbed)
	..(gibbed)
	if(hive_controller)
		hive_controller.psychicstrengthused -= src.psychiccost / 4

/mob/living/carbon/alien/Stat()
	..()
	stat(null, "Hivemind Strength: [hive_controller.psychicstrengthused]/[hive_controller.psychicstrength]")

/mob/living/carbon/alien/humanoid/queen/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	hive_controller.active_queen = src
	verbs -= /atom/movable/verb/pull
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
		if(Q == src)		continue
		if(Q.stat == DEAD)	continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid,/mob/living/carbon/alien/humanoid/proc/resin)
	verbs -= /mob/living/carbon/alien/verb/ventcrawl
	//var/matrix/M = matrix()
	//M.Scale(1.3,1.45)
	//src.transform = M
	pixel_x = -16
	..()



/mob/living/carbon/alien/humanoid/queen/Life()
	..()

	if(usedscreech <= 0)
		usedscreech = 0
	usedscreech--


//Queen verbs
/mob/living/carbon/alien/humanoid/queen/verb/lay_egg()

	set name = "Lay Egg (100)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	if(locate(/obj/effect/alien/egg) in get_turf(src) || locate(/obj/royaljelly) in get_turf(src))
		src << "There's already an egg or royal jelly here."
		return

	if(powerc(100,1))//Can't plant eggs on spess tiles. That's silly.
		adjustToxLoss(-100)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has laid an egg!</B>"), 1)
		new /obj/effect/alien/egg(loc)
	return

/mob/living/carbon/alien/humanoid/queen/verb/lay_jelly()

	set name = "Produce Royal Jelly (350)"
	set desc = "Produce a sac of fluid which furthers the evolution of the hive."
	set category = "Alien"

	if(locate(/obj/royaljelly) in get_turf(src) || locate(/obj/effect/alien/egg) in get_turf(src))
		src << "There's already royal jelly or egg here."
		return

	if(powerc(350,1))//Can't plant eggs on spess tiles. That's silly.
		adjustToxLoss(-350)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has shaped a sac and filled it with a greenish fluid!</B>"), 1)
		new /obj/royaljelly(loc)
	return

/mob/living/carbon/alien/humanoid/queen/verb/screech()
	set name = "Screech (250)"
	set desc = "Emit a screech that stuns prey."
	set category = "Alien"

	if(usedscreech >= 1)
		src << "\red Our screech is not ready.."
		return
	if(powerc(250))
		adjustToxLoss(-250)
		for(var/mob/O in view())
			playsound(loc, 'sound/effects/screech2.ogg', 25, 1, -1)
			O << "\red [src] emits a paralyzing screech!"

		for (var/mob/living/carbon/human/M in oview())
			if(istype(M.l_ear, /obj/item/clothing/ears/earmuffs) || istype(M.r_ear, /obj/item/clothing/ears/earmuffs))
				continue
			if (get_dist(src.loc, M.loc) <= 4)
				M.stunned += 3
				M.drop_l_hand()
				M.drop_r_hand()
			else if(get_dist(src.loc, M.loc) >= 5)
				M.stunned += 2

		usedscreech = 30

	return
//End queen verbs

/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "queen_s"
	pixel_x = -16

/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	if(lying)
		if(resting)					icon_state = "queen_sleep"
		else						icon_state = "queen_l"
		for(var/image/I in overlays_lying)
			overlays += I
	else
		icon_state = "queen_s"
		for(var/image/I in overlays_standing)
			overlays += I*/
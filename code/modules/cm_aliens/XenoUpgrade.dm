//Xenomorph Upgrade Code - Colonial Marines - Apophis775 - Last Edit: 11JUN16
//Edited by Artouris 21JAN17 Broke it up into a verb and proc. This way we can have our cake and eat it too. Also allowed for tiered spawns.

/mob/living/carbon/Xenomorph/verb/Upgrade()
	set name = "Upgrade"
	set desc = "Upgrades you, at the cost of never being able to evolve. Requires full plasma"
	set category = "Alien"

	upgrade_xeno(0,upgrade)

/mob/living/carbon/Xenomorph/proc/upgrade_xeno(bypass_limit, tier)
	upgrade = tier

	switch(upgrade)
		if(-2)
			src << "<span class='warning'>Sorry, your class can't upgrade.</span>"
			r_FAL
		if(3)
			src << "<span class='warning'>You can no longer upgrade.</span>"
			r_FAL

	if(health < maxHealth && !bypass_limit)
		src << "<span class='warning'>You must be fully healed to upgrade.</span>"
		return

	if(storedplasma < maxplasma && !bypass_limit)
		src << "<span class='warning'>An upgrade requires all of your plasma.</span>"
		return

	if(jobban_isbanned(src, "Alien"))
		src << "<span class='warning'>You are jobbanned from Aliens and cannot evolve. How did you even become an alien?</span>"
		return

	if(handcuffed || legcuffed)
		src << "<span class='warning'>The restraints are too restricting to allow you to upgrade.</span>"
		return

	if(evolution_threshold) //Does the caste have an evolution timer? Then check it
		if(evolution_stored < evolution_threshold && !bypass_limit)
			src << "<span class='warning'>You require more growth.</span>"
			return

/*
ARMOR
runner 0, 5, 10, 10
hunter 15, 20, 25, 25
Ravager 40, 45, 50, 50
Crusher 60, 65, 70, 75
Sentinel 15, 15, 20, 20
Spitter 15, 20, 25, 30
Boiler 20, 30, 35, 35
Praetorian 35, 40, 45, 45
Drone 0, 5, 10, 15
Hivelord 0, 10, 15, 20
Carrier 0, 10, 10, 15
Queen 45, 50, 55, 55

SPEED:
Runner -2.2 -2.1 -2
Hunter -2 -1.8 -1.7 -1.6
Ravager -1.5 -1.4 -1.3 -1.2
Sentinel -1 -0.8 -0.6 -0.4
Spitter -0.8 -0.5 -0.3 -0.1
Boiler 0.4 0.8 1 1.2
Preatorian 0.2 0.6 0.8 1
Drone -1 -0.8 -0.6 -0.8
Hivelord 0.4 0.8 1 1.2
Queen 0.2 0.4 0.6 0.8
*/

	switch(upgrade)

		//FIRST UPGRADE
		if(0)
			if(!bypass_limit)
				var/up = alert(src, "If you upgrade, you will never be able to evolve (except for Drone -> Queen), are you sure?", , "Yes", "No")
				if(up == "No")
					return
			upgrade = 1
			upgrade_name = "Mature"
			evolution_stored = 0
			src << "<span class='xenonotice'>You feel a bit stronger.</span>"
			switch(caste)
				if("Runner")
					melee_damage_lower = 15
					melee_damage_upper = 25
					health = 120
					maxHealth = 120
					storedplasma = 0
					plasma_gain = 2
					maxplasma = 150
					evolution_threshold = 400
					caste_desc = "A fast, four-legged terror, but weak in sustained combat. It looks a little more dangerous."
					speed = -2
					armor_deflection = 5
					attack_delay = -4
					tacklemin = 2
					tacklemax = 4
					tackle_chance = 50
				if("Hunter")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 170
					maxHealth = 170
					storedplasma = 0
					plasma_gain = 10
					maxplasma = 150
					evolution_threshold = 800
					caste_desc = "A fast, powerful front line combatant. It looks a little more dangerous."
					speed = -1.7
					armor_deflection = 20
					attack_delay = -2
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
				if("Ravager")
					melee_damage_lower = 50
					melee_damage_upper = 70
					health = 220
					maxHealth = 220
					storedplasma = 0
					plasma_gain = 10
					maxplasma = 150
					evolution_threshold = 1600
					caste_desc = "A brutal, devastating front-line attacker. It looks a little more dangerous."
					speed = -1.3
					armor_deflection = 45
					tacklemin = 4
					tacklemax = 8
					tackle_chance = 85
				if("Crusher")
					melee_damage_lower = 20
					melee_damage_upper = 35
					tacklemin = 4
					tacklemax = 7
					tackle_chance = 65
					health = 250
					maxHealth = 250
					storedplasma = 0
					plasma_gain = 15
					maxplasma = 300
					evolution_threshold = 1600
					caste_desc = "A huge tanky xenomorph. It looks a little more dangerous."
					armor_deflection = 65
				if("Sentinel")
					melee_damage_lower = 15
					melee_damage_upper = 25
					health = 150
					maxHealth = 150
					storedplasma = 0
					plasma_gain = 12
					maxplasma = 400
					evolution_threshold = 400
					spit_delay = 25
					caste_desc = "A ranged combat alien. It looks a little more dangerous."
					armor_deflection = 15
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					speed = -0.6
					spit_type = 0
				if("Spitter")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 180
					maxHealth = 180
					storedplasma = 0
					plasma_gain = 25
					maxplasma = 700
					evolution_threshold = 800
					spit_delay = 20
					caste_desc = "A ranged damage dealer. It looks a little more dangerous."
					armor_deflection = 20
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					speed = -0.3
					spit_type = 0
				if("Boiler")
					melee_damage_lower = 20
					melee_damage_upper = 25
					health = 200
					maxHealth = 200
					storedplasma = 0
					plasma_gain = 35
					maxplasma = 900
					evolution_threshold = 1600
					spit_delay = 30
					caste_desc = "Some sort of abomination. It looks a little more dangerous."
					armor_deflection = 30
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 65
					speed = 1.0
				if("Praetorian")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 220
					maxHealth = 220
					storedplasma = 0
					plasma_gain = 30
					maxplasma = 900
					evolution_threshold = 1600
					spit_delay = 15
					caste_desc = "A giant ranged monster. It looks a little more dangerous."
					armor_deflection = 40
					tacklemin = 5
					tacklemax = 8
					tackle_chance = 75
					speed = 0.8
					spit_type = 0
					aura_strength = 2.5
				if("Drone")
					melee_damage_lower = 12
					melee_damage_upper = 16
					health = 120
					maxHealth = 120
					storedplasma = 0
					maxplasma = 800
					plasma_gain = 20
					evolution_threshold = 1000
					caste_desc = "The workhorse of the hive. It looks a little more dangerous."
					armor_deflection = 5
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					speed = -0.6
					aura_strength = 1
				if("Hivelord")
					melee_damage_lower = 15
					melee_damage_upper = 20
					health = 220
					maxHealth = 220
					storedplasma = 0
					maxplasma = 900
					plasma_gain = 40
					evolution_threshold = 1600
					caste_desc = "A builder of REALLY BIG hives. It looks a little more dangerous."
					armor_deflection = 10
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					speed = 1
					aura_strength = 1.5
				if("Carrier")
					src << "<span class='xenonotice'>Throw a hugger to get your hugger upgrades.</span>"
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 200
					maxHealth = 200
					storedplasma = 0
					maxplasma = 300
					plasma_gain = 10
					evolution_threshold = 1600
					caste_desc = "A portable Love transport. It looks a little more dangerous."
					armor_deflection = 10
					tacklemin = 3
					tacklemax = 4
					tackle_chance = 60
					speed = -0.4
					var/mob/living/carbon/Xenomorph/Carrier/CA = src
					CA.huggers_max = 7
					CA.hugger_delay = 30
				if("Queen")
					melee_damage_lower = 40
					melee_damage_upper = 55
					health = 320
					maxHealth = 320
					storedplasma = 0
					maxplasma = 800
					plasma_gain = 40
					evolution_threshold = 1600
					caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs."
					armor_deflection = 50
					tacklemin = 5
					tacklemax = 7
					tackle_chance = 85
					speed = 0.6
					aura_strength = 3

		//SECOND UPGRADE
		if(1)
			upgrade = 2
			upgrade_name = "Elite"
			evolution_stored = 0
			src << "<span class='xenowarning'>You feel a whole lot stronger.</span>"
			switch(caste)
				if("Runner")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 150
					maxHealth = 150
					storedplasma = 0
					plasma_gain = 2
					maxplasma = 200
					evolution_threshold = 800
					caste_desc = "A fast, four-legged terror, but weak in sustained combat. It looks pretty strong."
					speed = -2.1
					armor_deflection = 10
					attack_delay = -4
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
				if("Hunter")
					melee_damage_lower = 35
					melee_damage_upper = 50
					health = 200
					maxHealth = 200
					storedplasma = 0
					plasma_gain = 10
					maxplasma = 200
					evolution_threshold = 1600
					caste_desc = "A fast, powerful front line combatant. It looks pretty strong."
					speed = -1.8
					armor_deflection = 25
					attack_delay = -3
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 65
				if("Ravager")
					melee_damage_lower = 60
					melee_damage_upper = 80
					health = 250
					maxHealth = 250
					storedplasma = 0
					plasma_gain = 15
					maxplasma = 200
					evolution_threshold = 3200
					caste_desc = "A brutal, devastating front-line attacker. It looks pretty strong."
					speed = -1.4
					armor_deflection = 50
					tacklemin = 5
					tacklemax = 9
					tackle_chance = 90
				if("Crusher")
					melee_damage_lower = 35
					melee_damage_upper = 45
					tacklemin = 5
					tacklemax = 9
					tackle_chance = 70
					health = 300
					maxHealth = 300
					storedplasma = 0
					plasma_gain = 30
					maxplasma = 400
					evolution_threshold = 3200
					caste_desc = "A huge tanky xenomorph. It looks pretty strong."
					armor_deflection = 70
				if("Sentinel")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 175
					maxHealth = 175
					storedplasma = 0
					plasma_gain = 15
					maxplasma = 500
					evolution_threshold = 800
					spit_delay = 20
					caste_desc = "A ranged combat alien. It looks pretty strong."
					armor_deflection = 20
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 60
					speed = -0.8
					spit_type = 0
				if("Spitter")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 200
					maxHealth = 200
					storedplasma = 0
					plasma_gain = 30
					maxplasma = 800
					evolution_threshold = 1600
					spit_delay = 15
					caste_desc = "A ranged damage dealer. It looks pretty strong."
					armor_deflection = 25
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 70
					speed = -0.5
					spit_type = 0
				if("Boiler")
					melee_damage_lower = 30
					melee_damage_upper = 35
					health = 220
					maxHealth = 220
					storedplasma = 0
					plasma_gain = 40
					maxplasma = 1000
					evolution_threshold = 3200
					spit_delay = 20
					caste_desc = "Some sort of abomination. It looks pretty strong."
					armor_deflection = 35
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 70
					speed = 0.8
				if("Praetorian")
					melee_damage_lower = 30
					melee_damage_upper = 35
					health = 250
					maxHealth = 250
					storedplasma = 0
					plasma_gain = 40
					maxplasma = 1000
					evolution_threshold = 3200
					spit_delay = 10
					caste_desc = "A giant ranged monster. It looks pretty strong."
					armor_deflection = 45
					tacklemin = 6
					tacklemax = 9
					tackle_chance = 80
					speed = 0.6
					spit_type = 0
					aura_strength = 3.5
				if("Drone")
					melee_damage_lower = 12
					melee_damage_upper = 16
					health = 150
					maxHealth = 150
					storedplasma = 0
					maxplasma = 900
					plasma_gain = 30
					evolution_threshold = 1500
					caste_desc = "The workhorse of the hive. It looks a little more dangerous."
					armor_deflection = 10
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					speed = -0.8
					aura_strength = 1.5
				if("Hivelord")
					melee_damage_lower = 15
					melee_damage_upper = 20
					health = 250
					maxHealth = 250
					storedplasma = 0
					maxplasma = 1000
					plasma_gain = 50
					evolution_threshold = 3200
					caste_desc = "A builder of REALLY BIG hives. It looks pretty strong."
					armor_deflection = 15
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 70
					speed = 0.8
					aura_strength = 2
				if("Carrier")
					src << "<span class='xenonotice'>Throw a hugger to get your hugger upgrades.</span>"
					melee_damage_lower = 30
					melee_damage_upper = 40
					health = 220
					maxHealth = 220
					storedplasma = 0
					maxplasma = 350
					plasma_gain = 12
					evolution_threshold = 3200
					caste_desc = "A portable Love transport. It looks pretty strong."
					armor_deflection = 10
					tacklemin = 4
					tacklemax = 5
					tackle_chance = 70
					speed = -0.4
					var/mob/living/carbon/Xenomorph/Carrier/CA = src
					CA.huggers_max = 8
					CA.hugger_delay = 20
				if("Queen")
					melee_damage_lower = 50
					melee_damage_upper = 60
					health = 350
					maxHealth = 350
					storedplasma = 0
					maxplasma = 900
					plasma_gain = 50
					evolution_threshold = 3200
					caste_desc = "The biggest and baddest xeno. The Empress controls multiple hives and planets."
					armor_deflection = 55
					tacklemin = 6
					tacklemax = 9
					tackle_chance = 90
					speed = 0.4
					aura_strength = 4

		//Final UPGRADE
		if(2)
			upgrade = 3
			upgrade_name = "Ancient"
			evolution_allowed = 0
			evolution_stored = 0
			evolution_threshold = 0
			switch(caste)
				if("Runner")
					src << "<span class='xenodanger'>You are the fastest assassin of all time. Your speed is unmatched.</span>"
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 140
					maxHealth = 140
					storedplasma = 0
					plasma_gain = 2
					maxplasma = 200
					caste_desc = "Not what you want to run into in a dark alley. It looks fucking deadly."
					speed = -2.2
					armor_deflection = 10
					attack_delay = -4
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 70
				if("Hunter")
					src << "<span class='xenodanger'>You are the epitome of the hunter. Few can stand against you in open combat.</span>"
					melee_damage_lower = 50
					melee_damage_upper = 60
					health = 250
					maxHealth = 250
					storedplasma = 0
					plasma_gain = 20
					maxplasma = 300
					caste_desc = "A completly unmatched hunter. No, not even the Yautja can match you."
					speed = -2
					armor_deflection = 25
					attack_delay = -3
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 65
				if("Ravager")
					src << "<span class='xenodanger'>You are death incarnate. All will tremble before you.</span>"
					melee_damage_lower = 80
					melee_damage_upper = 100
					health = 350
					maxHealth = 350
					storedplasma = 0
					plasma_gain = 15
					maxplasma = 200
					caste_desc = "As I walk through the valley of the shadow of death."
					speed = -1.5
					armor_deflection = 50
					tacklemin = 6
					tacklemax = 10
					tackle_chance = 95
				if("Crusher")
					src << "<span class='xenodanger'>You are the physical manifestation of a Tank. Almost nothing can harm you.</span>"
					melee_damage_lower = 35
					melee_damage_upper = 45
					tacklemin = 5
					tacklemax = 9
					tackle_chance = 75
					health = 350
					maxHealth = 350
					storedplasma = 0
					plasma_gain = 30
					maxplasma = 400
					caste_desc = "It always has the right of way."
					armor_deflection = 75
				if("Sentinel")
					src << "<span class='xenodanger'>You are the stun master. Your stunning is legendary and causes massive quantities of salt.</span>"
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 200
					maxHealth = 200
					storedplasma = 0
					plasma_gain = 20
					maxplasma = 600
					spit_delay = 10
					caste_desc = "Neurotoxin Factory, don't let it get you."
					armor_deflection = 20
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 60
					speed = -1
					spit_type = 0
				if("Spitter")
					src << "<span class='xenodanger'>You are a master of ranged stuns and damage. Go fourth and generate salt.</span>"
					melee_damage_lower = 35
					melee_damage_upper = 45
					health = 250
					maxHealth = 250
					storedplasma = 0
					plasma_gain = 50
					maxplasma = 900
					spit_delay = 5
					caste_desc = "A ranged destruction machine."
					armor_deflection = 30
					tacklemin = 5
					tacklemax = 7
					tackle_chance = 75
					speed = -0.8
					spit_type = 0
				if("Boiler")
					src << "<span class='xenodanger'>You are the master of ranged artillery. Bring death from above.</span>"
					melee_damage_lower = 35
					melee_damage_upper = 45
					health = 250
					maxHealth = 250
					storedplasma = 0
					plasma_gain = 50
					maxplasma = 1000
					spit_delay = 10
					caste_desc = "A devestating piece of alien artillery."
					armor_deflection = 35
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 80
					speed = 0.4
				if("Praetorian")
					src << "<span class='xenodanger'>You are the strongest range fighter around. Your spit is devestating and you can fire nearly a constant stream.</span>"
					melee_damage_lower = 40
					melee_damage_upper = 50
					health = 270
					maxHealth = 270
					storedplasma = 0
					plasma_gain = 50
					maxplasma = 1000
					spit_delay = 0
					caste_desc = "Its mouth looks like a minigun."
					armor_deflection = 45
					tacklemin = 7
					tacklemax = 10
					tackle_chance = 85
					speed = 0.2
					spit_type = 0
					aura_strength = 4.5
				if("Drone")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 200
					maxHealth = 200
					storedplasma = 0
					maxplasma = 1000
					plasma_gain = 50
					caste_desc = "A very mean architect."
					armor_deflection = 15
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 80
					speed = -1
					aura_strength = 2
				if("Hivelord")
					src <<"<span class='xenodanger'>You are the builder of walls. Ensure that the marines are the ones who pay for them.</span>"
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 300
					maxHealth = 300
					storedplasma = 0
					maxplasma = 1200
					plasma_gain = 70
					caste_desc = "An extreme construction machine. It seems to be building walls..."
					armor_deflection = 20
					tacklemin = 5
					tacklemax = 7
					tackle_chance = 80
					speed = 0.4
				if("Carrier")
					src << "<span class='xenodanger'>You are the master of huggers. Throw them like baseballs at the marines!</span>"
					src << "<span class='xenonotice'>Throw a hugger to get your hugger upgrades.</span>"
					melee_damage_lower = 35
					melee_damage_upper = 45
					health = 250
					maxHealth = 250
					storedplasma = 0
					maxplasma = 400
					plasma_gain = 15
					caste_desc = "It's literally crawling with 10 huggers."
					armor_deflection = 15
					tacklemin = 5
					tacklemax = 6
					tackle_chance = 75
					speed = -0.3
					var/mob/living/carbon/Xenomorph/Carrier/CA = src
					CA.huggers_max = 10
					CA.hugger_delay = 10
				if("Queen")
					src << "<span class='xenoannounce'>You are the Alpha and the Omega. The beginning and the end.</span>"
					melee_damage_lower = 70
					melee_damage_upper = 90
					health = 400
					maxHealth = 400
					storedplasma = 0
					maxplasma = 1000
					plasma_gain = 50
					caste_desc = "The most perfect Xeno form imaginable."
					armor_deflection = 55
					tacklemin = 7
					tacklemax = 10
					tackle_chance = 95
					speed = 0.2
					aura_strength = 5

	generate_name() //Give them a new name now


//Tiered spawns.
/mob/living/carbon/Xenomorph/Runner/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Runner/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Runner/ancient/New()
	..()
	upgrade_xeno(1,2)

/mob/living/carbon/Xenomorph/Drone/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Drone/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Drone/ancient/New()
	..()
	upgrade_xeno(1,2)

/mob/living/carbon/Xenomorph/Carrier/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Carrier/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Carrier/ancient/New()
	..()
	upgrade_xeno(1,2)

/mob/living/carbon/Xenomorph/Hivelord/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Hivelord/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Hivelord/ancient/New()
	..()
	upgrade_xeno(1,2)

/mob/living/carbon/Xenomorph/Praetorian/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Praetorian/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Praetorian/ancient/New()
	..()
	upgrade_xeno(1,2)

/mob/living/carbon/Xenomorph/Ravager/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Ravager/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Ravager/ancient/New()
	..()
	upgrade_xeno(1,2)

/mob/living/carbon/Xenomorph/Sentinel/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Sentinel/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Sentinel/ancient/New()
	..()
	upgrade_xeno(1,2)

/mob/living/carbon/Xenomorph/Spitter/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Spitter/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Spitter/ancient/New()
	..()
	upgrade_xeno(1,2)

/mob/living/carbon/Xenomorph/Hunter/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Hunter/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Hunter/ancient/New()
	..()
	upgrade_xeno(1,2)

/mob/living/carbon/Xenomorph/Queen/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Queen/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Queen/ancient/New()
	..()
	upgrade_xeno(1,2)

/mob/living/carbon/Xenomorph/Crusher/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Crusher/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Crusher/ancient/New()
	..()
	upgrade_xeno(1,2)

/mob/living/carbon/Xenomorph/Boiler/mature/New()
	..()
	upgrade_xeno(1,0)

/mob/living/carbon/Xenomorph/Boiler/elite/New()
	..()
	upgrade_xeno(1,1)

/mob/living/carbon/Xenomorph/Boiler/ancient/New()
	..()
	upgrade_xeno(1,2)

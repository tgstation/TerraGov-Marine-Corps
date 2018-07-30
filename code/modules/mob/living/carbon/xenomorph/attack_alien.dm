//This file deals with xenos clicking on stuff in general. Including mobs, objects, general atoms, etc.
//Abby

/*
 * Important note about attack_alien : In our code, attack_ procs are received by src, not dealt by src
 * For example, attack_alien defined for humans means what will happen to THEM when attacked by an alien
 * In that case, the first argument is always the attacker. For attack_alien, it should always be Xenomorph sub-types
 */


/mob/living/carbon/human/attack_alien(mob/living/carbon/Xenomorph/M, dam_bonus)
	if (M.fortify)
		return 0

	//Reviewing the four primary intents
	switch(M.a_intent)

		if("help")
			M.visible_message("<span class='notice'>\The [M] caresses [src] with its scythe-like arm.</span>", \
			"<span class='notice'>You caress [src] with your scythe-like arm.</span>", null, 5)

		if("grab")
			if(M == src || anchored || buckled)
				return 0

			if(check_shields(0, M.name) && prob(66)) //Bit of a bonus
				M.visible_message("<span class='danger'>\The [M]'s grab is blocked by [src]'s shield!</span>", \
				"<span class='danger'>Your grab was blocked by [src]'s shield!</span>", null, 5)
				playsound(loc, 'sound/weapons/alien_claw_block.ogg', 25, 1) //Feedback
				return 0

			if(Adjacent(M)) //Logic!
				M.start_pulling(src)

		if("hurt")
			var/datum/hive_status/hive
			if(M.hivenumber && M.hivenumber <= hive_datum.len)
				hive = hive_datum[M.hivenumber]
			else return

			if(!hive.slashing_allowed && !M.is_intelligent)
				M << "<span class='warning'>Slashing is currently <b>forbidden</b> by the Queen. You refuse to slash [src].</span>"
				r_FAL

			if(stat == DEAD)
				M << "<span class='warning'>[src] is dead, why would you want to touch it?</span>"
				r_FAL

			if(!M.is_intelligent)
				if(hive.slashing_allowed == 2)
					if(status_flags & XENO_HOST)
						for(var/obj/item/alien_embryo/embryo in src)
							if(embryo.hivenumber == M.hivenumber)
								M << "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. There is a host inside!</span>"
								r_FAL

					if(M.health > round(2 * M.maxHealth / 3)) //Note : Under 66 % health
						M << "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. You are not yet injured enough to overcome the Queen's orders.</span>"
						r_FAL

				else if(istype(buckled, /obj/structure/bed/nest) && (status_flags & XENO_HOST))
					for(var/obj/item/alien_embryo/embryo in src)
						if(embryo.hivenumber == M.hivenumber)
							M << "<span class='warning'>You should not harm this host! It has a sister inside.</span>"
							r_FAL

			if(check_shields(0, M.name) && prob(66)) //Bit of a bonus
				M.visible_message("<span class='danger'>\The [M]'s slash is blocked by [src]'s shield!</span>", \
				"<span class='danger'>Your slash is blocked by [src]'s shield!</span>", null, 5)
				r_FAL

			//From this point, we are certain a full attack will go out. Calculate damage and modifiers
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper) + dam_bonus

			//Frenzy auras stack in a way, then the raw value is multipled by two to get the additive modifier
			if(M.frenzy_aura > 0)
				damage += (M.frenzy_aura * 2)

			M.animation_attack_on(src)

			//Check for a special bite attack
			if(prob(M.bite_chance))
				M.bite_attack(src, damage)
				return 1

			//Check for a special bite attack
			if(prob(M.tail_chance))
				M.tail_attack(src, damage)
				return 1

			//Somehow we will deal no damage on this attack
			if(!damage)
				playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
				M.animation_attack_on(src)
				M.visible_message("<span class='danger'>\The [M] lunges at [src]!</span>", \
				"<span class='danger'>You lunge at [src]!</span>", null, 5)
				return 0

			M.flick_attack_overlay(src, "slash")
			var/datum/limb/affecting
			affecting = get_limb(ran_zone(M.zone_selected, 70))
			if(!affecting) //No organ, just get a random one
				affecting = get_limb(ran_zone(null, 0))
			if(!affecting) //Still nothing??
				affecting = get_limb("chest") //Gotta have a torso?!

			var/armor_block = run_armor_check(affecting, "melee")

			if(isYautja(src) && check_zone(M.zone_selected) == "head")
				if(istype(wear_mask, /obj/item/clothing/mask/gas/yautja))
					var/knock_chance = 1
					if(M.frenzy_aura > 0)
						knock_chance += 2 * M.frenzy_aura
					if(M.is_intelligent)
						knock_chance += 2
					knock_chance += min(round(damage * 0.25), 10) //Maximum of 15% chance.
					if(prob(knock_chance))
						playsound(loc, "alien_claw_metal", 25, 1)
						M.visible_message("<span class='danger'>The [M] smashes off [src]'s [wear_mask.name]!</span>", \
						"<span class='danger'>You smash off [src]'s [wear_mask.name]!</span>", null, 5)
						drop_inv_item_on_ground(wear_mask)
						emote("roar")
						return 1

			//The normal attack proceeds
			playsound(loc, "alien_claw_flesh", 25, 1)
			M.visible_message("<span class='danger'>\The [M] slashes [src]!</span>", \
			"<span class='danger'>You slash [src]!</span>")

			//Logging, including anti-rulebreak logging
			if(src.status_flags & XENO_HOST && src.stat != DEAD)
				if(istype(src.buckled, /obj/structure/bed/nest)) //Host was buckled to nest while infected, this is a rule break
					src.attack_log += text("\[[time_stamp()]\] <font color='orange'><B>was slashed by [M.name] ([M.ckey]) while they were infected and nested</B></font>")
					M.attack_log += text("\[[time_stamp()]\] <font color='red'><B>slashed [src.name] ([src.ckey]) while they were infected and nested</B></font>")
					msg_admin_ff("[key_name(M)] slashed [key_name(src)] while they were infected and nested.") //This is a blatant rulebreak, so warn the admins
				else //Host might be rogue, needs further investigation
					src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was slashed by [M.name] ([M.ckey]) while they were infected</font>")
					M.attack_log += text("\[[time_stamp()]\] <font color='red'>slashed [src.name] ([src.ckey]) while they were infected</font>")
			else //Normal xenomorph friendship with benefits
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was slashed by [M.name] ([M.ckey])</font>")
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>slashed [src.name] ([src.ckey])</font>")
			log_attack("[M.name] ([M.ckey]) slashed [src.name] ([src.ckey])")

			if (M.caste == "Ravager")
				var/mob/living/carbon/Xenomorph/Ravager/R = M
				if (R.delimb(src, affecting))
					return 1

			apply_damage(damage, BRUTE, affecting, armor_block, sharp = 1, edge = 1) //This should slicey dicey
			updatehealth()

		if("disarm")
			if(M.legcuffed && isYautja(src))
				M << "<span class='xenodanger'>You don't have the dexterity to tackle the headhunter with that thing on your leg!</span>"
				return 0
			M.animation_attack_on(src)
			if(check_shields(0, M.name) && prob(66)) //Bit of a bonus
				M.visible_message("<span class='danger'>\The [M]'s tackle is blocked by [src]'s shield!</span>", \
				"<span class='danger'>Your tackle is blocked by [src]'s shield!</span>", null, 5)
				return 0
			M.flick_attack_overlay(src, "disarm")
			if(knocked_down)
				if(isYautja(src))
					if(prob(95))
						M.visible_message("<span class='danger'>[src] avoids \the [M]'s tackle!</span>", \
						"<span class='danger'>[src] avoids your attempt to tackle them!</span>", null, 5)
						playsound(loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
						return 1
				else if(prob(80))
					playsound(loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
					M.visible_message("<span class='danger'>\The [M] tries to tackle [src], but they are already down!</span>", \
					"<span class='danger'>You try to tackle [src], but they are already down!</span>", null, 5)
					return 1
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1)
				KnockDown(rand(M.tacklemin, M.tacklemax)) //Min and max tackle strenght. They are located in individual caste files.
				M.visible_message("<span class='danger'>\The [M] tackles down [src]!</span>", \
				"<span class='danger'>You tackle down [src]!</span>", null, 5)

			else
				var/tackle_bonus = 0
				if(M.frenzy_aura > 0)
					tackle_bonus = M.frenzy_aura * 3
				if(isYautja(src))
					if(prob((M.tackle_chance + tackle_bonus)*0.2))
						playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, 1)
						KnockDown(rand(M.tacklemin, M.tacklemax))
						M.visible_message("<span class='danger'>\The [M] tackles down [src]!</span>", \
						"<span class='danger'>You tackle down [src]!</span>", null, 5)
						return 1
					else
						playsound(loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
						M.visible_message("<span class='danger'>\The [M] tries to tackle [src]</span>", \
						"<span class='danger'>You try to tackle [src]</span>", null, 5)
						return 1
				else if(prob(M.tackle_chance + tackle_bonus)) //Tackle_chance is now a special var for each caste.
					playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, 1)
					KnockDown(rand(M.tacklemin, M.tacklemax))
					M.visible_message("<span class='danger'>\The [M] tackles down [src]!</span>", \
					"<span class='danger'>You tackle down [src]!</span>", null, 5)
					return 1

				playsound(loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
				M.visible_message("<span class='danger'>\The [M] tries to tackle [src]</span>", \
				"<span class='danger'>You try to tackle [src]</span>", null, 5)
	return 1


//Every other type of nonhuman mob
/mob/living/attack_alien(mob/living/carbon/Xenomorph/M)
	if (M.fortify)
		return 0;

	switch(M.a_intent)
		if("help")
			M.visible_message("<span class='notice'>\The [M] caresses [src] with its scythe-like arm.</span>", \
			"<span class='notice'>You caress [src] with your scythe-like arm.</span>", null, 5)
			return 0

		if("grab")
			if(M == src || anchored || buckled)
				return 0

			if(Adjacent(M)) //Logic!
				M.start_pulling(src)

		if("hurt")
			if(isXeno(src) && xeno_hivenumber(src) == M.hivenumber)
				M.visible_message("<span class='warning'>\The [M] nibbles [src].</span>", \
				"<span class='warning'>You nibble [src].</span>", null, 5)
				return 1

			var/datum/hive_status/hive
			if(M.hivenumber && M.hivenumber <= hive_datum.len)
				hive = hive_datum[M.hivenumber]
			else return

			if(!M.is_intelligent)
				if(hive.slashing_allowed == 2)
					if(status_flags & XENO_HOST)
						for(var/obj/item/alien_embryo/embryo in src)
							if(embryo.hivenumber == M.hivenumber)
								M << "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. There is a host inside!</span>"
								r_FAL

					if(M.health > round(2 * M.maxHealth / 3)) //Note : Under 66 % health
						M << "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. You are not yet injured enough to overcome the Queen's orders.</span>"
						r_FAL

				else if(istype(buckled, /obj/structure/bed/nest) && (status_flags & XENO_HOST))
					for(var/obj/item/alien_embryo/embryo in src)
						if(embryo.hivenumber == M.hivenumber)
							M << "<span class='warning'>You should not harm this host! It has a sister inside.</span>"
							r_FAL

			if(issilicon(src) && stat != DEAD) //A bit of visual flavor for attacking Cyborgs. Sparks!
				var/datum/effect_system/spark_spread/spark_system
				spark_system = new /datum/effect_system/spark_spread()
				spark_system.set_up(5, 0, src)
				spark_system.attach(src)
				spark_system.start(src)
				playsound(loc, "alien_claw_metal", 25, 1)

			// copypasted from attack_alien.dm
			//From this point, we are certain a full attack will go out. Calculate damage and modifiers
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)

			//Frenzy auras stack in a way, then the raw value is multipled by two to get the additive modifier
			if(M.frenzy_aura > 0)
				damage += (M.frenzy_aura * 2)

			//Somehow we will deal no damage on this attack
			if(!damage)
				playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
				M.animation_attack_on(src)
				M.visible_message("<span class='danger'>\The [M] lunges at [src]!</span>", \
				"<span class='danger'>You lunge at [src]!</span>", null, 5)
				return 0

			M.visible_message("<span class='danger'>\The [M] slashes [src]!</span>", \
			"<span class='danger'>You slash [src]!</span>", null, 5)
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was slashed by [M.name] ([M.ckey])</font>")
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>slashed [src.name] ([src.ckey])</font>")
			log_attack("[M.name] ([M.ckey]) slashed [src.name] ([src.ckey])")

			playsound(loc, "alien_claw_flesh", 25, 1)
			apply_damage(damage, BRUTE)

		if("disarm")
			playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, 1)
			M.visible_message("<span class='warning'>\The [M] shoves [src]!</span>", \
			"<span class='warning'>You shove [src]!</span>", null, 5)
			if(ismonkey(src))
				KnockDown(8)
	return 0

/mob/living/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	M.visible_message("<span class='danger'>[M] nudges its head against [src].</span>", \
	"<span class='danger'>You nudge your head against [src].</span>", null, 5)

//This proc is here to prevent Xenomorphs from picking up objects (default attack_hand behaviour)
//Note that this is overriden by every proc concerning a child of obj unless inherited
/obj/item/attack_alien(mob/living/carbon/Xenomorph/M)
	return

/obj/item/clothing/mask/facehugger/attack_alien(mob/living/carbon/Xenomorph/M)
	attack_hand(M)


/obj/vehicle/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.a_intent == "hurt")
		M.animation_attack_on(src)
		playsound(loc, "alien_claw_metal", 25, 1)
		M.flick_attack_overlay(src, "slash")
		health -= 15
		playsound(src.loc, "alien_claw_metal", 25, 1)
		M.visible_message("<span class='danger'>[M] slashes [src].</span>","<span class='danger'>You slash [src].</span>", null, 5)
		healthcheck()
	else
		attack_hand(M)


/obj/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	return //larva can't do anything

//Closets are used just like humans would
/obj/structure/closet/attack_alien(mob/user as mob)
	return src.attack_hand(user)

//Breaking tables and racks
/obj/structure/table/attack_alien(mob/living/carbon/Xenomorph/M)
	if(breakable)
		M.animation_attack_on(src)
		if(sheet_type == /obj/item/stack/sheet/wood)
			playsound(src, 'sound/effects/woodhit.ogg', 25, 1)
		else
			playsound(src, 'sound/effects/metalhit.ogg', 25, 1)
		health -= rand(M.melee_damage_lower, M.melee_damage_upper)
		if(health <= 0)
			M.visible_message("<span class='danger'>\The [M] slices [src] apart!</span>", \
			"<span class='danger'>You slice [src] apart!</span>", null, 5)
			destroy()
		else
			M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
			"<span class='danger'>You slash [src]!</span>", null, 5)

//Breaking barricades
/obj/structure/barricade/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	health -= rand(M.melee_damage_lower, M.melee_damage_upper)
	if(barricade_hitsound)
		playsound(src, barricade_hitsound, 25, 1)
	if(health <= 0)
		M.visible_message("<span class='danger'>[M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
	else
		M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
		"<span class='danger'>You slash [src]!</span>", null, 5)
	if(is_wired)
		M.visible_message("<span class='danger'>The barbed wire slices into [M]!</span>",
		"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
		M.apply_damage(10)
	update_health(TRUE)


/obj/structure/rack/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	playsound(src, 'sound/effects/metalhit.ogg', 25, 1)
	M.visible_message("<span class='danger'>[M] slices [src] apart!</span>", \
	"<span class='danger'>You slice [src] apart!</span>", null, 5)
	destroy()

//Default "structure" proc. This should be overwritten by sub procs.
//If we sent it to monkey we'd get some weird shit happening.
/obj/structure/attack_alien(mob/living/carbon/Xenomorph/M)
	return 0


//Beds, nests and chairs - unbuckling
/obj/structure/bed/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.a_intent == "hurt")
		M.animation_attack_on(src)
		playsound(src, hit_bed_sound, 25, 1)
		M.visible_message("<span class='danger'>[M] slices [src] apart!</span>",
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
		unbuckle()
		destroy()
	else attack_hand(M)


//Medevac stretchers. Unbuckle ony
/obj/structure/bed/medevac_stretcher/attack_alien(mob/living/carbon/Xenomorph/M)
	unbuckle()

//Smashing lights
/obj/machinery/light/attack_alien(mob/living/carbon/Xenomorph/M)
	if(status == 2) //Ignore if broken. Note that we can't use defines here
		return 0
	M.animation_attack_on(src)
	M.visible_message("<span class='danger'>\The [M] smashes [src]!</span>", \
	"<span class='danger'>You smash [src]!</span>", null, 5)
	broken() //Smashola!

//Smashing windows
/obj/structure/window/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.a_intent == "help")
		playsound(src.loc, 'sound/effects/glassknock.ogg', 25, 1)
		M.visible_message("<span class='warning'>\The [M] creepily taps on [src] with its huge claw.</span>", \
		"<span class='warning'>You creepily tap on [src].</span>", \
		"<span class='warning'>You hear a glass tapping sound.</span>", 5)
	else
		attack_generic(M, M.melee_damage_lower)

//Slashing bots
/obj/machinery/bot/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	health -= rand(15, 30)
	if(health <= 0)
		M.visible_message("<span class='danger'>\The [M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
	else
		M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
		"<span class='danger'>You slash [src]!</span>", null, 5)
	playsound(loc, "alien_claw_metal", 25, 1)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()

//Slashing cameras
/obj/machinery/camera/attack_alien(mob/living/carbon/Xenomorph/M)
	if(status)
		M.visible_message("<span class='danger'>\The [M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
		playsound(loc, "alien_claw_metal", 25, 1)
		wires = 0 //wires all cut
		light_disabled = 0
		toggle_cam_status(M, TRUE)

//Slashing windoors
/obj/machinery/door/window/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
	M.visible_message("<span class='danger'>[M] smashes against [src]!</span>", \
	"<span class='danger'>You smash against [src]!</span>", null, 5)
	var/damage = 25
	if(M.mob_size == MOB_SIZE_BIG)
		damage = 40
	take_damage(damage)

//Slashing mechas
/obj/mecha/attack_alien(mob/living/carbon/Xenomorph/M)
	log_message("Attack by claw. Attacker - [M].", 1)

	if(!prob(deflect_chance))
		take_damage((rand(M.melee_damage_lower, M.melee_damage_upper)/2))
		check_for_internal_damage(list(MECHA_INT_CONTROL_LOST))
		playsound(loc, "alien_claw_metal", 25, 1)
		M.visible_message("<span class='danger'>[M] slashes [src]'s armor!</span>", \
		"<span class='danger'>You slash [src]'s armor!</span>", null, 5)
	else
		src.log_append_to_last("Armor saved.")
		playsound(loc, "alien_claw_metal", 25, 1)
		M.visible_message("<span class='warning'>[M] slashes [src]'s armor to no effect!</span>", \
		"<span class='danger'>You slash [src]'s armor to no effect!</span>", null, 5)

//Slashing grilles
/obj/structure/grille/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	playsound(loc, 'sound/effects/grillehit.ogg', 25, 1)
	var/damage_dealt = 5
	M.visible_message("<span class='danger'>\The [M] mangles [src]!</span>", \
	"<span class='danger'>You mangle [src]!</span>", \
	"<span class='danger'>You hear twisting metal!</span>", 5)

	if(shock(M, 70))
		M.visible_message("<span class='danger'>ZAP! \The [M] spazzes wildly amongst a smell of burnt ozone.</span>", \
		"<span class='danger'>ZAP! You twitch and dance like a monkey on hyperzine!</span>", \
		"<span class='danger'>You hear a sharp ZAP and a smell of ozone.</span>")
		return 0 //Intended apparently ?

	health -= damage_dealt
	healthcheck()

//Slashing fences
/obj/structure/fence/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	var/damage_dealt = 5
	M.visible_message("<span class='danger'>\The [M] mangles [src]!</span>", \
	"<span class='danger'>You mangle [src]!</span>", \
	"<span class='danger'>You hear twisting metal!</span>", 5)

	health -= damage_dealt
	healthcheck()

//Slashin mirrors
/obj/structure/mirror/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	if(shattered)
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 25, 1)
		return 1

	if(M.a_intent == "help")
		M.visible_message("<span class='warning'>\The [M] oogles its own reflection in [src].</span>", \
		"<span class='warning'>You oogle your own reflection in [src].</span>", null, 5)
	else
		M.visible_message("<span class='danger'>\The [M] smashes [src]!</span>", \
		"<span class='danger'>You smash [src]!</span>", null, 5)
		shatter()

//Foamed metal
/obj/structure/foamedmetal/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	if(prob(33))
		M.visible_message("<span class='danger'>\The [M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
		cdel(src)
		return 1
	else
		M.visible_message("<span class='danger'>\The [M] tears some shreds off [src]!</span>", \
		"<span class='danger'>You tear some shreds off [src]!</span>", null, 5)

//Prying open doors
/obj/machinery/door/airlock/attack_alien(mob/living/carbon/Xenomorph/M)
	var/turf/cur_loc = M.loc
	if(isElectrified())
		if(shock(M, 70))
			return
	if(locked)
		M << "<span class='warning'>\The [src] is bolted down tight.</span>"
		return 0
	if(welded)
		M << "<span class='warning'>\The [src] is welded shut.</span>"
		return 0
	if(!istype(cur_loc))
		return 0 //Some basic logic here
	if(!density)
		M << "<span class='warning'>\The [src] is already open!</span>"
		return 0

	if(M.action_busy)
		return 0

	if(M.lying)
		return 0

	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	M.visible_message("<span class='warning'>\The [M] digs into \the [src] and begins to pry it open.</span>", \
	"<span class='warning'>You dig into \the [src] and begin to pry it open.</span>", null, 5)

	if(do_after(M, 40, FALSE, 5, BUSY_ICON_HOSTILE))
		if(M.loc != cur_loc)
			return 0 //Make sure we're still there
		if(M.lying)
			return 0
		if(locked)
			M << "<span class='warning'>\The [src] is bolted down tight.</span>"
			return 0
		if(welded)
			M << "<span class='warning'>\The [src] is welded shut.</span>"
			return 0
		if(density) //Make sure it's still closed
			spawn(0)
				open(1)
				M.visible_message("<span class='danger'>\The [M] pries \the [src] open.</span>", \
				"<span class='danger'>You pry \the [src] open.</span>", null, 5)

/obj/machinery/door/airlock/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	for(var/atom/movable/AM in get_turf(src))
		if(AM != src && AM.density && !AM.CanPass(M, M.loc))
			M << "<span class='warning'>\The [AM] prevents you from squeezing under \the [src]!</span>"
			return
	if(locked || welded) //Can't pass through airlocks that have been bolted down or welded
		M << "<span class='warning'>\The [src] is locked down tight. You can't squeeze underneath!</span>"
		return
	M.visible_message("<span class='warning'>\The [M] scuttles underneath \the [src]!</span>", \
	"<span class='warning'>You squeeze and scuttle underneath \the [src].</span>", null, 5)
	M.forceMove(loc)

//Prying open FIREdoors
/obj/machinery/door/firedoor/attack_alien(mob/living/carbon/Xenomorph/M)
	var/turf/cur_loc = M.loc
	if(blocked)
		M << "<span class='warning'>\The [src] is welded shut.</span>"
		return 0
	if(!istype(cur_loc))
		return 0 //Some basic logic here
	if(!density)
		M << "<span class='warning'>\The [src] is already open!</span>"
		return 0

	playsound(src.loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	M.visible_message("<span class='warning'>\The [M] digs into \the [src] and begins to pry it open.</span>", \
	"<span class='warning'>You dig into \the [src] and begin to pry it open.</span>", null, 5)

	if(do_after(M, 30, FALSE, 5, BUSY_ICON_HOSTILE))
		if(M.loc != cur_loc)
			return 0 //Make sure we're still there
		if(blocked)
			M << "<span class='warning'>\The [src] is welded shut.</span>"
			return 0
		if(density) //Make sure it's still closed
			spawn(0)
				open(1)
				M.visible_message("<span class='danger'>\The [M] pries \the [src] open.</span>", \
				"<span class='danger'>You pry \the [src] open.</span>", null, 5)


//Nerfing the damn Cargo Tug Train
/obj/vehicle/train/attack_alien(mob/living/carbon/Xenomorph/M)
	attack_hand(M)


/obj/structure/mineral_door/resin/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	var/turf/cur_loc = M.loc
	if(!istype(cur_loc))
		return 0
	TryToSwitchState(M)
	return 1

//clicking on resin doors attacks them, or opens them without harm intent
/obj/structure/mineral_door/resin/attack_alien(mob/living/carbon/Xenomorph/M)
	var/turf/cur_loc = M.loc
	if(!istype(cur_loc))
		return 0 //Some basic logic here
	if(M.a_intent != "hurt")
		TryToSwitchState(M)
		return 1

	M.visible_message("<span class='warning'>\The [M] digs into \the [src] and begins ripping it down.</span>", \
	"<span class='warning'>You dig into \the [src] and begin ripping it down.</span>", null, 5)
	playsound(src, "alien_resin_break", 25)
	if(do_after(M, 80, FALSE, 5, BUSY_ICON_HOSTILE))
		if(!loc)
			return 0 //Someone already destroyed it, do_after should check this but best to be safe
		if(M.loc != cur_loc)
			return 0 //Make sure we're still there
		M.visible_message("<span class='danger'>[M] rips down \the [src]!</span>", \
		 "<span class='danger'>You rip down \the [src]!</span>", null, 5)
		cdel(src)

//Xenomorphs can't use machinery, not even the "intelligent" ones
//Exception is Queen and shuttles, because plot power
/obj/machinery/attack_alien(mob/living/carbon/Xenomorph/M)
	M << "<span class='warning'>You stare at \the [src] cluelessly.</span>"

/datum/shuttle/ferry/marine/proc/hijack(mob/living/carbon/Xenomorph/M)
	if(!queen_locked) //we have not hijacked it yet
		if(world.time < SHUTTLE_LOCK_TIME_LOCK)
			M << "<span class='xenodanger'>You can't mobilize the strength to hijack the shuttle yet. Please wait another [round((SHUTTLE_LOCK_TIME_LOCK-world.time)/600)] minutes before trying again.</span>"
			return
		M << "<span class='xenonotice'>You interact with the machine and disable remote control.</span>"
		xeno_message("<span class='xenoannounce'>We have wrested away remote control of the metal bird! Rejoice!</span>",3,M.hivenumber)
		last_locked = world.time
		queen_locked = 1

/datum/shuttle/ferry/marine/proc/door_override(mob/living/carbon/Xenomorph/M)
	if(!door_override)
		M << "<span class='xenonotice'>You override the doors.</span>"
		xeno_message("<span class='xenoannounce'>The doors of the metal bird have been overridden! Rejoice!</span>",3,M.hivenumber)
		last_door_override = world.time
		door_override = 1

		var/ship_id = "sh_dropship1"
		if(shuttle_tag == "[MAIN_SHIP_NAME] Dropship 2")
			ship_id = "sh_dropship2"

		for(var/obj/machinery/door/airlock/dropship_hatch/D in machines)
			if(D.id == ship_id)
				D.unlock()

		var/obj/machinery/door/airlock/multi_tile/almayer/reardoor
		switch(ship_id)
			if("sh_dropship1")
				for(var/obj/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds1/D in machines)
					reardoor = D
			if("sh_dropship2")
				for(var/obj/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds2/D in machines)
					reardoor = D

		reardoor.unlock()

/obj/machinery/computer/shuttle_control/attack_alien(mob/living/carbon/Xenomorph/M)
	var/datum/shuttle/ferry/marine/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if(M.is_intelligent)
		attack_hand(M)
		if(!shuttle.iselevator)
			shuttle.door_override(M)
			if(onboard) //This is the shuttle's onboard console
				shuttle.hijack(M)
	else
		..()

/obj/machinery/door_control/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.is_intelligent && normaldoorcontrol == CONTROL_DROPSHIP)
		var/shuttle_tag
		switch(id)
			if("sh_dropship1")
				shuttle_tag = "[MAIN_SHIP_NAME] Dropship 1"
			if("sh_dropship2")
				shuttle_tag = "[MAIN_SHIP_NAME] Dropship 2"
			else
				return

		var/datum/shuttle/ferry/marine/shuttle = shuttle_controller.shuttles[shuttle_tag]
		shuttle.hijack(M)
		shuttle.door_override(M)
	else
		..()

//APCs.
/obj/machinery/power/apc/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	M.visible_message("<span class='danger'>[M] slashes \the [src]!</span>", \
	"<span class='danger'>You slash \the [src]!</span>", null, 5)
	playsound(loc, "alien_claw_metal", 25, 1)
	var/allcut = 1
	for(var/wire in apcwirelist)
		if(!isWireCut(apcwirelist[wire]))
			allcut = 0
			break

	if(beenhit >= pick(3, 4) && wiresexposed != 1)
		wiresexposed = 1
		update_icon()
		visible_message("<span class='danger'>\The [src]'s cover swings open, exposing the wires!</span>", null, null, 5)

	else if(wiresexposed == 1 && allcut == 0)
		for(var/wire in apcwirelist)
			cut(apcwirelist[wire])
		update_icon()
		visible_message("<span class='danger'>\The [src]'s wires snap apart in a rain of sparks!", null, null, 5)
	else
		beenhit += 1

/obj/structure/ladder/attack_alien(mob/living/carbon/Xenomorph/M)
	return attack_hand(M)

/obj/structure/ladder/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	return attack_hand(M)

/obj/machinery/colony_floodlight/attack_alien(mob/living/carbon/Xenomorph/M)
	if(!is_lit)
		M << "Why bother? It's just some weird metal thing."
		return 0
	else if(damaged)
		M << "It's already damaged."
		return 0
	else
		M.animation_attack_on(src)
		M.visible_message("[M] slashes away at [src]!","You slash and claw at the bright light!", null, null, 5)
		health  = max(health - rand(M.melee_damage_lower, M.melee_damage_upper), 0)
		if(!health)
			playsound(src, "shatter", 70, 1)
			damaged = TRUE
			if(is_lit)
				SetLuminosity(0)
			update_icon()
		else
			playsound(loc, 'sound/effects/Glasshit.ogg', 25, 1)

/obj/machinery/colony_floodlight/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	M.visible_message("[M] starts biting [src]!","In a rage, you start biting [src], but with no effect!", null, 5)



//Digging up snow
/turf/open/snow/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.a_intent == "grab")

		if(!slayer)
			M << "<span class='warning'>There is nothing to clear out!</span>"
			return 0

		M.visible_message("<span class='notice'>\The [M] starts clearing out \the [src].</span>", \
		"<span class='notice'>You start clearing out \the [src].</span>", null, 5)
		playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		if(!do_after(M, 25, FALSE, 5, BUSY_ICON_FRIENDLY))
			return 0

		if(!slayer)
			M  << "<span class='warning'>There is nothing to clear out!</span>"
			return

		M.visible_message("<span class='notice'>\The [M] clears out \the [src].</span>", \
		"<span class='notice'>You clear out \the [src].</span>", null, 5)
		slayer -= 1
		update_icon(1, 0)

/turf/open/snow/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	return //Larvae can't do shit


//Crates, closets, other paraphernalia
/obj/structure/largecrate/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	playsound(src, 'sound/effects/woodhit.ogg', 25, 1)
	new /obj/item/stack/sheet/wood(src)
	var/turf/T = get_turf(src)
	for(var/obj/O in contents)
		O.loc = T
	M.visible_message("<span class='danger'>\The [M] smashes \the [src] apart!</span>", \
	"<span class='danger'>You smash \the [src] apart!</span>", \
	"<span class='danger'>You hear splitting wood!</span>", 5)
	cdel(src)

/obj/structure/closet/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.a_intent == "hurt" && !unacidable)
		M.animation_attack_on(src)
		if(!opened && prob(70))
			break_open()
			M.visible_message("<span class='danger'>\The [M] smashes \the [src] open!</span>", \
			"<span class='danger'>You smash \the [src] open!</span>", null, 5)
		else
			M.visible_message("<span class='danger'>\The [M] smashes \the [src]!</span>", \
			"<span class='danger'>You smash \the [src]!</span>", null, 5)
	else
		return attack_paw(M)

/obj/structure/girder/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.mob_size != MOB_SIZE_BIG || unacidable)
		M << "<span class='warning'>Your claws aren't sharp enough to damage \the [src].</span>"
		return 0
	else
		M.animation_attack_on(src)
		health -= round(rand(M.melee_damage_lower, M.melee_damage_upper) / 2)
		if(health <= 0)
			M.visible_message("<span class='danger'>\The [M] smashes \the [src] apart!</span>", \
			"<span class='danger'>You slice \the [src] apart!</span>", null, 5)
			playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)
			dismantle()
		else
			M.visible_message("<span class='danger'>[M] smashes \the [src]!</span>", \
			"<span class='danger'>You slash \the [src]!</span>", null, 5)
			playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)

/obj/machinery/vending/attack_alien(mob/living/carbon/Xenomorph/M)
	if(tipped_level)
		M << "<span class='warning'>There's no reason to bother with that old piece of trash.</span>"
		return 0

	if(M.a_intent == "hurt")
		M.animation_attack_on(src)
		if(prob(M.melee_damage_lower))
			playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)
			M.visible_message("<span class='danger'>\The [M] smashes \the [src] beyond recognition!</span>", \
			"<span class='danger'>You enter a frenzy and smash \the [src] apart!</span>", null, 5)
			malfunction()
			return 1
		else
			M.visible_message("<span class='danger'>[M] slashes \the [src]!</span>", \
			"<span class='danger'>You slash \the [src]!</span>", null, 5)
			playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)
		return 1

	M.visible_message("<span class='warning'>\The [M] begins to lean against \the [src].</span>", \
	"<span class='warning'>You begin to lean against \the [src].</span>", null, 5)
	tipped_level = 1
	var/shove_time = 100
	if(M.mob_size == MOB_SIZE_BIG)
		shove_time = 50
	if(istype(M,/mob/living/carbon/Xenomorph/Crusher))
		shove_time = 15
	if(do_after(M, shove_time, FALSE, 5, BUSY_ICON_HOSTILE))
		M.visible_message("<span class='danger'>\The [M] knocks \the [src] down!</span>", \
		"<span class='danger'>You knock \the [src] down!</span>", null, 5)
		tip_over()
	else
		tipped_level = 0

/obj/structure/inflatable/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	deflate(1)

/obj/machinery/vending/proc/tip_over()
	var/matrix/A = matrix()
	tipped_level = 2
	density = 0
	A.Turn(90)
	transform = A
	malfunction()

/obj/machinery/vending/proc/flip_back()
	icon_state = initial(icon_state)
	tipped_level = 0
	density = 1
	var/matrix/A = matrix()
	transform = A
	stat &= ~BROKEN //Remove broken. MAGICAL REPAIRS

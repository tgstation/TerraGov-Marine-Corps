/*
This is all of the abilities remade for AI xenos cause I suck at thinking ahead
When I'm not lazy enough I'll port everything from xeno AI life to regular xeno life, throw in some checks and everything will be alright
*/

/mob/living/carbon/Xenomorph/AI/Crusher/proc/stomp()

	if(!check_state()) return

	if(world.time < has_screeched + CRUSHER_STOMP_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='xenowarning'>You are not ready to stomp again.</span>")
		return FALSE

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't rear up to stomp with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to stomp but are unable as you fail to shake off the shock!</span>")
		return

	if(!check_plasma(80))
		return
	has_screeched = world.time
	use_plasma(80)

	round_statistics.crusher_stomps++

	playsound(loc, 'sound/effects/bang.ogg', 25, 0)
	visible_message("<span class='xenodanger'>[src] smashes into the ground!</span>", \
	"<span class='xenodanger'>You smash into the ground!</span>")
	create_stomp() //Adds the visual effect. Wom wom wom

	for(var/mob/living/M in range(2,loc))
		if(isxeno(M) || M.stat == DEAD || ((M.status_flags & XENO_HOST) && istype(M.buckled, /obj/structure/bed/nest)))
			continue
		var/distance = get_dist(M, loc)
		var/damage = (rand(xeno_caste.melee_damage_lower, xeno_caste.melee_damage_upper) * 1.5) / max(1,distance + 1)
		if(frenzy_aura > 0)
			damage *= (1 + round(frenzy_aura * 0.1,0.01)) //+10% per level of Frenzy
		if(distance == 0) //If we're on top of our victim, give him the full impact
			round_statistics.crusher_stomp_victims++
			var/armor_block = M.run_armor_check("chest", "melee")
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.take_overall_damage(rand(damage * 0.75,damage * 1.25), armor_block) //Armour functions against this.
			else
				M.take_overall_damage(rand(damage * 0.75,damage * 1.25), armor_block) //Armour functions against this.
			to_chat(M, "<span class='highdanger'>You are stomped on by [src]!</span>")
			shake_camera(M, 3, 3)
		else
			step_away(M, src, 1) //Knock away
			shake_camera(M, 2, 2)
			to_chat(M, "<span class='highdanger'>You reel from the shockwave of [src]'s stomp!</span>")
		if(distance < 2) //If we're beside or adjacent to the Crusher, we get knocked down.
			M.KnockDown(1)
		else
			M.Stun(1) //Otherwise we just get stunned.
		M.apply_damage(rand(damage * 0.75 , damage * 1.25), HALLOSS) //Armour ignoring Halloss

/mob/living/carbon/Xenomorph/AI/Queen/proc/queen_screech()
	if(!check_state())
		return

	if(has_screeched)
		to_chat(src, "<span class='warning'>You are not ready to screech again.</span>")
		return

	if(!check_plasma(250))
		return

	//screech is so powerful it kills huggers in our hands
	if(istype(r_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = r_hand
		if(FH.stat != DEAD)
			FH.Die()

	if(istype(l_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = l_hand
		if(FH.stat != DEAD)
			FH.Die()

	has_screeched = 1
	use_plasma(250)
	spawn(500)
		has_screeched = 0
		to_chat(src, "<span class='warning'>You feel your throat muscles vibrate. You are ready to screech again.</span>")
		for(var/Z in actions)
			var/datum/action/A = Z
			A.update_button_icon()
	playsound(loc, 'sound/voice/alien_queen_screech.ogg', 75, 0)
	visible_message("<span class='xenohighdanger'>\The [src] emits an ear-splitting guttural roar!</span>")
	round_statistics.queen_screech++
	create_shriekwave() //Adds the visual effect. Wom wom wom
	//stop_momentum(charge_dir) //Screech kills a charge

	for(var/mob/M in view())
		if(M && M.client)
			if(isxeno(M))
				shake_camera(M, 10, 1)
			else
				shake_camera(M, 30, 1) //50 deciseconds, SORRY 5 seconds was way too long. 3 seconds now

	for(var/mob/living/carbon/human/H in oview(7, src))
		var/dist = get_dist(src,H)
		var/reduction = max(1 - 0.1 * H.protection_aura, 0) //Hold orders will reduce the Halloss; 10% per rank.
		var/halloss_damage = (max(0,140 - dist * 10)) * reduction //Max 130 beside Queen, 70 at the edge
		var/stun_duration = max(0,1.1 - dist * 0.1) * reduction //Max 1 beside Queen, 0.4 at the edge.

		if(dist < 8)
			to_chat(H, "<span class='danger'>An ear-splitting guttural roar tears through your mind and makes your world convulse!</span>")
			H.stunned += stun_duration
			H.KnockDown(stun_duration)
			H.apply_damage(halloss_damage, HALLOSS)
			if(!H.ear_deaf)
				H.ear_deaf += stun_duration * 20  //Deafens them temporarily
			spawn(31)
				shake_camera(H, stun_duration * 10, 0.75) //Perception distorting effects of the psychic scream

/mob/living/carbon/Xenomorph/AI/Queen/proc/mount_ovipositor()
	if(ovipositor) return //sanity check
	ovipositor = TRUE

	for(var/datum/action/A in actions)
		qdel(A)

	var/list/immobile_abilities = list(\
		/datum/action/xeno_action/regurgitate,\
		/datum/action/xeno_action/remove_eggsac,\
		/datum/action/xeno_action/activable/screech,\
		/datum/action/xeno_action/psychic_whisper,\
		/datum/action/xeno_action/watch_xeno,\
		/datum/action/xeno_action/toggle_queen_zoom,\
		/datum/action/xeno_action/set_xeno_lead,\
		/datum/action/xeno_action/queen_heal,\
		/datum/action/xeno_action/queen_give_plasma,\
		/datum/action/xeno_action/queen_order,\
		/datum/action/xeno_action/deevolve, \
		/datum/action/xeno_action/toggle_pheromones, \
		)

	for(var/path in immobile_abilities)
		var/datum/action/xeno_action/A = new path()
		A.give_action(src)

	anchored = TRUE
	resting = FALSE
	update_canmove()
	update_icons()
/*
	if(hivenumber && hivenumber <= hive_datum.len)
		var/datum/hive_status/hive = hive_datum[hivenumber]

		for(var/mob/living/carbon/Xenomorph/L in hive.xeno_leader_list)
			L.handle_xeno_leader_pheromones(src)
*/
	xeno_message("<span class='xenoannounce'>The Queen has grown an ovipositor, evolution progress resumed.</span>", 3, hivenumber)

/mob/living/carbon/Xenomorph/AI/Ravager/proc/charge(atom/T)
	if(!T) return

	if(!check_state())
		return

	if(usedPounce)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before using Eviscerating Charge. It can be used in: [(charge_delay - world.time) * 0.1] seconds.</span>")
		return

	if(!check_plasma(80))
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't charge with that thing on your leg!</span>")
		return

	visible_message("<span class='danger'>[src] charges towards \the [T]!</span>", \
	"<span class='danger'>You charge towards \the [T]!</span>" )
	emote("roar") //heheh
	usedPounce = 1 //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	use_plasma(80)

	throw_at(T, RAV_CHARGEDISTANCE, RAV_CHARGESPEED, src)

	charge_delay = world.time + RAV_CHARGECOOLDOWN

	spawn(RAV_CHARGECOOLDOWN)
		usedPounce = FALSE
		to_chat(src, "<span class='xenodanger'>Your exoskeleton quivers as you get ready to use Eviscerating Charge again.</span>")
		playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
		update_action_button_icons()

/mob/living/carbon/Xenomorph/AI/Hunter/proc/Stealth()

	if(!check_state())
		return

	if(world.time < stealth_delay)
		to_chat(src, "<span class='xenodanger'><b>You're not yet ready to Stealth again. You'll be ready in [(stealth_delay - world.time)*0.1] seconds.</span>")
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't enter Stealth with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenodanger'>You're too disoriented from the shock to enter Stealth!</span>")
		return

	if(!stealth)
		if (!check_plasma(10))
			return
		else
			use_plasma(10)
			to_chat(src, "<span class='xenodanger'>You vanish into the shadows...</span>")
			last_stealth = world.time
			stealth = TRUE
			handle_stealth()
			sneak_attack_cooldown()
	else
		cancel_stealth()

/mob/living/carbon/Xenomorph/AI/Hunter/proc/stealth_cooldown_notice()
	if(!used_stealth)//sanity check/safeguard
		return
	spawn(HUNTER_STEALTH_COOLDOWN)
		used_stealth = FALSE
		to_chat(src, "<span class='notice'><b>You're ready to use Stealth again.</b></span>")
		playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
		update_action_button_icons()

/mob/living/carbon/Xenomorph/AI/Hunter/proc/cancel_stealth() //This happens if we take damage, attack, pounce, toggle stealth off, and do other such exciting stealth breaking activities.
	if(!stealth)//sanity check/safeguard
		return
	to_chat(src, "<span class='xenodanger'>You emerge from the shadows.</span>")
	stealth = FALSE
	used_stealth = TRUE
	can_sneak_attack = FALSE
	alpha = 255 //no transparency/translucency
	stealth_delay = world.time + HUNTER_STEALTH_COOLDOWN
	stealth_cooldown_notice()

/mob/living/carbon/Xenomorph/AI/Hunter/proc/sneak_attack_cooldown()
	if(can_sneak_attack)
		return
	spawn(HUNTER_POUNCE_SNEAKATTACK_DELAY)
		can_sneak_attack = TRUE
		to_chat(src, "<span class='xenodanger'>You're ready to use Sneak Attack while stealthed.</span>")
		playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)

/mob/living/carbon/Xenomorph/AI/Hunter/proc/handle_stealth()
	if(!stealth_router(HANDLE_STEALTH_CHECK))
		return
	if(stat != CONSCIOUS || stealth == FALSE || lying || resting) //Can't stealth while unconscious/resting
		cancel_stealth()
		return
	//Initial stealth
	if(last_stealth > world.time - HUNTER_STEALTH_INITIAL_DELAY) //We don't start out at max invisibility
		alpha = HUNTER_STEALTH_RUN_ALPHA //50% invisible
		return
	//Stationary stealth
	else if(last_move_intent < world.time - HUNTER_STEALTH_STEALTH_DELAY) //If we're standing still for 4 seconds we become almost completely invisible
		alpha = HUNTER_STEALTH_STILL_ALPHA //95% invisible
	//Walking stealth
	else if(m_intent == MOVE_INTENT_WALK)
		alpha = HUNTER_STEALTH_WALK_ALPHA //80% invisible
	//Running stealth
	else
		alpha = HUNTER_STEALTH_RUN_ALPHA //50% invisible
	//If we have 0 plasma after expending stealth's upkeep plasma, end stealth.
	if(!plasma_stored)
		to_chat(src, "<span class='xenodanger'>You lack sufficient plasma to remain camouflaged.</span>")
		cancel_stealth()

/mob/living/carbon/Xenomorph/AI/Ravager/proc/Ravage(atom/A)
	if (!check_state())
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake off the shock!</span>")
		return

	if (ravage_used)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before Ravaging. Ravage can be used in [(ravage_delay - world.time) * 0.1] seconds.</span>")
		return

	var/dist = get_dist(src,A)
	if (dist > 2)
		if(world.time > (recent_notice + notice_delay)) //anti-notice spam
			to_chat(src, "<span class='xenowarning'>Your target is too far away!</span>")

			recent_notice = world.time //anti-notice spam
		return

	if (!check_plasma(40))
		return

	emote("roar")
	round_statistics.ravager_ravages++
	visible_message("<span class='danger'>\The [src] thrashes about in a murderous frenzy!</span>", \
	"<span class='xenowarning'>You thrash about in a murderous frenzy!</span>")

	face_atom(A)
	if(dist > 1) //Lunge towards the target turf
		step_towards(src,A,2)

	var/sweep_range = 1
	var/list/L = orange(sweep_range)		// Not actually the fruit
	var/victims
	var/target_facing
	for (var/mob/living/carbon/human/H in L)
		if(victims >= 3) //Max 3 victims
			break
		target_facing = get_dir(src, H)
		if(target_facing != dir && target_facing != turn(dir,45) && target_facing != turn(dir,-45) ) //Have to be actually facing the target
			continue
		if(H.stat != DEAD && !(istype(H.buckled, /obj/structure/bed/nest) && H.status_flags & XENO_HOST) ) //No bully
			var/extra_dam = rand(xeno_caste.melee_damage_lower, xeno_caste.melee_damage_upper) * (1 + round(rage * 0.01) ) //+1% bonus damage per point of Rage.relative to base melee damage.
			H.attack_alien(src,  extra_dam, FALSE, TRUE, FALSE, TRUE, "hurt")
			victims++
			round_statistics.ravager_ravage_victims++
		step_away(H, src, sweep_range, 2)
		shake_camera(H, 2, 1)
		H.KnockDown(1, 1)

	victims = CLAMP(victims,0,3) //Just to be sure
	rage = (0 + 10 * victims) //rage resets to 0, though we regain 10 rage per victim.

	ravage_used = TRUE
	use_plasma(40)

	ravage_delay = world.time + (RAV_RAVAGE_COOLDOWN - (victims * 30))

	spawn(CLAMP(RAV_RAVAGE_COOLDOWN - (victims * 30),10,100)) //10 second cooldown base, minus 2 per victim
		ravage_used = FALSE
		to_chat(src, "<span class='xenodanger'>You gather enough strength to Ravage again.</span>")
		playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
		update_action_button_icons()

/mob/living/carbon/Xenomorph/proc/Pounce(atom/T)

	if(!T || !check_state() || !check_plasma(10) || T.layer >= FLY_LAYER) //anything above that shouldn't be pounceable (hud stuff)
		return

	if(!isturf(loc))
		to_chat(src, "<span class='xenowarning'>You can't pounce from here!</span>")
		return

	if(usedPounce)
		to_chat(src, "<span class='xenowarning'>You must wait before pouncing.</span>")
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't pounce with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake up the shock!</span>")
		return

	if(layer == XENO_HIDING_LAYER) //Xeno is currently hiding, unhide him
		layer = MOB_LAYER

	if(m_intent == "walk" && isxenohunter(src)) //Hunter that is currently using its stealth ability, need to unstealth him
		m_intent = "run"
		if(hud_used && hud_used.move_intent)
			hud_used.move_intent.icon_state = "running"
		update_icons()

	visible_message("<span class='xenowarning'>\The [src] pounces at [T]!</span>", \
	"<span class='xenowarning'>You pounce at [T]!</span>")
	usedPounce = TRUE
	flags_pass = PASSTABLE
	use_plasma(10)
	throw_at(T, 6, 2, src) //Victim, distance, speed
	addtimer(CALLBACK(src, .reset_flags_pass), 6)
	addtimer(CALLBACK(src, .reset_pounce_delay), xeno_caste.pounce_delay)

	return TRUE

/mob/living/carbon/Xenomorph/proc/reset_pounce_delay()
	usedPounce = FALSE
	to_chat(src, "<span class='xenodanger'>You're ready to pounce again.</span>")
	update_action_button_icons()
	playsound(src, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)

/mob/living/carbon/Xenomorph/proc/reset_flags_pass()
	if(!xeno_caste.hardcore)
		flags_pass = initial(flags_pass) //Reset the passtable.
	else
		flags_pass = NOFLAGS //Reset the passtable.


/atom/proc/acid_spray_act(mob/living/carbon/Xenomorph/X)
	return TRUE

/obj/structure/acid_spray_act(mob/living/carbon/Xenomorph/X)
	if(!is_type_in_typecache(src, GLOB.acid_spray_hit))
		return TRUE // normal density flag
	obj_integrity -= rand(40,60) + SPRAY_STRUCTURE_UPGRADE_BONUS(X)
	update_health(TRUE)
	return TRUE // normal density flag

/obj/structure/razorwire/acid_spray_act(mob/living/carbon/Xenomorph/X)
	. = ..()
	return FALSE // not normal density flag

/obj/vehicle/multitile/root/cm_armored/acid_spray_act(mob/living/carbon/Xenomorph/X)
	take_damage_type(rand(40,60) + SPRAY_STRUCTURE_UPGRADE_BONUS(X), "acid", src)
	healthcheck()
	return TRUE

/mob/living/carbon/acid_spray_act(mob/living/carbon/Xenomorph/X)
	if((status_flags & XENO_HOST) && istype(buckled, /obj/structure/bed/nest))
		return

	if(isxenopraetorian(X))
		round_statistics.praetorian_spray_direct_hits++

	acid_process_cooldown = world.time //prevent the victim from being damaged by acid puddle process damage for 1 second, so there's no chance they get immediately double dipped by it.
	var/armor_block = run_armor_check("chest", "acid")
	var/damage = rand(30,40) + SPRAY_MOB_UPGRADE_BONUS(X)
	apply_acid_spray_damage(damage, armor_block)
	to_chat(src, "<span class='xenodanger'>\The [X] showers you in corrosive acid!</span>")

/mob/living/carbon/proc/apply_acid_spray_damage(damage, armor_block)
	apply_damage(damage, BURN, null, armor_block)

/mob/living/carbon/human/apply_acid_spray_damage(damage, armor_block)
	take_overall_damage(null, damage, null, null, null, armor_block)
	emote("scream")
	KnockDown(1)

/mob/living/carbon/Xenomorph/acid_spray_act(mob/living/carbon/Xenomorph/X)
	return







/* WIP Burrower stuff
/mob/living/carbon/Xenomorph/proc/burrow()
	if (!check_state())
		return

	if (used_burrow)
		return

	burrow = !burrow
	used_burrow = 1

	if (burrow)
		// TODO Make immune to all damage here.
		to_chat(src, "<span class='xenowarning'>You burrow yourself into the ground.</span>")
		set_frozen(TRUE)
		invisibility = INVISIBILITY_MAXIMUM
		anchored = TRUE
		density = FALSE
		update_canmove()
		update_icons()
		do_burrow_cooldown()
		burrow_timer = world.timeofday + 90		// How long we can be burrowed
		process_burrow()
		return

	burrow_off()
	do_burrow_cooldown()

/mob/living/carbon/Xenomorph/proc/process_burrow()
	set background = 1

	spawn while (burrow)
		if (world.timeofday > burrow_timer && !tunnel)
			burrow = 0
			burrow_off()
		sleep(10)	// Process every second.

/mob/living/carbon/Xenomorph/proc/burrow_off()

	to_chat(src, "<span class='notice'>You resurface.</span>")
	set_frozen(FALSE)
	invisibility = 0
	anchored = 0
	density = 1
	update_canmove()
	update_icons()

/mob/living/carbon/Xenomorph/proc/do_burrow_cooldown()
	spawn(burrow_cooldown)
		used_burrow = 0
		to_chat(src, "<span class='notice'>You can now surface or tunnel.</span>")
		update_action_button_icons()


/mob/living/carbon/Xenomorph/proc/tunnel(var/turf/T)
	if (!burrow)
		to_chat(src, "<span class='notice'>You must be burrowed to do this.</span>")
		return

	if (used_burrow || used_tunnel)
		to_chat(src, "<span class='notice'>You must wait some time to do this.</span>")
		return

	if (tunnel)
		tunnel = 0
		to_chat(src, "<span class='notice'>You stop tunneling.</span>")
		used_tunnel = 1
		do_tunnel_cooldown()
		return

	if (!T || T.density)
		to_chat(src, "<span class='notice'>You cannot tunnel to there!</span>")

	tunnel = 1
	process_tunnel(T)


/mob/living/carbon/Xenomorph/proc/process_tunnel(var/turf/T)
	set background = 1

	spawn while (tunnel && T)
		if (world.timeofday > tunnel_timer)
			tunnel = 0
			do_tunnel()
		sleep(10)	// Process every second.

/mob/living/carbon/Xenomorph/proc/do_tunnel(var/turf/T)
	to_chat(src, "<span class='notice'>You tunnel to your destination.</span>")
	M.forceMove(T)
	burrow = 0
	burrow_off()

/mob/living/carbon/Xenomorph/proc/do_tunnel_cooldown()
	spawn(tunnel_cooldown)
		used_tunnel = 0
		to_chat(src, "<span class='notice'>You can now tunnel while burrowed.</span>")
		update_action_button_icons()
*/

// Vent Crawl
/mob/living/carbon/Xenomorph/proc/vent_crawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	if(!check_state())
		return
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)

/mob/living/carbon/Xenomorph/proc/xeno_salvage_plasma(atom/A, amount, salvage_delay, max_range)
	if(!isxeno(A) || !check_state() || A == src)
		return

	var/mob/living/carbon/Xenomorph/target = A

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You can't salvage plasma from here!</span>")
		return

	if(plasma_stored >= xeno_caste.plasma_max)
		to_chat(src, "<span class='notice'>Your plasma reserves are already at full capacity and can't hold any more.</span>")
		return

	if(target.stat != DEAD)
		to_chat(src, "<span class='warning'>You can't steal plasma from living sisters, ask for some to a drone or a hivelord instead!</span>")
		return

	if(get_dist(src, target) > max_range)
		to_chat(src, "<span class='warning'>You need to be closer to plasma.</span>")
		return

	if(!(target.plasma_stored))
		to_chat(src, "<span class='notice'>[target] doesn't have any plasma left to salvage.</span>")
		return

	to_chat(src, "<span class='notice'>You start salvaging plasma from [target].</span>")

	while(target.plasma_stored && plasma_stored >= xeno_caste.plasma_max)
		if(!do_after(src, salvage_delay, TRUE, 5, BUSY_ICON_HOSTILE) || !check_state())
			break

		if(!isturf(loc))
			to_chat(src, "<span class='warning'>You can't absorb plasma from here!</span>")
			break

		if(get_dist(src, target) > max_range)
			to_chat(src, "<span class='warning'>You need to be closer to [target].</span>")
			break

		if(stagger)
			to_chat(src, "<span class='xenowarning'>Your muscles fail to respond as you try to shake up the shock!</span>")
			break

		if(target.plasma_stored < amount)
			amount = target.plasma_stored //Just take it all.

		var/absorbed_amount = round(amount * PLASMA_SALVAGE_MULTIPLIER)
		target.use_plasma(amount)
		gain_plasma(absorbed_amount)
		to_chat(src, "<span class='xenowarning'>You salvage [absorbed_amount] units of plasma from [target]. You have [plasma_stored]/[xeno_caste.plasma_max] stored now.</span>")
		if(prob(50))
			playsound(src, "alien_drool", 25)



/mob/living/carbon/Xenomorph/verb/toggle_xeno_mobhud()
	set name = "Toggle Xeno Status HUD"
	set desc = "Toggles the health and plasma hud appearing above Xenomorphs."
	set category = "Alien"

	xeno_mobhud = !xeno_mobhud
	var/datum/mob_hud/H = huds[MOB_HUD_XENO_STATUS]
	if(xeno_mobhud)
		H.add_hud_to(usr)
	else
		H.remove_hud_from(usr)


/mob/living/carbon/Xenomorph/verb/middle_mousetoggle()
	set name = "Toggle Middle/Shift Clicking"
	set desc = "Toggles between using middle mouse click and shift click for selected abilitiy use."
	set category = "Alien"

	middle_mouse_toggle = !middle_mouse_toggle
	if(!middle_mouse_toggle)
		to_chat(src, "<span class='notice'>The selected xeno ability will now be activated with shift clicking.</span>")
	else
		to_chat(src, "<span class='notice'>The selected xeno ability will now be activated with middle mouse clicking.</span>")


/mob/living/carbon/Xenomorph/proc/recurring_injection(mob/living/carbon/C, toxin = "xeno_toxin", channel_time = XENO_NEURO_CHANNEL_TIME, transfer_amount = XENO_NEURO_AMOUNT_RECURRING, count = 3)
	if(!(C?.can_sting()) || !toxin)
		return FALSE
	var/datum/reagent/body_tox
	var/i = 1
	do
		face_atom(C)
		if(stagger)
			return FALSE
		body_tox = C.reagents.get_reagent(toxin)
		if(CHECK_BITFIELD(C.status_flags, XENO_HOST) && body_tox && body_tox.volume > body_tox.overdose_threshold)
			to_chat(src, "<span class='warning'>You sense the infected host is saturated with [body_tox.name] and cease your attempt to inoculate it further to preserve the little one inside.</span>")
			return FALSE
		animation_attack_on(C)
		playsound(C, 'sound/effects/spray3.ogg', 15, 1)
		playsound(C, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
		C.reagents.add_reagent(toxin, transfer_amount)
		if(!body_tox) //Let's check this each time because depending on the metabolization rate it can disappear between stings.
			body_tox = C.reagents.get_reagent(toxin)
		to_chat(C, "<span class='danger'>You feel a tiny prick.</span>")
		to_chat(src, "<span class='xenowarning'>Your stinger injects your victim with [body_tox.name]!</span>")
		if(body_tox.volume > body_tox.overdose_threshold)
			to_chat(src, "<span class='danger'>You sense the host is saturated with [body_tox.name].</span>")
	while(i++ < count && do_after(src, channel_time, TRUE, 5, BUSY_ICON_HOSTILE))
	return TRUE


/mob/living/carbon/Xenomorph/proc/neurotoxin_sting(mob/living/carbon/C)

	if(!check_state())
		return

	if(!(C?.can_sting()))
		to_chat(src, "<span class='warning'>Your sting won't affect this target!</span>")
		return

	if(world.time < last_neurotoxin_sting + XENO_NEURO_STING_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='warning'>You are not ready to use the sting again. It will be ready in [(last_neurotoxin_sting + XENO_NEURO_STING_COOLDOWN - world.time) * 0.1] seconds.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='warning'>You try to sting but are too disoriented!</span>")
		return

	if(!Adjacent(C))
		if(world.time > (recent_notice + notice_delay)) //anti-notice spam
			to_chat(src, "<span class='warning'>You can't reach this target!</span>")
			recent_notice = world.time //anti-notice spam
		return

	if (CHECK_BITFIELD(C.status_flags, XENO_HOST) && istype(C.buckled, /obj/structure/bed/nest))
		to_chat(src, "<span class='warning'>Ashamed, you reconsider bullying the poor, nested host with your stinger.</span>")
		return

	if(!check_plasma(150))
		return
	last_neurotoxin_sting = world.time
	use_plasma(150)

	round_statistics.sentinel_neurotoxin_stings++

	addtimer(CALLBACK(src, .neurotoxin_sting_cooldown), XENO_NEURO_STING_COOLDOWN)
	recurring_injection(C, "xeno_toxin", XENO_NEURO_CHANNEL_TIME, XENO_NEURO_AMOUNT_RECURRING)


/mob/living/carbon/Xenomorph/proc/neurotoxin_sting_cooldown()
	playsound(loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(src, "<span class='xenodanger'>You feel your neurotoxin glands refill. You can use your Neurotoxin Sting again.</span>")
	update_action_button_icons()





/atom/proc/can_sting()
	return FALSE

/mob/living/carbon/can_sting()
	if(stat == DEAD || CHECK_BITFIELD(status_flags, GODMODE))
		return FALSE
	return TRUE

/mob/living/carbon/human/can_sting()
	. = ..()
	if(!.)
		return FALSE
	if(CHECK_BITFIELD(species.species_flags, IS_SYNTHETIC))
		return FALSE
	return TRUE

/mob/living/carbon/Xenomorph/can_sting()
	return FALSE

/mob/living/carbon/Xenomorph/proc/hit_and_run_bonus(damage)
	return damage


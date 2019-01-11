/datum/xeno_caste/defiler
	caste_name = "Defiler"
	display_name = "Defiler"
	upgrade_name = "Young"
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids."
	caste_type_path = /mob/living/carbon/Xenomorph/Defiler
	tier = 3
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 20

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = 400

	deevolves_to = /mob/living/carbon/Xenomorph/Carrier

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	armor_deflection = 30

	// *** Defiler Abilities *** //

/datum/xeno_caste/defiler/mature
	upgrade_name = "Mature"
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids. It looks a little more dangerous."

	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 35
	melee_damage_upper = 45

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = -1.1

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 25

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 40

	// *** Warrior Abilities *** //

/datum/xeno_caste/defiler/elder
	upgrade_name = "Elder"
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids. It looks pretty strong."

	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 40
	melee_damage_upper = 45

	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = -1.7

	// *** Plasma *** //
	plasma_max = 550
	plasma_gain = 28

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 47

	// *** Defiler Abilities *** //

/datum/xeno_caste/defiler/ancient
	upgrade_name = "Ancient"
	caste_desc = "Being within mere eyeshot of this hulking, dripping monstrosity fills you with a deep, unshakeable sense of unease."
	ancient_message = "You are the ultimate alien rapist. You will impregnate the marines, see them burst open before you, and hear the gleeful screes of your larvae."
	upgrade = 3

	// *** Melee Attacks *** //
	melee_damage_lower = 45
	melee_damage_upper = 50

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 575
	plasma_gain = 30

	// *** Health *** //
	max_health = 315

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 50

	// *** Warrior Abilities *** //
	agility_speed_increase = 0

/mob/living/carbon/Xenomorph/Defiler
	caste_base_type = /mob/living/carbon/Xenomorph/Defiler
	name = "Defiler"
	desc = "A frightening looking, bulky xeno that drips with suspect green fluids."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Warrior Walking"
	health = 225
	maxHealth = 225
	plasma_stored = 50
	speed = -1
	pixel_x = -16
	old_x = -16
	tier = 2
	upgrade = 0
	var/datum/effect_system/smoke_spread/smoke_system = null
	var/last_defiler_sting = null
	var/last_emit_neurogas = null
	var/last_use_neuroclaws = null
	var/neuro_claws = FALSE
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/toggle_agility,
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/punch
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

/mob/living/carbon/Xenomorph/Defiler/update_icons()
	if (stat == DEAD)
		icon_state = "Defiler Dead"
	else if (lying)
		if ((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "Defiler Sleeping"
		else
			icon_state = "Defiler Knocked Down"
	else
		if (m_intent == MOVE_INTENT_RUN)
			icon_state = "Defiler Running"
		else
			icon_state = "Defiler Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds()

/mob/living/carbon/Xenomorph/Defiler/throw_item(atom/target)
	throw_mode_off()


/mob/living/carbon/Xenomorph/Defiler/stop_pulling()
	if(isliving(pulling))
		var/mob/living/L = pulling
		L.SetStunned(0)
	..()

/mob/living/carbon/Xenomorph/Defiler/proc/emit_neurogas()

	if(!check_state()) return

	if(world.time < has_screeched + DEFILER_GAS_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='xenowarning'>You are not ready to emit neurogas again.</span>")
		return FALSE

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
		return

	if(!check_plasma(150))
		return
	has_screeched = world.time
	use_plasma(150)

	round_statistics.defiler_neurogas_uses++

	playsound(loc, 'sound/effects/bang.ogg', 25, 0)
	visible_message("<span class='xenodanger'>[src] emits a noxious gas!</span>", \
	"<span class='xenodanger'>You emit neurogas!</span>")
	emit_neurogas()

/mob/living/carbon/Xenomorph/Defiler/proc/dispense_gas()
	var/turf/T = get_turf(src)
	smoke_system = new /datum/effect_system/smoke_spread/xeno_weaken()
	smoke_system.amount = 1 + upgrade
	smoke_system.set_up(4, 0, T)
	smoke_system.start()
	T.visible_message("<span class='danger'>Noxious smoke billows from the hulking xenomorph!</span>")


/mob/living/carbon/Xenomorph/Defiler/proc/defiler_sting(var/mob/living/H)

	if(!check_state())
		return

	if(world.time < last_defiler_sting + DEFILER_STING_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='xenowarning'>You are not ready to use the sting again. It will be ready in [(last_defiler_sting + DEFILER_STING_COOLDOWN - world.time) * 0.1] seconds.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to sting but are too disoriented!</span>")
		return

	if(!istype(H) || isXeno(H) || isrobot(H))
		to_chat(src, "<span class='xenowarning'>Your sting won't affect this target!</span>")
		return

	if(!Adjacent(H))
		if(world.time > (recent_notice + notice_delay)) //anti-notice spam
			to_chat(src, "<span class='xenowarning'>You can't reach this target!</span>")
			recent_notice = world.time //anti-notice spam
		return

	if ((H.status_flags & XENO_HOST) && istype(H.buckled, /obj/structure/bed/nest))
		to_chat(src, "<span class='xenowarning'>Ashamed, you reconsider bullying the poor, nested host with your stinger.</span>")
		return

	if(!check_plasma(150))
		return
	last_defiler_sting = world.time
	use_plasma(150)

	round_statistics.defiler_defiler_stings++

	face_atom(H)
	animation_attack_on(H)
	H.reagents.add_reagent("xeno_toxin", DEFILER_STING_AMOUNT_INITIAL) //15 units transferred initially.
	H.reagents.add_reagent("xeno_growthtoxin", DEFILER_STING_AMOUNT_INITIAL) //15 units transferred initially.
	to_chat(H, "<span class='danger'>You feel a tiny prick.</span>")
	to_chat(src, "<span class='xenowarning'>Your stinger injects your victim with neurotoxin!</span>")
	playsound(H, 'sound/effects/spray3.ogg', 15, 1)
	playsound(H, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	if(do_after(src, DEFILER_STING_INJECT_DELAY, TRUE, 5, BUSY_ICON_HOSTILE)) //First follow up injection
		if(!defiler_recurring_injection(H))
			return
		to_chat(src, "<span class='xenowarning'>Your stinger continues to inject neurotoxin!</span>")
		if(do_after(src, DEFILER_STING_INJECT_DELAY, TRUE, 5, BUSY_ICON_HOSTILE)) //Second follow up injection
			if(!defiler_recurring_injection(H, TRUE)) //the last one infects and injects the larval growth toxin
				return
			to_chat(src, "<span class='xenowarning'>Your stinger retracts as it finishes discharging the neurotoxin.</span>")


	spawn(DEFILER_STING_COOLDOWN)
		playsound(loc, 'sound/voice/alien_drool1.ogg', 50, 1)
		to_chat(src, "<span class='xenodanger'>You feel your neurotoxin glands refill. You can use your neurotoxin sting again.</span>")
		update_action_button_icons()

/mob/living/carbon/Xenomorph/Defiler/proc/defiler_recurring_injection(var/mob/living/H, var/larva = FALSE)
	face_atom(H)
	animation_attack_on(H)
	playsound(H, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	H.reagents.add_reagent("xeno_toxin", DEFILER_STING_AMOUNT_RECURRING) //10 units transferred.
	H.reagents.add_reagent("xeno_growthtoxin", DEFILER_STING_AMOUNT_RECURRING)
	//It's infection time!
	if(!larva)
		return TRUE

	if(!CanHug(H))
		return TRUE

	var/embryos = 0
	for(var/obj/item/alien_embryo/embryo in H) // already got one, stops doubling up
		embryos++
	if(!embryos)
		var/obj/item/alien_embryo/embryo = new /obj/item/alien_embryo(H)
		embryo.hivenumber = hivenumber
		icon_state = "[initial(icon_state)]_impregnated"
	return TRUE

/mob/living/carbon/Xenomorph/Defiler/proc/neuro_claws()

	if (!check_state())
		return

	if(world.time < last_use_neuroclaws + DEFILER_CLAWS_COOLDOWN)
		return

	neuro_claws = !neuro_claws
	last_use_neuroclaws = world.time
	to_chat(src, "<span class='notice'>You [neuro_claws ? "extend" : "retract"] your claws' neuro spines.</span>")
	if(neuro_claws)
		playsound(src, 'sound/weapons/slash.ogg', 15, 1)
	else
		playsound(src, 'sound/weapons/slashmiss.ogg', 15, 1)


/mob/living/carbon/Xenomorph/Defiler/hitby(atom/movable/AM as mob|obj,var/speed = 5)
	if(ishuman(AM))
		return
	..()

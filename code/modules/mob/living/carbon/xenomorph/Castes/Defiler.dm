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

	// *** Defiler Abilities *** //

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
	health = 225
	maxHealth = 225
	plasma_stored = 400
	speed = -1
	pixel_x = -16
	old_x = -16
	wound_type = "runner" //used to match appropriate wound overlays
	tier = 3
	upgrade = 0
	var/datum/effect_system/smoke_spread/smoke_system = null
	var/last_defiler_sting = null
	var/last_emit_neurogas = null
	var/last_use_neuroclaws = null
	var/neuro_claws = FALSE
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/emit_neurogas,
		/datum/action/xeno_action/activable/defiler_sting,
		/datum/action/xeno_action/neuroclaws,
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

	if(world.time < last_emit_neurogas + DEFILER_GAS_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='xenodanger'>You are not ready to emit neurogas again. This ability will be ready in [(last_emit_neurogas + DEFILER_GAS_COOLDOWN - world.time) * 0.1] seconds.</span>")
		return FALSE

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
		return

	if(!check_plasma(200))
		return

	last_emit_neurogas = world.time
	use_plasma(200)

	//give them fair warning
	visible_message("<span class='danger'>Tufts of smoke begin to billow from [src]!</span>", \
	"<span class='xenodanger'>Your dorsal vents widen, and emit tufts of neurogas!</span>")

	spawn(DEFILER_GAS_COOLDOWN)
		playsound(loc, 'sound/effects/xeno_newlarva.ogg', 50, 1)
		to_chat(src, "<span class='xenodanger'>You feel your dorsal vents bristle with neurotoxic gas. You can use Emit Neurotoxin again.</span>")
		update_action_button_icons()

	if(!do_after(src, DEFILER_STING_INJECT_DELAY, TRUE, 5, BUSY_ICON_HOSTILE))
		return

	if(stagger) //If we got staggered, return
		to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
		return

	round_statistics.defiler_neurogas_uses++

	visible_message("<span class='xenodanger'>[src] emits a noxious gas!</span>", \
	"<span class='xenodanger'>You emit neurogas!</span>")
	dispense_gas()

/mob/living/carbon/Xenomorph/Defiler/proc/dispense_gas(var/count = 0)
	if(stagger) //If we got staggered, return
		to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
		return
	if(count > 4)
		return
	playsound(loc, 'sound/effects/smoke.ogg', 25)
	var/turf/T = get_turf(src)
	smoke_system = new /datum/effect_system/smoke_spread/xeno_weaken()
	smoke_system.amount = 1
	smoke_system.set_up(2, 0, T)
	smoke_system.start()
	T.visible_message("<span class='danger'>Noxious smoke billows from the hulking xenomorph!</span>")
	spawn(10)
		dispense_gas(count + 1)


/mob/living/carbon/Xenomorph/Defiler/proc/defiler_sting(var/mob/living/H)

	if(!check_state())
		return

	if(world.time < last_defiler_sting + DEFILER_STING_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='xenodanger'>You are not ready to Defile again. It will be ready in [(last_defiler_sting + DEFILER_STING_COOLDOWN - world.time) * 0.1] seconds.</span>")
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
	to_chat(src, "<span class='xenowarning'>Your stinger injects your victim with neurotoxin and larval growth serum!</span>")
	playsound(H, 'sound/effects/spray3.ogg', 15, 1)
	playsound(H, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)

	spawn(DEFILER_STING_COOLDOWN)
		playsound(loc, 'sound/voice/alien_drool1.ogg', 50, 1)
		to_chat(src, "<span class='xenodanger'>You feel your toxin glands refill, another young one ready for implantation. You can use Defile again.</span>")
		update_action_button_icons()

	defiler_recurring_injection(H)


/mob/living/carbon/Xenomorph/Defiler/proc/defiler_recurring_injection(var/mob/living/H, var/count = 1)
	if(count > 3)
		return FALSE
	if(!Adjacent(H) || stagger)
		return FALSE
	face_atom(H)
	if(!do_after(src, DEFILER_STING_INJECT_DELAY, TRUE, 5, BUSY_ICON_HOSTILE))
		return
	animation_attack_on(H)
	playsound(H, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	H.reagents.add_reagent("xeno_toxin", DEFILER_STING_AMOUNT_RECURRING) //10 units transferred.
	H.reagents.add_reagent("xeno_growthtoxin", DEFILER_STING_AMOUNT_RECURRING)

	if(count < 2)
		defiler_recurring_injection(H, count + 1)
		return

	//It's infection time!
	if(!CanHug(H))
		return

	var/embryos = 0
	for(var/obj/item/alien_embryo/embryo in H) // already got one, stops doubling up
		embryos++
	if(!embryos)
		var/obj/item/alien_embryo/embryo = new /obj/item/alien_embryo(H)
		embryo.hivenumber = hivenumber
		to_chat(src, "<span class='xenodanger'>Your stinger successfully implants a larva into the host.</span>")
	return


/mob/living/carbon/Xenomorph/Defiler/hitby(atom/movable/AM as mob|obj,var/speed = 5)
	if(ishuman(AM))
		return
	..()

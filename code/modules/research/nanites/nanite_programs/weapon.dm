//Programs specifically engineered to cause harm to either the user or its surroundings (as opposed to ones that only do it due to broken programming)
//Very dangerous!

/datum/nanite_program/flesh_eating
	name = "Cellular Breakdown"
	desc = ""
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/necrotic)

/datum/nanite_program/flesh_eating/active_effect()
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		C.take_bodypart_damage(1, 0, 0)
	else
		host_mob.adjustBruteLoss(1, TRUE)
	if(prob(3))
		to_chat(host_mob, "<span class='warning'>I feel a stab of pain from somewhere inside you.</span>")

/datum/nanite_program/poison
	name = "Poisoning"
	desc = ""
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/poison/active_effect()
	host_mob.adjustToxLoss(1)
	if(prob(2))
		to_chat(host_mob, "<span class='warning'>I feel nauseous.</span>")
		if(iscarbon(host_mob))
			var/mob/living/carbon/C = host_mob
			C.vomit(20)

/datum/nanite_program/memory_leak
	name = "Memory Leak"
	desc = ""
	use_rate = 0
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/memory_leak/active_effect()
	if(prob(6))
		var/datum/nanite_program/target = pick(nanites.programs)
		if(target == src)
			return
		target.software_error()

/datum/nanite_program/aggressive_replication
	name = "Aggressive Replication"
	desc = ""
	use_rate = 1
	rogue_types = list(/datum/nanite_program/necrotic)

/datum/nanite_program/aggressive_replication/active_effect()
	var/extra_regen = round(nanites.nanite_volume / 200, 0.1)
	nanites.adjust_nanites(null, extra_regen)
	host_mob.adjustBruteLoss(extra_regen / 2, TRUE)

/datum/nanite_program/meltdown
	name = "Meltdown"
	desc = "Causes an internal meltdown inside the nanites, causing internal burns inside the host as well as rapidly destroying the nanite population.\
			Sets the nanites' safety threshold to 0 when activated."
	use_rate = 10
	rogue_types = list(/datum/nanite_program/glitch)

/datum/nanite_program/meltdown/active_effect()
	host_mob.adjustFireLoss(3.5)

/datum/nanite_program/meltdown/enable_passive_effect()
	. = ..()
	to_chat(host_mob, "<span class='danger'>My blood is burning!</span>")
	nanites.safety_threshold = 0

/datum/nanite_program/meltdown/disable_passive_effect()
	. = ..()
	to_chat(host_mob, "<span class='warning'>My blood cools down, and the pain gradually fades.</span>")

/datum/nanite_program/triggered/explosive
	name = "Chain Detonation"
	desc = ""
	trigger_cost = 25 //plus every idle nanite left afterwards
	trigger_cooldown = 100 //Just to avoid double-triggering
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/triggered/explosive/trigger()
	if(!..())
		return
	host_mob.visible_message("<span class='warning'>[host_mob] starts emitting a high-pitched buzzing, and [host_mob.p_their()] skin begins to glow...</span>",\
							"<span class='danger'>I start emitting a high-pitched buzzing, and my skin begins to glow...</span>")
	addtimer(CALLBACK(src, PROC_REF(boom)), CLAMP((nanites.nanite_volume * 0.35), 25, 150))

/datum/nanite_program/triggered/explosive/proc/boom()
	var/nanite_amount = nanites.nanite_volume
	var/dev_range = FLOOR(nanite_amount/200, 1) - 1
	var/heavy_range = FLOOR(nanite_amount/100, 1) - 1
	var/light_range = FLOOR(nanite_amount/50, 1) - 1
	explosion(host_mob, dev_range, heavy_range, light_range)
	qdel(nanites)

//TODO make it defuse if triggered again

/datum/nanite_program/triggered/heart_stop
	name = "Heart-Stopper"
	desc = ""
	trigger_cost = 12
	trigger_cooldown = 10
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/triggered/heart_stop/trigger()
	if(!..())
		return
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		var/obj/item/organ/heart/heart = C.getorganslot(ORGAN_SLOT_HEART)
		if(heart)
			if(heart.beating)
				heart.Stop()
			else
				heart.Restart()

/datum/nanite_program/triggered/emp
	name = "Electromagnetic Resonance"
	desc = ""
	trigger_cost = 10
	program_flags = NANITE_EMP_IMMUNE
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/triggered/emp/trigger()
	if(!..())
		return
	empulse(host_mob, 1, 2)

/datum/nanite_program/pyro/active_effect()
	host_mob.fire_stacks += 1
	host_mob.IgniteMob()

/datum/nanite_program/pyro
	name = "Sub-Dermal Combustion"
	desc = ""
	use_rate = 4
	rogue_types = list(/datum/nanite_program/skin_decay, /datum/nanite_program/cryo)

/datum/nanite_program/pyro/check_conditions()
	if(host_mob.fire_stacks >= 10 && host_mob.on_fire)
		return FALSE
	return ..()

/datum/nanite_program/pyro/active_effect()
	host_mob.fire_stacks += 1
	host_mob.IgniteMob()

/datum/nanite_program/cryo
	name = "Cryogenic Treatment"
	desc = ""
	use_rate = 1
	rogue_types = list(/datum/nanite_program/skin_decay, /datum/nanite_program/pyro)

/datum/nanite_program/cryo/check_conditions()
	if(host_mob.bodytemperature <= 70)
		return FALSE
	return ..()

/datum/nanite_program/cryo/active_effect()
	host_mob.adjust_bodytemperature(-rand(15,25), 50)

/datum/nanite_program/triggered/comm/mind_control
	name = "Mind Control"
	desc = ""
	trigger_cost = 30
	trigger_cooldown = 1800
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)

	extra_settings = list(NES_DIRECTIVE,NES_COMM_CODE)
	var/directive = "..."

/datum/nanite_program/triggered/comm/mind_control/set_extra_setting(user, setting)
	if(setting == NES_DIRECTIVE)
		var/new_directive = stripped_input(user, "Choose the directive to imprint with mind control.", NES_DIRECTIVE, directive, MAX_MESSAGE_LEN)
		if(!new_directive)
			return
		directive = new_directive
	if(setting == NES_COMM_CODE)
		var/new_code = input(user, "Set the communication code (1-9999) or set to 0 to disable external signals.", name, null) as null|num
		if(isnull(new_code))
			return
		comm_code = CLAMP(round(new_code, 1), 0, 9999)

/datum/nanite_program/triggered/comm/mind_control/get_extra_setting(setting)
	if(setting == NES_DIRECTIVE)
		return directive
	if(setting == NES_COMM_CODE)
		return comm_code

/datum/nanite_program/triggered/comm/mind_control/copy_extra_settings_to(datum/nanite_program/triggered/comm/mind_control/target)
	target.directive = directive
	target.comm_code = comm_code

/datum/nanite_program/triggered/comm/mind_control/trigger(comm_message)
	if(!..())
		return
	if(host_mob.stat == DEAD)
		return
	var/sent_directive = comm_message
	if(!comm_message)
		sent_directive = directive
	brainwash(host_mob, sent_directive)
	log_game("A mind control nanite program brainwashed [key_name(host_mob)] with the objective '[directive]'.")
	addtimer(CALLBACK(src, PROC_REF(end_brainwashing)), 600)

/datum/nanite_program/triggered/comm/mind_control/proc/end_brainwashing()
	if(host_mob.mind && host_mob.mind.has_antag_datum(/datum/antagonist/brainwashed))
		host_mob.mind.remove_antag_datum(/datum/antagonist/brainwashed)
	log_game("[key_name(host_mob)] is no longer brainwashed by nanites.")

/datum/nanite_program/triggered/comm/mind_control/disable_passive_effect()
	. = ..()
	end_brainwashing()

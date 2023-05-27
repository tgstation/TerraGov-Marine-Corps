// ***************************************
// *********** Flay
// ***************************************
/datum/action/xeno_action/activable/flay
	name = "Flay"
	action_icon_state = "flay"
	desc = "Takes a chunk of flesh from the victim marine through a quick swiping motion, adding 100 biomass to your biomass collection."
	ability_name = "flay"
	plasma_cost = 0
	cooldown_timer = 20 SECONDS
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FLAY,
	)

/datum/action/xeno_action/activable/flay/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!ishuman(target))
		if(!silent)
			to_chat(owner, span_xenowarning("We cant find any suitable flesh on this thing!"))
		return FALSE

	var/mob/living/carbon/xenomorph/owner_xeno = owner
	var/mob/living/carbon/human/target_human = target
	if(!owner_xeno.Adjacent(target_human))
		if(!silent)
			to_chat(owner_xeno, span_xenonotice("We need to be next to our victim."))
		return FALSE

	if(target_human.stat == DEAD)
		to_chat(owner_xeno, span_xenonotice("Dead meat is bad meat!"))
		return FALSE

	if(!.)
		return

	if(owner_xeno.plasma_stored >= owner_xeno.xeno_caste.plasma_max)
		if(!silent)
			to_chat(owner_xeno, span_xenowarning("No need, no space for all this meat..."))
		return FALSE

/datum/action/xeno_action/activable/flay/use_ability(mob/living/carbon/human/target_human)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.face_atom(target_human)
	owner_xeno.do_attack_animation(target_human, ATTACK_EFFECT_REDSTAB)
	owner_xeno.visible_message(target_human, span_danger("[owner_xeno] flays and rips skin and flesh from [target_human]!"))
	playsound(target_human, "alien_claw_flesh", 25, TRUE)
	target_human.emote("scream")
	owner_xeno.emote("roar")
	target_human.apply_damage(damage = 45, damagetype = BRUTE, def_zone = BODY_ZONE_CHEST, blocked = 0, sharp = TRUE, edge = FALSE, updating_health = TRUE)
	target_human.apply_effects(stun = 0.2)

	owner_xeno.gain_plasma(owner_xeno.xeno_caste.flay_plasma_gain)
	
	add_cooldown()

// ***************************************
// *********** Pincushion
// ***************************************
/datum/action/xeno_action/activable/pincushion
	name = "Pincushion"
	action_icon_state = "pincushion"
	desc = "Launch a spine from your tail. This attack will help deter any organic as well as support your puppets and teammates in direct combat."
	cooldown_timer = 5 SECONDS
	//target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PINCUSHION,
	)

/datum/action/xeno_action/activable/pincushion/can_use_ability(atom/victim, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/xenomorph/X = owner
	if(X.do_actions) //can't use if busy
		return FALSE
	X.face_atom(victim)
	if(!do_after(X, 0.3 SECONDS, FALSE, victim, BUSY_ICON_DANGER, extra_checks = CALLBACK(X, TYPE_PROC_REF(/mob, break_do_after_checks), list("health" = X.health))))
		return FALSE
	succeed_activate()

/datum/action/xeno_action/activable/pincushion/use_ability(atom/victim)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/turf/current_turf = get_turf(owner)
	playsound(xeno.loc, 'sound/bullets/spear_armor1.ogg', 25, 1)
	xeno.visible_message(span_warning("[xeno] shoots a spike!"), span_xenonotice("We discharge a spinal spike from our body."))

	var/obj/projectile/spine = new /obj/projectile(current_turf)
	spine.generate_bullet(/datum/ammo/xeno/spine)
	spine.def_zone = xeno.get_limbzone_target()
	spine.fire_at(victim, xeno, null, range = 6, speed = 1)

	add_cooldown()
// ***************************************
// *********** Dreadful Presence
// ***************************************
/datum/action/xeno_action/dreadful_presence
	name = "Dreadful Presence"
	action_icon_state = "dreadful_presence"
	desc = "Emit a menacing presence, striking fear into the organics and slowing them for a short duration."
	plasma_cost = 50
	cooldown_timer = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DREADFULPRESENCE,
	)

/datum/action/xeno_action/dreadful_presence/action_activate()
	var/obj/effect/overlay/dread/effect = new
	owner.vis_contents += effect
	for(var/mob/living/carbon/human/human in view(PETRIFY_RANGE, owner.loc))
		to_chat(human, span_userdanger("oh god what the fuck oh god oh god"))
		addtimer(CALLBACK(human, TYPE_PROC_REF(/mob/living/carbon/human, emote), "scream"), rand(0.55, 0.7))
		human.apply_status_effect(/datum/status_effect/dread, 6 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(clear_effect), effect), 3 SECONDS)
	add_cooldown()
	succeed_activate()

/datum/action/xeno_action/dreadful_presence/proc/clear_effect(atom/effect)
	owner.vis_contents -= effect
	qdel(effect)

// ***************************************
// *********** Refurbish Husk
// ***************************************
/datum/action/xeno_action/activable/refurbish_husk
	name = "Refurbish Husk"
	action_icon_state = "refurbish_husk"
	desc = "Harvest the biomass and organs of a body in order to create a meat puppet to do your bidding."
	cooldown_timer = 25 SECONDS
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_REFURBISHHUSK,
	)
	/// List of all our puppets
	var/list/mob/living/carbon/xenomorph/puppet/puppets = list()

/datum/action/xeno_action/activable/refurbish_husk/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	var/mob/living/carbon/human/target_human = target
	if(!ishuman(target))
		if(!silent)
			to_chat(owner, span_xenowarning("We dont know this things biology!"))
		return FALSE
	if(length(puppets) >= owner_xeno.xeno_caste.max_puppets)
		owner_xeno.balloon_alert(owner_xeno, "cant have more than [owner_xeno.xeno_caste.max_puppets]!")
		return FALSE
	if(HAS_TRAIT(target, TRAIT_PSY_DRAINED))
		if(!silent)
			to_chat(owner, span_xenonotice("This one has is drained of all psychic energy, of no use to us."))
		return FALSE

	if(!owner_xeno.Adjacent(target_human))
		if(!silent)
			to_chat(owner_xeno, span_xenonotice("We need to be next to our victim."))
		return FALSE

#ifndef TESTING
	if(!HAS_TRAIT(target_human, TRAIT_UNDEFIBBABLE) || target_human.stat != DEAD)
		to_chat(owner_xeno, span_xenonotice("The body is not yet ready for stitching!"))
		return FALSE
#endif

	if(!.)
		return
	owner_xeno.face_atom(target_human)
	owner_xeno.visible_message(target_human, span_danger("[owner_xeno] begins carving out, doing all sorts of horrible things to [target_human]!"))
	if(!do_after(owner_xeno, 8 SECONDS, FALSE, target_human, BUSY_ICON_DANGER, extra_checks = CALLBACK(owner_xeno, TYPE_PROC_REF(/mob, break_do_after_checks), list("health" = owner_xeno.health))))
		return FALSE
	succeed_activate()

/datum/action/xeno_action/activable/refurbish_husk/use_ability(mob/living/victim)
	var/turf/victim_turf = get_turf(victim)

	victim.unequip_everything()
	victim.gib()
	add_puppet(new /mob/living/carbon/xenomorph/puppet(victim_turf, owner))
	add_cooldown()

/// Adds a puppet to our list, this is basically just widow code
/datum/action/xeno_action/activable/refurbish_husk/proc/add_puppet(mob/living/carbon/xenomorph/puppet/new_puppet)
	RegisterSignal(new_puppet, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(remove_puppet))
	RegisterSignal(new_puppet, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(postattack)) //harvesting claws
	puppets += new_puppet

/// Cleans up puppet from our list
/datum/action/xeno_action/activable/refurbish_husk/proc/remove_puppet(datum/source)
	SIGNAL_HANDLER
	puppets -= source
	UnregisterSignal(source, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING, COMSIG_XENOMORPH_POSTATTACK_LIVING))

/datum/action/xeno_action/activable/refurbish_husk/proc/postattack(mob/living/source, useless, damage)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.plasma_stored = min(owner_xeno.plasma_stored + round(damage / 0.9), owner_xeno.xeno_caste.plasma_max)

// ***************************************
// *********** Stitch Puppet
// ***************************************
/datum/action/xeno_action/activable/puppet
	name = "Stitch Puppet"
	action_icon_state = "stitch_puppet"
	desc = "Uses 350 biomass to create a flesh homunculus to do your bidding, at an adjacent target location."
	plasma_cost = 350
	cooldown_timer = 25 SECONDS
	target_flags = XABB_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PUPPET,
	)

/datum/action/xeno_action/activable/puppet/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(isclosedturf(target))
		if(!silent)
			target.balloon_alert(owner_xeno, "THATS A FUCKING WALL")
		return FALSE

	var/datum/action/xeno_action/activable/refurbish_husk/huskaction = owner.actions_by_path[/datum/action/xeno_action/activable/refurbish_husk]
	if(length(huskaction.puppets) >= owner_xeno.xeno_caste.max_puppets)
		owner_xeno.balloon_alert(owner_xeno, "cant have more than [owner_xeno.xeno_caste.max_puppets]!")
		return FALSE

	if(!owner_xeno.Adjacent(target))
		if(!silent)
			to_chat(owner_xeno, span_xenonotice("We need to be next to where we want to create a puppet."))
		return FALSE

	if(!.)
		return
	owner_xeno.face_atom(target)
	//reverse gib here
	owner_xeno.visible_message(span_warning("[owner_xeno] begins to vomit out biomass and skillfully sews various bits and pieces together!"))
	if(!do_after(owner_xeno, 8 SECONDS, FALSE, target, BUSY_ICON_CLOCK, extra_checks = CALLBACK(owner_xeno, TYPE_PROC_REF(/mob, break_do_after_checks), list("health" = owner_xeno.health))))
		//cancel effects
		return FALSE
	//cancel effects
	owner_xeno.visible_message(span_warning("[owner_xeno] forms a repulsive puppet!"))
	succeed_activate()

/datum/action/xeno_action/activable/puppet/use_ability(atom/target)
	var/turf/target_turf = get_turf(target)

	var/datum/action/xeno_action/activable/refurbish_husk/huskaction = owner.actions_by_path[/datum/action/xeno_action/activable/refurbish_husk]
	huskaction.add_puppet(new /mob/living/carbon/xenomorph/puppet(target_turf, owner))
	add_cooldown()

// ***************************************
// *********** Organic Bomb
// ***************************************
/datum/action/xeno_action/activable/organic_bomb
	name = "Organic Bomb"
	action_icon_state = "organic_bomb"
	desc = "Causes one of our puppets to detonate on selection, spewing acid out of the puppet's body in all directions, gibbing the puppet."
	cooldown_timer = 30 SECONDS
	plasma_cost = 100
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ORGANICBOMB,
	)

/datum/action/xeno_action/activable/organic_bomb/use_ability(mob/living/victim)
	. = ..()
	var/datum/action/xeno_action/activable/refurbish_husk/huskaction = owner.actions_by_path[/datum/action/xeno_action/activable/refurbish_husk]
	if(length(huskaction.puppets) <= 0)
		owner.balloon_alert(owner, "no puppets")
		return fail_activate()
	if(!istype(victim, /mob/living/carbon/xenomorph/puppet) || !(victim in huskaction.puppets))
		victim.balloon_alert(owner, "not our puppet")
		return fail_activate()
	if(!SEND_SIGNAL(victim, COMSIG_PUPPET_CHANGE_ORDER, PUPPET_SEEK_CLOSEST))
		victim.balloon_alert(owner, "fail")
		return fail_activate()
	victim.balloon_alert(owner, "success")
	RegisterSignal(victim, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(start_exploding))
	RegisterSignal(victim, COMSIG_MOB_DEATH, PROC_REF(fucking_explode))
	addtimer(CALLBACK(src, PROC_REF(fucking_explode), victim), 15 SECONDS)
	add_cooldown()

/datum/action/xeno_action/activable/organic_bomb/proc/start_exploding(mob/living/puppet)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(start_exploding_async), puppet)

/datum/action/xeno_action/activable/organic_bomb/proc/start_exploding_async(mob/living/puppet)
	puppet.visible_message(span_danger("[puppet] bloats and slowly unfurls its stitched body!"))
	if(do_after(puppet, 1.5 SECONDS, FALSE, puppet, BUSY_ICON_DANGER))
		fucking_explode(puppet)

/datum/action/xeno_action/activable/organic_bomb/proc/fucking_explode(mob/living/puppet)
	SIGNAL_HANDLER
	UnregisterSignal(puppet, list(COMSIG_XENOMORPH_ATTACK_LIVING, COMSIG_MOB_DEATH))
	if(QDELETED(puppet))
		return
	puppet.visible_message(span_danger("[puppet] ruptures, releasing corrosive acid!"))
	var/turf/our_turf = get_turf(puppet)
	playsound(our_turf, 'sound/bullets/acid_impact1.ogg', 50, 1)
	puppet.gib()
	
	for(var/turf/acid_tile AS in RANGE_TURFS(1, our_turf))
		new /obj/effect/temp_visual/acid_splatter(acid_tile) //SFX
		if(!locate(/obj/effect/xenomorph/spray) in acid_tile.contents)
			new /obj/effect/xenomorph/spray(acid_tile, 10 SECONDS, 16)
// ***************************************
// *********** Articulate
// ***************************************
/datum/action/xeno_action/activable/articulate
	name = "Articulate"
	action_icon_state = "mimicry"
	desc = "Takes direct control of a Puppet’s vocal chords. Allows you to speak directly through your puppet to the talls."
	cooldown_timer = 10 SECONDS

// ***************************************
// *********** Strings Attached
// ***************************************
/datum/action/xeno_action/activable/strings_attached
	name = "Strings Attached"
	action_icon_state = "strings_attached"
	desc = "Take control of an organic's mind, forcing them to move in the direction of your choosing."
	plasma_cost = 250
	cooldown_timer = 60 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_STRINGSATTACHED,
	)

// ***************************************
// *********** Blessings todo
// ***************************************
/datum/action/xeno_action/blessing
/datum/action/xeno_action/blessing/frenzy
/datum/action/xeno_action/blessing/ward
/datum/action/xeno_action/blessing/fury

// ***************************************
// *********** Orders
// ***************************************

/datum/action/xeno_action/puppeteer_orders
	name = "Give Orders to Puppets"
	action_icon_state = "1"
	desc = "Emit a menacing presence, striking fear into the organics and slowing them for a short duration."
	//keybinding_signals = list(
	//	KEYBINDING_NORMAL = COMSIG_XENOABILITY_DREADFULPRESENCE,
	//)

/datum/action/xeno_action/puppeteer_orders/action_activate(mob/living/victim)
	var/choice = show_radial_menu(owner, owner, GLOB.puppeteer_order_images_list, radius = 35)
	if(!choice)
		return
	if(SEND_SIGNAL(owner, COMSIG_PUPPET_CHANGE_ALL_ORDER, choice))
		owner.balloon_alert(owner, "success")
		switch(choice) //visible message stuff
			if(PUPPET_ATTACK)
				owner.visible_message(span_warning("[owner] swiftly manipulates the psychic strings of the puppets, ordering them to attack!"))
			if(PUPPET_RECALL)
				owner.visible_message(span_warning("[owner] quickly manipulates the psychic strings of the puppets, drawing them near!"))
	else
		owner.balloon_alert(owner, "fail")

/datum/action/ability/activate_magic
	name = "Activate Magic"
	desc = "Activate your magical abilities."
	action_icon = 'icons/obj/wizard.dmi'
	action_icon_state = "scroll"

/datum/action/ability/activate_magic/action_activate()
	. = ..()
	//Should at least be a living
	if(!isliving(owner))
		to_chat(owner, span_warning("You can't use magic!"))
		return

	var/mob/living/wizard = owner
	for(var/datum/action/ability/ability AS in subtypesof(/datum/action/ability/activable/wizard))
		ability = new ability()
		ability.give_action(wizard)

	to_chat(wizard, span_notice("The magic flows through you!"))
	remove_action(wizard)

/datum/action/ability/activable/wizard
	name = "generic spell"
	desc = "A code wizard has made a grave error."
	cooldown_duration = 1 SECONDS
	///Sound played on casting
	var/sound_effect

/datum/action/ability/activable/wizard/use_ability(atom/A)
	. = ..()
	//Anime rules: always say the ability name!
	owner.say("[name]!")

	if(sound_effect)
		playsound(get_turf(owner), sound_effect, 100, FALSE, 7)

	add_cooldown()

/datum/action/ability/activable/wizard/fireball
	name = "Fireball"
	desc = "Cast a fireball."
	action_icon_state = "neuro_glob"
	cooldown_duration = 1 SECONDS
	sound_effect = 'sound/weapons/guns/fire/volkite_3.ogg'

/datum/action/ability/activable/wizard/fireball/use_ability(atom/A)
	. = ..()
	var/turf/target = get_turf(A)
	if(!target)
		return

	var/obj/projectile/fireball = new /obj/projectile(get_turf(owner))
	fireball.generate_bullet(/datum/ammo/fireball)
	fireball.fire_at(target, owner, owner, fireball.ammo.max_range, fireball.ammo.shell_speed)

/datum/action/ability/activable/wizard/lightning
	name = "Smite"
	desc = "Cast a lightning bolt."
	action_icon_state = "psy_blast"
	cooldown_duration = 0.3 SECONDS
	sound_effect = 'sound/magic/lightningbolt.ogg'
	///Damage each lightning bolt does
	var/damage = 30

/datum/action/ability/activable/wizard/lightning/use_ability(atom/A)
	. = ..()
	var/turf/turf = get_turf(A)
	if(!turf)
		return

	//Just aim at the floor by default
	var/target = turf
	if(isliving(A))
		if(ishuman(A))
			var/mob/living/carbon/human/human_victim = A
			//Will shock a random body part on humans
			human_victim.apply_damage(damage, BURN, pick(GLOB.human_body_parts), ENERGY)
			target = human_victim
		else
			var/mob/living/living_victim = A
			living_victim.apply_damage(damage, BURN, blocked = ENERGY)
			target = living_victim

	else if(isobj(A))
		var/obj/lightning_rod = A
		if(CHECK_BITFIELD(lightning_rod.flags_atom, CONDUCT))
			lightning_rod.take_damage(damage, BURN, ENERGY)
		target = lightning_rod

	owner.beam(target, "lightning[rand(1,12)]", time = 0.25 SECONDS)

/datum/action/ability/activable/wizard/explosion
	name = "Explosion"
	desc = "Cast an explosion."
	action_icon_state = "bombard"
	cooldown_duration = 5 SECONDS
	sound_effect = 'sound/magic/invoke_general.ogg'

/datum/action/ability/activable/wizard/explosion/use_ability(atom/A)
	. = ..()
	var/turf/target = get_turf(A)
	if(!target)
		return

	var/obj/effect/temp_visual/explosion_rune/effect = new(target)
	effect.SpinAnimation()
	addtimer(CALLBACK(src, PROC_REF(do_explosion), target), 2 SECONDS)

/datum/action/ability/activable/wizard/explosion/proc/do_explosion(turf/target)
	explosion(target, 0, 2, 4)

/obj/effect/temp_visual/explosion_rune
	icon = 'icons/obj/rune.dmi'
	icon_state = "rune1"
	duration = 2 SECONDS

/datum/action/ability/activable/wizard/summon_gun
	name = "Sacred Art: Gun"
	desc = "Summon a gun."
	action_icon = 'icons/obj/items/guns/pistols.dmi'
	action_icon_state = "g_deagle"
	cooldown_duration = 10 SECONDS
	sound_effect = 'sound/effects/pred_cloakon.ogg'

/datum/action/ability/activable/wizard/summon_gun/use_ability(atom/A)
	. = ..()
	var/obj/item/weapon/gun/gun = pick(subtypesof(/obj/item/weapon/gun))
	if(!gun)	//Just in case
		return

	gun = new gun(owner)

	//Owner should always be a living
	var/mob/living/wizard = owner
	//Delete the item if it can't be put in any hand; would use the parameter del_on_fail but it deletes the gun on the first hand it fails to put in
	if(!wizard.put_in_any_hand_if_possible(gun))
		wizard.balloon_alert(wizard, "No free hands!")
		qdel(gun)
		clear_cooldown()
		return

	ENABLE_BITFIELD(gun.flags_item, DELONDROP)
	//So you can't attach anything to these magic guns
	gun.attachable_allowed = null
	gun.name = gun.name + " (Summoned)"

//Wizard clothing, not sure where appropriate to put them as it's best to keep together
/obj/item/clothing/suit/wizard_robe
	name = "wizard robe"
	desc = "A robe for wizards."
	icon_state = "wizard"

/obj/item/clothing/head/wizard_hat
	name = "wizard hat"
	desc = "A hat for wizards."
	icon_state = "wizard"

/obj/item/clothing/shoes/wizard_shoes
	name = "wizard shoes"
	desc = "Shoes for wizards."
	icon_state = "wizard"

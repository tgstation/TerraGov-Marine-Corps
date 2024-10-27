/mob/living/carbon/xenomorph/runner
	caste_base_type = /datum/xeno_caste/runner
	name = "Runner"
	desc = "A small red alien that looks like it could run fairly quickly..."
	icon = 'icons/Xeno/castes/runner.dmi' //They are now like, 2x1 or something
	icon_state = "Runner Walking"
	bubble_icon = "alienleft"
	health = 100
	maxHealth = 100
	plasma_stored = 50
	pass_flags = PASS_LOW_STRUCTURE
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_NORMAL
	pixel_x = -16  //Needed for 2x2
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

/mob/living/carbon/xenomorph/runner/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_LIGHT_STEP, XENO_TRAIT)

/mob/living/carbon/xenomorph/runner/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER

/mob/living/carbon/xenomorph/runner/UnarmedAttack(atom/A, has_proximity, modifiers)
	/// Runner should not be able to slash while evading.
	var/datum/action/ability/xeno_action/evasion/evasion_action = actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(evasion_action.evade_active)
		balloon_alert(src, "Cannot slash while evading")
		return
	return ..()

/mob/living/carbon/xenomorph/runner/med_hud_set_status()
	. = ..()
	hud_set_evasion()

/mob/living/carbon/xenomorph/runner/proc/hud_set_evasion(duration)
	var/image/holder = hud_list[XENO_EVASION_HUD]
	if(!holder)
		return
	holder.overlays.Cut()
	holder.icon_state = ""
	if(stat == DEAD || !duration)
		return
	holder.icon = 'icons/mob/hud/xeno.dmi'
	holder.icon_state = "evasion_duration[duration]"
	holder.pixel_x = 24
	holder.pixel_y = 24
	hud_list[XENO_EVASION_HUD] = holder

/mob/living/carbon/xenomorph/runner/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!ishuman(over))
		return
	if(!back)
		balloon_alert(over,"This runner isn't wearing a saddle!")
		return
	if(!do_after(over, 3 SECONDS, NONE, src))
		return
	var/obj/item/storage/backpack/marine/duffelbag/xenosaddle/saddle = back
	dropItemToGround(saddle,TRUE)

/mob/living/carbon/xenomorph/runner/can_mount(mob/living/user, target_mounting = FALSE)
	. = ..()
	if(!target_mounting)
		user = pulling
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_pulled = user
	if(human_pulled.stat == DEAD)
		return FALSE
	if(!istype(back, /obj/item/storage/backpack/marine/duffelbag/xenosaddle)) //cant ride without a saddle
		return FALSE
	return TRUE

/mob/living/carbon/xenomorph/runner/resisted_against(datum/source)
	user_unbuckle_mob(source, source)

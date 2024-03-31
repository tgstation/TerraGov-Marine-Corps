
/datum/antagonist/villain
	name = "Maniac"
	roundend_category = "villains"
	antagpanel_category = "Villain"
	job_rank = ROLE_VILLAIN
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "villain"
	var/special_role = ROLE_VILLAIN
	confess_lines = list("I gave the lady no time to squeal.", "I am down on whores.", "I shant quit ripping them.")

/datum/antagonist/villain/on_gain()
	owner.special_role = "Maniac"
	var/yea = pick(/obj/item/rogueweapon/huntingknife)
	owner.special_items["Jack"] = yea
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		H.change_stat("speed", 2)
		H.change_stat("intelligence", 2)
		H.change_stat("endurance", 1)
		H.change_stat("constitution", 1)
		H.cmode_music = 'sound/music/combat_weird.ogg'
		owner.adjust_skillrank(/datum/skill/combat/knives, 6, TRUE)
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
		ADD_TRAIT(H, RTRAIT_NOSTINK, TRAIT_GENERIC)
		ADD_TRAIT(H, RTRAIT_HATEWOMEN, TRAIT_GENERIC)
	forge_villain_objectives()
	finalize_villain()
	return ..()

/datum/antagonist/villain/on_removal()
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='danger'>I am no longer a [special_role]!</span>")
	owner.special_role = null
	return ..()

/datum/antagonist/villain/on_life(mob/user)
	if(!user)
		return
	var/mob/living/carbon/human/H = user
	H.verbs |= /mob/living/carbon/human/proc/maniac_mark

/datum/antagonist/villain/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/villain/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/villain/proc/forge_villain_objectives()
	forge_single_human_objective()

	if(!(locate(/datum/objective/escape) in objectives))
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		return

/datum/antagonist/villain/proc/forge_single_human_objective() //Returns how many objectives are added
	.=1
	var/datum/objective/rt_maniac/kill_objective = new
	add_objective(kill_objective)

/datum/antagonist/villain/greet()
	to_chat(owner.current, "<span class='userdanger'>The worms call me the Maniac. I love my work and want to start again.</span>")
	owner.announce_objectives()
	..()

/datum/antagonist/villain/proc/finalize_villain()
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/traitor.ogg', 80, FALSE, pressure_affected = FALSE)

//TODO Collate
/datum/antagonist/roundend_report()
	var/traitorwin = TRUE

	printplayer(owner)

	var/count = 0
	if(objectives.len)//If the traitor had no objectives, don't need to process this.
		for(var/datum/objective/objective in objectives)
			objective.update_explanation_text()
			if(objective.check_completion())
				to_chat(world, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='greentext'>TRIUMPH!</span>")
			else
				to_chat(world, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='redtext'>Failure.</span>")
				traitorwin = FALSE
			count += objective.triumph_count

	var/special_role_text = lowertext(name)

	if(!considered_alive(owner))
		traitorwin = FALSE

	if(traitorwin)
		if(count)
			if(owner)
				owner.adjust_triumphs(count)
		to_chat(world, "<span class='greentext'>The [special_role_text] has TRIUMPHED!</span>")
		if(owner?.current)
			owner.current.playsound_local(get_turf(owner.current), 'sound/misc/triumph.ogg', 100, FALSE, pressure_affected = FALSE)
	else
		to_chat(world, "<span class='redtext'>The [special_role_text] has FAILED!</span>")
		if(owner?.current)
			owner.current.playsound_local(get_turf(owner.current), 'sound/misc/fail.ogg', 100, FALSE, pressure_affected = FALSE)

//this datum is tied to items, when they are examined it gives bad mood and gives the maniac a point and a message
/datum/examine_effect/maniac
	var/datum/objective/rt_maniac/the_objective

/datum/examine_effect/maniac/trigger(mob/user)
	if(!the_objective)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.mind == the_objective.owner)
		return
	var/oldnum = the_objective.people_seen.len
	the_objective.people_seen |= H.real_name
	if(the_objective.people_seen.len > oldnum)
		if(the_objective.owner)
			H.freak_out()
			H.add_stress(/datum/stressevent/maniac)
			user.playsound_local(get_turf(user), 'sound/music/maniac.ogg', 80, FALSE, pressure_affected = FALSE)
			to_chat(user, "<span class='userdanger'>It's the work of the MANIAC!</span>")
			to_chat(the_objective.owner, "<span class='info'>[the_objective.people_seen.len]/5 have witnessed my work.</span>")

/mob/living/carbon/human/proc/maniac_mark()
	set name = "Mark the Flesh"
	set category = "MANIAC"
	if(!stat)
		var/obj/item/bodypart/I = get_active_held_item()
		var/obj/item/W = get_inactive_held_item()
		if(!istype(I))
			to_chat(src, "<span class='warning'>This isn't a trophy.</span>")
			return
		if(I.body_gender != "female")
			to_chat(src, "<span class='warning'>This isn't a trophy.</span>")
			return
		if(I.skeletonized)
			to_chat(src, "<span class='warning'>It's not wet enough for marking.</span>")
			return
		if(!W || (W.wlength != WLENGTH_SHORT))
			to_chat(src, "<span class='warning'>I need the right tool in my offhand.</span>")
			return
		if(!W.max_blade_int)
			to_chat(src, "<span class='warning'>I need the right tool in my offhand.</span>")
			return
		for(var/datum/examine_effect/maniac/M in I.examine_effects)
			to_chat(src, "<span class='warning'>It's already marked.</span>")
			return
		var/datum/examine_effect/maniac/EE = new()
		for(var/datum/objective/rt_maniac/R in mind.get_all_objectives())
			EE.the_objective = R
			break
		if(EE && EE.the_objective)
			playsound(src, 'sound/foley/pierce.ogg', 100, FALSE)
			var/turf/T = get_turf(src)
			src.visible_message("<span class='warning'>[src] starts carving something wicked into [I] with [W]...</span>")
			if(do_after(src, 20, target = I))
				I.examine_effects += EE
				I.proximity_monitor = new(I, 0)
				if(T)
					var/obj/effect/decal/cleanable/blood/B = locate() in T
					if(!B)
						B = new /obj/effect/decal/cleanable/blood/splatter(T)
				to_chat(src, "<span class='danger'>The flesh is marked.</span>")
				scom_announce("T̵̖̤̎́Ḩ̵̢̛̺̦͖̈́̎̂̄͝Ẻ̵̡̼͇͈̱͒̿͂̕ͅ ̶͓̝͕͑̿F̴͎̉͊͂͋L̸̹̼̰̪̼̆̇͋̅̆E̷̖̹̗̱͑̕̚S̴̡̹̱̏͂͝H̷͍̙͒̍̒͊͝ ̴̛̭̗͇͂͗̂͋̃I̸̖̜͆̎̏͘ͅŚ̶͙͎̻̘͝͠ ̸͍͈̑̄͘̕̚͝M̴̦̮͍͊͗͐̓A̷̝̮̖͛̌͝R̶̠̙̼̿͒̑̿͌K̴̡̭͚̭͆͒̓̏̄̀Ĕ̷͍͍͇Ḑ̵̰̤̜̽̔͑̐̊̇͜")

	proximity_monitor = new(src, 0)

/obj/item/bodypart/HasProximity(atom/movable/AM)
	if(istype(AM, /mob/living/carbon))
		for(var/datum/examine_effect/maniac/E in examine_effects)
			var/mob/living/carbon/M = AM
			E.trigger(M)
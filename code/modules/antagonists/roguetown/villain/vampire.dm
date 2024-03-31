#ifdef TESTSERVER
/mob/living/carbon/human/verb/become_vampire()
	set category = "DEBUGTEST"
	set name = "VAMPIRETEST"
	if(mind)
		var/datum/antagonist/vampire/new_antag = new /datum/antagonist/vampire()
		mind.add_antag_datum(new_antag)
#endif

/datum/antagonist/vampire
	name = "Vampire"
	roundend_category = "Vampires"
	antagpanel_category = "Vampire"
	job_rank = ROLE_VAMPIRE
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "vampire"
	confess_lines = list("I WANT YOUR BLOOD!", "DRINK THE BLOOD!", "CHILD OF KAIN!")
	var/disguised = TRUE
	var/vitae = 1000
	var/last_transform
	var/is_lesser = FALSE
	var/cache_skin
	var/cache_eyes
	var/cache_hair
	var/obj/effect/proc_holder/spell/targeted/shapeshift/bat/batform //attached to the datum itself to avoid cloning memes, and other duplicates

/datum/antagonist/vampire/examine_friendorfoe(datum/antagonist/examined_datum,mob/examiner,mob/examined)
	if(istype(examined_datum, /datum/antagonist/vampire/lesser))
		return "<span class='boldnotice'>A child of Kain.</span>"
	if(istype(examined_datum, /datum/antagonist/vampire))
		return "<span class='boldnotice'>An elder Kin.</span>"
	if(examiner.Adjacent(examined))
		if(istype(examined_datum, /datum/antagonist/werewolf/lesser))
			if(!disguised)
				return "<span class='boldwarning'>I sense a lesser Werewolf.</span>"
		if(istype(examined_datum, /datum/antagonist/werewolf))
			if(!disguised)
				return "<span class='boldwarning'>THIS IS AN ELDER WEREWOLF! MY ENEMY!</span>"
	if(istype(examined_datum, /datum/antagonist/zombie))
		return "<span class='boldnotice'>Another deadite.</span>"
	if(istype(examined_datum, /datum/antagonist/skeleton))
		return "<span class='boldnotice'>Another deadite.</span>"

/datum/antagonist/vampire/lesser //le shitcode faec
	name = "Lesser Vampire"
	is_lesser = TRUE
	increase_votepwr = FALSE

/datum/antagonist/vampire/lesser/roundend_report()
	return

/datum/antagonist/vampire/on_gain()
	if(!is_lesser)
		owner.adjust_skillrank(/datum/skill/combat/wrestling, 6, TRUE)
		owner.adjust_skillrank(/datum/skill/combat/unarmed, 6, TRUE)
		ADD_TRAIT(owner.current, RTRAIT_NOBLE, TRAIT_GENERIC)
	owner.special_role = name
	ADD_TRAIT(owner.current, RTRAIT_STRONGBITE, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOFATSTAM, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOPAIN, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_LIMPDICK, TRAIT_GENERIC)
	owner.current.cmode_music = 'sound/music/combatvamp.ogg'
	var/obj/item/organ/eyes/eyes = owner.current.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.Remove(owner.current,1)
		QDEL_NULL(eyes)
	eyes = new /obj/item/organ/eyes/night_vision/zombie
	eyes.Insert(owner.current)
	if(increase_votepwr)
		forge_vampire_objectives()
	finalize_vampire()
//	if(!is_lesser)
//		if(isnull(batform))
//			batform = new
//			owner.current.AddSpell(batform)
	owner.current.verbs |= /mob/living/carbon/human/proc/disguise_button
	owner.current.verbs |= /mob/living/carbon/human/proc/vamp_regenerate
	if(!is_lesser)
		owner.current.verbs |= /mob/living/carbon/human/proc/blood_strength
		owner.current.verbs |= /mob/living/carbon/human/proc/blood_celerity
		owner.current.verbs |= /mob/living/carbon/human/proc/blood_fortitude

	return ..()

/datum/antagonist/vampire/on_removal()
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='danger'>I am no longer a [job_rank]!</span>")
	owner.special_role = null
	if(!isnull(batform))
		owner.current.RemoveSpell(batform)
		QDEL_NULL(batform)
	return ..()

/datum/antagonist/vampire/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/vampire/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/vampire/proc/forge_vampire_objectives()
	if(!(locate(/datum/objective/escape) in objectives))
		var/datum/objective/vampire/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		return

/datum/antagonist/vampire/greet()
	to_chat(owner.current, "<span class='userdanger'>Ever since that bite, I have been a VAMPIRE.</span>")
	owner.announce_objectives()
	..()

/datum/antagonist/vampire/proc/finalize_vampire()
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/vampintro.ogg', 80, FALSE, pressure_affected = FALSE)
	..()


/datum/antagonist/vampire/on_life(mob/user)
	if(!user)
		return
	var/mob/living/carbon/human/H = user
	if(H.stat == DEAD)
		return
	if(H.advsetup)
		return

	if(world.time % 5)
		if(GLOB.tod != "night")
			if(isturf(H.loc))
				var/turf/T = H.loc
				if(T.can_see_sky())
					if(T.get_lumcount() > 0.15)
						if(disguised)
							vitae -= 8
							to_chat(H, "<span class='warning'>My silver blood dwindles!</span>")
						else
							H.fire_act(1,5)

	if(H.on_fire)
		if(disguised)
			last_transform = world.time
			H.vampire_undisguise(src)
		H.freak_out()

	if(H.stat)
		if(istype(H.loc, /obj/structure/closet/crate/coffin))
			H.fully_heal()

	vitae = CLAMP(vitae, 0, 1666)

	if(vitae > 0)
		H.blood_volume = BLOOD_VOLUME_MAXIMUM
		if(vitae < 200)
			if(disguised)
				to_chat(H, "<span class='warning'>My disguise fails!</span>")
				H.vampire_undisguise(src)
		vitae -= 1
	else
		to_chat(H, "<span class='userdanger'>I RAN OUT OF SILVER BLOOD!</span>")
		var/obj/shapeshift_holder/SS = locate() in H
		if(SS)
			SS.shape.dust()
		H.dust()
		return


/mob/living/carbon/human/proc/disguise_button()
	set name = "Disguise"
	set category = "VAMPIRE"

	var/datum/antagonist/vampirelord/VD = mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(!VD)
		return
	if(world.time < VD.last_transform + 30 SECONDS)
		var/timet2 = (VD.last_transform + 30 SECONDS) - world.time
		to_chat(src, "<span class='warning'>No.. not yet. [round(timet2/10)]s</span>")
		return
	if(VD.disguised)
		VD.last_transform = world.time
		vampire_undisguise(VD)
	else
		if(VD.vitae < 100)
			to_chat(src, "<span class='warning'>I don't have enough Vitae!</span>")
			return
		VD.last_transform = world.time
		vampire_disguise(VD)

/mob/living/carbon/human/proc/vampire_disguise(var/datum/antagonist/vampirelord/VD)
	if(!VD)
		return
	VD.disguised = TRUE
	skin_tone = VD.cache_skin
	hair_color = VD.cache_hair
	eye_color = VD.cache_eyes
	facial_hair_color = VD.cache_hair
	mob_biotypes = MOB_ORGANIC
	update_body()
	update_hair()
	update_body_parts(redraw = TRUE)

/mob/living/carbon/human/proc/vampire_undisguise(var/datum/antagonist/vampirelord/VD)
	if(!VD)
		return
	VD.disguised = FALSE
//	VD.cache_skin = skin_tone
//	VD.cache_eyes = eye_color
//	VD.cache_hair = hair_color
	mob_biotypes = MOB_UNDEAD
	skin_tone = "c9d3de"
	hair_color = "181a1d"
	facial_hair_color = "181a1d"
	eye_color = "ff0000"
	update_body()
	update_hair()
	update_body_parts(redraw = TRUE)


/mob/living/carbon/human/proc/blood_strength()
	set name = "Night Muscles"
	set category = "VAMPIRE"

	var/datum/antagonist/vampirelord/VD = mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(!VD)
		return
	if(VD.disguised)
		to_chat(src, "<span class='warning'>My curse is hidden.</span>")
		return
	if(VD.vitae < 500)
		to_chat(src, "<span class='warning'>Not enough vitae.</span>")
		return
	if(has_status_effect(/datum/status_effect/buff/bloodstrength))
		to_chat(src, "<span class='warning'>Already active.</span>")
		return
	VD.handle_vitae(-500)
	apply_status_effect(/datum/status_effect/buff/bloodstrength)
	to_chat(src, "<span class='greentext'>! NIGHT MUSCLES !</span>")
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/status_effect/buff/bloodstrength
	id = "bloodstrength"
	alert_type = /obj/screen/alert/status_effect/buff/bloodstrength
	effectedstats = list("strength" = 6)
	duration = 1 MINUTES

/obj/screen/alert/status_effect/buff/bloodstrength
	name = "Night Muscles"
	desc = ""
	icon_state = "bleed1"

/mob/living/carbon/human/proc/blood_celerity()
	set name = "Quickening"
	set category = "VAMPIRE"

	var/datum/antagonist/vampirelord/VD = mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(!VD)
		return
	if(VD.disguised)
		to_chat(src, "<span class='warning'>My curse is hidden.</span>")
		return
	if(VD.vitae < 500)
		to_chat(src, "<span class='warning'>Not enough silver blood.</span>")
		return
	if(has_status_effect(/datum/status_effect/buff/celerity))
		to_chat(src, "<span class='warning'>Already active.</span>")
		return
	VD.handle_vitae(-500)
	apply_status_effect(/datum/status_effect/buff/celerity)
	to_chat(src, "<span class='greentext'>! QUICKENING !</span>")
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/status_effect/buff/celerity
	id = "celerity"
	alert_type = /obj/screen/alert/status_effect/buff/celerity
	effectedstats = list("speed" = 15,"perception" = 10)
	duration = 30 SECONDS

/datum/status_effect/buff/celerity/nextmove_modifier()
	return 0.60

/obj/screen/alert/status_effect/buff/celerity
	name = "Quickening"
	desc = ""
	icon_state = "bleed1"

/mob/living/carbon/human/proc/blood_fortitude()
	set name = "Armor of Darkness"
	set category = "VAMPIRE"

	var/datum/antagonist/vampire/VD = mind.has_antag_datum(/datum/antagonist/vampire)
	if(!VD)
		return
	if(VD.disguised)
		to_chat(src, "<span class='warning'>My curse is hidden.</span>")
		return
	if(VD.vitae < 200)
		to_chat(src, "<span class='warning'>Not enough silver blood.</span>")
		return
	if(has_status_effect(/datum/status_effect/buff/fortitude))
		to_chat(src, "<span class='warning'>Already active.</span>")
		return
	VD.vitae -= 200
	apply_status_effect(/datum/status_effect/buff/fortitude)
	to_chat(src, "<span class='greentext'>! ARMOR OF DARKNESS !</span>")
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/status_effect/buff/fortitude
	id = "fortitude"
	alert_type = /obj/screen/alert/status_effect/buff/fortitude
	effectedstats = list("endurance" = 20,"constitution" = 20)
	duration = 30 SECONDS

/obj/screen/alert/status_effect/buff/fortitude
	name = "Armor of Darkness"
	desc = ""
	icon_state = "bleed1"

/datum/status_effect/buff/fortitude/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		QDEL_NULL(H.skin_armor)
		H.skin_armor = new /obj/item/clothing/suit/roguetown/armor/skin_armor/vampire_fortitude(H)
	owner.add_stress(/datum/stressevent/weed)

/datum/status_effect/buff/fortitude/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(istype(H.skin_armor, /obj/item/clothing/suit/roguetown/armor/skin_armor/vampire_fortitude))
			QDEL_NULL(H.skin_armor)
	. = ..()

/obj/item/clothing/suit/roguetown/armor/skin_armor/vampire_fortitude
	slot_flags = null
	name = "vampire's skin"
	desc = ""
	icon_state = null
	body_parts_covered = FULL_BODY
	armor = list("melee" = 100, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	prevent_crits = list(BCLASS_CUT,BCLASS_STAB,BCLASS_BLUNT)
	blocksound = SOFTHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = TRUE
	max_integrity = 0

/mob/living/carbon/human/proc/vamp_regenerate()
	set name = "Regenerate"
	set category = "VAMPIRE"

	var/datum/antagonist/vampirelord/VD = mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(!VD)
		return
	if(VD.disguised)
		to_chat(src, "<span class='warning'>My curse is hidden.</span>")
		return
	if(VD.vitae < 500)
		to_chat(src, "<span class='warning'>Not enough vitae.</span>")
		return
	to_chat(src, "<span class='greentext'>! REGENERATE !</span>")
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)
	VD.handle_vitae(-500)
	fully_heal()

/mob/living/carbon/human/proc/vampire_infect()
	if(!mind)
		return
	if(mind.has_antag_datum(/datum/antagonist/vampire))
		return
	if(mind.has_antag_datum(/datum/antagonist/werewolf))
		return
	if(mind.has_antag_datum(/datum/antagonist/zombie))
		return
	if(mob_timers["becoming_vampire"])
		return
	mob_timers["becoming_vampire"] = world.time
	addtimer(CALLBACK(src, .mob/living/carbon/human/proc/vampire_finalize), 2 MINUTES)
	to_chat(src, "<span class='danger'>I feel sick...</span>")
	src.playsound_local(get_turf(src), 'sound/music/horror.ogg', 80, FALSE, pressure_affected = FALSE)
	flash_fullscreen("redflash3")

/mob/living/carbon/human/proc/vampire_finalize()
	if(!mind)
		mob_timers["becoming_vampire"] = null
		return
	if(mind.has_antag_datum(/datum/antagonist/vampire))
		mob_timers["becoming_vampire"] = null
		return
	if(mind.has_antag_datum(/datum/antagonist/werewolf))
		mob_timers["becoming_vampire"] = null
		return
	if(mind.has_antag_datum(/datum/antagonist/zombie))
		mob_timers["becoming_vampire"] = null
		return
	var/datum/antagonist/vampire/new_antag = new /datum/antagonist/vampire/lesser()
	mind.add_antag_datum(new_antag)
	Sleeping(100)
//	stop_all_loops()
	src.playsound_local(src, 'sound/misc/deth.ogg', 100)
	if(client)
		SSdroning.kill_rain(client)
		SSdroning.kill_loop(client)
		SSdroning.kill_droning(client)
		client.move_delay = initial(client.move_delay)
		var/obj/screen/gameover/hog/H = new()
		H.layer = SPLASHSCREEN_LAYER+0.1
		client.screen += H
		H.Fade()
		addtimer(CALLBACK(H, /obj/screen/gameover/proc/Fade, TRUE), 100)

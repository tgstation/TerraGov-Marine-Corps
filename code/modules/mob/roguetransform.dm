/mob/living/carbon/human
	var/mob/stored_mob = null

/mob/living/carbon/human/species/werewolf/death(gibbed)
	werewolf_untransform(TRUE, gibbed)

/mob/living/carbon/human/proc/werewolf_transform()
	if (notransform)
		return
	if(!mind)
		log_runtime("NO MIND ON [src.name] WHEN TRANSFORMING")
	notransform = TRUE
	Paralyze(1, ignore_canstun = TRUE)
	for(var/obj/item/W in src)
		dropItemToGround(W)
	regenerate_icons()
	icon = null
	var/oldinv = invisibility
	invisibility = INVISIBILITY_MAXIMUM
	cmode = FALSE
	if(client)
		SSdroning.play_area_sound(get_area(src), client)
//	stop_cmusic()

	var/mob/living/carbon/human/species/werewolf/W = new (loc)

	W.gender = gender
	W.regenerate_icons()
	W.stored_mob = src
	W.limb_destroyer = TRUE
	W.ambushable = FALSE
	W.cmode_music = 'sound/music/combatmaniac.ogg'
	W.skin_armor = new /obj/item/clothing/suit/roguetown/armor/skin_armor/werewolf_skin(W)
	playsound(W.loc, pick('sound/combat/gib (1).ogg','sound/combat/gib (2).ogg'), 200, FALSE, 3)
	W.spawn_gibs(FALSE)
	apply_status_effect(STATUS_EFFECT_STASIS, null, TRUE)
	src.forceMove(W)

	W.after_creation()
	W.stored_language = new
	W.stored_language.copy_known_languages_from(src)
	W.stored_skills = mind.known_skills.Copy()
	W.stored_experience = mind.skill_experience.Copy()
	mind.transfer_to(W)
	W.mind.known_skills = list()
	W.mind.skill_experience = list()
	W.remove_all_languages()
	W.grant_language(/datum/language/beast)

//	var/datum/antagonist/werewolf/WW = mind.has_antag_datum(/datum/antagonist/werewolf)
//	if(!W.mind)
//		W.mind_initialize()
//	if(WW)
//		W.mind.add_antag_datum(WW)

	W.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, /datum/intent/unarmed/wwolf)
	W.update_a_intents()
	W.name = "WEREWOLF"
	W.real_name = "WEREWOLF"


	to_chat(W, "<span class='userdanger'>I transform into a horrible beast!</span>")
	W.emote("rage")

	W.stress = stress

	W.mind.adjust_skillrank(/datum/skill/combat/wrestling, 6, TRUE)
	W.mind.adjust_skillrank(/datum/skill/combat/unarmed, 6, TRUE)
	W.mind.adjust_skillrank(/datum/skill/misc/climbing, 6, TRUE)

	W.verbs |= /mob/living/carbon/human/proc/howl_button

	ADD_TRAIT(src, TRAIT_NOSLEEP, TRAIT_GENERIC)

	ADD_TRAIT(W, RTRAIT_STRONGBITE, TRAIT_GENERIC)
	ADD_TRAIT(W, RTRAIT_ZJUMP, TRAIT_GENERIC)
	ADD_TRAIT(W, TRAIT_NOFATSTAM, TRAIT_GENERIC)
	ADD_TRAIT(W, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(W, TRAIT_BASHDOORS, TRAIT_GENERIC)
	ADD_TRAIT(W, TRAIT_SHOCKIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(W, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(W, RTRAIT_BREADY, TRAIT_GENERIC)

	invisibility = oldinv
	notransform = FALSE


/mob/living/carbon/human/proc/werewolf_untransform(dead,gibbed)
	if(notransform)
		return
	if(!stored_mob)
		return
	if(!mind)
		log_runtime("NO MIND ON [src.name] WHEN UNTRANSFORMING")
	notransform = TRUE
	Paralyze(1, ignore_canstun = TRUE)
	for(var/obj/item/W in src)
		dropItemToGround(W)
	icon = null
	invisibility = INVISIBILITY_MAXIMUM

	var/mob/living/carbon/human/W = stored_mob
	stored_mob = null
	REMOVE_TRAIT(W, TRAIT_NOSLEEP, TRAIT_GENERIC)
	if(dead)
		W.death(gibbed)
//	W.key = key
	W.forceMove(get_turf(src))
	W.remove_status_effect(STATUS_EFFECT_STASIS)

	REMOVE_TRAIT(W, TRAIT_NOMOOD, TRAIT_GENERIC)
	stress = W.stress

//	var/datum/antagonist/werewolf/WW = mind.has_antag_datum(/datum/antagonist/werewolf)
//	if(WW)
//		W.mind.add_antag_datum(WW)
	mind.transfer_to(W)

	var/mob/living/carbon/human/species/werewolf/WA = src
	W.remove_all_languages()
	W.copy_known_languages_from(WA.stored_language)
	W.mind.known_skills = WA.stored_skills.Copy()
	W.mind.skill_experience = WA.stored_experience.Copy()

	W.regenerate_icons()

	to_chat(W, "<span class='userdanger'>I return to my facade.</span>")
	playsound(W.loc, pick('sound/combat/gib (1).ogg','sound/combat/gib (2).ogg'), 200, FALSE, 3)
	W.spawn_gibs(FALSE)
	W.Knockdown(30)
	W.Stun(30)

	qdel(src)


/obj/item/clothing/suit/roguetown/armor/skin_armor/werewolf_skin
	slot_flags = null
	name = "werewolf's skin"
	desc = ""
	icon_state = null
	body_parts_covered = FULL_BODY
	armor = list("melee" = 30, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	prevent_crits = list(BCLASS_CUT,BCLASS_CHOP,BCLASS_STAB,BCLASS_BLUNT)
	blocksound = SOFTHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = FALSE
	max_integrity = 100

/obj/item/clothing/suit/roguetown/armor/skin_armor/dropped(mob/living/user, show_message = TRUE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)
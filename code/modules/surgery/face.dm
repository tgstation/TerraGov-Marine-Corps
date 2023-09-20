//Procedures in this file: Facial reconstruction surgery
//////////////////////////////////////////////////////////////////
//						FACE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/face
	priority = 2
	can_infect = 0
	var/face_step = 0

/datum/surgery_step/face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(target_zone != "mouth")
		return SURGERY_CANNOT_USE
	if(affected.limb_status & LIMB_DESTROYED)
		return SURGERY_CANNOT_USE
	var/datum/limb/head/H = affected
	if(!istype(H) || !H.disfigured || H.face_surgery_stage != face_step)
		return SURGERY_CANNOT_USE
	return SURGERY_CAN_USE

/datum/surgery_step/face/cut_face
	allowed_tools = list(
		/obj/item/tool/surgery/scalpel = 100,
		/obj/item/tool/kitchen/knife = 75,
		/obj/item/shard = 50,
	)

	min_duration = FACIAL_CUT_MIN_DURATION
	max_duration = FACIAL_CUT_MAX_DURATION
	face_step = 0

/datum/surgery_step/face/cut_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_notice("[user] starts to cut open [target]'s face and neck with \the [tool]."), \
	span_notice("You start to cut open [target]'s face and neck with \the [tool]."))
	target.balloon_alert_to_viewers("Incising...")
	..()

/datum/surgery_step/face/cut_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_notice("[user] has cut open [target]'s face and neck with \the [tool].") , \
	span_notice("You have cut open [target]'s face and neck with \the [tool]."),)
	target.balloon_alert_to_viewers("Success")
	affected.face_surgery_stage = 1
	return ..()

/datum/surgery_step/face/cut_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_warning("[user]'s hand slips, slicing [target]'s throat wth \the [tool]!") , \
	span_warning("Your hand slips, slicing [target]'s throat wth \the [tool]!") )
	target.balloon_alert_to_viewers("Slipped!")
	affected.createwound(CUT, 60)
	target.Losebreath(10)
	target.updatehealth()
	affected.update_wounds()


/datum/surgery_step/face/mend_vocal
	allowed_tools = list(
		/obj/item/tool/surgery/hemostat = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/assembly/mousetrap = 10,
	)

	min_duration = FACIAL_MEND_MIN_DURATION
	max_duration = FACIAL_MEND_MAX_DURATION
	face_step = 1

/datum/surgery_step/face/mend_vocal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_notice("[user] starts mending [target]'s vocal cords with \the [tool]."), \
	span_notice("You start mending [target]'s vocal cords with \the [tool]."))
	target.balloon_alert_to_viewers("Mending vocals...")
	..()

/datum/surgery_step/face/mend_vocal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_notice("[user] mends [target]'s vocal cords with \the [tool]."), \
	span_notice("You mend [target]'s vocal cords with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	affected.face_surgery_stage = 2
	return ..()

/datum/surgery_step/face/mend_vocal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_warning("[user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!"), \
	span_warning("Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!"))
	target.balloon_alert_to_viewers("Slipped!")
	target.Losebreath(10)
	target.updatehealth()


/datum/surgery_step/face/fix_face
	allowed_tools = list(
		/obj/item/tool/surgery/retractor = 100,
		/obj/item/tool/crowbar = 55,
		/obj/item/tool/kitchen/utensil/fork = 75,
	)

	min_duration = FACIAL_FIX_MIN_DURATION
	max_duration = FACIAL_FIX_MAX_DURATION
	face_step = 2

/datum/surgery_step/face/fix_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_notice("[user] starts pulling the skin on [target]'s face back in place with \the [tool]."), \
	span_notice("You start pulling the skin on [target]'s face back in place with \the [tool]."))
	target.balloon_alert_to_viewers("Reshaping...")
	..()

/datum/surgery_step/face/fix_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_notice("[user] pulls the skin on [target]'s face back in place with \the [tool]."),	\
	span_notice("You pull the skin on [target]'s face back in place with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	affected.face_surgery_stage = 3
	return ..()

/datum/surgery_step/face/fix_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_warning("[user]'s hand slips, tearing skin on [target]'s face with \the [tool]!"), \
	span_warning("Your hand slips, tearing skin on [target]'s face with \the [tool]!"))
	target.balloon_alert_to_viewers("Slipped!")
	target.apply_damage(10, BRUTE, affected, 0, TRUE, updating_health = TRUE)


/datum/surgery_step/face/cauterize
	allowed_tools = list(
		/obj/item/tool/surgery/cautery = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/tool/lighter = 50,
		/obj/item/tool/weldingtool = 25,
	)

	min_duration = FACIAL_CAUTERISE_MIN_DURATION
	max_duration = FACIAL_CAUTERISE_MAX_DURATION
	face_step = 3


/datum/surgery_step/face/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_notice("[user] is beginning to cauterize the incision on [target]'s face and neck with \the [tool].") , \
	span_notice("You are beginning to cauterize the incision on [target]'s face and neck with \the [tool]."))
	target.balloon_alert_to_viewers("Cauterizing...")
	..()

/datum/surgery_step/face/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_notice("[user] cauterizes the incision on [target]'s face and neck with \the [tool]."), \
	span_notice("You cauterize the incision on [target]'s face and neck with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	affected.remove_limb_flags(LIMB_BLEEDING)
	affected.disfigured = 0
	affected.owner.name = affected.owner.get_visible_name()
	affected.face_surgery_stage = 0
	return ..()

/datum/surgery_step/face/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/head/affected)
	user.visible_message(span_warning("[user]'s hand slips, leaving a small burn on [target]'s face with \the [tool]!"), \
	span_warning("Your hand slips, leaving a small burn on [target]'s face with \the [tool]!"))
	target.balloon_alert_to_viewers("Slipped!")
	target.apply_damage(4, BURN, affected, updating_health = TRUE)

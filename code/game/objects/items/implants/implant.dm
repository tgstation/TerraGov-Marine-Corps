/obj/item/implant
	name = "implant"
	icon = 'icons/obj/items/implants.dmi'
	icon_state = "implant"
	embedding = list("embedded_flags" = EMBEDDED_DEL_ON_HOLDER_DEL, "embed_process_chance" = 0, "embed_chance" = 0, "embedded_fall_chance" = 0)
	///Whether this implant has been implanted inside a human yet
	var/implanted = FALSE
	///Owner mob this implant is inserted to
	var/mob/living/implant_owner
	///The owner limb this implant is inside
	var/datum/limb/part
	///Color of the implant, used for selecting the implant cases icon_state
	var/implant_color = "b"
	///whether this implant allows reagents to be inserted into it
	var/allow_reagents = FALSE
	///What level of malfunction/breakage this implant is at, used for functionality checks
	var/malfunction = MALFUNCTION_NONE
	///Implant secific flags
	var/flags_implant = GRANT_ACTIVATION_ACTION
	///Whitelist for llimbs that this implavnt is allowed to be inserted into, all limbs by default
	var/list/allowed_limbs
	///Activation_action reference
	var/datum/action/item_action/implant/activation_action
	///Cooldown between usages of the implant
	var/cooldown_time = 1 SECONDS
	COOLDOWN_DECLARE(activation_cooldown)

/obj/item/implant/Initialize(mapload)
	. = ..()
	if(flags_implant & GRANT_ACTIVATION_ACTION)
		activation_action = new(src, src)
	if(allow_reagents)
		reagents = new /datum/reagents(MAX_IMPLANT_REAGENTS)
		reagents.my_atom = WEAKREF(src)
	if(!allowed_limbs)
		allowed_limbs = GLOB.human_body_parts


/obj/item/implant/Destroy(force)
	unimplant()
	QDEL_NULL(activation_action)
	part?.implants -= src
	return ..()

/obj/item/implant/ui_action_click(mob/user, datum/action/item_action/action)
	activate()

///Handles the actual activation of the implant/it's effects. Returns TRUE on succesful activation and FALSE on failure for parentcalls
/obj/item/implant/proc/activate()
	if(!COOLDOWN_CHECK(src, activation_cooldown))
		return FALSE
	COOLDOWN_START(src, activation_cooldown, cooldown_time)
	return TRUE

///Attempts to implant a mob with this implant, TRUE on success, FALSE on failure
/obj/item/implant/proc/try_implant(mob/living/carbon/human/target, mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	if(!ishuman(target))
		return FALSE
	if(!(user.zone_selected in allowed_limbs))
		to_chat(user, span_warning("You cannot implant this into that limb!"))
		return FALSE
	return implant(target, user)

/**
 * What does the implant do upon injection?
 * returns TRUE if the implant succeeds
 */
/obj/item/implant/proc/implant(mob/living/carbon/human/target, mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	forceMove(target)
	implant_owner = target
	implanted = TRUE
	var/limb_targeting = (user ? user.zone_selected : BODY_ZONE_CHEST)
	var/datum/limb/affected = target.get_limb(limb_targeting)
	if(!affected)
		CRASH("[src] implanted into [target] [user ? "by [user]" : ""] but had no limb, despite being set to implant in [limb_targeting].")
	affected.implants += src
	part = affected
	if(flags_implant & ACTIVATE_ON_HEAR)
		RegisterSignal(src, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))
	activation_action?.give_action(target)
	embed_into(target, limb_targeting, TRUE)
	return TRUE

/obj/item/implant/unembed_ourself()
	. = ..()
	unimplant()

/obj/item/implant/proc/unimplant()
	SHOULD_CALL_PARENT(TRUE)
	if(!implanted)
		return FALSE
	activation_action?.remove_action(implant_owner)
	if(flags_implant & ACTIVATE_ON_HEAR)
		UnregisterSignal(src, COMSIG_MOVABLE_HEAR)
	implanted = FALSE
	part.implants -= src
	part = null
	forceMove(get_turf(implant_owner))
	implant_owner = null

///Returns info about a implant concerning its usage and such
/obj/item/implant/proc/get_data()
	return "No information available"

///Called when the implant hears a message, used for activation phrases and the like
/obj/item/implant/proc/on_hear(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SIGNAL_HANDLER
	return

///Destroys and makes the implant unusable
/obj/item/implant/proc/meltdown()
	to_chat(implant_owner, span_warning("You feel something melting inside [part ? "your [part.display_name]" : "you"]!"))
	part.take_damage_limb(0, 15)

	name = "melted implant"
	desc = "Charred circuit in melted plastic case. Wonder what that used to be..."
	icon_state = "implant_melted"
	malfunction = MALFUNCTION_PERMANENT

/datum/action/item_action/implant
	desc = "Activates a currently implanted implant"

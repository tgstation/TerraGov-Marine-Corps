//! This file contains all the procs related to examining atoms,
//! except the verb you use to examine someone (see [/mob/verb/examinate])

/atom
	/// If non-null, overrides a/an/some in all cases
	var/article
	/// Text that appears preceding the name in [/atom/proc/examine_title].
	/// Don't include spaces after this, since that proc adds a space on its own.
	var/examine_thats = "That's"
	/// Boxed message style when examining this atom.
	/// Must be `boxed_message` or `boxed_message [red/green/blue/purple]_box`.
	var/boxed_message_style = "boxed_message"

/mob/living/carbon/human
	examine_thats = "This is"

/mob/living/silicon/ai
	examine_thats = "This is"

/**
 * Called when a mob examines this atom. [/mob/verb/examinate]
 *
 * This is the actual proc that generates the text for examining something
 *
 * Default behaviour is to get the name and icon of the object and its reagents where
 * the [TRANSPARENT] flag is set on the reagents holder
 *
 * SIGNAL FUN:
 * Produces a signal [COMSIG_ATOM_EXAMINE] - can use this to directly modify/add stuff to the examine list
 */
/atom/proc/examine(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	if(desc)
		. += "<i>[desc]</i>"

	var/list/tags_list = examine_tags(user)
	if(length(tags_list))
		var/tag_string = list()
		for(var/atom_tag in tags_list)
			tag_string += (isnull(tags_list[atom_tag]) ? atom_tag : span_tooltip(tags_list[atom_tag], atom_tag))
		// some regex to ensure that we don't add another "and" if the final element's main text (not tooltip) has one
		tag_string = english_list(tag_string, and_text = (findtext(tag_string[length(tag_string)], regex(@">.*?and .*?<"))) ? " " : " and ")
		. += "[p_they(TRUE)] [p_are()] [tag_string]."
	if(user.can_use_codex() && SScodex.get_codex_entry(get_codex_value()))
		. += EXAMINE_SECTION_BREAK
		. += span_notice("The codex has <a href='byond://?_src_=codex;show_examined_info=[REF(src)];show_to=[REF(user)]'>relevant information</a> available.")

	if((get_dist(user,src) <= 2) && reagents)
		. += EXAMINE_SECTION_BREAK
		if(reagents.reagent_flags & TRANSPARENT)
			. += "It contains:"
			if(length(reagents.reagent_list)) // TODO: Implement scan_reagent and can_see_reagents() to show each individual reagent
				var/total_volume = 0
				for(var/datum/reagent/R in reagents.reagent_list)
					total_volume += R.volume
				. +=  span_notice("[total_volume] units of various reagents.")
			else
				. += "Nothing."
		else if(CHECK_BITFIELD(reagents.reagent_flags, AMOUNT_VISIBLE))
			if(reagents.total_volume)
				. += span_notice("It has [reagents.total_volume] unit\s left.")
			else
				. += span_warning("It's empty.")
		else if(CHECK_BITFIELD(reagents.reagent_flags, AMOUNT_SKILLCHECK))
			if(isxeno(user))
				return
			if((user.skills.getRating(SKILL_MEDICAL) >= SKILL_MEDICAL_NOVICE) || isobserver(usr))
				. += "It contains these reagents:"
				if(length(reagents.reagent_list))
					for(var/datum/reagent/R in reagents.reagent_list)
						. += "[R.volume] units of [R.name]"
				else
					. += "Nothing."
			else
				. += "You don't know what's in it."
		else if(reagents.reagent_flags & AMOUNT_ESTIMEE)
			var/obj/item/reagent_containers/C = src
			if(!reagents.total_volume)
				. += span_notice("\The [src] is empty!")
			else if (reagents.total_volume<= C.volume*0.3)
				. += span_notice("\The [src] is almost empty!")
			else if (reagents.total_volume<= C.volume*0.6)
				. += span_notice("\The [src] is half full!")
			else if (reagents.total_volume<= C.volume*0.9)
				. += span_notice("\The [src] is almost full!")
			else
				. += span_notice("\The [src] is full!")

	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE, user, .)

/// Icon displayed in examine. Really just an icon2html wrapper,
/// BUT we can override this on something like a mob if it has issues with icon2html
/atom/proc/get_examine_icon(mob/user)
	return icon2html(src, user)

/**
 * Get the name of this object for examine
 *
 * You can override what is returned from this proc by registering to listen for the
 * [COMSIG_ATOM_GET_EXAMINE_NAME] signal
 */
/atom/proc/get_examine_name(mob/user)
	. = "\a [src]"
	var/list/override = list(gender == PLURAL ? "some" : "a", " ", "[name]")
	if(article)
		. = "[article] [src]"
		override[EXAMINE_POSITION_ARTICLE] = article
	if(SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
		. = override.Join("")

///Generate the full examine string of this atom (including icon for chat)
/atom/proc/examine_title(mob/user, thats = FALSE)
	var/examine_icon = get_examine_icon(user)
	return "[examine_icon ? "[examine_icon] " : ""][thats ? "[examine_thats] ":""]<em>[get_examine_name(user)]</em>"

/**
 * This is called when we want to get a sort-of "descriptor" for this item, where applicable.
 *
 * Must return a string. Can be something like "item" "weapon" etc.
 *
 * Used for [/obj/item/examine_tags], will appear in the weight class tooltip, like:
 * It is a normal-sized (whatever this returns).
 */
/atom/proc/examine_descriptor(mob/user)
	return "object"

/**
 * A list of "tags" displayed after atom's description in examine.
 * This should return an assoc list of tags -> tooltips for them.
 * Should probably be calling parent so signals can modify it.
 *
 * ### Things to keep in mind:
 *
 * * TGUI tooltips (not the main text) in chat cannot use HTML stuff at all, so
 * including something like `<b><big>ffff</big></b>` will not work for tooltips.
 *
 * **Example usage:**
 * ```byond
 * .["small"] = "It is a small [examine_descriptor(user)]." // It is a small item.
 * .["fireproof"] = "It is made of fire-retardant materials."
 * .["and conductive"] = "Blah blah blah." // Using 'and' in the final element's main text will work aswell.
 * ```
 * This will result in
 *
 * It is *small*, *fireproof* *and conductive*.
 *
 * SIGNAL FUN:
 * Produces a signal [COMSIG_ATOM_EXAMINE_TAGS] - can use this to directly modify/add stuff to the examine tags list
 */
/atom/proc/examine_tags(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE_TAGS, user, .)

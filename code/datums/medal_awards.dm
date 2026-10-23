/// A list of all medals awarded to players; indexed by character real name.
GLOBAL_LIST_EMPTY(medal_awards)

/**
 * A list of all medals awarded to a player.
 */
/datum/recipient_awards
	/// Medal names.
	var/list/medal_names = list()
	/// Medal citations.
	var/list/medal_citations = list()
	/// If the medal was awarded after death.
	var/list/posthumous = list()
	/// The rank of the recipient.
	var/recipient_rank

/**
 * Award a medal to a chosen marine.
 * Does not check if the user has the right to award medals.
 * - mob/user - The mob awarding the medal.
 */
/proc/do_award_medal(mob/user)
	var/list/all_marines = list()
	for(var/mob/living/mob as anything in GLOB.human_mob_list)
		if(!isterragovjob(mob?.job)) // this should mean only terragov marine roles
			continue
		if(user == mob)
			continue
		var/display_name = mob.job.title + " " + mob.real_name
		var/list/dupes_found = list()
		// this shouldnt realyl happen but eh lets be safe
		if(all_marines[display_name])
			if(!dupes_found)
				dupes_found[display_name] = 1
			else
				dupes_found[display_name]++
			display_name = display_name + " #" + "[dupes_found[display_name]]"
		all_marines[display_name] = mob
	if(!length(all_marines))
		to_chat(user, "Who do that vodoo you do? (No valid targets?)")
		return FALSE

	var/choice = tgui_input_list(user, "Award a medal to who?", "Medal Tyme", sort_list(all_marines)) // no its not a typo.
	if(!choice || !(choice in all_marines))
		return FALSE
	var/marine = all_marines[choice]
	if(marine == null)
		to_chat(user, span_notice("Failed to select target due to an internal server error."))
		while(null in GLOB.human_mob_list)
			GLOB.human_mob_list -= null
		return
	award_medal_to(user, marine)

/**
 * Award a medal to a client. Note that players do not get persistent medals if dead (or the body no longer exists).
 * - mob/user - The mob awarding the medal.
 * - mob/living/awardee - The mob receiving the medal.
 */
/proc/award_medal_to(mob/issuer, mob/living/awardee)
	if(issuer == null)
		CRASH("Attempted to award a medal with a null issuer.")
	if(awardee == null)
		CRASH("Attempted to award a medal to a null awardee.")
	if(issuer == awardee || issuer.ckey == awardee.ckey)
		to_chat(issuer, "You can't award yourself a medal.")
		return FALSE

	var/is_posthumous = (awardee.stat == DEAD)

	var/list/medal_types = subtypesof(/obj/item/clothing/tie/medal)
	var/list/medal_choices = list("Cancel")
	for(var/obj/item/clothing/tie/medal/medal_type as anything in medal_types)
		medal_choices[medal_type::name] = medal_type

	var/medal_choice = tgui_input_list(issuer, "What type of medal do you want to award?", "Medal Type", medal_choices)
	if(!medal_choice || medal_choice == "Cancel")
		return FALSE
	var/medal_type = medal_choices[medal_choice]
	var/medal_citation = stripped_input(issuer, "What should the medal citation read?", "Medal Citation", max_length = 255) || "Non-Specific"

	var/obj/item/clothing/tie/medal/medal = new medal_type
	medal.recipient_name = awardee.real_name
	medal.recipient_rank = awardee.get_paygrade(PAYGRADE_FULL)
	medal.medal_citation = medal_citation

	// award if the player exists and is not dead
	if(!isnull(awardee) && !isnull(medal.medal_uid))
		var/datum/medal_persistence/medals = get_medal_persistence_for_ckey(awardee.ckey)
		var/datum/persistent_medal_info/medal_info = medals.award_medal(
			awardee.real_name,
			medal.recipient_rank,
			issuer.real_name,
			issuer.get_paygrade(PAYGRADE_FULL),
			medal.medal_uid,
			medal_citation,
			is_posthumous,
		)
		medal_info.medal = medal

	if(!(awardee.real_name in GLOB.medal_awards))
		var/datum/recipient_awards/new_award = new /datum/recipient_awards
		new_award.recipient_rank = medal.recipient_rank
		GLOB.medal_awards[awardee.real_name] = new_award

	var/datum/recipient_awards/awards = GLOB.medal_awards[awardee.real_name]
	awards.medal_names += medal_choice
	awards.medal_citations += medal_citation
	awards.posthumous += is_posthumous

	log_game("[key_name(issuer)] awarded a [medal_choice] to [awardee.real_name] for: '[medal_citation]'.")
	message_admins("[ADMIN_TPMONTY(issuer)] awarded a [medal_choice] to [ADMIN_TPMONTY(awardee)] for: '[medal_citation]'.")

	issuer.put_in_hands(medal)
	return TRUE

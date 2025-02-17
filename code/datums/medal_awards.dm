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
 * - mob/medal_awardee - The mob being awarded the medal.
 */
/proc/do_award_medal(mob/user)
	var/list/all_marines = list()
	for(var/mob/living/mob in GLOB.mob_living_list)
		var/real_name = mob.real_name
		var/datum/data/record/record
		// holy shit theres gotta be a better way
		for(var/datum/data/record/t in GLOB.datacore.general)
			if(t.fields["name"] == real_name)
				record = t
				break
		if(!record)
			continue
		all_marines[real_name] = list(GLOB.joined_player_list[real_name], record.fields["rank"])

	if(!length(all_marines))
		to_chat("Who do that vodoo you do?")
		return FALSE

	var/choice = tgui_input_list(user, "Award a medal to who?", "Medal Tyme", sort_names(all_marines)) // no its not a typo.
	if(!choice || !(choice in all_marines))
		return FALSE

	award_medal_to(user, )

/**
 * Award a medal to a client. Note that players do not get persistent medals if dead (or the body no longer exists).
 * - mob/user - The mob awarding the medal.
 * - client/medal_awardee - he mob being awarded the medal.
 * - awardee_real_name - The real name of the player being awarded the medal.
 */
/proc/award_medal_to(
	mob/issuer,
	client/medal_awardee,
	awardee_real_name,
)
	var/datum/data/record/awardee_record
	var/datum/data/record/issuer_record
	for(var/datum/data/record/t in GLOB.datacore.general)
		if(t.fields["name"] == awardee_real_name)
			awardee_record = t
			continue
		if(t.fields["name"] == issuer.real_name)
			issuer_record = t
			continue
		if(awardee_record && issuer_record)
			break

	if(!awardee_record)
		to_chat(issuer, span_warning("No record found for [awardee_real_name]."))
		return FALSE
	if(!issuer_record && !check_rights_for(issuer, NONE))
		to_chat(issuer, span_warning("According to all of our paperwork you do not exist.")) // lol
		return FALSE

	var/mob/living/awardee_mob
	for(var/mob/living/living in GLOB.mob_living_list)
		if(living.real_name == awardee_real_name)
			awardee_mob = living
			break

	var/is_posthumous = FALSE
	if(!awardee_mob || awardee_mob.stat == DEAD)
		is_posthumous = TRUE

	var/list/medal_types = subtypesof(/obj/item/clothing/tie/medal)
	var/list/medal_choices = list("Cancel")
	for(var/obj/item/clothing/tie/medal/medal_type in medal_types)
		medal_choices[medal_type::name] = medal_type

	var/medal_choice = tgui_input_list(issuer, "What type of medal do you want to award?", "Medal Type", medal_choices)
	if(!medal_choice || medal_choice == "Cancel")
		return FALSE
	var/medal_type = medal_choices[medal_choice]
	var/medal_citation = stripped_input(issuer, "What should the medal citation read?", "Medal Citation") || "Non-Specific"

	var/obj/item/clothing/tie/medal/medal = new medal_type
	medal.recipient_name = awardee_real_name
	medal.recipient_rank = awardee_record.fields["rank"]
	medal.medal_citation = medal_citation

	// award if the player exists and is not dead
	if(!is_posthumous && !isnull(medal_awardee))
		var/datum/medal_persistence/medals = get_medal_persistence(medal_awardee.key)
		var/datum/persistent_medal_info/medal = medals.award_medal(
			awardee_real_name,
			awardee_record.fields["rank"],
			issuer.real_name,
			issuer_record.fields["rank"],
			medal_type,
			medal_citation,
		)
		medal.medal = medal

	if(!(awardee_real_name in GLOB.medal_awards))
		var/datum/recipient_awards/new_award = new /datum/recipient_awards
		new_award.recipient_rank = awardee_record.fields["rank"] // could cache this, oh well
	var/datum/recipient_awards/awards = GLOB.medal_awards[awardee_real_name]
	awards.medal_names += medal_choice
	awards.medal_citations += medal_citation
	awards.posthumous += is_posthumous

	log_game("[key_name(issuer)] awarded a [medal_choice] to [awardee_real_name] for: '[medal_citation]'.")
	message_admins("[ADMIN_TPMONTY(issuer)] awarded a [medal_choice] to [awardee_real_name] for: '[medal_citation]'.")

	issuer.put_in_hands(medal)
	return TRUE

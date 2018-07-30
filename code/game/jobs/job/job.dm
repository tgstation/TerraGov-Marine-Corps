/datum/job

	//The name of the job
	var/title = ""				 //The internal title for the job, used for the job ban system and so forth. Don't change these, change the disp_title instead.
	var/special_role 			 //In case they have some special role on spawn.
	var/disp_title				 //Determined on new(). Usually the same as the title, but doesn't have to be. Set this to override what the player sees in the game as their title.
	var/comm_title 			= "" //The mini-title to display over comms.
	var/paygrade 			= 0 //Also displays a ranking when talking over the radio.

	//Job access. The use of minimal_access or access is determined by a config setting: config.jobs_have_minimal_access
	var/list/minimal_access		//Useful for servers which prefer to only have access given to the places a job absolutely needs (Larger server population)
	var/list/access				//Useful for servers which either have fewer players, so each person needs to fill more than one role, or servers which like to give more access, so players can't hide forever in their super secure departments (I'm looking at you, chemistry!)

	var/faction 			= "Marines" //Players will be allowed to spawn in as jobs that are set to "Marines". Other factions are special game mode spawns.
	var/total_positions 	= 0 //How many players can be this job
	var/spawn_positions 	= 0 //How many players can spawn in as this job
	var/scaled = 0
	var/current_positions 	= 0 //How many players have this job
	var/supervisors 		= "" //Supervisors, who this person answers to directly. Should be a string, shown to the player when they enter the game.
	var/selection_color 	= "#ffffff" //Sellection screen color.
	var/idtype 				= /obj/item/card/id //The type of the ID the player will have.
	var/list/alt_titles 	//List of alternate titles, if any.
	//If you have use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/minimal_player_age 	= 0
	//var/flags_role				= NOFLAGS
	var/flag = NOFLAGS //TODO robust this later.
	//var/flags_department 			= NOFLAGS
	var/department_flag = NOFLAGS //TODO robust this later.
	var/flags_startup_parameters 	= NOFLAGS //These flags are used to determine how to load the role, and some other parameters.
	var/flags_whitelist 			= NOFLAGS //Only used by whitelisted roles. Can be a single whitelist flag, or a combination of them.

	var/skills_type //the job knowledges we have. a type path

	New()
		..()
		if(!disp_title) disp_title = title

/datum/job/proc/get_alternative_title(mob/living/M, lowercase)
	if(istype(M) && M.client && M.client.prefs)
		. = M.client.prefs.GetPlayerAltTitle(src)
		if(. && lowercase) . = lowertext(.)

/datum/job/proc/set_spawn_positions(var/count) return spawn_positions

/datum/job/proc/generate_wearable_equipment() return list() //This should ONLY be used to list things that the character can wear, or show on their sprite.

/datum/job/proc/generate_stored_equipment() return list() //This is the list of everything else. Combine the two.

/datum/job/proc/get_wearable_equipment() return generate_wearable_equipment() //Use and override this proc to get things for character select dressup.

/datum/job/proc/generate_entry_message() return //The job description that characters get, along with anything else that may be appropriate.

/datum/job/proc/announce_entry_message(mob/living/carbon/human/H, datum/money_account/M) //The actual message that is displayed to the mob when they enter the game as a new player.
	set waitfor = 0
	sleep(10)
	if(H && H.loc && H.client)
		var/title_given
		var/title_alt
		title_alt = get_alternative_title(H,1)
		title_given = title_alt ? title_alt : lowertext(disp_title)

		//Document syntax cannot have tabs for proper formatting.
		var/t = {"
<span class='role_body'>|______________________|</span>
<span class='role_header'>You are \a [title_given]![flags_startup_parameters & ROLE_ADMIN_NOTIFY? "\nYou are playing a job that is important for game progression. If you have to disconnect, please notify the admins via adminhelp." : ""]</span>

<span class='role_body'>[generate_entry_message(H)]</span>

<span class='role_body'>As the [title_given] you answer to [supervisors]. Special circumstances may change this.[M ? "\nYour account number is: <b>[M.account_number]</b>. Your account pin is: <b>[M.remote_access_pin]</b>." : ""]</span>
<span class='role_body'>|______________________|</span>
"}

		H << t

/datum/job/proc/generate_entry_conditions(mob/living/M) return //Anything special that should happen to the mob upon entering the world.

//Have to pass H to both equip procs so that "backbag" shows correctly. Sigh.
/datum/job/proc/equip(mob/living/carbon/human/H, list/L = generate_wearable_equipment() + generate_stored_equipment())
	if(!istype(H) || !L.len) return
	var/i
	var/item_path
	var/obj/item/stack/sheet/I //Just to make this shorter.

	for(i in L)
		item_path = L[i]
		I = new item_path(H)
		if(istype(I)) I.amount = 30 //We want to make sure that the amount is actually proper.
		H.equip_to_slot_or_del(I, i) //The item loc will be transferred from mob to an item, if needed.

//This should come after equip(), usually only on spawn or late join. Otherwise just use equip.
/datum/job/proc/equip_preference_gear(mob/living/carbon/human/H)
	 //TODO Adjust this based on mob and latejoin.
	 //TODO Adjust the actual spawns, so they all have a slot, instead of spawning in the pack when they don't have a slot.
	if(!H.client || !H.client.prefs || !H.client.prefs.gear) return//We want to equip them with custom stuff second, after they are equipped with everything else.
	var/datum/gear/G
	var/i
	for(i in H.client.prefs.gear)
		G = gear_datums[i]
		if(G)
			if(G.allowed_roles && !(title in G.allowed_roles)) 				continue //Is the role allowed?
			if(G.whitelisted && !is_alien_whitelisted(H, G.whitelisted)) 	continue //is the role whitelisted? //TODO Remove this.
			H.equip_to_slot_or_del(new G.path(H), G.slot ? G.slot : WEAR_IN_BACK)

	//Give humans wheelchairs, if they need them.
	var/datum/limb/l_foot = H.get_limb("l_foot")
	var/datum/limb/r_foot = H.get_limb("r_foot")
	if((!l_foot || l_foot.status & LIMB_DESTROYED) && (!r_foot || r_foot.status & LIMB_DESTROYED))
		var/obj/structure/bed/chair/wheelchair/W = new (H.loc)
		H.buckled = W
		H.update_canmove()
		W.dir = H.dir
		W.buckled_mob = H
		W.add_fingerprint(H)

	//Gives glasses to the vision impaired
	if(H.disabilities & NEARSIGHTED)
		var/obj/item/clothing/glasses/regular/P = new (H)
		P.prescription = 1
		H.equip_to_slot_or_del(P, WEAR_EYES)

/datum/job/proc/equip_identification(mob/living/carbon/human/H)
	if(!istype(H))	return
	var/obj/item/card/id/C
	var/title_alt
	title_alt = get_alternative_title(H)

	C = new idtype(H)
	C.access = get_access()
	C.paygrade = paygrade
	C.registered_name = H.real_name
	C.rank = title
	C.assignment = title_alt ? title_alt : disp_title
	C.name = "[C.registered_name]'s ID Card ([C.assignment])"

	//put the player's account number onto the ID
	if(H.mind && H.mind.initial_account) C.associated_account_number = H.mind.initial_account.account_number
	H.equip_to_slot_or_del(C, WEAR_ID)
	return 1

//This proc removes overlays, then adds new ones.
/datum/job/proc/display_overlay_equipment(atom/A, list/L = get_wearable_equipment())
	var/image/reusable/I
	var/obj/item/P
	var/i
	for(i in A.overlays) //Remove the old.
		A.overlays -= i
		cdel(i)
	for(i in L) //Add the new.
		P = i
		I = rnew(/image/reusable, list(initial(P.icon),A, initial(P.icon_state)))
		A.overlays += I

/datum/job/proc/get_access()
	if(!config)							return minimal_access.Copy() //Need to copy, because we want a new list here. Not the datum's list.
	if(config.jobs_have_minimal_access) return minimal_access.Copy()
	return access.Copy()

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	if(available_in_days(C) == 0) return 1	//If available in 0 days, the player is old enough to play. Can be compared to null, but I think this is clearer.

/datum/job/proc/available_in_days(client/C)
	//Checking the player's age is only possible through a db connection, so if there isn't one, player age will be a text string instead.
	if(!istype(C) || !config.use_age_restriction_for_jobs || !isnum(C.player_age) || !isnum(minimal_player_age)) return 0 //One of the few times when returning 0 is the proper behavior.
	return max(0, minimal_player_age - C.player_age)

//This lets you scale max jobs at runtime
//All you have to do is rewrite the inheritance
/datum/job/proc/get_total_positions(var/latejoin)
	return latejoin ? spawn_positions : total_positions

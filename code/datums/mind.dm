/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/living/current
	var/mob/living/original	//TODO: remove.not used in any meaningful way ~Carn. First I'll need to tweak the way silicon-mobs handle minds.
	var/active = 0

	var/memory

	var/assigned_role
	var/special_role
	var/assigned_squad

	var/datum/skills/cm_skills //the knowledge you have about certain abilities and actions (e.g. do you how to do surgery?)
								//see skills.dm in #define folder and code/datums/skills.dm for more info

	var/role_alt_title
	var/role_comm_title

//	var/datum/job/assigned_job

	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/datum/faction/faction 			//associated faction
	var/datum/changeling/changeling		//changeling holder

	var/rev_cooldown = 0

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1

	//put this here for easier tracking ingame
	var/datum/money_account/initial_account

	New(var/key)
		src.key = key




	proc/transfer_to(mob/living/new_character, var/force_key_move = FALSE)
		if(current)	current.mind = null	//remove ourself from our old body's mind variable

		if(new_character.mind) new_character.mind.current = null //remove any mind currently in our new body's mind variable
		nanomanager.user_transferred(current, new_character) // transfer active NanoUI instances to new user

		current = new_character		//link ourself to our new body
		new_character.mind = src	//and link our new body to ourself

		if(active || force_key_move)
			new_character.key = key		//now transfer the key to link the client to our new body
			if(new_character.client)
				new_character.client.change_view(world.view) //reset view range to default.
				new_character.client.pixel_x = 0
				new_character.client.pixel_y = 0

		new_character.refresh_huds(current)					//inherit the HUDs from the old body


	proc/store_memory(new_text)
		memory += "[new_text]<BR>"

	proc/show_memory(mob/recipient)
		var/output = "<B>[current.real_name]'s Memory</B><HR>"
		output += memory

		recipient << browse(output,"window=memory")

	proc/edit_memory()
		if(!SSticker?.mode)
			alert("Not before round-start!", "Alert")
			return

		var/out = "<B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"
		out += "Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>"
		out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"

		out += "<br>"

		out += "<b>Memory:</b><br>"
		out += memory
		out += "<br><a href='?src=\ref[src];memory_edit=1'>Edit memory</a><br>"

		usr << browse(out, "window=edit_memory[src]")

	Topic(href, href_list)
		if(!check_rights(R_ADMIN))	return

		if (href_list["role_edit"])
			var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in joblist
			if (!new_role)
				return
			assigned_role = new_role
			if(ishuman(current) && current.mind)
				current.reset_cm_skills(new_role)
				current.reset_special_role(new_role)
				current.reset_comm_title(new_role)
				current.reset_alt_title(new_role)
				current.set_ID(new_role)
				current.update_action_buttons()

		else if (href_list["memory_edit"])
			var/new_memo = copytext(sanitize(input("Write new memory", "Memory", memory) as null|message),1,MAX_MESSAGE_LEN)
			if (isnull(new_memo)) return
			memory = new_memo

		edit_memory()

	// check whether this mind's mob has been brigged for the given duration
	// have to call this periodically for the duration to work properly
	proc/is_brigged(duration)
		var/turf/T = current.loc
		if(!istype(T))
			brigged_since = -1
			return 0

		var/is_currently_brigged = 0

		if(istype(T.loc,/area/sulaco/brig))
			is_currently_brigged = 1
			for(var/obj/item/card/id/card in current)
				is_currently_brigged = 0
				break // if they still have ID they're not brigged
			for(var/obj/item/device/pda/P in current)
				if(P.id)
					is_currently_brigged = 0
					break // if they still have ID they're not brigged

		if(!is_currently_brigged)
			brigged_since = -1
			return 0

		if(brigged_since == -1)
			brigged_since = world.time

		return (duration <= world.time - brigged_since)


/datum/mind/proc/set_cm_skills(skills_path)
	if(cm_skills)
		qdel(cm_skills)
	cm_skills = new skills_path()

/mob/proc/reset_cm_skills(new_job)
	var/datum/job/J = SSjob.roles_by_name[new_job]
	if(J)
		mind?.set_cm_skills(J.skills_type) //give new role's job_knowledge to us.

/mob/proc/reset_comm_title(new_job)
	var/datum/job/J = SSjob.roles_by_name[new_job]
	if(J && mind)
		mind.role_comm_title = J.comm_title

/mob/proc/reset_alt_title(new_job)
	var/datum/job/J = SSjob.roles_by_name[new_job]
	if(J && mind)
		mind.role_alt_title = J.get_alternative_title(src)

/mob/proc/reset_special_role(new_job)
	var/datum/job/J = SSjob.roles_by_name[new_job]
	if(J && mind)
		mind.special_role = J.special_role


/mob/proc/reset_role(new_job)
	var/datum/job/J = SSjob.roles_by_name[new_job]
	if(J && mind)
		mind.assigned_role = J.title

/mob/proc/set_ID(new_job)
	var/datum/job/J = SSjob.roles_by_name[new_job]
	if(new_job && ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.wear_id)
			var/obj/item/card/id/I = H.wear_id.GetID()
			if(I)
				var/title_alt = J.get_alternative_title(H)
				I.access = J.get_access()
				I.rank = J.title
				I.assignment = title_alt ? title_alt :  J.disp_title
				I.name = "[I.registered_name]'s ID Card ([I.assignment])"
				I.paygrade = J.paygrade
		else
			J.equip_identification(H, J)

/mob/proc/set_everything(var/mob/living/carbon/human/H, var/new_role)
	H.reset_cm_skills(new_role)
	H.reset_special_role(new_role)
	H.reset_comm_title(new_role)
	H.reset_alt_title(new_role)
	H.reset_role(new_role)
	H.set_ID(new_role)
	H.update_action_buttons()

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind) mind.key = key
	else
		mind = new /datum/mind(key)
		mind.original = src
		if(SSticker) SSticker.minds += mind
		else log_world("## DEBUG: mind_initialize(): No SSticker ready yet! Please inform Carn")
		. = 1 //successfully created a new mind
	if(!mind.name)	mind.name = real_name
	mind.current = src

//HUMAN
/mob/living/carbon/human/mind_initialize()
	if(..()) //new mind created
		//if we find an ID with assignment, we give the new mind the info linked to that job.
		if(wear_id)
			var/obj/item/card/id/I = wear_id.GetID()
			if(I && I.assignment)
				reset_role(I.rank)
				reset_cm_skills(I.rank)
				reset_special_role(I.rank)
				reset_alt_title(I.rank)
				reset_comm_title(I.rank)

	//if not, we give the mind default job_knowledge and assigned_role
	if(!mind.assigned_role)
		mind.assigned_role = "Squad Marine"	//default
		if(mind.cm_skills)
			qdel(mind.cm_skills)
		mind.cm_skills = null //no restriction on what we can do.

//MONKEY
/mob/living/carbon/monkey/mind_initialize()
	..()

//XENO
/mob/living/carbon/Xenomorph/mind_initialize()
	..()
	mind.assigned_role = "MODE"
	mind.special_role = "Xenomorph"

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = "AI"

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = "Cyborg"

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"

/mob/living/simple_animal/construct/builder/mind_initialize()
	..()
	mind.assigned_role = "Artificer"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = "Cultist"

/mob/living/simple_animal/vox/armalis/mind_initialize()
	..()
	mind.assigned_role = "Armalis"
	mind.special_role = "Vox Raider"

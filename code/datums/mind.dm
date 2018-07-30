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




	proc/transfer_to(mob/living/new_character)
		if(!istype(new_character))
			world.log << "## DEBUG: transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform Carn"
		if(current)	current.mind = null	//remove ourself from our old body's mind variable

		if(new_character.mind) new_character.mind.current = null //remove any mind currently in our new body's mind variable
		nanomanager.user_transferred(current, new_character) // transfer active NanoUI instances to new user

		current = new_character		//link ourself to our new body
		new_character.mind = src	//and link our new body to ourself

		if(active)
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

		if(objectives.len>0)
			output += "<HR><B>Objectives:</B>"

			var/obj_count = 1
			for(var/datum/objective/objective in objectives)
				output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

		recipient << browse(output,"window=memory")

	proc/edit_memory()
		if(!ticker || !ticker.mode)
			alert("Not before round-start!", "Alert")
			return

		var/out = "<B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"
		out += "Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>"
		out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"
		out += "Factions and special roles:<br>"

		var/list/sections = list(
			"implant",
			"traitor",
		)
		var/text = ""
		var/mob/living/carbon/human/H = current
		if (istype(current, /mob/living/carbon/human) || istype(current, /mob/living/carbon/monkey))
			/** Impanted**/
			if(istype(current, /mob/living/carbon/human))
				if(H.is_loyalty_implanted(H))
					text = "Loyalty Implant:<a href='?src=\ref[src];implant=remove'>Remove</a>|<b>Implanted</b></br>"
				else
					text = "Loyalty Implant:<b>No Implant</b>|<a href='?src=\ref[src];implant=add'>Implant him!</a></br>"
			else
				text = "Loyalty Implant: Don't implant that monkey!</br>"
			sections["implant"] = text

		/** TRAITOR ***/
		text = "traitor"
		if (ticker.mode.config_tag=="traitor")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(istype(current, /mob/living/carbon/human))
			if (H.is_loyalty_implanted(H))
				text +="traitor|<b>LOYAL EMPLOYEE</b>"
			else
				if (src in ticker.mode.traitors)
					text += "<b>TRAITOR</b>|<a href='?src=\ref[src];traitor=clear'>Employee</a>"
					if (objectives.len==0)
						text += "<br>Objectives are empty! <a href='?src=\ref[src];traitor=autoobjectives'>Randomize</a>!"
				else
					text += "<a href='?src=\ref[src];traitor=traitor'>traitor</a>|<b>Employee</b>"
		sections["traitor"] = text

		out += "<br>"

		out += "<b>Memory:</b><br>"
		out += memory
		out += "<br><a href='?src=\ref[src];memory_edit=1'>Edit memory</a><br>"
		out += "Objectives:<br>"
		if (objectives.len == 0)
			out += "EMPTY<br>"
		else
			var/obj_count = 1
			for(var/datum/objective/objective in objectives)
				out += "<B>[obj_count]</B>: [objective.explanation_text] <a href='?src=\ref[src];obj_edit=\ref[objective]'>Edit</a> <a href='?src=\ref[src];obj_delete=\ref[objective]'>Delete</a> <a href='?src=\ref[src];obj_completed=\ref[objective]'><font color=[objective.completed ? "green" : "red"]>Toggle Completion</font></a><br>"
				obj_count++
		out += "<a href='?src=\ref[src];obj_add=1'>Add objective</a><br><br>"

		out += "<a href='?src=\ref[src];obj_announce=1'>Announce objectives</a><br><br>"

		usr << browse(out, "window=edit_memory[src]")

	Topic(href, href_list)
		if(!check_rights(R_ADMIN))	return

		if (href_list["role_edit"])
			var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in joblist
			if (!new_role) return
			assigned_role = new_role
			if(ishuman(current))
				var/mob/living/carbon/human/H = current
				if(H.mind)
					for(var/datum/job/J in get_all_jobs())
						if(J.title == new_role)
							H.mind.set_cm_skills(J.skills_type) //give new role's job_knowledge to us.
							H.mind.special_role = J.special_role
							H.mind.role_alt_title = J.get_alternative_title(src)
							H.mind.role_comm_title = J.comm_title
							break

		else if (href_list["memory_edit"])
			var/new_memo = copytext(sanitize(input("Write new memory", "Memory", memory) as null|message),1,MAX_MESSAGE_LEN)
			if (isnull(new_memo)) return
			memory = new_memo

		else if (href_list["obj_edit"] || href_list["obj_add"])
			var/datum/objective/objective
			var/objective_pos
			var/def_value

			if (href_list["obj_edit"])
				objective = locate(href_list["obj_edit"])
				if (!objective) return
				objective_pos = objectives.Find(objective)

				//Text strings are easy to manipulate. Revised for simplicity.
				var/temp_obj_type = "[objective.type]"//Convert path into a text string.
				def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
				if(!def_value)//If it's a custom objective, it will be an empty string.
					def_value = "custom"

			var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "debrain", "protect", "prevent", "harm", "brig", "hijack", "escape", "survive", "steal", "download", "nuclear", "capture", "absorb", "custom")
			if (!new_obj_type) return

			var/datum/objective/new_objective = null

			switch (new_obj_type)
				if ("assassinate","protect","debrain", "harm", "brig")
					//To determine what to name the objective in explanation text.
					var/objective_type_capital = uppertext(copytext(new_obj_type, 1,2))//Capitalize first letter.
					var/objective_type_text = copytext(new_obj_type, 2)//Leave the rest of the text.
					var/objective_type = "[objective_type_capital][objective_type_text]"//Add them together into a text string.

					var/list/possible_targets = list("Free objective")
					for(var/datum/mind/possible_target in ticker.minds)
						if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
							possible_targets += possible_target.current

					var/mob/def_target = null
					var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)
					if (objective&&(objective.type in objective_list) && objective:target)
						def_target = objective:target.current

					var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
					if (!new_target) return

					var/objective_path = text2path("/datum/objective/[new_obj_type]")
					if (new_target == "Free objective")
						new_objective = new objective_path
						new_objective.owner = src
						new_objective:target = null
						new_objective.explanation_text = "Free objective"
					else
						new_objective = new objective_path
						new_objective.owner = src
						new_objective:target = new_target:mind
						//Will display as special role if the target is set as MODE. Ninjas/commandos/nuke ops.
						new_objective.explanation_text = "[objective_type] [new_target:real_name], the [new_target:mind:assigned_role=="MODE" ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

				if ("survive")
					new_objective = new /datum/objective/survive
					new_objective.owner = src

				if ("steal")
					if (!istype(objective, /datum/objective/steal))
						new_objective = new /datum/objective/steal
						new_objective.owner = src
					else
						new_objective = objective
					var/datum/objective/steal/steal = new_objective
					if (!steal.select_target())
						return

				if("download","capture")
					var/def_num
					if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
						def_num = objective.target_amount

					var/target_number = input("Input target number:", "Objective", def_num) as num|null
					if (isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
						return

					switch(new_obj_type)
						if("download")
							new_objective = new /datum/objective/download
							new_objective.explanation_text = "Download [target_number] research levels."
						if("capture")
							new_objective = new /datum/objective/capture
							new_objective.explanation_text = "Accumulate [target_number] capture points."
					new_objective.owner = src
					new_objective.target_amount = target_number

				if ("custom")
					var/expl = stripped_input(usr, "Custom objective:", "Objective", objective ? objective.explanation_text : "",MAX_MESSAGE_LEN)
					if (!expl) return
					new_objective = new /datum/objective
					new_objective.owner = src
					new_objective.explanation_text = expl

			if (!new_objective) return

			if (objective)
				objectives -= objective
				objectives.Insert(objective_pos, new_objective)
			else
				objectives += new_objective

		else if (href_list["obj_delete"])
			var/datum/objective/objective = locate(href_list["obj_delete"])
			if(!istype(objective))	return
			objectives -= objective

		else if(href_list["obj_completed"])
			var/datum/objective/objective = locate(href_list["obj_completed"])
			if(!istype(objective))	return
			objective.completed = !objective.completed

		else if (href_list["traitor"])
			switch(href_list["traitor"])
				if("clear")
					if(src in ticker.mode.traitors)
						ticker.mode.traitors -= src
						special_role = null
						current.hud_set_special_role()
						current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a traitor!</B></FONT>"
						log_admin("[key_name_admin(usr)] has de-traitor'ed [current].")
						if(isAI(current))
							var/mob/living/silicon/ai/A = current
							A.set_zeroth_law("")
							A.show_laws()

				if("traitor")
					if(!(src in ticker.mode.traitors))
						ticker.mode.traitors += src
						special_role = "traitor"
						current.hud_set_special_role()
						current << "<B>\red You are a traitor!</B>"
						log_admin("[key_name_admin(usr)] has traitor'ed [current].")
						show_objectives()

						if(istype(current, /mob/living/silicon))
							var/mob/living/silicon/A = current
							call(/datum/game_mode/proc/add_law_zero)(A)
							A.show_laws()

				if("autoobjectives")
					if (!config.objectives_disabled)
						ticker.mode.forge_traitor_objectives(src)
						usr << "\blue The objectives for traitor [key] have been generated. You can edit them and anounce manually."

		else if (href_list["common"])
			switch(href_list["common"])
				if("undress")
					for(var/obj/item/W in current)
						current.drop_inv_item_on_ground(W)
				if("takeuplink")
					take_uplink()
					memory = null//Remove any memory they may have had.
				if("crystals")
					if (usr.client.holder.rights & R_FUN)
						var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink()
						var/crystals
						if (suplink)
							crystals = suplink.uses
						crystals = input("Amount of telecrystals for [key]","Syndicate uplink", crystals) as null|num
						if (!isnull(crystals))
							if (suplink)
								suplink.uses = crystals
				if("uplink")
					if (!ticker.mode.equip_traitor(current, !(src in ticker.mode.traitors)))
						usr << "\red Equipping a syndicate failed!"

		else if (href_list["obj_announce"])
			var/obj_count = 1
			current << "\blue Your current objectives:"
			for(var/datum/objective/objective in objectives)
				current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

		edit_memory()

	proc/find_syndicate_uplink()
		var/list/L = current.get_contents()
		for (var/obj/item/I in L)
			if (I.hidden_uplink)
				return I.hidden_uplink
		return null

	proc/take_uplink()
		var/obj/item/device/uplink/hidden/H = find_syndicate_uplink()
		if(H)
			cdel(H)

	proc/make_Traitor()
		if(!(src in ticker.mode.traitors))
			ticker.mode.traitors += src
			special_role = "traitor"
			if (!config.objectives_disabled)
				ticker.mode.forge_traitor_objectives(src)
			ticker.mode.finalize_traitor(src)
			ticker.mode.greet_traitor(src)

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
		cdel(cm_skills)
	cm_skills = new skills_path()



//Initialisation procs
/mob/proc/mind_initialize()
	if(mind) mind.key = key
	else
		mind = new /datum/mind(key)
		mind.original = src
		if(ticker) ticker.minds += mind
		else world.log << "## DEBUG: mind_initialize(): No ticker ready yet! Please inform Carn"
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
				for(var/datum/job/J in get_all_jobs())
					if(J.title == I.rank)
						mind.assigned_role = J.title
						mind.set_cm_skills(J.skills_type)
						mind.special_role = J.special_role
						mind.role_alt_title = J.get_alternative_title(src)
						mind.role_comm_title = J.comm_title
						break
	//if not, we give the mind default job_knowledge and assigned_role
	if(!mind.assigned_role)
		mind.assigned_role = "Squad Marine"	//default
		if(mind.cm_skills)
			cdel(mind.cm_skills)
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

/datum/tgs_chat_command/ahelp
	name = "ahelp"
	help_text = "<ckey|ticket #> <message|ticket <close|resolve|icissue|reject|reopen|tier <ticket #>|list>>"
	admin_only = TRUE


/datum/tgs_chat_command/ahelp/Run(datum/tgs_chat_user/sender, params)
	var/list/all_params = splittext(params, " ")
	if(length(all_params) < 2)
		return "Insufficient parameters"
	var/target = all_params[1]
	all_params.Cut(1, 2)
	var/id = text2num(target)
	if(id != null)
		var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(id)
		if(AH)
			target = AH.initiator_ckey
		else
			return "Ticket #[id] not found!"
	var/res = TgsPm(target, all_params.Join(" "), sender.friendly_name)
	return res


/datum/tgs_chat_command/namecheck
	name = "namecheck"
	help_text = "Returns info on the specified target"
	admin_only = TRUE


/datum/tgs_chat_command/namecheck/Run(datum/tgs_chat_user/sender, params)
	params = trim(params)
	if(!params)
		return "Insufficient parameters"
	log_admin("Chat Name Check: [sender.friendly_name] on [params]")
	message_admins("Name checking [params] from [sender.friendly_name]")
	return keywords_lookup(params, TRUE)


/datum/tgs_chat_command/adminwho
	name = "adminwho"
	help_text = "Lists administrators currently on the server"
	admin_only = TRUE


/datum/tgs_chat_command/adminwho/Run(datum/tgs_chat_user/sender, params)
	return tgsadminwho()


/datum/tgs_chat_command/validated/sdql
	name = "sdql"
	help_text = "Runs an SDQL query"
	admin_only = TRUE
	required_rights = R_DEBUG

/datum/tgs_chat_command/validated/sdql/Validated_Run(datum/tgs_chat_user/sender, params)
	var/list/results = HandleUserlessSDQL(sender.friendly_name, params)
	if(!results)
		return new /datum/tgs_message_content("Query produced no output")
	var/list/text_res = results.Copy(1, 3)
	var/list/refs = results.len > 3 ? results.Copy(4) : null
	return new /datum/tgs_message_content("[text_res.Join("\n")][refs ? "\nRefs: [refs.Join(" ")]" : ""]")


/datum/tgs_chat_command/reload_admins
	name = "reload_admins"
	help_text = "Forces the server to reload admins."
	admin_only = TRUE


/datum/tgs_chat_command/reload_admins/Run(datum/tgs_chat_user/sender, params)
	ReloadAsync()
	log_admin("[sender.friendly_name] reloaded admins via chat command.")
	message_admins("[sender.friendly_name] reloaded admins via chat command.")
	return "Admins reloaded."


/datum/tgs_chat_command/reload_admins/proc/ReloadAsync()
	set waitfor = FALSE
	load_admins()

/// subtype tgs chat command with validated admin ranks. Only supports discord.
/datum/tgs_chat_command/validated
	ignore_type = /datum/tgs_chat_command/validated
	admin_only = TRUE
	var/required_rights = 0 //! validate discord userid is linked to a game admin with these flags.

/// called by tgs
/datum/tgs_chat_command/validated/Run(datum/tgs_chat_user/sender, params)
	if (!CONFIG_GET(flag/secure_chat_commands) || CONFIG_GET(flag/admin_legacy_system) || !SSdbcore.Connect())
		return Validated_Run(sender, params)

	var/discord_id = SSdiscord.get_discord_id_from_mention(sender.mention) || sender.id
	if (!discord_id)
		return new /datum/tgs_message_content("Error: Unknown error trying to get your discord id.")

	var/datum/admins/linked_admin
	var/admin_ckey = ckey(SSdiscord.lookup_ckey(discord_id))

	if (admin_ckey)
		linked_admin = GLOB.admin_datums[admin_ckey] || GLOB.deadmins[admin_ckey]
	else
		return new /datum/tgs_message_content("Error: Could not find a linked ckey for your discord id.")

	if (!linked_admin)
		return new /datum/tgs_message_content("Error: Your linked ckey (`[admin_ckey]`) was not found in the admin list. If this is a mistake you can try `reload_admins`")

	if (!linked_admin.check_for_rights(required_rights))
		return new /datum/tgs_message_content("Error: Your linked ckey (`[admin_ckey]`) does not have sufficient rights to do that. You require one of the following flags: `[rights2text(required_rights," ")]`")

	return Validated_Run(sender, params)


/// Called if the sender passes validation checks or if those checks are disabled.
/datum/tgs_chat_command/validated/proc/Validated_Run(datum/tgs_chat_user/sender, params)
	RETURN_TYPE(/datum/tgs_message_content)
	CRASH("[type] has no implementation for Validated_Run()")

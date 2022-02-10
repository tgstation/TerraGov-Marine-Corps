GLOBAL_LIST_INIT(admin_approvals, list())

/*
admin_approval - This is a proc that is similar to do_after but waits until an admin replies or the delay time is reached. At which point the default_option is chosen and returned.datum

params
	admin_message = The message shown to every admin
	options = assoc list of options and their return value
	default_option = the option selected when no admins are online or the delay time is reached
	delay = the amount of time to wait for an admin to reply
	client/user = A client that may have initiated the proc
	user_message = a message to show to the user
	rank_required = bitflag of admin ranks to limit the admin that can reply to this message
	ignore_afk = should we ignore afk admins
	admin_sound = sound played to each admin

*/
/proc/admin_approval(admin_message = "", list/options = list("approve" = TRUE, "deny" = FALSE), default_option = "approve", delay = 60 SECONDS, client/user, user_message = "", rank_required = R_ADMIN, ignore_afk = FALSE, sound/admin_sound)
	. = options[default_option]

	if(!admin_message)
		stack_trace("admin_approval called without an admin_message")
		return

	var/list/active_admins = list()
	for(var/client/C in GLOB.admins)
		if((ignore_afk || !C.is_afk()) && check_other_rights(C, rank_required, FALSE))
			active_admins.Add(C)

	if(!length(active_admins)) // If no admin just return the default option
		log_admin("Admin Approval: '[admin_message]' was answered with [default_option] due to lack of online admin.")
		send2tgs_adminless_only("Approval", "'[admin_message]' was answered with [default_option] due to lack of online admin")
		return

	var/approval_id = num2text(UNIQUEID)
	if(GLOB.admin_approvals.Find(approval_id))
		CRASH("approval_id: [approval_id] is already in use.")

	GLOB.admin_approvals[approval_id] = -1
	for(var/client/C in active_admins)
		var/ref = "[REF(C.holder)];[HrefToken()]"
		var/admin_specific_options = ""
		for(var/opt in options)
			admin_specific_options += " <a href='byond://?src=[ref];adminapproval=[approval_id];option=[opt]'>\[[uppertext(opt)]\]</a>"
		admin_specific_options += " Default: [uppertext(default_option)] (after [delay / 10] seconds)"
		to_chat(C, span_admin("[span_prefix("APPROVAL REQUEST:")] <span class='message linkify'>[admin_message] | [admin_specific_options]</span>"))
		window_flash(C)
		if(admin_sound) // Additional send the sound if set
			SEND_SOUND(C, admin_sound)
	to_chat(user, user_message)

	var/endtime = world.time + delay
	while (world.time < endtime)
		stoplag(1)

		if(GLOB.admin_approvals[approval_id] != -1)
			. = options[GLOB.admin_approvals[approval_id]]
			break

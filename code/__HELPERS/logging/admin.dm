/* Items with ADMINPRIVATE prefixed are stripped from public logs. */

// For backwards compatibility these are currently also added to LOG_CATEGORY_GAME with their respective prefix
// This is to avoid breaking any existing tools that rely on the old format, but should be removed in the future

/// General logging for admin actions
/proc/log_admin(text, list/data)
	GLOB.admin_activities.Add(text)
	logger.Log(LOG_CATEGORY_ADMIN, text, data)
	logger.Log(LOG_CATEGORY_COMPAT_GAME, "ADMIN: [text]")

/// General logging for admin actions
/proc/log_admin_private(text, list/data)
	GLOB.admin_activities.Add(text)
	logger.Log(LOG_CATEGORY_ADMIN_PRIVATE, text, data)
	logger.Log(LOG_CATEGORY_COMPAT_GAME, "ADMINPRIVATE: [text]")

/// Logging for AdminSay (ASAY) messages
/proc/log_adminsay(text, list/data)
	GLOB.admin_activities.Add(text)
	logger.Log(LOG_CATEGORY_ADMIN_PRIVATE_ASAY, text, data)
	logger.Log(LOG_CATEGORY_COMPAT_GAME, "ADMINPRIVATE: ASAY: [text]")

/// Logging for MentorSay (MSAY) messages
/proc/log_mentorsay(text, list/data)
	GLOB.admin_activities.Add(text)
	logger.Log(LOG_CATEGORY_ADMIN_PRIVATE_MSAY, text, data)
	logger.Log(LOG_CATEGORY_COMPAT_GAME, "ADMINPRIVATE: MSAY: [text]")

/// Logging for DeadchatSay (DSAY) messages
/proc/log_dsay(text, list/data)
	logger.Log(LOG_CATEGORY_ADMIN_DSAY, text, data)
	logger.Log(LOG_CATEGORY_COMPAT_GAME, "ADMIN: DSAY: [text]")

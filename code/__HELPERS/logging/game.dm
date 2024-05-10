/// Logging for generic/unsorted game messages
/proc/log_game(text, list/data)
	logger.Log(LOG_CATEGORY_GAME, text, data)

/// Logging for emotes
/proc/log_emote(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_EMOTE, text, data)

/// Logging for hivemind messages
/proc/log_hivemind(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_HIVEMIND, text, data)

/// Logging for messages sent in OOC
/proc/log_ooc(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_OOC, text, data)

/// Logging for messages sent in LOOC
/proc/log_looc(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_LOOC, text, data)

/// Logging for messages sent in XOOC
/proc/log_xooc(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_XOOC, text, data)

/// Logging for messages sent in MOOC
/proc/log_mooc(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_MOOC, text, data)

/// Logging for prayed messages
/proc/log_prayer(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_PRAYER, text, data)

/// Logging for logging in & out of the game, with error messages.
/proc/log_access(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_ACCESS, text, data)

/// Logging for OOC votes
/proc/log_vote(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_VOTE, text, data)

/// Logging for drawing on minimap
/proc/log_minimap_drawing(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_MINIMAP_DRAWING, text, data)

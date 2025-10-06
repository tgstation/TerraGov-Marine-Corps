/datum/emote/dead/observer
	mob_type_allowed_typecache = /mob/dead/observer
	cooldown = 60 SECONDS
	emote_type = EMOTE_TYPE_VISIBLE
	stat_allowed = DEAD
	///icon file for the image to be displayed
	var/emote_icon = 'icons/misc/observer_emotes.dmi'
	///icon state for the image to be displayed
	var/emote_icon_state = null

/datum/emote/dead/observer/run_emote(mob/user)
	. = ..()
	if(!.)
		return
	var/image/emote_image = image(emote_icon, user, emote_icon_state)
	user.create_point_bubble(emote_image, FALSE)

/datum/emote/dead/observer/clueless
	key = "clueless"
	message = "looks clueless."
	emote_icon_state = "clueless"

/datum/emote/dead/observer/hmm
	key = "hmm"
	message = "hmms."
	emote_icon_state = "hmm"

/datum/emote/dead/observer/troll
	key = "troll"
	message = "trollfaces."
	emote_icon_state = "troll"

/datum/emote/dead/observer/true
	key = "true"
	message = "thinks thats so true..."
	emote_icon_state = "true"

/datum/emote/dead/observer/jawdrop
	key = "jawdrop"
	message = "jaw drops!"
	emote_icon_state = "jawdrop"

/datum/emote/dead/observer/acinema
	key = "acinema"
	message = "thinks it's peak."
	emote_icon_state = "acinema"

/datum/emote/dead/observer/xdd
	key = "xdd"
	message = "xdd"
	emote_icon_state = "xdd"

/datum/emote/dead/observer/bleak
	key = "bleak"
	message = "bleaks..."
	emote_icon_state = "bleak"

/datum/emote/dead/observer/uni
	key = "uni"
	message = "unis"
	emote_icon_state = "uni"

/datum/emote/dead/observer/soyjak
	key = "soyjak"
	message = "depicts you as a soyjak."
	emote_icon_state = "soyjak"

/datum/emote/dead/observer/jokerge
	key = "jokerge"
	message = "lives in a society."
	emote_icon_state = "jokerge"

/atom/movable/screen/text/screen_text/picture
	maptext_height = 64
	maptext_width = 480
	maptext_x = 66
	maptext_y = 32
	letters_per_update = 1
	fade_out_delay = 5 SECONDS
	screen_loc = "WEST:6,1:5"
	style_open = "<span class='maptext' style=font-size:20pt;text-align:left valign='top'>"
	style_close = "</span>"
	layer = INTRO_LAYER
	plane = ABOVE_HUD_PLANE
	///image that will display on the left of the screen alert
	var/image_to_play = "lrprr"
	///y offset of image
	var/image_to_play_offset_y = 32
	///x offset of image
	var/image_to_play_offset_x = 0

/atom/movable/screen/text/screen_text/picture/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/image/alertimage = image('icons/UI_Icons/screen_alert_images.dmi', icon_state = image_to_play, pixel_y = image_to_play_offset_y, pixel_x = image_to_play_offset_x)
	alertimage.appearance_flags = APPEARANCE_UI
	overlays += alertimage

/atom/movable/screen/text/screen_text/picture/tdf
	image_to_play = "tdf"

/atom/movable/screen/text/screen_text/picture/shokk
	image_to_play = "shokk"

/atom/movable/screen/text/screen_text/picture/saf_four
	image_to_play = "saf_4"

/atom/movable/screen/text/screen_text/picture/rapid_response
	image_to_play = "rapid_response"

/atom/movable/screen/text/screen_text/picture/blackop
	image_to_play = "blackops"

/atom/movable/screen/text/screen_text/picture/potrait
	screen_loc = "LEFT,TOP-3"
	image_to_play = "overwatch"
	image_to_play_offset_y = 0
	maptext_y = 0
	letters_per_update = 2

/atom/movable/screen/text/screen_text/picture/potrait/tgmc_req
	image_to_play = "req_tgmc"

/atom/movable/screen/text/screen_text/picture/potrait/pod_officer
	image_to_play = "pod_officer"

/atom/movable/screen/text/screen_text/picture/potrait/tgmc_mortar
	image_to_play = "mortar_team"

/atom/movable/screen/text/screen_text/picture/potrait/som_mortar
	image_to_play = "mortar_team_som"

/atom/movable/screen/text/screen_text/picture/potrait/som_over
	image_to_play = "overwatch_som"

/atom/movable/screen/text/screen_text/picture/potrait/som_req
	image_to_play = "req_som"

/atom/movable/screen/text/screen_text/picture/potrait/som_scientist
	image_to_play = "scientist_som"

/atom/movable/screen/text/screen_text/picture/potrait/unknown
	image_to_play = "overwatch_unknown"

/atom/movable/screen/text/screen_text/picture/potrait/pilot
	image_to_play = "cas"

/atom/movable/screen/text/screen_text/picture/potrait/som_pilot
	image_to_play = "cas_som"

//
/atom/movable/screen/text/screen_text/picture/potrait/icc_over
	image_to_play = "overwatch_icc"

/atom/movable/screen/text/screen_text/picture/potrait/militia_reinforcement
	image_to_play = "reinforcement_clf"

/atom/movable/screen/text/screen_text/picture/potrait/freelancer_reinforcement
	image_to_play = "reinforcement_fre"

/atom/movable/screen/text/screen_text/picture/potrait/robot_reinforcement
	image_to_play = "reinforcement_robot"

/atom/movable/screen/text/screen_text/picture/potrait/spec_reinforcement
	image_to_play = "reinforcement_spec"

/atom/movable/screen/text/screen_text/picture/potrait/pmc_reinforcement
	image_to_play = "reinforcement_pmc"

/atom/movable/screen/text/screen_text/picture/potrait/icc_reinforcement
	image_to_play = "reinforcement_icc"

/atom/movable/screen/text/screen_text/picture/potrait/som_reinforcement
	image_to_play = "reinforcement_som"

/atom/movable/screen/text/screen_text/picture/potrait/vsd_reinforcement
	image_to_play = "vsd_syndicate_red"

/atom/movable/screen/text/screen_text/picture/potrait/tgmc_distress
	image_to_play = "distress_tgmc"

/atom/movable/screen/text/screen_text/picture/potrait/som_distress
	image_to_play = "distress_som"

/atom/movable/screen/text/screen_text/picture/potrait/custom_mugshot
	image_to_play = "custom"

#define MAX_NON_COMMTITLE_LEN 9

/atom/movable/screen/text/screen_text/picture/potrait/custom_mugshot/Initialize(mapload, datum/hud/hud_owner, mob/living/mugshottee)
	. = ..()
	var/atom/movable/holding_movable = new
	holding_movable.appearance_flags = APPEARANCE_UI|KEEP_TOGETHER
	holding_movable.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/mutable_appearance/mugshot = mutable_appearance()
	mugshot.appearance = mugshottee.appearance
	mugshot.pixel_x = image_to_play_offset_x + 17
	mugshot.pixel_y = image_to_play_offset_y - 1 //scale shittery meant this didn't line up exactly without the -1
	mugshot.layer = layer+0.1
	SET_PLANE(mugshot, plane, src)
	mugshot.transform = matrix().Scale(3) //only need to scale once, although this can actually be after as well alpha filter stuff, makes no diff. we use a NEW matrix to also fix things like people lying down
	mugshot.dir = SOUTH

	var/mutable_appearance/alphafilter = mutable_appearance('icons/effects/alphacolors.dmi', "announcement")
	alphafilter.appearance_flags = APPEARANCE_UI
	alphafilter.render_target = "*mugshots"

	mugshot.overlays += alphafilter
	mugshot.filters += filter(arglist(alpha_mask_filter(0, 0, null, "*mugshots")))

	holding_movable.overlays += strip_appearance_underlays(mugshot)

	var/image/static_overlay = image('icons/UI_Icons/screen_alert_images.dmi', icon_state = image_to_play+"_static", pixel_y = image_to_play_offset_y, pixel_x = image_to_play_offset_x)
	static_overlay.appearance_flags = APPEARANCE_UI
	static_overlay.alpha = 75
	static_overlay.layer = layer+0.2
	SET_PLANE(static_overlay, plane, src)
	holding_movable.overlays += static_overlay

	var/mutable_appearance/mugshot_name = mutable_appearance()
	mugshot_name.appearance_flags = APPEARANCE_UI
	mugshot_name.maptext_width = 66 // 64 (the icon) + 1 buffer each side
	mugshot_name.maptext_x = -1
	mugshot_name.maptext_y = -1
	SET_PLANE(mugshot_name, plane, src)
	mugshot_name.layer = layer+0.3

	var/cleaned_realname = mugshottee.real_name
	var/firstname = copytext(cleaned_realname, 1, findtext(cleaned_realname, " "))
	var/lastname = trim(copytext(cleaned_realname, findtext(cleaned_realname, " ")))
	var/nametouse
	if(length(lastname) >= 1 && length(lastname) <= MAX_NON_COMMTITLE_LEN)
		nametouse = lastname
	else if(length(firstname) >= 1 && length(firstname) <= MAX_NON_COMMTITLE_LEN)
		nametouse = firstname
	else if(length(cleaned_realname) >= 1)
		if(length(cleaned_realname) > MAX_NON_COMMTITLE_LEN)
			//cleans too long clone names down to a better fitting length
			cleaned_realname = replacetext(cleaned_realname, regex(@"CS-.-"), "")
		nametouse = copytext(cleaned_realname, 1, MAX_NON_COMMTITLE_LEN+1)
	else
		nametouse = "UNKNOWN"
	var/user_name = trim(mugshottee.comm_title + " " + nametouse)
	mugshot_name.maptext = "<span class='maptext' style=font-size:6px;text-align:center>[user_name]</span>"

	holding_movable.overlays += mugshot_name

	vis_contents += holding_movable

#undef MAX_NON_COMMTITLE_LEN

/atom/movable/screen/text/screen_text/rightaligned
	screen_loc = "RIGHT,TOP-3"
	maptext_width = 480
	//equal to the width-32
	maptext_x = -448

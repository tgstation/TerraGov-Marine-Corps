/atom/movable/screen/ai
	icon = 'icons/mob/screen_ai.dmi'


/atom/movable/screen/ai/Click()
	if(isobserver(usr) || usr.incapacitated())
		return TRUE


/atom/movable/screen/ai/aicore
	name = "AI core"
	icon_state = "ai_core"


/atom/movable/screen/ai/aicore/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.view_core()


/atom/movable/screen/ai/camera_list
	name = "Show Camera List"
	icon_state = "camera"

/atom/movable/screen/ai/announcement
	name = "Make Vox Announcement"
	icon_state = "announcement"

/atom/movable/screen/ai/announcement/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.announcement()

/atom/movable/screen/ai/announcement_help
	name = "Vox Announcement Help"
	icon_state = "alerts"

/atom/movable/screen/ai/announcement_help/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.announcement_help()

/atom/movable/screen/ai/bioscan
	name = "Issue Manual Bioscan"
	icon_state = "bioscan"

/atom/movable/screen/ai/bioscan/Click()
	. = ..()
	if(.)
		return
	SSticker.mode.announce_bioscans(FALSE, GLOB.current_orbit, TRUE, FALSE, FALSE)

/atom/movable/screen/ai/camera_list/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.show_camera_list()


/atom/movable/screen/ai/camera_track
	name = "Track With Camera"
	icon_state = "track"


/atom/movable/screen/ai/camera_track/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	var/target_name = tgui_input_list(AI, "Choose who you want to track", "Tracking", AI.trackable_mobs())
	AI.ai_camera_track(target_name)


/atom/movable/screen/ai/camera_light
	name = "Toggle Camera Light"
	icon_state = "camera_light"


/atom/movable/screen/ai/camera_light/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.toggle_camera_light()


/atom/movable/screen/ai/multicam
	name = "Multicamera Mode"
	icon_state = "multicam"


/atom/movable/screen/ai/multicam/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.toggle_multicam()


/atom/movable/screen/ai/add_multicam
	name = "New Camera"
	icon_state = "new_cam"


/atom/movable/screen/ai/add_multicam/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.drop_new_multicam()


/datum/hud/ai/New(mob/owner, ui_style, ui_color, ui_alpha = 230)
	. = ..()
	var/atom/movable/screen/using

//AI core
	using = new /atom/movable/screen/ai/aicore()
	using.screen_loc = ui_ai_core
	static_inventory += using

//Camera list
	using = new /atom/movable/screen/ai/camera_list()
	using.screen_loc = ui_ai_camera_list
	static_inventory += using

//Track
	using = new /atom/movable/screen/ai/camera_track()
	using.screen_loc = ui_ai_track_with_camera
	static_inventory += using

//VOX
	using = new /atom/movable/screen/ai/announcement()
	using.screen_loc = ui_ai_announcement
	static_inventory += using

//VOX Help
	using = new /atom/movable/screen/ai/announcement_help()
	using.screen_loc = ui_ai_announcement_help
	static_inventory += using

//Camera light
	using = new /atom/movable/screen/ai/camera_light()
	using.screen_loc = ui_ai_camera_light
	static_inventory += using

//Multicamera mode
	using = new /atom/movable/screen/ai/multicam()
	using.screen_loc = ui_ai_multicam
	static_inventory += using

//Add multicamera camera
	using = new /atom/movable/screen/ai/add_multicam()
	using.screen_loc = ui_ai_add_multicam
	static_inventory += using

//bioscan
	using = new /atom/movable/screen/ai/bioscan()
	using.screen_loc = ui_ai_bioscan
	static_inventory += using

/atom/movable/screen/alert/ai_notify
	name = "Notification"
	desc = "A new notification. You can enter it."
	icon_state = "template"
	timeout = 15 SECONDS
	var/atom/target = null
	var/action = NOTIFY_AI_ALERT

/atom/movable/screen/alert/ai_notify/Click()
	var/mob/living/silicon/ai/recipientai = usr
	if(!istype(recipientai) || usr != owner)
		return
	if(!recipientai.client)
		return
	if(!target)
		return
	switch(action)
		if(NOTIFY_AI_ALERT)
			var/turf/T = get_turf(target)
			if(T)
				recipientai.eyeobj.setLoc(T)

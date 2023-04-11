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

/atom/movable/screen/ai/view_manifest
	name = "View Crew Manifest"
	icon_state = "manifest"


/atom/movable/screen/ai/view_manifest/Click()
	. = ..()
	if(.)
		return
	var/dat = GLOB.datacore.get_manifest()

	var/datum/browser/popup = new(usr, "manifest", "<div align='center'>Crew Manifest</div>", 370, 420)
	popup.set_content(dat)
	popup.open(FALSE)

/atom/movable/screen/ai/main_overwatch
	name = "Connect to Main Overwatch"
	icon_state = "overwatch"


/atom/movable/screen/ai/main_overwatch/Click()
	. = ..()
	if(.)
		return
	to_chat(usr, span_notice("Establishing connection to Main Overwatch..."))
	var/static/obj/machinery/computer/camera_advanced/overwatch/main/overwatch
	if(!overwatch || QDELETED(overwatch))
		stoplag()
		overwatch = locate(/obj/machinery/computer/camera_advanced/overwatch/main) in GLOB.machines

	if(!overwatch) //still no overwatch
		to_chat(usr, span_warning("Connection Failure! Main Overwatch missing."))
	else
		overwatch.interact(usr)
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

//Manifest
	using = new /atom/movable/screen/ai/view_manifest()
	using.screen_loc = ui_ai_manifest
	static_inventory += using

//Main Overwatch
	using = new /atom/movable/screen/ai/main_overwatch()
	using.screen_loc = ui_ai_mainoverwatch
	static_inventory += using
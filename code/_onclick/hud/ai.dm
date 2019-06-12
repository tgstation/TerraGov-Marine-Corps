/obj/screen/ai
	icon = 'icons/mob/screen_ai.dmi'


/obj/screen/ai/Click()
	if(isobserver(usr) || usr.incapacitated())
		return TRUE


/obj/screen/ai/aicore
	name = "AI core"
	icon_state = "ai_core"


/obj/screen/ai/aicore/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.view_core()


/obj/screen/ai/camera_list
	name = "Show Camera List"
	icon_state = "camera"


/obj/screen/ai/camera_list/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.show_camera_list()


/obj/screen/ai/camera_track
	name = "Track With Camera"
	icon_state = "track"


/obj/screen/ai/camera_track/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	var/target_name = input(AI, "Choose who you want to track", "Tracking") as null|anything in AI.trackable_mobs()
	AI.ai_camera_track(target_name)


/obj/screen/ai/camera_light
	name = "Toggle Camera Light"
	icon_state = "camera_light"


/obj/screen/ai/camera_light/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.toggle_camera_light()


/obj/screen/ai/multicam
	name = "Multicamera Mode"
	icon_state = "multicam"


/obj/screen/ai/multicam/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.toggle_multicam()


/obj/screen/ai/add_multicam
	name = "New Camera"
	icon_state = "new_cam"


/obj/screen/ai/add_multicam/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.drop_new_multicam()


/datum/hud/ai/New(mob/owner, ui_style, ui_color, ui_alpha = 230)
	. = ..()
	var/obj/screen/using

//AI core
	using = new /obj/screen/ai/aicore()
	using.screen_loc = ui_ai_core
	static_inventory += using

//Camera list
	using = new /obj/screen/ai/camera_list()
	using.screen_loc = ui_ai_camera_list
	static_inventory += using

//Track
	using = new /obj/screen/ai/camera_track()
	using.screen_loc = ui_ai_track_with_camera
	static_inventory += using

//Camera light
	using = new /obj/screen/ai/camera_light()
	using.screen_loc = ui_ai_camera_light
	static_inventory += using

//Multicamera mode
	using = new /obj/screen/ai/multicam()
	using.screen_loc = ui_ai_multicam
	static_inventory += using

//Add multicamera camera
	using = new /obj/screen/ai/add_multicam()
	using.screen_loc = ui_ai_add_multicam
	static_inventory += using
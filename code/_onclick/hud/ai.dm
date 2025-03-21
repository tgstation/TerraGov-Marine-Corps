/atom/movable/screen/ai
	icon = 'icons/mob/screen_ai.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER


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

/atom/movable/screen/ai/supply_interface
	name = "Supply Interface"
	icon_state = "pda"

/atom/movable/screen/ai/supply_interface/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.supply_interface()


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

/atom/movable/screen/ai/floor_indicator
	icon_state = "zindicator"
	screen_loc = ui_ai_floor_indicator

/atom/movable/screen/ai/floor_indicator/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(istype(hud_owner))
		RegisterSignal(hud_owner, COMSIG_HUD_OFFSET_CHANGED, PROC_REF(update_z))
		update_z()

/atom/movable/screen/ai/floor_indicator/proc/update_z(datum/hud/source)
	SIGNAL_HANDLER
	var/mob/living/silicon/ai/ai = hud?.mymob //if you use this for anyone else i will find you
	if(isnull(ai))
		return
	var/turf/locturf = isturf(ai.loc) ? get_turf(ai.eyeobj) : get_turf(ai) //must be a var cuz error
	var/ai_z = locturf.z
	var/text = "Floor<br/>[ai_z]"
	if(SSmapping.level_trait(ai_z, ZTRAIT_STATION))
		text = "Floor<br/>[ai_z - 1]"
	maptext = MAPTEXT_TINY_UNICODE("<div align='center' valign='middle' style='position:relative; top:0px; left:0px'>[text]</div>")

/atom/movable/screen/ai/go_up
	name = "go up"
	icon_state = "up"
	screen_loc = ui_ai_godownup

/atom/movable/screen/ai/go_up/Click(location,control,params)
	var/mob/ai = hud?.mymob //the core
	flick("uppressed",src)
	if(!isturf(ai.loc) || usr != ai) //aicard and stuff
		return
	ai.up()

/atom/movable/screen/ai/go_up/down
	name = "go down"
	icon_state = "down"

/atom/movable/screen/ai/go_up/down/Click(location,control,params)
	var/mob/ai = hud?.mymob //the core
	flick("downpressed",src)
	if(!isturf(ai.loc) || usr != ai) //aicard and stuff
		return
	ai.down()

/datum/hud/ai/New(mob/owner, ui_style, ui_color, ui_alpha = 230)
	. = ..()
	var/atom/movable/screen/using

//AI core
	using = new /atom/movable/screen/ai/aicore(null, src)
	using.screen_loc = ui_ai_core
	static_inventory += using

//Camera list
	using = new /atom/movable/screen/ai/camera_list(null, src)
	using.screen_loc = ui_ai_camera_list
	static_inventory += using

//Track
	using = new /atom/movable/screen/ai/camera_track(null, src)
	using.screen_loc = ui_ai_track_with_camera
	static_inventory += using

//VOX
	using = new /atom/movable/screen/ai/announcement(null, src)
	using.screen_loc = ui_ai_announcement
	static_inventory += using

//VOX Help
	using = new /atom/movable/screen/ai/announcement_help(null, src)
	using.screen_loc = ui_ai_announcement_help
	static_inventory += using

//Camera light
	using = new /atom/movable/screen/ai/camera_light(null, src)
	using.screen_loc = ui_ai_camera_light
	static_inventory += using

//Supply Interface
	using = new /atom/movable/screen/ai/supply_interface(null, src)
	using.screen_loc = ui_ai_supply
	static_inventory += using

//Multicamera mode
	using = new /atom/movable/screen/ai/multicam(null, src)
	using.screen_loc = ui_ai_multicam
	static_inventory += using

//Add multicamera camera
	using = new /atom/movable/screen/ai/add_multicam(null, src)
	using.screen_loc = ui_ai_add_multicam
	static_inventory += using

//bioscan
	using = new /atom/movable/screen/ai/bioscan(null, src)
	using.screen_loc = ui_ai_bioscan
	static_inventory += using

	using = new /atom/movable/screen/ai/floor_indicator(null, src) //These come with their own predefined screen locs
	static_inventory += using
	using = new /atom/movable/screen/ai/go_up(null, src)
	static_inventory += using
	using = new /atom/movable/screen/ai/go_up/down(null, src)
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

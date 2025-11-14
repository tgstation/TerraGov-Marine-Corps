//HUD styles.  Index order defines how they are cycled in F12.
/// Standard hud
#define HUD_STYLE_STANDARD 1
/// Reduced hud (just hands and intent switcher)
#define HUD_STYLE_REDUCED 2
/// No hud (for screenshots)
#define HUD_STYLE_NOHUD 3

/// Used in show_hud(); Please ensure this is the same as the maximum index.
#define HUD_VERSIONS 3

//defines for datum/hud
#define HUD_SL_LOCATOR_COOLDOWN 0.5 SECONDS
#define HUD_SL_LOCATOR_PROCESS_COOLDOWN 10 SECONDS

// Consider these images/atoms as part of the UI/HUD (apart of the appearance_flags)
/// Used for progress bars and chat messages
#define APPEARANCE_UI_IGNORE_ALPHA (RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|RESET_ALPHA|PIXEL_SCALE)
/// Used for HUD objects
#define APPEARANCE_UI (RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|PIXEL_SCALE)
#define APPEARANCE_UI_TRANSFORM (RESET_COLOR|NO_CLIENT_COLOR|RESET_ALPHA|PIXEL_SCALE)

/proc/ui_hand_position(i) //values based on old hand ui positions (CENTER:-/+16,SOUTH:5)
	var/x_off = i % 2 ? 0 : -1
	var/y_off = round((i-1) / 2)
	return"CENTER+[x_off]:16,SOUTH+[y_off]:5"

//Lower left, persistant menu
#define ui_inventory "WEST:6,1:5"

//Lower center, persistant menu
#define ui_sstore1 "WEST+2:10,1:5"
#define ui_id "WEST+3:12,1:5"
#define ui_belt "WEST+4:14,1:5"
#define ui_back "WEST+5:14,1:5"
#define ui_rhand "WEST+6:16,1:5"
#define ui_lhand "WEST+7:16,1:5"
#define ui_swaphand1 "WEST+6:16,2:5"
#define ui_swaphand2 "WEST+7:16,2:5"
#define ui_storage1 "WEST+8:18,1:5"
#define ui_storage2 "WEST+9:20,1:5"

//Lower right, persistant menu
#define ui_drop_throw "EAST-1:28,SOUTH+1:7"
#define ui_acti "EAST-3:24,SOUTH:5"
#define ui_above_movement "EAST-2:26,SOUTH+1:7"
#define ui_above_intent "EAST-3:24, SOUTH+1:7"
#define ui_movi "EAST-2:26,SOUTH:5"
#define ui_zonesel "EAST-1:28,SOUTH:5"
#define ui_acti_alt "EAST-1:28,1:5" //alternative intent switcher for when the interface is hidden (F12)
#define ui_crafting "EAST-4:22,SOUTH:5"
#define ui_language_menu "EAST-4:6,SOUTH:21"

//Upper-middle right (alerts)
#define ui_alert1 "EAST-1:28,CENTER+5:27"
#define ui_alert2 "EAST-1:28,CENTER+4:25"
#define ui_alert3 "EAST-1:28,CENTER+3:23"
#define ui_alert4 "EAST-1:28,CENTER+2:21"
#define ui_alert5 "EAST-1:28,CENTER+1:19"
#define ui_combo "CENTER+1:19,CENTER+4:25"

//Middle right (status indicators)
#define UI_STAMINA "EAST-1:28,CENTER-2:13"
#define ui_health "EAST-1:28,CENTER-1:15"
#define ui_ammo1 "EAST-1:28,CENTER+1:25"
#define ui_ammo2 "EAST-1:28,CENTER+2:27"
#define ui_ammo3 "EAST-1:28,CENTER+3:29"
#define ui_ammo4 "EAST-1:28,CENTER+4:31"

#define ui_alien_nightvision "EAST-1:28,5:13"
#define ui_alien_health "EAST-1:28,6:13" //aliens have the health display where humans have the bodytemp indicator.
#define ui_queen_locator "EAST-1:28,7:13"
#define ui_alienplasmadisplay "EAST-1:28,8:13"

//Pop-up inventory
#define ui_shoes "WEST+1:8,1:5"

#define ui_iclothing "WEST:6,2:7"
#define ui_oclothing "WEST+1:8,2:7"
#define ui_gloves "WEST+2:10,2:7"
#define ui_glasses "WEST:6,3:9"
#define ui_mask "WEST+1:8,3:9"
#define ui_wear_ear "WEST+2:10,3:9"
#define ui_head "WEST+1:8,4:11"

#define ui_sl_dir "CENTER,CENTER"

// Ghosts
#define ui_ghost_base(horizontal_offset, vertical_offset) "SOUTH" + vertical_offset + ":6" + ",CENTER" + horizontal_offset + ":24"

#define ui_ghost_slot1 ui_ghost_base("-3", "")
#define ui_ghost_slot2 ui_ghost_base("-2", "")
#define ui_ghost_slot3 ui_ghost_base("-1", "")
#define ui_ghost_slot4 ui_ghost_base("", "")
#define ui_ghost_slot5 ui_ghost_base("+1", "")

// AI
#define ui_ai_core "SOUTH:6,WEST"
#define ui_ai_camera_list "SOUTH:6,WEST+1"
#define ui_ai_track_with_camera "SOUTH:6,WEST+2"
#define ui_ai_camera_light "SOUTH:6,WEST+3"
#define ui_ai_announcement "SOUTH:6,WEST+4"
#define ui_ai_announcement_help "SOUTH:6,WEST+5"
#define ui_ai_supply "SOUTH:6,WEST+6"
#define ui_ai_bioscan "SOUTH:6,WEST+7"
#define ui_ai_multicam "SOUTH:6,WEST+17"
#define ui_ai_add_multicam "SOUTH:6,WEST+18"
#define ui_ai_floor_indicator "BOTTOM+5,RIGHT"
#define ui_ai_godownup "BOTTOM+5,RIGHT-1"

// Plane group keys, used to group swaths of plane masters that need to appear in subwindows
/// The primary group, holds everything on the main window
#define PLANE_GROUP_MAIN "main"
/// A secondary group, used when a client views a generic window
#define PLANE_GROUP_POPUP_WINDOW(screen) "popup-[REF(screen)]"

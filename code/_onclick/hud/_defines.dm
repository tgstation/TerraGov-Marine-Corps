/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	The size of the user's screen is defined by client.view (indirectly by WORLD_VIEW), in our case "15x15".
	Therefore, the top right corner (except during admin shenanigans) is at "15,15"
*/

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
#define ui_language_menu "EAST-4:6,SOUTH:21"

//Upper-middle right (alerts)
#define ui_alert1 "EAST-1:28,CENTER+5:27"
#define ui_alert2 "EAST-1:28,CENTER+4:25"
#define ui_alert3 "EAST-1:28,CENTER+3:23"
#define ui_alert4 "EAST-1:28,CENTER+2:21"
#define ui_alert5 "EAST-1:28,CENTER+1:19"

//Upper-middle right (damage indicators)
#define ui_toxin "EAST-1:28,13:27"
#define ui_fire "EAST-1:28,12:25"
#define ui_oxygen "EAST-1:28,11:23"
#define ui_pressure "EAST-1:28,10:21"

//Middle right (status indicators)
#define ui_nutrition "EAST-1:28,5:11"
#define ui_temp "EAST-1:28,6:13"
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
#define ui_ghost_slot2 "SOUTH:6,CENTER-1:24"
#define ui_ghost_slot3 "SOUTH:6,CENTER:24"

// AI
#define ui_ai_core "SOUTH:6,WEST"
#define ui_ai_camera_list "SOUTH:6,WEST+1"
#define ui_ai_track_with_camera "SOUTH:6,WEST+2"
#define ui_ai_camera_light "SOUTH:6,WEST+3"
#define ui_ai_announcement "SOUTH:6,WEST+4"
#define ui_ai_announcement_help "SOUTH:6,WEST+5"
#define ui_ai_bioscan "SOUTH:6,WEST+6"
#define ui_ai_multicam "SOUTH:6,WEST+17"
#define ui_ai_add_multicam "SOUTH:6,WEST+18"

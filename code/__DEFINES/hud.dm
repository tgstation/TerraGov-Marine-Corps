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

/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	In addition, the keywords NORTH, SOUTH, EAST, WEST and CENTER can be used to represent their respective
	screen borders. NORTH-1, for example, is the row just below the upper edge. Useful if you want your
	UI to scale with screen size.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "15x15".
	Therefore, the top right corner (except during admin shenanigans) is at "15,15"
*/

/*/proc/ui_hand_position(i) //values based on old hand ui positions (CENTER:-/+16,SOUTH:5)
	var/x_off = i % 2 ? 0 : -1
	var/y_off = round((i-1) / 2)
	return"CENTER+[x_off]:16,SOUTH+[y_off]:5"

/proc/ui_equip_position(mob/M)
	var/y_off = round((M.held_items.len-1) / 2) //values based on old equip ui position (CENTER: +/-16,SOUTH+1:5)
	return "CENTER:-16,SOUTH+[y_off+1]:5"

/proc/ui_swaphand_position(mob/M, which = 1) //values based on old swaphand ui positions (CENTER: +/-16,SOUTH+1:5)
	var/x_off = which == 1 ? -1 : 0
	var/y_off = round((M.held_items.len-1) / 2)
	return "CENTER+[x_off]:16,SOUTH+[y_off+1]:5"*/ //These are from TG, not sure if they are needed Xander

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
#define ui_dropbutton "EAST-4:22,1:5"
#define ui_drop_throw "EAST-1:28,SOUTH+1:7"
#define ui_acti "EAST-3:24,SOUTH:5"
#define ui_above_movement "EAST-2:26,SOUTH+1:7"
#define ui_above_intent "EAST-3:24, SOUTH+1:7"
#define ui_movi "EAST-2:26,SOUTH:5"
#define ui_zonesel "EAST-1:28,SOUTH:5"
#define ui_acti_alt "EAST-1:28,1:5" //alternative intent switcher for when the interface is hidden (F12)
#define ui_crafting "EAST-4:22,SOUTH:5"
#define ui_building "EAST-4:22,SOUTH:21"
#define ui_language_menu "EAST-4:6,SOUTH:21"

#define ui_borg_pull "EAST-3:24,2:7"
#define ui_borg_module "EAST-2:26,2:7"
#define ui_borg_panel "EAST-1:28,2:7"

//Gun buttons
#define ui_gun1 "EAST-2:26,3:7"
#define ui_gun2 "EAST-1:28, 4:7"
#define ui_gun3 "EAST-2:26,4:7"
#define ui_gun_select "EAST-1:28,3:7"

#define ui_gun_burst "EAST-3:-8,1:+5"
#define ui_gun_railtoggle "EAST-3:-21,1:+13"
#define ui_gun_eject "EAST-3:-12,1:+5"
#define ui_gun_attachment "EAST-3:-10,1:+5"
#define ui_gun_unique "EAST-3:-4,1:+2"

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

#define ui_alien_toxin "EAST-1:28,13:25"
#define ui_alien_fire "EAST-1:28,12:25"
#define ui_alien_oxygen "EAST-1:28,11:25"
#define ui_alien_resist "EAST-4:20,1:5"

//Middle right (status indicators)
#define ui_nutrition "EAST-1:28,5:11"
#define ui_temp "EAST-1:28,6:13"
#define ui_healthdoll "EAST-1:28,CENTER-3:11"
#define UI_STAMINA "EAST-1:28,CENTER-2:13"
#define ui_health "EAST-1:28,CENTER-1:15"
#define ui_internal "EAST-1:28,CENTER:17"
#define ui_ammo1 "EAST-1:28,CENTER+1:25"
#define ui_ammo2 "EAST-1:28,CENTER+2:27"
#define ui_ammo3 "EAST-1:28,CENTER+3:29"
#define ui_ammo4 "EAST-1:28,CENTER+4:31"

									//borgs
#define ui_borg_health "EAST-1:28,6:13" //borgs have the health display where humans have the bodytemp indicator.
#define ui_borg_temp "EAST-1:28,10:21"	//borgs have the bodytemp display where humans have the pressure indicator.
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
#define ui_ghost_slot1 "SOUTH:6,CENTER-2:24"
#define ui_ghost_slot2 "SOUTH:6,CENTER-1:24"
#define ui_ghost_slot3 "SOUTH:6,CENTER:24"
#define ui_ghost_slot4 "SOUTH:6,CENTER+1:24"
#define ui_ghost_slot5 "SOUTH:6,CENTER+2:24"

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


//////////// FROM TG, Probably not needed, but can't hurt to have

//Middle left indicators
#define ui_lingchemdisplay "WEST,CENTER-1:15"
#define ui_lingstingdisplay "WEST:6,CENTER-3:11"

//Lower center, persistent menu
#define ui_combo "CENTER+4:24,SOUTH+1:7" //combo meter for martial arts

//Lower right, persistent menu
#define ui_combat_toggle "EAST-3:24,SOUTH:5"
#define ui_navigate_menu "EAST-4:22,SOUTH:5"

//Upper left (action buttons)
#define ui_action_palette "WEST+0:23,NORTH-1:5"
#define ui_action_palette_offset(north_offset) ("WEST+0:23,NORTH-[1+north_offset]:5")

#define ui_palette_scroll "WEST+1:8,NORTH-6:28"
#define ui_palette_scroll_offset(north_offset) ("WEST+1:8,NORTH-[6+north_offset]:28")

//Middle right (status indicators)
#define ui_mood "EAST-1:28,CENTER:21"
#define ui_spacesuit "EAST-1:28,CENTER-4:14"
#define ui_stamina "EAST-1:28,CENTER-3:14"

//Pop-up inventory
#define ui_ears "WEST+2:10,SOUTH+2:9"
#define ui_neck "WEST:6,SOUTH+2:9"

//Generic living
#define ui_living_pull "EAST-1:28,CENTER-3:15"
#define ui_living_healthdoll "EAST-1:28,CENTER-1:15"

//Monkeys
#define ui_monkey_head "CENTER-5:13,SOUTH:5"
#define ui_monkey_mask "CENTER-4:14,SOUTH:5"
#define ui_monkey_neck "CENTER-3:15,SOUTH:5"
#define ui_monkey_back "CENTER-2:16,SOUTH:5"

//Drones
#define ui_drone_drop "CENTER+1:18,SOUTH:5"
#define ui_drone_pull "CENTER+2:2,SOUTH:5"
#define ui_drone_storage "CENTER-2:14,SOUTH:5"
#define ui_drone_head "CENTER-3:14,SOUTH:5"

//Cyborgs
#define ui_borg_radio "EAST-1:28,SOUTH+1:7"
#define ui_borg_intents "EAST-2:26,SOUTH:5"
#define ui_borg_lamp "CENTER-3:16, SOUTH:5"
#define ui_borg_tablet "CENTER-4:16, SOUTH:5"
#define ui_inv1 "CENTER-2:16,SOUTH:5"
#define ui_inv2 "CENTER-1 :16,SOUTH:5"
#define ui_inv3 "CENTER :16,SOUTH:5"
#define ui_borg_store "CENTER+2:16,SOUTH:5"
#define ui_borg_camera "CENTER+3:21,SOUTH:5"
#define ui_borg_alerts "CENTER+4:21,SOUTH:5"
#define ui_borg_language_menu "CENTER+4:19,SOUTH+1:6"
#define ui_borg_navigate_menu "CENTER+4:19,SOUTH+1:6"

//Aliens
#define ui_alien_queen_finder "EAST,CENTER-3:15"
#define ui_alien_storage_r "CENTER+1:18,SOUTH:5"
#define ui_alien_language_menu "EAST-4:20,SOUTH:5"
#define ui_alien_navigate_menu "EAST-4:20,SOUTH:5"

//AI
#define ui_ai_shuttle "BOTTOM:6,RIGHT-3"
#define ui_ai_state_laws "BOTTOM:6,RIGHT-1"
#define ui_ai_mod_int "BOTTOM:6,RIGHT"
#define ui_ai_language_menu "BOTTOM+1:8,RIGHT-1:30"

#define ui_ai_crew_monitor "BOTTOM:6,CENTER-1"
#define ui_ai_crew_manifest "BOTTOM:6,CENTER"
#define ui_ai_alerts "BOTTOM:6,CENTER+1"

#define ui_ai_view_images "BOTTOM:6,LEFT+4"
#define ui_ai_sensor "BOTTOM:6,LEFT"
#define ui_ai_take_picture "BOTTOM+2:6,LEFT"


//pAI
#define ui_pai_software "SOUTH:6,WEST"
#define ui_pai_shell "SOUTH:6,WEST+1"
#define ui_pai_chassis "SOUTH:6,WEST+2"
#define ui_pai_rest "SOUTH:6,WEST+3"
#define ui_pai_light "SOUTH:6,WEST+4"
#define ui_pai_state_laws "SOUTH:6,WEST+5"
#define ui_pai_crew_manifest "SOUTH:6,WEST+6"
#define ui_pai_host_monitor "SOUTH:6,WEST+7"
#define ui_pai_internal_gps "SOUTH:6,WEST+8"
#define ui_pai_mod_int "SOUTH:6,WEST+9"
#define ui_pai_newscaster "SOUTH:6,WEST+10"
#define ui_pai_take_picture "SOUTH:6,WEST+11"
#define ui_pai_view_images "SOUTH:6,WEST+12"
#define ui_pai_radio "SOUTH:6,WEST+13"
#define ui_pai_language_menu "SOUTH+1:8,WEST+12:31"
#define ui_pai_navigate_menu "SOUTH+1:8,WEST+12:31"

//Ghosts
#define ui_ghost_spawners_menu "SOUTH:6,CENTER-3:24"
#define ui_ghost_orbit "SOUTH:6,CENTER-2:24"
#define ui_ghost_reenter_corpse "SOUTH:6,CENTER-1:24"
#define ui_ghost_teleport "SOUTH:6,CENTER:24"
#define ui_ghost_pai "SOUTH: 6, CENTER+1:24"
#define ui_ghost_minigames "SOUTH: 6, CENTER+2:24"
#define ui_ghost_language_menu "SOUTH: 22, CENTER+3:8"

//Blobbernauts
#define ui_blobbernaut_overmind_health "EAST-1:28,CENTER+0:19"

// Defines relating to action button positions

/// Whatever the base action datum thinks is best
#define SCRN_OBJ_DEFAULT "default"
/// Floating somewhere on the hud, not in any predefined place
#define SCRN_OBJ_FLOATING "floating"
/// In the list of buttons stored at the top of the screen
#define SCRN_OBJ_IN_LIST "list"
/// In the collapseable palette
#define SCRN_OBJ_IN_PALETTE "palette"
///Inserted first in the list
#define SCRN_OBJ_INSERT_FIRST "first"

// Plane group keys, used to group swaths of plane masters that need to appear in subwindows
/// The primary group, holds everything on the main window
#define PLANE_GROUP_MAIN "main"
/// A secondary group, used when a client views a generic window
#define PLANE_GROUP_POPUP_WINDOW(screen) "popup-[REF(screen)]"

/// The filter name for the hover outline
#define HOVER_OUTLINE_FILTER "hover_outline"

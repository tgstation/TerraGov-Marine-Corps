/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "15x15".
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
#define ui_equip "WEST+6:16,2:5"
#define ui_swaphand1 "WEST+6:16,2:5"
#define ui_swaphand2 "WEST+7:16,2:5"
#define ui_storage1 "WEST+8:18,1:5"
#define ui_storage2 "WEST+9:20,1:5"

#define ui_inv1 "WEST+5:16,1:5"			//borgs
#define ui_inv2 "WEST+6:16,1:5"			//borgs
#define ui_inv3 "WEST+7:16,1:5"			//borgs
#define ui_borg_store "WEST+8:16,1:5"	//borgs

#define ui_monkey_mask "WEST+4:14,1:5"	//monkey
#define ui_monkey_back "WEST+5:14,1:5"	//monkey

//Lower right, persistant menu
#define ui_dropbutton "EAST-4:22,1:5"
#define ui_drop_throw "EAST-1:28,2:7"
#define ui_pull_resist "EAST-2:26,2:7"
#define ui_acti "EAST-2:26,1:5"
#define ui_movi "EAST-3:24,1:5"
#define ui_zonesel "EAST-1:28,1:5"
#define ui_acti_alt "EAST-1:28,1:5" //alternative intent switcher for when the interface is hidden (F12)

#define ui_borg_pull "EAST-3:24,2:7"
#define ui_borg_module "EAST-2:26,2:7"
#define ui_borg_panel "EAST-1:28,2:7"

//Gun buttons
#define ui_gun1 "EAST-2:26,3:7"
#define ui_gun2 "EAST-1:28, 4:7"
#define ui_gun3 "EAST-2:26,4:7"
#define ui_gun_select "EAST-1:28,3:7"

#define ui_gun_burst 		"EAST-3:-8,1:+5"
#define ui_gun_railtoggle	"EAST-3:-21,1:+13"
#define ui_gun_eject 		"EAST-3:-12,1:+5"
#define ui_gun_attachment 	"EAST-3:-10,1:+5"
#define ui_gun_unique 		"EAST-3:-4,1:+2"

//Upper-middle right (damage indicators)
#define ui_toxin "EAST-1:28,13:27"
#define ui_fire "EAST-1:28,12:25"
#define ui_oxygen "EAST-1:28,11:23"
#define ui_pressure "EAST-1:28,10:21"

#define ui_alien_toxin "EAST-1:28,13:25"
#define ui_alien_fire "EAST-1:28,12:25"
#define ui_alien_oxygen "EAST-1:28,11:25"
#define ui_alien_resist "EAST-4:20,1:5"

#define ui_predator_power "EAST-1:28,9:13"

//Middle right (status indicators)
#define ui_nutrition "EAST-1:28,5:11"
#define ui_temp "EAST-1:28,6:13"
#define ui_health "EAST-1:28,7:15"
#define ui_internal "EAST-1:28,8:17"
#define ui_sl_locator "EAST-1:28,9:13"
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
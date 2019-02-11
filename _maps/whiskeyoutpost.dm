#if !defined(MAP_FILE)

        #include "..\maps\Z.01.Whiskey_Outpost_v2.dmm"
        #include "..\maps\Z.02.Admin_Level.dmm"
        #include "..\maps\Z.03.TGS_Theseus.dmm"
        #include "..\maps\Z.04.Low_Orbit.dmm"

        #define MAP_FILE "Z.01.Whiskey_Outpost_v2.dmm" //name of the main dmm file
        #define MAP_ID "whiskeyoutpost" //filename of this file without the .dm
        #define MAP_NAME "Whiskey Outpost" //friendly human readable name

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring Whiskey Outpost.

#endif
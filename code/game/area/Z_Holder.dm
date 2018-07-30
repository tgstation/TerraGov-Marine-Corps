////////////////////////////////////////////////////////////
// This is the Z-holder, which will do a LOT of things to //
// handle the fact that we have a shit-ton of maps.  Each //
// Layer will need to have this object in it's T-comm     //
// area. If you don't, you won't be able to manage things //
// like where gibbed bodies land, where beacons go, and   //
// which levels are "planets" and are unbreachable.       //
// Follow the format for the example, and set the vars as //
// Needed.                                                //
////////////////////////////////////////////////////////////


/obj/item/z_holder/
	name = "Default" //Name of the item
	var/MapName = "Default" //This should be the name of the map, without the Z.##
	desc = "Something you shouldn't be fucking with while the server is running." //This shouldn't be changed
	var/Planet = 0 //Set true if this is a planet, and the ground shouldn't "breach to space"
	var/Station = 0 //Set true if this is a station, and it should breach to space
	var/Sulaco = 0 //Set true if this is a deck of the Sulaco.
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "relay"
	unacidable = 1
	anchored = 1

/obj/item/z_holder/LV624   //Zlayer 1
	name = "LV-624 Z-Holder"
	MapName = "LV624"
	Planet = 1


/obj/item/z_holder/CentCom   //Zlayer 2
	name = "CentCom Z-Holder"
	MapName = "CentComm"
	Station = 1


/obj/item/z_holder/SulacoUpper   //Zlayer 3
	name = "Sulaco Upper Z-Holder"
	MapName = "PlaceholderSulaco"
	Station = 1


/obj/item/z_holder/SulacoLower   //Zlayer 4
	name = "Sulaco Lower Z-Holder"
	MapName = "SulacoBottom"
	Station = 1


/obj/item/z_holder/Space   //Zlayer 5
	name = "Space Z-holder"
	MapName = "Space"


/obj/item/z_holder/Halloween   //Zlayer 6
	name = "HauntedHouse Z-holder"
	MapName = "HauntedHouse"
	Planet = 1


/obj/item/z_holder/Prison   //Zlayer 7
	name = "Prison Z-holder"
	MapName = "Prison"
	Station = 1


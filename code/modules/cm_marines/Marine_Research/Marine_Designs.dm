//EDITING BY APOPHIS:  Non-Ripleys disabled, as well as mech suit weapons.

//This is an exentision of Designs.dm, focused on the alien stuff.


#define BIOPRINTER 32

/*
//TEMPLATE
datum/design						//Datum for object designs, used in construction
	var/name = "Name"					//Name of the created object.
	var/desc = "Desc"					//Description of the created object.
	var/id = "id"						//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/list/req_tech = list()			//IDs of that techs the object originated from and the minimum level requirements.
	var/reliability_mod = 0				//Reliability modifier of the device at it's starting point.
	var/reliability_base = 100			//Base reliability of a device before modifiers.
	var/reliability = 100				//Reliability of the device.
	var/build_type = null				//Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()			//List of materials. Format: "id" = amount.
	var/build_path = ""					//The file path of the object that gets created
	var/locked = 0						//If true it will spawn inside a lockbox with currently sec access
	var/category = null //Primarily used for Mech Fabricators, but can be used for anything
*/


datum/design/ChitinPlate
	name = "Chitin Armor Plate"
	desc = "Item that can be attached to Marine Armor to greatly increase defense at the expense of movement speed."
	id = "ChitinPlate"
	req_tech = list("Bio" = 2)
	build_type = BIOPRINTER
	materials = list("$blood" = 1, "$chitin" = 2, "$resin" = 2)
	build_path = "/obj/item/XenoItem/ChitinPlate"


datum/design/ResinPaste
	name = "Resin Paste"
	desc = "A paste which allows you to repair a broken helmet."
	id = "ResinPaste"
	req_tech = list("Bio" = 2)
	build_type = BIOPRINTER
	materials = list("$chitin" = 2, "$resin" = 2)
	build_path = "/obj/item/XenoItem/ResinPaste"

datum/design/AntiAcid
	name = "Anti-Acid Spray"
	desc = "Spraying this onto a surface will prevent it from being meltable by Xeno Acid."
	id = "AntiAcid"
	req_tech = list("Bio" = 2)
	build_type = BIOPRINTER
	materials = list("$blood" = 1, "$resin" = 2)
	build_path = "/obj/item/XenoItem/AntiAcid"
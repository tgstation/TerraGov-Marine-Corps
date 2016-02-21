//EDITING BY APOPHIS:  Non-Ripleys disabled, as well as mech suit weapons.

//This is an exentision of Designs.dm, focused on the alien stuff.


/*
#define	IMPRINTER	1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE	2	//New stuff. Uses glass/metal/chemicals
#define	AUTOLATHE	4	//Uses glass/metal only.
#define CRAFTLATHE	8	//Uses fuck if I know. For use eventually.
#define MECHFAB		16 //Remember, objects utilising this flag should have construction_time and construction_cost vars.*/ //FOR REFERENCE ONLY
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
	id = "chitinarm"
	req_tech = list("Bio" = 2)
	build_type = BIOPRINTER
	materials = list("$acidblood" = 1, "$chitin" = 2, "$xenomass" = 2)
	build_path = "/obj/item/XenoItem/ChitinPlate"



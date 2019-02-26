/datum/codex_entry/bodyscanner
	associated_paths = list(/obj/machinery/bodyscanner)
	mechanics_text = "The advanced scanner detects and reports internal injuries such as bone fractures, internal bleeding, and organ damage. \
	This is useful if you are about to perform surgery.<br>\
	<br>\
	Click your target with Grab intent, then click on the scanner to place them in it. Click the nearby terminal to scan. \
	Click the scanner to remove them.  You can enter the scanner yourself in a similar way, using the 'Enter Body Scanner' \
	verb."

/datum/codex_entry/cryocell
	associated_paths = list(/obj/machinery/atmospherics/components/unary/cryo_cell)
	mechanics_text = "The cryogenic chamber, or 'cryo', treats most damage types, most notably genetic damage. It also stabilizes patients \
	in critical condition by placing them in stasis, so they can be treated at a later time.<br>\
	<br>\
	In order for it to work, it must be loaded with chemicals, and the temperature of the solution must reach a certain point. \
	The most commonly used chemicals in the chambers are Cryoxadone and \
	Clonexadone. Clonexadone is more effective in treating all damage, including Genetic damage, but is otherwise functionally identical.<br>\
	<br>\
	Clicking the tube with a beaker full of chemicals in hand will place it in its storage to distribute when it is activated. Although it does come pre-loaded with an effective mix of chemicals.<br>\
	<br>\
	Click your target with Grab intent, then click on the tube, with an empty hand, to place them in it. Click the tube again to open the menu. \
	Press the button on the menu to activate it."

/datum/codex_entry/optable
	associated_paths = list(/obj/machinery/optable)
	mechanics_text = "Click your target with Grab intent, then click on the table with an empty hand, to place them on it.<br>Click+drag them onto the table after that to enable knockout function. <br>\
	<br> Requires an inserted tank of Anesthetic to perform knockout."

/datum/codex_entry/operating
	associated_paths = list(/obj/machinery/computer/operating)
	mechanics_text = "This console gives information on the status of the patient on the adjacent operating table, notably their consciousness."

/datum/codex_entry/sleeper
	associated_paths = list(/obj/machinery/sleeper)
	mechanics_text = "The sleeper allows you to clean the blood by means of dialysis, and to administer medication in a controlled environment.<br>\
	<br>\
	Click your target with Grab intent, then click on the sleeper to place them in it. Click the red console, with an empty hand, to open the menu. \
	Click 'Start Dialysis' to begin filtering unwanted chemicals from the occupant's blood. The beaker contained will begin to fill with their \
	contaminated blood, and will need to be emptied when full.<br>\
	<br>\
	You can also inject common medicines directly into their bloodstream.\
	<br>\
	Right-click the cell and click 'Eject Occupant' to remove them.  You can enter the cell yourself by right clicking and selecting 'Enter Sleeper'. \
	Note that you cannot control the sleeper while inside of it."

/datum/codex_entry/cryobag_furled
	associated_paths = list(/obj/item/bodybag/cryobag)
	mechanics_text = "This stasis bag will preserve the occupant, stopping most forms of harm from occuring, such as from oxygen \
	deprivation, irradiation, shock, and chemicals inside the occupant, at least until the bag is opened again.<br>\
	<br>\
	They are ideal for situations where someone may die \
	before being able to bring them back to safety, or if they are in a hostile enviroment, such as in vacuum or in a toxins leak, as \
	the bag will protect the occupant from most outside enviromental hazards. \
	<br>\
	You can use a health analyzer to scan the occupant's vitals without opening the bag by clicking the occupied bag with the analyzer."

/datum/codex_entry/cryobag_open
	associated_paths = list(/obj/item/bodybag/cryobag)
	mechanics_text = "This stasis bag will preserve the occupant, stopping most forms of harm from occuring, such as from oxygen \
	deprivation, irradiation, shock, and chemicals inside the occupant, at least until the bag is opened again.<br>\
	<br>\
	They are ideal for situations where someone may die \
	before being able to bring them back to safety, or if they are in a hostile enviroment, such as in vacuum or in a toxins leak, as \
	the bag will protect the occupant from most outside enviromental hazards. <br>\
	<br>\
	You can use a health analyzer to scan the occupant's vitals without opening the bag by clicking the occupied bag with the analyzer."

/datum/codex_entry/incision_management_system
	associated_paths = list(/obj/item/tool/surgery/scalpel/manager)
	mechanics_text = "This is the first tool for every surgery. When you target a persons bodypart while they are on a table, you can then click them \
	with this tool on help intent to prepare an incision on that selected body part. <br><br>\
	This tool is can also be used to remove Necotic tissue as step one in a chain of Incision Management System > Advanced Trauma Kit."

/datum/codex_entry/retractor
	associated_paths = list(/obj/item/tool/surgery/retractor)
	mechanics_text = "This is the tool for opening and closing parts of the body during surgery. If you saw open a ribcage or skuill, you can then open the ribcage or skull with this tool. \
	The same can be said about closing a ribcage or skull with this tool. When you are finished operating inside of the ribcage or skull, you can close the ribcage or skull with this tool. \
	Then you must repair your Circular Saw cut with the Bone Gel. <br><br>\
	This tool is also used to prepare incisions as the third step in the chain of Scalpel > Hemostat > Retractor. However it is recommended that you use the Incision Management System instead, if available. <br><br>\
	This tool is also used to prepare limbs for robotic limb attachment as step two in the chain of Incision Management System > Retractor > Cautery."

/datum/codex_entry/hemostat
	associated_paths = list(/obj/item/tool/surgery/hemostat)
	mechanics_text = "This is the tool for extracting objects from surgical incisions. With an already prepared incision, you can use this tool to extract shrapnel from limbs. <br><br>\
	This can also be used in the larvae extraction surgery as step four in the chain of Incision Management System > Saw > Retractor > Hemostat > Retractor > Bone Gel > Cautery. <br><br>\
	This can also be used to prepare incisions as the second step in the chain of Scalpel > Hemostat > Retractor."

/datum/codex_entry/cautery
	associated_paths = list(/obj/item/tool/surgery/cautery)
	mechanics_text = "This is the tool for finishing a surgery. When you apply this tool to a surgical incision, this will close the incision. <br><br>Please note: performing the cautery step will \
	leave your patient in whatever state they are in. Remember to finish your surgeries.<br><br>\
	The most common cause of being unable to cauterize a surgical incision is because the patients ribcage or skull is still open. Close it with the Retractor and apply Bone Gel to continue. <br><br>\
	This tool is also used to prepare limbs for robotic limb attachment as the final step in a chain of Incision Management System > Retractor > Cautery."

/datum/codex_entry/surgical_drill
	associated_paths = list(/obj/item/tool/surgery/surgicaldrill)
	mechanics_text = "This is the tool for creating cavities inside of your patients for implantation of devices. There are no such devices you can find or make in the game at current."

/datum/codex_entry/scalpel
	associated_paths = list(/obj/item/tool/surgery/scalpel)
	mechanics_text = "This is the tool for preparing incisions if you do not have access to an Incision Management System. <br>\
	This can be done as the first step in the chain of Scalpel > Hemostat > Retractor. \
	This tool is also used to remove Necrotic tissue as step one in a chain of Scalpel > Advanced Trauma Kit."

/datum/codex_entry/circular_saw
	associated_paths = list(/obj/item/tool/surgery/circular_saw)
	mechanics_text = "This is the tool for cutting through bone. This is important for working on internal organs in the chest or head. <br>\
	Open the ribcage or skull by targeting the chest or head as appropriate and following this three step chain of Incision Management System > Circular Saw > Retractor. <br><br>\
	This can also be used in the amputation surgery by targeting a limb (but not the head), on help intent and then applying the Circular Saw. <br><br>\
	You do not need to remove the entire limb for replacement if the patient is only missing a hand or foot. Perform the limb replacement surgery as normal \
	but target the hand or foot as appropriate."

/datum/codex_entry/bone_gel
	associated_paths = list(/obj/item/tool/surgery/bonegel)
	mechanics_text = "This is the tool for repairing broken or damaged bones. <br><br>\
	This tool is used to repair broken bones as step 2 in a chain of Incision Management System > Bone Gel > Bone Setter > Cautery. <br><br>\
	This tool is used to repair the ribcage or skull that had been sawed open as step two in a chain of Retractor > Bone Gel. <br><br>\
	Bones cannot be fixed and will rebreak if that limbs brute damage is over 40. Fix any internal bleeding and/or give your patient Bicaridine to reduce the brute damage."

/datum/codex_entry/FixOVein
	associated_paths = list(/obj/item/tool/surgery/FixOVein)
	mechanics_text = "This is the tool for repairing internal bleeding. This can be done in any open incision as step two in a chain of Incision Management System > FixOVein > Cautery. <br><br>\
	Important to note is that internal bleeding must be fixed before bone repair surgery can be performed. This is because bones continue to break if brute damage is over 40."

/datum/codex_entry/bone_setter
	associated_paths = list(/obj/item/tool/surgery/bonesetter)
	mechanics_text = "This is the tool that, when paired with Bone Gel, repairs broken bones. <br><br>\
	It is always behind the Bone Gel step. Bone Gel > Bone Setter."


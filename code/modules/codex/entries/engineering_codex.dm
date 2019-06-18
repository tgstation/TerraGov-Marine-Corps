/datum/codex_entry/apc
	associated_paths = list(/obj/machinery/power/apc)
	mechanics_text = "An APC (Area Power Controller) regulates and supplies backup power for the area they are in. Their power channels are divided \
	out into 'environmental' (Items that manipulate airflow and temperature), 'lighting' (the lights), and 'equipment' (Everything else that consumes power).  \
	Power consumption and backup power cell charge can be seen from the interface, further controls (turning a specific channel on, off or automatic, \
	toggling the APC's ability to charge the backup cell, or toggling power for the entire area via master breaker) first requires the interface to be unlocked \
	with an ID with Engineering access or by one of the station's robots or the artificial intelligence."

	antag_text = "This can be emagged to unlock it.  It will cause the APC to have a blue error screen. \
	Wires can be pulsed remotely with a signaler attached to it.  A powersink will also drain any APCs connected to the same wire the powersink is on."

/datum/codex_entry/inflatable_item
	associated_paths = list(/obj/item/inflatable)
	mechanics_text = "Inflate by using it in your hand.  The inflatable barrier will inflate on your tile.  To deflate it, use the 'deflate' verb."

/datum/codex_entry/inflatable_deployed
	associated_paths = list(/obj/structure/inflatable)
	mechanics_text = "To remove these safely, use the 'deflate' verb.  Hitting these with any objects will probably puncture and break it forever."

/datum/codex_entry/inflatable_door
	associated_paths = list(/obj/structure/inflatable/door)
	mechanics_text = "Click the door to open or close it.  It only stops air while closed.<br>\
	To remove these safely, use the 'deflate' verb.  Hitting these with any objects will probably puncture and break it forever."

/datum/codex_entry/welding_pack
	associated_paths = list(/obj/item/storage/backpack/marine/engineerpack)
	mechanics_text = "This pack acts as a portable source of welding fuel. Use a welder on it to refill its tank - but make sure it's not lit! You can use this kit on a fuel tank or appropriate reagent dispenser to replenish its reserves."
	lore_text = "The Shenzhen Chain of 2380 was an industrial accident of noteworthy infamy that occurred at Earth's L3 Lagrange Point. An apprentice welder, working for the Shenzhen Space Fabrication Group, failed to properly seal her fuel port, triggering a chain reaction that spread from laborer to laborer, instantly vaporizing a crew of fourteen. Don't let this happen to you!"
	antag_text = "In theory, you could hold an open flame to this pack and produce some pretty catastrophic results. The trick is getting out of the blast radius."
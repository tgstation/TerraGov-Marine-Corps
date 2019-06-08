//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/pod
	name = "Pod Launch Control"
	desc = "A controll for launching pods. Some people prefer firing Mechas."
	icon_state = "computer_generic"
	circuit = /obj/item/circuitboard/computer/pod
	var/id = 1.0
	var/timing = 0.0
	var/time = 30.0
	var/title = "Mass Driver Controls"

/obj/machinery/computer/pod/old
	icon_state = "old"
	name = "DoorMex Control Computer"
	title = "Door Controls"

/obj/machinery/computer/pod/old/syndicate
	name = "ProComp Executive IIc"
	desc = "The Syndicate operate on a tight budget. Operates external airlocks."
	title = "External Airlock Controls"

/obj/machinery/computer/pod/old/swf
	name = "Magix System IV"
	desc = "An arcane artifact that holds much magic. Running E-Knock 2.2: Sorceror's Edition"

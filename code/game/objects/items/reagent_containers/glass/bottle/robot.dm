
/obj/item/reagent_container/glass/bottle/robot
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	volume = 60
	var/reagent = ""


/obj/item/reagent_container/glass/bottle/robot/inaprovaline
	name = "internal inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle16"
	reagent = "inaprovaline"
	list_reagents = list("inaprovaline" = 60)


/obj/item/reagent_container/glass/bottle/robot/antitoxin
	name = "internal anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle17"
	reagent = "anti_toxin"
	list_reagents = list("anti_toxin" = 60)
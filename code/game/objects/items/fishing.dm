/obj/item/fishing
	name = "fishing prop"
	icon = 'icons/obj/items/fishing.dmi'
	icon_state = "worm"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/toys_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/toys_right.dmi',
		)
	force = 0

/obj/item/fishing/reel
	name = "red reel"
	desc = "A reel of red fishing wire."
	icon_state = "reel_red"

/obj/item/fishing/reel/blue
	name = "blue reel"
	desc = "A reel of blue fishing wire."
	icon_state = "reel_blue"

/obj/item/fishing/reel/white
	name = "white reel"
	desc = "A reel of white fishing wire."
	icon_state = "reel_white"

/obj/item/fishing/reel/green
	name = "green reel"
	desc = "A reel of green fishing wire."
	icon_state = "reel_green"

/obj/item/fishing/bait_can
	name = "bait can"
	desc = "What could be inside?"
	icon_state = "bait_can_closed"

/obj/item/fishing/bait_can/open
	desc = "Full of worms."
	icon_state = "bait_can_open"

/obj/item/fishing/bait_can/empty
	desc = "Its contents have been emptied."
	icon_state = "bait_can_empty"

/obj/item/fishing/hook
	name = "hook"
	desc = "It's very sharp and pointy at the end."
	icon_state = "hook"

/obj/item/fishing/hook/rescue
	name = "rescue hook"
	desc = "Contains double the hooks for more precision."
	icon_state = "rescue_hook"

/obj/item/fishing/worm
	name = "worm"
	desc = "It's still twitching."
	icon_state = "worm"

/obj/item/fishing/lure
	name = "lure"
	desc = "It's buyoant and has bait attached."
	icon_state = "lure"

/obj/item/fishing/rod
	name = "fishing rod"
	desc = "You can fish with this."
	icon_state = "fishing_rod"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/fishing_rod_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/fishing_rod_righthand.dmi',
	)
	worn_icon_state = "rod"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	force = 8
	w_class = WEIGHT_CLASS_HUGE

/obj/item/fishing/rod/telescopic
	name = "telescopic fishing rod"
	icon_state = "telescopic_fishing_rod"

/obj/item/fishing/fish
	name = "goldfish"
	desc = "It tastes funny."
	icon_state = "goldfish"
	force = 2

/obj/item/fishing/fish/guppy
	name = "guppyfish"
	desc = "It tastes weird."
	icon_state = "guppyfish"

/obj/item/fishing/fish/jelly
	name = "jellyfish"
	desc = "This one is slightly transparent."
	icon_state = "jellyfish"

/obj/item/fishing/fish/puffer
	name = "pufferfish"
	desc = "It is permanently swollen."
	icon_state = "pufferfish"

/obj/item/fishing/fish/lanternfish
	name = "lanternfish"
	desc = "Usually found in the depths of the ocean."
	icon_state = "lanternfish"

/obj/item/fishing/fish/crab
	name = "crab"
	desc = "It appears dead."
	icon_state = "crab"

/obj/item/fishing/fish/starfish
	name = "starfish"
	desc = "These ones are found on beaches."
	icon_state = "starfish"

/obj/item/fishing/fish/firefish
	name = "firefish"
	desc = "Has an exotic color."
	icon_state = "firefish"

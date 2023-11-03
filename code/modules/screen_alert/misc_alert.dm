/atom/movable/screen/text/screen_text/picture
	maptext_height = 64
	maptext_width = 480
	maptext_x = 66
	maptext_y = 32
	letters_per_update = 1
	fade_out_delay = 5 SECONDS
	screen_loc = "WEST:6,1:5"
	style_open = "<span class='maptext' style=font-size:20pt;text-align:left valign='top'>"
	style_close = "</span>"
	layer = INTRO_LAYER
	plane = INTRO_PLANE
	///image that will display on the left of the screen alert
	var/image_to_play = "lrprr"
	///y offset of image
	var/image_to_play_offset_y = 32
	///x offset of image
	var/image_to_play_offset_x = 0

/atom/movable/screen/text/screen_text/picture/Initialize(mapload)
	. = ..()
	overlays += image('icons/UI_Icons/screen_alert_images.dmi', icon_state = image_to_play, pixel_y = image_to_play_offset_y, pixel_x = image_to_play_offset_x)

/atom/movable/screen/text/screen_text/picture/tdf
	image_to_play = "tdf"

/atom/movable/screen/text/screen_text/picture/shokk
	image_to_play = "shokk"

/atom/movable/screen/text/screen_text/picture/saf_four
	image_to_play = "saf_4"

/atom/movable/screen/text/screen_text/picture/rapid_response
	image_to_play = "rapid_response"

/atom/movable/screen/text/screen_text/picture/blackop
	image_to_play = "blackops"

/atom/movable/screen/text/screen_text/picture/potrait
	screen_loc = "LEFT,TOP-3"
	image_to_play = "overwatch"
	image_to_play_offset_y = 0
	maptext_y = 0
	letters_per_update = 2

/atom/movable/screen/text/screen_text/picture/potrait/som_over
	image_to_play = "overwatch_som"

/atom/movable/screen/text/screen_text/picture/potrait/unknown
	image_to_play = "overwatch_unknown"

/atom/movable/screen/text/screen_text/picture/potrait/pilot
	image_to_play = "po"

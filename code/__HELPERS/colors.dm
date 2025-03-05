/// Blends together two colors (passed as 3 or 4 length lists) using the screen blend mode
/// Much like multiply, screen effects the brightness of the resulting color
/// Screen blend will always lighten the resulting color, since before multiplication we invert the colors
/// This makes our resulting output brighter instead of darker
/proc/blend_screen_color(list/first_color, list/second_color)
	var/list/output = new /list(4)

	// max out any non existant alphas
	if(length(first_color) < 4)
		first_color[4] = 255
	if(length(second_color) < 4)
		second_color[4] = 255

	// time to do our blending
	for(var/i in 1 to 4)
		output[i] = (1 - (1 - first_color[i] / 255) * (1 - second_color[i] / 255)) * 255
	return output

/// Used to blend together two different color cutoffs
/// Uses the screen blendmode under the hood, essentially just [/proc/blend_screen_color]
/// But paired down and modified to work for our color range
/// Accepts the color cutoffs as two 3 length list(0-100,...) arguments
/proc/blend_cutoff_colors(list/first_color, list/second_color)
	// These runtimes usually mean that either the eye or the glasses have an incorrect color_cutoffs
	ASSERT(first_color?.len == 3, "First color must be a 3 length list, received [json_encode(first_color)]")
	ASSERT(second_color?.len == 3, "Second color must be a 3 length list, received [json_encode(second_color)]")

	var/list/output = new /list(3)

	// Invert the colors, multiply to "darken" (actually lights), then uninvert to get back to what we want
	for(var/i in 1 to 3)
		output[i] = (1 - (1 - first_color[i] / 100) * (1 - second_color[i] / 100)) * 100

	return output

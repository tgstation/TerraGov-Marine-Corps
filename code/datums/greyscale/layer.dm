/datum/greyscale_layer
	///This is the layer type that is used to generate these greyscale layers. It should be the same as the typepath after the base type here.
	var/layer_type
	///The list of colors to be used.
	var/list/color_ids
	///The selected blend mode.
	var/blend_mode
	///This list is for converting json entries into the correct defines to be used on blend_mode
	var/static/list/blend_modes = list(
		"add" = ICON_ADD,
		"subtract" = ICON_SUBTRACT,
		"multiply" = ICON_MULTIPLY,
		"or" = ICON_OR,
		"overlay" = ICON_OVERLAY,
		"underlay" = ICON_UNDERLAY
	)

/datum/greyscale_layer/New(icon_file, list/json_data)
	color_ids = json_data["color_ids"]
	for(var/i in color_ids)
		if(!isnum(i))
			CRASH("Color ids must be a positive integer starting from 1, '[i]' is not valid. Make sure it is not quoted in the json configuration.")
	blend_mode = blend_modes[lowertext(json_data["blend_mode"])]

/// Used to actualy create the layer using the given colors
/// Do not override, use InternalGenerate instead
/datum/greyscale_layer/proc/Generate(list/colors, list/render_steps, datum/greyscale_config/parent)
	var/list/processed_colors = list()
	for(var/i in color_ids)
		processed_colors += colors[i]
	return InternalGenerate(processed_colors, render_steps, parent)

/datum/greyscale_layer/proc/InternalGenerate(list/colors, list/render_steps, datum/greyscale_config/parent)

////////////////////////////////////////////////////////
// Subtypes

/// The most basic greyscale layer; a layer which is created from a single icon_state in the given icon file
/datum/greyscale_layer/icon_state
	layer_type = "icon_state"
	///This is the icon that the layer should use
	var/icon/icon
	///This is the color id that should be used in the operation. It is the index of the correct color in the passed-in string.
	var/color_id


/datum/greyscale_layer/icon_state/New(icon_file, list/json_data, prefix)
	. = ..()
	if(isnull(blend_mode))
		CRASH("Greyscale config for [icon_file] is missing a blend mode on a layer.")
	var/icon_state = json_data["icon_state"]
	if(prefix && !json_data["ignore_prefix"])
		icon_state = prefix+icon_state
	if(!(icon_state in icon_states(icon_file)))
		CRASH("Configured icon state \[[icon_state]\] was not found in [icon_file]. Double check your json configuration.")
	icon = new(icon_file, icon_state)

	if(length(color_ids) > 1)
		CRASH("Icon state layers can not have more than one color id")

/datum/greyscale_layer/icon_state/InternalGenerate(list/colors, list/render_steps, datum/greyscale_config/parent)
	var/icon/new_icon = icon(icon)
	if(length(colors))
		new_icon.Blend(colors[1], ICON_MULTIPLY)
	return new_icon

/// A layer created by using another greyscale icon's configuration
/datum/greyscale_layer/reference
	layer_type = "reference"
	var/datum/greyscale_config/reference_config

/datum/greyscale_layer/reference/New(icon_file, list/json_data)
	. = ..()
	if(isnull(blend_mode))
		CRASH("Greyscale config for [icon_file] is missing a blend mode on a layer.")
	reference_config = SSgreyscale.configurations[json_data["reference_type"]]
	if(!reference_config)
		CRASH("An unknown greyscale configuration was given to a reference layer: [json_data["reference_type"]]")

/datum/greyscale_layer/reference/InternalGenerate(list/colors, list/render_steps, datum/greyscale_config/parent)
	return reference_config.Generate(colors.Join(), render_steps)



/datum/greyscale_layer/hyperscale
	layer_type = "hyperscale"
	///This is the list of colors in the given icon from darkest to lightest. The colors are converted to greyscale before sorting.
	var/list/icon_file_colors = list()
	///This is the icon of the layer
	var/icon/icon

/datum/greyscale_layer/hyperscale/Generate(list/colors, list/render_steps, datum/greyscale_config/parent)
	return InternalGenerate(colors, render_steps, parent)


/datum/greyscale_layer/hyperscale/New(icon_file, list/json_data, prefix)
	. = ..()
	var/icon_state = json_data["icon_state"]
	if(prefix && !json_data["ignore_prefix"])
		icon_state = prefix + icon_state
	if(!(icon_state in icon_states(icon_file)))
		CRASH("Configured icon state \"[icon_state]\" was not found in [icon_file]. Double check your json configuration.")
	icon = new(icon_file, icon_state)
	icon.GrayScale()
	var/w = icon.Width()
	var/h = icon.Height()
	for(var/dir in GLOB.alldirs)
		for(var/x = 1 to w)
			for(var/y = 1 to h)
				var/pixel = icon.GetPixel(x, y, dir = dir)
				if(isnull(pixel))
					continue
				pixel = copytext(pixel, 1, 8) // "#RRGGBB", no alpha
				if(pixel in icon_file_colors)
					continue
				icon_file_colors[pixel] = rgb2num(pixel)
	// sort ascending by red
	sortTim(icon_file_colors, cmp = /proc/cmp_list_numeric_asc, associative = TRUE, sortkey = 1)

/datum/greyscale_layer/hyperscale/InternalGenerate(list/colors, list/render_steps, datum/greyscale_config/parent)
	var/icon/new_icon = icon(icon)
	if(CHECK_BITFIELD(parent.greyscale_flags, HYPERSCALE_ALLOW_GREYSCALE) && length(colors) == 1)
		new_icon.Blend(colors[1], ICON_MULTIPLY)
		return new_icon
	if(length(icon_file_colors) > length(colors))
		CRASH("[src] set to Hyperscale, expected [length(icon_file_colors)], got [length(colors)].")

	for(var/icon_file_color in icon_file_colors)
		var/i = icon_file_colors.Find(icon_file_color)
		new_icon.SwapColor(icon_file_color, colors[i])
	return new_icon

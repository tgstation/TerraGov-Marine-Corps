#define MAX_PAINTING_ZOOM_OUT 3
#define MAX_COLORS_IN_PALETTE 14
#define MAX_DECAL_SIZE 32
#define MIN_DECAL_SIZE 5
#define MAX_DECAL_TAGS 5

// todo, rust pr, tguicore update, make it possible to select alpha

/datum/custom_decal
	///user displayed name for the decal
	var/name = "Untitled"
	///md5 hash for the decal, used as the identifier & filename
	var/md5

	///the creating ckey for admin purposes
	var/creator_ckey
	///the round this decal was created in, for admin purposes
	var/creation_round_id
	///list of tags on this decal
	var/list/tags = list()
	///the icon we loaded from disk
	var/icon/decal_icon
	///cached height of the decal icon
	var/height
	///cached width of the decal icon
	var/width
	///the number of times this decal has been favourited
	var/favourites = 0

	/**
	 * How big the grid cells that compose the painting are in the UI (multiplied by zoom).
	 * This impacts the size of the UI, so smaller values are generally better for bigger canvases and vice-versa
	 */
	var/pixels_per_unit = 9
	///how much zoom for the person looking
	var/zoom = 2
	///whether the user wants to be showing the grid currently
	var/show_grid = TRUE
	///list of the currently selected colors for drawing with
	var/list/palette = list()
	///the current selected color for drawing
	var/selected_color = "#ffffff"
	/// empty canvas color
	var/default_color = "#ffffff"
	var/finalized = FALSE
	/// width of the drawing grid as set by the user
	var/grid_width = MAX_DECAL_SIZE
	/// height of the drawing grid as set by the user
	var/grid_height = MAX_DECAL_SIZE
	/// list[x] = list(y, y) grid of colors representing the ui
	var/list/grid

///resets the color grid to the basic color
/datum/custom_decal/proc/reset_grid()
	grid = new/list(grid_width,grid_height)
	for(var/x in 1 to grid_width)
		for(var/y in 1 to grid_height)
			grid[x][y] = default_color

/datum/custom_decal/proc/finalize(name, client/user, list/tags = list())
	src.name = name
	src.tags = tags
	src.creator_ckey = user.ckey
	src.creation_round_id = GLOB.round_id

	var/image_data = get_data_string()
	md5 = md5(image_data)
	var/png_filename = "data/custom_decals/decal_[md5].png"

	//tivi todo this needs to support rgba ideally
	var/result = rustg_dmi_create_png(png_filename, "[grid_width]", "[grid_height]", image_data)
	if(result)
		CRASH("Error generating decal png : [result]")
	decal_icon = new(png_filename)

	height = grid_height
	width = grid_width
	finalized = TRUE

	SScustom_decals.save_decal(src)


/datum/custom_decal/proc/get_data_string()
	var/list/data = list()
	for(var/y in 1 to grid_height)
		for(var/x in 1 to grid_width)
			data += grid[x][y]
	return data.Join("")

/datum/custom_decal/ui_state(mob/user)
	return GLOB.always_state

/datum/custom_decal/ui_interact(mob/user, datum/tgui/ui)
	if(!length(grid))
		for(var/index in 1 to MAX_COLORS_IN_PALETTE)
			palette += COLOR_WHITE
		reset_grid()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canvas", name)
		ui.open()

/datum/custom_decal/ui_static_data(mob/user)
	. = ..()
	.["px_per_unit"] = pixels_per_unit
	.["max_zoom"] = MAX_PAINTING_ZOOM_OUT
	.["max_decal_size"] = MAX_DECAL_SIZE
	.["min_decal_size"] = MIN_DECAL_SIZE

/datum/custom_decal/ui_data(mob/user)
	. = ..()
	.["grid"] = grid
	.["zoom"] = zoom
	.["name"] = name
	.["author"] = user.ckey
	.["finalized"] = finalized
	.["editable"] = !finalized //Ideally you should be able to draw moustaches on existing paintings in the gallery but that's not implemented yet
	.["show_grid"] = show_grid
	.["grid_width"] = grid_width
	.["grid_height"] = grid_height
	.["paint_tool_color"] = selected_color
	for(var/color in palette)
		.["paint_tool_palette"] += list()
	var/list/painting_data = list()
	for(var/hexcolor in palette)
		painting_data += list(list(
			"color" = hexcolor,
			"is_selected" = hexcolor == selected_color
		))
	.["paint_tool_palette"] = painting_data

/datum/custom_decal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	switch(action)
		if("paint", "fill")
			if(finalized)
				return TRUE
			var/tool_color = selected_color
			if(!tool_color)
				return FALSE
			if(action == "fill")
				var/x = params["x"]
				var/y = params["y"]
				if(!canvas_fill(x, y, tool_color))
					return FALSE
			else
				var/list/data = params["data"]
				for(var/point in data)
					var/x = text2num(point["x"])
					var/y = text2num(point["y"])
					grid[x][y] = tool_color
			. = TRUE
		if("select_color")
			set_selected_color(params["selected_color"])
			. = TRUE
		if("select_color_from_coords")
			var/x = text2num(params["x"])
			var/y = text2num(params["y"])
			set_selected_color(grid[x][y])
			. = TRUE
		if("change_palette")
			//I'd have this done inside the signal, but that'd have to be asynced,
			//while we want the UI to be updated after the color is chosen, not before.
			var/chosen_color = input(user, "Pick new color", "Decal Painting", params["old_color"]) as color|null
			if(!chosen_color)
				return FALSE
			var/index = params["color_index"]
			var/was_selected_color = selected_color == palette[index]
			palette[index] = chosen_color
			if(was_selected_color)
				set_selected_color(chosen_color)
			. = TRUE
		if("toggle_grid")
			. = TRUE
			show_grid = !show_grid
		if("finalize")
			. = TRUE
			if(finalized)
				return FALSE
			var/name = tgui_input_text(user, "Decal Name", "Decal Name", max_length = 200, multiline = FALSE)
			if(!name)
				return FALSE
			var/filter_result = is_ic_filtered(name)
			if(filter_result)
				to_chat(user, span_warning("That name contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[name]\"</span>"))
				SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
				REPORT_CHAT_FILTER_TO_USER(user, filter_result)
				log_filter("Decal naming", name, filter_result)
				return FALSE
			var/list/tags = list()
			var/new_tag = tgui_input_text(user, "Would you like to add tags? Press cancel to not add any tags", "Add tags", max_length = 200)
			while(new_tag)
				var/tag_filter_result = is_ic_filtered(new_tag)
				if(tag_filter_result)
					to_chat(user, span_warning("That tag contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[new_tag]\"</span>"))
					SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
					REPORT_CHAT_FILTER_TO_USER(user, tag_filter_result)
					log_filter("Decal tagging", new_tag, tag_filter_result)
					new_tag = tgui_input_text(user, "Would you like to add tags? Press cancel to stop adding tags", "Add tags", max_length = 200)
					continue
				tags += new_tag
				if(length(tags) >= MAX_DECAL_TAGS)
					break
				new_tag = tgui_input_text(user, "Would you like to add tags? Press cancel to stop adding tags", "Add tags", max_length = 200)
			finalize(name, user.client, tags)
		if("zoom_in")
			. = TRUE
			zoom = min(zoom + 1, MAX_PAINTING_ZOOM_OUT)
		if("zoom_out")
			. = TRUE
			zoom = max(zoom - 1, 1)
		if("resize")
			var/new_height = params["new_height"]
			var/new_width = params["new_width"]
			if(!isnum(new_height) || new_height > MAX_DECAL_SIZE || new_height < MIN_DECAL_SIZE)
				return
			if(!isnum(new_width) || new_width > MAX_DECAL_SIZE || new_width < MIN_DECAL_SIZE)
				return
			grid_height = new_height
			grid_width = new_width
			reset_grid()

/datum/custom_decal/proc/set_selected_color(new_color)
	selected_color = new_color

/datum/custom_decal/serialize_list(list/options, list/semvers)
	. = ..()
	.["md5"] = md5
	.["name"] = name
	.["creator_ckey"] = creator_ckey
	.["creation_round_id"] = creation_round_id
	.["tags"] = tags
	.["width"] = width
	.["height"] = height
	.["favourites"] = favourites

	SET_SERIALIZATION_SEMVER(semvers, "1.0.0")

/datum/custom_decal/deserialize_list(list/json, list/options)
	. = ..()
	md5 = json["md5"]
	decal_icon = icon(file("data/custom_decals/decal_[md5].png"))
	name = json["name"]
	creator_ckey = json["creator_ckey"]
	creation_round_id = json["creation_round_id"]
	tags = json["tags"]
	width = json["width"]
	height = json["height"]
	favourites = json["favourites"]
	finalized = TRUE



///The pixel to the right matches the previous color we're flooding over
#define CANVAS_FILL_R_MATCH (1<<0)
///The pixel to the left matches the previous color we're flooding over
#define CANVAS_FILL_L_MATCH (1<<1)

//a macro for the stringized key for coordinates to check later
#define CANVAS_COORD(x, y) "[x]-[y]"
///queues a coordinate on the canvas for future cycles.
#define QUEUE_CANVAS_COORD(x, y, queue) \
	if(y && !queue[CANVAS_COORD(x, y)]) {\
		queue[CANVAS_COORD(x, y)] = list(x, y);\
	}

/**
 * A proc that adopts a span-based, 4-dir (correct me if I'm wrong) flood fill algorithm used
 * by the bucked tool in the UI, to facilitate coloring larger portions of the canvas.
 * If you have never used the bucket/flood tool on an image editor, I suggest you do it
 * now so you know what I'm basically talking about.
 *
 * @ param x The point on the x axys where we start flooding our canvas. The arg is later used to store the current x
 * @ param y The point on the y axys where we start flooding the canvas. The arg is later used to store the current y
 * @ param new_color The new color that floods over the old one
 */
/datum/custom_decal/proc/canvas_fill(x, y, new_color)
	var/prev_color = grid[x][y]
	//If the colors are the same, don't do anything.
	if(prev_color == new_color)
		return FALSE

	//The queue for coordinates to the right of the current line
	var/list/queue_right = list()
	//Inversely for those to our left
	var/list/queue_left = list()
	//Whether we're currently checking the right or left queue.
	var/go_right = TRUE

	//The current coordinates. The only reason this is outside the loop
	//is because we first go up, then reset our vertical position to just below
	//the starting position and go down from there.
	var/list/coords = list(x, y)

	//Basically, the way it works is that each cycle we first go up, then down until we
	//either reach the vertical borders of the raster or find a pixel that is not of the color we want
	//to flood. As we do this, we try to queue a minimum of coordinates to our
	//left and right to use for future cycles, moving horizontally in one direction until there are no
	//more queued coordinates for that dir. Then we turn around and repeat
	//until both left and right queues are completely empty.
	while(coords)
		//The current vertical line, the right and the left ones.
		var/list/curr_line = grid[x]
		var/list/right_line = x < grid_width ? grid[x+1] : null
		var/list/left_line = x > 1 ? grid[x-1] : null
		//the queue we're on, depending on direction
		var/list/curr_queue = go_right ? queue_right : queue_left
		//Instead of queueing every point to our left and right that shares our prevous color,
		//Causing a lot of empty cycles, we only queue an extremity of a vertical segment
		//delimited by pixels of other colors or the y boundaries of the raster. To do this,
		//we need to track where the segment (called line for simplicity) starts (or ends).
		var/r_line_start
		var/l_line_start

		//go up first (y = 1 is the upper border is)
		while(y >= 1 && curr_line[y] == prev_color)
			var/return_flags = canvas_scan_step(x, y, queue_left, queue_right, left_line, right_line, l_line_start, r_line_start, prev_color)
			if(return_flags & CANVAS_FILL_R_MATCH)
				r_line_start = y
			else
				r_line_start = null
			if(return_flags & CANVAS_FILL_L_MATCH)
				l_line_start = y
			else
				l_line_start = null
			curr_line[y] = new_color
			curr_queue -= CANVAS_COORD(x, y) //remove it from the queue if possible.
			y--

		//Any unqueued coordinate is queued and cleared before the next half of the cycle
		QUEUE_CANVAS_COORD(x + 1, r_line_start, queue_right)
		QUEUE_CANVAS_COORD(x - 1, l_line_start, queue_left)
		r_line_start = l_line_start = null

		//set y to the pixel immediately below the starting y
		y = coords[2] + 1

		//then go down (y = height is the bottom border)
		while(y <= grid_height && curr_line[y] == prev_color)
			var/return_flags = canvas_scan_step(x, y, queue_left, queue_right, left_line, right_line, l_line_start, r_line_start, prev_color)
			if(!(return_flags & CANVAS_FILL_R_MATCH))
				r_line_start = null
			else if(!r_line_start)
				r_line_start = y
			if(!(return_flags & CANVAS_FILL_L_MATCH))
				l_line_start = null
			else if(!l_line_start)
				l_line_start = y
			curr_line[y] = new_color
			curr_queue -= CANVAS_COORD(x, y)
			y++

		QUEUE_CANVAS_COORD(x + 1, r_line_start, queue_right)
		QUEUE_CANVAS_COORD(x - 1, l_line_start, queue_left)

		//Pick the next set of coords from the queue (and change direction if necessary)
		if(!length(curr_queue))
			var/list/other_queue = go_right ? queue_left : queue_right
			coords = other_queue[other_queue[1]]
			other_queue.Cut(1, 2)
			go_right = !go_right
		else
			coords = curr_queue[curr_queue[1]]
			curr_queue.Cut(1, 2)

		x = coords?[1]
		y = coords?[2]

	return TRUE

/**
 * The step of canvas_fill() that scans the pixels to the immediate right and left of our coord and see if they need to be queue'd or not.
 * Kept as a separate proc to reduce copypasted code.
 */
/proc/canvas_scan_step(x, y, list/queue_left, list/queue_right, list/left_line, list/right_line, left_pos, right_pos, prev_color)
	if(left_line)
		if(left_line[y] == prev_color)
			. += CANVAS_FILL_L_MATCH
		else
			QUEUE_CANVAS_COORD(x - 1, left_pos, queue_left)

	if(!right_line)
		return

	if(right_line[y] == prev_color)
		. += CANVAS_FILL_R_MATCH
	else
		QUEUE_CANVAS_COORD(x + 1, right_pos, queue_right)

#undef CANVAS_FILL_R_MATCH
#undef CANVAS_FILL_L_MATCH
#undef CANVAS_COORD
#undef QUEUE_CANVAS_COORD
#undef MAX_PAINTING_ZOOM_OUT
#undef MAX_COLORS_IN_PALETTE
#undef MAX_DECAL_SIZE
#undef MIN_DECAL_SIZE
#undef MAX_DECAL_TAGS

/**
 * Causes the passed atom / image to appear floating,
 * playing a simple animation where they move up and down by 2 pixels (looping)
 *
 * In most cases you should NOT call this manually, instead use [/datum/element/movetype_handler]!
 * This is just so you can apply the animation to things which can be animated but are not movables (like images)
 */
#define DO_FLOATING_ANIM(target, delay, pixel_offset) \
	animate(target, pixel_y = pixel_offset, time = delay, loop = -1, flags = ANIMATION_RELATIVE); \
	animate(pixel_y = -pixel_offset, time = delay, flags = ANIMATION_RELATIVE)

/**
 * Stops the passed atom / image from appearing floating
 * (Living mobs also have a 'body_position_pixel_y_offset' variable that has to be taken into account here)
 *
 * In most cases you should NOT call this manually, instead use [/datum/element/movetype_handler]!
 * This is just so you can apply the animation to things which can be animated but are not movables (like images)
 */
#define STOP_FLOATING_ANIM(target) \
	var/final_pixel_y = 0; \
	if(ismovable(target)) { \
		var/atom/movable/movable_target = target; \
		final_pixel_y = initial(movable_target.pixel_y); \
	}; \
	animate(target, pixel_y = final_pixel_y, time = 1 SECONDS)

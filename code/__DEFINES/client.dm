/// Checks if the given target is either a client or a mock client
#define IS_CLIENT_OR_MOCK(target) (istype(target, /client))

/// The minimum client BYOND build to disable screentip icons for.
#define MIN_BYOND_BUILD_DISABLE_SCREENTIP_ICONS 1657
/// The maximum client BYOND build to disable screentip icons for.
/// Update this whenever https://www.byond.com/forum/post/2967731 is fixed.
#define MAX_BYOND_BUILD_DISABLE_SCREENTIP_ICONS 1699

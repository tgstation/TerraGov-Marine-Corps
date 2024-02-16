//Greyscale flags


/*
This flag allows any hyperscale layers in a greyscale config to accept a single color input.
This will mean that the single color will just be applied with multiply.
This flag exists to allow functionality and disable any errors that come from not having enough colors given.
This way the color errors (which we want to catch mistakes) will only be disabled for specified greyscale configs.
*/
#define HYPERSCALE_ALLOW_GREYSCALE (1<<0)

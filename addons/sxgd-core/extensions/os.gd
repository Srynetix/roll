extends RefCounted
## OS extensions.
##
## Additional methods around OS related functionalities.

## Set the window size from a WIDTHxHEIGHT string.[br]
##
## Usage:
## [codeblock]
## SxOs.set_window_size_str("1280x720")
## [/codeblock]
static func set_window_size_str(window_size: String) -> void:
	var sz_split := window_size.split("x")
	var sz_vec := Vector2(int(sz_split[0]), int(sz_split[1]))
	DisplayServer.window_set_size(sz_vec)

## Detect if the current system is a mobile environment.[br]
##
## Usage:
## [codeblock]
## if SxOs.is_mobile():
##   print("Mobile !")
## [/codeblock]
static func is_mobile() -> bool:
	return OS.get_name() in ["Android", "iOS"]

## Detect if the current system is a web environment.
static func is_web() -> bool:
	return OS.get_name() in ["HTML5"]

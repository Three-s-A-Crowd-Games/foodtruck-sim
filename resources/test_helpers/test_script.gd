@tool
extends EditorScript


const IGNORE_CHARACTERS: Array = ["'"]
var ignore_characters_as_int = IGNORE_CHARACTERS.map(func(x:String): return x.to_utf8_buffer()[0])

func _run():
	print(ignore_characters_as_int)
	pass

extends XRToolsSceneBase

var thread = Thread.new()

func _ready():
	super._ready()
	
	print("Data entries: ", SliceManager._slice_data.size())
	thread.start(SliceManager.slice_all)
	

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		printt("size",SliceManager.slices_dic.size())


func _on_back_to_menu_button_back_to_menu_requested():
	exit_to_main_menu()

func _exit_tree():
	thread.wait_to_finish()

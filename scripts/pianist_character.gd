extends Control

@onready var head = $Head
@onready var r_arm = $RArm
@onready var l_arm = $LArm

func _ready():
	_start_animation()

func _start_animation():
	var tween = get_tree().create_tween().set_loops()
	
	# Swaying animation
	tween.tween_property(self, "position:y", position.y - 10, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y, 0.6).set_trans(Tween.TRANS_SINE)
	
	# Head nodding
	var head_tween = get_tree().create_tween().set_loops()
	head_tween.tween_property(head, "position:y", -38.0, 0.4).set_trans(Tween.TRANS_SINE)
	head_tween.tween_property(head, "position:y", -35.0, 0.4).set_trans(Tween.TRANS_SINE)
	
	# Arm swaying
	var r_arm_tween = get_tree().create_tween().set_loops()
	r_arm_tween.tween_property(r_arm, "rotation", deg_to_rad(20), 0.5).set_trans(Tween.TRANS_SINE)
	r_arm_tween.tween_property(r_arm, "rotation", deg_to_rad(-5), 0.5).set_trans(Tween.TRANS_SINE)
	
	var l_arm_tween = get_tree().create_tween().set_loops()
	l_arm_tween.tween_property(l_arm, "rotation", deg_to_rad(-20), 0.5).set_trans(Tween.TRANS_SINE)
	l_arm_tween.tween_property(l_arm, "rotation", deg_to_rad(5), 0.5).set_trans(Tween.TRANS_SINE)

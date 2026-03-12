extends Resource
class_name AttackFrameData

# startup: animation plays, hitbox inactive
@export var startup_frames: Array[int] = []

# active: hitbox is active
@export var active_frames: Array[int] = []

# recovery: animation plays, hitbox inactive
@export var recovery_frames: Array[int] = []

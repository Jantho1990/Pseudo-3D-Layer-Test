extends Spellcaster


onready var Hammer = get_parent()


var current_construct_spell = 'CreatePlatformConstruct' # temp hardcode until construct creation system is in place


func _input(event):
  if Input.is_action_just_pressed('cast'):
    if Hammer.throwing:
        switch_active_spell_by_name('TeleportSpell')
        cast()
  
  if Input.is_action_just_pressed('build_construct') and Hammer.throwing and not Hammer.meleeing:
    switch_active_spell_by_name(current_construct_spell)
    cast()


func _ready():
  GlobalSignal.listen('change_construct', self, '_on_Change_construct')


func _on_Change_construct(data):
  var construct_name = data.name
  current_construct_spell = 'Create' + construct_name

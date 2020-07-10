extends AudioStreamPlayer


class_name SoundPool


export(float) var delay = 0.0
export(int) var pool_size = 1
var delaying = false
var pool = []
var sound_index = 0

onready var delay_timer = Timer.new()


func _ready():
  delay_timer.connect('timeout', self, '_on_Delay_timer_timeout')
  add_child(delay_timer)
  for i in range(0, pool_size):
    var sound = create_sound()
    add_child(sound)
    pool.push_back(sound)
  
  if playing: play()


func _physics_process(delta):
  pass


func _on_Delay_timer_timeout():
  delaying = false


func create_sound():
  var sound = AudioStreamPlayer.new()
  sound.stream = stream
  sound.volume_db = volume_db
  sound.pitch_scale = pitch_scale
  sound.playing = playing
  sound.autoplay = autoplay
  sound.stream_paused = stream_paused
  sound.bus = bus
  sound.mix_target = mix_target
  return sound


func play(from_position : float = 0.0):
  if not delaying and pool.size() > 0:
    var sound = pool[sound_index]
    sound.play(from_position)
    playing = true
    sound_index = sound_index + 1 if sound_index < pool.size() - 1 else 0
    if delay > 0: start_delay()


func start_delay():
  delaying = true
  delay_timer.start(delay)


func stop():
  playing = false
  if pool.size() > 0:
    for sound in pool:
      sound.stop()


func set_volume_db(value : float):
  volume_db = value
  for sound in pool:
    sound.volume_db = value

extends CreateConstruct


func create_build_unit_data():
  var caster = Spellcaster.Caster

  return {
    'unit_name': 'PlatformConstruct',
    'pos': caster.Weapon.global_position + Vector2(0, 72), # hardcoding for now; should draw from construct build selector whenever that gets built
    'cost': cost
  }

extends Spell


class_name CreateConstruct


func effect():
  .effect()
  var caster = Spellcaster.Caster

  if caster.Weapon.throwing:
    Spellcaster.reduce_mana_total(cost)
    GlobalSignal.dispatch('build_unit', create_build_unit_data())


func create_build_unit_data():
  var caster = Spellcaster.Caster
  return {
    'unit_name': 'Construct',
    'pos': caster.Weapon.global_position, # hardcoding for now; should draw from construct build selector whenever that gets built
    'cost': cost
  }
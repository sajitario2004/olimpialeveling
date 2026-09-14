class Achievement {
  final String id;
  final String title;
  final String description;
  final String bonusDescription;
  final String icon;
  bool isUnlocked;
  bool isEquipped;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.bonusDescription,
    this.icon = '🏆',
    this.isUnlocked = false,
    this.isEquipped = false,
  });

  static List<Achievement> getDefaultAchievements() {
    return [
      Achievement(
        id: 'ach_despanchizado',
        title: 'El Despanchizado',
        description: 'Alcanza el Nivel Total 25 superando el estado inicial.',
        bonusDescription: '+2% XP en Abdominales y Oblicuos',
        icon: '🛡️',
      ),
      Achievement(
        id: 'ach_hierro',
        title: 'Devorador de Hierro',
        description: 'Levanta 80 kg o más en una serie de cualquier ejercicio.',
        bonusDescription: '+5% XP en Pecho y Espalda',
        icon: '⚔️',
      ),
      Achievement(
        id: 'ach_ares',
        title: 'Hijo de Ares',
        description: 'Mantén una racha de 7 días consecutivos cumpliendo misiones.',
        bonusDescription: '+5% XP General de Racha',
        icon: '🔥',
      ),
      Achievement(
        id: 'ach_espartano',
        title: 'Voluntad Espartana',
        description: 'Alcanza el rango SPARTAN (Nivel 220).',
        bonusDescription: '+8% XP en Piernas y Hombros',
        icon: '🔱',
      ),
      Achievement(
        id: 'ach_hercules',
        title: 'Fuerza Herclúlea',
        description: 'Lleva al menos 3 músculos a Nivel 30.',
        bonusDescription: '+10% XP en Brazos (Bíceps/Tríceps)',
        icon: '🦁',
      ),
      Achievement(
        id: 'ach_dios',
        title: 'Dios del Olimpo',
        description: 'Alcanza el Rango Supremo GOD OF OLIMPUS (Nivel 400).',
        bonusDescription: '+15% XP Divina en Todos los Músculos',
        icon: '👑',
      ),
    ];
  }
}

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
        title: 'Iniciado del Olimpo',
        description: 'Inicia tu consagración sagrada superando el estado mortal inicial.',
        bonusDescription: '+2% XP en Abdominales y Oblicuos',
        icon: '🏛️',
      ),
      Achievement(
        id: 'ach_hierro',
        title: 'Herrero de Hefesto',
        description: 'Levanta 80 kg o más en una serie forjada en la fragua divina.',
        bonusDescription: '+5% XP en Pecho y Espalda',
        icon: '⚒️',
      ),
      Achievement(
        id: 'ach_ares',
        title: 'Furia de Ares',
        description: 'Mantén una racha de 7 días consecutivos cumpliendo las pruebas sagradas.',
        bonusDescription: '+5% XP General de Racha',
        icon: '🔥',
      ),
      Achievement(
        id: 'ach_espartano',
        title: 'Poder de Poseidón',
        description: 'Alcanza el rango SPARTAN dominando la fuerza de las tempestades.',
        bonusDescription: '+8% XP en Piernas y Hombros',
        icon: '🔱',
      ),
      Achievement(
        id: 'ach_hercules',
        title: 'Trabajos de Heracles',
        description: 'Lleva al menos 3 músculos a Nivel 30 emulando la fuerza del semidiós.',
        bonusDescription: '+10% XP en Brazos (Bíceps/Tríceps)',
        icon: '🦁',
      ),
      Achievement(
        id: 'ach_dios',
        title: 'Elegido de Zeus',
        description: 'Alcanza el Rango Supremo GOD OF OLIMPUS y reclama el trono sagrado.',
        bonusDescription: '+15% XP Divina en Todos los Músculos',
        icon: '⚡',
      ),
    ];
  }
}

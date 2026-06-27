class SpecialtyLabels {
  SpecialtyLabels._();

  static const _map = {
    'GENERAL_PRACTICE': 'Médecine générale',
    'CARDIOLOGY': 'Cardiologie',
    'NEUROLOGY': 'Neurologie',
    'PEDIATRICS': 'Pédiatrie',
    'ONCOLOGY': 'Oncologie',
    'DERMATOLOGY': 'Dermatologie',
    'ORTHOPEDICS': 'Orthopédie',
    'PSYCHIATRY': 'Psychiatrie',
    'RADIOLOGY': 'Radiologie',
    'SURGERY': 'Chirurgie',
  };

  static String label(String? specialty) {
    if (specialty == null) return '—';
    return _map[specialty] ?? specialty.replaceAll('_', ' ');
  }
}

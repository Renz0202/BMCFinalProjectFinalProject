class ProductUtils {
  static const _brandKeywords = <String, List<String>>{
    'Yamaha': ['yamaha'],
    'Shure': ['shure'],
    'JBL': ['jbl'],
    'Pioneer': ['pioneer', 'ddj'],
    'Behringer': ['behringer', 'xenyx', 'xr'],
    'Sennheiser': ['sennheiser'],
    'AKG': ['akg'],
    'Audio-Technica': ['audio-technica', 'audiotechnica', 'at-'],
    'Mackie': ['mackie'],
    'RMB': ['rmb'],
    'RCF': ['rcf'],
    'TT Audio': ['tt audio', 'ttaudio', 'tt-audio'],
    'Lumos': ['lumos'],
  };

  static String detectBrand(String text) {
    final t = text.toLowerCase();
    for (final entry in _brandKeywords.entries) {
      for (final kw in entry.value) {
        if (t.contains(kw)) return entry.key;
      }
    }
    return '';
  }

  static String detectCategory(String text) {
    final t = text.toLowerCase();
    if (t.contains('mixer') || t.contains('mixing')) {
      return 'Mixer';
    }
    if (t.contains('microphone') || t.contains('mic')) {
      return 'Microphone';
    }
    if (t.contains('wireless')) {
      return 'Wireless System';
    }
    if (t.contains('subwoofer') || t.contains('sub')) {
      return 'Subwoofer';
    }
    if (t.contains('speaker')) {
      return 'Speaker';
    }
    if (t.contains('controller') || t.contains('dj')) {
      return 'DJ Controller';
    }
    if (t.contains('dmx')) {
      return 'DMX Controller';
    }
    if (t.contains('moving head') ||
        (t.contains('moving') && t.contains('head'))) {
      return 'Moving Head';
    }
    if (t.contains('par') || t.contains('led') || t.contains('wash')) {
      return 'LED Par';
    }
    if (t.contains('fog') || t.contains('smoke')) {
      return 'Fog Machine';
    }
    return 'Other';
  }

  static Map<String, String> deriveFields({
    required String name,
    String? description,
  }) {
    final cat = detectCategory('$name ${description ?? ''}');
    final brand = detectBrand('$name ${description ?? ''}');
    return {'category': cat, 'brand': brand};
  }

  /// Attempts to detect brand from a product/source URL.
  /// Simple domain-based mapping for known sources.
  static String detectBrandFromUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    final u = url.toLowerCase();
    if (u.contains('ph.yamaha.com')) return 'Yamaha';
    if (u.contains('rcf.it')) return 'RCF';
    if (u.contains('ttaudio.com')) return 'TT Audio';
    if (u.contains('jblstore.com')) return 'JBL';
    if (u.contains('facebook.com')) {
      if (u.contains('rmb')) return 'RMB';
      if (u.contains('lumos')) return 'Lumos';
    }
    return '';
  }
}

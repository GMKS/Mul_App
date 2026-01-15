/// Quote Model
/// Model for devotional quotes with religion-based content

class DevotionalQuote {
  final String id;
  final String text;
  final String religion;
  final String? source; // Scripture or author
  final String? author;
  final String language;
  final DateTime date;

  DevotionalQuote({
    required this.id,
    required this.text,
    required this.religion,
    this.source,
    this.author,
    required this.language,
    required this.date,
  });

  factory DevotionalQuote.fromJson(Map<String, dynamic> json) {
    return DevotionalQuote(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      religion: json['religion'] ?? '',
      source: json['source'],
      author: json['author'],
      language: json['language'] ?? 'en',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'religion': religion,
      'source': source,
      'author': author,
      'language': language,
      'date': date.toIso8601String(),
    };
  }

  /// Get predefined quotes by religion
  static List<DevotionalQuote> getPredefinedQuotes(String religion) {
    final now = DateTime.now();

    switch (religion.toLowerCase()) {
      case 'hinduism':
        return [
          DevotionalQuote(
            id: 'h1',
            text: 'You have the right to work, but never to the fruit of work.',
            religion: 'hinduism',
            source: 'Bhagavad Gita',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'h2',
            text: 'The mind is everything. What you think you become.',
            religion: 'hinduism',
            source: 'Upanishads',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'h3',
            text:
                'When meditation is mastered, the mind is unwavering like the flame of a lamp in a windless place.',
            religion: 'hinduism',
            source: 'Bhagavad Gita',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'h4',
            text: 'The soul is neither born, and nor does it die.',
            religion: 'hinduism',
            source: 'Bhagavad Gita',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'h5',
            text:
                'Perform your obligatory duty, because action is better than inaction.',
            religion: 'hinduism',
            source: 'Bhagavad Gita',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'h6',
            text: 'Let your aim be the good of all.',
            religion: 'hinduism',
            source: 'Rig Veda',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'h7',
            text: 'Truth alone triumphs.',
            religion: 'hinduism',
            source: 'Mundaka Upanishad',
            language: 'en',
            date: now,
          ),
        ];

      case 'islam':
        return [
          DevotionalQuote(
            id: 'i1',
            text: 'Indeed, with hardship comes ease.',
            religion: 'islam',
            source: 'Quran 94:6',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'i2',
            text: 'Be patient. Indeed, the promise of Allah is truth.',
            religion: 'islam',
            source: 'Quran 30:60',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'i3',
            text:
                'And whoever puts their trust in Allah, He will be enough for them.',
            religion: 'islam',
            source: 'Quran 65:3',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'i4',
            text:
                'The best among you are those who have the best manners and character.',
            religion: 'islam',
            source: 'Sahih Bukhari',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'i5',
            text: 'Kindness is a mark of faith.',
            religion: 'islam',
            source: 'Sahih Muslim',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'i6',
            text:
                'Do not let your difficulties fill you with anxiety; after all, it is only in the darkest nights that stars shine more brightly.',
            religion: 'islam',
            source: 'Ali ibn Abi Talib',
            author: 'Ali ibn Abi Talib',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'i7',
            text: 'Speak good or remain silent.',
            religion: 'islam',
            source: 'Sahih Bukhari',
            language: 'en',
            date: now,
          ),
        ];

      case 'christianity':
        return [
          DevotionalQuote(
            id: 'c1',
            text:
                'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.',
            religion: 'christianity',
            source: 'Jeremiah 29:11',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'c2',
            text: 'I can do all things through Christ who strengthens me.',
            religion: 'christianity',
            source: 'Philippians 4:13',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'c3',
            text: 'Love your neighbor as yourself.',
            religion: 'christianity',
            source: 'Mark 12:31',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'c4',
            text:
                'Be strong and courageous. Do not be afraid; do not be discouraged.',
            religion: 'christianity',
            source: 'Joshua 1:9',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'c5',
            text:
                'Faith is confidence in what we hope for and assurance about what we do not see.',
            religion: 'christianity',
            source: 'Hebrews 11:1',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'c6',
            text: 'The Lord is my shepherd; I shall not want.',
            religion: 'christianity',
            source: 'Psalm 23:1',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'c7',
            text: 'Trust in the Lord with all your heart.',
            religion: 'christianity',
            source: 'Proverbs 3:5',
            language: 'en',
            date: now,
          ),
        ];

      case 'sikhism':
        return [
          DevotionalQuote(
            id: 's1',
            text:
                'Even Kings and emperors with heaps of wealth and vast dominion cannot compare with an ant filled with the love of God.',
            religion: 'sikhism',
            source: 'Guru Granth Sahib',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 's2',
            text: 'There is but One God. His name is Truth; He is the Creator.',
            religion: 'sikhism',
            source: 'Guru Granth Sahib',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 's3',
            text:
                'From woman, man is born; within woman, man is conceived; to woman he is engaged and married.',
            religion: 'sikhism',
            source: 'Guru Nanak',
            author: 'Guru Nanak',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 's4',
            text: 'Conquer your mind and conquer the world.',
            religion: 'sikhism',
            source: 'Guru Nanak',
            author: 'Guru Nanak',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 's5',
            text: 'He who has no faith in himself can never have faith in God.',
            religion: 'sikhism',
            source: 'Guru Granth Sahib',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 's6',
            text:
                'Burn worldly love, rub the ashes and make ink of it, make the heart the pen, the intellect the writer.',
            religion: 'sikhism',
            source: 'Guru Nanak',
            author: 'Guru Nanak',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 's7',
            text: 'Recognize the whole human race as one.',
            religion: 'sikhism',
            source: 'Guru Gobind Singh',
            author: 'Guru Gobind Singh',
            language: 'en',
            date: now,
          ),
        ];

      case 'buddhism':
        return [
          DevotionalQuote(
            id: 'b1',
            text: 'Peace comes from within. Do not seek it without.',
            religion: 'buddhism',
            source: 'Buddha',
            author: 'Buddha',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'b2',
            text: 'The mind is everything. What you think you become.',
            religion: 'buddhism',
            source: 'Buddha',
            author: 'Buddha',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'b3',
            text:
                'Three things cannot be long hidden: the sun, the moon, and the truth.',
            religion: 'buddhism',
            source: 'Buddha',
            author: 'Buddha',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'b4',
            text:
                'Happiness will never come to those who fail to appreciate what they already have.',
            religion: 'buddhism',
            source: 'Buddha',
            author: 'Buddha',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'b5',
            text:
                'Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.',
            religion: 'buddhism',
            source: 'Buddha',
            author: 'Buddha',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'b6',
            text: 'You yourself must strive. The Buddhas only point the way.',
            religion: 'buddhism',
            source: 'Dhammapada',
            language: 'en',
            date: now,
          ),
          DevotionalQuote(
            id: 'b7',
            text:
                'Hatred does not cease by hatred, but only by love; this is the eternal rule.',
            religion: 'buddhism',
            source: 'Dhammapada',
            language: 'en',
            date: now,
          ),
        ];

      default:
        return [];
    }
  }
}

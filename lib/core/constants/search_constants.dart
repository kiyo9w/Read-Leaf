class SearchConstants {
  static const Map<String, String> typeValues = {
    'All': '',
    'Any Books': 'book_any',
    'Unknown Books': 'book_unknown',
    'Fiction Books': 'book_fiction',
    'Non-fiction Books': 'book_nonfiction',
    'Comic Books': 'book_comic',
    'Magazine': 'magazine',
    'Standards Document': 'standards_document',
    'Journal Article': 'journal_article'
  };

  static const Map<String, String> sortValues = {
    'Most Relevant': '',
    'Newest': 'newest',
    'Oldest': 'oldest',
    'Largest': 'largest',
    'Smallest': 'smallest',
  };

  static const List<String> fileTypes = ["All", "PDF", "Epub", "Cbr", "Cbz"];

  static const Map<String, List<String>> categoryQueries = {
    'Most Downloaded': [
      'Harry Potter',
      'The Lord of the Rings',
      'Rich Dad Poor Dad',
      'Think and Grow Rich',
      'The Alchemist',
      'Dune',
      'The Power of Now',
      '1984'
    ],
    'Top Romance': [
      'Pride and Prejudice',
      'The Notebook',
      'Outlander',
      'Me Before You',
      'The Fault in Our Stars',
      'The Time Traveler\'s Wife',
      'The Duke and I',
      'The Kiss Quotient'
    ],
    'Top Fiction': [
      'The Midnight Library',
      'Project Hail Mary',
      'The Seven Husbands of Evelyn Hugo',
      'The Silent Patient',
      'Where the Crawdads Sing',
      'The Thursday Murder Club',
      'The Invisible Life of Addie LaRue',
      'Klara and the Sun'
    ],
    'Top Non-Fiction': [
      'Atomic Habits',
      'The 48 Laws of Power',
      'The Psychology of Money',
      'The Body Keeps the Score',
      'Thinking, Fast and Slow',
      'Sapiens',
      'The Power of Habit',
      'Can\'t Hurt Me'
    ],
    'Top Self-Help': [
      'The Mountain Is You',
      'The Subtle Art of Not Giving a F*ck',
      'You Are a Badass',
      'The Four Agreements',
      'The 7 Habits of Highly Effective People',
      'Think Like a Monk',
      'Mindset: The New Psychology of Success',
      'The Power of Now'
    ],
    'Top Business': [
      'Zero to One',
      'Good to Great',
      'Start with Why',
      'Built to Last',
      'The Lean Startup',
      'Blue Ocean Strategy',
      'The E-Myth Revisited',
      'The Innovator\'s Dilemma'
    ],
    'Top Science': [
      'A Brief History of Time',
      'The Selfish Gene',
      'The Elegant Universe',
      'The Origin of Species',
      'The Grand Design',
      'The Hidden Life of Trees',
      'The Code Breaker',
      'The Immortal Life of Henrietta Lacks'
    ],
    'Top Fantasy': [
      'The Name of the Wind',
      'The Way of Kings',
      'The Final Empire',
      'The Priory of the Orange Tree',
      'A Game of Thrones',
      'The Eye of the World',
      'Gardens of the Moon',
      'The Black Prism'
    ]
  };

  static const List<String> topSearchQueries = [
    "The 48 Laws of Power",
    "Atomic Habits",
    "Control Your Mind and Master Your Feelings",
    "The Psychology of Money",
    "The Mountain Is You",
    "The Body Keeps the Score",
    "Think and Grow Rich",
    "Can't Hurt Me"
  ];

  static const List<String> trendingQueries = [
    "Project Hail Mary",
    "The Seven Husbands of Evelyn Hugo",
    "The Silent Patient",
    "Where the Crawdads Sing",
    "The Thursday Murder Club",
    "The Invisible Life of Addie LaRue",
    "Klara and the Sun",
    "The Midnight Library"
  ];
}

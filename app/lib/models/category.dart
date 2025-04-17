class Category {
  final String name;
  final String description;
  final List<String> examples;

  const Category({
    required this.name,
    required this.description,
    required this.examples,
  });
}

class Categories {
  static const List<Category> all = [
    Category(
      name: 'Programming & Tech',
      description: 'Technical skills in software development and technology',
      examples: [
        'Python',
        'Web Development',
        'Mobile App Development',
        'Data Science',
        'Machine Learning',
        "Java"
      ],
    ),
    Category(
      name: 'Culinary Skills',
      description: 'Cooking, baking, and beverage preparation',
      examples: [
        'Recipe Creation',
        'Drink Mixing',
        'Baking',
        'Meal Planning',
        'Food Presentation'
      ],
    ),
    Category(
      name: 'Creative Arts',
      description: 'Artistic and creative expression',
      examples: ['Sketching', 'Writing', 'Music', 'Photography', 'Digital Art'],
    ),
    Category(
      name: 'Lifestyle Skills',
      description: 'Personal development and daily life skills',
      examples: [
        'Time Management',
        'Journaling',
        'Meditation',
        'Organization',
        'Public Speaking'
      ],
    ),
    Category(
      name: 'Business & Productivity',
      description: 'Professional and business-related skills',
      examples: [
        'Marketing',
        'Entrepreneurship',
        'Project Management',
        'Financial Planning',
        'Leadership'
      ],
    ),
  ];
}

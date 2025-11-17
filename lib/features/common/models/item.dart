class Item {
  Item({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.price,
    required this.rooms,
    required this.image,
    required this.mapPreview,
    required this.preview3d,
    this.tags = const [],
    this.description,
    this.city = 'Riyadh',
  });

  final String id;
  final String name;
  final String location;
  final String type;
  final String price;
  final int rooms;
  final String image;
  final String mapPreview;
  final String preview3d;
  final List<String> tags;
  final String? description;
  final String city;
}

final mockItems = [
  Item(
    id: '1',
    name: 'Skyline Apartment',
    location: 'Downtown, Dubai',
    type: 'Apartment',
    price: '\$1,200,000',
    rooms: 3,
    image: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85',
    mapPreview: 'https://images.unsplash.com/photo-1505761671935-60b3a7427bad',
    preview3d: 'https://images.unsplash.com/photo-1465808892320-47a97059e571',
    tags: ['city', 'luxury', 'view'],
    description: 'Panoramic skyline views with a modern interior.',
    city: 'Dubai',
  ),
  Item(
    id: '2',
    name: 'Desert Villa',
    location: 'Al Ula, KSA',
    type: 'Villa',
    price: '\$980,000',
    rooms: 5,
    image: 'https://images.unsplash.com/photo-1505691938895-1758d7feb511',
    mapPreview: 'https://images.unsplash.com/photo-1505761671935-60b3a7427bad',
    preview3d: 'https://images.unsplash.com/photo-1470246973918-29a93221c455',
    tags: ['desert', 'private', 'pool'],
    description: 'Private desert villa with calm courtyards and pool.',
    city: 'Al Ula',
  ),
  Item(
    id: '3',
    name: 'Coastal Escape',
    location: 'Muscat, Oman',
    type: 'Beach House',
    price: '\$1,450,000',
    rooms: 4,
    image: 'https://images.unsplash.com/photo-1505691938895-1758d7feb511',
    mapPreview: 'https://images.unsplash.com/photo-1505761671935-60b3a7427bad',
    preview3d: 'https://images.unsplash.com/photo-1505691938895-1758d7feb511',
    tags: ['sea', 'relax', 'modern'],
    description: 'Beachfront escape with open living and natural light.',
    city: 'Muscat',
  ),
];

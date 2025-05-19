// lib/data/models/property_model.dart
class PropertyModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String landlordId;
  final List<String> imageUrls;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final bool isAvailable;
  final bool isFeatured; // Added featured flag
  final DateTime? createdAt;
  final DateTime? updatedAt; // Added last updated timestamp
  final List<String> amenities;
  final double? rating; // Added rating field
  final int? reviewCount; // Added review count

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.landlordId,
    this.imageUrls = const [],
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.area = 0,
    this.isAvailable = true,
    this.isFeatured = false, // Default to not featured
    this.createdAt,
    this.updatedAt,
    this.amenities = const [],
    this.rating,
    this.reviewCount,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String,
      landlordId: json['landlord_id'] as String,
      imageUrls: List<String>.from(json['image_urls'] as List? ?? []),
      bedrooms: json['bedrooms'] as int? ?? 1,
      bathrooms: json['bathrooms'] as int? ?? 1,
      area: (json['area'] as num?)?.toDouble() ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      amenities: List<String>.from(json['amenities'] as List? ?? []),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'landlord_id': landlordId,
      'image_urls': imageUrls,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'is_available': isAvailable,
      'is_featured': isFeatured,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'amenities': amenities,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  PropertyModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? location,
    String? landlordId,
    List<String>? imageUrls,
    int? bedrooms,
    int? bathrooms,
    double? area,
    bool? isAvailable,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? amenities,
    double? rating,
    int? reviewCount,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      landlordId: landlordId ?? this.landlordId,
      imageUrls: imageUrls ?? this.imageUrls,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      amenities: amenities ?? this.amenities,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  // Helper method to get the first image or placeholder
  String get primaryImage {
    return imageUrls.isNotEmpty 
        ? imageUrls.first
        : 'assets/images/placeholder_property.jpg';
  }

  // Helper method to format price for display
  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Helper method to check if property is new (added in last 7 days)
  bool get isNew {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inDays < 7;
  }
}
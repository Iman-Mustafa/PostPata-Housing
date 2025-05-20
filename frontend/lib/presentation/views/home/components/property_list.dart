// lib/presentation/views/home/components/property_list.dart
import 'package:flutter/material.dart';

import '../../../../core/widgets/cards/property_card.dart';
import '../../../../data/models/property_model.dart';
import '../../../router/route_names.dart';

class PropertyList extends StatelessWidget {
  final List<PropertyModel> properties;
  final bool isFeatured;
  final VoidCallback? onRefresh;

  const PropertyList({
    super.key,
    required this.properties,
    this.isFeatured = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return Center(
        child: Text('Hakuna nyumba zilizopatikana'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: isFeatured
          ? _buildFeaturedList()
          : _buildRegularList(),
    );
  }

  Widget _buildFeaturedList() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: properties.length,
        itemBuilder: (ctx, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == properties.length - 1 ? 16 : 8,
            ),
            child: PropertyCard(
              property: properties[index],
              isFeatured: true,
              onTap: () => _navigateToDetail(ctx, properties[index].id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegularList() {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (ctx, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: PropertyCard(
            property: properties[index],
            onTap: () => _navigateToDetail(ctx, properties[index].id),
          ),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, String propertyId) {
    Navigator.pushNamed(
      context,
      RouteNames.propertyDetailPath(propertyId),
    );
  }
}
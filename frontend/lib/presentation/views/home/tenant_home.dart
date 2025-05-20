// lib/presentation/views/home/tenant_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/property_controller.dart';
import 'components/bottom_nav.dart';
import 'components/property_list.dart';

class TenantHome extends StatelessWidget {
  const TenantHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nyumba Zilizopo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<PropertyController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.properties.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (controller.featuredProperties.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Nyumba Bora',
                    style: Theme.of(context).textTheme.titleLarge, // Updated
                  ),
                ),
              if (controller.featuredProperties.isNotEmpty)
                PropertyList(
                  properties: controller.featuredProperties,
                  isFeatured: true,
                ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Nyumba Zote',
                  style: Theme.of(context).textTheme.titleLarge, // Updated
                ),
              ),
              Expanded(
                child: PropertyList(
                  properties: controller.properties,
                  onRefresh: () => controller.loadProperties(),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
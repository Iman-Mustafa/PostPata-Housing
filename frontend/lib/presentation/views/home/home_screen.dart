// lib/features/home/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/property_controller.dart';
import 'components/bottom_nav.dart';
import 'components/property_list.dart';

class HomeScreen extends StatelessWidget {
  final Widget? floatingActionButton;

  const HomeScreen({
    Key? key,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final propertyController = Provider.of<PropertyController>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _navigateToSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _navigateToProfile(context),
          ),
        ],
      ),
      body: _buildBody(propertyController),
      bottomNavigationBar: const CustomBottomNav(),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildBody(PropertyController controller) {
    if (controller.isLoading && controller.allProperties.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null && controller.allProperties.isEmpty) {
      return Center(child: Text(controller.error!));
    }

    return Column(
      children: [
        if (controller.featuredProperties.isNotEmpty)
          SizedBox(
            height: 200,
            child: PropertyList(
              properties: controller.featuredProperties,
              isFeatured: true,
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.loadProperties(),
            child: PropertyList(
              properties: controller.allProperties,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToSearch(BuildContext context) {
    // Implement search navigation
  }

  void _navigateToProfile(BuildContext context) {
    // Implement profile navigation
  }
}
// lib/presentation/views/home/admin_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/property_controller.dart';
import '../../router/route_names.dart';
import 'components/bottom_nav.dart';
import 'components/property_list.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, RouteNames.addProperty),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, RouteNames.addProperty),
        child: const Icon(Icons.add),
      ),
    );
  }
}
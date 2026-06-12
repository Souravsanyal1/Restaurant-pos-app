import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../routes/app_routes.dart';
import 'tables_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/table_model.dart';
import '../../widgets/glass_card.dart';

class TablesView extends GetView<TablesController> {
  const TablesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offAllNamed(AppRoutes.dashboard);
            }
          },
          tooltip: 'Back to Dashboard',
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.table_restaurant_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Table Floor Layout'),
            ],
          ),
        ),
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F172A) : AppColors.background.withValues(alpha: 0.3),
        child: Obx(() {
          final tables = controller.dbService.tables;
          if (tables.isEmpty) {
            return const Center(child: Text('No tables added yet. Click + to add one.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.width >= 1024 ? 4 : (context.width >= 600 ? 3 : 2),
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: context.width < 600 ? 0.75 : 0.85,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final t = tables[index];
              return _buildTableCard(context, t);
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTableDialog(context),
        label: const Text('Add Table (টেবিল যোগ করুন)', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTableCard(BuildContext context, TableModel table) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (table.status) {
      case TableStatus.available:
        statusColor = const Color(0xFF0D9488); // Teal
        statusLabel = 'Available';
        statusIcon = Icons.check_circle_rounded;
        break;
      case TableStatus.reserved:
        statusColor = const Color(0xFFD97706); // Amber
        statusLabel = 'Reserved';
        statusIcon = Icons.bookmark_added_rounded;
        break;
      case TableStatus.occupied:
        statusColor = const Color(0xFFE11D48); // Rose red
        statusLabel = 'Occupied';
        statusIcon = Icons.table_bar_rounded;
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => controller.toggleTableStatus(table.id, table.status),
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 24,
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        border: BorderSide(color: statusColor.withValues(alpha: 0.25), width: 1.5),
        child: Column(
          children: [
            // Top Row: Capacity & Unified Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Capacity Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_alt_rounded, size: 11, color: isDark ? Colors.white60 : Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '${table.capacity}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.15), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 10),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            
            // Visual Dining Table drawing
            _buildDiningTableDrawing(table, statusColor),
            
            const Spacer(),
            
            // Table Name & Action Label
            Text(
              table.name,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.3),
            ),
            const SizedBox(height: 2),
            Text(
              table.status == TableStatus.occupied 
                  ? 'TAP TO FREE TABLE' 
                  : (table.status == TableStatus.reserved ? 'TAP TO OCCUPY' : 'TAP TO OCCUPY'),
              style: TextStyle(
                fontSize: 8, 
                fontWeight: FontWeight.w900, 
                color: statusColor.withValues(alpha: 0.7),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Visual layout widget: draw a dining table surrounded by chair nodes
  Widget _buildDiningTableDrawing(TableModel table, Color color) {
    final int capacity = table.capacity;
    
    // Circular table for small capacities (2, 4)
    if (capacity <= 4) {
      return SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dining Table Central circle
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.08),
                border: Border.all(color: color, width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.flatware_rounded, size: 16, color: Colors.grey),
              ),
            ),

            // Seating positions surrounding the table radially
            ...List.generate(capacity, (index) {
              final double angle = (index * 2 * 3.14159) / capacity - (3.14159 / 2); // Start at top
              final double radius = 31.0;
              final double dx = radius * math.cos(angle);
              final double dy = radius * math.sin(angle);
              
              return Transform.translate(
                offset: Offset(dx, dy),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 7, 
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    } 
    
    // Rectangular table for larger capacities (6, 8, etc.)
    else {
      List<Offset> seatOffsets = [];
      if (capacity == 6) {
        seatOffsets = [
          const Offset(-20, -24), // Top left
          const Offset(0, -24),   // Top center
          const Offset(20, -24),  // Top right
          const Offset(-20, 24),  // Bottom left
          const Offset(0, 24),    // Bottom center
          const Offset(20, 24),   // Bottom right
        ];
      } else if (capacity == 8) {
        seatOffsets = [
          const Offset(-20, -24), // Top left
          const Offset(0, -24),   // Top center
          const Offset(20, -24),  // Top right
          const Offset(-20, 24),  // Bottom left
          const Offset(0, 24),    // Bottom center
          const Offset(20, 24),   // Bottom right
          const Offset(-34, 0),   // Left side
          const Offset(34, 0),    // Right side
        ];
      } else {
        // Fallback oval arrangement
        for (int i = 0; i < capacity; i++) {
          final double angle = (i * 2 * 3.14159) / capacity - (3.14159 / 2);
          final double rx = 36.0;
          final double ry = 25.0;
          seatOffsets.add(Offset(rx * math.cos(angle), ry * math.sin(angle)));
        }
      }

      return SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dining Table Central Rectangle
            Container(
              width: 54,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color.withValues(alpha: 0.08),
                border: Border.all(color: color, width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.flatware_rounded, size: 14, color: Colors.grey),
              ),
            ),

            // Seating positions
            ...List.generate(seatOffsets.length, (index) {
              final offset = seatOffsets[index];
              return Transform.translate(
                offset: offset,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 7, 
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }
  }

  void _showAddTableDialog(BuildContext context) {
    final nameController = TextEditingController();
    var selectedCapacity = 4.obs;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Dining Table', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Table 7',
                labelText: 'Table Name',
                prefixIcon: Icon(Icons.table_restaurant_rounded),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'SEATING CAPACITY (সিট সংখ্যা):',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [2, 4, 6, 8].map((cap) {
                    final isSel = selectedCapacity.value == cap;
                    return InkWell(
                      onTap: () => selectedCapacity.value = cap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : (isDark ? const Color(0xFF0F172A) : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? AppColors.primary : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          '$cap',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addNewTable(nameController.text.trim(), selectedCapacity.value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add Table'),
          ),
        ],
      ),
    );
  }
}

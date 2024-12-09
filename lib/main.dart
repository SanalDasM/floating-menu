import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: MacOSDock(
            items: [
              DockItem(icon: Icons.person, color: Colors.blue),
              DockItem(icon: Icons.message, color: Colors.green),
              DockItem(icon: Icons.call, color: Colors.red),
              DockItem(icon: Icons.camera, color: Colors.orange),
              DockItem(icon: Icons.photo, color: Colors.purple),
            ],
          ),
        ),
      ),
    );
  }
}

class DockItem {
  final IconData icon;
  final Color color;

  DockItem({required this.icon, required this.color});
}

class MacOSDock extends StatefulWidget {
  const MacOSDock({super.key, required this.items});

  final List<DockItem> items;

  @override
  State<MacOSDock> createState() => _MacOSDockState();
}

class _MacOSDockState extends State<MacOSDock> {
  late List<DockItem> dockItems;
  DockItem? draggingItem;
  int? hoverIndex;

  @override
  void initState() {
    super.initState();
    dockItems = widget.items.toList();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          hoverIndex = _getHoverIndex(event.localPosition);
        });
      },
      onExit: (_) {
        setState(() {
          hoverIndex = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(dockItems.length, (index) {
            final isHovering = hoverIndex == index;

            return Draggable<DockItem>(
              data: dockItems[index],
              feedback: _buildDockItem(dockItems[index], isDragging: true),
              childWhenDragging: const SizedBox.shrink(),
              onDragStarted: () {
                setState(() {
                  draggingItem = dockItems[index];
                });
              },
              onDragCompleted: () {
                setState(() {
                  draggingItem = null;
                });
              },
              child: DragTarget<DockItem>(
                onWillAcceptWithDetails: (data) => true,
                onAcceptWithDetails: (d) {
                  final data = d.data;
                  setState(() {
                    final draggedIndex = dockItems.indexOf(data);
                    if (draggedIndex != index) {
                      dockItems.removeAt(draggedIndex);
                      dockItems.insert(index, data);
                    }
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedScale(
                    scale: isHovering ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _buildDockItem(dockItems[index]),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDockItem(DockItem dockItem, {bool isDragging = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: dockItem.color, // Fixed color for each icon
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        dockItem.icon,
        color: Colors.white,
      ),
    );
  }

  int _getHoverIndex(Offset localPosition) {
    final itemWidth = 70.0;
    final centerX = localPosition.dx;
    final index = (centerX / itemWidth).floor();
    return index.clamp(0, dockItems.length - 1);
  }
}

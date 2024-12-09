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
        body: const Center(
          child: MacOSDock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}


class MacOSDock extends StatefulWidget {
  const MacOSDock({super.key, required this.items});

  final List<IconData> items;

  @override
  State<MacOSDock> createState() => _MacOSDockState();
}
class _MacOSDockState extends State<MacOSDock> {
  late List<IconData> dockItems;
  IconData? draggingItem;
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

            return Draggable<IconData>(
              data: dockItems[index],
              feedback: _buildDockItem(dockItems[index], index, isDragging: true),
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
              child: DragTarget<IconData>(
                onWillAcceptWithDetails: (data) => true,
                onAccept: (data) {
                  setState(() {
                    final draggedIndex = dockItems.indexOf(data);
                    if (draggedIndex != index) {
                      dockItems.removeAt(draggedIndex);
                      dockItems.insert(index, data);
                    }
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  // Use AnimatedScale for smoother animation
                  return AnimatedScale(
                    scale: isHovering ? 1.2 : 1.0, // Scale up when hovered
                    duration: const Duration(milliseconds: 200), // Slow down the animation
                    curve: Curves.easeInOut, // Smooth easing curve
                    child: _buildDockItem(dockItems[index], index),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }


  Widget _buildDockItem(IconData icon, int index, {bool isDragging = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color:  Colors.primaries[index % Colors.primaries.length],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
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

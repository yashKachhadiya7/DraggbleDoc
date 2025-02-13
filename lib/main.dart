import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Interactive Dock',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Sliding Dock'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<IconData> items = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ];

  // Track the currently dragged item's position
  Offset? dragPosition;
  int? draggingIndex; // Track the index of the dragged item

  // GlobalKey to track the container's position
  final GlobalKey _containerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            key: _containerKey, // Assign the GlobalKey to the container
            height: 80,
            margin: EdgeInsetsDirectional.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                // Calculate the base position of each icon
                double leftPosition = index * 60.0;

                // Adjust positions only if an icon is being dragged
                if (draggingIndex != null && dragPosition != null) {
                  // Get the container's offset relative to the screen
                  final RenderBox containerRenderBox =
                  _containerKey.currentContext!.findRenderObject() as RenderBox;
                  final containerOffset = containerRenderBox.localToGlobal(Offset.zero);

                  // Calculate the local drag position within the container
                  final localDragPosition = dragPosition! - containerOffset;

                  // Check if the current icon is a neighbor of the dragged icon
                  if (index == draggingIndex! - 1 || index == draggingIndex! + 1) {
                    // Move the neighbor inward based on the drag direction
                    if (localDragPosition.dy < 50) { // Dragged upward
                      if (index == draggingIndex! - 1) {
                        // Left neighbor moves slightly to the right
                        leftPosition += 20;
                      } else if (index == draggingIndex! + 1) {
                        // Right neighbor moves slightly to the left
                        leftPosition -= 20;
                      }
                    }
                  }
                }

                return AnimatedPositioned(
                  key: ValueKey(item),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: leftPosition,
                  top: 8,
                  child: DragTarget<IconData>(
                    onWillAccept: (data) {
                      if (data != item) {
                        setState(() {
                          final fromIndex = items.indexOf(data!);
                          final toIndex = index;
                          // Swap items in the list
                          items.removeAt(fromIndex);
                          items.insert(toIndex, data);
                        });
                      }
                      return true;
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Draggable<IconData>(
                        data: item,
                        feedback: _buildDockItem(item, isDragging: true),
                        childWhenDragging: Opacity(
                          opacity: 0.0,
                          child: _buildDockItem(item),
                        ),
                        child: _buildDockItem(item),
                        onDragStarted: () {
                          // Track the index of the dragged item
                          setState(() {
                            draggingIndex = items.indexOf(item);
                          });
                        },
                        onDragUpdate: (details) {
                          // Update the drag position
                          setState(() {
                            dragPosition = details.globalPosition;
                          });
                        },
                        onDragEnd: (details) {
                          // Reset the drag position and dragging index when dragging ends
                          setState(() {
                            dragPosition = null;
                            draggingIndex = null;
                          });
                        },
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockItem(IconData icon, {bool isDragging = false}) {
    return Container(
      width: 48,

      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging
            ? [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1)]
            : null,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
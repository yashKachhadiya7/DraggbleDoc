import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Dock',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Sliding Dock'),
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

  IconData? draggingItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Container(
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
              return AnimatedPositioned(
                key: ValueKey(item),
                duration: const Duration(milliseconds: 500),
                left: index * 60.0,
                top: 8,
                curve: Curves.easeInOut,
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
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
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

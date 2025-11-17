import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum QueueStatus { waiting, progress, done }

class CoffeeItem {
  final String coffee;
  final String type;
  final String milk;
  final String notes;
  final int quantity;

  CoffeeItem({
    required this.coffee,
    required this.type,
    required this.milk,
    required this.notes,
    required this.quantity,
  });
}

class QueueOrder {
  final List<CoffeeItem> items; 
  QueueStatus status;
  QueueOrder({required this.items, this.status = QueueStatus.waiting});
}

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  List<QueueOrder> orders = [
    QueueOrder(
      items: [
        CoffeeItem(
          coffee: 'Cappuccino',
          type: 'Hot',
          milk: 'Oat Milk',
          notes: 'No sugar',
          quantity: 2,
        ),
        CoffeeItem(
          coffee: 'Espresso',
          type: 'Hot',
          milk: 'None',
          notes: 'Double shot',
          quantity: 1,
        ),
      ],
      status: QueueStatus.waiting,
    ),
    QueueOrder(
      items: [
        CoffeeItem(
          coffee: 'Matcha Latte',
          type: 'Ice',
          milk: 'Almond Milk',
          notes: 'Less ice',
          quantity: 1,
        ),
      ],
      status: QueueStatus.done,
    ),
    QueueOrder(
      items: [
        CoffeeItem(
          coffee: 'Americano',
          type: 'Ice',
          milk: 'None',
          notes: '',
          quantity: 1,
        ),
        CoffeeItem(
          coffee: 'Latte',
          type: 'Hot',
          milk: 'Soy Milk',
          notes: 'Extra foam',
          quantity: 1,
        ),
      ],
      status: QueueStatus.progress,
    ),
    QueueOrder(
      items: [
        CoffeeItem(
          coffee: 'Cappuccino',
          type: 'Ice',
          milk: 'Oat Milk',
          notes: 'Less sugar',
          quantity: 1,
        ),
        CoffeeItem(
          coffee: 'Latte',
          type: 'Hot',
          milk: 'Soy Milk',
          notes: 'Extra foam',
          quantity: 2,
        ),
      ],
      status: QueueStatus.waiting,
    ),
    QueueOrder(
      items: [
        CoffeeItem(
          coffee: 'Strawberry Smoothie ',
          type: 'Hot',
          milk: 'Oat Milk',
          notes: 'No sugar',
          quantity: 2,
        ),
        CoffeeItem(
          coffee: 'Java Chip Frappuccino',
          type: 'Hot',
          milk: 'Soy Milk',
          notes: 'Extra foam',
          quantity: 2,
        ),
      ],
      status: QueueStatus.waiting,
    ),
  ];

  Color _statusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
        return Colors.grey[300]!;
      case QueueStatus.progress:
        return const Color(0xFF476EAE);
      case QueueStatus.done:
        return const Color(0xFFA7E399);
    }
  }

  Color _statusTextColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
        return Colors.black87;
      default:
        return Colors.white;
    }
  }

  String _statusText(QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
        return 'Pending';
      case QueueStatus.progress:
        return 'On Progress';
      case QueueStatus.done:
        return 'Done';
    }
  }

  void _nextStatus(int index) {
    setState(() {
      if (orders[index].status == QueueStatus.waiting) {
        orders[index].status = QueueStatus.progress;
      } else if (orders[index].status == QueueStatus.progress) {
        orders[index].status = QueueStatus.done;
      }
    });
  }

  void _updateStatus(int index, QueueStatus newStatus) {
    setState(() {
      orders[index].status = newStatus;
    });
  }

  void _showOrderDetail(QueueOrder order, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.brown[800],
              ),
            ),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _coffeeItemDetail(item),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                DropdownButton<QueueStatus>(
                  value: order.status,
                  items: QueueStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Chip(
                        label: Text(
                          _statusText(status),
                          style: GoogleFonts.poppins(
                            color: _statusTextColor(status),
                          ),
                        ),
                        backgroundColor: _statusColor(status),
                      ),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null) {
                      Navigator.pop(context);
                      _updateStatus(index, newStatus);
                    }
                  },
                ),
                const Spacer(),
                if (order.status != QueueStatus.done)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _nextStatus(index);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _statusColor(
                        order.status == QueueStatus.waiting
                            ? QueueStatus.progress
                            : QueueStatus.done,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      order.status == QueueStatus.waiting
                          ? 'Start Progress'
                          : 'Mark Done',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _coffeeItemDetail(CoffeeItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${item.coffee} x${item.quantity}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.brown[900],
            fontSize: 16,
          ),
        ),
        _detailRow('Type', item.type),
        _detailRow('Milk', item.milk),
        if (item.notes.isNotEmpty) _detailRow('Notes', item.notes),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.brown[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _queueCard(QueueOrder order, int index, int queueNumber) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showOrderDetail(order, index),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: _statusColor(order.status), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
              decoration: BoxDecoration(
                color: _statusColor(order.status),
                borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              child: Row(
                children: [
                Flexible(
                  child: Text(
                  'Queue No.${queueNumber + 1}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: _statusTextColor(order.status),
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Chip(
                  label: Text(
                    _statusText(order.status),
                    style: GoogleFonts.poppins(
                    color: _statusTextColor(order.status),
                    fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  backgroundColor: _statusColor(order.status),
                  visualDensity: VisualDensity.compact,
                  ),
                ),
                ],
              ),
              ),
              // Order details
              Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                      flex: 2,
                      child: Text(
                        '${item.coffee} x${item.quantity}',
                        style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.brown[900],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                      flex: 3,
                      child: Text(
                        '(${item.type}${item.milk != 'None' && item.milk.isNotEmpty ? ', ${item.milk}' : ''})',
                        style: GoogleFonts.poppins(
                        color: Colors.brown[700],
                        fontSize: 13,
                        ),
                        softWrap: true,
                      ),
                      ),
                    ],
                    ),
                  ),
                  ),
                  if (order.items.any((item) => item.notes.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: order.items
                      .where((item) => item.notes.isNotEmpty)
                      .map(
                        (item) => Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.brown[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.coffee}: ${item.notes}',
                          style: GoogleFonts.poppins(
                          color: Colors.brown[500],
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                          ),
                        ),
                        ),
                      )
                      .toList(),
                    ),
                  ),
                  const Spacer(),
                  if (order.status != QueueStatus.done)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                    onPressed: () => _nextStatus(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _statusColor(
                      order.status == QueueStatus.waiting
                        ? QueueStatus.progress
                        : QueueStatus.done,
                      ),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(90, 36),
                    ),
                    child: Text(
                      order.status == QueueStatus.waiting
                        ? 'Start Progress'
                        : 'Mark Done',
                      style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                    ),
                  ),
                ],
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 1;
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 900) {
      crossAxisCount = 3;
    } else if (width > 600) {
      crossAxisCount = 2;
    }

    return Container(
      color: Colors.brown[25],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                Icon(Icons.queue, color: Colors.brown[700], size: 28),
                const SizedBox(width: 10),
                Text(
                  'Queue Orders',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.brown[900],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: orders.isEmpty
                  ? Center(
                      child: Text(
                        'No queue orders',
                        style: GoogleFonts.poppins(
                          color: Colors.brown[300],
                          fontSize: 16, 
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: orders.length,
                      itemBuilder: (context, i) => _queueCard(orders[i], i, i),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

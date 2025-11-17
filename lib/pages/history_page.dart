import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'queue_page.dart';

class Order {
  final String id;
  final String time;
  final int amount;
  String status;

  Order({
    required this.id,
    required this.time,
    required this.amount,
    required this.status,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Order> _orders = [];
  List<Order> _filtered = [];
  String _query = '';
  String? _filterStatus;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _orders = List.generate(10, (i) {
      return Order(
        id: '#${348 + i}',
        time: '${8 + (i % 10)}:${(i % 2 == 0) ? '00' : '30'}',
        amount: 12000 + (i * 7500),
        status: (i % 3 == 0) ? 'Paid' : ((i % 3 == 1) ? 'Failed' : 'Paid'),
      );
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filtered = _orders.where((o) {
        final matchesQuery =
            _query.isEmpty || o.id.toLowerCase().contains(_query.toLowerCase());
        final matchesStatus =
            _filterStatus == null || o.status == _filterStatus;
        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  String _formatCurrency(int value) {
    var s = value.toString();
    var res = '';
    var count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      res = s[i] + res;
      count++;
      if (count == 3 && i != 0) {
        res = '.$res';
        count = 0;
      }
    }
    return 'Rp $res';
  }

  int get _totalSales =>
      _orders.where((o) => o.status == 'Paid').fold(0, (p, e) => p + e.amount);
  int get _transactionCount => _orders.length;

  void _toggleStatus(Order order) {
    setState(() {
      order.status = order.status == 'Paid' ? 'Failed' : 'Paid';
      _applyFilters();
    });
  }

  void _showOrderDetail(Order order) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.brown[100],
                    radius: 24,
                    child: Text(
                      order.id.replaceAll('#', ''),
                      style: GoogleFonts.poppins(
                        color: Colors.brown[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Detail',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Order ${order.id}',
                        style: GoogleFonts.poppins(
                          color: Colors.brown[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _detailRow('Time', order.time),
                    const Divider(height: 20),
                    _detailRow('Amount', _formatCurrency(order.amount)),
                    const Divider(height: 20),
                    _detailRow('Status', ''),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        order.status,
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      backgroundColor: order.status == 'Paid'
                          ? Colors.brown[700]
                          : Colors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(color: Colors.brown[700]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleStatus(order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      order.status == 'Paid'
                          ? 'Mark as Failed'
                          : 'Mark as Paid',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.brown[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _exportSimulated(String contextNote, List<Order> listToExport) {
    final buffer = StringBuffer();
    buffer.writeln('Export: $contextNote');
    buffer.writeln('Total rows: ${listToExport.length}');
    for (var o in listToExport) {
      buffer.writeln(
        '${o.id} | ${o.time} | ${_formatCurrency(o.amount)} | ${o.status}',
      );
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export (simulated)'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: Text(buffer.toString())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    final items = <String?>[null, 'Paid', 'Failed'];
    final labels = ['All', 'Paid', 'Failed'];
    return Wrap(
      spacing: 8,
      children: List.generate(items.length, (index) {
        final value = items[index];
        final selected = _filterStatus == value;
        return FilterChip(
          label: Text(labels[index], style: GoogleFonts.poppins()),
          selected: selected,
          selectedColor: Colors.brown[200],
          onSelected: (s) {
            setState(() {
              _filterStatus = value;
              _applyFilters();
            });
          },
        );
      }),
    );
  }

  Widget _leftColumn() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.03),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.brown.shade300),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: GoogleFonts.poppins(
                            color: Colors.brown.shade900,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search orders, IDs, amounts...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.brown.shade400,
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            _query = value;
                            _applyFilters();
                          },
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _query = '';
                              _applyFilters();
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            size: 18,
                            color: Colors.brown.shade300,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () =>
                    _exportSimulated('Left panel export', _filtered),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(
                  'Export',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: _filterChips()),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.brown[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    'ID',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'Time',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Amount',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: Text(
                    'Status',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No orders',
                      style: GoogleFonts.poppins(color: Colors.brown.shade400),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final o = _filtered[i];
                      return InkWell(
                        onTap: () => _showOrderDetail(o),
                        onLongPress: () => _showOrderActions(o),
                        child: Card(
                          color: Colors.brown[25],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    o.id,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    o.time,
                                    style: GoogleFonts.poppins(
                                      color: Colors.brown.shade400,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _formatCurrency(o.amount),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Center(
                                    child: Chip(
                                      label: Text(
                                        o.status,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: o.status == 'Paid'
                                          ? Colors.brown[700]
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.brown[400],
                                  ),
                                  onPressed: () => _showOrderActions(o),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showOrderActions(Order order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order ${order.id}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _actionButton(
              icon: Icons.visibility,
              label: 'View Details',
              onTap: () {
                Navigator.pop(context);
                _showOrderDetail(order);
              },
            ),
            _actionButton(
              icon: Icons.edit,
              label: 'Change Status',
              onTap: () {
                Navigator.pop(context);
                _toggleStatus(order);
              },
            ),
            _actionButton(
              icon: Icons.print,
              label: 'Print Receipt',
              onTap: () {
                Navigator.pop(context);
                _showPrintSimulation(order);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown[700]),
      title: Text(label, style: GoogleFonts.poppins()),
      onTap: onTap,
    );
  }

  void _showPrintSimulation(Order order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Print Receipt', style: GoogleFonts.poppins()),
        content: Text(
          'Printing simulation for Order ${order.id}\n'
          'Amount: ${_formatCurrency(order.amount)}\n'
          'Time: ${order.time}\n'
          'Status: ${order.status}',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.brown[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rightColumn() {
    final recent = _orders.reversed.take(5).toList();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.brown, Color(0xFFa1887f)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.08),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Sales',
                        style: GoogleFonts.poppins(color: Colors.brown.shade50),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatCurrency(_totalSales),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Today • $_transactionCount transactions',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.06),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Transactions',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.brown.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _transactionCount.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recent Transactions',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: recent.length,
              itemBuilder: (_, i) {
                final o = recent[i];
                return Card(
                  color: Colors.brown[25],
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () => _showOrderDetail(o),
                    leading: Icon(
                      Icons.receipt_long,
                      color: Colors.brown.shade300,
                    ),
                    title: Text(
                      o.id,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      o.time,
                      style: GoogleFonts.poppins(color: Colors.brown.shade500),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(o.amount),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          o.status,
                          style: GoogleFonts.poppins(
                            color: o.status == 'Paid'
                                ? Colors.brown
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () => _exportSimulated('Right panel export', recent),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: Text(
                'Export Recent',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 1:
        return const QueuePage();
      case 0:
      default:
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row( 
                children: [
                  Expanded(flex: 6, child: _leftColumn()),
                  Container(width: 1, color: Colors.brown.shade100),
                  Expanded(flex: 4, child: _rightColumn()),
                ],
              );
            } else {
              return Column(
                children: [
                  Expanded(child: _leftColumn()),
                  Container(height: 1, color: Colors.brown.shade100),
                  SizedBox(height: 360, child: _rightColumn()),
                ],
              );
            }
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        elevation: 0,
        backgroundColor: Colors.brown,
        flexibleSpace: Container(),
        title: Row(
          children: [
            const CircleAvatar(
              child: Icon(Icons.coffee, color: Colors.white),
              backgroundColor: Colors.brown,
            ),
            const SizedBox(width: 12),
            Text(
              'OrderCast',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '• Modern POS',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor:  Colors.brown.shade400,
            labelType: NavigationRailLabelType.all,
            leading: const SizedBox(height: 20),
            indicatorColor: Colors.white24,
            selectedIconTheme: const IconThemeData( 
              color: Colors.white,
              size: 28,
            ),
            unselectedIconTheme: IconThemeData(
              color: Colors.brown[200],
              size: 28,
            ),
            selectedLabelTextStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: GoogleFonts.poppins(
              color: Colors.brown[200],
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.access_time_outlined),
                selectedIcon: const Icon(Icons.access_time),
                label: Text('History'),
              ),
              // Hapus Menu destination
              NavigationRailDestination(
                icon: const Icon(Icons.local_drink_outlined),
                selectedIcon: const Icon(Icons.local_drink),
                label: Text('Queue'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1, color: Colors.brown[200]),

          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFd7ccc8), Color(0xFFf3ebe6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _buildPageContent(),
            ),
          ),
        ],
      ),
    );
  }
}

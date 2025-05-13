import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:managment/data/model/add_date.dart'; // Ensure this path is correct
import 'package:managment/data/utlity.dart'; // Ensure this path is correct
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Simple class for mock notification data
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.icon = Icons.notifications_active_rounded,
    this.iconColor = Colors.blueAccent,
    this.isRead = false,
  });
}

class Home extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab; // Callback to navigate to a tab in BottomNav

  const Home({Key? key, this.onNavigateToTab}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Box<Add_data> box = Hive.box<Add_data>('data');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  String? _userName;
  bool _isLoadingUserData = true;

  // Mock notifications list
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: 'Large Expense Alert!',
      message: 'You spent \$12000.00 on "Transfer". Consider reviewing this transaction.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      icon: Icons.error_outline_rounded,
      iconColor: Colors.orange.shade700,
    ),
    AppNotification(
      id: '2',
      title: 'Income Received',
      message: 'Successfully received \$1300.00. Check your updated balance.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      icon: Icons.price_check_rounded,
      iconColor: Colors.green.shade600,
    ),
    AppNotification(
      id: '3',
      title: 'Profile Updated',
      message: 'Your account information was successfully updated yesterday.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      icon: Icons.manage_accounts_rounded,
      iconColor: Colors.blue.shade600,
      isRead: true,
    ),
    AppNotification(
      id: '4',
      title: 'Maintenance Soon',
      message: 'Scheduled system maintenance tonight from 2 AM to 3 AM. App services might be unavailable.',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      icon: Icons.construction_rounded,
      iconColor: Colors.grey.shade700,
      isRead: true,
    ),
  ];

  int get _unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return; // Check if widget is still in the tree
    setState(() {
      _isLoadingUserData = true;
    });

    if (_currentUser == null) {
      if (mounted) setState(() => _isLoadingUserData = false);
      return;
    }
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (mounted) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          setState(() {
            _userName = data?['name'];
            _isLoadingUserData = false;
          });
        } else {
          setState(() {
            _userName = _currentUser?.displayName ?? "User"; // Fallback
            _isLoadingUserData = false;
          });
          print("User document not found in Firestore for UID: ${_currentUser!.uid}");
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
      if (mounted) {
        setState(() {
          _userName = "User"; // Fallback
          _isLoadingUserData = false;
        });
        if (context.mounted) { // Check context before showing SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not load user details: ${e.toString()}')));
        }
      }
    }
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.55,
              minChildSize: 0.3,
              maxChildSize: 0.85,
              builder: (_, controller) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 16.0, right: 16.0, bottom: 4.0),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[350],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Notifications',
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (_notifications.any((n) => !n.isRead))
                                TextButton(
                                  onPressed: () {
                                    setModalState(() {
                                      for (var n in _notifications) {
                                        n.isRead = true;
                                      }
                                    });
                                    if (mounted) setState(() {}); // Update Home screen badge
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'All notifications marked as read.')));
                                  },
                                  child: Text('Mark all as read',
                                      style: TextStyle(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.w500)),
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 0.5, color: theme.dividerColor.withOpacity(0.5)),
                    Expanded(
                      child: _notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_paused_outlined,
                                      size: 70, color: Colors.grey.shade400),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No new notifications',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(color: Colors.grey.shade600),
                                  ),
                                  Text(
                                    'You\'re all caught up!',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              controller: controller,
                              itemCount: _notifications.length,
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              itemBuilder: (BuildContext context, int index) {
                                final notification = _notifications[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: notification.isRead
                                        ? notification.iconColor.withOpacity(0.08)
                                        : notification.iconColor.withOpacity(0.15),
                                    child: Icon(notification.icon,
                                        color: notification.isRead
                                            ? Colors.grey.shade500
                                            : notification.iconColor,
                                        size: 24),
                                  ),
                                  title: Text(notification.title,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: notification.isRead
                                            ? FontWeight.normal
                                            : FontWeight.w600,
                                        color: notification.isRead
                                            ? Colors.grey.shade700
                                            : theme.textTheme.bodyLarge?.color,
                                      )),
                                  subtitle: Text(notification.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: notification.isRead
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade700,
                                        height: 1.3,
                                      )),
                                  trailing: Text(
                                    DateFormat('MMM d, hh:mm a')
                                        .format(notification.timestamp),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                  onTap: () {
                                    setModalState(() {
                                      notification.isRead = true;
                                    });
                                    if (mounted) setState(() {}); // Update Home screen badge
                                    print('Tapped on: ${notification.title}');
                                  },
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                  indent: 72,
                                  endIndent: 16,
                                  height: 0.5,
                                  thickness: 0.5,
                                  color: theme.dividerColor.withOpacity(0.3)),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderAndCard(ThemeData theme) {
    final primaryColor = theme.primaryColor;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 45, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _isLoadingUserData
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(children: [
                            SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white.withOpacity(0.8),
                                  strokeWidth: 2.0),
                            ),
                            const SizedBox(width: 12),
                            Text("Loading profile...",
                                style: textTheme.titleSmall
                                    ?.copyWith(color: Colors.white70))
                          ]))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Hello,',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _userName ?? 'Valued User!',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                ),
              ],
            ),
            const SizedBox(height: 25), // Space above balance card

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(0, 6),
                    blurRadius: 15,
                    spreadRadius: -2,
                  ),
                ],
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: textTheme.titleSmall?.copyWith(
                        color: textTheme.bodySmall?.color?.withOpacity(0.75),
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                        .format(total()), // Assuming total() is from utlity.dart
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildIncomeExpenseColumn(
                            Icons.trending_down_rounded,
                            'Income',
                            income(), // Assuming income() is from utlity.dart
                            Colors.green.shade600,
                            textTheme),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildIncomeExpenseColumn(
                            Icons.trending_up_rounded,
                            'Expenses',
                            expenses(), // Assuming expenses() is from utlity.dart
                            Colors.red.shade600,
                            textTheme),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Space between card and "Dashboard" title

            Text( // "Dashboard" title moved here
              'Dashboard',
              style: textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseColumn(IconData icon, String label, double amount,
      Color iconColor, TextTheme textTheme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: iconColor.withOpacity(0.12),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: textTheme.bodySmall?.color?.withOpacity(0.75),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                    .format(amount),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textTheme.bodyLarge?.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Add_data history, ThemeData theme) {
    bool isIncome = history.IN == 'Income';
    return Dismissible(
      key: ValueKey(history.key ?? UniqueKey()), // Ensure history.key is available and unique
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        history.delete();
        if(mounted && context.mounted){
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${history.name} transaction removed.'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Colors.black87,
            ),
            );
        }
      },
      background: Container(
        decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Delete',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            SizedBox(width: 8),
            Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 26),
          ],
        ),
      ),
      child: Card(
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor:
                (isIncome ? Colors.green.shade50 : Colors.red.shade50)
                    .withOpacity(0.9),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
              size: 20,
            ),
          ),
          title: Text(
            history.name,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            DateFormat('MMM d, yyyy  •  hh:mm a').format(history.datetime),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'} ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(double.tryParse(history.amount) ?? 0.0)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          onTap: () {
             if(mounted && context.mounted){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Details for ${history.name}'),
                    duration: const Duration(seconds: 1)));
             }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
      body: ValueListenableBuilder<Box<Add_data>>(
          valueListenable: box.listenable(),
          builder: (context, historyBox, child) {
            List<Add_data> transactions = historyBox.values.toList();
            transactions.sort((a, b) => b.datetime.compareTo(a.datetime));

            final recentTransactionsCount =
                transactions.length > 5 ? 5 : transactions.length;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 380.0, // Adjusted to fit content including "Dashboard" text
                  floating: false,
                  pinned: true,
                  snap: false,
                  elevation: 1.0,
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    // Title is removed as "Dashboard" is now in the background
                    background: _buildHeaderAndCard(theme),
                  ),
                  actions: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, size: 28),
                          onPressed: () {
                            _showNotificationsBottomSheet(context);
                          },
                          tooltip: 'Notifications',
                        ),
                        if (_unreadNotificationCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.shade400,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 18, minHeight: 18),
                              child: Center(
                                child: Text(
                                  '$_unreadNotificationCount',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (transactions.length > recentTransactionsCount)
                          TextButton(
                              onPressed: () {
                                widget.onNavigateToTab?.call(2); // Navigate to Wallet tab (index 2)
                              },
                              child: Text('View All',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500)))
                      ],
                    ),
                  ),
                ),
                transactions.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 70, color: Colors.grey[400]),
                                const SizedBox(height: 20),
                                Text(
                                  'No transactions yet.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the "+" button to add your first one!',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[500], height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 5.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              Add_data history = transactions[index];
                              return _buildTransactionItem(history, theme);
                            },
                            childCount: recentTransactionsCount,
                          ),
                        ),
                      ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: 80)), // Space for FAB overlap
              ],
            );
          }),
    );
  }
}
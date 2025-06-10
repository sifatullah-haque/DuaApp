import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/theme.dart';
import '../../../models/user_quote.dart';
import '../../../services/appwrite_service.dart';
import 'update_quotes.dart';

class AdminTab extends StatefulWidget {
  final List<UserQuote> allQuotes;
  final VoidCallback onQuotesUpdated;

  const AdminTab({
    super.key,
    required this.allQuotes,
    required this.onQuotesUpdated,
  });

  @override
  State<AdminTab> createState() => _AdminTabState();
}

class _AdminTabState extends State<AdminTab> with TickerProviderStateMixin {
  String _currentFilter = 'all';
  bool _isLoading = false;
  Set<String> _selectedQuoteIds = {};
  bool _isSelectionMode = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final filters = ['all', 'pending', 'approved', 'rejected'];
        _filterQuotes(filters[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section - Made more compact
        Container(
          decoration: AppTheme.glassMorphicDecoration,
          margin: EdgeInsets.all(12.w),
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: AppTheme.goldAccent,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        color: AppTheme.whiteText,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage user quotes',
                      style: TextStyle(
                        color: AppTheme.whiteText.withOpacity(0.7),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSelectionMode) ...[
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.whiteText,
                    size: 20.sp,
                  ),
                  onPressed: _exitSelectionMode,
                  tooltip: 'Exit selection mode',
                ),
              ] else ...[
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppTheme.whiteText,
                    size: 20.sp,
                  ),
                  color: AppTheme.glassMorphBlack,
                  onSelected: _handleMenuAction,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'bulk_select',
                      child: Row(
                        children: [
                          Icon(
                            Icons.checklist,
                            color: AppTheme.goldAccent,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Bulk Select',
                            style: TextStyle(
                              color: AppTheme.whiteText,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(
                            Icons.download,
                            color: AppTheme.goldAccent,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Export Data',
                            style: TextStyle(
                              color: AppTheme.whiteText,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Statistics Cards - Made more compact and fixed overflow
        Container(
          height: 80.h,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  'Total',
                  widget.allQuotes.length,
                  Icons.library_books,
                  AppTheme.goldAccent,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildCompactStatCard(
                  'Pending',
                  _getPendingCount(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildCompactStatCard(
                  'Approved',
                  _getApprovedCount(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildCompactStatCard(
                  'Rejected',
                  _getRejectedCount(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Tab Bar for Filters - Made more compact
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: AppTheme.glassMorphicDecoration,
          child: TabBar(
            dividerColor: Colors.transparent,
            controller: _tabController,
            labelColor: AppTheme.goldAccent,
            unselectedLabelColor: AppTheme.whiteText.withOpacity(0.6),
            indicatorColor: AppTheme.goldAccent,
            indicatorWeight: 2,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 10.sp,
            ),
            tabs: [
              Tab(text: 'All\n(${widget.allQuotes.length})'),
              Tab(text: 'Pending\n(${_getPendingCount()})'),
              Tab(text: 'Approved\n(${_getApprovedCount()})'),
              Tab(text: 'Rejected\n(${_getRejectedCount()})'),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Bulk Actions Bar - Made more compact
        if (_isSelectionMode && _selectedQuoteIds.isNotEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppTheme.goldAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
            ),
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Text(
                  '${_selectedQuoteIds.length} selected',
                  style: TextStyle(
                    color: AppTheme.whiteText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
                const Spacer(),
                _buildCompactBulkActionButton(
                  'Approve',
                  Icons.check,
                  Colors.green,
                  () => _bulkAction('approve'),
                ),
                SizedBox(width: 6.w),
                _buildCompactBulkActionButton(
                  'Reject',
                  Icons.close,
                  Colors.red,
                  () => _bulkAction('reject'),
                ),
                SizedBox(width: 6.w),
                _buildCompactBulkActionButton(
                  'Delete',
                  Icons.delete,
                  Colors.red.shade700,
                  () => _bulkAction('delete'),
                ),
              ],
            ),
          ),

        if (_isSelectionMode && _selectedQuoteIds.isNotEmpty)
          SizedBox(height: 12.h),

        // Quote List - More space allocated for better scrolling
        Expanded(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppTheme.goldAccent),
                      SizedBox(height: 12.h),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: AppTheme.whiteText,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                )
              : _getFilteredQuotes().isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 20.h),
                  itemCount: _getFilteredQuotes().length,
                  itemBuilder: (context, index) {
                    final quote = _getFilteredQuotes()[index];
                    return _buildCompactQuoteCard(quote);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCompactStatCard(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: EdgeInsets.all(10.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(height: 4.h),
          Text(
            value.toString(),
            style: TextStyle(
              color: AppTheme.whiteText,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.whiteText.withOpacity(0.7),
              fontSize: 8.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBulkActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 12.sp),
      label: Text(label, style: TextStyle(fontSize: 9.sp)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        minimumSize: Size(0, 28.h),
      ),
    );
  }

  Widget _buildCompactQuoteCard(UserQuote quote) {
    final isSelected = _selectedQuoteIds.contains(quote.id);
    Color statusColor = _getStatusColor(quote.status);
    IconData statusIcon = _getStatusIcon(quote.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.glassBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? AppTheme.goldAccent : AppTheme.glassBorder,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppTheme.goldAccent.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: isSelected ? 12 : 8,
            offset: Offset(0, isSelected ? 6.h : 4.h),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _showQuoteUpdateDialog(quote),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and selection - Made more compact
            Container(
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  if (_isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleQuoteSelection(quote.id),
                      activeColor: AppTheme.goldAccent,
                    ),
                    SizedBox(width: 6.w),
                  ],
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 12.sp),
                        SizedBox(width: 3.w),
                        Text(
                          quote.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'By: ${quote.userEmail ?? 'Unknown'}',
                        style: TextStyle(
                          color: AppTheme.whiteText.withOpacity(0.7),
                          fontSize: 9.sp,
                        ),
                      ),
                      Text(
                        _formatDate(quote.createdAt),
                        style: TextStyle(
                          color: AppTheme.whiteText.withOpacity(0.5),
                          fontSize: 8.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quote Content - Made more compact
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (quote.arabicText != null &&
                      quote.arabicText!.isNotEmpty) ...[
                    _buildCompactQuoteSection(
                      'Arabic | العربية',
                      quote.arabicText!,
                      true,
                    ),
                    SizedBox(height: 8.h),
                  ],
                  _buildCompactQuoteSection(
                    'Bengali | বাংলা',
                    quote.bengaliText,
                    false,
                  ),
                  if (quote.englishText != null &&
                      quote.englishText!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    _buildCompactQuoteSection(
                      'English',
                      quote.englishText!,
                      false,
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.book, color: AppTheme.goldAccent, size: 10.sp),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          quote.reference,
                          style: TextStyle(
                            color: AppTheme.whiteText.withOpacity(0.7),
                            fontSize: 9.sp,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons - Made more compact
            Container(
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              padding: EdgeInsets.all(8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (quote.status == 'pending') ...[
                    _buildCompactActionButton(
                      'Approve',
                      Icons.check_circle,
                      Colors.green,
                      () => _approveQuote(quote.id),
                    ),
                    _buildCompactActionButton(
                      'Reject',
                      Icons.cancel,
                      Colors.red,
                      () => _rejectQuote(quote.id),
                    ),
                  ] else ...[
                    _buildCompactActionButton(
                      'Edit',
                      Icons.edit,
                      AppTheme.goldAccent,
                      () => _showQuoteUpdateDialog(quote),
                    ),
                  ],
                  _buildCompactActionButton(
                    'Delete',
                    Icons.delete_outline,
                    Colors.red.shade300,
                    () => _deleteQuoteAdmin(quote.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactQuoteSection(
    String title,
    String content,
    bool isArabic,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.goldAccent,
            fontSize: 9.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          content,
          style: TextStyle(
            color: AppTheme.whiteText,
            fontSize: 11.sp,
            height: 1.4,
          ),
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        ),
      ],
    );
  }

  Widget _buildCompactActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 12.sp),
          label: Text(label, style: TextStyle(fontSize: 8.sp)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
            padding: EdgeInsets.symmetric(vertical: 6.h),
            minimumSize: Size(0, 28.h),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48.sp,
            color: AppTheme.whiteText.withOpacity(0.3),
          ),
          SizedBox(height: 12.h),
          Text(
            'No quotes found',
            style: TextStyle(
              color: AppTheme.whiteText.withOpacity(0.7),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Quotes will appear here once users submit them',
            style: TextStyle(
              color: AppTheme.whiteText.withOpacity(0.5),
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper Methods
  int _getPendingCount() =>
      widget.allQuotes.where((q) => q.status == 'pending').length;
  int _getApprovedCount() =>
      widget.allQuotes.where((q) => q.status == 'approved').length;
  int _getRejectedCount() =>
      widget.allQuotes.where((q) => q.status == 'rejected').length;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  void _filterQuotes(String filter) {
    setState(() {
      _currentFilter = filter;
      _selectedQuoteIds.clear();
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'bulk_select':
        setState(() {
          _isSelectionMode = true;
        });
        break;
      case 'export':
        _exportData();
        break;
    }
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedQuoteIds.clear();
    });
  }

  void _toggleQuoteSelection(String quoteId) {
    setState(() {
      if (_selectedQuoteIds.contains(quoteId)) {
        _selectedQuoteIds.remove(quoteId);
      } else {
        _selectedQuoteIds.add(quoteId);
      }
    });
  }

  List<UserQuote> _getFilteredQuotes() {
    if (_currentFilter == 'all') return widget.allQuotes;
    return widget.allQuotes
        .where((quote) => quote.status == _currentFilter)
        .toList();
  }

  Future<void> _bulkAction(String action) async {
    if (_selectedQuoteIds.isEmpty) return;

    final confirmed = await _showBulkActionConfirmation(action);
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    final appwrite = AppwriteService();
    int successCount = 0;

    for (String quoteId in _selectedQuoteIds) {
      Map<String, dynamic> result;

      switch (action) {
        case 'approve':
          result = await appwrite.updateQuoteStatus(quoteId, 'approved');
          break;
        case 'reject':
          result = await appwrite.updateQuoteStatus(quoteId, 'rejected');
          break;
        case 'delete':
          result = await appwrite.deleteQuote(quoteId);
          break;
        default:
          continue;
      }

      if (result['success']) {
        successCount++;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _selectedQuoteIds.clear();
        _isSelectionMode = false;
      });

      widget.onQuotesUpdated();
      final actionMessage = action == 'approve' 
          ? '$successCount quotes approved successfully! They are now visible to all users.'
          : action == 'reject'
          ? '$successCount quotes rejected successfully! They will not be visible to users.'
          : '$successCount quotes deleted successfully!';
      _showSnackBar(actionMessage);
    }
  }

  Future<bool> _showBulkActionConfirmation(String action) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.glassMorphBlack,
            title: Text(
              'Bulk ${action.capitalize()}',
              style: TextStyle(color: AppTheme.whiteText),
            ),
            content: Text(
              'Are you sure you want to $action ${_selectedQuoteIds.length} selected quotes?',
              style: TextStyle(color: AppTheme.whiteText.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.whiteText),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getActionColor(action),
                  foregroundColor: Colors.white,
                ),
                child: Text(action.capitalize()),
              ),
            ],
          ),
        ) ??
        false;
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'approve':
        return Colors.green;
      case 'reject':
        return Colors.red;
      case 'delete':
        return Colors.red.shade700;
      default:
        return AppTheme.goldAccent;
    }
  }

  void _exportData() {
    _showSnackBar('Export functionality coming soon!');
  }

  void _showQuoteUpdateDialog(UserQuote quote) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateQuotesDialog(
        quote: quote,
        isAdminView: true,
        onQuoteUpdated: () {
          widget.onQuotesUpdated();
        },
      ),
    );
  }

  void _showStatusEditDialog(UserQuote quote) {
    _showQuoteUpdateDialog(quote);
  }

  Future<void> _approveQuote(String quoteId) async {
    final appwrite = AppwriteService();
    final result = await appwrite.updateQuoteStatus(quoteId, 'approved');

    if (mounted) {
      if (result['success']) {
        widget.onQuotesUpdated();
        _showSnackBar('Quote approved successfully! It is now visible to all users.');
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    }
  }

  Future<void> _rejectQuote(String quoteId) async {
    final appwrite = AppwriteService();
    final result = await appwrite.updateQuoteStatus(quoteId, 'rejected');

    if (mounted) {
      if (result['success']) {
        widget.onQuotesUpdated();
        _showSnackBar('Quote rejected successfully! It will not be visible to users.');
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    }
  }

  Future<void> _deleteQuoteAdmin(String quoteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.glassMorphBlack,
        title: Text(
          'Delete Quote',
          style: TextStyle(color: AppTheme.whiteText),
        ),
        content: Text(
          'Are you sure you want to permanently delete this quote?',
          style: TextStyle(color: AppTheme.whiteText.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.whiteText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final appwrite = AppwriteService();
      final result = await appwrite.deleteQuote(quoteId);

      if (mounted) {
        if (result['success']) {
          widget.onQuotesUpdated();
          _showSnackBar('Quote deleted successfully!');
        } else {
          _showSnackBar(result['message'], isError: true);
        }
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.withOpacity(0.8)
            : AppTheme.goldAccent.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

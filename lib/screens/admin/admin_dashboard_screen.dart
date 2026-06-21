import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../models/admit_card_request_model.dart';
import '../../services/admin_service.dart';
import '../../services/admit_card_service.dart';
import '../../services/auth_service.dart';
import '../../utils/date_formatter.dart';
import '../../utils/responsive.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/dashboard_card.dart';
import '../auth/login_screen.dart';
import '../../services/role_guard_service.dart';
import '../student/student_dashboard_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  final AdmitCardService _admitCardService = AdmitCardService();
  final AuthService _authService = AuthService();
  final RoleGuardService _roleGuardService = RoleGuardService();

  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';
  bool _isApproving = false;
  String? _approvingRequestId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  bool _isCheckingAccess = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
}
  Future<void> _checkAccess() async {
  final role = await _roleGuardService.getCurrentUserRole();

  if (!mounted) return;

  if (role == null) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
    return;
  }

  if (role == 'student') {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const StudentDashboardScreen(),
      ),
      (route) => false,
    );
    return;
  }

  if (role == 'admin') {
    setState(() {
      _isCheckingAccess = false;
    });
  }
}

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _approveRequest(String requestId) async {
    setState(() {
      _isApproving = true;
      _approvingRequestId = requestId;
    });

    try {
      await _admitCardService.approveRequest(requestId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text('Application approved successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.dangerRed,
          content: Text(
            error.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isApproving = false;
          _approvingRequestId = null;
        });
      }
    }
  }

  List<AdmitCardRequestModel> _filterRequests(
    List<AdmitCardRequestModel> requests,
  ) {
    final search = _searchText.trim();

    if (search.isEmpty) {
      return requests;
    }

    return requests.where((request) {
      return request.studentId.toLowerCase().contains(search.toLowerCase());
    }).toList();
  }

  Color _statusColor(String status) {
    if (status == 'approved') {
      return AppColors.successGreen;
    }

    if (status == 'pending') {
      return AppColors.pendingOrange;
    }

    return AppColors.dangerRed;
  }

  String _statusLabel(String status) {
    if (status == 'approved') {
      return 'Approved';
    }

    if (status == 'pending') {
      return 'Pending';
    }

    return 'Rejected';
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 28,
        vertical: isMobile ? 18 : 22,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Image.asset(
            AppAssets.luLogo,
            width: isMobile ? 48 : 58,
            height: isMobile ? 48 : 58,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Admin Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 22 : 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (!isMobile)
            const Text(
              'Digital Admit Card System',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _logout,
            tooltip: 'Logout',
            icon: const Icon(
              Iconsax.logout,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    bool isMobile,
    List<AdmitCardRequestModel> requests,
  ) {
    final total = _adminService.countTotalApplications(requests);
    final approved = _adminService.countApprovedApplications(requests);

    if (isMobile) {
      return Column(
        children: [
          DashboardCard(
            title: 'Total Applications',
            value: total.toString(),
            icon: Iconsax.document_text,
            iconColor: AppColors.primaryBlue,
          ),
          const SizedBox(height: 16),
          DashboardCard(
            title: 'Approved',
            value: approved.toString(),
            icon: Iconsax.tick_circle,
            iconColor: AppColors.successGreen,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: DashboardCard(
            title: 'Total Applications',
            value: total.toString(),
            icon: Iconsax.document_text,
            iconColor: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: DashboardCard(
            title: 'Approved',
            value: approved.toString(),
            icon: Iconsax.tick_circle,
            iconColor: AppColors.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Student ID',
              prefixIcon: const Icon(Iconsax.search_normal),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
            ),
            onSubmitted: (_) {
              setState(() {
                _searchText = _searchController.text;
              });
            },
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Search',
            onPressed: () {
              setState(() {
                _searchText = _searchController.text;
              });
            },
            backgroundColor: AppColors.primaryBlue,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Student ID',
              prefixIcon: const Icon(Iconsax.search_normal),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
            ),
            onSubmitted: (_) {
              setState(() {
                _searchText = _searchController.text;
              });
            },
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 150,
          child: CustomButton(
            text: 'Search',
            onPressed: () {
              setState(() {
                _searchText = _searchController.text;
              });
            },
            backgroundColor: AppColors.primaryBlue,
          ),
        ),
        if (_searchText.trim().isNotEmpty) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            height: 54,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _searchText = '';
                  _searchController.clear();
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.dangerRed,
                side: const BorderSide(color: AppColors.dangerRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Clear',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildApplicationsTable(
    bool isMobile,
    List<AdmitCardRequestModel> requests,
  ) {
    final filteredRequests = _filterRequests(requests);

    if (filteredRequests.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Center(
          child: Text(
            'No applications found',
            style: TextStyle(
              color: AppColors.hintText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (isMobile) {
      return Column(
        children: filteredRequests.map((request) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.studentName,
                  style: const TextStyle(
                    color: AppColors.navyText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${request.studentId}',
                  style: const TextStyle(
                    color: AppColors.hintText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Batch: ${request.batch}',
                  style: const TextStyle(
                    color: AppColors.hintText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Submitted: ${DateFormatter.formatDate(request.submittedOn)}',
                  style: const TextStyle(
                    color: AppColors.hintText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(request.status).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(request.status),
                    style: TextStyle(
                      color: _statusColor(request.status),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  text: request.status == 'approved'
                      ? 'Approved'
                      : 'Approve',
                  onPressed: request.status == 'approved'
                      ? null
                      : () => _approveRequest(request.id),
                  isLoading:
                      _isApproving && _approvingRequestId == request.id,
                  backgroundColor: AppColors.successGreen,
                  height: 48,
                  fontSize: 15,
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.lightBlue),
          dataRowMinHeight: 62,
          dataRowMaxHeight: 70,
          columnSpacing: 48,
          columns: const [
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            DataColumn(
              label: Text(
                'Student ID',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            DataColumn(
              label: Text(
                'Batch',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            DataColumn(
              label: Text(
                'Submitted On',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            DataColumn(
              label: Text(
                'Action',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
          rows: filteredRequests.map((request) {
            final isThisApproving =
                _isApproving && _approvingRequestId == request.id;

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    request.studentName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(Text(request.studentId)),
                DataCell(Text(request.batch)),
                DataCell(Text(DateFormatter.formatDate(request.submittedOn))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(request.status).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _statusLabel(request.status),
                      style: TextStyle(
                        color: _statusColor(request.status),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 125,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: request.status == 'approved'
                          ? null
                          : () => _approveRequest(request.id),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.successGreen,
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isThisApproving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              request.status == 'approved'
                                  ? 'Approved'
                                  : 'Approve',
                              style: TextStyle(
                                color: request.status == 'approved'
                                    ? Colors.grey.shade700
                                    : Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(
    bool isMobile,
    List<AdmitCardRequestModel> requests,
  ) {
    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile),
              const SizedBox(height: 24),
              _buildSummaryCards(isMobile, requests),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 18 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Applications',
                      style: TextStyle(
                        color: AppColors.navyText,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSearchSection(isMobile),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildApplicationsTable(isMobile, requests),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    if(_isCheckingAccess){
      return const Scaffold(
        backgroundColor:AppColors.background,
        body: Center(
          child:CircularProgressIndicator(
            color:AppColors.primaryBlue
          ) ,
          
        )

      );

    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<AdmitCardRequestModel>>(
        stream: _adminService.requestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.dangerRed,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          final requests = snapshot.data ?? [];

          return _buildContent(isMobile, requests);
        },
      ),
    );
  }
}
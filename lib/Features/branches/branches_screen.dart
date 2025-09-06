import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:safetyZone/Features/branch_management/data/services/manager_api_service.dart';
import 'package:safetyZone/core/localization/app_localizations.dart';
import 'package:safetyZone/core/routing/routes.dart';
import 'package:safetyZone/core/utils/constants/colors.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  List<Branch> _branches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      ManagerApiService apiService = ManagerApiService();
      final response =
          await apiService.getBranchesPaginated(page: 1, limit: 10);

      if (response.success && response.data != null) {
        final paginatedResponse = response.data!;
        setState(() {
          _branches = paginatedResponse.data;
          _isLoading = false;
        });

        debugPrint('✅ Total branches: ${paginatedResponse.total}');
      } else {
        debugPrint('⚠️ Failed to load branches: ${response.message}');
        setState(() => _isLoading = false);
      }
    } catch (error) {
      debugPrint('💥 Error fetching branches: $error');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.translate("branches_added"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: loc.translate("search_branch"),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.grey, width: 0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.grey, width: 0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      const BorderSide(color: CColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Branches List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: SpinKitDoubleBounce(color: CColors.primary))
                : _branches.isEmpty
                    ? Center(
                        child: Text(
                          loc.translate("no_branches_found"),
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _branches.length,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemBuilder: (context, index) {
                          final branch = _branches[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    branch.branchName,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    branch.address,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Actions
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildOutlinedButton(
                                              loc.translate("location")),
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                Routes.branchDetails,
                                                arguments: branch,
                                              );
                                            },
                                            child: _buildFilledButton(
                                              loc.translate("edit"),
                                              CColors.secondary,
                                              branch,
                                              Icons.edit,
                                            ),
                                          ),
                                          _buildFilledButton(
                                              loc.translate("print"),
                                              CColors.primary,
                                              branch,
                                              Icons.print),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildOutlinedButton(
                                            loc.translate(
                                              "branch_quantities",
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                Routes.branchDetails,
                                                arguments: branch,
                                              );
                                            },
                                            child: _buildFilledButton(
                                              loc.translate("edit"),
                                              CColors.secondary,
                                              branch,
                                              Icons.edit,
                                            ),
                                          ),
                                          _buildFilledButton(
                                              loc.translate("print"),
                                              CColors.primary,
                                              branch,
                                              Icons.print),
                                        ],
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            _buildFilledButton(
                                              loc.translate("contract_details"),
                                              CColors.primary,
                                              branch,
                                              Icons.print,
                                              18,
                                              10,
                                              12,
                                            ),
                                            const SizedBox(width: 8),
                                            _buildFilledButton(
                                              loc.translate("invoices"),
                                              CColors.primary,
                                              branch,
                                              Icons.print,
                                              18,
                                              10,
                                              12,
                                            ),
                                            const SizedBox(width: 16),
                                            _buildOutlinedButton(
                                              loc.translate("renew_contract"),
                                              18,
                                              10,
                                            ),
                                            const SizedBox(width: 8),
                                            _buildOutlinedButton(
                                              loc.translate("no_contract"),
                                              18,
                                              10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Add New Branch Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.branchDetails,
                    arguments: null,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  loc.translate("add_branch"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
      backgroundColor: const Color(0xFFF2F5FA),
    );
  }

  Widget _buildOutlinedButton(String text, [double? radius, double? fontSize]) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: CColors.secondary),
        foregroundColor: CColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 8)),
      ),
      child: Text(text, style: TextStyle(fontSize: fontSize ?? 13)),
    );
  }

  Widget _buildFilledButton(String text, Color color, Branch branch,
      [IconData? icon, double? radius, double? fontSize, double? iconSize]) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).pushNamed(
          Routes.branchDetails,
          arguments: branch,
        );
      },
      label: icon != null
          ? Icon(icon, size: iconSize ?? 16, color: color)
          : const SizedBox(),
      icon: Text(
        text,
        style: TextStyle(fontSize: fontSize ?? 13, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 8)),
      ),
    );
  }
}

class PaginatedBranchesResponse {
  final int total;
  final List<Branch> data;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedBranchesResponse({
    required this.total,
    required this.data,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedBranchesResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedBranchesResponse(
      total: json['total'] ?? 0,
      data: (json['data'] as List<dynamic>)
          .map((e) => Branch.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class Branch {
  final String id;
  final String branchName;
  final Employee employee;
  final String address;
  final List<double> coordinates;
  final String mall;
  final int space;
  final String systemType;
  final String consumer;
  final int createdAt;
  final List<WorkingDay> workingDays;
  final List<ItemQuantity> alarmItem;
  final List<ItemQuantity> fireSystemItem;
  final List<ItemQuantity> fireExtinguisherItem;

  Branch({
    required this.id,
    required this.branchName,
    required this.employee,
    required this.address,
    required this.coordinates,
    required this.mall,
    required this.space,
    required this.systemType,
    required this.consumer,
    required this.createdAt,
    required this.workingDays,
    required this.alarmItem,
    required this.fireSystemItem,
    required this.fireExtinguisherItem,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'] ?? '',
      branchName: json['branchName'] ?? '',
      employee: Employee.fromJson(json['employee'] ?? {}),
      address: json['address'] ?? '',
      coordinates: (json['location']?['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      mall: json['mall'] ?? '',
      space: json['space'] ?? 0,
      systemType: json['systemType'] ?? '',
      consumer: json['consumer'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      workingDays: (json['workingDays'] as List<dynamic>?)
              ?.map((e) => WorkingDay.fromJson(e))
              .toList() ??
          [],
      alarmItem: (json['alarmItem'] as List<dynamic>?)
              ?.map((e) => ItemQuantity.fromJson(e))
              .toList() ??
          [],
      fireSystemItem: (json['fireSystemItem'] as List<dynamic>?)
              ?.map((e) => ItemQuantity.fromJson(e))
              .toList() ??
          [],
      fireExtinguisherItem: (json['fireExtinguisherItem'] as List<dynamic>?)
              ?.map((e) => ItemQuantity.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Employee {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String profileImage;
  final String employeeType;

  Employee({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.profileImage,
    required this.employeeType,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profileImage: json['profileImage'] ?? '',
      employeeType: json['employeeType'] ?? '',
    );
  }
}

class WorkingDay {
  final String day;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  WorkingDay({
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  factory WorkingDay.fromJson(Map<String, dynamic> json) {
    return WorkingDay(
      day: json['day'] ?? '',
      startHour: json['startHour'] ?? 0,
      startMinute: json['startMinute'] ?? 0,
      endHour: json['endHour'] ?? 0,
      endMinute: json['endMinute'] ?? 0,
    );
  }
}

class ItemQuantity {
  final String itemId;
  final int quantity;

  ItemQuantity({
    required this.itemId,
    required this.quantity,
  });

  factory ItemQuantity.fromJson(Map<String, dynamic> json) {
    return ItemQuantity(
      itemId: json['item_id'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }
}

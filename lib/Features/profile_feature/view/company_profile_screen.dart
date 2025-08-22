import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:safetyZone/Features/engineering_inspection_report_feature/data/services/engineering_inspection_report_api_service.dart';
import 'package:safetyZone/core/localization/app_localizations.dart';
import 'package:safetyZone/core/utils/constants/colors.dart';

class CompanyProfileScreen extends StatefulWidget {
  final String providerId;

  const CompanyProfileScreen({
    super.key,
    required this.providerId,
  });

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  Map<String, dynamic> installationFees =
      {}; // Map to hold installation fees data
  bool isLoading = true;
  Map<String, dynamic> providerData =
      <String, dynamic>{}; // Map to hold provider data
  void fetchData() async {
    final api = EngineeringInspectionReportApiService();

    final result = await api.getProvider(widget.providerId);

    if (result.success && result.data != null) {
      providerData = result.data!; // Map<String, dynamic>

      print("✅ Company Name: ${providerData['companyName']}");
      print("✅ Installation Fees: ${providerData['installationFees']}");

      setState(() {
        installationFees = providerData['installationFees'] ?? {};
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("❌ Error: ${result.message}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: SpinKitDoubleBounce(color: CColors.primary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ====== Header ======
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: 40.h,
                      left: 12.w,
                      right: 12.w,
                      bottom: 40.h,
                    ),
                    color: Colors.red.shade900,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                          const Spacer(),
                          //arrow back
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              textDirection: TextDirection.ltr,
                              size: 24.sp,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ====== Services ======
                  Container(
                    transform: Matrix4.translationValues(0, -30, 0),
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 120.h,
                              width: 100.w,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100.w,
                                    height: 100.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      color: Colors.grey[200],
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          providerData['image'] ??
                                              'https://via.placeholder.com/150',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    left: 16,
                                    right: 16,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Center(
                                        child: Text(
                                          localizations.translate("openNow"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber, size: 18.sp),
                                      SizedBox(width: 4.w),
                                      Text("4.8",
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(providerData['companyName'] ?? '',
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4.h),
                                  Text(
                                    providerData['address'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // SizedBox(height: 12.h),
                  // Divider(),
                  // SizedBox(height: 4.h),

                  // Working Hours
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.translate("workingHours"),
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Icon(Icons.add, color: Colors.red.shade900),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: buildWorkingHoursSection(
                        providerData['workingTime'] ?? [], localizations),
                  ),

                  SizedBox(height: 16.h),
                  // ====== Company Card ======
                  SizedBox(
                    height: 50.h,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.translate("installationFees"),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InstallationFeesAllScreen(
                                    installationFees: installationFees,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              localizations.translate("showAll"),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: CColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: InstallationFeesScreen(
                      installationFees: {
                        for (var entry in installationFees.entries)
                          entry.key: (entry.value as List).take(2).toList(),
                      },
                    ),
                  ),

                  SizedBox(height: 16.h),
                  // ====== Reviews ======
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.translate("customerReviews"),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ClientsReviewsScreen(),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: CColors.primary,
                                size: 18.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        _buildReviewCard(
                          name: "محمد الزهراني",
                          rating: 4.8,
                          image: "assets/user1.png",
                          comment: localizations.translate("review1"),
                        ),
                        _buildReviewCard(
                          name: "سارة المطيري",
                          rating: 4.9,
                          image: "assets/user2.png",
                          comment: localizations.translate("review2"),
                        ),
                        SizedBox(height: 64.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildWorkingHoursSection(
      List<dynamic> workingTime, AppLocalizations localizations) {
    if (workingTime.isEmpty) {
      return SizedBox.shrink();
    }

    // Flatten all workingDays من كل الـ workingTime
    final allDays =
        workingTime.expand((t) => t["workingDays"] as List).toList();

    String formatTime(int hour, int minute) {
      final h = hour.toString().padLeft(2, '0');
      final m = minute.toString().padLeft(2, '0');
      return "$h:$m";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.translate("workingHours"),
              style: TextStyle(
                color: Colors.red.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            Icon(Icons.access_time, color: Colors.red.shade900),
          ],
        ),
        SizedBox(height: 6.h),

        // List of working days
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: allDays.length,
          itemBuilder: (context, index) {
            final day = allDays[index];
            final start = formatTime(day["startHour"], day["startMinute"]);
            final end = formatTime(day["endHour"], day["endMinute"]);

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Text(
                "${day['day']}  |  $start - $end",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black87,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required double rating,
    required String image,
    required String comment,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 22.r, backgroundImage: AssetImage(image)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    Spacer(),
                    Icon(Icons.star, color: Colors.amber, size: 18.sp),
                    SizedBox(width: 4.w),
                    Text(rating.toString(),
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(comment,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InstallationFeesScreen extends StatefulWidget {
  final Map<String, dynamic> installationFees;

  const InstallationFeesScreen({
    super.key,
    required this.installationFees,
  });

  @override
  State<InstallationFeesScreen> createState() => _InstallationFeesScreenState();
}

class _InstallationFeesScreenState extends State<InstallationFeesScreen> {
  // بيانات محلية لكل قسم
  final List<Map<String, dynamic>> feesData = [];
  final Map<String, Map<String, dynamic>> categoryMapping = {
    "Fire pumps": {
      "title": "مضخات النار",
      "icon": Icons.water,
    },
    "Automatic Sprinklers": {
      "title": "الرشاشات التلقائية",
      "icon": Icons.water_drop,
    },
    "Fire Cabinets": {
      "title": "خزائن النار",
      "icon": Icons.archive,
    },
    "control panel": {
      "title": "لوحة التحكم",
      "icon": Icons.tune,
    },
    "Fire Alarm": {
      "title": "جرس إنذار",
      "icon": Icons.notifications_active,
    },
    "Smoke Detector": {
      "title": "كاشف دخان",
      "icon": Icons.fire_extinguisher,
    },
    "Glass Breaker": {
      "title": "كاسر زجاج",
      "icon": Icons.window,
    },
    "Emergency Lighting": {
      "title": "إنارة احتياطية",
      "icon": Icons.lightbulb,
    },

    // تقدر تكمل بقية الكاتيجوري اللي عندك
  };

// 🔥 هنا التعديل
  List<Map<String, dynamic>> convertFees(
      Map<String, dynamic> installationFees) {
    Map<String, List<Map<String, String>>> groupedItems = {};

    // loop على كل الأقسام (alarm-item, fire-system-item, ...)
    installationFees.forEach((category, items) {
      for (var fee in items) {
        final subCategory = fee["subCategory"];
        final itemNameAr = fee["itemName"]["ar"] ?? "";
        final price = "${fee["price"]} رس";

        if (!groupedItems.containsKey(subCategory)) {
          groupedItems[subCategory] = [];
        }

        groupedItems[subCategory]!.add({
          "name": itemNameAr,
          "normal": price,
          "addressed": "-", // مفيش عندك في الـ API → نخليها "-"
        });
      }
    });

    // حوّلها للشكل النهائي
    List<Map<String, dynamic>> result = [];

    groupedItems.forEach((subCategory, items) {
      final mapping = categoryMapping[subCategory];
      if (mapping != null) {
        result.add({
          "title": mapping["title"],
          "icon": mapping["icon"],
          "items": items,
        });
      }
    });

    return result;
  }

// متابعة العنصر المفتوح
  int expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    // تحويل البيانات من الـ API للشكل المطلوب
    feesData.addAll(convertFees(widget.installationFees));
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   appBar: AppBar(title: Text("أجور التركيب")),
    //   body: ,
    // );
    return Column(
      children: feesData.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final section = feesData[idx];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: ExpansionTile(
            initiallyExpanded: expandedIndex == idx,
            backgroundColor: Colors.grey.shade100,
            collapsedBackgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onExpansionChanged: (expanded) {
              setState(() {
                expandedIndex = expanded ? idx : -1;
              });
            },
            leading: Icon(section["icon"], color: CColors.secondary),
            title: Text(section["title"],
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            children: [
              _buildTable(section["items"]),
            ],
          ),
        );
      }).toList(),
    );
  }

  // جدول داخلي زي الصورة
  Widget _buildTable(List items) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade300),
        ),
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text("البند",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text("أجر التركيب",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
              ),
              // Padding(
              //   padding: EdgeInsets.all(8.w),
              //   child: Text("الأجر المعنون",
              //       style: TextStyle(
              //           fontWeight: FontWeight.bold, fontSize: 13.sp)),
              // ),
            ],
          ),
          // Rows
          ...items.map<TableRow>((item) {
            return TableRow(children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(item["name"], style: TextStyle(fontSize: 12.sp)),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(item["normal"], style: TextStyle(fontSize: 12.sp)),
              ),
              // Padding(
              //   padding: EdgeInsets.all(8.w),
              //   child:
              //       Text(item["addressed"], style: TextStyle(fontSize: 12.sp)),
              // ),
            ]);
          }),
        ],
      ),
    );
  }
}

class InstallationFeesAllScreen extends StatefulWidget {
  final Map<String, dynamic> installationFees;

  const InstallationFeesAllScreen({
    super.key,
    required this.installationFees,
  });

  @override
  State<InstallationFeesAllScreen> createState() =>
      _InstallationFeesAllScreenState();
}

class _InstallationFeesAllScreenState extends State<InstallationFeesAllScreen> {
  // بيانات محلية لكل قسم
  final List<Map<String, dynamic>> feesData = [];
  final Map<String, Map<String, dynamic>> categoryMapping = {
    "Fire pumps": {
      "title": "مضخات النار",
      "icon": Icons.water,
    },
    "Automatic Sprinklers": {
      "title": "الرشاشات التلقائية",
      "icon": Icons.water_drop,
    },
    "Fire Cabinets": {
      "title": "خزائن النار",
      "icon": Icons.archive,
    },
    "control panel": {
      "title": "لوحة التحكم",
      "icon": Icons.tune,
    },
    "Fire Alarm": {
      "title": "جرس إنذار",
      "icon": Icons.notifications_active,
    },
    "Smoke Detector": {
      "title": "كاشف دخان",
      "icon": Icons.fire_extinguisher,
    },
    "Heat Detector": {
      "title": "كاشف حرارة",
      "icon": Icons.fire_extinguisher,
    },
    "Glass Breaker": {
      "title": "كاسر زجاج",
      "icon": Icons.window,
    },
    "Emergency Lighting": {
      "title": "إنارة احتياطية",
      "icon": Icons.lightbulb,
    },

    // تقدر تكمل بقية الكاتيجوري اللي عندك
  };

// 🔥 هنا التعديل
  List<Map<String, dynamic>> convertFees(
      Map<String, dynamic> installationFees) {
    Map<String, List<Map<String, String>>> groupedItems = {};

    // loop على كل الأقسام (alarm-item, fire-system-item, ...)
    installationFees.forEach((category, items) {
      for (var fee in items) {
        final subCategory = fee["subCategory"];
        final itemNameAr = fee["itemName"]["ar"] ?? "";
        final price = "${fee["price"]} رس";

        if (!groupedItems.containsKey(subCategory)) {
          groupedItems[subCategory] = [];
        }

        groupedItems[subCategory]!.add({
          "name": itemNameAr,
          "normal": price,
          "addressed": "-", // مفيش عندك في الـ API → نخليها "-"
        });
      }
    });

    // حوّلها للشكل النهائي
    List<Map<String, dynamic>> result = [];

    groupedItems.forEach((subCategory, items) {
      final mapping = categoryMapping[subCategory];
      if (mapping != null) {
        result.add({
          "title": mapping["title"],
          "icon": mapping["icon"],
          "items": items,
        });
      }
    });

    return result;
  }

// متابعة العنصر المفتوح
  int expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    // تحويل البيانات من الـ API للشكل المطلوب
    feesData.addAll(convertFees(widget.installationFees));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate("installationFees"),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: CColors.primary,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: feesData.length,
              padding: EdgeInsets.all(16.w),
              itemBuilder: (context, index) {
                final section = feesData[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: ExpansionTile(
                    backgroundColor: Colors.grey.shade100,
                    collapsedBackgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    initiallyExpanded: expandedIndex == index,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        expandedIndex = expanded ? index : -1;
                      });
                    },
                    leading: Icon(section["icon"], color: CColors.secondary),
                    title: Text(section["title"],
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    children: [
                      _buildTable(section["items"]),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 64.h),
        ],
      ),
    );
  }

  // جدول داخلي زي الصورة
  Widget _buildTable(List items) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade300),
        ),
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text("البند",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text("أجر التركيب",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
              ),
              // Padding(
              //   padding: EdgeInsets.all(8.w),
              //   child: Text("الأجر المعنون",
              //       style: TextStyle(
              //           fontWeight: FontWeight.bold, fontSize: 13.sp)),
              // ),
            ],
          ),
          // Rows
          ...items.map<TableRow>((item) {
            return TableRow(children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(item["name"], style: TextStyle(fontSize: 12.sp)),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(item["normal"], style: TextStyle(fontSize: 12.sp)),
              ),
              // Padding(
              //   padding: EdgeInsets.all(8.w),
              //   child:
              //       Text(item["addressed"], style: TextStyle(fontSize: 12.sp)),
              // ),
            ]);
          }),
        ],
      ),
    );
  }
}

class ClientsReviewsScreen extends StatefulWidget {
  const ClientsReviewsScreen({super.key});

  @override
  State<ClientsReviewsScreen> createState() => _ClientsReviewsScreenState();
}

class _ClientsReviewsScreenState extends State<ClientsReviewsScreen> {
  // بيانات محلية للريفيوهات
  final List<Map<String, dynamic>> reviews = [
    {
      "name": "أحمد محمد",
      "rating": 4.5,
      "image": "assets/images/splash.png",
      "comment": "خدمة ممتازة جدًا والتعامل راقي."
    },
    {
      "name": "منى علي",
      "rating": 5.0,
      "image": "assets/images/splash.png",
      "comment": "أعجبتني سرعة الاستجابة والتنفيذ."
    },
    {
      "name": "خالد يوسف",
      "rating": 4.0,
      "image": "assets/images/splash.png",
      "comment": "جودة جيدة ولكن محتاجين بعض التحسينات."
    },
    {
      "name": "سارة حسن",
      "rating": 4.8,
      "image": "assets/images/splash.png",
      "comment": "تجربة رائعة وسأكرر التعامل معهم."
    },
    {
      "name": "محمود إبراهيم",
      "rating": 5.0,
      "image": "assets/images/splash.png",
      "comment": "كل شيء تمام 👍."
    },
  ];

  // نعرض أول 3 فقط كبداية
  int itemsToShow = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "آراء العملاء",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: CColors.primary,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: itemsToShow,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return _buildReviewCard(
                    name: review["name"],
                    rating: review["rating"],
                    image: review["image"],
                    comment: review["comment"],
                  );
                },
              ),
            ),
            if (itemsToShow < reviews.length)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllClientsReviewsScreen(reviews: reviews),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "عرض المزيد",
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required double rating,
    required String image,
    required String comment,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 22.r, backgroundImage: AssetImage(image)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    const Spacer(),
                    Icon(Icons.star, color: Colors.amber, size: 18.sp),
                    SizedBox(width: 4.w),
                    Text(rating.toString(),
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(comment,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// شاشة عرض كل العملاء
class AllClientsReviewsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;

  const AllClientsReviewsScreen({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("كل آراء العملاء")),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                      radius: 22.r,
                      backgroundImage: AssetImage(review["image"])),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(review["name"],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp)),
                            const Spacer(),
                            Icon(Icons.star, color: Colors.amber, size: 18.sp),
                            SizedBox(width: 4.w),
                            Text(review["rating"].toString(),
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(review["comment"],
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

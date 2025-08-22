import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safetyZone/core/localization/app_localizations.dart';

class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                      offset: Offset(0, 3))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: Colors.grey[200],
                          image: DecorationImage(
                            image: AssetImage("assets/icons/logo.png"),
                            fit: BoxFit.cover,
                          ),
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
                            Text(localizations.translate("companyName"),
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 4.h),
                            Text(localizations.translate("companyAddress"),
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(localizations.translate("openNow"),
                            style: TextStyle(
                                color: Colors.green, fontSize: 12.sp)),
                      )
                    ],
                  ),

                  SizedBox(height: 12.h),
                  Divider(),
                  SizedBox(height: 4.h),

                  // Working Hours
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(localizations.translate("workingHours"),
                          style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold)),
                      // Icon(Icons.add, color: Colors.red.shade900),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text("السبت : الخميس  |  7am - 12am",
                      style: TextStyle(fontSize: 13.sp)),
                ],
              ),
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InstallationFeesAllScreen(),
                          ),
                        );
                      },
                      child: Text(
                        localizations.translate("showAll"),
                        style: TextStyle(fontSize: 14.sp, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: InstallationFeesScreen(),
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
                      Text(localizations.translate("customerReviews"),
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.bold)),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InstallationFeesAllScreen(),
                            ),
                          );
                        },
                        child: Text(
                          localizations.translate("showAll"),
                          style: TextStyle(fontSize: 14.sp, color: Colors.black),
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

  Widget _buildServiceItem(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 22.sp),
          SizedBox(width: 12.w),
          Text(title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
        ],
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
  const InstallationFeesScreen({super.key});

  @override
  State<InstallationFeesScreen> createState() => _InstallationFeesScreenState();
}

class _InstallationFeesScreenState extends State<InstallationFeesScreen> {
  // بيانات محلية لكل قسم
  final List<Map<String, dynamic>> feesData = [
    {
      "title": "لوحة التحكم",
      "icon": Icons.tune,
      "items": [
        {"name": "لوحة تحكم zone-1", "normal": "350 رس", "addressed": "-"},
        {"name": "لوحة تحكم zone-2", "normal": "350 رس", "addressed": "-"},
        {"name": "لوحة تحكم loop-1/2", "normal": "-", "addressed": "150 رس"},
        {"name": "لوحة تحكم zone-16", "normal": "350 رس", "addressed": "-"},
        {"name": "لوحة تحكم zone-24", "normal": "-", "addressed": "150 رس"},
        {"name": "لوحة تحكم zone-8", "normal": "350 رس", "addressed": "-"},
        {"name": "لوحة تحكم loop-1/4", "normal": "-", "addressed": "150 رس"},
      ]
    },
    {
      "title": "كاشف الحريق",
      "icon": Icons.fire_extinguisher,
      "items": [
        {"name": "كاشف دخان", "normal": "100 رس", "addressed": "-"},
        {"name": "كاشف حرارة", "normal": "120 رس", "addressed": "-"},
      ]
    },
    {
      "title": "جرس انذار",
      "icon": Icons.notifications_active,
      "items": [
        {"name": "جرس صغير", "normal": "80 رس", "addressed": "-"},
        {"name": "جرس كبير", "normal": "150 رس", "addressed": "-"},
      ]
    }
  ];

  // متابعة العنصر المفتوح
  int expandedIndex = -1;

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onExpansionChanged: (expanded) {
              setState(() {
                expandedIndex = expanded ? idx : -1;
              });
            },
            leading: Icon(section["icon"], color: Colors.blue),
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
                child: Text("الأجر العادي",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text("الأجر المعنون",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
              ),
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
              Padding(
                padding: EdgeInsets.all(8.w),
                child:
                    Text(item["addressed"], style: TextStyle(fontSize: 12.sp)),
              ),
            ]);
          }),
        ],
      ),
    );
  }
}

class InstallationFeesAllScreen extends StatefulWidget {
  const InstallationFeesAllScreen({super.key});

  @override
  State<InstallationFeesAllScreen> createState() =>
      _InstallationFeesAllScreenState();
}

class _InstallationFeesAllScreenState extends State<InstallationFeesAllScreen> {
  // بيانات محلية لكل قسم
  final List<Map<String, dynamic>> feesData = [
    {
      "title": "لوحة التحكم",
      "icon": Icons.tune,
      "items": [
        {"name": "لوحة تحكم zone-1", "normal": "350 رس", "addressed": "-"},
        {"name": "لوحة تحكم zone-2", "normal": "350 رس", "addressed": "-"},
        {"name": "لوحة تحكم loop-1/2", "normal": "-", "addressed": "150 رس"},
        {"name": "لوحة تحكم zone-16", "normal": "350 رس", "addressed": "-"},
        {"name": "لوحة تحكم zone-24", "normal": "-", "addressed": "150 رس"},
        {"name": "لوحة تحكم zone-8", "normal": "350 رس", "addressed": "-"},
        {"name": "لوحة تحكم loop-1/4", "normal": "-", "addressed": "150 رس"},
      ]
    },
    {
      "title": "كاشف الحريق",
      "icon": Icons.fire_extinguisher,
      "items": [
        {"name": "كاشف دخان", "normal": "100 رس", "addressed": "-"},
        {"name": "كاشف حرارة", "normal": "120 رس", "addressed": "-"},
      ]
    },
    {
      "title": "جرس إنذار",
      "icon": Icons.notifications_active,
      "items": [
        {"name": "جرس صغير", "normal": "80 رس", "addressed": "-"},
        {"name": "جرس كبير", "normal": "150 رس", "addressed": "-"},
      ]
    },
    {
      "title": "كاسر زجاج",
      "icon": Icons.window,
      "items": [
        {"name": "كاسر زجاج عادي", "normal": "50 رس", "addressed": "-"},
        {"name": "كاسر زجاج معنون", "normal": "-", "addressed": "120 رس"},
      ]
    },
    {
      "title": "إنارة احتياطية",
      "icon": Icons.lightbulb,
      "items": [
        {"name": "إنارة احتياطية صغيرة", "normal": "100 رس", "addressed": "-"},
        {"name": "إنارة احتياطية كبيرة", "normal": "150 رس", "addressed": "-"},
      ]
    },
    {
      "title": "مخرج الطوارئ",
      "icon": Icons.exit_to_app,
      "items": [
        {"name": "لوحة إرشادية صغيرة", "normal": "70 رس", "addressed": "-"},
        {"name": "لوحة إرشادية كبيرة", "normal": "100 رس", "addressed": "-"},
      ]
    },
    {
      "title": "مضخات النار",
      "icon": Icons.water,
      "items": [
        {"name": "مضخة صغيرة", "normal": "300 رس", "addressed": "-"},
        {"name": "مضخة كبيرة", "normal": "500 رس", "addressed": "-"},
      ]
    },
    {
      "title": "الرشاشات التلقائية",
      "icon": Icons.water_drop,
      "items": [
        {"name": "رشاش سقفي", "normal": "80 رس", "addressed": "-"},
        {"name": "رشاش جداري", "normal": "100 رس", "addressed": "-"},
      ]
    },
    {
      "title": "خزائن النار",
      "icon": Icons.archive,
      "items": [
        {"name": "خزانة صغيرة", "normal": "200 رس", "addressed": "-"},
        {"name": "خزانة كبيرة", "normal": "300 رس", "addressed": "-"},
      ]
    },
    {
      "title": "صيانة طفاية الحريق",
      "icon": Icons.build,
      "items": [
        {"name": "طفاية صغيرة", "normal": "50 رس", "addressed": "-"},
        {"name": "طفاية كبيرة", "normal": "80 رس", "addressed": "-"},
      ]
    },
  ];

  // متابعة العنصر المفتوح
  int expandedIndex = -1;

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
        backgroundColor: Colors.red.shade900,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    initiallyExpanded: expandedIndex == index,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        expandedIndex = expanded ? index : -1;
                      });
                    },
                    leading: Icon(section["icon"], color: Colors.blue),
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
                child: Text("الأجر العادي",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text("الأجر المعنون",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
              ),
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
              Padding(
                padding: EdgeInsets.all(8.w),
                child:
                    Text(item["addressed"], style: TextStyle(fontSize: 12.sp)),
              ),
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
      "image": "assets/images/user1.png",
      "comment": "خدمة ممتازة جدًا والتعامل راقي."
    },
    {
      "name": "منى علي",
      "rating": 5.0,
      "image": "assets/images/user2.png",
      "comment": "أعجبتني سرعة الاستجابة والتنفيذ."
    },
    {
      "name": "خالد يوسف",
      "rating": 4.0,
      "image": "assets/images/user3.png",
      "comment": "جودة جيدة ولكن محتاجين بعض التحسينات."
    },
    {
      "name": "سارة حسن",
      "rating": 4.8,
      "image": "assets/images/user4.png",
      "comment": "تجربة رائعة وسأكرر التعامل معهم."
    },
    {
      "name": "محمود إبراهيم",
      "rating": 5.0,
      "image": "assets/images/user5.png",
      "comment": "كل شيء تمام 👍."
    },
  ];

  // نعرض أول 3 فقط كبداية
  int itemsToShow = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("آراء العملاء")),
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
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
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
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 22.r, backgroundImage: AssetImage(review["image"])),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(review["name"],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14.sp)),
                            const Spacer(),
                            Icon(Icons.star, color: Colors.amber, size: 18.sp),
                            SizedBox(width: 4.w),
                            Text(review["rating"].toString(),
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(review["comment"],
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safetyZone/Features/chat_feature/view/chat_screen.dart';
import 'package:safetyZone/core/localization/app_localizations.dart';
import 'package:safetyZone/core/utils/constants/colors.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  // TODO: Replace with actual chat list from your state management
  final List<Map<String, dynamic>> chats = [
    {
      'id': '1',
      'providerName': 'شركة الأمان المتكاملة',
      'lastMessage': 'نعم، يمكنني مساعدتك في ذلك',
      'time': '10:30 ص',
      'unreadCount': 2,
    },
    {
      'id': '2',
      'providerName': 'الدفاع المدني',
      'lastMessage': 'تم استلام طلبك وسيتم الرد قريباً',
      'time': 'أمس',
      'unreadCount': 0,
    },
  ];
  List<Map<String, dynamic>> filteredChats = [];
  @override
  void initState() {
     super.initState();
    // Initialize filteredChats with all chats
    filteredChats = List.from(chats);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isArabic = localizations.isArabic();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CColors.secondary,
        title: Text(
          localizations.translate('chats'),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Almarai',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 60.h,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: CColors.secondary,
                ),
              ),
              Container(
                height: 32.h,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: CColors.white,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    // Handle search logic here
                    _handleSearch(value);
                  },
                  decoration: InputDecoration(
                    hintText: localizations.translate('search'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: CColors.borderPrimary),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                    prefixIcon: Icon(
                      Icons.search,
                      color: CColors.textGrey,
                      size: 20.sp,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index];
                return _buildChatItem(context, chat, isArabic);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(
      BuildContext context, Map<String, dynamic> chat, bool isArabic) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ChatScreen(
          //       providerId: chat['id'],
          //       providerName: chat['providerName'],
          //     ),
          //   ),
          // );
        },
        leading: CircleAvatar(
          backgroundColor: CColors.secondary,
          child: Text(
            chat['providerName'][0],
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          chat['providerName'],
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Almarai',
          ),
        ),
        subtitle: Text(
          chat['lastMessage'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            fontFamily: 'Almarai',
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chat['time'],
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontFamily: 'Almarai',
              ),
            ),
            if (chat['unreadCount'] > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: CColors.secondary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  chat['unreadCount'].toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
          ],
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
    );
  }

  void _handleSearch(String value) {
    // Implement search logic here
    // For example, filter the chat list based on the search value
    setState(() {
      filteredChats = chats.where((chat) => chat['providerName'].contains(value)).toList();
    });
  }
}

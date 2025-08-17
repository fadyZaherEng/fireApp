import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safetyZone/Features/chat_feature/view/chat_view.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/constants/colors.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_states.dart';

class ChatsListView extends StatelessWidget {
  const ChatsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit()..fetchChats(),
      child: const ChatsListContent(),
    );
  }
}

class ChatsListContent extends StatefulWidget {
  const ChatsListContent({super.key});

  @override
  State<ChatsListContent> createState() => _ChatsListContentState();
}

class _ChatsListContentState extends State<ChatsListContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('chats'),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ChatCubit, ChatStates>(
        builder: (context, state) {
          if (state is ChatLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatErrorState) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(fontSize: 16.sp, color: Colors.red),
              ),
            );
          } else if (state is ChatsLoadedState) {
            if (state.chats.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.translate('no_chats_found'),
                  style: TextStyle(fontSize: 16.sp),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25.r,
                    backgroundImage: chat.avatarUrl != null
                        ? NetworkImage(chat.avatarUrl!)
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                  ),
                  title: Text(
                    chat.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    chat.lastMessage ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chat.timeAgo,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            color: CColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to chat view
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatView(chatId: chat.id),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

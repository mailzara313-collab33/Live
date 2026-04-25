import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Model/personalChatHistory.dart';

import 'package:eshop_multivendor/Screen/converstationScreen.dart';
import 'package:eshop_multivendor/cubits/converstationCubit.dart';
import 'package:eshop_multivendor/cubits/sendMessageCubit.dart';
import 'package:eshop_multivendor/repository/chatRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChateWithSeller extends StatelessWidget {
  final Product? model;
  const ChateWithSeller({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () async {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => ConverstationCubit(ChatRepository()),
                  ),
                  BlocProvider(
                      create: (_) => SendMessageCubit(ChatRepository()))
                ],
                child: ConverstationScreen(
                  isGroup: false,
                  personalChatHistory: PersonalChatHistory(
                    unreadMsg: '1',
                    opponentUserId: model?.seller_id,
                    opponentUsername: model?.seller_name,
                    image: model?.seller_profile,
                  ),
                ),
              ),
            ),
          );
        },
        child: ListTile(
          dense: true,
          title: Row(
            children: [
              Text(
                'CHATE_WITH_SELLER'.translate(context: context),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.black,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Ubuntu',
                  fontStyle: FontStyle.normal,
                  fontSize: textFontSize16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                model!.store_name ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(
                  color: Color(0xfffc6a57),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Ubuntu',
                  fontStyle: FontStyle.normal,
                  fontSize: textFontSize16,
                ),
              )),
            ],
          ),
          trailing: Icon(
            Icons.navigate_next,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

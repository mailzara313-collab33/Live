import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/groupDetails.dart';
import 'package:eshop_multivendor/Model/groupMember.dart';

import 'package:eshop_multivendor/widgets/appBar.dart';
import 'package:flutter/material.dart';

class GroupInfoScreen extends StatefulWidget {
  final GroupDetails groupDetails;
  const GroupInfoScreen({super.key, required this.groupDetails});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  late final TextEditingController _titleTextEditingController =
      TextEditingController();
  late final TextEditingController _descriptionEditinngController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    setGroupTitleAndDescription();
  }

  void setGroupTitleAndDescription() {
    _titleTextEditingController.text = widget.groupDetails.title ?? '';
    _descriptionEditinngController.text = widget.groupDetails.description ?? '';
  }

  @override
  void dispose() {
    _titleTextEditingController.dispose();
    _descriptionEditinngController.dispose();
    super.dispose();
  }

  Widget _buildTitleTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(circularBorderRadius10),
      ),
      child: TextFormField(
        enabled: false,
        controller: _titleTextEditingController,
        decoration: InputDecoration(
            labelText: 'GROUP_TITLE'.translate(context: context)),
      ),
    );
  }

  Widget _buildDescriptionTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(circularBorderRadius10),
      ),
      child: TextFormField(
        enabled: false,
        controller: _descriptionEditinngController,
        validator: (value) {
          if ((value ?? '').isEmpty) {
            return 'Please enter description';
          }
          return null;
        },
        decoration: InputDecoration(
            labelText: 'DESCRIPTION'.translate(context: context)),
      ),
    );
  }

  Widget _buildGroupDetails() {
    return Column(
      children: [
        _buildTitleTextField(),
        const SizedBox(
          height: 10,
        ),
        _buildDescriptionTextField()
      ],
    );
  }

  Widget _buildGroupMemberContainer({required GroupMember groupMember}) {
    return ListTile(
      leading: (groupMember.image ?? '').isEmpty
          ? const Icon(Icons.person)
          : SizedBox(
              height: 25, width: 25, child: Image.network(groupMember.image!)),
      contentPadding: const EdgeInsets.all(0),
      title: Text(groupMember.username ?? ''),
      trailing: groupMember.isAdmin == '1'
          ? Text(
              'GROUP_ADMIN'.translate(context: context),
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          : const SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getSimpleAppBar(
        'GROUP_INFO'.translate(context: context),
        context,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupDetails(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'MEMBERS'.translate(context: context),
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.w600),
              ),
            ),
            ...(widget.groupDetails.groupMembers ?? []).map((groupMember) =>
                _buildGroupMemberContainer(groupMember: groupMember))
          ],
        ),
      ),
    );
  }
}

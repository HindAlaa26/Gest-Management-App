import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/widgets/info_row.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';

class DeliveryRoomCard extends StatelessWidget {
  const DeliveryRoomCard({super.key});

  @override
  Widget build(BuildContext context) {
    final room = Session.currentStay?.roomNumber;

    return RoyalCard(
      padding: const EdgeInsets.all(14),
      child: InfoRow(
        icon: Icons.meeting_room_outlined,
        label: 'Delivering to',
        text: room == null ? 'Your room' : 'Room $room',
      ),
    );
  }
}

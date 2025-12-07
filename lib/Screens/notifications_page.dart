import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Mock Data: In a real app, this would come from Firestore
  List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'title': 'Амжилттай!',
      'body': 'Та Python хичээлийн 1-р бүлгийг амжилттай дуусгалаа. +10 XP',
      'time': '2 цагийн өмнө',
      'type': 'success', // success, info, alert
      'isRead': false,
    },
    {
      'id': 2,
      'title': 'Шинэ хичээл',
      'body': 'Java хэлний шинэ "Object Oriented Programming" хичээл нэмэгдлээ.',
      'time': '1 өдрийн өмнө',
      'type': 'info',
      'isRead': true,
    },
    {
      'id': 3,
      'title': 'Сануулга',
      'body': 'Өнөөдөр хичээлээ хийхээ мартуузай! Таны "Streak" тасрах дөхлөө.',
      'time': '2 өдрийн өмнө',
      'type': 'alert',
      'isRead': true,
    },
    {
      'id': 4,
      'title': 'Системийн шинэчлэл',
      'body': 'Бид аппликейшнээ шинэчиллээ. Шинэ боломжуудыг туршиж үзээрэй.',
      'time': '1 долоо хоногийн өмнө',
      'type': 'info',
      'isRead': true,
    },
  ];

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Мэдэгдэл устгагдлаа'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Мэдэгдэл',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // Hide back button as it's a tab
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  notifications.clear();
                });
              },
              child: const Text('Бүгдийг арилгах'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Dismissible(
                  key: Key(item['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white, size: 30),
                  ),
                  onDismissed: (direction) => _deleteNotification(index),
                  child: _buildNotificationCard(item),
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (item['type']) {
      case 'success':
        icon = Icons.check_circle;
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'alert':
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case 'info':
      default:
        icon = Icons.info;
        color = const Color(0xFF1976D2);
        bgColor = Colors.blue.shade50;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            if (item['isRead'] == false)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              item['body'],
              style: TextStyle(color: Colors.grey[600], height: 1.3),
            ),
            const SizedBox(height: 8),
            Text(
              item['time'],
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 60,
              color: Colors.blue.shade200,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Мэдэгдэл алга',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Танд одоогоор шинэ мэдэгдэл ирээгүй байна.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
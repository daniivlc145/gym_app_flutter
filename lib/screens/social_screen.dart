import 'package:flutter/material.dart';
import 'package:gym_app/screens/profile_screen.dart';
import '../widgets/training_feed_card.dart';
import 'package:gym_app/services/training_service.dart';
import 'package:gym_app/services/user_service.dart';

import 'otro_profile_screen.dart';

class SocialScreen extends StatefulWidget {
  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final TrainingService _trainingService = TrainingService();
  late Future<List<Map<String, dynamic>>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = _trainingService.getFeedEntrenamientos(limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _feedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay entrenamientos para mostrar"));
          }

          final feedData = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: feedData.length,
            itemBuilder: (context, index) {
              final training = feedData[index];
              return TrainingFeedCard(
                trainingData: training,
                onUserTap: () async {
                  final clickedUserId = training['usuario']['pk_usuario'];
                  final currentUserId =
                      UserService().supabase.auth.currentUser?.id;

                  if (clickedUserId == currentUserId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OtroProfileScreen(
                          userId: clickedUserId,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
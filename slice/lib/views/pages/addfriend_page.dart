import 'package:flutter/material.dart';
import 'package:slice/services/friend/friend_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final _friendEmailController = TextEditingController();
  final friendService = FriendService();

  bool _isEmailEmpty = true;

  @override
  void initState() {
    super.initState();
    _friendEmailController.addListener(() {
      setState(() {
        _isEmailEmpty = _friendEmailController.text.isEmpty;
      });
    });
  }

  void sendRequest() async {
    final targetEmail = _friendEmailController.text;
    try {
      await friendService.sendFriendRequest(targetEmail);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Friend request sent!")));
      _friendEmailController.clear();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void acceptRequest(String requestId, fromUid) async {
    try {
      await friendService.acceptFriendRequest(
        requestId,
        fromUid,
        FirebaseAuth.instance.currentUser!.uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Friend request accepted!")));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void rejectRequest(String requestId) async {
    try {
      await friendService.rejectFriendRequest(requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Friend request rejected!")));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _friendEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 255, 245, 1),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color.fromRGBO(246, 255, 245, 1),
        title: Text(
          'Add Friend',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _friendEmailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Email',
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Color.fromRGBO(153, 226, 145, 1),
              ),
              onPressed: _isEmailEmpty ? null : sendRequest,
              child: Text('Send Request'),
            ),

            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: Divider(thickness: 1, color: Colors.black12)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Requests for you',
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
                Expanded(child: Divider(thickness: 1, color: Colors.black12)),
              ],
            ),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: friendService.getFriendRequests(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final requests = snapshot.data!;
                  if (requests.isEmpty) {
                    return const Center(child: Text("No friend requests"));
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final requestId =
                          "${request['fromUid']}_${request['toUid']}";
                      final fromUid = request['fromUid'];
                      final fromUsername = request['fromUsername'];
                      final profilePic = request['fromProfilePic'];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: profilePic != null && profilePic != ''
                            ? NetworkImage(profilePic) 
                            : AssetImage('assets/slice_logo.jpeg')
                            ),
                          title: Text(fromUsername),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  acceptRequest(requestId, fromUid);
                                },
                                icon: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  rejectRequest(requestId);
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

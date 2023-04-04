import 'package:ambulance_tracker/screens/patient_page.dart';
import 'package:ambulance_tracker/services/notifications.dart';
import 'package:ambulance_tracker/services/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/drivers.dart';
import 'all_drivers.dart';

class HospitalPage extends StatefulWidget {
  const HospitalPage({Key? key}) : super(key: key);

  @override
  _HospitalPageState createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  String number = '';
  int count = 0;
  List id = [];
  NotificationsServices notificationsServices = NotificationsServices();

  @override
  void initState() {
    number = bookedUsers.length.toString();
    notificationsServices.InitializeSettings();
    super.initState();
  }

  final fireStore =
      FirebaseFirestore.instance.collection('Bookings').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        color: const Color.fromRGBO(143, 148, 251, 0.75),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 48),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: RichText(
                              text: const TextSpan(
                                  text:
                                      "Hospital Dashboard         ", //let the spaces be for alignment
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'you have got ' +
                                  number +
                                  ' requests\ncurrently!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 250,
                        child: StreamBuilder<QuerySnapshot>(
                            stream: fireStore,
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return const Center(child: Text('Some error'));
                              }
                             
                               return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                   return _buildRequestsCard(
                                    
                                    index: index,
                                    title: "Name: " +
                                        snapshot.data!.docs[index]['user'],
                                    subject: "Location",
                                    text: snapshot.data!.docs[index]['loc'],
                                    id: snapshot.data!.docs[index].id,
                                  );
                                },
                              
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: double.infinity,
                  maxHeight: double.maxFinite,
                ),
                child: Container(
                  height: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 1,
                        spreadRadius: 0.0,
                        offset: Offset(
                            -1.0, -1.0), // shadow direction: bottom right
                      )
                    ],
                  ),
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        SizedBox(
                          height: 250,
                          child: PageView(
                            controller: PageController(
                                viewportFraction: 1, initialPage: 1),
                            scrollDirection: Axis.horizontal,
                            pageSnapping: false,
                            children: <Widget>[
                              _buildItemCard(
                                  title: "Drivers Status",
                                  total: "Total: 11",
                                  totalNum: 11,
                                  color: Colors.blue,
                                  icon: FontAwesomeIcons.addressCard,
                                  onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ShowDrivers()),
                                      )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(
      {required String title,
      String? total,
      required int totalNum,
      Color? color,
      IconData? icon,
      GestureTapCallback? onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                children: [
                  WidgetSpan(
                      child: FaIcon(
                    icon,
                    color: color,
                    size: 40,
                  )),
                ],
              )),
              const SizedBox(height: 25),
              RichText(
                  text: TextSpan(
                      text: title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                      ))),
              const SizedBox(height: 20),
              const Divider(
                thickness: 1,
              ),
              RichText(
                  text: TextSpan(
                      text: total,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ))),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsCard({
    required String title,
    String? subject,
    required var id,
    required int index,
    required String text,
  }) {
    return Container(
      height: 120,
      width: 270,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40), color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                  text: subject,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                  text: text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      checkAvailability(index, id);
                    },
                    child: const Text('Confirm')),
                const SizedBox(
                  width: 50,
                ),
                ElevatedButton(
                    onPressed: () {
                      cancelBooking(index, id);
                    },
                    child: const Text('cancel')),
              ],
            )
          ],
        ),
      ),
    );
  }

  void checkAvailability(int index, var fid) async {
    for (var e in drivers) {
      if (e['isFree'] && e['isAvailable']) {
        id.add(e['id']);
      } else {
        print('not available');
      }
    }
    print(id);
    if (id.isEmpty) {
        notificationsServices.sendNotification(
        'AmbuTech',
        'Sorry Ambulance is unavailable at the moment please try another hospital ',
      );
      await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(fid)
          .update({"Booked": false});
      Fluttertoast.showToast(
          msg: "Ambulance not available",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      notificationsServices.sendNotification(
        'AmbuTech',
        'Booking Confirmed! Ambulance will arrive shortly ',
      );
      await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(fid)
          .update({"Booked": true});

      Fluttertoast.showToast(
          msg: "Booking confirmed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    drivers[id[0] - 1]['isAvailable'] = false;
    drivers[id[0] - 1]['isFree'] = false;
    id.clear();

    setState(() {
      number = bookedUsers.length.toString();
      bookedUsers.removeAt(index);
    });
  }

  void cancelBooking(int index, var id) async {
    notificationsServices.sendNotification(
        'AmbuTech',
        'Sorry Ambulance is unavailable at the moment please try another hospital ',
      );
    await FirebaseFirestore.instance.collection('Bookings').doc(id).delete();
    setState(() {
      number = bookedUsers.length.toString();
      bookedUsers.removeAt(index);
    });
    Fluttertoast.showToast(
        msg: "Booking canceled",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

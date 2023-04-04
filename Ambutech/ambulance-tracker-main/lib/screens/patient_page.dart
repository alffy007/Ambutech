import 'dart:math';
import 'package:ambulance_tracker/services/MapUtils.dart';
import 'package:ambulance_tracker/services/current_location.dart';
import 'package:ambulance_tracker/services/hospitals.dart';
import 'package:ambulance_tracker/services/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({Key? key}) : super(key: key);

  @override
  _PatientPageState createState() => _PatientPageState();
}

String currLoc = "";
var details = [];
String date_time = "", address = "";
var loc = [];
List hos = [];
bool? isSelected;
Random random = Random();
int randomNumber = random.nextInt(6);

class _PatientPageState extends State<PatientPage> {
  @override
  void initState() {
    super.initState();
       
    currentLoc();
    setState(() {
      isSelected = false;
      hos.clear();
      hos.addAll(hospitals);
    });
  }

  @override
  Widget build(BuildContext context) {
    currentLoc();

    try {
      loc[0];
    } catch (e) {
      currentLoc();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
      ),
      backgroundColor: const Color.fromRGBO(222, 224, 252, 1),
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                child: const Text("Refresh location"),
                onPressed: () async {
                  setState(() {
                    hos.clear();
                    hos.addAll(hospitals);
                  });
                  currentLoc();
                  date_time = currLoc.split("{}")[0];
                  address = currLoc.split("{}")[2];
                  loc = currLoc.split("{}")[1].split(" , ");

                  setState(() {
                    currLoc;
                    date_time;
                    address;
                    loc;
                  });
                }),
            Card(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Date: " + date_time),
                  Text("Address: " + address),
                  //Text("Location: " + loc[0] + ", " + loc[1]),
                ],
              ),
            ),
            ElevatedButton(
                child: const Text("See nearby hospitals"),
                onPressed: () async {
                  MapUtils.openMap(double.parse(loc[0]), double.parse(loc[1]));
                }),
            ElevatedButton(
                child: const Text("See nearby ambulance"),
                onPressed: () async {
                  MapUtils.openMap2(double.parse(loc[1]), double.parse(loc[1]));
                }),
            Expanded(
              child: getHosps(),
            ),
          ],
        ),
      ),
    );
  }

  void currentLoc() async {
    currLoc = await getLoc();
    date_time = currLoc.split("{}")[0];
    address = currLoc.split("{}")[2];
    loc = currLoc.split("{}")[1].split(" , ");
  }

  getHosps() {
    return ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(25),
        itemCount: hos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              height: 120,
              width: 200,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade600,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(40),
                color: const Color.fromRGBO(143, 148, 251, 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      hos[index]['name'],
                      style: const TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      hospitals[index]['location'],
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 50,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSelected! ? Colors.grey : Colors.white,
                            shape: StadiumBorder(),
                          ),
                          onPressed: () {
                            setState(() {
                              hos.clear();
                              hos.add(hospitals[index]);
                              isSelected = true;
                              Random random = Random();
                              int randomNumber = random.nextInt(6);
                              bookedUsers.add({
                                'hospital': hospitals[index]['name'],
                                'user': names[randomNumber],
                                'loc': address
                              });
                              bookUser(index);
                            });
                            Fluttertoast.showToast(
                                msg:
                                    "Hospital chosen, you'll be notified about the ambulance",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                          child: const Text(
                            'Book',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: StadiumBorder(),
                            ),
                            onPressed: () {
                              isSelected!
                                  ? setState(
                                      () {
                                        hos.clear();
                                        bookedUsers.clear();
                                       
                                      },
                                    )
                                  : setState(() {
                                      hos.removeAt(index);
                                    });
                              Fluttertoast.showToast(
                                  msg: "Hospital rejected",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black),
                            )),
                        const SizedBox(
                          width: 40,
                        ),
                        const Icon(Icons.location_on)
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future bookUser(int index) async {
   
    final docUser = FirebaseFirestore.instance.collection('Bookings').doc();
      Random random = Random();
      int randomNumber = random.nextInt(6);
      final json = {
        'hospital': hospitals[index]['name'],
        'Booked': false,
        'user': names[randomNumber],
        'loc': address
      };
      await docUser.set(json);
  }
}

import 'dart:async';
import 'dart:io';

import 'package:cnmci/konan/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'objets/constants.dart';

class InterfaceRegularisationManuelle extends StatefulWidget {
  const InterfaceRegularisationManuelle({super.key});

  @override
  State<InterfaceRegularisationManuelle> createState() => _InterfaceRegularisationManuelle();
}

class _InterfaceRegularisationManuelle extends State<InterfaceRegularisationManuelle> {

  // A t t r i b u t e s  :
  TextEditingController dateController = TextEditingController();
  TextEditingController transactionIdController = TextEditingController();
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;



  // METHODS :
  @override
  void initState() {
    super.initState();

  }

  void displayRequestingForRegularisation(){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return PopScope(
              canPop: false,
              child: AlertDialog(
                  title: Text('Information'),
                  content: SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          Text('Veuillez patienter ...'),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child:
                              CircularProgressIndicator(
                                valueColor:
                                AlwaysStoppedAnimation<
                                    Color>(Colors.blue),
                                strokeWidth: 3.0,
                              ))
                        ],
                      )
                  )
              )
          );
        });

    flagSendData = true;
    flagServerResponse = true;

    requestingForRegularisation();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            displayToast("Veuillez vérifier vos données !");
            // Close :
            Navigator.pop(context);
          }
        }
      },
    );
  }

  Future<void> requestingForRegularisation() async {
    // First Call this :
    var localToken = await MesServices().checkJwtExpiration();
    var pathRequest = '${dateController.text}/${transactionIdController.text.trim()}';
    final url = Uri.parse('${dotenv.env['URL_BACKEND']}get-regularisation-checkout/$pathRequest');
    try {
      var response = await get(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          }
      ).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        flagSendData = false;
      } else {
        displayToast("Impossible de procéder à la régularisation !");
      }
    } catch (e) {
      displayToast("Impossible de traiter les données : $e");
    } finally {
      flagServerResponse = false;
    }
  }

  void displayToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> _selectDate() async {
    final now = DateTime(2025, 12, 10, 00, 00);
    final initialDate = DateTime.now();//DateTime(2025, 12, 10, 00, 00);

    // Sélection de la date
    final selectedDate = await showDatePicker(
        locale: Locale(Platform.localeName.split("_").first, Platform.localeName.split("_").lastOrNull),
        context: context,
        initialDate: initialDate,
        firstDate: now,
        lastDate: DateTime.now()// DateTime.fromMillisecondsSinceEpoch(globalReservation!.fin),
    );
    if (selectedDate == null) return;

    // Process DATA :
    List<String> tp = selectedDate.toString().split(" ");
    String tpDate = tp[0] ;

    setState(() {
      dateController = TextEditingController(
          text: tpDate);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: Text(
              "Régularisation avancée",
              textAlign: TextAlign.center,
            )
        ),

        body: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10, top: 20),
                      width: (MediaQuery.of(context).size.width / 2) - 20,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                        ),
                        label: const Text("Date",
                            style: TextStyle(
                                color: Colors.white
                            )
                        ),
                        onPressed: () {
                          _selectDate();
                        },
                        icon: const Icon(
                          Icons.access_time_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(right: 10, top: 20),
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: TextField(
                          enabled: false,
                          controller: dateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Date exécution...',
                          ),
                          style: TextStyle(
                              height: 0.8
                          ),
                          textAlignVertical: TextAlignVertical.bottom,
                          textAlign: TextAlign.right,
                        )
                    ),
                  ],
                ),
                Container(
                    alignment: Alignment.topLeft,
                    //margin: EdgeInsets.only(top: 20, left: 10),
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                    child: SizedBox(
                      //width: (MediaQuery.of(context).size.width / 2) - 20,
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: transactionIdController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1.0),
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'Id de la transaction',
                        ),
                        style: const TextStyle(
                            height: 1.5
                        ),
                        textAlignVertical: TextAlignVertical.bottom,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.next,
                      ),
                    )
                ),
                Container(
                    alignment: Alignment.topRight,
                    //margin: EdgeInsets.only(top: 20, left: 10),
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateColor.resolveWith((states) => Colors.blue)
                      ),
                      label: const Text("Validez",
                          style: TextStyle(
                              color: Colors.white
                          )),
                      onPressed: () {
                        if(dateController.text.trim().isNotEmpty &&
                        transactionIdController.text.trim().isNotEmpty) {
                          displayRequestingForRegularisation();
                        }
                        else{
                          displayToast("Veuillez renseigner les 2 champs !");
                        }
                      },
                      icon: const Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                ),
              ],
            )
        )
    );

  }

}
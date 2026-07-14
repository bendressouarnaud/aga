import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cnmci/konan/services.dart';
import 'package:cnmci/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:signature/signature.dart';

import 'objets/constants.dart';

class InterfaceSignature extends StatefulWidget {
  final int id;
  final String requester;
  final int operationType; // 0 : Signature , 1 : Livraison
  const InterfaceSignature({super.key, required this.id, required this.requester, required this.operationType});

  @override
  State<InterfaceSignature> createState() => _InterfaceSignatureState();
}

class _InterfaceSignatureState extends State<InterfaceSignature> {

  // A T T R I B U T E S :
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  bool closeAlertDialog = false;
  bool onGoingProcess = false;

  SignatureController controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.white,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black
  );


  // M E T H O D S :
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

  void displayDataSending(String signature){
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

    sendSignatureData(signature);

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            if(widget.operationType == 1){
              // Return ELEMENTS to UPDATE INTERFACE :
              Navigator.pop(context, 1);
            }
            else{
              Navigator.pop(context);
            }
          } else {
            displayToast('Traitement impossible');
          }
        }
      },
    );
  }

  Future<void> sendSignatureData(String signature) async
  {
    // First Call this :
    var localToken = await MesServices().checkJwtExpiration();
    final url = widget.operationType == 0 ?
      Uri.parse('${dotenv.env['URL_BACKEND']}manage-signature') :
      Uri.parse('${dotenv.env['URL_BACKEND']}confirm-document-delivery');
    try {
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id" : widget.id,
            "requester" : widget.requester,
            "image" : signature
          })
      ).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        flagSendData = false;
      } else {
        displayToast("Impossible de transmettre la signature");
      }
    } catch (e) {
      displayToast("Impossible de traiter les données de référence : $e");
    } finally {
      onGoingProcess = false;
      flagServerResponse = false;
    }
  }

  @override
  void initState() {
    super.initState();
    //controller.addListener(() => log('Value changed'));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> exportImage() async {
    if (controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: Key('snackbarPNG'),
          content: Text('Veuillez apposer votre signature'),
        ),
      );
      onGoingProcess = false;
      return;
    }

    final Uint8List? data = await controller.toPngBytes(height: 500, width: 450);
    if (data == null) {
      onGoingProcess = false;
      return;
    }

    if (!mounted) return;

    // SEND DATA From there :
    displayDataSending(base64Encode(data));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text('Signature'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Signature(
              key: const Key('signature'),
              controller: controller,
              height: 500,//MediaQuery.of(context).size.height,
              backgroundColor: Colors.black,
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(right: 10, left: 10, top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateColor.resolveWith((states) => Colors.deepOrange)
                      ),
                      label: Text("Effacer",
                          style: const TextStyle(
                              color: Colors.white
                          )
                      ),
                      onPressed: () {
                        controller.clear();
                      },
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: Colors.white,
                      )
                  ),
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateColor.resolveWith((states) => Colors.green)
                      ),
                      label: Text("Enregistrer",
                          style: const TextStyle(
                              color: Colors.white
                          )
                      ),
                      onPressed: () {
                        if(!onGoingProcess) {
                          onGoingProcess = true;
                          exportImage();
                        }
                      },
                      icon: Icon(
                        Icons.save,
                        size: 20,
                        color: Colors.white,
                      )
                  )
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
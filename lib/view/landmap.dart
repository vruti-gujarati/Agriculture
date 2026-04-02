import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'floating_robot.dart';

class LandMap extends StatefulWidget {
  const LandMap({super.key});

  @override
  State<LandMap> createState() => _LandMapState();
}

class _LandMapState extends State<LandMap> {

  WebViewController? controller;
  bool showWebView = false;

  void openWebView(String url) {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    setState(() {
      showWebView = true;
    });
  }

  /// 🔹 Button UI
  Widget _areaButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF66BB6A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF66BB6A)),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF66BB6A),
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 HANDLE BACK BUTTON
  Future<bool> _onBackPressed() async {
    if (showWebView) {
      setState(() {
        showWebView = false;   // 🔙 Go back to Select Area screen
      });
      return false; // prevent exiting screen
    }
    return true; // allow exit if already on selection screen
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,   // ⭐ IMPORTANT

      child: Scaffold(
        backgroundColor: const Color(0xFFEFF7EF),

        appBar: AppBar(
          title: const Text("Land Record (7/12)"),
          backgroundColor: const Color(0xFF66BB6A),
          centerTitle: true,
        ),

          body: Stack(
            children: [

              /// MAIN CONTENT
              showWebView
                  ? WebViewWidget(controller: controller!)
                  : Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF66BB6A),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.25),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const Text(
                        "Choose Area Type?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _areaButton(
                        icon: Icons.location_on_outlined,
                        text: "Village Area",
                        onTap: () {
                          openWebView("https://anyror.gujarat.gov.in/LandRecordRural.aspx");
                        },
                      ),

                      const SizedBox(height: 14),

                      _areaButton(
                        icon: Icons.location_city_outlined,
                        text: "City Area",
                        onTap: () {
                          openWebView("https://anyror.gujarat.gov.in/emilkat/GeneralReport_IDB.aspx");
                        },
                      ),
                    ],
                  ),
                ),
              ),

              /// 🤖 FLOATING ROBOT
              const FloatingRobot(),

            ],
          )
      ),
      );
  }
}

import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_application_1/constant/hive_keys.dart';
import 'package:flutter_application_1/constant/routes.dart';
import 'package:flutter_application_1/constant/stages.dart';
import 'package:flutter_application_1/singletons/record.dart';
import 'package:hive/hive.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String backImgUrl = "assets/back_photo.png";
  String comeSoonUrl = "assets/coming_soon.jpeg";

  TextStyle headerStyle = TextStyle(color: Colors.blue[400], fontSize: 24);

  List<bool> isExpandedList = [false, false, false];
  late String route;
  late Box box;

  @override
  void initState() {
    super.initState();

    box = Hive.box(MyHive.userStatus);

    route = box.length == 0 ? Routes.questionaire : Routes.postureDetection;

    Timer(const Duration(milliseconds: 700),
        () => setState(() => isExpandedList[0] = true));
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('dashboard_visibility_key'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0) {
          Stages.currentStage = Stages.checkInstruction;
          Record.instance.reset();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("主頁"),
            leading: const Icon(Icons.home),
            actions: [
              // If user finished questionaire previously:
              if (box.length != 0)
                IconButton(
                  onPressed: () =>
                      // Push to user_profile page,
                      // when returned dashboard,
                      // refresh UI if user deleted the questionaire record:
                      Navigator.pushNamed(context, Routes.userProfile)
                          .whenComplete(() => setState(() => route =
                              box.length == 0
                                  ? Routes.questionaire
                                  : Routes.postureDetection)),
                  icon: const Icon(Icons.person_rounded),
                ),

              IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.exerciseHistory),
                icon: const Icon(Icons.receipt_long_rounded),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ExpansionPanelList(
                expandedHeaderPadding: const EdgeInsets.all(16.0),
                animationDuration: const Duration(milliseconds: 1500),
                children: [
                  ExpansionPanel(
                    isExpanded: isExpandedList[0],
                    headerBuilder: (context, isExpanded) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("寒背治療", style: headerStyle),
                    ),
                    body: Stack(
                      children: [
                        Image.asset(backImgUrl, fit: BoxFit.fitWidth),

                        // Animated text:
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: AnimatedTextKit(
                            repeatForever: true,
                            animatedTexts: [
                              WavyAnimatedText(
                                "點擊圖片開始",
                                textStyle: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        // Ripple effect on top of its siblings:
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                showAnimatedDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  animationType: DialogTransitionType.size,
                                  curve: Curves.fastOutSlowIn,
                                  duration: const Duration(seconds: 1),
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text("指引",
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text("1.直放手機，與使用者保持約兩米距離，確保鏡頭能顯示全身。"),
                                        SizedBox(height: 8),
                                        Text("2.固定手機，確保過程進行時手機不會搖晃或掉下。"),
                                        SizedBox(height: 8),
                                        Text("3.療程當中不要勉強，如有不適，應到診所求醫。"),
                                      ],
                                    ),
                                    actions: [
                                      OutlinedButton(
                                          onPressed: () => Navigator.of(context)
                                              .popUntil(ModalRoute.withName(
                                                  Routes.dashboard)),
                                          child: const Text("返回")),
                                      ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pushReplacementNamed(
                                                context,
                                                route,
                                              ).whenComplete(() => setState(
                                                  () => route = box.length == 0
                                                      ? Routes.questionaire
                                                      : Routes
                                                          .postureDetection)),
                                          child: const Text("繼續")),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Coming soon...",
                        style: headerStyle,
                      ),
                    ),
                    body: Image.asset(comeSoonUrl, fit: BoxFit.fitWidth),
                    isExpanded: isExpandedList[1],
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Coming soon...",
                        style: headerStyle,
                      ),
                    ),
                    body: Image.asset(comeSoonUrl, fit: BoxFit.fitWidth),
                    isExpanded: isExpandedList[2],
                  ),
                ],
                expansionCallback: (panelIndex, isExpanded) =>
                    setState(() => isExpandedList[panelIndex] = !isExpanded),
              ),
            ),
          )),
    );
  }
}

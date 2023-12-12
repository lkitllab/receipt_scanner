import 'package:flutter/material.dart';
import '../colors.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen(this.progressString, {super.key});

  final String? progressString;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 150),
      color: Colors.black45,
      child: SafeArea(
        child: Stack(children: [
          const Center(
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: SizedBox(
                width: 48,
                height: 78,
                child: Image.asset(
                  'assets/images/list.gif',
                  fit: BoxFit.fill,
                  color: AppColors.accentColor,
                  colorBlendMode: BlendMode.plus,
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.phone_iphone,
              color: AppColors.accentColor,
              size: 120,
            ),
          ),
          if (progressString != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Text(
                  'Processed $progressString',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    background: Paint()
                      ..color = Colors.grey.shade700
                      ..strokeWidth = 22
                      ..strokeJoin = StrokeJoin.round
                      ..strokeCap = StrokeCap.round
                      ..style = PaintingStyle.stroke,
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

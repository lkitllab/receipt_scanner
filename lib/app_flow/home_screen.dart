import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../colors.dart';
import './receipts_screen.dart';
import './progress_screen.dart';
import '../providers/providers.dart';
import '../exstensions/alert_extension.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  late final TabController _tabController;

  bool _isFloatingButtonExpanded = false;
  String? _progressString;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  void _trigerFloatingButton() {
    setState(() {
      _isFloatingButtonExpanded = !_isFloatingButtonExpanded;
    });
  }

  void _updateProgress(int finished, int total) {
    setState(() {
      _progressString = '$finished/$total';
    });
  }

  void _pickImage(ImageSource source, WidgetRef ref) async {
    _trigerFloatingButton();
    final progress = ref.read(progressProvider.notifier);
    try {
      List<String> paths = [];
      if (source == ImageSource.gallery) {
        final files = await _picker.pickMultiImage();
        paths = files.map((file) => file.path).toList();
      } else {
        final file = await _picker.pickImage(source: source);
        final path = file?.path;
        if (path != null) paths = [path];
      }
      if (paths.isNotEmpty) {
        final total = paths.length;
        int finished = 0;
        _updateProgress(finished, total);
        progress.startProgress();
        await ref.read(receiptProvider.notifier).processDocuments(paths, () {
          finished += 1;
          _updateProgress(finished, total);
        });
        progress.stopProgress();
      }
    } on Exception catch (e) {
      progress.stopProgress();
      await showAlert(title: 'Error!', message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInProgress = ref.watch(progressProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accentColor,
        title: const Text('Demo'),
      ),
      body: Stack(
        children: [
          Column(children: [
            Expanded(child: _tabBarView()),
            _tabBar(),
          ]),
          if (isInProgress) ProgressScreen(_progressString),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _bottomButtons(isInProgress),
    );
  }

  Widget _tabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        Container(
          color: AppColors.backgroundColor,
          child: const ReceiptsScreen(),
        ),
        Container(
          color: AppColors.backgroundColor,
          child: Center(
            child: Text('Charts'),
          ),
        ),
        Container(
          color: AppColors.backgroundColor,
          child: Center(
            child: Text('Search'),
          ),
        ),
        Container(
          color: AppColors.backgroundColor,
          child: Center(
            child: Text('Settings'),
          ),
        ),
      ],
    );
  }

  Widget _tabBar() {
    return Container(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: TabBar(
          labelColor: AppColors.accentColor,
          unselectedLabelColor: AppColors.textColor,
          indicatorColor: Colors.transparent,
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.receipt_outlined),
            ),
            Tab(
              icon: Icon(Icons.bar_chart_outlined),
            ),
            Tab(
              icon: Icon(Icons.search),
            ),
            Tab(
              icon: Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomButtons(bool isInProgress) {
    return _isFloatingButtonExpanded
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                shape: const StadiumBorder(),
                onPressed: () => _pickImage(ImageSource.gallery, ref),
                backgroundColor: AppColors.accentColor,
                child: const Icon(
                  Icons.photo_library,
                  size: 28.0,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              FloatingActionButton(
                shape: const StadiumBorder(),
                onPressed: () => _pickImage(ImageSource.camera, ref),
                backgroundColor: AppColors.accentColor,
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 28.0,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              FloatingActionButton(
                shape: const StadiumBorder(),
                onPressed: _trigerFloatingButton,
                backgroundColor: AppColors.accentColor,
                child: const Icon(
                  Icons.arrow_downward,
                  size: 28.0,
                ),
              ),
            ],
          )
        : Stack(
            children: [
              FloatingActionButton(
                shape: const StadiumBorder(),
                onPressed: isInProgress ? null : _trigerFloatingButton,
                backgroundColor: AppColors.accentColor,
                child: const Icon(
                  Icons.add,
                  size: 28.0,
                ),
              ),
              isInProgress
                  ? const CircleAvatar(
                      backgroundColor: Colors.black45,
                      radius: 28,
                    )
                  : const CircleAvatar(radius: 0),
            ],
          );
  }
}

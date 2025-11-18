import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../auth/login/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  static const route = '/onboarding';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _index = 0;
  Timer? _timer;

  List<_Slide> _slides(AppLocalizations t) => [
        _Slide(
          title: t.translate('onboarding_title_1'),
          description: t.translate('onboarding_desc_1'),
          image: 'https://images.unsplash.com/photo-1505691938895-1758d7feb511',
        ),
        _Slide(
          title: t.translate('onboarding_title_2'),
          description: t.translate('onboarding_desc_2'),
          image: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85',
        ),
        _Slide(
          title: t.translate('onboarding_title_3'),
          description: t.translate('onboarding_desc_3'),
          image: 'https://images.unsplash.com/photo-1505691938895-1758d7feb511',
        ),
      ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final next = (_index + 1) % 3;
      _pageController.animateToPage(next, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _finish() async {
    await AppScope.of(context).setHasSeenOnboarding(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(LoginPage.route);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final slides = _slides(t);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(slide.image, fit: BoxFit.cover),
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.black54, Colors.transparent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).scale(),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (i) => Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _index ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _finish,
                    child: Text(t.translate('skip')),
                  ),
                  const Spacer(),
                  if (_index > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Text(t.translate('back')),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_index == slides.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    },
                    child: Text(_index == slides.length - 1 ? t.translate('get_started') : t.translate('next')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  _Slide({required this.title, required this.description, required this.image});

  final String title;
  final String description;
  final String image;
}

import 'package:fitness_tracker_frontend/services/workout_service.dart';
import 'package:fitness_tracker_frontend/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';
import '../utils/toast_utils.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _isLoading = true;
  int _workoutSessions = 0;
  bool _isSessionsLoading = true;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getUserData();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
        // Загружаем сессии после успешной загрузки пользователя
        _loadWorkoutSessions();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ToastUtils.showError(
            AppLocalizations.of(context).translate('failedLoadUser'));
      }
    }
  }

  Future<void> _loadWorkoutSessions() async {
    try {
      final sessions = await WorkoutService.getWorkoutSessions();
      if (mounted) {
        setState(() {
          _workoutSessions = sessions.length;
          _isSessionsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSessionsLoading = false;
        });
        ToastUtils.showError(
            AppLocalizations.of(context).translate('failedLoadSessions'));
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        ToastUtils.showInfo(
            AppLocalizations.of(context).translate('signedOut'));
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(
            AppLocalizations.of(context).translate('failedSignOut'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.grey,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: AppColors.black),
            onPressed: () {
              final currentLocale = Localizations.localeOf(context);
              final newLocale = currentLocale.languageCode == 'en'
                  ? const Locale('ru')
                  : const Locale('en');
              MyApp.of(context).setLocale(newLocale);
            },
          ),
        ],
        title:  Text(
          AppLocalizations.of(context).translate('profileTitle'),
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: AppColors.grey,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Image.asset(
                      'assets/images/person.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _user?.email ??
                        AppLocalizations.of(context).translate('noEmail'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user?.name ??
                        AppLocalizations.of(context).translate('noName'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context).translate('totalWorkouts'),
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: _isSessionsLoading
                              ? "..."
                              : _workoutSessions.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),
                  Text(
                    AppLocalizations.of(context).translate('aiInsight'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate('aiText'),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _signOut,
                    child: Text(
                      AppLocalizations.of(context).translate('logOut'),
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }
}

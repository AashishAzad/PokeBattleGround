import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_hero.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isRegister = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // These rules mirror the backend's RegisterDto, so most mistakes are
  // caught instantly on-device. The backend still validates everything
  // itself — client-side checks are a convenience, never the real defense.
  String? _validateUsername(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a username';
    if (text.length < 3 || text.length > 32) {
      return 'Username must be 3-32 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(text)) {
      return 'Only letters, numbers, and underscores';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Enter a password';
    // Only enforce length rules when creating an account; on login, any
    // mismatch simply comes back as "invalid username or password".
    if (_isRegister && (text.length < 8 || text.length > 128)) {
      return 'Password must be 8-128 characters';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (!_isRegister) return null;
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(authNotifierProvider.notifier);
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (_isRegister) {
      notifier.register(username: username, password: password);
    } else {
      notifier.login(username: username, password: password);
    }
  }

  void _toggleMode() {
    ref.read(authNotifierProvider.notifier).clearError();
    setState(() => _isRegister = !_isRegister);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    return GlassScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final form = ConstrainedBox(
            // Capping the width keeps the form readable on tablets and web
            // instead of stretching edge to edge.
            constraints: const BoxConstraints(maxWidth: 440),
            child: EntranceAnimation(
              delay: const Duration(milliseconds: 150),
              child: _buildFormCard(context, auth),
            ),
          );

          if (constraints.maxWidth >= AppBreakpoints.wide) {
            return Row(
              children: [
                const Expanded(
                  child: Center(
                    child: EntranceAnimation(child: AuthHero(scale: 1.35)),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: form,
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  const EntranceAnimation(child: AuthHero(scale: 0.9)),
                  const SizedBox(height: AppSpacing.lg),
                  form,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, AuthState auth) {
    final textTheme = Theme.of(context).textTheme;

    return GlassContainer(
      borderRadius: AppRadii.xlAll,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassSegmentedControl(
                labels: const ['Log in', 'Sign up'],
                selectedIndex: _isRegister ? 1 : 0,
                onChanged: auth.isSubmitting
                    ? null
                    : (index) {
                        if ((index == 1) != _isRegister) _toggleMode();
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedSwitcher(
                duration: AppDurations.medium,
                child: Column(
                  key: ValueKey(_isRegister),
                  children: [
                    Text(
                      _isRegister ? 'Create your account' : 'Welcome back',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _isRegister
                          ? 'Pick a trainer name and start battling'
                          : 'Sign in to continue your journey',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _usernameController,
                enabled: !auth.isSubmitting,
                autofillHints: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: _validateUsername,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                enabled: !auth.isSubmitting,
                obscureText: _obscurePassword,
                autofillHints: [
                  _isRegister
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                textInputAction: _isRegister
                    ? TextInputAction.next
                    : TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_isRegister) _submit();
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: _validatePassword,
              ),
              AnimatedSize(
                duration: AppDurations.medium,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _isRegister
                    ? Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: TextFormField(
                          controller: _confirmController,
                          enabled: !auth.isSubmitting,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(
                            labelText: 'Confirm password',
                            prefixIcon: Icon(Icons.verified_user_rounded),
                          ),
                          validator: _validateConfirm,
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              AnimatedSize(
                duration: AppDurations.medium,
                alignment: Alignment.topCenter,
                child: auth.errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: MessageBanner.error(auth.errorMessage!),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              const SizedBox(height: AppSpacing.lg),
              GradientButton(
                label: _isRegister ? 'Create account' : 'Log in',
                icon: _isRegister
                    ? Icons.person_add_alt_1_rounded
                    : Icons.login_rounded,
                gradient: AppGradients.pokeBall,
                isLoading: auth.isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: auth.isSubmitting ? null : _toggleMode,
                child: Text(
                  _isRegister
                      ? 'Already have an account? Log in'
                      : 'New here? Create an account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

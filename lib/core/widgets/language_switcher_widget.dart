import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inspecta/core/consts/app_colors.dart';
import 'package:inspecta/core/consts/svgs.dart';
import 'package:inspecta/core/framework/app_cubit.dart';
import 'package:inspecta/core/shared/m_svg.dart';

class LanguageSwitcherWidget extends StatelessWidget {
  const LanguageSwitcherWidget({super.key});

  static const _languages = <_LanguageOption>[
    _LanguageOption(code: 'en', label: 'ENG', icon: Svgs.english),
    _LanguageOption(code: 'ar', label: 'ARA', icon: Svgs.arabic),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final theme = Theme.of(context);
    final current = _languages.firstWhere(
      (l) => l.code == cubit.locale.languageCode,
      orElse: () => _languages.first,
    );

    return PopupMenuButton<_LanguageOption>(
      color: AppColours.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      onSelected: (lang) {
        if (lang.code != cubit.locale.languageCode) {
          cubit.changeLang(lang.code);
        }
      },
      itemBuilder: (_) => _languages
          .map(
            (lang) => PopupMenuItem<_LanguageOption>(
              value: lang,
              child: Row(
                spacing: 8.0,
                children: [
                  MSvg(name: lang.icon, width: 20.0, height: 20.0),
                  Text(lang.label, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          )
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6.0,
        children: [
          MSvg(name: current.icon, width: 22.0, height: 22.0),
          Text(
            current.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18.0,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String label;
  final String icon;

  const _LanguageOption({
    required this.code,
    required this.label,
    required this.icon,
  });
}

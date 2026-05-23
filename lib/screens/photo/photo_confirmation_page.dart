// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/models/aed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/i18n/app_localizations.dart';

class PhotoConfirmationPage extends StatelessWidget {
  const PhotoConfirmationPage(
      {super.key, required this.defibrillator, required this.file});

  final Defibrillator defibrillator;
  final File file;

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    return BlocListener<EditCubit, EditState>(
      listenWhen: (previous, current) =>
          previous.photoStatus != current.photoStatus,
      listener: (context, state) {
        if (state.photoStatus == PhotoStatus.uploadSuccess &&
            state.photoUpdatedDefibrillator != null) {
          context.read<PointsCubit>().update(state.photoUpdatedDefibrillator!);
          context.read<EditCubit>().resetPhotoStatus();
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state.photoStatus == PhotoStatus.uploadFailure) {
          var message = state.photoErrorMessage ?? '';
          context.read<EditCubit>().resetPhotoStatus();
          showCupertinoDialog(
            context: context,
            builder: (dialogContext) => CupertinoAlertDialog(
              title: Text(appLocalizations.photoUploadFailed),
              content: Text(message),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appLocalizations.cancel),
          ),
          middle: Text(appLocalizations.addPhoto),
        ),
        child: SafeArea(
          bottom: false,
          child: BlocBuilder<EditCubit, EditState>(
            buildWhen: (previous, current) =>
                previous.photoStatus != current.photoStatus,
            builder: (context, state) {
              var isUploading = state.photoStatus == PhotoStatus.uploading;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      file,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildLicenseSection(context, appLocalizations),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: isUploading
                          ? null
                          : () => context
                              .read<EditCubit>()
                              .submitPhoto(defibrillator, file),
                      child: isUploading
                          ? const CupertinoActivityIndicator(
                              color: CupertinoColors.white)
                          : Text(appLocalizations.save),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildLicenseSection(
      BuildContext context, AppLocalizations appLocalizations) {
    var parts = appLocalizations.photoLicenseInfo
        .split(appLocalizations.photoLicenseLink);
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          color: CupertinoColors.label.resolveFrom(context),
        ),
        children: [
          if (parts.isNotEmpty) TextSpan(text: parts[0]),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => launchUrl(
                Uri.parse(
                    'https://creativecommons.org/publicdomain/zero/1.0/'),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                appLocalizations.photoLicenseLink,
                style: const TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}

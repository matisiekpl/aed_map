// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/screens/photo/photo_confirmation_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image_picker/image_picker.dart';

import '../../generated/i18n/app_localizations.dart';

Future<void> showPhotoSourceSheet(
    BuildContext context, Defibrillator defibrillator) async {
  var appLocalizations = AppLocalizations.of(context)!;
  await showCupertinoModalPopup(
    context: context,
    builder: (sheetContext) => CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.of(sheetContext).pop();
            await pickAndProceed(
                context, defibrillator, ImageSource.gallery);
          },
          child: Text(appLocalizations.chooseFromGallery),
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.of(sheetContext).pop();
            await pickAndProceed(
                context, defibrillator, ImageSource.camera);
          },
          child: Text(appLocalizations.takePhoto),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDestructiveAction: true,
        onPressed: () => Navigator.of(sheetContext).pop(),
        child: Text(appLocalizations.cancel),
      ),
    ),
  );
}

Future<void> pickAndProceed(BuildContext context, Defibrillator defibrillator,
    ImageSource source) async {
  var appLocalizations = AppLocalizations.of(context)!;
  var picked = await ImagePicker().pickImage(source: source);
  if (picked == null) return;

  var path = picked.path;
  final lower = path.toLowerCase();
  if (lower.endsWith('.heic') || lower.endsWith('.heif')) {
    final converted = await HeifConverter.convert(path, format: 'jpg');
    if (converted != null) {
      path = converted;
    }
  }
  var file = File(path);
  var editCubit = context.read<EditCubit>();
  var unsafe = await editCubit.isPhotoUnsafe(file);

  if (unsafe) {
    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(appLocalizations.nsfwBlockedTitle),
        content: Text(appLocalizations.nsfwBlockedMessage),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  await Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (pageContext) => BlocProvider<EditCubit>.value(
        value: editCubit,
        child: PhotoConfirmationPage(
          defibrillator: defibrillator,
          file: file,
        ),
      ),
    ),
  );
}
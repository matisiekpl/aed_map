import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('EditCubit', () {
    late EditCubit editCubit;

    setUp(() {
      editCubit = EditCubit(
          pointsRepository: PointsRepository(),
          geolocationRepository: GeolocationRepository());
    });

    test('initial state is EditInitial', () {
      expect(editCubit.state, EditReady(enabled: false, cursor: warsaw));
    });

    test('enter', () async {
      await editCubit.enter();
      expect(editCubit.state.enabled, true);
    });

    test('exit', () async {
      await editCubit.enter();
      editCubit.exit();
      expect(editCubit.state.enabled, false);
    });

    test('moveCursor', () async {
      editCubit.moveCursor(warsaw);
      expect(editCubit.state.cursor, warsaw);
    });

    test('cancel', () async {
      await editCubit.enter();
      editCubit.cancel();
      expect(editCubit.state.enabled, false);
    });

    test('add', () async {
      await editCubit.enter();
      await editCubit.add();
      expect(editCubit.state, isA<EditInProgress>());
      expect(editCubit.state.enabled, false);
      expect((editCubit.state as EditInProgress).defibrillator, isA<Defibrillator>());
      expect((editCubit.state as EditInProgress).defibrillator.id, 0);
      expect((editCubit.state as EditInProgress).indoor, 'no');
    });

    test('edit', () async {
      await editCubit.enter();
      await editCubit.edit(Defibrillator(
          id: 7,
          location: warsaw,
          description: 'test_description',
          indoor: 'no',
          access: 'yes',
          operator: 'test_operator',
          phone: 'test_phone'));
      expect(editCubit.state.enabled, false);
      expect(editCubit.state, isA<EditInProgress>());
      expect((editCubit.state as EditInProgress).defibrillator, isA<Defibrillator>());
      expect((editCubit.state as EditInProgress).defibrillator.id, 7);
      expect((editCubit.state as EditInProgress).defibrillator.description,
          'test_description');
      expect((editCubit.state as EditInProgress).indoor, 'no');
      expect((editCubit.state as EditInProgress).access, 'yes');
      expect((editCubit.state as EditInProgress).defibrillator.operator, 'test_operator');
      expect((editCubit.state as EditInProgress).defibrillator.phone, 'test_phone');
    });

    test('editDescription', () async {
      await editCubit.enter();
      await editCubit.edit(Defibrillator(
          id: 7,
          location: warsaw,
          description: 'test_description',
          indoor: 'no',
          access: 'yes',
          operator: 'test_operator',
          phone: 'test_phone'));
      editCubit.editDescription('test_description2');
      expect(editCubit.state, isA<EditInProgress>());
      expect((editCubit.state as EditInProgress).defibrillator.description,
          'test_description2');
      expect(
          (editCubit.state as EditInProgress).description, 'test_description2');
    });

    test('editIndoor', () async {
      await editCubit.enter();
      await editCubit.edit(Defibrillator(
          id: 7,
          location: warsaw,
          description: 'test_description',
          indoor: 'yes',
          access: 'yes',
          operator: 'test_operator',
          phone: 'test_phone'));
      editCubit.editIndoor(true);
      expect(editCubit.state, isA<EditInProgress>());
      expect((editCubit.state as EditInProgress).defibrillator.indoor, 'yes');
      expect((editCubit.state as EditInProgress).indoor, 'yes');
    });

    test('editAccess', () async {
      await editCubit.enter();
      await editCubit.edit(Defibrillator(
          id: 7,
          location: warsaw,
          description: 'test_description',
          indoor: 'no',
          access: 'yes',
          operator: 'test_operator',
          phone: 'test_phone'));
      editCubit.editAccess('no');
      expect(editCubit.state, isA<EditInProgress>());
      expect((editCubit.state as EditInProgress).defibrillator.access, 'no');
      expect((editCubit.state as EditInProgress).access, 'no');
    });

    test('editAccess', () async {
      await editCubit.enter();
      await editCubit.edit(Defibrillator(
          id: 7,
          location: warsaw,
          description: 'test_description',
          indoor: 'no',
          access: 'yes',
          operator: 'test_operator',
          phone: 'test_phone'));
      editCubit.editAccess('test_access');
      expect(editCubit.state, isA<EditInProgress>());
      expect((editCubit.state as EditInProgress).defibrillator.access, 'test_access');
      expect((editCubit.state as EditInProgress).access, 'test_access');
    });
  });
}

import 'package:aed_map/repositories/points_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  CustomBindings();
  TestWidgetsFlutterBinding.ensureInitialized();
  group("PointsRepository", () {
    late PointsRepository pointsRepository;

    setUp(() {
      pointsRepository = PointsRepository();
    });

    test("should correctly fetch complete node", () async {
      var defibrillator = await pointsRepository.getNode(11197705644);
      expect(defibrillator, isNotNull);
      expect(defibrillator?.id, 11197705644);
      expect(defibrillator?.access, 'yes');
      expect(defibrillator?.description, 'W czarnej kapsule przy wejściu do urzędu gminy');
      expect(defibrillator?.location.longitude, 21.288825);
      expect(defibrillator?.location.latitude, 50.2623153);
      expect(defibrillator?.indoor, 'yes');
      expect(defibrillator?.openingHours, '24/7');
      expect(defibrillator?.operator, 'Urząd Gminy Wadowice Górne');
      expect(defibrillator?.phone, '+48 14 666 97 51');
    });

    test("should correctly fetch sparse node", ()async{
      var defibrillator = await pointsRepository.getNode(11883717971);
      expect(defibrillator, isNotNull);
      expect(defibrillator?.id, 11883717971);
    });

    test("should return null if node not found", ()async{
      var defibrillator = await pointsRepository.getNode(-1);
      expect(defibrillator, isNull);
    });
  });
}

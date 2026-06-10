import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  CustomBindings();
  TestWidgetsFlutterBinding.ensureInitialized();
  group("PointsRepository", () {
    // getNode method was removed per code review (matisiekpl)
  });
}

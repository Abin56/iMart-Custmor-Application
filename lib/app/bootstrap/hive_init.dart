import 'package:hive_ce/hive.dart';
import 'package:imart/app/core/storage/hive/adapters/address.dart';
import 'package:imart/app/core/storage/hive/adapters/delivery_tracking.dart';
import 'package:imart/app/core/storage/hive/adapters/user.dart';
import 'package:imart/app/core/storage/hive/boxes.dart';
import 'package:imart/features/product_details/infrastructure/data_sources/local/product_detail_cache.dart';
import 'package:path_provider/path_provider.dart';

class HiveInit {
  const HiveInit._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    // Register all adapters (must be before opening boxes)
    Hive
      ..init(dir.path)
      ..registerAdapter(AddressModelAdapter())
      ..registerAdapter(UserModelAdapter())
      ..registerAdapter(AddressTypeAdapter())
      ..registerAdapter(DeliveryTrackingDataAdapter())
      ..registerAdapter(ProductMetadataAdapter());

    // Open all needed boxes
    await Boxes.openHiveBoxes();

    _initialized = true;
  }
}

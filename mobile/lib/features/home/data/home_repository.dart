import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/home_models.dart';

class HomeRepository {
  const HomeRepository(this.client);
  final ApiClient client;
  Future<Dashboard> dashboard() => client.get(
    ApiEndpoints.dashboard,
    (j) => Dashboard.fromJson(Map<String, dynamic>.from(j! as Map)),
  );
}

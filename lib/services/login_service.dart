import 'package:grpc/grpc.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';
import 'package:mobile/grpc_gen/chronolens.pb.dart';
import '../grpc_gen/chronolens.pbgrpc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginServiceClient {
  late ClientChannel channel;
  late ChronoLensClient stub;

  LoginServiceClient() {
    // Initialize gRPC channel
    channel = ClientChannel(
      '10.0.0.10', // The IP or hostname of the gRPC server
      port: 8080, // The port on which the gRPC server is running
      options: const ChannelOptions(
        credentials: ChannelCredentials
            .insecure(), // Use secure credentials in production
      ),
    );

    // Create stub from generated gRPC code
    stub = ChronoLensClient(channel);
  }

  //TODO: Log in check

  Future<Maybe<GrpcError?>> login(String username, String password) async {
    try {
      final request = LoginRequest()
        ..username = username
        ..password = password;

      final response = await stub.login(request);

      final storage = new FlutterSecureStorage();
      await storage.write(key: "jwtToken", value: response.token);

      // String? value = await storage.read(key: "jwtToken");
      // print(value);

      return const Nothing();
    } on GrpcError catch (e) {
      print('GrpcError: $e');
      return Just(e);
    } catch (e) {
      print('Random Error: $e');
      return const Just(null);
    }
  }

  // Gracefully close the channel when no longer needed
  Future<void> shutdown() async {
    await channel.shutdown();
  }
}

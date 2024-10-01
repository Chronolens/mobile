import 'package:grpc/grpc.dart';
import 'package:mobile/grpc_gen/chronolens.pb.dart';
import '../grpc_gen/chronolens.pbgrpc.dart'; // Import your generated gRPC code

class LoginServiceClient {
  late ClientChannel channel;
  late ChronoLensClient stub;

  LoginServiceClient() {
    // Initialize gRPC channel
    channel = ClientChannel(
      '10.0.0.10', // The IP or hostname of the gRPC server
      port: 50051, // The port on which the gRPC server is running
      options: const ChannelOptions(
        credentials: ChannelCredentials
            .insecure(), // Use secure credentials in production
      ),
    );

    // Create stub from generated gRPC code
    stub = ChronoLensClient(channel);
  }

  // Function to get photo by ID
  Future<LoginResponse?> login(String username, String password) async {
    try {
      // Create a GetPhotoRequest with the provided id
      final request = LoginRequest()
        ..username = username
        ..password = password;

      // Call the gRPC method and get the response
      final response = await stub.login(request);
      
      // Return the photo URL from the response
      return response;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  // Gracefully close the channel when no longer needed
  Future<void> shutdown() async {
    await channel.shutdown();
  }
}

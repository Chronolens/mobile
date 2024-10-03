///
//  Generated code. Do not modify.
//  source: chronolens.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'chronolens.pb.dart' as $0;
export 'chronolens.pb.dart';

class ChronoLensClient extends $grpc.Client {
  static final _$login = $grpc.ClientMethod<$0.LoginRequest, $0.LoginResponse>(
      '/chronolens.ChronoLens/Login',
      ($0.LoginRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.LoginResponse.fromBuffer(value));
  static final _$uploadImage =
      $grpc.ClientMethod<$0.UploadImageRequest, $0.UploadImageResponse>(
          '/chronolens.ChronoLens/UploadImage',
          ($0.UploadImageRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.UploadImageResponse.fromBuffer(value));

  ChronoLensClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.LoginResponse> login($0.LoginRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$login, request, options: options);
  }

  $grpc.ResponseFuture<$0.UploadImageResponse> uploadImage(
      $async.Stream<$0.UploadImageRequest> request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$uploadImage, request, options: options)
        .single;
  }
}

abstract class ChronoLensServiceBase extends $grpc.Service {
  $core.String get $name => 'chronolens.ChronoLens';

  ChronoLensServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.LoginRequest, $0.LoginResponse>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginRequest.fromBuffer(value),
        ($0.LoginResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UploadImageRequest, $0.UploadImageResponse>(
            'UploadImage',
            uploadImage,
            true,
            false,
            ($core.List<$core.int> value) =>
                $0.UploadImageRequest.fromBuffer(value),
            ($0.UploadImageResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.LoginResponse> login_Pre(
      $grpc.ServiceCall call, $async.Future<$0.LoginRequest> request) async {
    return login(call, await request);
  }

  $async.Future<$0.LoginResponse> login(
      $grpc.ServiceCall call, $0.LoginRequest request);
  $async.Future<$0.UploadImageResponse> uploadImage(
      $grpc.ServiceCall call, $async.Stream<$0.UploadImageRequest> request);
}

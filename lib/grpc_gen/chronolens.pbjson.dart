///
//  Generated code. Do not modify.
//  source: chronolens.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = const {
  '1': 'LoginRequest',
  '2': const [
    const {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    const {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode('CgxMb2dpblJlcXVlc3QSGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEhoKCHBhc3N3b3JkGAIgASgJUghwYXNzd29yZA==');
@$core.Deprecated('Use loginResponseDescriptor instead')
const LoginResponse$json = const {
  '1': 'LoginResponse',
  '2': const [
    const {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `LoginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginResponseDescriptor = $convert.base64Decode('Cg1Mb2dpblJlc3BvbnNlEhQKBXRva2VuGAEgASgJUgV0b2tlbg==');
@$core.Deprecated('Use uploadImageRequestDescriptor instead')
const UploadImageRequest$json = const {
  '1': 'UploadImageRequest',
  '2': const [
    const {'1': 'info', '3': 1, '4': 1, '5': 11, '6': '.chronolens.ImageInfo', '9': 0, '10': 'info'},
    const {'1': 'image', '3': 2, '4': 1, '5': 12, '9': 0, '10': 'image'},
  ],
  '8': const [
    const {'1': 'data'},
  ],
};

/// Descriptor for `UploadImageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadImageRequestDescriptor = $convert.base64Decode('ChJVcGxvYWRJbWFnZVJlcXVlc3QSKwoEaW5mbxgBIAEoCzIVLmNocm9ub2xlbnMuSW1hZ2VJbmZvSABSBGluZm8SFgoFaW1hZ2UYAiABKAxIAFIFaW1hZ2VCBgoEZGF0YQ==');
@$core.Deprecated('Use imageInfoDescriptor instead')
const ImageInfo$json = const {
  '1': 'ImageInfo',
  '2': const [
    const {'1': 'filetype', '3': 1, '4': 1, '5': 9, '10': 'filetype'},
  ],
};

/// Descriptor for `ImageInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageInfoDescriptor = $convert.base64Decode('CglJbWFnZUluZm8SGgoIZmlsZXR5cGUYASABKAlSCGZpbGV0eXBl');
@$core.Deprecated('Use uploadImageResponseDescriptor instead')
const UploadImageResponse$json = const {
  '1': 'UploadImageResponse',
  '2': const [
    const {'1': 'size', '3': 1, '4': 1, '5': 13, '10': 'size'},
  ],
};

/// Descriptor for `UploadImageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadImageResponseDescriptor = $convert.base64Decode('ChNVcGxvYWRJbWFnZVJlc3BvbnNlEhIKBHNpemUYASABKA1SBHNpemU=');

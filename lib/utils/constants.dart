const String LOGIN_ERROR_401 = "Error, wrong credentials";
const String LOGIN_ERROR_UNKNOWN = "Unkown error";

const String BASE_URL = "baseUrl";
const String CHECKSUM = 'checksum';

const String JWT_TOKEN = "jwtToken";
String getAuthHeader(jwtToken) => "Bearer $jwtToken";
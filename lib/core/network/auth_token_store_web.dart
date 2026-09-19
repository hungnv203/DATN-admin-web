// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

String? readAuthToken() => html.window.localStorage['auth_token'];

void writeAuthToken(String? token) {
  if (token != null && token.isNotEmpty) {
    html.window.localStorage['auth_token'] = token;
  } else {
    html.window.localStorage.remove('auth_token');
  }
}

void clearAuthToken() {
  html.window.localStorage.remove('auth_token');
}

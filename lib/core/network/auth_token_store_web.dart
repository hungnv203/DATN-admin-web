import 'dart:html' as html;

String? readAuthToken() => html.window.localStorage['auth_token'];

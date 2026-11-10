import 'dart:js_interop';

@JS('open')
external JSAny? _openWindow(JSString url, JSString target, JSString features);

void openExternalUrl(String url) {
  _openWindow(url.toJS, '_blank'.toJS, 'noopener,noreferrer'.toJS);
}

import 'external_url_stub.dart'
    if (dart.library.js_interop) 'external_url_web.dart'
    as implementation;

/// Opens a source link in a new browser tab on the web.
void openExternalUrl(String url) => implementation.openExternalUrl(url);

import 'package:web/web.dart' as web;

class GoogleClientIdStrategy {
  String? resolve({required bool isProd}) {
    final metaName = isProd
        ? 'mh-google-client-id-prod'
        : 'mh-google-client-id-dev';
    final meta =
        web.document.querySelector('meta[name="$metaName"]')
            as web.HTMLMetaElement?;
    if (meta != null && meta.content.trim().isNotEmpty) {
      return meta.content.trim();
    }

    return null;
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/city.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import '../../../shared/widgets/city_picker.dart';
import '../../../shared/widgets/islamic_art.dart';
import '../../../shared/widgets/reveal.dart';

class QiblaPage extends ConsumerStatefulWidget {
  const QiblaPage({super.key});

  @override
  ConsumerState<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends ConsumerState<QiblaPage> {
  double _heading = 0;

  void _setHeading(double value) {
    final normalized = ((value % 360) + 360) % 360;
    if ((normalized - _heading).abs() < 0.01) return;
    setState(() => _heading = normalized);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final city = ref.watch(selectedCityProvider);
    final bearing = ref.watch(qiblaBearingProvider);
    final distance = ref.watch(qiblaDistanceProvider);

    return PageScaffold(
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: 'Arah Kiblat',
            title: 'Menghadap ke Baitullah.',
            description:
                'Hitung arah kiblat dari kota yang kamu pilih. Bitaqwa menentukan bearing terhadap '
                'utara sejati menggunakan koordinat Ka\u2019bah dan koordinat kotamu.',
            action: const CityPickerButton(),
            meta: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SoftBadge(
                  label: '${formatBearing(bearing)} dari utara',
                  icon: Icons.explore_outlined,
                ),
                SoftBadge(
                  label: '${formatDistance(distance)} ke Ka\u2019bah',
                  icon: Icons.straighten_rounded,
                  color: palette.gold,
                ),
                SoftBadge(
                  label: city.timezoneLabel,
                  icon: Icons.public_rounded,
                ),
              ],
            ),
          ),
          Container(
            color: palette.background,
            padding: EdgeInsets.only(
              left: context.pageGutter,
              right: context.pageGutter,
              top: context.isMobile ? 32 : 44,
              bottom: context.isMobile ? 56 : 84,
            ),
            child: ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 980;
                      final compass = Reveal(
                        child: _CompassCard(
                          city: city,
                          bearing: bearing,
                          heading: _heading,
                          onHeadingChanged: _setHeading,
                        ),
                      );
                      final details = Reveal(
                        delay: const Duration(milliseconds: 110),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _BearingCard(
                              city: city,
                              bearing: bearing,
                              distance: distance,
                            ),
                            const SizedBox(height: 18),
                            const _HowToCard(),
                            const SizedBox(height: 18),
                            const _SensorNote(),
                          ],
                        ),
                      );
                      if (!wide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            compass,
                            const SizedBox(height: 20),
                            details,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(flex: 11, child: compass),
                          const SizedBox(width: 22),
                          Expanded(flex: 9, child: details),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const SourceNote(
                    text:
                        'Bearing kiblat dihitung dengan rumus great-circle dari koordinat kota ke Ka\u2019bah '
                        '(21,4225\u00b0 LU, 39,8252\u00b0 BT). Hasil terhadap utara sejati dapat berbeda '
                        'beberapa derajat dari kompas magnetik karena deklinasi magnetik setempat.',
                    icon: Icons.calculate_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassCard extends StatelessWidget {
  const _CompassCard({
    required this.city,
    required this.bearing,
    required this.heading,
    required this.onHeadingChanged,
  });

  final City city;
  final double bearing;
  final double heading;
  final ValueChanged<double> onHeadingChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                .withValues(alpha: context.isDarkMode ? 0.3 : 0.06),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.explore_outlined, size: 19, color: palette.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Kompas kiblat',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SoftBadge(
                label: 'SIMULASI',
                icon: Icons.touch_app_outlined,
                color: palette.gold,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Geser kompas atau atur arah perangkat untuk melihat posisi kiblat relatif terhadap layar.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: palette.muted, height: 1.5),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(constraints.maxWidth, 390.0);
              return Center(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: _Compass(
                    size: size,
                    bearing: bearing,
                    heading: heading,
                    onHeadingChanged: onHeadingChanged,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            decoration: BoxDecoration(
              color: palette.surfaceAlt.withValues(
                alpha: context.isDarkMode ? 0.55 : 0.6,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.screen_rotation_alt_outlined,
                      size: 16,
                      color: palette.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Arah perangkat (simulasi)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: palette.text,
                        ),
                      ),
                    ),
                    Text(
                      '${heading.round()}\u00b0',
                      style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: palette.primary,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: heading,
                  min: 0,
                  max: 359,
                  divisions: 359,
                  semanticFormatterCallback: (value) =>
                      'Arah perangkat ${value.round()} derajat',
                  onChanged: onHeadingChanged,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Utara 0\u00b0',
                      style: TextStyle(fontSize: 9.5, color: palette.muted),
                    ),
                    const Spacer(),
                    Text(
                      'Timur 90\u00b0',
                      style: TextStyle(fontSize: 9.5, color: palette.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: <Widget>[
              AppButton(
                label: 'Hadapkan ke utara',
                icon: Icons.north_rounded,
                size: AppButtonSize.compact,
                variant: AppButtonVariant.secondary,
                onPressed: () => onHeadingChanged(0),
              ),
              AppButton(
                label: 'Kiblat di depan',
                icon: Icons.center_focus_strong_rounded,
                size: AppButtonSize.compact,
                onPressed: () => onHeadingChanged(bearing),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Ikuti arah panah emas untuk menghadap kiblat dari ${city.name}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: palette.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Compass extends StatelessWidget {
  const _Compass({
    required this.size,
    required this.bearing,
    required this.heading,
    required this.onHeadingChanged,
  });

  final double size;
  final double bearing;
  final double heading;
  final ValueChanged<double> onHeadingChanged;

  void _handlePan(Offset localPosition) {
    final center = Offset(size / 2, size / 2);
    final delta = localPosition - center;
    if (delta.distance < size * 0.12) return;
    // Angle measured clockwise from the top of the dial.
    final radians = math.atan2(delta.dx, -delta.dy);
    final degrees = (radians * 180 / math.pi + 360) % 360;
    onHeadingChanged(degrees);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      label:
          'Kompas simulasi. Arah perangkat ${heading.round()} derajat, arah kiblat ${bearing.round()} derajat.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => _handlePan(details.localPosition),
        onPanDown: (details) => _handlePan(details.localPosition),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned.fill(
              child: Transform.rotate(
                angle: -heading * math.pi / 180,
                child: CustomPaint(
                  painter: _CompassPainter(
                    bearing: bearing,
                    surface: palette.surfaceAlt.withValues(
                      alpha: context.isDarkMode ? 0.55 : 1,
                    ),
                    dial: palette.surface,
                    border: palette.border,
                    tick: palette.muted,
                    gold: palette.gold,
                    primary: palette.primary,
                    text: palette.text,
                    muted: palette.muted,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 2,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 0,
                    height: 0,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.transparent,
                          width: 8,
                        ),
                        right: BorderSide(
                          color: Colors.transparent,
                          width: 8,
                        ),
                        bottom: BorderSide(color: palette.primary, width: 13),
                      ),
                    ),
                  ),
                  Text(
                    'DEPAN',
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: palette.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter({
    required this.bearing,
    required this.surface,
    required this.dial,
    required this.border,
    required this.tick,
    required this.gold,
    required this.primary,
    required this.text,
    required this.muted,
  });

  final double bearing;
  final Color surface;
  final Color dial;
  final Color border;
  final Color tick;
  final Color gold;
  final Color primary;
  final Color text;
  final Color muted;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 6;

    final base = Paint()..color = surface;
    final borderPaint = Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, radius, base);
    canvas.drawCircle(center, radius, borderPaint);
    canvas.drawCircle(center, radius * 0.86, borderPaint);
    canvas.drawCircle(center, radius * 0.3, borderPaint);

    // Degree ticks.
    for (int i = 0; i < 72; i++) {
      final angle = i * math.pi / 36 - math.pi / 2;
      final major = i % 6 == 0;
      final cardinal = i % 18 == 0;
      final outer = radius * 0.95;
      final inner = radius * (cardinal ? 0.84 : (major ? 0.88 : 0.91));
      final paint = Paint()
        ..color = cardinal ? primary : tick.withValues(alpha: major ? 0.6 : 0.3)
        ..strokeWidth = cardinal ? 2.2 : (major ? 1.4 : 0.8)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * outer,
        center + Offset(math.cos(angle), math.sin(angle)) * inner,
        paint,
      );
    }

    // Cardinal labels. The whole dial rotates, so north stays at true north.
    const labels = <String>['N', 'T', 'S', 'B'];
    for (int i = 0; i < labels.length; i++) {
      final angle = i * math.pi / 2 - math.pi / 2;
      final position = center +
          Offset(math.cos(angle), math.sin(angle)) * (radius * 0.72);
      final painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontSize: radius * 0.095,
            fontWeight: FontWeight.w700,
            color: i == 0 ? gold : muted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        position - Offset(painter.width / 2, painter.height / 2),
      );
    }

    // Qibla needle, drawn at the true bearing.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(bearing * math.pi / 180);
    final needle = Paint()
      ..color = gold
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, radius * 0.18),
      Offset(0, -radius * 0.64),
      needle,
    );
    final arrow = Path()
      ..moveTo(0, -radius * 0.82)
      ..lineTo(-radius * 0.085, -radius * 0.6)
      ..lineTo(0, -radius * 0.68)
      ..lineTo(radius * 0.085, -radius * 0.6)
      ..close();
    canvas.drawPath(arrow, Paint()..color = gold);
    canvas.drawLine(
      Offset.zero,
      Offset(0, radius * 0.18),
      Paint()
        ..color = primary.withValues(alpha: 0.55)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // Ka'bah marker at the needle tip.
    final tip = center +
        Offset(
          math.sin(bearing * math.pi / 180),
          -math.cos(bearing * math.pi / 180),
        ) *
            (radius * 0.82);
    final markerRect = Rect.fromCenter(
      center: tip,
      width: radius * 0.17,
      height: radius * 0.17,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(markerRect, Radius.circular(radius * 0.03)),
      Paint()..color = gold,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: tip,
        width: radius * 0.09,
        height: radius * 0.09,
      ),
      Paint()
        ..color = dial
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Center pin.
    canvas.drawCircle(center, radius * 0.055, Paint()..color = dial);
    canvas.drawCircle(
      center,
      radius * 0.055,
      Paint()
        ..color = primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(center, radius * 0.018, Paint()..color = primary);

    // Small label under the needle.
    final label = TextPainter(
      text: TextSpan(
        text: 'KA\u2019BAH',
        style: TextStyle(
          fontSize: radius * 0.045,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: gold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelPosition = center +
        Offset(
          math.sin(bearing * math.pi / 180),
          -math.cos(bearing * math.pi / 180),
        ) *
            (radius * 0.56);
    label.paint(
      canvas,
      labelPosition - Offset(label.width / 2, label.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.bearing != bearing ||
        oldDelegate.surface != surface ||
        oldDelegate.dial != dial ||
        oldDelegate.border != border ||
        oldDelegate.tick != tick ||
        oldDelegate.gold != gold ||
        oldDelegate.primary != primary ||
        oldDelegate.text != text ||
        oldDelegate.muted != muted;
  }
}

class _BearingCard extends StatelessWidget {
  const _BearingCard({
    required this.city,
    required this.bearing,
    required this.distance,
  });

  final City city;
  final double bearing;
  final double distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF064E3B), Color(0xFF0F7557)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const CrescentMark(size: 24, color: Colors.white),
              const SizedBox(width: 9),
              Text(
                'Arah kiblat',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${bearing.round()}\u00b0',
                style: const TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 58,
                  height: 0.92,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'dari utara\nsejati',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    city.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatDistance(distance),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8D4A8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _Coordinate(
                  label: 'Lintang',
                  value:
                      '${city.latitude.abs().toStringAsFixed(2)}\u00b0 ${city.latitude >= 0 ? 'LU' : 'LS'}',
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withValues(alpha: 0.14),
              ),
              Expanded(
                child: _Coordinate(
                  label: 'Bujur',
                  value:
                      '${city.longitude.abs().toStringAsFixed(2)}\u00b0 ${city.longitude >= 0 ? 'BT' : 'BB'}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Coordinate extends StatelessWidget {
  const _Coordinate({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              letterSpacing: 0.8,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HowToCard extends StatelessWidget {
  const _HowToCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.assistant_navigation, size: 18, color: palette.primary),
              const SizedBox(width: 8),
              Text(
                'Cara menggunakan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _Step(
            number: '1',
            text:
                'Berdiri atau duduk di tempat yang tenang, lalu tentukan arah utara sejati.',
          ),
          const _Step(
            number: '2',
            text:
                'Geser kompas hingga label N berada di depanmu. Angka pada panah emas adalah arah kiblat.',
          ),
          const _Step(
            number: '3',
            text:
                'Jika memakai kompas magnetik, periksa deklinasi magnetik di kotamu dan jangan dekatkan benda logam.',
          ),
          const _Step(
            number: '4',
            text:
                'Untuk ibadah, utamakan verifikasi dengan masjid setempat atau aplikasi kiblat yang memakai sensor terkalibrasi.',
            last: true,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.text,
    this.last = false,
  });

  final String number;
  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: palette.primarySoft.withValues(
                alpha: context.isDarkMode ? 0.55 : 1,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: palette.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: palette.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorNote extends StatelessWidget {
  const _SensorNote();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(
          alpha: context.isDarkMode ? 0.5 : 0.6,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.sensors_off_outlined, size: 17, color: palette.gold),
              const SizedBox(width: 8),
              Text(
                'Tentang sensor',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'Versi web Bitaqwa belum membaca sensor kompas perangkat. Kompas di halaman ini '
            'adalah simulasi untuk memahami arah, bukan pembacaan sensor langsung. '
            'Jangan gunakan simulasi sebagai satu-satunya acuan arah ibadah.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.6,
              color: palette.muted,
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Buka jadwal shalat',
            icon: Icons.access_time_rounded,
            size: AppButtonSize.compact,
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: () => context.go('/jadwal-shalat'),
          ),
        ],
      ),
    );
  }
}

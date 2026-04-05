import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherDetailPage extends StatefulWidget {
  final String cityName;
  final String temperature;
  final String description;
  final String humidity;

  const WeatherDetailPage({
    super.key,
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
  });

  @override
  State<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage>
    with TickerProviderStateMixin {
  String _selectedTab = "Hourly";
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Current weather extras
  String windSpeed = "--";
  String visibility = "--";
  String pressure = "--";
  String uvIndex = "7 High";
  String rainChance = "--";
  String feelsLike = "--";

  // Hourly forecast (mock realistic data)
  final List<Map<String, dynamic>> hourlyData = [
    {"time": "6am", "temp": 22, "rain": 5},
    {"time": "9am", "temp": 24, "rain": 8},
    {"time": "12pm", "temp": 27, "rain": 18},
    {"time": "3pm", "temp": 28, "rain": 22},
    {"time": "6pm", "temp": 25, "rain": 14},
    {"time": "9pm", "temp": 23, "rain": 6},
  ];

  // 7-day forecast from API
  List<Map<String, dynamic>> sevenDayData = [];
  bool isLoadingForecast = true;

  final String apiKey = "86ccb27e8e74f234c003068b6f9228aa";

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _fetchDetailedWeather();
    _fetch7DayForecast();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Fetch current weather details ──────────────────────────────────────────
  Future<void> _fetchDetailedWeather() async {
    if (widget.cityName.isEmpty) return;
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(widget.cityName)}&appid=$apiKey&units=metric";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          windSpeed = "${data["wind"]["speed"]} km/h";
          visibility =
          "${((data["visibility"] ?? 10000) / 1000).toStringAsFixed(1)} km";
          pressure = "${data["main"]["pressure"]} mb";
          feelsLike = "${data["main"]["feels_like"].toStringAsFixed(1)}°C";
          rainChance = "${data["clouds"]["all"]}%";
        });
      }
    } catch (_) {}
  }

  // ── Fetch 5-day/3-hour forecast → group by day ─────────────────────────────
  Future<void> _fetch7DayForecast() async {
    if (widget.cityName.isEmpty) {
      setState(() => isLoadingForecast = false);
      return;
    }
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?q=${Uri.encodeComponent(widget.cityName)}&appid=$apiKey&units=metric&cnt=40";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data["list"];

        // Group entries by date
        final Map<String, List<dynamic>> grouped = {};
        for (final item in list) {
          final dt = DateTime.fromMillisecondsSinceEpoch(item["dt"] * 1000);
          final dateKey =
              "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
          grouped.putIfAbsent(dateKey, () => []).add(item);
        }

        final dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        final List<Map<String, dynamic>> result = [];

        for (final entry in grouped.entries) {
          final items = entry.value;
          final temps =
          items.map((i) => (i["main"]["temp"] as num).toDouble()).toList();
          final avgTemp = temps.reduce((a, b) => a + b) / temps.length;
          final maxRain = items
              .map((i) => ((i["pop"] ?? 0) as num).toDouble() * 100)
              .reduce((a, b) => a > b ? a : b);
          final midItem = items[items.length ~/ 2];
          final condition =
          midItem["weather"][0]["description"] as String;
          final icon = midItem["weather"][0]["main"] as String;
          final date = DateTime.parse(entry.key);
          final dayName = dayNames[date.weekday - 1];

          result.add({
            "day": dayName,
            "temp": avgTemp.round(),
            "rain": maxRain.round(),
            "condition": condition,
            "icon": icon,
          });
        }

        setState(() {
          sevenDayData = result.take(7).toList();
          isLoadingForecast = false;
        });
      } else {
        setState(() => isLoadingForecast = false);
      }
    } catch (_) {
      setState(() => isLoadingForecast = false);
    }
  }

  IconData _getWeatherIcon(String main) {
    switch (main.toLowerCase()) {
      case "clear":
        return Icons.wb_sunny;
      case "clouds":
        return Icons.cloud;
      case "rain":
      case "drizzle":
        return Icons.grain;
      case "thunderstorm":
        return Icons.flash_on;
      case "snow":
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  Color _getWeatherIconColor(String main) {
    switch (main.toLowerCase()) {
      case "clear":
        return const Color(0xFFF9A825);
      case "rain":
      case "drizzle":
      case "thunderstorm":
        return const Color(0xFF1565C0);
      case "snow":
        return const Color(0xFF90CAF9);
      default:
        return const Color(0xFF78909C);
    }
  }

  String _capitalize(String s) => s
      .split(" ")
      .map((w) => w.isEmpty ? "" : w[0].toUpperCase() + w.substring(1))
      .join(" ");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F1),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // ─── Green Hero Header ────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 210,
              pinned: true,
              backgroundColor: const Color(0xFF2E7D32),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.07),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 50,
                        top: 40,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 85, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Weather Forecast",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      widget.cityName.isEmpty
                                          ? "Location-based updates"
                                          : widget.cityName,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.cloud_outlined,
                                    color: Colors.white, size: 40),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "Today, ${TimeOfDay.now().format(context)}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.temperature.isEmpty
                                      ? "--°C"
                                      : "${widget.temperature}°C",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(bottom: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.description.isEmpty
                                            ? ""
                                            : _capitalize(
                                            widget.description),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        feelsLike == "--"
                                            ? ""
                                            : "Feels like $feelsLike",
                                        style: TextStyle(
                                          color:
                                          Colors.white.withOpacity(0.8),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // ─── Stats Grid ─────────────────────────────────────────
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 11,
                      mainAxisSpacing: 11,
                      childAspectRatio: 1.05,
                      children: [
                        _StatCard(
                          icon: Icons.water_drop_outlined,
                          iconColor: const Color(0xFF2E7D32),
                          label: "Humidity",
                          value: widget.humidity.isEmpty
                              ? "--"
                              : "${widget.humidity}%",
                        ),
                        _StatCard(
                          icon: Icons.air,
                          iconColor: const Color(0xFF388E3C),
                          label: "Wind Speed",
                          value: windSpeed,
                        ),
                        _StatCard(
                          icon: Icons.visibility_outlined,
                          iconColor: const Color(0xFF43A047),
                          label: "Visibility",
                          value: visibility,
                        ),
                        _StatCard(
                          icon: Icons.speed_outlined,
                          iconColor: const Color(0xFF2E7D32),
                          label: "Pressure",
                          value: pressure,
                        ),
                        _StatCard(
                          icon: Icons.wb_sunny_outlined,
                          iconColor: const Color(0xFFF9A825),
                          label: "UV Index",
                          value: uvIndex,
                        ),
                        _StatCard(
                          icon: Icons.grain,
                          iconColor: const Color(0xFF1565C0),
                          label: "Rain",
                          value: rainChance,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ─── Tab Bar ────────────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: ["Hourly", "7-Day"].map((tab) {
                          final active = _selectedTab == tab;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedTab = tab),
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  color: active
                                      ? const Color(0xFF2E7D32)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: Text(
                                  tab,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: active
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── HOURLY TAB ─────────────────────────────────────────
                    if (_selectedTab == "Hourly") ...[
                      _ChartCard(
                        title: "Temperature Today",
                        data: hourlyData
                            .map((e) => e["temp"] as int)
                            .toList(),
                        labels: hourlyData
                            .map((e) => e["time"] as String)
                            .toList(),
                        color: const Color(0xFF2E7D32),
                        unit: "°C",
                        maxY: 36,
                      ),
                      const SizedBox(height: 14),
                      _ChartCard(
                        title: "Rain Probability",
                        data: hourlyData
                            .map((e) => e["rain"] as int)
                            .toList(),
                        labels: hourlyData
                            .map((e) => e["time"] as String)
                            .toList(),
                        color: const Color(0xFF1565C0),
                        unit: "%",
                        maxY: 30,
                        filled: true,
                      ),
                    ],

                    // ─── 7-DAY TAB ──────────────────────────────────────────
                    if (_selectedTab == "7-Day") ...[
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isLoadingForecast
                            ? const Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        )
                            : sevenDayData.isEmpty
                            ? const Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: Text(
                              "Unable to load forecast data",
                              style: TextStyle(
                                  color: Colors.black45),
                            ),
                          ),
                        )
                            : Column(
                          children: List.generate(
                              sevenDayData.length, (index) {
                            final item = sevenDayData[index];
                            final isLast =
                                index == sevenDayData.length - 1;
                            return Column(
                              children: [
                                _SevenDayRow(
                                  day: item["day"] as String,
                                  condition: _capitalize(
                                      item["condition"]
                                      as String),
                                  weatherIcon: _getWeatherIcon(
                                      item["icon"] as String),
                                  iconColor: _getWeatherIconColor(
                                      item["icon"] as String),
                                  rainPercent:
                                  item["rain"] as int,
                                  temperature:
                                  "${item["temp"]}°",
                                ),
                                if (!isLast)
                                  Divider(
                                    height: 1,
                                    indent: 16,
                                    endIndent: 16,
                                    color: Colors.grey
                                        .withOpacity(0.15),
                                  ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // ─── Weather-Based Advice ────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFA5D6A7),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text("🌿",
                                  style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text(
                                "Weather-Based Advice",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _AdviceTile(
                            color: const Color(0xFF4CAF50),
                            text:
                            "Good conditions for spraying pesticides today (low wind)",
                          ),
                          const SizedBox(height: 8),
                          _AdviceTile(
                            color: const Color(0xFF1565C0),
                            text:
                            "Rain expected Sunday–Monday, plan irrigation accordingly",
                          ),
                          const SizedBox(height: 8),
                          _AdviceTile(
                            color: const Color(0xFFF57F17),
                            text:
                            "High UV today, ensure adequate water for crops",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 7-Day Row ─────────────────────────────────────────────────────────────────
class _SevenDayRow extends StatelessWidget {
  final String day;
  final String condition;
  final IconData weatherIcon;
  final Color iconColor;
  final int rainPercent;
  final String temperature;

  const _SevenDayRow({
    required this.day,
    required this.condition,
    required this.weatherIcon,
    required this.iconColor,
    required this.rainPercent,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Day label
          SizedBox(
            width: 42,
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Weather icon
          Icon(weatherIcon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          // Condition description
          Expanded(
            child: Text(
              condition,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Rain %
          Row(
            children: [
              const Icon(Icons.water_drop,
                  color: Color(0xFF1565C0), size: 14),
              const SizedBox(width: 3),
              Text(
                "$rainPercent%",
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Temperature
          Text(
            temperature,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chart Card ────────────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String title;
  final List<int> data;
  final List<String> labels;
  final Color color;
  final String unit;
  final int maxY;
  final bool filled;

  const _ChartCard({
    required this.title,
    required this.data,
    required this.labels,
    required this.color,
    required this.unit,
    required this.maxY,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineChartPainter(
                data: data,
                labels: labels,
                color: color,
                maxY: maxY,
                filled: filled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Line Chart Painter ────────────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<int> data;
  final List<String> labels;
  final Color color;
  final int maxY;
  final bool filled;

  _LineChartPainter({
    required this.data,
    required this.labels,
    required this.color,
    required this.maxY,
    required this.filled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const double chartTop = 10;
    final double chartBottom = size.height - 24;
    final double chartHeight = chartBottom - chartTop;
    final double stepX = size.width / (data.length - 1);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = chartTop + (chartHeight / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data points
    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = chartTop + chartHeight * (1 - data[i] / maxY);
      points.add(Offset(x, y));
    }

    // Filled gradient area
    if (filled) {
      final fillPath = Path()..moveTo(points.first.dx, chartBottom);
      for (final p in points) {
        fillPath.lineTo(p.dx, p.dy);
      }
      fillPath
        ..lineTo(points.last.dx, chartBottom)
        ..close();
      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.35), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
            Rect.fromLTWH(0, chartTop, size.width, chartHeight));
      canvas.drawPath(fillPath, fillPaint);
    }

    // Curved line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 =
      Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final p in points) {
      canvas.drawCircle(p, 4.5, dotFill);
      canvas.drawCircle(p, 4.5, dotBorder);
    }

    // X labels
    const labelStyle = TextStyle(color: Colors.black45, fontSize: 11);
    for (int i = 0; i < labels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, Offset(i * stepX - tp.width / 2, chartBottom + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── Advice Tile ───────────────────────────────────────────────────────────────
class _AdviceTile extends StatelessWidget {
  final Color color;
  final String text;

  const _AdviceTile({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            width: 8,
            height: 8,
            decoration:
            BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2E4A2E),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

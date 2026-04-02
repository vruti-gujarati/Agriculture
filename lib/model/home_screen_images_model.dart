import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String temperature = "";
  String description = "";
  String humidity = "";
  String cityName = "Ahmedabad";

  final TextEditingController cityController = TextEditingController();

  final String apiKey = "86ccb27e8e74f234c003068b6f9228aa";

  @override
  void initState() {
    super.initState();
    fetchWeather(cityName);
  }

  Future<void> fetchWeather(String city) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("this is is response ${data}");

        setState(() {
          cityName = data["name"];
          temperature = data["main"]["temp"].toString();
          description = data["weather"][0]["description"];
          humidity = data["main"]["humidity"].toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("City not found")),
        );
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F1),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE7F9EB),
        title: const Text(
          "Greenexis",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.menu, color: Colors.black),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              // 🔎 SEARCH BAR
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  hintText: "Enter city name",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(70),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.green[200],
                      child: IconButton(
                        icon: const Icon(Icons.search,
                            color: Colors.black),
                        onPressed: () {
                          if (cityController.text.isNotEmpty) {
                            fetchWeather(
                                cityController.text.trim());
                            cityController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 🌤 WEATHER CARD
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: AssetImage(
                        'assets/home_screen/weather.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      // ✅ Temperature Left, City Right
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            temperature.isEmpty
                                ? "Loading..."
                                : "$temperature°C",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            cityName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Weather description
                      Text(
                        description.isEmpty
                            ? ""
                            : description,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          _WeatherStatus(
                            title: "Humidity",
                            value: humidity.isEmpty
                                ? "--"
                                : "$humidity%",
                          ),
                          const _WeatherStatus(
                              title: "Soil Moisture",
                              value: "Good"),
                          const _WeatherStatus(
                              title: "Precipitation",
                              value: "Low"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 9),

              // 🌾 MANAGE YOUR FIELDS (UNCHANGED)
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5EC),
                  borderRadius:
                  BorderRadius.circular(24),
                ),
                child: Column(
                  children: [

                    const Text(
                      "Manage Your Fields",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 19),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: const [
                          _FieldCard(
                            title: "Plant Guide",
                            imagePath:
                            "assets/home_screen/plant_guide.png",
                          ),
                          _FieldCard(
                            title: "Crops",
                            imagePath:
                            "assets/home_screen/crops.png",
                          ),
                          _FieldCard(
                            title: "Agri ChatBot",
                            imagePath:
                            "assets/home_screen/agrichatbot.png",
                          ),
                          _FieldCard(
                            title: "7/12 Info",
                            imagePath:
                            "assets/home_screen/info712.png",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 0),

                    Container(
                      width: 155,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(16),
                            child: Image.asset(
                              "assets/home_screen/calculator.png",
                              height: 64,
                              width: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Calculator",
                            style: TextStyle(
                                fontWeight:
                                FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherStatus extends StatelessWidget {
  final String title;
  final String value;

  const _WeatherStatus({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius:
            BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const _FieldCard({
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Container(
            height: 84,
            width: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5EC),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

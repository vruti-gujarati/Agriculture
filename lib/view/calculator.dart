import 'package:flutter/material.dart';
// import 'floating_robot.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {

  bool isMaundMode = true;

  final TextEditingController kapasMaundController = TextEditingController();
  final TextEditingController kapasKgController = TextEditingController();
  final TextEditingController kapasMaundPriceController = TextEditingController();

  final TextEditingController directIncomeController = TextEditingController();
  final TextEditingController labourController = TextEditingController();
  final TextEditingController expensesController = TextEditingController();
  final TextEditingController partnershipController = TextEditingController();

  double cottonIncome = 0;
  double totalCost = 0;
  double partnerAmount = 0;
  double farmerShare = 0;
  double farmerFinal = 0;
  double profitPercent = 0;

  void calculateAll() {

    double price = double.tryParse(kapasMaundPriceController.text) ?? 0;
    double productionIncome = 0;

    if (isMaundMode) {

      double maund = double.tryParse(kapasMaundController.text) ?? 0;
      double extraKg = double.tryParse(kapasKgController.text) ?? 0;

      double totalMaund = maund + (extraKg / 20);
      productionIncome = totalMaund * price;

    } else {

      double totalKg = double.tryParse(kapasKgController.text) ?? 0;

      // 🔥 Direct KG Multiply
      productionIncome = totalKg * price;
    }

    double directIncome = double.tryParse(directIncomeController.text) ?? 0;
    double labour = double.tryParse(labourController.text) ?? 0;
    double expenses = double.tryParse(expensesController.text) ?? 0;

    double cost = labour + expenses;

    double percent = double.tryParse(partnershipController.text) ?? 0;
    double partnerShare = (directIncome * percent) / 100;

    double farmerIncomeBeforeCost = directIncome - partnerShare;
    double finalFarmerIncome = farmerIncomeBeforeCost - cost;

    double prfPercent = directIncome > 0
        ? (finalFarmerIncome / directIncome) * 100
        : 0;

    setState(() {
      cottonIncome = productionIncome;
      totalCost = cost;
      partnerAmount = partnerShare;
      farmerShare = farmerIncomeBeforeCost;
      farmerFinal = finalFarmerIncome;
      profitPercent = prfPercent;
    });
  }

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => calculateAll(),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF66BB6A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF66BB6A), width: 1),
          ),
        ),
      ),
    );
  }

  Widget resultRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            "₹ ${value.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget percentRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            "${value.toStringAsFixed(2)} %",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Agri Calculator"),
        backgroundColor: const Color(0xFF66BB6A),
        centerTitle: true,
      ),
        body: Stack(
          children: [

            /// MAIN CONTENT (UNCHANGED)
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF66BB6A), width: 1.5),
                ),
                child: Column(
                  children: [

                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isMaundMode = !isMaundMode;
                            kapasMaundController.clear();
                            kapasKgController.clear();
                            kapasMaundPriceController.clear();
                            cottonIncome = 0;
                            calculateAll();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 38,
                          width: 75,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF66BB6A), Color(0xFF66BB6A)],
                            ),
                          ),
                          child: Stack(
                            children: [

                              AnimatedAlign(
                                duration: const Duration(milliseconds: 250),
                                alignment: isMaundMode
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.all(3.5),
                                  height: 30,
                                  width: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isMaundMode
                                        ? Icons.scale
                                        : Icons.monitor_weight,
                                    size: 18,
                                    color: Color(0xFF66BB6A),
                                  ),
                                ),
                              ),

                              AnimatedAlign(
                                duration: const Duration(milliseconds: 250),
                                alignment: isMaundMode
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMaundMode ? 5 : 15,
                                  ),
                                  child: Text(
                                    isMaundMode ? "Maund" : "KG",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMaundMode ? 11 : 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    isMaundMode
                        ? Column(
                      children: [
                        inputField("Crop Quantity (Maund)", kapasMaundController),
                        inputField("Extra Kg", kapasKgController),
                      ],
                    )
                        : inputField("Crop Quantity (KG)", kapasKgController),

                    inputField(
                      isMaundMode ? "Price per Maund" : "Price per KG",
                      kapasMaundPriceController,
                    ),

                    const Divider(),

                    resultRow("Production Value", cottonIncome),

                    const Divider(),

                    inputField("Income (₹)", directIncomeController),
                    inputField("Labour Cost", labourController),
                    inputField("Expenses Cost", expensesController),

                    const Divider(),

                    resultRow("Total Farming Cost", totalCost),

                    const Divider(),

                    inputField("Partnership %", partnershipController),

                    const Divider(),

                    resultRow("Partner Share", partnerAmount),
                    resultRow("Farmer Share (Before Cost)", farmerShare),
                    resultRow("Final Farmer Income", farmerFinal),

                    const Divider(),

                    percentRow("Profit %", profitPercent),

                  ],
                ),
              ),
            ),

            // /// 🤖 FLOATING ROBOT
            // const Positioned(
            //   bottom: 10,
            //   right: 35,
            //   child: FloatingRobot(),
            // ),

          ],
        ),
    );
        }
}

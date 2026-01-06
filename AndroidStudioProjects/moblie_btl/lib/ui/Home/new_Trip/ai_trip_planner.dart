import 'package:flutter/material.dart';
import '../../../services/ai_service.dart';
// import 'package:flutter_markdown/flutter_markdown.dart'; // Optional: Use if we add markdown package later

class AiTripPlannerPage extends StatefulWidget {
  const AiTripPlannerPage({super.key});

  @override
  State<AiTripPlannerPage> createState() => _AiTripPlannerPageState();
}

class _AiTripPlannerPageState extends State<AiTripPlannerPage> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _fromLocationController = TextEditingController();
  final TextEditingController _peopleCountController = TextEditingController();
  final AiService _aiService = AiService();

  String _result = "";
  bool _isLoading = false;

  void _generateTrip() async {
    final dest = _destinationController.text.trim();
    final duration = _durationController.text.trim();
    final fromLoc = _fromLocationController.text.trim();
    final people = _peopleCountController.text.trim();

    if (dest.isEmpty || duration.isEmpty || fromLoc.isEmpty || people.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = "";
    });

    final schedule = await _aiService.generateTripSchedule(dest, duration, fromLoc, people);

    setState(() {
      _isLoading = false;
      _result = schedule;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo Chuyến Đi Thông Minh ✨", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF153359),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- Input Section ---
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: "Điểm đến (VD: Đà Lạt)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _durationController,
              decoration: InputDecoration(
                labelText: "Thời gian (VD: 3 ngày 2 đêm)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.timer),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _fromLocationController,
              decoration: InputDecoration(
                labelText: "Điểm xuất phát (VD: Hà Nội)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.flight_takeoff),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _peopleCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Số người (VD: 2 người)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.people),
              ),
            ),
            const SizedBox(height: 20),

            // --- Action Button ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF153359),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Tạo lịch trình",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Result Section ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _result.isEmpty
                    ? const Center(
                        child: Text(
                          "Nhập thông tin và nhấn nút để AI gợi ý lịch trình cho bạn!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Text(
                          _result,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

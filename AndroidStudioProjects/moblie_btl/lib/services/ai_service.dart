import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/trip.dart'; 

class AiService {
  // API Key của bạn
  static const String _apiKey = 'AIzaSyCC5TEFMImv8E693F0D6W8MSbw-v0sDbYU';

  late final GenerativeModel _model;

  AiService() {
    _model = GenerativeModel(
      // Giữ model ổn định
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      // SỬA LỖI: Thêm các thiết lập an toàn để đảm bảo tương thích API
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
  }

  Future<String> generateTripSchedule(String destination, String duration) async {
    final prompt = '''
      Lập một lịch trình du lịch chi tiết cho chuyến đi đến $destination trong $duration.
      Hãy trả về kết quả dưới dạng văn bản có cấu trúc rõ ràng, liệt kê theo từng ngày (Ngày 1, Ngày 2...).
      Với mỗi ngày, liệt kê các hoạt động (Sáng, Trưa, Chiều, Tối).
      
      QUAN TRỌNG: Hãy ước tính chi phí dự kiến cho từng hoạt động, ăn uống và đi lại (bằng VND).
      Cuối cùng, hãy tổng hợp tổng chi phí ước tính cho toàn bộ chuyến đi.

      Không cần phần mở bài hay kết bài dài dòng, đi thẳng vào lịch trình.
      Nếu có thể, hãy để hiển thị đẹp mắt.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Không thể tạo lịch trình lúc này.";
    } catch (e) {
      print("Lỗi đầy đủ từ AI Service: $e"); 
      return "Lỗi khi gọi AI: $e";
    }
  }
}

import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // API Key của bạn
  static const String _apiKey = 'AIzaSyBEhVX4jHYynlVxeUeT6L85ujKE8IjVYn8';

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

  Future<String> generateTripSchedule(
    String destination,
    String duration,
    String fromLocation,
    String peopleCount,
  ) async {
    final prompt =
        '''
      Lập một lịch trình du lịch chi tiết cho chuyến đi đến $destination trong $duration.
      Xuất phát từ: $fromLocation
      Số lượng người: $peopleCount
      
      Hãy trả về kết quả dưới dạng văn bản có cấu trúc rõ ràng, liệt kê theo từng ngày (Ngày 1, Ngày 2...).
      Với mỗi ngày, liệt kê các hoạt động (Sáng, Trưa, Chiều, Tối).
      
      QUAN TRỌNG: Hãy ước tính chi phí dự kiến cho từng hoạt động, ăn uống và đi lại (bằng VND) dựa trên số lượng người là $peopleCount.
      Cuối cùng, hãy tổng hợp tổng chi phí ước tính cho toàn bộ chuyến đi cho cả nhóm.

      Không cần phần mở bài hay kết bài dài dòng, đi thẳng vào lịch trình.
      Nếu có thể, hãy định dạng Markdown để hiển thị đẹp mắt.
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

  // --- MỚI: TẠO DỮ LIỆU CHUYẾN ĐI MẪU ---
  // --- MỚI: TẠO DỮ LIỆU CHUYẾN ĐI MẪU ---
  Future<List<Map<String, dynamic>>> generateSampleTrips() async {
    const prompt = '''
      Hãy tạo ra 3 ý tưởng chuyến đi du lịch thú vị (trong nước Việt Nam hoặc quốc tế).
      Trả về kết quả dưới dạng JSON thuần túy (không có markdown block ```json).
      Cấu trúc MẢNG JSON như sau (bắt buộc đúng format):
      [
        {
          "name": "Tên chuyến đi (ngắn gọn)",
          "destination": "Địa điểm",
          "description": "Mô tả tổng quan, bao gồm tổng chi phí dự kiến.",
          "days": [
            {
              "day": 1,
              "activities": [
                {
                  "title": "Tên hoạt động",
                  "location": "Địa điểm cụ thể",
                  "description": "Mô tả chi tiết + Chi phí dự kiến (VD: Vé 50k, Ăn 100k)",
                  "startHour": 8, 
                  "durationHours": 2
                }
              ]
            }
          ]
        }
      ]
      QUAN TRỌNG: 
      - "startHour" là số nguyên (0-23).
      - "durationHours" là số thực (ví dụ 1.5).
      - Hãy bịa ra ít nhất 2 ngày cho mỗi chuyến, mỗi ngày 3-4 hoạt động.
      - JSON phải hợp lệ.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      String? text = response.text;

      if (text == null) return [];

      // Clean up markdown markers if present
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      final List<dynamic> jsonList = jsonDecode(text);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      print("Lỗi tạo sample trips: $e");
      return [];
    }
  }
}

<think>Hãy phân tích và trả lời từng câu hỏi dựa trên mã nguồn và tài liệu đã cung cấp:

1. Về việc lưu trữ và load Character:
   - Nhân vật được lưu ở cả local (thông qua Hive và local storage) và cloud (thông qua Supabase)
   - Cần xác định chi tiết luồng lưu trữ và việc load lại
   - Phân tích khả năng xảy ra quá tải và cách tối ưu

2. Định dạng file JSON input và cấu trúc prompt:
   - Cần xác định định dạng JSON input từ mã nguồn
   - Phân tích cách lắp ghép thành prompt
   - Mô tả cấu trúc prompt đầu ra

3. Khả năng offline và xử lý khi Supabase không khả dụng:
   - Phân tích cách hệ thống xử lý khi không có kết nối
   - Đánh giá các cơ chế dự phòng
   - Đề xuất tối ưu

4. Vấn đề bảo mật với system prompt:
   - Phân tích lỗ hổng prompt injection
   - Đánh giá các lỗ hổng bảo mật khác
   - Gợi ý cách giảm thiểu rủi ro

5. CRUD với Supabase - file và hàm chính:
   - Xác định các file quan trọng trong quá trình CRUD
   - Phân tích các hàm chính xử lý logic CRUD</think># GIẢI ĐÁP CÁC CÂU HỎI CHẤT VẤN VỀ TÍNH NĂNG "CHARACTER"

## 1. Lưu trữ, tải và tối ưu hóa Character

### Cơ chế lưu trữ
Nhân vật sau khi được tạo/import sẽ được lưu trữ ở hai vị trí:

- **Local Storage**:
  - Hive được sử dụng để lưu trữ preferences của người dùng cho mỗi nhân vật thông qua class `AiCharacterPreference`
  - Files (như avatar) được lưu trong thư mục ứng dụng sử dụng `path_provider` trong `CharacterTemplateService`
  - Nhân vật mặc định được lưu trữ trong file JSON trong bundle ứng dụng và được tải qua `DefaultCharacterLoader`

- **Supabase (Cloud)**:
  - Thông tin nhân vật được lưu trong bảng `characters` (xử lý bởi `UnifiedCharacterRepository`)
  - Thông tin "thích" được lưu ở bảng `character_likes` (quan hệ nhiều-nhiều)

### Cơ chế tải nhân vật
Quá trình tải nhân vật diễn ra theo các bước:

1. **Từ `AiCharacterService`**: Khi ứng dụng khởi động, service sẽ:
   - Đầu tiên tải nhân vật mặc định từ `DefaultCharacterLoader`
   - Tải các nhân vật đã lưu từ local thông qua preferences
   - Đồng bộ hóa với cloud thông qua `SyncManager` và `UnifiedCharacterRepository`

2. **Caching thông minh**:
   - `DefaultCharacterLoader` có cơ chế cache: `static List<AiCharacter>? _cachedCharacters`
   - `UnifiedCharacterRepository` thực hiện các truy vấn phức tạp chỉ khi cần thiết

### Xử lý với số lượng lớn nhân vật
Khi người dùng upload >1000 nhân vật lên server:

- **Vấn đề tiềm ẩn**:
  - Quá tải băng thông và không gian lưu trữ
  - Truy vấn chậm ảnh hưởng đến tất cả người dùng
  - Tải nhiều dữ liệu không cần thiết về thiết bị người dùng

- **Giải pháp hiện tại**:
  - Tất cả các hàm lấy danh sách nhân vật đều có pagination (tham số `limit` và `offset`) để không lấy toàn bộ cùng lúc
  ```dart
  Future<List<AiCharacter>> getAllPublicCharacters({
    int limit = 50,
    int offset = 0,
    // ...
  })
  ```

- **Tối ưu hóa đề xuất**:
  1. **Quota và Rate Limiting**: Giới hạn số lượng nhân vật mỗi người dùng có thể tạo
  2. **Lazy Loading**: Chỉ tải avatar và thông tin chi tiết khi cần
  3. **Content Moderation**: Kiểm duyệt tự động để ngăn chặn spam/lạm dụng
  4. **Database Indexing**: Tối ưu hóa các truy vấn thường xuyên sử dụng
  5. **CDN cho Avatar**: Sử dụng CDN chuyên biệt để cache hình ảnh

## 2. Định dạng JSON Input và Cấu trúc Prompt

### Định dạng file JSON input
Dựa vào code trong `CharacterTemplateService.importTemplate()`, định dạng input có thể có nhiều biến thể:

- **Định dạng chuẩn**:
```json
{
  "spec": "chara_card_v2",
  "spec_version": "2.0",
  "data": {
    "name": "Tên nhân vật",
    "description": "Mô tả chi tiết",
    "personality": "Tính cách",
    "scenario": "Bối cảnh",
    "first_mes": "Tin nhắn chào đầu tiên",
    "example_messages": ["Ví dụ 1", "Ví dụ 2"],
    "avatar": "đường dẫn đến ảnh đại diện",
    "tags": ["tag1", "tag2"],
    "creator": "Người tạo",
    "created_at": "2023-01-01T00:00:00Z",
    "updated_at": "2023-01-01T00:00:00Z",
    "character_version": "1.0.0",
    "system_prompt": "Hướng dẫn hệ thống"
  }
}
```

- **Xử lý linh hoạt**: Code có khả năng xử lý nhiều trường hợp:
  - Dữ liệu bọc trong key `data` hoặc trực tiếp ở root
  - Trường hợp `name` hoặc `char_name`
  - Trường hợp `first_mes` hoặc `greeting_message`
  - Trường `description` là JSON lồng nhau hoặc văn bản thông thường
  - Tags có thể là chuỗi phân tách bởi dấu phẩy hoặc mảng

### Cấu trúc và lắp ghép prompt
Nhân vật được chuyển thành prompt theo phương thức `getEffectiveSystemPrompt()` trong class `AiCharacter`:

```dart
String getEffectiveSystemPrompt() {
  if (systemPrompt != null && systemPrompt!.isNotEmpty) {
    return systemPrompt!;
  }

  return '''You are $name, $personality

SCENARIO:
$scenario

ROLEPLAY RULES:
- Chat exclusively as $name
- Keep responses personal and in-character
- Use subtle physical cues to hint at mental state
- Include internal thoughts in asterisks *like this*
- Keep responses concise (2-3 sentences)
- Stay in character at all times
- Express emotions and reactions naturally
- Use your character's unique way of speaking''';
}
```

### Prompt đầu ra
Prompt đầu ra có định dạng như sau:

1. **Nếu có system_prompt tùy chỉnh**: Sử dụng trực tiếp giá trị đó
2. **Mặc định**: Tạo prompt cấu trúc gồm:
   - **Phần giới thiệu**: "You are [tên nhân vật], [mô tả tính cách]"
   - **Phần bối cảnh**: "SCENARIO: [nội dung kịch bản]"
   - **Quy tắc roleplay**: Liệt kê 8 quy tắc định hình cách nhân vật trả lời

## 3. Xử lý khi Supabase không khả dụng

### Khả năng hoạt động offline
Nếu Supabase sập, hệ thống vẫn có thể hoạt động với mức độ giới hạn:

- **Hoạt động được**:
  - Tải và sử dụng các nhân vật mặc định từ file JSON trong ứng dụng thông qua `DefaultCharacterLoader`
  - Sử dụng nhân vật đã lưu trong bộ nhớ local
  - Tạo và chỉnh sửa nhân vật mới (lưu local)

- **Không hoạt động**:
  - Đồng bộ dữ liệu lên cloud
  - Khám phá nhân vật công khai
  - Thích/bỏ thích nhân vật
  - Xem số lượt tải

### Cơ chế hiện tại
Hiện tại, hệ thống có một số cơ chế xử lý khi không kết nối được:

1. **Try-catch trong các hàm truy cập Supabase**:
```dart
try {
  // Truy cập Supabase
} catch (e, stack) {
  _log.severe('Error getting public characters', e, stack);
  return []; // Trả về danh sách trống
}
```

2. **Fallback tới nhân vật mặc định**:
```dart
if (_characters.isEmpty) {
  _log.info('No saved characters found, loading defaults');
  _characters = await DefaultCharacterLoader.loadDefaultCharacters();
}
```

### Đề xuất tối ưu hóa
Để tăng cường khả năng offline:

1. **Offline-first Architecture**:
   - Triển khai hệ thống local-first, coi cloud như điểm đồng bộ phụ
   - Lưu cache các nhân vật phổ biến trong bộ nhớ local

2. **Background Synchronization**:
   - Đưa tất cả thao tác với Supabase vào hàng đợi khi offline
   - Đồng bộ khi có kết nối trở lại (WorkManager/Background Tasks)

3. **Service Worker và Progressive Web App**:
   - Triển khai PWA capabilities để cải thiện trải nghiệm offline
   - Tạo manifest để tải trước nhân vật phổ biến

4. **Conflict Resolution**:
   - Cài đặt cơ chế giải quyết xung đột trong trường hợp chỉnh sửa offline rồi mới đồng bộ

5. **Global Error Boundary**:
   - Cảnh báo người dùng khi đang ở chế độ offline
   - Tạo UI thân thiện khi không thể tải dữ liệu từ server

## 4. Vấn đề bảo mật system prompt

### Prompt Injection
Người dùng có thể tùy chỉnh system prompt thông qua trường `systemPrompt` trong `AiCharacter`:

- **Nguy cơ**:
  - **Prompt Leaking**: Tin tặc có thể lừa mô hình AI tiết lộ system prompt gốc
  - **Instruction Override**: Vượt qua các giới hạn của mô hình AI
  - **Harmful Content**: Tạo nội dung độc hại, bạo lực hoặc thiếu văn hóa
  - **Data Extraction**: Dụ mô hình tiết lộ thông tin người dùng khác

- **Hậu quả**:
  - Mô hình AI có thể lộ thông tin nhạy cảm
  - Nhân vật có thể trả lời không phù hợp với giá trị của ứng dụng
  - Người dùng trải nghiệm nội dung tiêu cực khi tương tác

### Lỗ hổng bảo mật khác
Một số lỗ hổng bảo mật tiềm ẩn:

1. **Client-side Authorization**:
   - Một số kiểm tra quyền được thực hiện ở client:
   ```dart
   final userId = _supabase.auth.currentUser?.id;
   if (userId == null) {
     throw Exception('User not authenticated');
   }
   ```

2. **Thiếu Sanitization Input**:
   - `character_template_service.dart` xử lý JSON từ nguồn bên ngoài nhưng thiếu kiểm tra kỹ lưỡng
   - Có thể dẫn đến XSS hoặc JSON injection

3. **Lưu trữ Avatar không an toàn**:
   - Ảnh nhân vật có thể chứa mã độc (steganography)
   - Thiếu kiểm tra định dạng và nội dung file

4. **Quản lý bộ nhớ**:
   - Thiếu giới hạn kích thước cho một số trường (ví dụ: `personality` có thể rất lớn)
   - Có thể dẫn đến tấn công cạn kiệt tài nguyên

### Giải pháp đề xuất
Để cải thiện bảo mật:

1. **Prompt Validation**:
   - Thêm whitelist/blacklist từ khóa trong system prompt
   - Giới hạn độ dài system prompt
   - AI-based scanning để phát hiện lệnh nguy hiểm

2. **Input Sanitization**:
   - Triển khai kiểm tra nghiêm ngặt cho mọi trường nhập liệu
   - Sử dụng thư viện chuyên dụng để xử lý JSON/XML từ nguồn bên ngoài

3. **Server-side Authorization**:
   - Di chuyển logic quyền truy cập sang phía server (Row Level Security của Supabase)
   - Triển khai JWT validation cho mọi request

4. **Image Processing**:
   - Tạo service riêng xử lý và kiểm tra avatar trước khi lưu
   - Chuyển đổi định dạng để loại bỏ payload độc hại

5. **Rate Limiting**:
   - Áp dụng giới hạn API call trên mỗi người dùng
   - Giám sát mẫu sử dụng bất thường

## 5. CRUD với Supabase - File và hàm chính

### File đóng vai trò chính trong CRUD
Các file chính xử lý CRUD operations với Supabase:

1. **`unified_character_repository.dart`**: Repository chính xử lý CRUD cho đối tượng AiCharacter
2. **`public_character_repository.dart`**: Xử lý nhân vật công khai
3. **`character_template_service.dart`**: Quản lý các template nhân vật
4. **`ai_character_service.dart`**: Service cấp cao điều phối các repository

### Hàm đóng vai trò chính

Trong `UnifiedCharacterRepository`:

1. **Create & Update**:
```dart
Future<AiCharacter?> saveCharacter(AiCharacter character, {...})
```

2. **Read**:
```dart
Future<List<AiCharacter>> getAllPublicCharacters({...})
Future<AiCharacter?> getCharacterById(String id)
Future<List<AiCharacter>> getUserCharacters()
Future<List<AiCharacter>> searchCharacters(String query, {...})
```

3. **Delete**:
```dart
Future<bool> deleteCharacter(String id)
```

4. **Các thao tác bổ sung**:
```dart
Future<bool> likeCharacter(String characterId)
Future<bool> unlikeCharacter(String characterId)
Future<bool> incrementDownloadCount(String characterId)
```

Trong `CharacterTemplateService`:

1. **Import/Export**:
```dart
Future<AiCharacter> importTemplate(String jsonPath)
Future<String> exportTemplate(AiCharacter character)
```

2. **Làm việc với Supabase**:
```dart
Future<void> saveTemplate(AiCharacter character, {...})
Future<List<AiCharacter>> getUserTemplates()
Future<List<AiCharacter>> getPublicTemplates()
Future<void> deleteTemplate(String name)
```

Các hàm này triển khai đầy đủ CRUD functionality với xử lý lỗi, logging, và business logic phức tạp để đảm bảo tính nhất quán dữ liệu giữa local và cloud.

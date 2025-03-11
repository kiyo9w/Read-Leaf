# TÀI LIỆU TÍNH NĂNG "CHARACTER"

## I. TẦM NHÌN PHỔ QUÁT DƯỚI GÓC NHÌN CỦA NGƯỜI DÙNG

### Tổng quan tính năng "Character"

Tính năng "Character" trong ứng dụng Read Leaf là một phần trọng tâm cho phép người dùng tương tác với các nhân vật AI được cá nhân hóa. Đây là cách mà ứng dụng tạo ra trải nghiệm đọc và giao tiếp tương tác có chiều sâu, vượt qua giới hạn của việc đọc sách truyền thống.

### Trải nghiệm người dùng với Character

- **Lựa chọn nhân vật**: Người dùng có thể chọn từ một bộ sưu tập các nhân vật AI đa dạng, mỗi nhân vật có tính cách, nền tảng và phong cách giao tiếp riêng biệt.
- **Tương tác hai chiều**: Thay vì chỉ đọc nội dung tĩnh, người dùng có thể trò chuyện trực tiếp với nhân vật, nhận được phản hồi phù hợp với tính cách của nhân vật đó.
- **Khám phá nhân vật công cộng**: Người dùng có thể khám phá và tải về các nhân vật do cộng đồng tạo ra, mở rộng trải nghiệm của họ.
- **Tạo nhân vật riêng**: Tính năng cho phép người dùng tạo nhân vật AI của riêng mình, tùy chỉnh từ tính cách, ngoại hình đến cách phản ứng.
- **Chia sẻ với cộng đồng**: Người dùng có thể chia sẻ nhân vật họ tạo ra với cộng đồng, nhận phản hồi và theo dõi số lượt tải về, lượt thích.

### Ví dụ trải nghiệm sử dụng

Minh họa trải nghiệm của một người dùng:

1. Nguyễn Văn A đang đọc một cuốn tiểu thuyết fantasiy và muốn hiểu sâu hơn về nhân vật chính.
2. Anh ấy chọn nhân vật "Elara - The Mystic Guide" từ danh sách nhân vật công khai.
3. Khi tương tác, Elara trả lời với phong cách bí ẩn, sử dụng ngôn ngữ phù hợp với bối cảnh fantasy, giúp Nguyễn Văn A hiểu sâu hơn về thế giới trong cuốn sách.
4. Khi Elara đang "suy nghĩ", người dùng nhìn thấy hiệu ứng gõ chữ (typing indicator) làm tăng cảm giác thực tế của cuộc trò chuyện.
5. Nguyễn Văn A có thể xem thông tin chi tiết về Elara thông qua popup thông tin nhân vật, hiểu rõ về tính cách và bối cảnh của nhân vật này.
6. Nếu Nguyễn Văn A thích nhân vật này, anh ta có thể "thích" nhân vật và nó sẽ được lưu vào danh sách yêu thích để dễ dàng truy cập sau này.

## II. THIẾT KẾ VÀ TECH STACK CHÍNH ĐƯỢC ÁP DỤNG

### Cấu trúc mã nguồn theo Clean Architecture

Tính năng Character được tổ chức theo mô hình Clean Architecture với cách phân chia thư mục rõ ràng:

1. **Domain Layer**:
   - `models/`: Chứa các mô hình dữ liệu cốt lõi như `AiCharacter`, `PublicCharacter`, `AiCharacterPreference`
   - Các model này định nghĩa cấu trúc dữ liệu và các phương thức cơ bản

2. **Data Layer**:
   - `default_character_loader.dart`: Tải các nhân vật mặc định từ tài nguyên ứng dụng
   - `character_suggestion_service.dart`: Cung cấp gợi ý cho việc tạo nhân vật
   - Các repository và service khác để quản lý nhân vật

3. **Presentation Layer**:
   - `widgets/`: Chứa các widget UI như `typing_indicator.dart`
   - Cung cấp giao diện người dùng để tương tác với nhân vật

### Các thư viện và packages cốt lõi

1. **json_annotation/json_serializable**: Sử dụng cho việc tự động tạo code chuyển đổi giữa JSON và Dart objects.
   ```dart
   @JsonSerializable()
   class AiCharacter {
     // Properties and methods
   }
   ```

2. **Hive**: Sử dụng làm cơ sở dữ liệu local để lưu trữ các tùy chọn nhân vật.
   ```dart
   @HiveType(typeId: 6)
   class AiCharacterPreference extends HiveObject {
     @HiveField(0)
     final String characterName;
     
     @HiveField(1)
     final DateTime lastUsed;
   }
   ```

3. **Supabase Flutter**: Cung cấp backend-as-a-service, được sử dụng để lưu trữ và đồng bộ nhân vật trên cloud.

4. **Logging**: Triển khai hệ thống log để theo dõi và gỡ lỗi.
   ```dart
   static final _log = Logger('DefaultCharacterLoader');
   ```

## III. KEY FINDINGS - PHÁT KIẾN VÀ ĐIỂM ĐỘT PHÁ VỀ LOGIC

### 1. Mô hình dữ liệu AiCharacter linh hoạt và đầy đủ

`AiCharacter` là mô hình data cốt lõi:

```dart
@JsonSerializable()
class AiCharacter {
  final String name;
  final String summary;
  final String personality;
  final String scenario;
  @JsonKey(name: 'greeting_message')
  final String greetingMessage;
  @JsonKey(name: 'example_messages', defaultValue: [])
  final List<String> exampleMessages;
  @JsonKey(name: 'avatar_image_path')
  final String avatarImagePath;
  @JsonKey(name: 'character_version')
  final String characterVersion;
  @JsonKey(name: 'system_prompt')
  final String? systemPrompt;
  @JsonKey(defaultValue: [])
  final List<String> tags;
  final String creator;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final AiGenerationParams generationParams;
}
```

**Điểm đột phá về logic**:
- **Đa dạng thuộc tính**: Mô hình bao gồm đầy đủ các thuộc tính cần thiết của một nhân vật AI như tên, tính cách, kịch bản, lời chào, v.v.
- **JSON Serialization**: Sử dụng annotation để tự động hóa việc chuyển đổi giữa JSON và đối tượng Dart
- **Nullable System Prompt**: Thiết kế cho phép system prompt tùy chọn, kết hợp với fallback
- **Tùy chỉnh tham số sinh**: Hỗ trợ tùy chỉnh các tham số sinh AI qua `AiGenerationParams`
- **Validation tích hợp**: Phương thức `validate` giúp kiểm tra tính hợp lệ của dữ liệu nhân vật

### 2. Hệ thống cache trong DefaultCharacterLoader

`DefaultCharacterLoader` triển khai một cơ chế cache đơn giản nhưng hiệu quả:

```dart
class DefaultCharacterLoader {
  static final _log = Logger('DefaultCharacterLoader');
  static List<AiCharacter>? _cachedCharacters;

  static Future<List<AiCharacter>> loadDefaultCharacters() async {
    // Return from cache if available
    if (_cachedCharacters != null) {
      return _cachedCharacters!;
    }

    try {
      _log.info('Loading default characters from assets');
      final jsonString = await rootBundle
          .loadString('lib/features/characters/data/default_characters.json');
      final jsonMap = json.decode(jsonString);
      final charactersList = jsonMap['characters'] as List;

      // Convert each character JSON to an AiCharacter object
      final characters = charactersList
          .map((charJson) {
            try {
              final Map<String, dynamic> characterData =
                  charJson.containsKey('data') ? charJson['data'] : charJson;
              return AiCharacter.fromJson(characterData);
            } catch (e) {
              _log.warning('Failed to parse character: $e');
              return null;
            }
          })
          .whereType<AiCharacter>() // Filter out nulls
          .toList();

      // Cache the characters
      _cachedCharacters = characters;
      
      return characters;
    } catch (e, stack) {
      _log.severe('Error loading default characters', e, stack);
      return [];
    }
  }
  
  static void clearCache() {
    _cachedCharacters = null;
    _log.info('Default character cache cleared');
  }
}
```

**Điểm đột phá về logic**:
- **In-memory caching**: Sử dụng biến static để lưu trữ nhân vật đã tải, tránh đọc lại file JSON
- **Static singleton pattern**: Theo mô hình singleton để đảm bảo truy cập nhất quán
- **Robust error handling**: Xử lý lỗi khi tải và phân tích nhân vật
- **Flexible JSON parsing**: Xử lý nhiều định dạng JSON (có hoặc không có trường `data`)
- **Null safety**: Lọc bỏ các nhân vật không hợp lệ bằng `whereType<AiCharacter>()`

### 3. Tạo prompt hệ thống động

Phương thức `getEffectiveSystemPrompt()` trong `AiCharacter` thể hiện cách tiếp cận thông minh trong việc tạo prompt:

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

**Điểm đột phá về logic**:
- **Fallback thông minh**: Sử dụng system prompt tùy chỉnh nếu có, nếu không tự động tạo
- **Cấu trúc clear**: Chia prompt thành các phần rõ ràng: giới thiệu, kịch bản và quy tắc
- **Template interpolation**: Nhúng các thuộc tính cụ thể của nhân vật (tên, tính cách) vào prompt
- **Hướng dẫn chi tiết**: Cung cấp quy tắc rõ ràng giúp mô hình AI hiểu cách trả lời

### 4. Hệ thống gợi ý thông minh dựa trên đặc điểm tính cách

`CharacterSuggestionService` cung cấp một hệ thống gợi ý phức tạp dựa trên mối quan hệ giữa các đặc điểm:

```dart
static List<String> getRelatedTraits(String trait, {int maxSuggestions = 3}) {
  if (_cachedRelatedTraits.containsKey(trait)) {
    return _cachedRelatedTraits[trait]!;
  }

  if (_personalityData == null) {
    return [];
  }

  final relationships = _personalityData!['trait_relationships'] as Map<String, dynamic>;
  if (relationships.containsKey(trait)) {
    final traitRelations = relationships[trait] as Map<String, dynamic>;
    final sortedTraits = traitRelations.entries.toList()
      ..sort((a, b) => (b.value as double).compareTo(a.value as double));

    final relatedTraits = sortedTraits.take(maxSuggestions).map((e) => e.key).toList();
    _cachedRelatedTraits[trait] = relatedTraits;
    return relatedTraits;
  }

  // Tìm đặc điểm từ cùng một danh mục nếu không tìm thấy mối quan hệ trực tiếp
  final categories = _personalityData!['trait_categories'] as Map<String, dynamic>;
  for (final category in categories.entries) {
    final traits = category.value as List<dynamic>;
    if (traits.contains(trait)) {
      final otherTraits = traits
          .where((t) => t != trait)
          .take(maxSuggestions)
          .cast<String>()
          .toList();
      _cachedRelatedTraits[trait] = otherTraits;
      return otherTraits;
    }
  }

  return [];
}
```

**Điểm đột phá về logic**:
- **Cơ sở dữ liệu mối quan hệ tính cách**: Sử dụng file JSON chứa dữ liệu về mối quan hệ giữa các đặc điểm tính cách
- **Caching results**: Lưu trữ kết quả đã tính toán để tăng hiệu suất
- **Phân loại đặc điểm**: Dựa vào cả mối quan hệ trực tiếp và phân loại để tìm đặc điểm liên quan
- **Fallback logic**: Khi không tìm thấy mối quan hệ trực tiếp, tìm đặc điểm từ cùng danh mục
- **Weighted sorting**: Sắp xếp các đặc điểm theo mức độ liên quan (weight) để đề xuất những đặc điểm phù hợp nhất

### 5. Hiệu ứng typing indicator sống động

Widget `TypingIndicator` triển khai một hiệu ứng đang nhập sống động và chuyên nghiệp:

```dart
class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(
      3,
      (index) => TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1, end: 0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 40,
        ),
        TweenSequenceItem(
          tween: ConstantTween<double>(0),
          weight: 20,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2, // Stagger the animations
            0.6 + index * 0.2,
            curve: Curves.linear,
          ),
        ),
      ),
    );
  }
```

**Điểm đột phá về logic**:
- **Staggered animation**: Các chấm nhảy theo mẫu chậm lại với nhau tạo hiệu ứng sóng
- **Multiple animation curves**: Kết hợp nhiều đường cong animation (easeIn, easeOut) tạo chuyển động tự nhiên
- **TweenSequence implementation**: Sử dụng TweenSequence cho phép chuỗi các animation khác nhau
- **Responsive design**: Tự động điều chỉnh kích thước theo thiết bị (điện thoại/máy tính bảng)
- **Theme integration**: Sử dụng màu sắc từ theme cho tính nhất quán trong giao diện

### Phân tích đánh giá tổng thể và khả năng cải thiện

**Điểm mạnh chính**:
1. **Model chuẩn hóa**: AiCharacter cung cấp cấu trúc dữ liệu nhất quán cho toàn bộ hệ thống
2. **Tối ưu hiệu suất**: Cơ chế cache trong DefaultCharacterLoader cải thiện thời gian tải
3. **Logic AI thông minh**: Tạo system prompt động dựa trên thuộc tính nhân vật
4. **Gợi ý dựa trên dữ liệu**: CharacterSuggestionService sử dụng dữ liệu mối quan hệ phức tạp
5. **UI tương tác**: TypingIndicator tạo cảm giác tương tác thực với AI

**Khả năng cải thiện**:
1. **Tối ưu hóa dữ liệu offline**: Áp dụng các chiến lược lưu trữ nâng cao để giảm kích thước dữ liệu
2. **Đồng bộ hóa xung đột**: Xử lý tốt hơn khi có xung đột giữa dữ liệu local và cloud
3. **Caching avatar**: Tối ưu hóa việc tải và lưu trữ hình ảnh nhân vật
4. **Prompt safety**: Bổ sung kiểm tra bảo mật cho system prompt tùy chỉnh
5. **Đa dạng thiết bị**: Kiểm thử và tối ưu hóa với nhiều kích thước màn hình khác nhau
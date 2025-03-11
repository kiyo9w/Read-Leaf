## 1. Góc nhìn người dùng

### Tổng quan
Tính năng Companion Chat trong Read Leaf là một nền tảng trò chuyện với AI tích hợp vào trải nghiệm đọc sách, cho phép người dùng tương tác với nhân vật AI về nội dung sách họ đang đọc. Trò chuyện được thiết kế để cảm giác như đối thoại với một người bạn đồng hành, nắm rõ văn phong và đặc điểm tính cách của nhân vật họ đại diện.

### Trải nghiệm người dùng
Khi sử dụng tính năng Companion Chat, người dùng có thể:

1. **Tương tác với nhân vật AI**: Trò chuyện với nhân vật AI có tính cách riêng biệt, được thiết kế để phản ánh tính cách đặc trưng của nhân vật đó.

2. **Đặt câu hỏi về nội dung sách**: Người dùng có thể hỏi về nội dung đang đọc, yêu cầu giải thích đoạn văn khó hiểu, hoặc thảo luận về các khía cạnh khác của cuốn sách.

3. **Nhận khuyến khích đọc sách**: AI có thể chủ động khuyến khích người dùng tiếp tục đọc sách và cung cấp các nhận xét động viên dựa trên tiến trình đọc.

4. **Dễ dàng truy cập chat**: Chat được thiết kế như một widget nổi có thể:
   - Di chuyển tự do trên màn hình
   - Thu gọn thành biểu tượng nhỏ khi không sử dụng
   - Mở rộng thành cửa sổ chat đầy đủ khi cần thiết
   - Điều chỉnh kích thước theo ý muốn

5. **Đánh dấu văn bản và hỏi**: Người dùng có thể đánh dấu một đoạn văn trong sách và yêu cầu AI giải thích hoặc thảo luận về đoạn văn đó.

### Hành trình người dùng

1. **Khởi đầu**: Người dùng đang đọc sách và gặp một đoạn văn hoặc khái niệm thú vị hoặc khó hiểu.

2. **Mở chat**: Người dùng nhấn vào biểu tượng chat nổi ở góc màn hình.

3. **Đặt câu hỏi**: Người dùng đặt câu hỏi về nội dung sách hoặc chọn một đoạn văn để thảo luận.

4. **Nhận phản hồi có nhân cách**: AI phản hồi với phong cách và cá tính của nhân vật đã chọn, cung cấp thông tin phù hợp và trò chuyện tự nhiên.

5. **Tùy chỉnh vị trí**: Người dùng có thể kéo chat đến vị trí phù hợp trên màn hình để không cản trở việc đọc sách.

6. **Thu gọn khi cần**: Khi muốn tập trung đọc, người dùng có thể thu gọn cửa sổ chat thành biểu tượng nhỏ.

7. **Tiếp tục đối thoại**: Người dùng có thể tiếp tục cuộc trò chuyện bất cứ lúc nào, với lịch sử trò chuyện được lưu trữ theo nhân vật và cuốn sách.

## 2. Thiết kế và Tech Stack

### Kiến trúc
Tính năng Companion Chat được xây dựng theo mô hình Clean Architecture với ba lớp chính:

1. **Domain Layer**:
   - Model: `ChatMessage` - Đại diện cho một tin nhắn trong cuộc trò chuyện
   - Logic nghiệp vụ cốt lõi về quản lý trò chuyện

2. **Data Layer**:
   - `ChatService`: Quản lý lưu trữ và truy xuất tin nhắn
   - `GeminiService`: Tích hợp với Google Generative AI (Gemini) để tạo phản hồi
   - `RagService`: Dịch vụ Retrieval-Augmented Generation (hiện không dùng)

3. **Presentation Layer**:
   - `ChatScreen`: Giao diện chính của cửa sổ chat
   - `FloatingChatWidget`: Widget nổi có thể di chuyển và thay đổi kích thước
   - `FloatingChatHead`: Biểu tượng chat khi ở chế độ thu gọn

### Công nghệ sử dụng
- **State Management**: GetIt cho dependency injection
- **Local Storage**: Hive để lưu trữ tin nhắn chat
- **AI Integration**: Google Generative AI SDK cho tích hợp Gemini
- **Reactive Programing**: RxDart cho luồng dữ liệu phản ứng
- **UI Components**: Animations API của Flutter cho hiệu ứng chuyển động mượt mà
- **Image Caching**: Cached Network Image cho tải hình đại diện hiệu quả
- **Synchronization**: SyncManager để đồng bộ hóa dữ liệu với máy chủ

### Luồng dữ liệu
1. Người dùng nhập tin nhắn trong `ChatScreen`
2. Tin nhắn được lưu vào bộ nhớ cục bộ qua `ChatService`
3. `GeminiService` xử lý tin nhắn với AI và tạo phản hồi
4. Phản hồi được lưu trữ và hiển thị trên giao diện
5. Đồng thời, tin nhắn được xếp hàng đợi để đồng bộ hóa lên máy chủ

### Đồng bộ hóa
Tính năng Companion Chat tích hợp với hệ thống đồng bộ hóa trung tâm của ứng dụng:
- Tin nhắn được lưu trữ cục bộ trước tiên
- `ChatService` sử dụng `SyncManager` để đồng bộ hóa lên đám mây
- Tin nhắn được đánh dấu trạng thái đồng bộ (`isSynced`)
- Người dùng có thể thấy trực quan trạng thái đồng bộ của mỗi tin nhắn

## 3. Phát hiện chính

### Hệ thống nhân vật AI

#### System Prompt Động
`GeminiService` sử dụng system prompt động để đảm bảo AI luôn nhất quán với nhân vật được chọn:

```dart
String _buildFinalPrompt({
  required String finalPrompt,
  required String? customPrompt,
  required String selectedText,
  required String bookTitle,
  required int currentPage,
  required int totalPages,
  required AiCharacter character,
  required String conversationContext,
  bool isAlternativeBook = false,
}) {
  // Base system prompt for roleplay
  const baseSystemPrompt =
      """Write the next reply in a fictional roleplay chat between {CHARACTER_NAME} and {USER}. Write 1 reply only in a natural, conversational style...
```

Hệ thống prompt:
1. **Động theo nhân vật**: Chèn tên, cá tính, kịch bản của nhân vật vào prompt
2. **Bao gồm context sách**: Chèn tiêu đề sách, trang hiện tại, tổng số trang
3. **Bao gồm văn bản đã chọn**: Chèn đoạn văn bản người dùng đã chọn để thảo luận
4. **Chèn lịch sử trò chuyện**: Đảm bảo AI hiểu được ngữ cảnh của cuộc trò chuyện

#### Prompt Khuyến khích Đặc biệt
Một loại prompt đặc biệt được dùng cho phản hồi khuyến khích đọc sách:

```dart
static const String _baseEncouragementPrompt = """
CHARACTER CONTEXT:
Name: {CHARACTER_NAME}
Personality: {PERSONALITY}
Scenario: {SCENARIO}

BOOK CONTEXT:
Title: {BOOK_TITLE}
Current Page: {CURRENT_PAGE}/{TOTAL_PAGES}
Reading Progress: {PROGRESS}%

ROLEPLAY RULES:
- Stay in character at all times
- ... (rules for encouragement)
```

### Hệ thống quản lý tin nhắn

#### Cấu trúc lưu trữ tin nhắn
Tin nhắn chat được lưu trữ sử dụng Hive, với mỗi nhân vật có một box riêng:

```dart
Future<Box<ChatMessage>> _getBoxForCharacter(String characterName) async {
  try {
    _log.info('Getting box for character: $characterName');
    if (_boxes.containsKey(characterName)) {
      _log.info('Found existing box for $characterName');
      return _boxes[characterName]!;
    }

    final box = await Hive.openBox<ChatMessage>('chat_$characterName');
    _boxes[characterName] = box;
    _log.info('Box is open, message count: ${box.length}');
    return box;
  } catch (e) {
    _log.severe('Error opening box for character $characterName: $e');
    rethrow;
  }
}
```

Thiết kế này cho phép:
- Tách biệt cuộc trò chuyện theo từng nhân vật
- Tải nhanh và hiệu quả cuộc trò chuyện hiện tại
- Mở rộng dễ dàng cho nhiều nhân vật

#### Giới hạn lưu trữ
Để tránh tiêu thụ quá nhiều bộ nhớ, hệ thống giới hạn số lượng tin nhắn:

```dart
Future<void> _cleanupOldMessages(String characterName) async {
  try {
    final box = await _getBoxForCharacter(characterName);
    if (box.length > _maxMessagesPerCharacter) {
      _log.info('Cleaning up old messages for $characterName');
      final messagesToDelete = box.length - _maxMessagesPerCharacter;
      for (var i = 0; i < messagesToDelete; i++) {
        await box.deleteAt(0); // Delete oldest messages
      }
      _log.info('Deleted $messagesToDelete old messages');
    }
  } catch (e) {
    _log.severe('Error cleaning up old messages: $e');
  }
}
```

### Đồng bộ hóa tin nhắn

#### Cơ chế đồng bộ hóa queued
Tin nhắn được đồng bộ hóa với máy chủ qua cơ chế hàng đợi:

```dart
Future<void> _queueMessagesForSync() async {
  if (!_syncManager.isAuthenticated) {
    _log.info('Skipping sync - user not authenticated');
    return;
  }

  try {
    for (final characterName in _boxes.keys) {
      final box = _boxes[characterName];
      if (box == null) continue;

      // Get only unsynced messages
      final messages = box.values.where((msg) => !msg.isSynced).toList();
      if (messages.isEmpty) {
        _log.info('No unsynced messages for $characterName');
        continue;
      }

      _log.info('Found ${messages.length} unsynced messages for $characterName');

      // Create sync task for this batch of messages
      final task = SyncTask(
        id: _uuid.v4(),
        type: SyncTaskType.chatHistory,
        data: {
          'character_name': characterName,
          'messages': messages.map((msg) => // message mapping...)
        },
        timestamp: DateTime.now(),
        priority: SyncPriority.normal,
      );

      await _syncManager.addTask(task);
    }
  } catch (e) {
    _log.severe('Error queueing messages for sync: $e');
    rethrow;
  }
}
```

Cơ chế này đảm bảo:
- Tin nhắn luôn được lưu cục bộ trước, đảm bảo trải nghiệm nhất quán
- Đồng bộ hóa xảy ra trong nền, không ảnh hưởng đến UX
- Tin nhắn không đồng bộ thành công được giữ lại để thử lại sau

#### Xử lý xung đột khi đồng bộ
Khi đồng bộ từ máy chủ, hệ thống xử lý xung đột thông minh:

```dart
Future<void> updateFromServer(
    String characterName, List<Map<String, dynamic>> serverMessages) async {
  try {
    _log.info('Updating messages from server for $characterName');
    final box = await _getBoxForCharacter(characterName);

    // Get current local messages
    final localMessages = box.values.toList();
    _log.info('Found ${localMessages.length} local messages');

    // Create a map of existing messages by timestamp for quick lookup
    final existingMessageMap = {
      for (var msg in localMessages) msg.timestamp.toIso8601String(): msg
    };

    // Convert server messages to ChatMessage objects
    final serverChatMessages = serverMessages
        .map((data) {
          try {
            final timestamp = DateTime.parse(data['timestamp']);
            return ChatMessage(
              // message construction...
            );
          } catch (e) {
            _log.warning('Error converting server message: $e');
            _log.warning('Message data: $data');
            return null;
          }
        })
        .whereType<ChatMessage>()
        .toList();

    // Add or update messages from server
    for (var serverMsg in serverChatMessages) {
      final existingMsg =
          existingMessageMap[serverMsg.timestamp.toIso8601String()];
      if (existingMsg == null) {
        // Message doesn't exist locally, add it
        await box.add(serverMsg);
      } else if (!existingMsg.isSynced ||
          existingMsg.text != serverMsg.text ||
          existingMsg.isUser != serverMsg.isUser) {
        // Message exists but needs update
        final index = localMessages.indexOf(existingMsg);
        await box.putAt(index, serverMsg);
      }
    }
  } catch (e, stackTrace) {
    _log.severe('Error updating messages from server for $characterName',
        e, stackTrace);
    rethrow;
  }
}
```

### Hệ thống giao diện nổi

#### Widget chat nổi có thể di chuyển
`FloatingChatWidget` cho phép người dùng di chuyển chat tự do trên màn hình:

```dart
void _handleDragUpdate(DragUpdateDetails details) {
  final screenSize = MediaQuery.of(context).size;
  setState(() {
    _xPosition = (_xPosition + details.delta.dx)
        .clamp(0, screenSize.width - _chatHeadSize);
    _yPosition = _getValidYPosition(_yPosition + details.delta.dy, context);
  });
}
```

Khi kéo, widget thông minh:
- Tránh đi ra khỏi màn hình
- Điều chỉnh vị trí khi bàn phím xuất hiện
- Tự động "snap" vào cạnh gần nhất

#### Điều chỉnh kích thước và thích ứng với bàn phím
Cửa sổ chat có thể điều chỉnh kích thước và thông minh thích ứng với bàn phím:

```dart
void _handleResize(DragUpdateDetails details) {
  final screenSize = MediaQuery.of(context).size;
  final maxWidth = _getMaxChatWidth(context);
  final maxHeight = _getMaxChatHeight(context);
  final minWidth = ResponsiveConstants.getMinChatWidth(context);

  setState(() {
    // Handle horizontal resize
    final horizontalDelta = _xPosition < screenSize.width / 2
        ? details.delta.dx
        : -details.delta.dx;

    double newWidth =
        (_chatWidth + horizontalDelta).clamp(minWidth, maxWidth);
    if (newWidth != _chatWidth) {
      _chatWidth = newWidth;
    }

    // Vertical resize logic...
  });
}
```

### Hiệu ứng chuyển động cho UX mượt mà

#### Hiệu ứng hoạt hình cho tin nhắn
Mỗi tin nhắn có hiệu ứng xuất hiện mượt mà:

```dart
return SlideTransition(
  position: Tween<Offset>(
    begin: Offset(message.isUser ? 1.0 : -1.0, 0.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
  )),
  child: FadeTransition(
    opacity: CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ),
    child: _buildMessageBubble(message),
  ),
);
```

#### Blur effect và hiệu ứng glass morphism
Giao diện chat sử dụng hiệu ứng kính mờ hiện đại:

```dart
ClipRRect(
  borderRadius: BorderRadius.only(/* ... */),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    child: Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF352A3B).withOpacity(0.85)
            : Colors.white.withOpacity(0.85),
        // More styling...
      ),
      // Content...
    ),
  ),
)
```

### Tối ưu hóa hiệu suất

#### Caching tin nhắn và context
`GeminiService` sử dụng caching để giảm thiểu API calls:

```dart
// Cache for conversation contexts to reduce database reads
final Map<String, _CachedContext> _contextCache = {};

// Internal caching class
class _CachedContext {
  final String context;
  final DateTime timestamp;
  static const Duration _defaultExpiration = Duration(minutes: 5);

  _CachedContext(this.context) : timestamp = DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(timestamp) > _defaultExpiration;
}
```

#### Tối ưu hóa hình ảnh 
Ứng dụng sử dụng `CachedNetworkImage` với nhiều tùy chỉnh hiệu suất:

```dart
CachedNetworkImage(
  imageUrl: imagePath,
  fit: BoxFit.cover,
  placeholder: (context, url) => Container(/* ... */),
  errorWidget: (context, url, error) => Container(/* ... */),
  fadeInDuration: const Duration(milliseconds: 0),
  memCacheHeight: (radius * 3).toInt(),
  memCacheWidth: (radius * 3).toInt(),
  cacheKey: 'chat_msg_avatar_$imagePath',
  useOldImageOnUrlChange: true,
)
```

## Đánh giá tổng thể

### Điểm mạnh
1. **Trải nghiệm AI sâu sắc**: Sử dụng prompt động để tạo ra nhân vật AI có cá tính riêng biệt
2. **Thiết kế UI/UX xuất sắc**: Widget nổi thông minh, hiệu ứng chuyển động mượt mà
3. **Xử lý dữ liệu hiệu quả**: Caching nhiều lớp, đồng bộ hóa bất đồng bộ
4. **Responsive và thích ứng**: Hoạt động tốt trên cả điện thoại và máy tính bảng
5. **Tích hợp sâu với sách**: Nhận biết sách đang đọc, tiến trình và nội dung

### Hạn chế
1. **Phụ thuộc vào Gemini API**: Yêu cầu kết nối internet để tạo phản hồi AI mới
2. **Chiếm dụng màn hình**: Widget nổi có thể che khuất một phần nội dung sách
3. **Tiêu thụ tài nguyên**: Animation và backdrop filter có thể nặng trên thiết bị cũ

### Cải tiến tiềm năng
1. **Chế độ offline**: Thêm phản hồi AI đơn giản khi không có kết nối
2. **Đồng bộ nhiều thiết bị thời gian thực**: Cải thiện trải nghiệm đồng bộ trò chuyện
3. **Tích hợp voice chat**: Cho phép tương tác bằng giọng nói
4. **Tùy chỉnh nhân vật sâu hơn**: Cho phép người dùng tạo nhân vật AI tùy chỉnh
5. **Chia sẻ trích dẫn từ trò chuyện**: Cho phép chia sẻ đoạn trò chuyện thú vị lên mạng xã hội

Tính năng Companion Chat của Read Leaf là một ví dụ xuất sắc về cách AI có thể tăng cường trải nghiệm đọc sách, làm cho việc đọc trở nên tương tác và hấp dẫn hơn thông qua trải nghiệm đàm thoại được cá nhân hóa.

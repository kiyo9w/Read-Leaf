## 1. Góc nhìn người dùng (30%)

### Tổng quan
Tính năng Cài đặt trong Read Leaf cung cấp cho người dùng trải nghiệm đọc sách có thể tùy chỉnh, đồng thời đảm bảo tùy chọn và dữ liệu của họ được đồng bộ hóa trên nhiều thiết bị.

### Các cài đặt chính
Dựa trên phân tích mã nguồn, người dùng có thể cấu hình:

- **Tùy chọn giao diện**: Chuyển đổi giữa chế độ sáng và tối
- **Tùy chọn đọc sách**: 
  - Điều chỉnh cỡ chữ (nhỏ, trung bình, lớn)
  - Hiển thị/ẩn tiến trình đọc
- **Tính năng AI**:
  - Bật/tắt tính năng AI
  - Cấu hình tự động tóm tắt nội dung
  - Bật tính năng hiểu biết theo ngữ cảnh
  - Chọn nhân vật AI ưa thích để tương tác
- **Cài đặt đồng bộ hóa**:
  - Bật/tắt đồng bộ tự động
  - Quản lý đồng bộ hóa dữ liệu ngoại tuyến

### Hành trình người dùng
1. Người dùng điều hướng đến màn hình Cài đặt
2. Điều chỉnh tùy chọn theo phong cách đọc của họ
3. Thay đổi được tự động lưu cục bộ
4. Nếu đã đăng nhập và bật đồng bộ tự động, thay đổi sẽ được đồng bộ lên đám mây
5. Khi sử dụng thiết bị khác, tùy chọn của họ sẽ tự động được đồng bộ hóa

## 2. Thiết kế và công nghệ (20%)

### Kiến trúc
Tính năng Cài đặt tuân theo cách tiếp cận kiến trúc sạch (Clean Architecture) với sự phân tách rõ ràng:

- **Tầng Domain**: Chứa các mô hình dữ liệu và logic nghiệp vụ
  - Các model như `UserPreferences`, `UserAISettings`
- **Tầng Data**: Quản lý thao tác dữ liệu và dịch vụ bên ngoài
  - Các dịch vụ đồng bộ, xử lý ngoại tuyến và quản lý tùy chọn
- **Tầng Presentation**: Xử lý giao diện người dùng và tương tác
  - BLoCs để quản lý trạng thái của cài đặt và đồng bộ hóa

### Thành phần công nghệ
- **Quản lý trạng thái**: Mẫu Flutter BLoC
  - `SettingsBloc` - Quản lý trạng thái cài đặt cục bộ
  - `SyncBloc` - Quản lý trạng thái đồng bộ hóa
- **Lưu trữ cục bộ**: Hive và SharedPreferences
  - Hive cho dữ liệu có cấu trúc (tùy chọn, hàng đợi đồng bộ)
  - SharedPreferences cho các cờ đơn giản
- **Tích hợp backend**: Supabase
  - Cơ sở dữ liệu real-time để đồng bộ hóa tùy chọn
  - Xác thực danh tính người dùng
- **Kết nối**: Gói Connectivity Plus
  - Giám sát trạng thái mạng để phát hiện ngoại tuyến
- **Tuần tự hóa**: Freezed và JSON Serializable
  - Mô hình an toàn kiểu với tính bất biến

### Các mẫu thiết kế chính
- **Mẫu Repository**: Trừu tượng hóa nguồn dữ liệu
- **Mẫu Singleton**: Các dịch vụ được tiêm qua Get_It
- **Event Sourcing**: Cho các hoạt động đồng bộ
- **Mẫu Queue**: Để quản lý tác vụ đồng bộ

## 3. Phát hiện chính (50%)

### Hệ thống đồng bộ hóa

#### Cài đặt hàng đợi đồng bộ (Sync Queue)
Hệ thống đồng bộ sử dụng cách tiếp cận dựa trên hàng đợi để quản lý đồng bộ hóa dữ liệu:

```dart
class SyncQueue {
  final _queue = SplayTreeMap<String, SyncTask>();
  final _statusController = BehaviorSubject<SyncStatus>.seeded(SyncStatus.idle);
  final _maxRetries = 3;
  final _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(seconds: 120),
  ];
  // ...
}
```

`SyncQueue` sử dụng `SplayTreeMap` để lưu trữ tác vụ đồng bộ, điều này đảm bảo:
- Tra cứu nhanh theo ID tác vụ (O(log n))
- Các tác vụ có thể được sắp xếp hiệu quả theo ưu tiên
- Cập nhật hiệu quả các tác vụ hiện có

#### Ưu tiên tác vụ
Các tác vụ được phân loại theo mức ưu tiên:

```dart
enum SyncPriority {
  immediate,  // Cho cập nhật quan trọng cần đồng bộ ngay lập tức
  high,       // Cho cập nhật quan trọng nhưng không khẩn cấp
  normal,     // Cho cập nhật thông thường
  low,        // Cho cập nhật nền
  batch       // Cho cập nhật nhóm
}
```

Điều này cho phép hệ thống:
1. Xử lý ngay lập tức các tác vụ quan trọng (ví dụ: thay đổi tùy chọn người dùng)
2. Nhóm các tác vụ ít quan trọng hơn để sử dụng mạng hiệu quả
3. Hoãn các tác vụ không quan trọng khi ngoại tuyến

#### Hỗ trợ ngoại tuyến
`OfflineManager` xử lý các hoạt động khi thiết bị đang ngoại tuyến:

```dart
class OfflineManager {
  final SyncQueue _offlineQueue;
  final _connectivityController = BehaviorSubject<bool>();
  
  // ...
  
  Future<void> queueOfflineChanges(SyncTask task) async {
    try {
      await _offlineQueue.addTask(task.copyWith(
        priority: SyncPriority.low,
        timestamp: DateTime.now(),
      ));
      // ...
    } catch (e) {
      // Xử lý lỗi
    }
  }
}
```

Các khả năng ngoại tuyến chính:
- Tự động phát hiện thay đổi kết nối mạng
- Xếp hàng cục bộ các thay đổi được thực hiện khi ngoại tuyến
- Đồng bộ tự động khi kết nối được khôi phục
- Chiến lược giải quyết xung đột khi trở lại trực tuyến

#### Cơ chế thử lại
Hệ thống triển khai chiến lược trì hoãn theo cấp số nhân cho các hoạt động đồng bộ thất bại:

```dart
Future<void> _handleTaskError(SyncTask task, dynamic error) async {
  if (task.retryCount >= _maxRetries) {
    _log.warning('Task ${task.id} has failed too many times, removing from queue');
    _queue.remove(task.id);
    return;
  }

  // Lên lịch thử lại với độ trễ tăng dần
  final delay = _retryDelays[task.retryCount];
  // ...
  
  _queue[task.id] = task.copyWith(
    retryCount: task.retryCount + 1,
    error: error.toString(),
  );
}
```

Điều này đảm bảo:
- Các vấn đề mạng tạm thời không gây ra lỗi đồng bộ vĩnh viễn
- Giảm tải cho máy chủ trong thời gian gián đoạn
- Tiết kiệm pin và băng thông trên thiết bị di động

### Quản lý tùy chọn người dùng

#### Thiết kế mô hình dữ liệu
Các mô hình tùy chọn người dùng sử dụng Freezed để bất biến và an toàn kiểu:

```dart
@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(false) bool darkMode,
    @Default('medium') String fontSize,
    @Default(true) bool enableAIFeatures,
    @Default(true) bool showReadingProgress,
    @Default(false) bool enableAutoSync,
    @Default({}) Map<String, dynamic> customSettings,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
```

Lợi ích:
- Truy cập tùy chọn an toàn kiểu
- Giá trị mặc định cho cài đặt mới
- Có thể mở rộng thông qua map `customSettings` cho các bổ sung trong tương lai
- Tuần tự hóa JSON để dễ dàng đồng bộ và lưu trữ

#### Chiến lược lưu trữ cục bộ
Các tùy chọn được lưu trữ bằng Hive:

```dart
class UserPreferencesService {
  static const String _boxName = 'user_preferences';
  late Box<Map> _box;
  
  // ...
  
  Future<void> savePreferences(UserPreferences preferences) async {
    await _box.put('preferences', preferences.toJson());
    // Xếp hàng để đồng bộ...
  }
}
```

Điều này cung cấp:
- Lưu trữ dữ liệu có cấu trúc
- Truy cập nhanh thông qua bộ nhớ đệm
- Khả năng phục hồi với cơ chế khôi phục lỗi (tạo lại box nếu bị hỏng)

### Tích hợp xác thực

Hệ thống cài đặt tích hợp với hệ thống xác thực:

```dart
// Trong SyncManager
bool get isAuthenticated => _supabase.auth.currentUser != null;

_supabase.auth.onAuthStateChange.listen((data) {
  if (data.event == AuthChangeEvent.signedIn) {
    _log.info('User signed in, processing pending tasks');
    processPendingTasks();
  }
});
```

Các điểm tích hợp chính:
- Hoạt động đồng bộ kiểm tra trạng thái xác thực
- Thay đổi xác thực kích hoạt hành động đồng bộ thích hợp
- Dữ liệu cụ thể của người dùng được liên kết với tài khoản đã xác thực

### Cân nhắc về bảo mật và quyền riêng tư

1. **Mã hóa dữ liệu**: Tùy chọn người dùng được lưu trữ an toàn
2. **Yêu cầu xác thực**: Các hoạt động nhạy cảm yêu cầu xác thực
3. **Xử lý lỗi**: Chi tiết nhạy cảm không được hiển thị trong thông báo lỗi
4. **Truyền dữ liệu tối thiểu**: Chỉ dữ liệu đã thay đổi được đồng bộ hóa

### Tối ưu hóa hiệu suất

1. **Cập nhật theo lô**: Các tác vụ tương tự được nhóm lại để giảm network calls
2. **Đồng bộ định kỳ**: Đồng bộ thường xuyên nhưng không liên tục để cân bằng giữa độ mới và sử dụng tài nguyên
3. **Xử lý dựa trên ưu tiên**: Cập nhật quan trọng được xử lý trước
4. **Hoạt động nhận biết kết nối**: Điều chỉnh hành vi dựa trên chất lượng kết nối

## Đánh giá tổng thể

### Điểm mạnh
- Đồng bộ hóa mạnh mẽ với hỗ trợ ngoại tuyến
- Kiến trúc sạch với phân tách rõ ràng
- Mô hình tùy chọn linh hoạt có thể mở rộng
- Nhiều cấp độ xử lý lỗi và khôi phục

### Các lĩnh vực cần cải thiện
- Chiến lược giải quyết xung đột còn hạn chế
- Không có khả năng đồng bộ một phần cho bộ dữ liệu lớn
- Phụ thuộc vào Supabase cho hoạt động backend

### Cải tiến tương lai
Dựa trên mã nguồn, các cải tiến tiềm năng có thể bao gồm:
- Giải quyết xung đột với các tùy chọn can thiệp của người dùng
- Đồng bộ vi sai để giảm truyền dữ liệu
- Mã hóa đầu cuối cho các tùy chọn nhạy cảm
- Kiểm soát đồng bộ chi tiết hơn cho các danh mục tùy chọn cụ thể
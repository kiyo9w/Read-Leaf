## 1. Góc nhìn người dùng

### Tổng quan
Tính năng Library trong ứng dụng Read Leaf cung cấp một không gian để người dùng quản lý, tổ chức và truy cập vào bộ sưu tập sách điện tử của họ. Nó hỗ trợ nhiều định dạng file khác nhau, cho phép phân loại và cung cấp thông tin chi tiết về tiến trình đọc.

### Trải nghiệm người dùng
Khi sử dụng tính năng Library, người dùng có thể:

- **Xem sách theo danh mục**: Các sách được phân loại thành "Sách đã đánh dấu sao", "Sách đã đọc" và "Lưu trữ cục bộ".
- **Tìm kiếm và duyệt sách**: Người dùng có thể dễ dàng duyệt qua bộ sưu tập sách của họ.
- **Theo dõi tiến trình đọc**: Thanh tiến trình trực quan hiển thị phần trăm sách đã đọc.
- **Quản lý sách**: Người dùng có thể thêm sách mới, xóa sách không cần thiết, và đánh dấu sách yêu thích.
- **Lưu đánh dấu và ghi chú**: Lưu trữ đánh dấu trang, ghi chú và đoạn văn được highlight.
- **Tích hợp AI**: Lưu trữ các cuộc trò chuyện AI liên quan đến nội dung sách.

### Các tính năng chính
1. **Quản lý bộ sưu tập**:
   - Thêm sách từ bộ nhớ thiết bị
   - Quét bộ nhớ để tìm sách mới
   - Xóa sách khỏi thư viện (với khả năng hoàn tác)

2. **Tổ chức sách**:
   - Đánh dấu sao sách yêu thích
   - Đánh dấu sách đã đọc xong
   - Xem sách đã đọc gần đây

3. **Hiển thị thông tin**:
   - Hiển thị bìa sách
   - Hiển thị thông tin cơ bản (tên sách, tác giả)
   - Hiển thị kích thước file và định dạng
   - Hiển thị tiến trình đọc

### Hành trình người dùng
1. Người dùng mở ứng dụng, giao diện hiện ở màn hình "Home Screen" hoặc điều hướng đến màn hình "My Library"
2. Ở "My Library", họ nhìn thấy các danh mục khác nhau: Sách đã đánh dấu sao, Sách đã đọc, và Lưu trữ cục bộ / Ở "Home Screen" họ thấy Sách vừa đọc, Các Sách đã được thêm vào thư viện, Sách của ngày
3. Người dùng có thể mở rộng/thu gọn từng danh mục
4. Khi chọn một cuốn sách, họ thấy bìa sách, thông tin cơ bản và tiến trình đọc
5. Họ có thể mở sách để đọc, đánh dấu sao, đánh dấu đã hoàn thành, xoá sách khỏi thư viện, hoặc thêm sách
6. Khi quét bộ nhớ, ứng dụng tự động tìm trong thư mục của thiết bị và thêm sách mới vào thư viện

## 2. Thiết kế và Tech Stack

### Kiến trúc
Tính năng Library được xây dựng theo mô hình kiến trúc Clean Architecture với ba lớp rõ ràng:

1. **Domain Layer**:
   - Các models: `FileInfo`, `BookData`, `BookMetadata`, `UserLibrary`
   - Định nghĩa các entities và use cases của tính năng Library

2. **Data Layer**:
   - Repositories: `BookMetadataRepository`
   - Services: `StorageScannerService`, `ThumbnailService`, `StorageService`
   - Xử lý lưu trữ, truy xuất và quản lý dữ liệu

3. **Presentation Layer**:
   - Blocs: `FileBloc`
   - Screens: `MyLibraryScreen`
   - Widgets: `FileCard`, `MinimalFileCardWidget`, `BookInfoWidget`
   - Xử lý UI và tương tác người dùng

### Công nghệ sử dụng
- **State Management**: BLoC pattern
- **Local Storage**:
  - Hive: Lưu trữ metadata của sách
  - SharedPreferences: Cài đặt người dùng
  - File System: Lưu trữ sách và thumbnails
- **UI Components**: Flutter widgets tùy chỉnh
- **Caching**: In-memory cache và file-system cache cho thumbnails
- **Backend Integration**: Supabase cho lưu trữ avatar và đồng bộ hóa

### Thư viện chính
- `flutter_bloc`: Quản lý state
- `hive_flutter`: Lưu trữ local
- `path_provider`: Truy cập bộ nhớ thiết bị
- `equatable`: So sánh objects
- `rxdart`: Reactive programming
- `percent_indicator`: Hiển thị tiến trình
- `epubx`: Xử lý tệp EPUB
- `pdfrx`: Xử lý tệp PDF
- `screenshot`: Tạo thumbnails
- `flutter_cache_manager`: Quản lý bộ nhớ cache

## 3. KEY FINDINGS | Phát hiện chính

### Hệ thống quản lý tệp

#### Mô hình dữ liệu FileInfo
`FileInfo` là class cốt lõi đại diện cho một tệp trong thư viện:

```dart
class FileInfo extends Equatable {
  final String filePath;
  final int fileSize;
  final bool isSelected;
  final bool isInternetBook;
  final String? author;
  final String? thumbnailUrl;
  final bool isStarred;
  final bool wasRead;
  final bool hasBeenCompleted;
  
  // Constructor và phương thức copyWith...
}
```

Thiết kế này cho phép:
- Theo dõi các thuộc tính cơ bản của tệp (đường dẫn, kích thước)
- Lưu trữ trạng thái UI (đã chọn)
- Lưu trữ metadata (tác giả, URL thumbnail)
- Lưu trữ trạng thái đọc (đã đánh dấu sao, đã đọc gần đây, đã hoàn thành)

#### Lưu trữ metadata chi tiết
`BookMetadata` cung cấp cấu trúc phong phú hơn cho dữ liệu sách:

```dart
@HiveType(typeId: 0)
class BookMetadata extends Equatable {
  @HiveField(0)
  final String filePath;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? author;
  @HiveField(3)
  final int lastOpenedPage;
  @HiveField(4)
  final int totalPages;
  @HiveField(5)
  final List<TextHighlight> highlights;
  @HiveField(6)
  final List<AiConversation> aiConversations;
  @HiveField(7)
  final bool isStarred;
  @HiveField(8)
  final DateTime lastReadTime;
  @HiveField(9)
  final double readingProgress;
  @HiveField(10)
  final String fileType;
  
  // Constructor và phương thức copyWith...
}
```

Hive được sử dụng cho lưu trữ hiệu quả với:
- Type adapters được tạo tự động
- Lưu trữ hiệu quả các danh sách con (highlights, conversations)
- Tối ưu hóa cho truy xuất nhanh

Điều đặc biệt thú vị là việc tích hợp AI với trường `aiConversations`, cho phép lưu trữ các tương tác AI liên quan đến nội dung sách.

### Quản lý bộ nhớ đệm và thumbnails

Một phần quan trọng của tính năng Library là hệ thống tạo và quản lý thumbnails cho sách điện tử:

```dart
class ThumbnailService {
  final _memoryCache = <String, ImageProvider>{};
  static const int maxMemoryCacheSize = 100;
  
  // Phương thức caching và generation...
}
```

Hệ thống sử dụng chiến lược cache nhiều lớp:
1. **In-memory cache**: Lưu trữ tối đa 100 thumbnails đã tải gần đây
2. **Disk cache**: Thumbnails được lưu trong bộ nhớ tạm thời của thiết bị
3. **Default cache**: Thumbnails được pre-loaded cho các sách mặc định

Quá trình tạo thumbnails được tối ưu hóa:
- **PDF**: Sử dụng `PdfPageView` để render trang đầu tiên
- **EPUB**: Trích xuất hình ảnh bìa hoặc tạo thumbnail với tiêu đề sách
- **Fallback**: Sử dụng thumbnail mặc định khi không thể tạo

```dart
Future<ImageProvider> getEpubThumbnail(String filePath) async {
  // Kiểm tra cache
  if (_memoryCache.containsKey(filePath)) {
    return _memoryCache[filePath]!;
  }
  
  // Tạo thumbnail mới
  try {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final book = await EpubReader.readBook(bytes);

    // Tìm hình ảnh bìa trong sách EPUB
    // Nếu không tìm thấy, tạo thumbnail mặc định
    // ...
  } catch (e) {
    // Xử lý lỗi...
  }
}
```

### Quản lý trang thái ứng dụng với FileBloc

`FileBloc` là thành phần trung tâm quản lý trạng thái cho tính năng Library, sử dụng mô hình BLoC:

```dart
class FileBloc extends Bloc<FileEvent, FileState> {
  // Xử lý các events: init, load, select, view, remove, toggle...
}
```

#### Một số tính năng chính của FileBloc:
1. **Quản lý trạng thái đa dạng**:
   - `FileInitial`: Khởi tạo
   - `FileLoaded`: Đã tải sách
   - `FileViewing`: Đang xem sách
   - `FileScanning`: Đang quét bộ nhớ
   - `FileError`: Xảy ra lỗi

2. **Xử lý undo hiệu quả**:
   ```dart
   void _onRemoveFile(RemoveFile event, Emitter<FileState> emit) async {
     _lastFileState = List.from(currentFiles);
     _lastRemovedFile = fileToRemove;
     // Xóa file và cập nhật trạng thái...
   }
   
   Future<void> _onUndoRemoveFile(UndoRemoveFile event, Emitter<FileState> emit) async {
     if (_lastFileState.isNotEmpty && _lastRemovedFile != null) {
       emit(FileLoaded(_lastFileState));
       await fileRepository.saveFiles(_lastFileState);
       _lastFileState = [];
       _lastRemovedFile = null;
     }
   }
   ```

3. **Tích hợp RAG (Retrieval Augmented Generation)**:
   ```dart
   void _onLoadFile(LoadFile event, Emitter<FileState> emit) async {
     // ...
     if (fileType == "pdf") {
       try {
         await _ragService.uploadPdf(file);
       } catch (e) {
         print('Error uploading PDF to backend: $e');
       }
     }
     // ...
   }
   ```
   Điều này cho thấy tích hợp với dịch vụ RAG để phân tích và xử lý nội dung PDF.

### Tối ưu hiển thị thư viện

Màn hình Library đã được tối ưu cho hiệu suất và trải nghiệm người dùng:

#### 1. Nhóm sách theo danh mục:
```dart
final starredBooks = state.files.where((file) => file.isStarred).toList();
final completedBooks = state.files.where((file) => file.hasBeenCompleted).toList();
final localFiles = state.files.toList();
```

#### 2. Điều khiển hiển thị thông minh:
```dart
_buildCategoryHeader(
  title: "Starred Books",
  count: starredBooks.length,
  isExpanded: _favouriteExpanded,
  onTap: () {
    setState(() {
      _favouriteExpanded = !_favouriteExpanded;
    });
  },
)
```

#### 3. Tối ưu hiệu suất cuộn:
```dart
void _scrollListener() {
  if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
    if (!_isScrollingDown) {
      _isScrollingDown = true;
      NavScreen.globalKey.currentState?.hideNavBar(true);
    }
  }
  // ...
}
```

#### 4. Lazy loading thumbnails:
```dart
FutureBuilder<ImageProvider>(
  future: _thumbnailFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    // ...
  },
)
```

### Quét bộ nhớ thiết bị

`StorageScannerService` cung cấp khả năng quét bộ nhớ thiết bị để tìm sách mới:

```dart
Future<List<FileInfo>> scanStorage() async {
  List<FileInfo> discoveredFiles = [];

  try {
    if (!await _checkAndRequestPermissions()) {
      throw Exception('Storage permission denied');
    }

    // Get all storage paths
    List<String> storagePaths = await _getStoragePaths();

    for (String storagePath in storagePaths) {
      await _scanDirectory(Directory(storagePath), discoveredFiles);
    }
  } catch (e) {
    print('Error scanning storage: $e');
  }

  return discoveredFiles;
}
```

Tính năng này:
- Xử lý quyền lưu trữ cho cả Android và iOS
- Quét cả thư mục tài liệu và thư mục tải xuống
- Lọc files theo định dạng được hỗ trợ
- Bỏ qua các thư mục hệ thống không liên quan
- Xử lý lỗi mà không làm crash ứng dụng

### Bảo mật và quản lý bộ nhớ

`BookMetadataRepository` sử dụng hashing để lưu trữ an toàn:

```dart
String _getKey(String filePath) {
  final bytes = utf8.encode(filePath);
  final hash = sha256.convert(bytes);
  return hash.toString().substring(0, 32); // Use first 32 chars of hash
}
```

Lợi ích:
- Tránh các ký tự không hợp lệ trong tên file
- Ngăn chặn các đường dẫn quá dài gây lỗi
- Tạo ID ngắn gọn, cố định cho mỗi sách
- Tránh lộ thông tin đường dẫn đầy đủ

Ngoài ra, hệ thống cũng xử lý các box Hive bị hỏng:

```dart
try {
  _box = await Hive.openBox<BookMetadata>(_boxName);
} catch (e) {
  await Hive.deleteBoxFromDisk(_boxName);
  _box = await Hive.openBox<BookMetadata>(_boxName);
}
```

### Tích hợp với Supabase

Library hỗ trợ lưu trữ dữ liệu người dùng thông qua Supabase:

```dart
Future<String?> uploadProfilePicture(File file, String userId) async {
  try {
    // Validate file size (max 5MB)
    final fileSize = await file.length();
    if (fileSize > 5 * 1024 * 1024) {
      throw Exception('File size must be less than 5MB');
    }

    final fileExt = path.extension(file.path);
    final filePath = '$userId/avatar$fileExt';

    // Delete existing avatar if any
    // ...
    
    // Upload the new avatar
    await _supabase.storage
        .from(_bucketName)
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

    // Get the public URL with cache busting
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final imageUrl =
        '${_supabase.storage.from(_bucketName).getPublicUrl(filePath)}?v=$timestamp';

    return imageUrl;
  } catch (e) {
    // ...
  }
}
```

## Đánh giá tổng thể

### Điểm mạnh
1. **Thiết kế cấu trúc hóa**: Sử dụng kiến trúc rõ ràng với các lớp domain, data và presentation
2. **Hiệu suất tối ưu**: Sử dụng cache nhiều lớp, lazy loading và xử lý thumbnails hiệu quả
3. **Trải nghiệm người dùng mượt mà**: Hiển thị tiến trình đọc, tính năng hoàn tác, và phân loại sách
4. **Khả năng mở rộng**: Dễ dàng thêm định dạng sách mới và tính năng bổ sung
5. **Tích hợp AI**: Lưu trữ các tương tác AI liên quan đến nội dung sách

### Hạn chế
1. **Quản lý bộ nhớ**: Chưa có cơ chế tự động dọn dẹp cache cũ
2. **Hiệu suất trên thiết bị cũ**: Tạo thumbnail cho PDF có thể nặng trên thiết bị cấp thấp
3. **Xử lý lỗi**: Một số trường hợp lỗi chỉ được ghi log mà không thông báo cho người dùng

### Cải tiến tiềm năng
1. **Đồng bộ hóa đám mây**: Mở rộng đồng bộ với cloud storage
2. **Tìm kiếm nội dung**: Thêm khả năng tìm kiếm trong nội dung sách
3. **Gợi ý sách thông minh**: Sử dụng AI để gợi ý sách dựa trên lịch sử đọc
4. **Quản lý bộ sưu tập nâng cao**: Cho phép người dùng tạo bộ sưu tập và thẻ tùy chỉnh
5. **Chia sẻ trích dẫn**: Cho phép chia sẻ highlights và ghi chú lên mạng xã hội

Tài liệu này cung cấp một tổng quan chi tiết về tính năng Library trong ứng dụng Read Leaf, từ trải nghiệm người dùng đến các chi tiết triển khai kỹ thuật.

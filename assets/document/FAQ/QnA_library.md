## 1. Tại sao tồn tại 2 tầng data là `FileInfo` và `BookMetadata`, dù 2 class này có trường data rất tương đồng nhau, `BookMetadata` là bản mở rộng hơn?

### Trả lời:

Hai class này phục vụ các mục đích khác nhau trong kiến trúc ứng dụng:

- **`FileInfo`**:  
  - Là một model đơn giản, nhẹ, chủ yếu phục vụ cho việc hiển thị danh sách sách trong giao diện người dùng (UI).  
  - Chứa các thông tin cơ bản như đường dẫn file, kích thước, trạng thái UI (đã chọn, đánh dấu sao, đã đọc), và thông tin hiển thị nhanh (tác giả, thumbnail URL).  
  - Được sử dụng trực tiếp bởi UI components như `FileCard`, `MinimalFileCard`.

- **`BookMetadata`**:  
  - Là một model chi tiết hơn, lưu trữ các thông tin sâu hơn về sách, phục vụ cho việc quản lý dữ liệu lâu dài và các tính năng nâng cao.  
  - Chứa các thông tin như highlights, ghi chú, các cuộc trò chuyện AI, tiến trình đọc chi tiết (trang cuối cùng đã mở, tổng số trang, thời gian đọc gần nhất).  
  - Được lưu trữ trong Hive database, phục vụ cho việc truy xuất nhanh và quản lý dữ liệu lâu dài.

**Lý do tồn tại cả hai**:  
- Tách biệt rõ ràng giữa tầng UI (nhẹ, nhanh, chỉ cần thông tin cơ bản) và tầng dữ liệu (chi tiết, đầy đủ, phục vụ các tính năng nâng cao).  
- Tối ưu hiệu suất: UI chỉ cần tải các thông tin tối thiểu, trong khi các thông tin chi tiết chỉ được tải khi cần thiết.

---

## 2. Tại sao phải cache ảnh bìa thumbnails của sách? Quy trình này diễn ra thế nào về mặt technical?

### Trả lời:

**Lý do cần cache thumbnails**:  
- Tăng tốc độ tải giao diện: Việc tạo thumbnail từ file PDF/EPUB mỗi lần hiển thị sẽ rất tốn thời gian và tài nguyên.  
- Giảm tải CPU và bộ nhớ: Cache giúp tránh việc render lại thumbnail nhiều lần, tiết kiệm pin và tài nguyên thiết bị.

**Quy trình cache thumbnails** (theo mã nguồn `ThumbnailService`):

1. **Kiểm tra cache trong bộ nhớ (memory cache)**:  
   - Nếu thumbnail đã tồn tại trong `_memoryCache`, trả về ngay lập tức.

2. **Kiểm tra cache trên ổ đĩa (disk cache)**:  
   - Nếu thumbnail đã được lưu trên ổ đĩa (thư mục tạm thời), tải từ ổ đĩa và lưu vào memory cache.

3. **Tạo thumbnail mới nếu chưa có cache**:  
   - Với EPUB:  
     - Đọc file EPUB, tìm ảnh bìa. Nếu không có, tạo thumbnail mặc định với tiêu đề sách.  
   - Với PDF:  
     - Render trang đầu tiên của PDF thành ảnh thumbnail. Nếu thất bại, tạo thumbnail mặc định.

4. **Lưu thumbnail mới vào cache**:  
   - Thumbnail mới được lưu vào cả memory cache và disk cache để sử dụng cho lần sau.

---

## 3. Những dữ liệu người dùng được lưu lên Supabase là gì? Tại sao lại có việc lưu lên dù không đẩy các quyển sách lên?

### Trả lời:

**Các dữ liệu được lưu lên Supabase** (theo mã nguồn `SupabaseService` và `SyncManager`):

- **Thông tin người dùng**:  
  - Profile (username, email, avatar URL).
  - Preferences (cài đặt giao diện, cỡ chữ, chế độ tối/sáng, AI settings).
  - Reading progress (trang cuối cùng đã đọc, tiến trình đọc).
  - Character preferences (cài đặt nhân vật AI).
  - Chat history (lịch sử trò chuyện với AI).

**Tại sao lưu lên Supabase dù không lưu sách?**  
- Đồng bộ hóa trải nghiệm người dùng giữa các thiết bị: Người dùng có thể tiếp tục đọc sách từ đúng vị trí đã dừng lại trên thiết bị khác.  
- Lưu trữ các cài đặt và lịch sử tương tác AI để cung cấp trải nghiệm cá nhân hóa.  
- Không lưu sách lên cloud để tránh các vấn đề bản quyền và dung lượng lưu trữ lớn.

---

## 4. Các hàm của `BookMetadataRepository` là gì? Nêu lên các chức năng của nó?

### Trả lời:

`BookMetadataRepository` quản lý việc lưu trữ và truy xuất metadata chi tiết của sách, sử dụng Hive database. Các hàm chính bao gồm:

- **`init()`**: Khởi tạo Hive database, đăng ký các adapters cần thiết.
- **`saveMetadata(BookMetadata metadata)`**: Lưu metadata của một cuốn sách vào Hive.
- **`getMetadata(String filePath)`**: Lấy metadata của một cuốn sách dựa trên đường dẫn file.
- **`updateLastOpenedPage(String filePath, int pageNumber)`**: Cập nhật trang cuối cùng đã mở và tiến trình đọc.
- **`addHighlight(String filePath, TextHighlight highlight)`**: Thêm một đoạn highlight vào metadata sách.
- **`addAiConversation(String filePath, AiConversation conversation)`**: Thêm một cuộc trò chuyện AI vào metadata sách.
- **`toggleStarred(String filePath)`**: Đánh dấu hoặc bỏ đánh dấu sao cho sách.
- **`getAllMetadata()`**: Lấy toàn bộ metadata của tất cả sách.
- **`deleteMetadata(String filePath)`**: Xóa metadata của một cuốn sách.
- **`clear()`**: Xóa toàn bộ metadata sách trong Hive.
- **`close()`**: Đóng Hive box khi không sử dụng nữa.

---

## 5 (Rất quan trọng). Giải thích cách Undo hoạt động một cách kỹ càng (quá trình undo delete sau khi người dùng vừa xoá một quyển sách khỏi thư viện).

### Trả lời:

Quá trình Undo delete được quản lý bởi `FileBloc` như sau:

**Bước 1: Khi người dùng xóa sách (`RemoveFile` event)**  
- Trước khi xóa, trạng thái hiện tại của thư viện (`_lastFileState`) và cuốn sách vừa xóa (`_lastRemovedFile`) được lưu lại:
```dart
Future<void> _onRemoveFile(RemoveFile event, Emitter<FileState> emit) async {
  if (state is FileLoaded) {
    final currentFiles = (state as FileLoaded).files;
    final fileToRemove = currentFiles.firstWhere(
      (file) => file.filePath == event.filePath,
      orElse: () => currentFiles.first,
    );

    _lastFileState = List.from(currentFiles); // Lưu trạng thái trước khi xóa
    _lastRemovedFile = fileToRemove; // Lưu file vừa xóa

    final updatedFiles = currentFiles
        .where((file) => file.filePath != event.filePath)
        .toList();

    if (updatedFiles.isEmpty) {
      emit(FileInitial());
      await fileRepository.saveFiles([]);
    } else {
      emit(FileLoaded(updatedFiles, lastRemovedFile: _lastRemovedFile));
      await fileRepository.saveFiles(updatedFiles);
    }
  }
}
```

**Bước 2: Hiển thị Snackbar Undo**  
- Sau khi xóa, UI hiển thị một Snackbar với nút "Undo":
```dart
Utils.showUndoSnackBar(
  context,
  'File deleted',
  () {
    context.read<FileBloc>().add(const UndoRemoveFile());
  },
);
```

**Bước 3: Khi người dùng nhấn Undo (`UndoRemoveFile` event)**  
- Bloc sẽ khôi phục trạng thái thư viện về trạng thái trước khi xóa:
```dart
Future<void> _onUndoRemoveFile(UndoRemoveFile event, Emitter<FileState> emit) async {
  if (_lastFileState.isNotEmpty && _lastRemovedFile != null) {
    emit(FileLoaded(_lastFileState)); // Khôi phục trạng thái cũ
    await fileRepository.saveFiles(_lastFileState); // Lưu lại trạng thái cũ vào repository

    // Xóa trạng thái lưu tạm thời sau khi undo
    _lastFileState = [];
    _lastRemovedFile = null;
  }
}
```

**Tổng kết quá trình Undo**:  
- Khi xóa sách, trạng thái trước khi xóa được lưu lại.  
- Snackbar hiển thị cho phép người dùng Undo.  
- Khi Undo, trạng thái cũ được khôi phục và lưu lại vào repository.  
- Sau khi Undo, trạng thái lưu tạm thời được xóa để tránh nhầm lẫn.
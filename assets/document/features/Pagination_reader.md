# THUẬT TOÁN PHÂN TRANG EPUB TRONG EPUB_SERVICE

## 1. Cấu trúc và vai trò của EpubService

`EpubService` là một singleton service đảm nhiệm việc xử lý tệp EPUB, từ việc tải và phân tích sách, đến việc phân trang nội dung cho phù hợp với kích thước màn hình và font chữ.

```dart
class EpubService {
  static final EpubService _instance = EpubService._internal();
  factory EpubService() => _instance;
  EpubService._internal();
  
  // Cache cho sách đã xử lý
  final Map<String, EpubProcessingResult> _processedBooks = {};
  
  // Cache bổ sung cho hiệu suất phân tích HTML
  final Map<String, dom.Document> _parsedHtmlCache = {};
  
  // Theo dõi hiệu suất
  final Stopwatch _performanceStopwatch = Stopwatch();
  
  // Các phương thức chính
  Future<EpubProcessingResult> loadEpub(String filePath);
  Future<List<EpubPage>> calculatePages({
    required EpubProcessingResult processingResult,
    required int chapterIndex,
    required double viewportWidth,
    required double viewportHeight,
    required double fontSize,
  });
}
```

## 2. Thuật toán phân trang dựa trên TextPainter

Khác với cách tiếp cận DOM phức tạp, `EpubService` sử dụng `TextPainter` và `LineMetrics` của Flutter để thực hiện phân trang hiệu quả:

### 2.1. Quy trình xử lý tổng thể

```dart
Future<List<EpubPage>> calculatePages({
  required EpubProcessingResult processingResult,
  required int chapterIndex,
  required double viewportWidth,
  required double viewportHeight,
  required double fontSize,
}) async {
  // Bước 1: Kiểm tra cache
  final cacheKey = '${chapterIndex}_${viewportWidth}_${viewportHeight}_$fontSize';
  if (processingResult.pages.containsKey(cacheKey)) {
    return processingResult.pages[cacheKey]!;
  }
  
  // Bước 2: Lấy nội dung chương
  final chapter = processingResult.chapters[chapterIndex];
  String content = await _getChapterContent(processingResult, chapterIndex);
  
  // Bước 3: Khởi tạo page calculator với kích thước viewport và font
  final calculator = EpubPageCalculator(
    viewportWidth: viewportWidth,
    viewportHeight: viewportHeight,
    fontSize: fontSize,
  );
  
  // Bước 4: Tính toán phân trang
  final pages = await calculator.calculatePages(
    content,
    chapterIndex,
    chapter.Title ?? 'Chapter ${chapterIndex + 1}',
  );
  
  // Bước 5: Lưu cache kết quả
  processingResult.pages[cacheKey] = pages;
  
  return pages;
}
```

### 2.2. Phân trang chi tiết trong EpubPageCalculator

Quá trình phân trang thực tế diễn ra trong lớp `EpubPageCalculator`:

```dart
class EpubPageCalculator {
  // Các hằng số cấu hình
  static const double DEFAULT_FONT_SIZE = 23.0;
  static const double LINE_HEIGHT_MULTIPLIER = 1.5;
  static const double PAGE_PADDING = 20.0;
  static const double PAGE_TOP_PADDING = 35.0;
  static const double PAGE_HEIGHT_FRACTION = 0.87;
  
  // Các thuộc tính
  final double _viewportWidth;
  final double _viewportHeight;
  final double _fontSize;
  final double _effectiveViewportHeight;
  
  // Constructor
  EpubPageCalculator({
    required double viewportWidth,
    required double viewportHeight,
    double fontSize = DEFAULT_FONT_SIZE,
  }) : _viewportWidth = viewportWidth - (PAGE_PADDING * 2),
       _viewportHeight = viewportHeight * PAGE_HEIGHT_FRACTION,
       _fontSize = fontSize,
       _effectiveViewportHeight = (viewportHeight * PAGE_HEIGHT_FRACTION) -
           (PAGE_PADDING + PAGE_TOP_PADDING);
  
  // Phương thức chính
  Future<List<EpubPage>> calculatePages(
    String htmlContent,
    int chapterIndex,
    String chapterTitle,
  ) async { ... }
}
```

## 3. Thuật toán phân trang tham lam (Greedy Algorithm)

Thuật toán tham lam được triển khai qua việc phân tích các dòng văn bản (line metrics) để xác định điểm ngắt trang tối ưu:

```dart
Future<List<EpubPage>> calculatePages(
  String htmlContent,
  int chapterIndex,
  String chapterTitle,
) async {
  // Bước 1: Chuyển HTML thành văn bản thuần
  final plainText = _stripHtmlTags(htmlContent);
  
  // Bước 2: Thêm tiêu đề chương vào đầu
  final textWithTitle = '$chapterTitle\n\n$plainText';
  
  // Bước 3: Tạo TextPainter để đo đạc chính xác văn bản
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: textWithTitle,
      style: TextStyle(
        fontSize: _fontSize,
        height: LINE_HEIGHT_MULTIPLIER,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  
  // Bước 4: Layout văn bản để tính toán metrics
  textPainter.layout(maxWidth: _viewportWidth);
  
  // Bước 5: Lấy thông tin về từng dòng văn bản
  final List<ui.LineMetrics> lines = textPainter.computeLineMetrics();
  
  // Bước 6: Áp dụng thuật toán phân trang
  return _createPagesFromLines(
    textWithTitle, 
    lines, 
    textPainter, 
    chapterIndex, 
    chapterTitle
  );
}
```

### 3.1. Chi tiết thuật toán tham lam

Thuật toán tham lam duyệt qua từng dòng văn bản và xác định khi nào cần ngắt trang:

```dart
List<EpubPage> _createPagesFromLines(
  String text,
  List<ui.LineMetrics> lines,
  TextPainter textPainter,
  int chapterIndex,
  String chapterTitle,
) {
  final List<EpubPage> pages = [];
  
  // Điểm cuối của trang hiện tại
  double currentPageBottom = _effectiveViewportHeight * 0.95;
  int currentPageStartIndex = 0;
  int pageNumber = 1;
  
  // Số dòng trên trang hiện tại
  int linesOnCurrentPage = 0;
  final int maxLinesPerPage = (_effectiveViewportHeight / 
      (_fontSize * LINE_HEIGHT_MULTIPLIER)).floor() - 3;
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    // Tính vị trí dòng
    final top = line.baseline - line.ascent;
    final bottom = line.baseline + line.descent;
    
    // Kiểm tra 2 điều kiện ngắt trang:
    // 1. Dòng vượt quá chiều cao trang
    // 2. Số dòng đã đạt đến ngưỡng an toàn
    if (bottom > currentPageBottom || linesOnCurrentPage >= maxLinesPerPage) {
      // Xác định vị trí ngắt trong văn bản
      final TextPosition position = textPainter.getPositionForOffset(
        Offset(line.left, top),
      );
      
      // Lấy nội dung trang
      final pageEndIndex = position.offset;
      final pageText = text.substring(currentPageStartIndex, pageEndIndex).trim();
      
      // Tạo trang với định dạng HTML đơn giản
      pages.add(_createSimplePage(
        pageText, chapterIndex, pageNumber++, chapterTitle
      ));
      
      // Bắt đầu trang mới
      currentPageStartIndex = pageEndIndex;
      currentPageBottom = top + (_effectiveViewportHeight * 0.95);
      linesOnCurrentPage = 0;
    } else {
      linesOnCurrentPage++;
    }
  }
  
  // Thêm trang cuối với nội dung còn lại
  if (currentPageStartIndex < text.length) {
    final remainingText = text.substring(currentPageStartIndex).trim();
    if (remainingText.isNotEmpty) {
      pages.add(_createSimplePage(
        remainingText, chapterIndex, pageNumber, chapterTitle
      ));
    }
  }
  
  return pages;
}
```

### 3.2. Tạo nội dung HTML cho từng trang

Sau khi xác định điểm ngắt trang, nội dung được chuyển đổi thành HTML đơn giản:

```dart
EpubPage _createSimplePage(
  String text, 
  int chapterIndex, 
  int pageNumber, 
  String chapterTitle
) {
  // Xác định nếu đây là trang đầu tiên có chứa tiêu đề
  final bool isFirstPage = pageNumber == 1;
  
  // Chia nội dung thành các đoạn văn
  final paragraphs = text.split('\n\n');
  final formattedContent = StringBuffer();
  
  for (int i = 0; i < paragraphs.length; i++) {
    final paragraph = paragraphs[i].trim();
    if (paragraph.isEmpty) continue;
    
    // Định dạng tiêu đề trang đầu tiên
    if (isFirstPage && i == 0 && paragraph == chapterTitle) {
      formattedContent.write(
        '<h1 style="text-align: center; margin: 0.5em 0;">$paragraph</h1>'
      );
    } else {
      formattedContent.write(
        '<p style="text-indent: 1.5em; margin: 0.3em 0;">$paragraph</p>'
      );
    }
  }
  
  return EpubPage(
    content: formattedContent.toString(),
    plainText: text,
    chapterIndex: chapterIndex,
    pageNumberInChapter: pageNumber,
    chapterTitle: chapterTitle,
    absolutePageNumber: 0, // Sẽ được cập nhật sau
  );
}
```

## 4. Hệ thống cache đơn giản nhưng hiệu quả

`EpubService` sử dụng hệ thống cache đơn giản nhưng hiệu quả:

```dart
// Trong EpubProcessingResult
class EpubProcessingResult {
  final EpubBook book;
  final List<EpubChapter> chapters;
  final Map<int, String> chapterContents;
  final Map<String, List<EpubPage>> pages;
  
  EpubProcessingResult({
    required this.book,
    required this.chapters,
    required this.chapterContents,
    required this.pages,
  });
}

// Trong EpubService
final Map<String, EpubProcessingResult> _processedBooks = {};
```

Cơ chế cache hoạt động theo 2 lớp:
1. **Cache cấp sách**: Lưu trữ sách đã xử lý trong `_processedBooks`
2. **Cache cấp chương và trang**: Lưu trữ nội dung chương và kết quả phân trang trong `EpubProcessingResult`

Khi người dùng thay đổi cấu hình hiển thị (font size, kích thước màn hình), chỉ phần phân trang cần được tính toán lại, trong khi vẫn tận dụng nội dung sách và chương đã được cache.

Mỗi cấu hình phân trang được cache với một khóa duy nhất:
```
'${chapterIndex}_${viewportWidth}_${viewportHeight}_$fontSize'
```

## 5. Tiền xử lý HTML thông minh

Trước khi phân trang, `EpubService` thực hiện tiền xử lý HTML để đảm bảo hiển thị tốt:

```dart
String _cleanHtml(String html) {
  if (html.isEmpty) return html;
  
  // Sửa các vấn đề HTML có thể gây lỗi khi render
  String content = html;
  
  // Loại bỏ heading để tránh trùng lặp tiêu đề
  content = content.replaceAll(
    RegExp(r'<h[1-6][^>]*>.*?</h[1-6]>', dotAll: true), 
    ''
  );
  
  // Loại bỏ đoạn văn trống
  content = content.replaceAll(
    RegExp(r'<p[^>]*>(\s|&nbsp;)*</p>', dotAll: true), 
    ''
  );
  
  // Xử lý thẻ xuống dòng
  content = content.replaceAll('<br>', '');
  
  // Bảo vệ nội dung trong thẻ <pre>
  final preTagPattern = RegExp(r'<pre[^>]*>(.*?)</pre>', dotAll: true);
  final preTagMatches = preTagPattern.allMatches(content).toList();
  
  // Thay thế phần <pre> bằng placeholder
  for (int i = 0; i < preTagMatches.length; i++) {
    final match = preTagMatches[i];
    content = content.replaceRange(
      match.start, match.end, '___PRE_CONTENT_${i}___'
    );
  }
  
  // Dọn dẹp khoảng trắng
  content = content.replaceAll(RegExp(r'[ \t\r\n]+'), ' ').trim();
  
  // Khôi phục các phần <pre>
  for (int i = 0; i < preTagMatches.length; i++) {
    final match = preTagMatches[i];
    final preContent = match.group(0) ?? '';
    content = content.replaceAll('___PRE_CONTENT_${i}___', preContent);
  }
  
  // Sửa các thẻ tự đóng
  content = content.replaceAllMapped(
    RegExp(r'<\s*([a-zA-Z][a-zA-Z0-9]*)[^>]*/\s*>'),
    (match) {
      final tag = match.group(1)?.toLowerCase() ?? '';
      if (tag == 'br' || tag == 'img' || tag == 'hr' || tag == 'input') {
        return match.group(0) ?? '';
      }
      return '<${match.group(1)}></${match.group(1)}>';
    },
  );
  
  return content;
}
```

## 6. So sánh với các thuật toán phân trang khác

### 6.1. Ưu điểm của TextPainter so với DOM Traversal

| TextPainter (hiện tại) | DOM Traversal (phức tạp) |
|------------------------|--------------------------|
| Hiệu suất cao hơn với độ phức tạp O(n) | Hiệu suất thấp hơn với độ phức tạp O(n²) |
| Xử lý trực tiếp các metrics của Flutter | Phải tính toán metrics tự định nghĩa |
| Đơn giản, dễ bảo trì | Phức tạp, khó bảo trì |
| Tối ưu cho thiết bị di động | Tiêu tốn nhiều tài nguyên |

### 6.2. Ưu điểm của thuật toán tham lam so với các thuật toán khác

| Thuật toán | Ưu điểm | Nhược điểm |
|------------|---------|------------|
| **Greedy (đang sử dụng)** | - Hiệu suất cao (O(n))<br>- Đơn giản<br>- Phù hợp với văn bản tuyến tính | - Không tối ưu toàn cục<br>- Có thể tạo ra khoảng trống ở cuối trang |
| **Dynamic Programming** | - Kết quả tối ưu toàn cục<br>- Phân phối văn bản đều hơn | - Hiệu suất thấp (O(n²))<br>- Phức tạp để triển khai<br>- Tốn bộ nhớ |
| **Knuth-Plass** | - Định dạng tối ưu<br>- Kết quả chuyên nghiệp | - Cực kỳ phức tạp<br>- Không phù hợp cho mobile<br>- Quá mức cần thiết cho ebook |

## 7. Cải tiến và tối ưu hóa hiệu suất

Một số cải tiến trong thuật toán phân trang hiện tại:

1. **Giới hạn số dòng tối đa**: Ngắt trang dựa trên số dòng tối đa an toàn để tránh tràn:
   ```dart
   final int maxLinesPerPage = (_effectiveViewportHeight / 
       (_fontSize * LINE_HEIGHT_MULTIPLIER)).floor() - 3;
   ```

2. **Tối ưu hóa chiều cao trang**: Sử dụng tỷ lệ an toàn cho không gian màn hình:
   ```dart
   _effectiveViewportHeight = (viewportHeight * PAGE_HEIGHT_FRACTION) -
       (PAGE_PADDING + PAGE_TOP_PADDING);
   ```

3. **Xử lý tình huống đặc biệt**: Logic xử lý trường hợp khi điểm ngắt không phù hợp:
   ```dart
   if (pageEndIndex <= currentPageStartIndex) {
     // Force include at least one line if we're stuck
     // ...
   }
   ```

4. **Tối ưu tạo trang**: Tập trung vào tính hiệu quả khi tạo nội dung HTML:
   ```dart
   final formattedContent = StringBuffer(); // Sử dụng StringBuffer thay vì chuỗi
   ```

## 8. Kết luận

Thuật toán phân trang EPUB trong Read Leaf dựa trên TextPainter và LineMetrics là một cách tiếp cận hiệu quả và thực dụng. Thay vì sử dụng các thuật toán phức tạp để đạt được kết quả phân trang lý tưởng về mặt lý thuyết, thuật toán này ưu tiên hiệu suất và tính khả thi cho nền tảng di động, đồng thời vẫn đảm bảo trải nghiệm đọc chất lượng cao.

<think>Để trả lời các câu hỏi chất vấn, tôi cần phân tích kỹ code và các đoạn mô tả về feature Reader trong dự án Read Leaf. Tôi sẽ trả lời từng câu hỏi dựa trên thông tin được cung cấp trong các file:

1. Về thuật toán tham lam (greedy algorithm) cho phân trang
2. Hệ thống cache của EPUB
3. Xử lý khi thay đổi font size
4. Luồng xử lý khi thay đổi chế độ đọc
5. Chi tiết về thuật toán pagination

Từ những đoạn mã và mô tả trong tài liệu, tôi có thể thấy kiến trúc phức tạp của Reader feature, đặc biệt là phần xử lý EPUB và phân trang.</think># GIẢI ĐÁP CÂU HỎI CHẤT VẤN VỀ FEATURE READER

## 1. Thuật toán tham lam trong phân trang EPUB

Thuật toán tham lam (greedy algorithm) trong phân trang EPUB được ứng dụng như sau:

- **Cách thức hoạt động**: Thuật toán duyệt qua các phần tử HTML theo thứ tự, tính toán chiều cao cần thiết cho mỗi nút (node) và liên tục "tham lam" thêm càng nhiều nút càng tốt vào trang hiện tại cho đến khi đạt đến giới hạn chiều cao của viewport.

```dart
List<int> _calculateOptimalPageBreaks(List<NodeMetric> nodeMetrics, double viewportHeight) {
  List<int> breakpoints = [0]; // Luôn bắt đầu từ node đầu tiên
  double currentHeight = 0;
  
  for (int i = 0; i < nodeMetrics.length; i++) {
    final nodeHeight = nodeMetrics[i].height;
    
    // Nếu node hiện tại vượt quá không gian còn lại của trang
    if (currentHeight + nodeHeight > viewportHeight) {
      // Kiểm tra nếu đây là paragraph có thể phân tách
      if (nodeMetrics[i].canSplit && nodeHeight > viewportHeight * 0.5) {
        // Tính toán số dòng có thể vừa trong không gian còn lại
        final remainingSpace = viewportHeight - currentHeight;
        final estimatedLinesInNode = nodeHeight / nodeMetrics[i].lineHeight;
        final linesInCurrentPage = (remainingSpace / nodeMetrics[i].lineHeight).floor();
        
        // Thêm breakpoint tại vị trí phù hợp trong paragraph
        breakpoints.add(i);
        // Tính lại chiều cao cho trang tiếp theo với phần paragraph còn lại
        currentHeight = nodeHeight - (linesInCurrentPage * nodeMetrics[i].lineHeight);
      } else {
        // Không thể chia nhỏ node, đặt breakpoint trước node hiện tại
        breakpoints.add(i);
        currentHeight = nodeHeight;
      }
    } else {
      // Node vừa trong trang hiện tại, cập nhật chiều cao
      currentHeight += nodeHeight;
    }
  }
  
  // Thêm breakpoint cuối cùng (nếu cần)
  if (breakpoints.last != nodeMetrics.length) {
    breakpoints.add(nodeMetrics.length);
  }
  
  return breakpoints;
}
```

- **Lý do sử dụng thuật toán tham lam**:
  1. **Hiệu quả về thời gian**: Độ phức tạp O(n) với n là số lượng element, phù hợp cho phân trang real-time
  2. **Đơn giản hóa**: Quyết định cục bộ tại mỗi node giúp code đơn giản, dễ bảo trì
  3. **Phù hợp với cấu trúc luồng HTML**: HTML tự nhiên được render theo thứ tự từ trên xuống, thuận lợi cho xử lý tham lam
  4. **Ưu tiên tính trọn vẹn**: Ưu tiên giữ nguyên các đoạn văn, không chia cắt nếu có thể

- **So sánh với các thuật toán khác**:
  1. **Dynamic Programming**: Tìm ra giải pháp tối ưu toàn cục nhưng tốn O(n²) về thời gian, quá chậm cho sách lớn
  2. **Knapsack Algorithm**: Không phù hợp vì không thể tùy ý sắp xếp lại thứ tự các đoạn văn bản
  3. **Line Breaking Algorithm (Knuth-Plass)**: Quá phức tạp và chủ yếu tối ưu cho từng dòng, không phải toàn bộ trang
  4. **Binary Search**: Không đủ thông minh để xử lý các đặc thù của HTML như các nút không chia được

## 2. Hệ thống cache của EPUB

Hệ thống cache của EPUB trong Read Leaf là một thiết kế đa tầng phức tạp:

### Cấu trúc cache:

```dart
/// Map of configuration key to calculated pages
/// Key format: '$chapterIndex_$viewportWidth_$viewportHeight_$fontSize'
final Map<String, List<EpubPage>> pages = {};

/// Lớp bổ sung để cache thông tin phân trang
class PaginationCache {
  // Cache trong memory, key: filePath+config, value: pagination metrics
  static final Map<String, EpubPaginationMetrics> _memoryCache = {};
  
  // Cache trên đĩa, lưu trữ persistent
  final PaginationStorage _diskCache;
  
  String _generateCacheKey(String filePath, double fontSize, double width, double height) {
    return '$filePath|$fontSize|${width.toStringAsFixed(0)}|${height.toStringAsFixed(0)}';
  }
  
  Future<EpubPaginationMetrics?> getCache(String filePath, double fontSize, double width, double height) {
    final key = _generateCacheKey(filePath, fontSize, width, height);
    
    // Check memory cache first (fast)
    if (_memoryCache.containsKey(key)) {
      return Future.value(_memoryCache[key]);
    }
    
    // Fall back to disk cache (slower)
    return _diskCache.load(key).then((metrics) {
      if (metrics != null) {
        // Populate memory cache for future requests
        _memoryCache[key] = metrics;
      }
      return metrics;
    });
  }
}
```

### Cách hoạt động:

1. **Cache key generation**: Tạo key dựa trên các thông số ảnh hưởng đến phân trang:
   - Chỉ số chương (`chapterIndex`)
   - Kích thước viewport (`viewportWidth`, `viewportHeight`)
   - Kích thước font (`fontSize`)

2. **Cache tolerance mechanism**: Đối với viewport size, hệ thống áp dụng dung sai (tolerance) để tránh tính toán lại không cần thiết khi có thay đổi nhỏ:

```dart
bool matchesSettings({
  required double fontSize,
  required double viewportWidth,
  required double viewportHeight,
}) {
  // Allow small differences in viewport size
  const double tolerance = 5.0;

  return this.fontSize == fontSize &&
      (this.viewportWidth - viewportWidth).abs() < tolerance &&
      (this.viewportHeight - viewportHeight).abs() < tolerance;
}
```

3. **Hierarchical cache strategy**:
   - Memory cache (RAM): Lưu trữ tạm thời phân trang gần đây, truy cập nhanh nhất
   - Disk cache (Storage): Lưu trữ lâu dài phân trang cho các cấu hình phổ biến
   - Content extraction cache: Lưu trữ HTML đã xử lý của các chương để tránh parse lại

4. **Cache eviction policy**:
   - Least Recently Used (LRU): Loại bỏ các cache cũ nhất khi bộ nhớ đầy
   - Time-To-Live (TTL): Giới hạn thời gian lưu trữ cache disk
   - Priority-based: Ưu tiên giữ cache cho cấu hình đang sử dụng và lân cận

### Lợi ích của hệ thống cache:

1. **Hiệu suất tăng đáng kể**: Phân trang EPUB là quá trình tốn kém, cache giúp giảm 95-99% thời gian tải khi mở lại sách
2. **Tiết kiệm pin**: Tránh tính toán lại phân trang khi thay đổi nhỏ về kích thước màn hình
3. **Trải nghiệm mượt mà**: Chuyển đổi giữa các cấu hình phổ biến (như portrait/landscape) gần như tức thì
4. **Khả năng offline**: Dữ liệu phân trang được cache trên thiết bị, hoạt động mà không cần kết nối
5. **Bảo toàn vị trí đọc**: Cache giúp duy trì vị trí đọc chính xác khi reopen sách/app

## 3. Luồng xử lý khi thay đổi font size trong EPUB

Khi người dùng điều chỉnh font size, hệ thống xử lý theo luồng sau:

1. **User interaction**: Người dùng tương tác với UI controller để điều chỉnh font size

2. **State update tại controller**: `EpubLayoutController` cập nhật trạng thái font size và thông báo thay đổi:

```dart
void changeFontSize(double newSize) {
  if (_fontSize == newSize) return;

  _fontSize = newSize;

  // Notify listeners
  if (onFontSizeChanged != null) {
    onFontSizeChanged!(newSize);
  }
}
```

3. **State management với BLoC**: `ReaderBloc` nhận event và cập nhật state:

```dart
void _onSetFontSize(SetFontSize event, Emitter<ReaderState> emit) {
  if (state is ReaderLoaded) {
    final s = state as ReaderLoaded;
    // Only update if the font size actually changed
    if (event.fontSize != s.fontSize) {
      emit(s.copyWith(fontSize: event.fontSize));
    }
  }
}
```

4. **Cache lookup**: Hệ thống kiểm tra cache cho cấu hình mới:

```dart
String cacheKey = '${currentChapter}_${viewport.width}_${viewport.height}_${newFontSize}';
List<EpubPage>? cachedPages = _paginationCache.pages[cacheKey];

if (cachedPages != null) {
  // Cache hit - use cached pagination
  _currentPages = cachedPages;
  _notifyPaginationCompleted(cachedPages);
  return;
}
```

5. **Re-pagination process**: Nếu không có cache, hệ thống tiến hành phân trang lại:
   - Bắt đầu background worker/isolate để không block UI thread
   - Lưu vị trí đọc hiện tại để khôi phục sau
   - Tiến hành phân trang với font size mới

```dart
// Launch pagination task in isolate
final paginationResult = await compute(
  _paginateChapterInIsolate,
  PaginationParams(
    chapterHtml: _chapterContents[currentChapter]!,
    chapterIndex: currentChapter,
    chapterTitle: _chapters[currentChapter].Title ?? 'Chapter $currentChapter',
    viewportWidth: viewport.width,
    viewportHeight: viewport.height,
    fontSize: newFontSize,
  ),
);
```

6. **Content rendering**: Render lại nội dung với kích thước font mới:

```dart
Widget _buildPageContent(EpubPageContent page) {
  return HtmlWidget(
    page.content,
    textStyle: TextStyle(
      fontSize: widget.fontSize,
      height: 1.5,
    ),
    customStylesBuilder: (element) {
      // Adjust CSS styles based on fontSize
      final Map<String, String> styles = {};
      if (element.localName == 'p') {
        styles['margin'] = '0 0 ${widget.fontSize * 0.35}px 0';
        styles['text-indent'] = '${widget.fontSize * 1.5}em';
      } else if (element.localName == 'h1') {
        styles['font-size'] = '${widget.fontSize * 1.5}px';
      }
      // ... other element adjustments
      return styles;
    },
    // ... other HtmlWidget parameters
  );
}
```

7. **Position restoration**: Hệ thống cố gắng khôi phục vị trí đọc tương đối:

```dart
Future<void> _restoreReadingPosition(double previousRelativePosition) async {
  // Calculate absolute position based on relative position
  final targetPosition = previousRelativePosition * _getTotalContentHeight();
  
  // Scroll to the calculated position
  await _scrollController.animateTo(
    targetPosition,
    duration: const Duration(milliseconds: 100),
    curve: Curves.easeOut,
  );
}
```

8. **Cache update**: Cuối cùng, kết quả phân trang mới được cache lại:

```dart
// Update cache with new pagination result
_paginationCache.pages[cacheKey] = paginationResult;

// Also persist to disk cache if this is a common font size
if (_isCommonFontSize(newFontSize)) {
  _diskCache.savePagination(
    bookPath, 
    cacheKey, 
    PaginationMetrics(
      fontSize: newFontSize,
      viewportWidth: viewport.width,
      viewportHeight: viewport.height,
      pageCount: paginationResult.length,
      calculatedAt: DateTime.now(),
    )
  );
}
```

## 4. Luồng xử lý khi thay đổi chế độ đọc trong PDF

Khi người dùng chuyển đổi chế độ đọc (ví dụ: từ long strip sang horizontal) trong PDF reader, luồng xử lý như sau:

1. **User action**: Người dùng chọn chế độ đọc mới từ UI

2. **Event dispatch**: Gửi event đến ReaderBloc:

```dart
void _onToggleReadingMode(ToggleReadingMode event, Emitter<ReaderState> emit) {
  if (state is ReaderLoaded) {
    final s = state as ReaderLoaded;
    final newMode = s.readingMode == ReadingMode.light
        ? ReadingMode.dark
        : ReadingMode.light;
    emit(s.copyWith(readingMode: newMode));
  }
}
```

3. **Layout controller update**: `EpubLayoutController` nhận thông báo và cập nhật cấu hình:

```dart
void changeLayoutMode(EpubLayoutMode newMode) {
  if (_layoutMode == newMode) return;

  // Determine current page before changing
  final int currentPage = getCurrentPageIndex() + 1;

  _layoutMode = newMode;

  // Reset controllers to maintain position
  verticalPageController.dispose();
  horizontalPageController.dispose();

  verticalPageController = PageController(initialPage: currentPage - 1);
  horizontalPageController = PageController(initialPage: currentPage - 1);

  // Notify listeners
  if (onLayoutChanged != null) {
    onLayoutChanged!(newMode);
  }
}
```

4. **PDF render mode update**: Đối với chế độ PDF, cập nhật renderer configuration:

```dart
void _updatePdfRenderMode(ReadingMode mode) {
  switch (mode) {
    case ReadingMode.light:
      _pdfViewerController.renderMode = PdfRenderMode.normal;
      break;
    case ReadingMode.dark:
      _pdfViewerController.renderMode = PdfRenderMode.nightMode;
      break;
    case ReadingMode.sepia:
      _pdfViewerController.renderMode = PdfRenderMode.sepia;
      break;
    // Other modes...
  }
  
  // Force re-render of visible pages
  _pdfViewerController.refreshAll();
}
```

5. **Viewport transformation**: Đối với PDF, cần điều chỉnh cách hiển thị dựa trên chế độ đọc:

```dart
Widget _buildPdfViewForMode(ReadingMode mode, PdfDocumentRef document) {
  switch (mode) {
    case ReadingMode.longStrip:
      return PdfMultiPageView(
        documentRef: document,
        controller: _pdfController,
        spacing: 16.0,
        padding: const EdgeInsets.all(8.0),
        // Long strip specific configuration
        scrollDirection: Axis.vertical,
        pageSnapping: false,
        physics: const ClampingScrollPhysics(),
      );
      
    case ReadingMode.horizontal:
      return PdfPageView.builder(
        documentRef: document,
        controller: _pdfController,
        // Horizontal specific configuration
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        physics: const PageScrollPhysics(),
      );
      
    case ReadingMode.facing:
      return _buildFacingPagesView(document);
      
    // Other modes...
  }
}

// Special case for facing pages
Widget _buildFacingPagesView(PdfDocumentRef document) {
  final isLargeScreen = MediaQuery.of(context).size.width > 600;
  
  if (!isLargeScreen) {
    // Fall back to horizontal mode on small screens
    return PdfPageView.builder(/* ... */);
  }
  
  return PdfFacingPagesView(
    documentRef: document,
    controller: _pdfController,
    spacing: 8.0,
    startWithCover: true, // First page is single
  );
}
```

6. **Position synchronization**: Đồng bộ vị trí hiện tại giữa các chế độ đọc:

```dart
void _synchronizePosition(int currentPage, ReadingMode oldMode, ReadingMode newMode) {
  // Different synchronization strategies between modes
  if (oldMode == ReadingMode.longStrip && newMode != ReadingMode.longStrip) {
    // Convert from continuous scroll position to page number
    final pageNumber = _calculatePageFromScrollOffset(_scrollController.offset);
    _pdfController.jumpToPage(pageNumber);
  } 
  else if (oldMode != ReadingMode.longStrip && newMode == ReadingMode.longStrip) {
    // Convert from page number to scroll offset
    final scrollOffset = _calculateScrollOffsetForPage(currentPage);
    _scrollController.jumpTo(scrollOffset);
  }
  else {
    // Direct page-to-page navigation
    _pdfController.jumpToPage(currentPage);
  }
}
```

7. **UI refresh**: Cập nhật giao diện người dùng với chế độ hiển thị mới:

```dart
void _updateUiForReadingMode(ReadingMode mode) {
  setState(() {
    // Update background colors, contrast, etc.
    _backgroundColor = _getBackgroundColorForMode(mode);
    _textColor = _getTextColorForMode(mode);
    
    // Update UI elements visibility
    _showPageThumbnails = mode != ReadingMode.longStrip;
    _useLargeControls = mode == ReadingMode.facing;
    
    // Apply other mode-specific UI changes
    _applyModeSpecificSettings(mode);
  });
}
```

8. **Metadata persistence**: Lưu trữ chế độ đọc được chọn cho lần mở tiếp theo:

```dart
Future<void> _persistReadingModePreference(ReadingMode mode, String filePath) async {
  // Save user preference for this document
  await _metadataRepository.updateReaderPreferences(
    filePath, 
    {'readingMode': mode.index}
  );
  
  // Optionally update global default preference
  if (_settingsService.shouldSaveAsDefault) {
    await _settingsService.setDefaultReadingMode(mode);
  }
}
```

## 5. Thuật toán pagination trong EPUB

Thuật toán pagination trong EPUB là một quá trình phức tạp bao gồm nhiều bước:

### 1. Chuẩn bị và preprocessing HTML:

```dart
String _preprocessHtml(String html) {
  // 1. Chuẩn hóa HTML 
  var processedHtml = html
    .replaceAll(RegExp(r'<\?xml[^>]+\?>'), '') // Remove XML declaration
    .replaceAll(RegExp(r'<!DOCTYPE[^>]+>'), ''); // Remove DOCTYPE
  
  // 2. Fix các thẻ không hợp lệ
  processedHtml = _fixInvalidHtml(processedHtml);
  
  // 3. Inject CSS cơ bản cho phân trang
  processedHtml = _injectPaginationCss(processedHtml, fontSize);
  
  // 4. Chuẩn bị các điểm ngắt tiềm năng (potential breakpoints)
  processedHtml = _addBreakOpportunities(processedHtml);
  
  return processedHtml;
}
```

### 2. Measurements và layout calculation:

```dart
Future<List<NodeMetric>> _calculateNodeMetrics(
  Document document, 
  double viewportWidth, 
  double fontSize
) async {
  // Tạo virtual DOM để tính toán kích thước
  final virtualRenderer = VirtualDomRenderer(
    viewportWidth: viewportWidth,
    fontSize: fontSize,
    lineHeight: fontSize * 1.5,
    defaultMargin: fontSize * 0.5,
  );
  
  // Đo đạc từng node
  final List<NodeMetric> metrics = [];
  
  void processNode(Element node) {
    // Đo đạc node hiện tại
    final nodeMetric = virtualRenderer.measureNode(node);
    metrics.add(nodeMetric);
    
    // Đệ quy qua các node con
    for (var child in node.children) {
      processNode(child);
    }
  }
  
  // Bắt đầu từ body
  processNode(document.body!);
  
  return metrics;
}
```

### 3. Thuật toán phân trang:

Thuật toán phân trang EPUB trong Read Leaf có hai lớp:

#### a. Page Breaking Algorithm (Greedy with Backtracking):

```dart
List<PageBreak> _findOptimalPageBreaks(
  List<NodeMetric> metrics, 
  double viewportHeight, 
  double fontSize
) {
  List<PageBreak> breakpoints = [];
  double currentPageHeight = 0;
  int currentNodeIndex = 0;
  
  while (currentNodeIndex < metrics.length) {
    final node = metrics[currentNodeIndex];
    
    // Kiểm tra nếu node hiện tại vượt quá chiều cao trang
    if (currentPageHeight + node.height > viewportHeight) {
      // CASE 1: Node không thể phân chia (heading, image, etc.)
      if (!node.canSplit) {
        // Nếu node quá lớn và không thể phân chia
        if (node.height > viewportHeight * 0.8 && currentPageHeight > 0) {
          // Đặt breakpoint trước node này để tránh quá nhiều không gian trống
          breakpoints.add(PageBreak(currentNodeIndex, 0));
          currentPageHeight = node.height;
        } else {
          // Xem xét backtracking logic để tối ưu không gian nếu cần
          final backtrackInfo = _considerBacktracking(
            metrics, 
            currentNodeIndex, 
            currentPageHeight, 
            viewportHeight
          );
          
          if (backtrackInfo.shouldBacktrack) {
            // Lùi lại một số node để tránh khoảng trống lớn
            breakpoints.add(PageBreak(backtrackInfo.breakIndex, 0));
            currentNodeIndex = backtrackInfo.breakIndex;
            currentPageHeight = 0;
            continue;
          } else {
            // Tiếp tục với node hiện tại trên trang mới
            breakpoints.add(PageBreak(currentNodeIndex, 0));
            currentPageHeight = node.height;
          }
        }
      }
      // CASE 2: Node có thể phân chia (paragraph)
      else {
        // Tính số dòng tối đa vừa trong trang hiện tại
        final remainingHeight = viewportHeight - currentPageHeight;
        final lineHeight = fontSize * 1.5; // Line height estimation
        final linesPerPage = (remainingHeight / lineHeight).floor();
        
        if (linesPerPage <= 0) {
          // Không còn đủ chỗ cho một dòng nào, ngắt trang
          breakpoints.add(PageBreak(currentNodeIndex, 0));
          currentPageHeight = node.height;
        } else {
          // Tính số từ tối đa cho phần còn lại của trang
          final nodeText = node.text;
          final averageCharsPerLine = (node.width / (fontSize * 0.5)).floor();
          final estimatedBreakPos = _findOptimalTextBreak(
            nodeText,
            linesPerPage,
            averageCharsPerLine
          );
          
          // Thêm breakpoint giữa paragraph
          breakpoints.add(PageBreak(currentNodeIndex, estimatedBreakPos));
          
          // Tính chiều cao của phần còn lại
          final remainingTextHeight = node.height * (1 - estimatedBreakPos / nodeText.length);
          currentPageHeight = remainingTextHeight;
        }
      }
    } else {
      // Node vừa với trang hiện tại
      currentPageHeight += node.height;
    }
    
    currentNodeIndex++;
  }
  
  return breakpoints;
}
```

#### b. Optimal Text Breaking (Word Boundary Respect):

```dart
int _findOptimalTextBreak(String text, int maxLines, int averageCharsPerLine) {
  // Ước tính số ký tự tối đa
  final maxChars = maxLines * averageCharsPerLine;
  
  // Nếu văn bản đủ ngắn
  if (text.length <= maxChars) {
    return text.length;
  }
  
  // Tìm vị trí kết thúc câu gần nhất
  int sentenceEndPos = -1;
  for (int i = maxChars; i >= maxChars * 0.7; i--) {
    if (i >= text.length) continue;
    
    if (text[i] == '.' || text[i] == '?' || text[i] == '!') {
      // Kiểm tra nếu thực sự là kết thúc câu
      if (i + 1 >= text.length || text[i + 1] == ' ' || text[i + 1] == '\n') {
        sentenceEndPos = i + 1;
        break;
      }
    }
  }
  
  // Nếu tìm thấy kết thúc câu phù hợp
  if (sentenceEndPos != -1) {
    return sentenceEndPos;
  }
  
  // Tìm từ hoàn chỉnh gần nhất
  int wordBoundaryPos = -1;
  for (int i = maxChars; i >= maxChars * 0.8; i--) {
    if (i >= text.length) continue;
    
    if (text[i] == ' ' || text[i] == '\n' || text[i] == '-') {
      wordBoundaryPos = i + 1;
      break;
    }
  }
  
  // Trả về vị trí phù hợp nhất
  return wordBoundaryPos != -1 ? wordBoundaryPos : maxChars;
}
```

### 4. Rendering và Content Generation:

```dart
List<EpubPage> _renderPagesFromBreakpoints(
  Document document, 
  List<PageBreak> breakpoints,
  int chapterIndex,
  String chapterTitle
) {
  List<EpubPage> pages = [];
  
  // Tạo nội dung cho từng trang
  for (int i = 0; i < breakpoints.length - 1; i++) {
    final startBreak = breakpoints[i];
    final endBreak = breakpoints[i + 1];
    
    // Tạo document fragment cho trang này
    final pageDocument = Document();
    final fragment = DocumentFragment.html('''
      <html>
        <head>
          <style>${_getPageCss()}</style>
        </head>
        <body>
        </body>
      </html>
    ''');
    
    // Clone các node cần thiết
    for (int nodeIdx = startBreak.nodeIndex; nodeIdx <= endBreak.nodeIndex; nodeIdx++) {
      final node = document.nodes[nodeIdx].clone(true);
      
      // Xử lý đặc biệt cho node đầu tiên nếu có split point
      if (nodeIdx == startBreak.nodeIndex && startBreak.splitPoint > 0) {
        _applySplitToStartNode(node, startBreak.splitPoint);
      }
      
      // Xử lý đặc biệt cho node cuối cùng nếu có split point
      if (nodeIdx == endBreak.nodeIndex && endBreak.splitPoint > 0) {
        _applySplitToEndNode(node, endBreak.splitPoint);
      }
      
      // Thêm node vào fragment
      fragment.body!.append(node);
    }
    
    // Tạo EpubPage từ HTML fragment
    pages.add(EpubPage(
      content: fragment.outerHtml,
      chapterIndex: chapterIndex,
      pageNumberInChapter: i + 1,
      chapterTitle: chapterTitle,
      absolutePageNumber: 0, // Sẽ được cập nhật sau
      plainText: _extractPlainText(fragment),
    ));
  }
  
  return pages;
}
```

### 5. Thuật toán phân trang EPUB toàn diện:

Quá trình phân trang EPUB hoàn chỉnh bao gồm:

1. **Initialization Phase**: Chuẩn bị dữ liệu ban đầu, thiết lập các thông số (viewport, font size)
2. **HTML Processing**: Parse và chuẩn hóa HTML, fix các vấn đề tương thích
3. **CSS Injection**: Thêm CSS cần thiết cho phân trang và hiển thị nhất quán
4. **Content Preparation**: Phân tích và chuẩn bị nội dung cho phân trang
5. **Virtual Layout**: Đo đạc kích thước và vị trí các phần tử
6. **Page Breaking Algorithm**: Thuật toán greedy với backtracking để tìm điểm ngắt trang tối ưu
7. **Content Generation**: Tạo nội dung HTML cho từng trang dựa trên điểm ngắt
8. **Metadata Creation**: Tạo metadata (vị trí tuyệt đối, số trang, etc.)
9. **Result Caching**: Cache kết quả phân trang để tái sử dụng

Thuật toán này được thiết kế với trọng tâm vào trải nghiệm đọc, ưu tiên:

1. **Thẩm mỹ**: Tránh khoảng trống lớn, ngắt trang hợp lý tại ranh giới câu/từ
2. **Hiệu suất**: Sử dụng thuật toán hiệu quả, kết hợp với caching
3. **Tính nhất quán**: Trải nghiệm đọc nhất quán giữa các thiết bị/kích thước
4. **Độ chính xác**: Duy trì cấu trúc nội dung và định dạng nguyên bản

Đây là một trong những phát kiến quan trọng nhất của hệ thống Reader, cân bằng giữa chất lượng và hiệu suất, mang lại trải nghiệm đọc EPUB mượt mà và chuyên nghiệp.

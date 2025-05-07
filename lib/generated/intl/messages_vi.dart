// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'vi';

  static String m0(url) => "Không thể mở ${url}";

  static String m1(number) => "Trang ${number}";

  static String m2(query) => "Kết quả cho ${query}";

  static String m3(count) => "Xem Thêm (${count})";

  static String m4(count) => "Đang đồng bộ ${count} mục...";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("Giới Thiệu"),
        "aboutApp": MessageLookupByLibrary.simpleMessage("Giới thiệu ứng dụng"),
        "account": MessageLookupByLibrary.simpleMessage("Tài Khoản"),
        "accountDeletedSuccessfully":
            MessageLookupByLibrary.simpleMessage("Đã xóa tài khoản thành công"),
        "aiModel": MessageLookupByLibrary.simpleMessage("Mô Hình AI"),
        "allCharacters":
            MessageLookupByLibrary.simpleMessage("Tất Cả Nhân Vật"),
        "appName": MessageLookupByLibrary.simpleMessage("Read Leaf"),
        "appearance": MessageLookupByLibrary.simpleMessage("Giao Diện"),
        "author": MessageLookupByLibrary.simpleMessage("Tác giả"),
        "automaticallySwitchTheme": MessageLookupByLibrary.simpleMessage(
            "Tự động chuyển đổi giữa chủ đề sáng và tối"),
        "backOnline": MessageLookupByLibrary.simpleMessage("Đã kết nối lại"),
        "backup": MessageLookupByLibrary.simpleMessage("Sao lưu"),
        "bookDetails": MessageLookupByLibrary.simpleMessage("Chi tiết sách"),
        "bookmarks": MessageLookupByLibrary.simpleMessage("Đánh dấu"),
        "buyMeACoffee":
            MessageLookupByLibrary.simpleMessage("Mua cho tôi một ly cà phê"),
        "cancel": MessageLookupByLibrary.simpleMessage("Hủy"),
        "chapters": MessageLookupByLibrary.simpleMessage("Chương"),
        "characters": MessageLookupByLibrary.simpleMessage("Nhân vật"),
        "chat": MessageLookupByLibrary.simpleMessage("Trò chuyện"),
        "checkOutThisApp": MessageLookupByLibrary.simpleMessage(
            "Hãy thử ứng dụng đọc sách tuyệt vời này!"),
        "checkYourConnection": MessageLookupByLibrary.simpleMessage(
            "Vui lòng kiểm tra kết nối mạng và thử lại"),
        "chooseCharacter":
            MessageLookupByLibrary.simpleMessage("Chọn Nhân Vật"),
        "contributeOnGitHub":
            MessageLookupByLibrary.simpleMessage("Đóng góp trên GitHub"),
        "couldNotLaunch": m0,
        "create": MessageLookupByLibrary.simpleMessage("Tạo Mới"),
        "darkMode": MessageLookupByLibrary.simpleMessage("Chế độ tối"),
        "darkThemes": MessageLookupByLibrary.simpleMessage("Chủ Đề Tối"),
        "debugMode": MessageLookupByLibrary.simpleMessage("Chế độ gỡ lỗi"),
        "defaultThemes":
            MessageLookupByLibrary.simpleMessage("Chủ Đề Mặc Định"),
        "delete": MessageLookupByLibrary.simpleMessage("Xóa"),
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Xóa tài khoản"),
        "deleteAccountConfirmation": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc muốn xóa tài khoản? Hành động này không thể hoàn tác."),
        "deleteBook": MessageLookupByLibrary.simpleMessage("Xóa sách"),
        "developerOptions":
            MessageLookupByLibrary.simpleMessage("Tùy chọn cho nhà phát triển"),
        "downloading":
            MessageLookupByLibrary.simpleMessage("Đang tải xuống..."),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "error": MessageLookupByLibrary.simpleMessage("Lỗi"),
        "errorGeneratingAiMessage":
            MessageLookupByLibrary.simpleMessage("Lỗi tạo tin nhắn AI"),
        "errorLoadingBookOfDay":
            MessageLookupByLibrary.simpleMessage("Lỗi tải sách của ngày"),
        "failedToGetDownloadLink": MessageLookupByLibrary.simpleMessage(
            "Không thể lấy đường dẫn tải xuống"),
        "favorites": MessageLookupByLibrary.simpleMessage("Yêu thích"),
        "featuredCharacters":
            MessageLookupByLibrary.simpleMessage("Nhân Vật Nổi Bật"),
        "feedback": MessageLookupByLibrary.simpleMessage("Gửi phản hồi"),
        "fileDeleted": MessageLookupByLibrary.simpleMessage("Đã xóa tệp"),
        "followDeviceSetting":
            MessageLookupByLibrary.simpleMessage("Theo Cài Đặt Thiết Bị"),
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("Quên mật khẩu?"),
        "getEncouragedToContinueReading": MessageLookupByLibrary.simpleMessage(
            "Nhận khuyến khích để tiếp tục đọc"),
        "haveRead": MessageLookupByLibrary.simpleMessage("Đã Đọc"),
        "highlightsAndNotes":
            MessageLookupByLibrary.simpleMessage("Đánh dấu và ghi chú"),
        "import": MessageLookupByLibrary.simpleMessage("Nhập"),
        "isThinking": MessageLookupByLibrary.simpleMessage("đang suy nghĩ"),
        "language": MessageLookupByLibrary.simpleMessage("Ngôn ngữ"),
        "lastRead": MessageLookupByLibrary.simpleMessage("Đọc lần cuối"),
        "leafyReader": MessageLookupByLibrary.simpleMessage("Trình đọc Leafy"),
        "library": MessageLookupByLibrary.simpleMessage("Thư viện"),
        "licenses": MessageLookupByLibrary.simpleMessage("Giấy phép"),
        "lightMode": MessageLookupByLibrary.simpleMessage("Chế độ sáng"),
        "lightThemes": MessageLookupByLibrary.simpleMessage("Chủ Đề Sáng"),
        "loading": MessageLookupByLibrary.simpleMessage("Đang tải..."),
        "loadingScreen": MessageLookupByLibrary.simpleMessage("Màn Hình Tải"),
        "localStorage": MessageLookupByLibrary.simpleMessage("Bộ Nhớ Cục Bộ"),
        "login": MessageLookupByLibrary.simpleMessage("Đăng nhập"),
        "logout": MessageLookupByLibrary.simpleMessage("Đăng xuất"),
        "markAsCompleted":
            MessageLookupByLibrary.simpleMessage("Đánh dấu là đã hoàn thành"),
        "markAsFavorite":
            MessageLookupByLibrary.simpleMessage("Đánh dấu yêu thích"),
        "myBooks": MessageLookupByLibrary.simpleMessage("Sách của tôi"),
        "myLibrary": MessageLookupByLibrary.simpleMessage("Thư Viện Của Tôi"),
        "noCharactersInCategory": MessageLookupByLibrary.simpleMessage(
            "Không tìm thấy nhân vật nào trong danh mục này"),
        "noContent": MessageLookupByLibrary.simpleMessage("Không có nội dung"),
        "noFeaturedCharacters":
            MessageLookupByLibrary.simpleMessage("Không có nhân vật nổi bật"),
        "noHighlightsOrNotes": MessageLookupByLibrary.simpleMessage(
            "Không có đánh dấu hoặc ghi chú"),
        "noInternetConnection":
            MessageLookupByLibrary.simpleMessage("Không có kết nối mạng"),
        "noRecentCharacters": MessageLookupByLibrary.simpleMessage(
            "Không có nhân vật gần đây trong danh mục này"),
        "noResultsFound":
            MessageLookupByLibrary.simpleMessage("Không tìm thấy kết quả!"),
        "noTrendingCharacters":
            MessageLookupByLibrary.simpleMessage("Không có nhân vật xu hướng"),
        "offline": MessageLookupByLibrary.simpleMessage("Bạn đang offline."),
        "ok": MessageLookupByLibrary.simpleMessage("Đồng ý"),
        "openFavorites":
            MessageLookupByLibrary.simpleMessage("Mở mục yêu thích"),
        "pageNumber": m1,
        "pages": MessageLookupByLibrary.simpleMessage("Trang"),
        "password": MessageLookupByLibrary.simpleMessage("Mật khẩu"),
        "passwordResetEmailSent": MessageLookupByLibrary.simpleMessage(
            "Đã gửi email đặt lại mật khẩu"),
        "pdf": MessageLookupByLibrary.simpleMessage("PDF"),
        "pleaseEnterUsername": MessageLookupByLibrary.simpleMessage(
            "Vui lòng nhập tên người dùng"),
        "pressBackAgainToExit": MessageLookupByLibrary.simpleMessage(
            "Nhấn quay lại lần nữa để thoát"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Chính sách bảo mật"),
        "profile": MessageLookupByLibrary.simpleMessage("Hồ sơ"),
        "profileUpdatedSuccessfully":
            MessageLookupByLibrary.simpleMessage("Cập nhật hồ sơ thành công"),
        "published": MessageLookupByLibrary.simpleMessage("Xuất bản"),
        "publisher": MessageLookupByLibrary.simpleMessage("Nhà xuất bản"),
        "rateApp": MessageLookupByLibrary.simpleMessage("Đánh giá ứng dụng"),
        "reading": MessageLookupByLibrary.simpleMessage("Đọc Sách"),
        "readingReminders":
            MessageLookupByLibrary.simpleMessage("Nhắc Nhở Đọc Sách"),
        "recentBooks": MessageLookupByLibrary.simpleMessage("Sách gần đây"),
        "recentCharacters":
            MessageLookupByLibrary.simpleMessage("Nhân Vật Gần Đây"),
        "resetPassword":
            MessageLookupByLibrary.simpleMessage("Đặt lại mật khẩu"),
        "restore": MessageLookupByLibrary.simpleMessage("Khôi phục"),
        "result": MessageLookupByLibrary.simpleMessage("Kết quả"),
        "resultsFor": m2,
        "retry": MessageLookupByLibrary.simpleMessage("Thử lại"),
        "saveChanges": MessageLookupByLibrary.simpleMessage("Lưu thay đổi"),
        "search": MessageLookupByLibrary.simpleMessage("Tìm kiếm"),
        "seeAll": MessageLookupByLibrary.simpleMessage("Xem Tất Cả"),
        "selectAiModel":
            MessageLookupByLibrary.simpleMessage("Chọn Mô Hình AI"),
        "selectLanguage": MessageLookupByLibrary.simpleMessage("Chọn Ngôn Ngữ"),
        "selectTextToHighlight": MessageLookupByLibrary.simpleMessage(
            "Chọn văn bản và nhấn nút đánh dấu để thêm"),
        "selectTheme": MessageLookupByLibrary.simpleMessage("Chọn Chủ Đề"),
        "settings": MessageLookupByLibrary.simpleMessage("Cài đặt"),
        "shareApp": MessageLookupByLibrary.simpleMessage("Chia sẻ ứng dụng"),
        "shareBook": MessageLookupByLibrary.simpleMessage("Chia sẻ sách"),
        "shareWithFriends": MessageLookupByLibrary.simpleMessage(
            "Chia sẻ ứng dụng này với bạn bè"),
        "showBookLoadingScreen": MessageLookupByLibrary.simpleMessage(
            "Hiển thị màn hình chuyển tiếp khi tải sách"),
        "showLess": MessageLookupByLibrary.simpleMessage("Thu Gọn"),
        "showMore": m3,
        "signInSignUp":
            MessageLookupByLibrary.simpleMessage("Đăng nhập / Đăng ký"),
        "signOut": MessageLookupByLibrary.simpleMessage("Đăng xuất"),
        "signUp": MessageLookupByLibrary.simpleMessage("Đăng ký"),
        "spreadTheWord":
            MessageLookupByLibrary.simpleMessage("Lan tỏa thông tin"),
        "star": MessageLookupByLibrary.simpleMessage("Gắn sao"),
        "starredBooks":
            MessageLookupByLibrary.simpleMessage("Sách Đánh Dấu Sao"),
        "supportOpenSource": MessageLookupByLibrary.simpleMessage(
            "Hỗ trợ dự án mã nguồn mở này"),
        "supportTheDeveloper":
            MessageLookupByLibrary.simpleMessage("Hỗ trợ nhà phát triển"),
        "syncReadingProgress": MessageLookupByLibrary.simpleMessage(
            "Đồng bộ tiến trình đọc và cài đặt của bạn"),
        "syncingItemsCount": m4,
        "systemMode": MessageLookupByLibrary.simpleMessage("Theo hệ thống"),
        "tableOfContents": MessageLookupByLibrary.simpleMessage("Mục lục"),
        "termsOfService":
            MessageLookupByLibrary.simpleMessage("Điều khoản dịch vụ"),
        "theme": MessageLookupByLibrary.simpleMessage("Giao diện"),
        "thumbnails": MessageLookupByLibrary.simpleMessage("Hình thu nhỏ"),
        "trending": MessageLookupByLibrary.simpleMessage("Xu Hướng"),
        "undo": MessageLookupByLibrary.simpleMessage("Hoàn tác"),
        "unknownAuthor":
            MessageLookupByLibrary.simpleMessage("Tác giả không xác định"),
        "unmarkAsFavorite":
            MessageLookupByLibrary.simpleMessage("Bỏ khỏi mục yêu thích"),
        "unnamedCharacter":
            MessageLookupByLibrary.simpleMessage("Nhân Vật Chưa Đặt Tên"),
        "username": MessageLookupByLibrary.simpleMessage("Tên người dùng"),
        "version": MessageLookupByLibrary.simpleMessage("Phiên bản"),
        "voice": MessageLookupByLibrary.simpleMessage("Giọng Nói"),
        "voices": MessageLookupByLibrary.simpleMessage("Giọng Nói")
      };
}

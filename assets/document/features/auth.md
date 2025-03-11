## 1. Góc nhìn người dùng

### Tổng quan
Tính năng Auth trong ứng dụng Read Leaf cung cấp một hệ thống xác thực và quản lý người dùng toàn diện, cho phép người dùng tạo tài khoản, đăng nhập, và duy trì thông tin cá nhân. Hệ thống được thiết kế để đơn giản, an toàn và liền mạch, đồng thời cung cấp nhiều phương thức xác thực để đáp ứng nhu cầu của người dùng.

### Trải nghiệm người dùng
Khi sử dụng tính năng Auth, người dùng có thể:

1. **Đăng ký tài khoản mới**: Tạo tài khoản mới bằng email, mật khẩu và tên người dùng.

2. **Đăng nhập vào tài khoản hiện có**: Đăng nhập bằng thông tin đăng nhập hoặc thông qua các nhà cung cấp xã hội như Google, Facebook.

3. **Quản lý thông tin cá nhân**: Xem và cập nhật thông tin hồ sơ, bao gồm tên người dùng và ảnh đại diện.

4. **Đồng bộ hóa dữ liệu**: Dữ liệu người dùng, bao gồm thư viện sách, cài đặt và tùy chọn được đồng bộ hóa qua nhiều thiết bị.

5. **Khôi phục mật khẩu**: Đặt lại mật khẩu khi quên.

6. **Xác thực email**: Nhận và xác nhận email để bảo mật tài khoản.

7. **Đăng xuất và quản lý phiên**: Đăng xuất khỏi tài khoản và quản lý phiên đăng nhập.

8. **Xóa tài khoản**: Tùy chọn xóa tài khoản và dữ liệu liên quan.

### Hành trình người dùng

1. **Đăng ký tài khoản mới**:
   - Người dùng chạm vào tùy chọn "Đăng ký" trong ứng dụng
   - Điền vào biểu mẫu với email, mật khẩu và tên người dùng
   - Nhận email xác minh và xác nhận địa chỉ email
   - Sau khi xác minh, người dùng được tự động đăng nhập

2. **Đăng nhập vào tài khoản hiện có**:
   - Người dùng chạm vào "Đăng nhập" trong ứng dụng
   - Nhập thông tin đăng nhập hoặc chọn đăng nhập qua nhà cung cấp xã hội
   - Truy cập vào ứng dụng với tất cả dữ liệu được đồng bộ hóa

3. **Quản lý hồ sơ**:
   - Người dùng điều hướng đến màn hình hồ sơ
   - Xem và cập nhật thông tin cá nhân
   - Tải lên hoặc thay đổi ảnh hồ sơ
   - Lưu thay đổi để cập nhật hồ sơ

4. **Quản lý tài khoản**:
   - Thay đổi mật khẩu hoặc thông tin đăng nhập
   - Đăng xuất khỏi tài khoản
   - Xem tiến độ đồng bộ hóa

## 2. Thiết kế và Tech Stack

### Kiến trúc
Tính năng Auth được xây dựng theo mô hình Clean Architecture với ba lớp chính:

1. **Domain Layer**:
   - Model: `User` - Mô hình dữ liệu cốt lõi đại diện cho người dùng với các thuộc tính như id, email, username
   - Được xây dựng bằng Freezed để hỗ trợ immutability và serialization

2. **Data Layer**:
   - `SupabaseService`: Xử lý tích hợp với Supabase cho authentication
   - `SocialAuthService`: Quản lý đăng nhập qua các nhà cung cấp xã hội
   - `AuthDialogService`: Dịch vụ hiển thị dialog xác thực

3. **Presentation Layer**:
   - `AuthBloc`, `AuthEvent`, `AuthState`: Quản lý trạng thái xác thực
   - `AuthDialog`: UI chính cho đăng nhập và đăng ký
   - `ProfileScreen`: UI quản lý thông tin người dùng
   - `EmailVerificationScreen`: UI xác thực email
   - Các widget tái sử dụng: `AuthButton`, `AuthTextField`

### Công nghệ sử dụng
- **Authentication Backend**: Supabase Auth
- **State Management**: Flutter BLoC
- **Data Serialization**: Freezed và JSON Serializable
- **Social Auth**: Google Sign-In, Facebook Auth, Sign-In with Apple
- **Secure Storage**: Supabase
- **UI Components**: Material Design widgets tùy chỉnh
- **Profile Image Management**: ImagePicker và Storage Service

### Luồng dữ liệu
1. Người dùng tương tác với UI trong Presentation Layer
2. Các sự kiện (Events) được gửi đến AuthBloc
3. AuthBloc xử lý các sự kiện và gọi các service liên quan
4. Các service (SupabaseService, SocialAuthService) thực hiện các hoạt động xác thực
5. Kết quả được chuyển trở lại AuthBloc dưới dạng trạng thái (State)
6. UI cập nhật theo trạng thái mới

### Tương tác với các tính năng khác
- **Settings**: Đồng bộ hóa UserPreferences cho người dùng
- **Companion Chat**: Đồng bộ hóa lịch sử chat của người dùng
- **Library**: Đồng bộ hóa thư viện sách và tiến độ đọc

## 3. Phát hiện chính

### Mô hình dữ liệu người dùng

#### User Model
User model được cài đặt bằng Freezed cho immutability và type-safety:

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    String? avatarUrl,
    String? socialProvider,
    @Default(UserPreferences()) UserPreferences preferences,
    @Default(UserLibrary()) UserLibrary library,
    @Default(UserAISettings()) UserAISettings aiSettings,
    @Default(false) bool isAnonymous,
    DateTime? lastSyncTime,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.anonymous() => const User(
        id: '',
        email: '',
        username: 'Anonymous User',
        isAnonymous: true,
      );
}
```

Thiết kế này có các ưu điểm:
1. **Immutability**: Đảm bảo an toàn trạng thái bằng các đối tượng không thay đổi
2. **Type-safety**: Cung cấp kiểm tra kiểu mạnh mẽ từ Dart
3. **Embedded models**: Chứa các mô hình con như UserPreferences, UserLibrary
4. **Serialization**: Hỗ trợ chuyển đổi giữa đối tượng và JSON

### Quản lý trạng thái xác thực

#### AuthBloc
AuthBloc quản lý toàn bộ luồng xác thực và trạng thái người dùng:

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseService _supabaseService;
  late final StreamSubscription<AuthState> _authStateSubscription;
  AuthState? _lastKnownState;
  final ChatService _chatService;
  final BookMetadataRepository _bookMetadataRepository;
  final UserPreferencesService _userPreferencesService;

  AuthBloc(
    this._supabaseService,
    this._chatService,
    this._bookMetadataRepository,
    this._userPreferencesService,
  ) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthUserUpdated>(_onAuthUserUpdated);

    // Initialize with cached state if available
    _initializeAuthState();

    // Listen to auth state changes
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.distinct().map((data) {
      // Logic to map auth state changes
    }).listen((authState) {
      // Handle auth state updates
    });
  }
  
  // Event handlers...
}
```

Thiết kế này cài đặt:
1. **Reactive auth state**: Lắng nghe thay đổi trạng thái xác thực từ Supabase
2. **Caching state**: Lưu trữ trạng thái xác thực để truy cập nhanh
3. **Event handling**: Xử lý các sự kiện xác thực khác nhau
4. **Service dependencies**: Tích hợp với các service khác để quản lý dữ liệu

#### AuthState
Các trạng thái xác thực được mô hình hóa rõ ràng bằng lớp trừu tượng:

```dart
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final app_models.User user;
  const AuthAuthenticated(this.user);
  @override
  List<Object> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object> get props => [message];
}
// Other auth states...
```

Cách tiếp cận này đảm bảo:
1. **Clearly defined states**: Các trạng thái xác thực được định nghĩa rõ ràng
2. **Type-safety**: Mọi trạng thái đều có cấu trúc dữ liệu riêng
3. **Testability**: Dễ dàng kiểm thử với Equatable comparison
4. **UI predictability**: Giao diện người dùng phản ứng nhất quán với các trạng thái xác định

### Đăng nhập xã hội

#### SocialAuthService
Đăng nhập xã hội được xử lý thông qua một service chuyên dụng:

```dart
@lazySingleton
class SocialAuthService {
  final supabase = Supabase.instance.client;
  final _googleSignIn = GoogleSignIn(/* config */);

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Could not get auth details from Google');
      }

      return await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  Future<AuthResponse?> signInWithFacebook() async {
    // Implementation for Facebook login
  }

  Future<AuthResponse?> signInWithApple() async {
    // Implementation for Apple login
  }

  Future<void> signOut() async {
    // Sign out from all providers
  }
}
```

Service này cung cấp:
1. **Multiple providers**: Hỗ trợ nhiều nhà cung cấp xác thực xã hội
2. **Error handling**: Xử lý lỗi mạnh mẽ cho các trường hợp đặc biệt
3. **Token management**: Quản lý token xác thực từ các nhà cung cấp
4. **Integration with Supabase**: Tích hợp liền mạch với Supabase Auth

### Giao diện xác thực 

#### AuthDialog
AuthDialog là điểm nhập chính cho luồng xác thực người dùng:

```dart
class AuthDialog extends StatefulWidget {
  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  late final SocialAuthService _socialAuthService;
  late final AnimationController _animationController;
  // Other state variables...

  @override
  Widget build(BuildContext context) {
    // UI implementation
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: DraggableScrollableSheet(
        // Sheet configuration
        builder: (context, scrollController) => Material(
          color: Colors.transparent,
          child: BlocListener<AuthBloc, AuthState>(
            // Bloc listener implementation
            child: AnimatedContainer(
              // UI component for auth form
            ),
          ),
        ),
      ),
    );
  }
  // Methods for handling auth flows...
}
```

Dialog này cung cấp:
1. **Smooth animations**: Hiệu ứng chuyển động mượt mà giữa các trạng thái
2. **Responsive layout**: Layout thích ứng với nhiều kích thước màn hình
3. **Form validation**: Xác thực đầu vào người dùng
4. **Multiple auth options**: Hỗ trợ đăng nhập qua email và các nền tảng xã hội

#### ProfileScreen
ProfileScreen cho phép người dùng quản lý hồ sơ của họ:

```dart
class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final ImageService _imageService;
  late final StorageService _storageService;
  // Other state variables...

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _buildProfileContent(context, state);
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, AuthAuthenticated state) {
    // Profile UI implementation
  }

  // Methods for profile management...
}
```

Màn hình này bao gồm các tính năng:
1. **Profile editing**: Cho phép chỉnh sửa tên người dùng
2. **Avatar management**: Tải lên và cắt ảnh đại diện
3. **Account actions**: Đặt lại mật khẩu, đăng xuất và xóa tài khoản
4. **Reactive UI**: Phản ứng với thay đổi trạng thái xác thực

### Xác minh email

#### EmailVerificationScreen
EmailVerificationScreen cung cấp UX sau quá trình đăng ký:

```dart
class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final Duration? autoDismissAfter;

  const EmailVerificationScreen({
    required this.email,
    this.autoDismissAfter,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flyAnimation;
  // Other animations...

  @override
  Widget build(BuildContext context) {
    // Animated email verification UI
  }
}

// Custom painter for animated path
class PathPainter extends CustomPainter {
  // Implementation of animated path
}
```

Màn hình này cung cấp:
1. **Engaging animations**: Hiệu ứng động hấp dẫn cho quá trình xác minh
2. **Clear instructions**: Hướng dẫn rõ ràng về các bước tiếp theo
3. **Auto-dismiss**: Tùy chọn đóng tự động sau một khoảng thời gian
4. **Email link**: Khả năng mở ứng dụng email

### Quá trình đăng xuất thông minh

Khi người dùng đăng xuất, AuthBloc xử lý xóa dữ liệu an toàn:

```dart
Future<void> _onAuthSignOutRequested(
  AuthSignOutRequested event,
  Emitter<AuthState> emit,
) async {
  try {
    emit(AuthLoading());

    // Cancel existing subscription first
    await _authStateSubscription.cancel();

    // Clear all local user data
    await Future.wait([
      _chatService.clearAllData(),
      _bookMetadataRepository.clear(),
      _userPreferencesService.clear(),
    ]);

    // Sign out from Supabase
    await _supabaseService.signOut();

    // Reset the last known state
    _lastKnownState = AuthUnauthenticated();
    emit(_lastKnownState!);

    // Reinitialize auth state subscription
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange
        .distinct()
        .map((data) {
      // Map auth state changes
    }).listen((authState) {
      // Handle auth state updates
    });
  } catch (e) {
    emit(AuthFailure(e.toString()));
  }
}
```

Quá trình này đảm bảo:
1. **Data cleanup**: Xóa dữ liệu cục bộ trước khi đăng xuất
2. **Secure logout**: Đảm bảo đăng xuất từ Supabase
3. **State reset**: Đặt lại trạng thái xác thực
4. **Stream management**: Quản lý subscription để lắng nghe trạng thái mới

### Widget tái sử dụng

#### AuthButton
Widget button tùy chỉnh cho các hành động xác thực:

```dart
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const AuthButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Button UI implementation
  }
}
```

#### AuthTextField
Trường nhập liệu tùy chỉnh cho xác thực:

```dart
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? helperText;
  final bool autofocus;
  final bool enabled;

  const AuthTextField({
    required this.controller,
    required this.labelText,
    // Other parameters...
  });

  @override
  Widget build(BuildContext context) {
    // Text field UI implementation
  }
}
```

Những widget này cung cấp:
1. **Consistent styling**: Giao diện nhất quán trong toàn bộ luồng xác thực
2. **Loading states**: Trạng thái tải tích hợp
3. **Validation**: Xác thực đầu vào tích hợp
4. **Customization**: Tùy chỉnh linh hoạt cho các trường hợp sử dụng khác nhau

## Đánh giá tổng thể

### Điểm mạnh
1. **Kiến trúc chắc chắn**: Sử dụng BLoC pattern với separation of concerns rõ ràng
2. **Trải nghiệm người dùng mượt mà**: UI/UX hiện đại với animations và responsive design
3. **Đa dạng phương thức xác thực**: Hỗ trợ email/password và nhiều social providers
4. **Bảo mật cao**: Xác thực email và quản lý token an toàn
5. **Tích hợp sâu**: Kết nối liền mạch với các tính năng khác trong ứng dụng
6. **Khả năng mở rộng**: Cấu trúc dễ dàng thêm providers xác thực mới

### Hạn chế
1. **Phụ thuộc vào Supabase**: Tight coupling với Supabase có thể gây khó khăn khi muốn thay đổi provider
2. **Xử lý ngoại tuyến hạn chế**: Chưa có cơ chế xác thực ngoại tuyến mạnh mẽ
3. **Thiếu phương thức khôi phục**: Chức năng khôi phục mật khẩu chưa được triển khai đầy đủ

### Cải tiến tiềm năng
1. **Xác thực hai yếu tố**: Thêm bảo mật bổ sung với 2FA
2. **Xác thực sinh trắc học**: Tích hợp xác thực vân tay/khuôn mặt trên thiết bị hỗ trợ
3. **Cải thiện xác thực ngoại tuyến**: Cho phép đăng nhập khi không có kết nối
4. **Analytics và reporting**: Thêm theo dõi hành vi đăng nhập cho bảo mật
5. **Progressive authentication**: Yêu cầu xác thực bổ sung cho các hành động nhạy cảm

Tính năng Auth của Read Leaf cung cấp nền tảng an toàn và linh hoạt để quản lý danh tính người dùng, đồng thời hỗ trợ đồng bộ hóa dữ liệu liền mạch giữa các thiết bị. Kiến trúc module hóa và sự tách biệt rõ ràng giữa các lớp giúp dễ dàng mở rộng và bảo trì theo thời gian.

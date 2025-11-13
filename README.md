# 🎴 Flashcard App - Mobile MVP

Ứng dụng học tập với flashcard cho iOS và Android, được xây dựng bằng Flutter.

## ✨ Tính năng chính

### 📱 Màn hình đã hoàn thành

1. **Login Screen** - Đăng nhập với form validation
2. **Home Screen** - Quản lý bộ thẻ với stats overview
3. **Flashcard List Screen** - Danh sách thẻ trong bộ với CRUD
4. **Study Screen** - Học với flip animation 3D
5. **Stats Screen** - Thống kê học tập với charts

### 🎨 UI/UX Features

- ✅ Material Design 3
- ✅ Custom Theme System với Google Fonts (Inter)
- ✅ Responsive layouts
- ✅ Smooth animations (3D flip card)
- ✅ Dark/Light mode ready
- ✅ Beautiful charts (fl_chart)
- ✅ Interactive components

### 🔧 Technical Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: Riverpod 2.6.1
- **Navigation**: GoRouter 14.8.1
- **UI**: Google Fonts 6.2.1, fl_chart 0.69.2
- **Storage Ready**: SQLite, SharedPreferences
- **Network Ready**: Dio 5.7.0

## 📁 Cấu trúc Project

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart          # Color palette
│   ├── theme/
│   │   └── app_theme.dart           # Material Theme 3
│   ├── router/
│   │   └── app_router.dart          # GoRouter config
│   └── widgets/
│       ├── custom_button.dart       # Reusable button
│       ├── custom_card.dart         # Reusable card
│       └── loading_indicator.dart   # Loading widget
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── login_screen.dart
│   ├── home/
│   │   └── presentation/
│   │       └── home_screen.dart
│   ├── deck/
│   │   └── presentation/
│   │       └── flashcard_list_screen.dart
│   ├── study/
│   │   └── presentation/
│   │       └── study_screen.dart
│   └── stats/
│       └── presentation/
│           └── stats_screen.dart
└── main.dart
```

## 🚀 Cài đặt và Chạy

### Yêu cầu

- Flutter SDK 3.9.2 trở lên
- Dart 3.9.2 trở lên
- Android Studio / Xcode (cho emulator)

### Các bước chạy

```bash
# 1. Cài đặt dependencies
flutter pub get

# 2. Kiểm tra devices
flutter devices

# 3. Chạy app
flutter run

# Hoặc chạy trên emulator cụ thể:
flutter run -d android         # Android
flutter run -d ios             # iOS (chỉ trên macOS)
```

## 🎯 Hướng dẫn sử dụng

1. **Đăng nhập**: Nhập email và password (hiện tại chỉ là UI mock)
2. **Trang chủ**: Xem các bộ thẻ, stats, và streak
3. **Chi tiết bộ thẻ**: Xem danh sách flashcard, thêm/sửa/xóa
4. **Học tập**: Chạm để lật thẻ, đánh giá độ khó (Dễ/Khó/Học lại)
5. **Thống kê**: Xem biểu đồ hoạt động và tiến độ

## 📊 Mock Data

Hiện tại app sử dụng mock data để demo UI. Để kết nối với backend:

1. Tạo models trong `lib/features/[feature]/data/models/`
2. Tạo repositories trong `lib/features/[feature]/data/repositories/`
3. Sử dụng Riverpod providers để quản lý state
4. Kết nối API với Dio

## 🎨 Customization

### Thay đổi màu sắc

Chỉnh sửa `lib/core/constants/app_colors.dart`:

```dart
static const primary = Color(0xFF5E35B1);  // Màu chính
static const secondary = Color(0xFF26A69A); // Màu phụ
```

### Thay đổi font

Chỉnh sửa `lib/core/theme/app_theme.dart`:

```dart
textTheme: GoogleFonts.interTextTheme(), // Thay 'inter' bằng font khác
```

## 📝 TODO - Backend Integration

- [ ] Tích hợp API authentication
- [ ] CRUD operations với SQLite
- [ ] Spaced Repetition Algorithm (SRS)
- [ ] Sync data với server
- [ ] Offline mode với cache
- [ ] Push notifications
- [ ] Import/Export decks
- [ ] Shared decks feature

## 🎉 Ready to Run!

App đã sẵn sàng để chạy:

```bash
flutter run
```

---

Built with ❤️ using Flutter

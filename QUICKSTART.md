# 🚀 QUICK START GUIDE

## Chạy App Ngay (3 bước)

### Bước 1: Kiểm tra Flutter

```bash
flutter doctor
```

### Bước 2: Mở Emulator

- **Android Studio**: Tools → Device Manager → Start emulator
- **Xcode (macOS)**: Open Simulator
- **Hoặc kết nối điện thoại qua USB** (bật Developer Mode)

### Bước 3: Chạy!

```bash
flutter run
```

---

## 📱 Các màn hình có sẵn

### 1. Login Screen (`/login`)

- Email & password validation
- Responsive form
- Loading state

### 2. Home Screen (`/home`)

- 4 bộ thẻ mẫu
- Stats overview (Streak, Today, Total)
- Progress bar
- Pull to refresh
- Thêm/xóa bộ thẻ

### 3. Flashcard List (`/deck/:id`)

- Danh sách 5 thẻ mẫu
- CRUD operations (Add/Edit/Delete)
- Mastered badge
- Nút "Bắt đầu học"

### 4. Study Screen (`/study/:deckId`)

- 3D flip animation
- 3 nút đánh giá (Dễ/Khó/Học lại)
- Progress bar
- Completion dialog với kết quả

### 5. Stats Screen (`/stats`)

- Bar chart (7 ngày hoạt động)
- Pie chart (tiến độ học tập)
- Thời gian học
- Best streak

---

## 🎨 Màu sắc & Theme

### Primary Colors

- **Primary**: `#5E35B1` (Purple)
- **Secondary**: `#26A69A` (Teal)
- **Success**: `#66BB6A` (Green)
- **Warning**: `#FFB74D` (Orange)
- **Error**: `#EF5350` (Red)

### Font

- **Google Fonts**: Inter (all weights)

---

## 🛠️ Troubleshooting

### Lỗi thường gặp:

**1. "No devices found"**

```bash
# Kiểm tra devices
flutter devices

# Khởi động emulator
flutter emulators --launch <emulator_id>
```

**2. "Packages not found"**

```bash
flutter pub get
flutter clean
flutter pub get
```

**3. "Build failed"**

```bash
flutter clean
flutter pub get
flutter run
```

**4. Hot reload không work**

- Nhấn `r` trong terminal để hot reload
- Nhấn `R` để hot restart
- Hoặc tắt app và `flutter run` lại

---

## 📋 Commands hữu ích

```bash
# Xem logs chi tiết
flutter run -v

# Chạy ở release mode (nhanh hơn)
flutter run --release

# Build APK (Android)
flutter build apk

# Build iOS (macOS only)
flutter build ios

# Kiểm tra code
flutter analyze

# Format code
flutter format lib/

# Clean build
flutter clean
```

---

## 🎯 Next Steps

### Thêm tính năng mới:

1. Vào `lib/features/` tạo folder mới
2. Copy structure từ feature có sẵn
3. Update `app_router.dart` để thêm route
4. Done!

### Kết nối Backend:

1. Tạo models trong `data/models/`
2. Tạo repositories trong `data/repositories/`
3. Setup Riverpod providers
4. Call API với Dio

---

## 💡 Tips

- **Hot Reload**: `r` - Cực nhanh, giữ state
- **Hot Restart**: `R` - Restart app, mất state
- **Open DevTools**: `Shift + D` trong terminal
- **Toggle Inspector**: FloatingActionButton trong app

---

## 🆘 Cần trợ giúp?

1. Đọc error message trong terminal
2. Google error message
3. Check Flutter docs: https://docs.flutter.dev
4. Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

**Happy Coding! 🎉**

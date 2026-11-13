// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Up Escape Mind';

  @override
  String get appTagline =>
      'Trò chơi giải đố thoát hiểm, chơi hoàn toàn ngoại tuyến.';

  @override
  String get menuContinue => 'Tiếp tục';

  @override
  String get menuNewGame => 'Chơi mới';

  @override
  String get menuChapters => 'Chương';

  @override
  String get menuSettings => 'Cài đặt';

  @override
  String get menuCredits => 'Ghi công';

  @override
  String get chaptersTitle => 'Các chương';

  @override
  String get chapterLocked => 'Đã khóa';

  @override
  String get chapterAvailable => 'Có thể chơi';

  @override
  String get chapterInProgress => 'Đang chơi';

  @override
  String get chapterCompleted => 'Đã hoàn thành';

  @override
  String get noSaveExists =>
      'Chưa có dữ liệu lưu. Bắt đầu trò chơi mới để chơi.';

  @override
  String get newGameConfirmTitle => 'Bắt đầu trò chơi mới?';

  @override
  String get newGameConfirmBody =>
      'Thao tác này sẽ thay thế dữ liệu lưu hiện tại.';

  @override
  String get journalTitle => 'Nhật ký';

  @override
  String get journalEmpty =>
      'Chưa có khám phá nào. Ghi chú và manh mối bạn tìm thấy sẽ xuất hiện ở đây.';

  @override
  String get errorGeneric => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsMusic => 'Nhạc nền';

  @override
  String get settingsSoundEffects => 'Hiệu ứng âm thanh';

  @override
  String get settingsHaptics => 'Rung phản hồi';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get languageSystemDefault => 'Theo hệ thống';

  @override
  String get settingsResetProgress => 'Đặt lại tiến trình';

  @override
  String get resetProgressConfirmTitle => 'Đặt lại toàn bộ tiến trình?';

  @override
  String get resetProgressConfirmBody =>
      'Thao tác này xóa vĩnh viễn dữ liệu lưu. Không thể hoàn tác.';

  @override
  String get resetProgressDone => 'Tiến trình đã được đặt lại.';

  @override
  String get creditsTitle => 'Ghi công';

  @override
  String get creditsBody =>
      'Up Escape Mind — trò chơi phiêu lưu giải đố một người chơi, chơi ngoại tuyến.';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String get roomLockedMessage => 'Khu vực này vẫn đang bị khóa.';

  @override
  String get puzzleLockedMessage => 'Câu đố này chưa thể mở ra lúc này.';

  @override
  String get puzzleIncorrectMessage => 'Chưa chính xác. Hãy thử lại.';

  @override
  String get puzzleSolvedMessage => 'Chính xác! Câu đố đã được giải.';

  @override
  String get keypadClear => 'Xóa hết';

  @override
  String get keypadDelete => 'Xóa';

  @override
  String itemCollectedMessage(String name) {
    return 'Đã nhặt được $name.';
  }

  @override
  String alreadyHaveItemMessage(String name) {
    return 'Bạn đã có $name rồi.';
  }

  @override
  String clueDiscoveredMessage(String title) {
    return 'Manh mối mới trong Nhật ký: $title.';
  }

  @override
  String get inventoryTitle => 'Hành trang';

  @override
  String get inventoryEmpty =>
      'Hành trang trống. Vật phẩm nhặt được sẽ xuất hiện ở đây.';

  @override
  String get itemUseAction => 'Sử dụng';

  @override
  String get itemDeselectAction => 'Bỏ chọn';

  @override
  String get itemCombineAction => 'Kết hợp';

  @override
  String get combineExitAction => 'Xong';

  @override
  String get combineNeedsSelection => 'Chọn ít nhất hai vật phẩm để kết hợp.';

  @override
  String get invalidItemUseMessage => 'Món này không có tác dụng ở đây.';

  @override
  String get invalidCombinationMessage => 'Các vật phẩm này không thể kết hợp.';

  @override
  String itemUsedMessage(String item) {
    return 'Bạn sử dụng $item.';
  }

  @override
  String itemUsingHint(String item) {
    return 'Đang dùng $item — chạm vào một điểm trong phòng.';
  }
}

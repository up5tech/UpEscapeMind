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
  String get puzzleCheck => 'Kiểm tra';

  @override
  String get puzzleReset => 'Đặt lại';

  @override
  String get leverUp => 'Lên';

  @override
  String get leverDown => 'Xuống';

  @override
  String observationProgress(int found, int total) {
    return 'Đã tìm thấy $found/$total.';
  }

  @override
  String get hintsAction => 'Gợi ý';

  @override
  String get hintsTitle => 'Gợi ý';

  @override
  String hintLevelTitle(int level) {
    return 'Gợi ý $level';
  }

  @override
  String get hintNextButton => 'Xem gợi ý tiếp theo';

  @override
  String get hintWalkthroughConfirmTitle => 'Xem bài giải từng bước?';

  @override
  String get hintWalkthroughConfirmBody =>
      'Gợi ý cấp 3 sẽ hướng dẫn giải từng bước. Việc dùng gợi ý không ảnh hưởng đến tiến trình hay đánh giá của bạn.';

  @override
  String get prereqMissingPuzzle => 'Hãy giải một câu đố khác trước.';

  @override
  String get prereqMissingItem => 'Bạn vẫn cần tìm thêm một vật phẩm.';

  @override
  String get prereqMissingItemUse =>
      'Bạn cần dùng đúng vật phẩm ở một nơi khác trước đã.';

  @override
  String get prereqMissingClue => 'Nhật ký của bạn vẫn thiếu một manh mối.';

  @override
  String get prereqMissingArea => 'Một khu vực vẫn đang bị khóa.';

  @override
  String get prereqMissingChapter => 'Bạn cần hoàn thành một chương trước.';

  @override
  String get summaryTitle => 'Hoàn thành chương!';

  @override
  String get summaryAreas => 'Khu vực';

  @override
  String get statsTitle => 'Thống kê';

  @override
  String get summaryStarsLabel => 'Đánh giá';

  @override
  String get starRuleOne => 'Hoàn thành mục tiêu cuối của chương.';

  @override
  String get starRuleTwo => 'Giải mọi câu đố, kể cả câu đố tùy chọn.';

  @override
  String get starRuleThree =>
      'Tìm mọi manh mối, mẩu ghi chú và bí mật, kể cả loại tùy chọn.';

  @override
  String get badgeNoWalkthrough => 'Không dùng bài giải từng bước';

  @override
  String get viewSummary => 'Xem tổng kết';

  @override
  String get statChaptersCompleted => 'Chương đã hoàn thành';

  @override
  String statAreasDiscovered(int found, int total) {
    return 'Khu vực đã khám phá: $found/$total';
  }

  @override
  String statPuzzlesSolved(int found, int total) {
    return 'Câu đố đã giải: $found/$total';
  }

  @override
  String statOptionalCluesFound(int found, int total) {
    return 'Manh mối tùy chọn đã tìm: $found/$total';
  }

  @override
  String statHintsLevel(int level, int count) {
    return 'Gợi ý đã mở cấp $level: $count';
  }

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

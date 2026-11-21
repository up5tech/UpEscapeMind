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
  String get creditsArtTitle => 'Hình ảnh';

  @override
  String get creditsArtBody =>
      'Toàn bộ hình ảnh là nguyên bản, được tạo riêng cho Up Escape Mind.';

  @override
  String get creditsAudioTitle => 'Âm thanh';

  @override
  String get creditsAudioBody =>
      'Phiên bản 1.0.0 chưa có âm thanh. Nhạc nền và hiệu ứng âm thanh dự kiến sẽ có trong bản cập nhật sau.';

  @override
  String get creditsTechTitle => 'Công nghệ';

  @override
  String get creditsTechBody =>
      'Được xây dựng bằng Flutter. Trò chơi chơi hoàn toàn ngoại tuyến — không tài khoản, không quảng cáo, không cần Internet.';

  @override
  String get creditsLicensesAction => 'Giấy phép mã nguồn mở';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonNext => 'Tiếp';

  @override
  String get prologueCard1 =>
      'Bạn tỉnh dậy trên sàn dinh thự Meridian. Mọi chiếc đồng hồ đều đã dừng — mỗi chiếc một giờ khác nhau.';

  @override
  String get prologueCard2 =>
      '\"Kho lưu trữ giữ lại điều ngôi nhà lãng quên. — E.V.\"';

  @override
  String get prologueCard3 =>
      'Có người đã sắp xếp tất cả những điều này cho bạn. Hãy bắt đầu tìm.';

  @override
  String get prologueSkip => 'Bỏ qua';

  @override
  String get prologueEnter => 'Bước vào ngôi nhà';

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
  String get rotationDecrease => 'Xoay ngược chiều kim đồng hồ';

  @override
  String get rotationIncrease => 'Xoay theo chiều kim đồng hồ';

  @override
  String get leverUp => 'Lên';

  @override
  String get leverDown => 'Xuống';

  @override
  String observationProgress(int found, int total) {
    return 'Đã tìm thấy $found/$total.';
  }

  @override
  String tapRegionOption(int index) {
    return 'Mục tiêu $index';
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

  @override
  String get menuHowToPlay => 'Cách chơi';

  @override
  String get howToPlayTitle => 'Cách chơi';

  @override
  String get howToPlayExplore =>
      'Chạm vào các điểm sáng trong phòng để khám phá manh mối, vật phẩm và câu đố.';

  @override
  String get howToPlayItems =>
      'Vật phẩm nằm trong Hành trang: chọn “Sử dụng” rồi chạm vào điểm trong phòng, hoặc “Kết hợp” nhiều vật phẩm.';

  @override
  String get howToPlayHints =>
      'Nút bóng đèn trong câu đố mở gợi ý 3 cấp — gợi ý không bao giờ bắt buộc.';

  @override
  String get howToPlayJournal =>
      'Mọi manh mối và ghi chú được lưu trong Nhật ký.';

  @override
  String get howToPlayStart => 'Bắt đầu khám phá';

  @override
  String get guideRoomExplore =>
      'Chạm vào các điểm sáng để khám phá căn phòng.';

  @override
  String get guideRoomDismiss => 'Đã hiểu';

  @override
  String get guideChaptersPick => 'Chạm vào một khu vực để vào chơi.';

  @override
  String get guidePuzzleKeypad =>
      'Chạm các số để nhập mã — đủ số sẽ tự kiểm tra.';

  @override
  String get guidePuzzleSymbolMatching =>
      'Chạm ô để chọn biểu tượng đúng, rồi nhấn Kiểm tra.';

  @override
  String get guidePuzzleSequence =>
      'Chạm ứng viên để xếp vào các ô theo thứ tự, rồi nhấn Kiểm tra.';

  @override
  String get guidePuzzleRotation =>
      'Kéo hoặc chạm vòng để xoay về đúng góc, rồi nhấn Kiểm tra.';

  @override
  String get guidePuzzleLogicDeduction =>
      'Điền đáp án cho từng dòng, rồi nhấn Kiểm tra.';

  @override
  String get guidePuzzleMechanicalState =>
      'Gạt các cần về đúng vị trí, rồi nhấn Kiểm tra.';

  @override
  String get guidePuzzleTapRegion => 'Chạm vào các điểm ẩn để tìm đủ mục tiêu.';

  @override
  String get roomZoomAction => 'Phóng to khung cảnh';

  @override
  String get roomZoomHint => 'Chụm để phóng to · kéo để di chuyển';

  @override
  String get roomLabelsShowAction => 'Hiện tên vật';

  @override
  String get roomLabelsHideAction => 'Ẩn tên vật';

  @override
  String get clueSavedToJournal => 'Đã lưu vào Nhật ký.';
}

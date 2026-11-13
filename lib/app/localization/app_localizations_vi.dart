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
  String get chapter1Title => 'Kho Lưu Trữ của Thợ Làm Đồng Hồ';

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
  String get roomEntranceTitle => 'Sảnh Chính';

  @override
  String get roomStudyTitle => 'Phòng Nghiên Cứu của Thợ Làm Đồng Hồ';

  @override
  String get roomWorkshopTitle => 'Xưởng';

  @override
  String get roomGalleryTitle => 'Phòng Chân Dung';

  @override
  String get roomObservatoryTitle => 'Đài Thiên Văn Phong Ấn';

  @override
  String get chapterSampleTitle => 'Chương Mẫu (dữ liệu thử)';

  @override
  String get roomSampleTitle => 'Phòng Mẫu';

  @override
  String get roomSampleDescription =>
      'Một căn phòng tối giản dùng để kiểm tra hệ thống nội dung.';

  @override
  String get roomSampleExitTitle => 'Phòng Mẫu — Lối Ra';

  @override
  String get hotspotSampleNote => 'Một mẩu ghi chú';

  @override
  String get hotspotSampleNoteDesc => 'Một mẩu giấy gấp nằm trên bàn.';

  @override
  String get hotspotSamplePlaque => 'Một tấm biển';

  @override
  String get hotspotSampleKeyDrawer => 'Ngăn kéo chìa khóa';

  @override
  String get hotspotSampleGearDrawer => 'Ngăn kéo bánh răng';

  @override
  String get hotspotSampleDoorLock => 'Ổ khóa cửa';

  @override
  String get hotspotSampleExitDoor => 'Cửa bên';

  @override
  String get hotspotSampleExitBack => 'Đường quay lại';

  @override
  String get exitSampleForward => 'Đi tiếp';

  @override
  String get exitSampleBack => 'Quay lại';

  @override
  String get puzzleSampleLockTitle => 'Ổ Khóa Mẫu';

  @override
  String get puzzleSampleLockInstructions => 'Nhập mã số gồm bốn chữ số.';

  @override
  String get puzzleSampleLockHint1 =>
      'Hãy nhìn quanh căn phòng để tìm các chữ số.';

  @override
  String get puzzleSampleLockHint2 =>
      'Tấm biển cạnh cửa hiển thị hai chữ số đầu.';

  @override
  String get puzzleSampleLockHint3 => 'Mã: 4 - 2 - 7 - 1.';

  @override
  String get itemSampleKeyName => 'Chìa Khóa Nhỏ';

  @override
  String get itemSampleKeyDesc => 'Một chìa khóa đồng nhỏ, vẫn còn ấm.';

  @override
  String get itemSampleGearName => 'Bánh Răng Đồng';

  @override
  String get itemSampleGearDesc => 'Một bánh răng đơn lẻ từ cơ cấu cũ.';

  @override
  String get itemSampleHookName => 'Móc & Chìa';

  @override
  String get itemSampleHookDesc =>
      'Dụng cụ kết hợp: chìa khóa gắn trên bánh răng.';

  @override
  String get combinationSampleHookMessage =>
      'Bạn gắn bánh răng vào chìa khóa, tạo thành dụng cụ có móc.';

  @override
  String get clueSampleNoteTitle => 'Ghi Chú Lề';

  @override
  String get clueSampleNoteBody =>
      'Người thợ làm đồng hồ viết: \'Thời gian là ổ khóa, không phải dòng sông.\'';

  @override
  String get clueSampleLockOpenedTitle => 'Ổ Khóa Mở Ra';

  @override
  String get clueSampleLockOpenedBody =>
      'Bên trong bảng điều khiển: một ổ khóa nhỏ hơn nữa.';

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
}

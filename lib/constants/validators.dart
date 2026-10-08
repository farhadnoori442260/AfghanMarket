import 'package:easy_localization/easy_localization.dart';

/// اعتبارسنجی ایمیل
String? validateEmail(String? value, bool isValid) {
  if (value == null || value.trim().isEmpty) {
    return 'validation_enter_email'.tr();
  }
  if (!isValid) {
    return 'validation_invalid_email'.tr();
  }
  return null;
}

/// اعتبارسنجی رمز عبور
String? validatePassword(String? value, String email) {
  if (email.trim().isNotEmpty) {
    if (value == null || value.isEmpty) {
      return 'validation_enter_password'.tr();
    }
    if (value.length < 6) {
      return 'validation_short_password'.tr();
    }
  }
  return null;
}

/// اعتبارسنجی تکرار رمز عبور
String? validateSamePassword(String? value, String? password) {
  if (value == null || value.isEmpty) {
    return 'validation_enter_confirm_password'.tr();
  }
  if (value != password) {
    return 'validation_password_mismatch'.tr();
  }
  return null;
}

/// اعتبارسنجی سال ساخت/خرید (مثلاً خودرو یا ملک)
String? validateYear(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'validation_enter_year'.tr();
  }
  final int? year = int.tryParse(value.trim());
  final int currentYear = DateTime.now().year;

  if (year == null || year < 1950 || year > (currentYear + 1)) {
    return 'validation_invalid_year'.tr();
  }
  return null;
}

/// اعتبارسنجی قیمت
String? validatePrice(String? value) {
  return checkNullEmptyValidation(value, 'field_price'.tr());
}

/// اعتبارسنجی شماره موبایل افغانستان (مثال: 0791234567 یا 791234567)
String? validateMobile(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'validation_enter_phone'.tr();
  }
  
  final cleanPhone = value.trim().replaceAll(' ', '');
  final phoneRegex = RegExp(r'^(07|7|00937|\+937)[0-9]{8}$');

  if (!phoneRegex.hasMatch(cleanPhone)) {
    return 'validation_invalid_phone'.tr();
  }
  return null;
}

/// اعتبارسنجی کلی برای فیلدهای خالی
String? checkNullEmptyValidation(String? value, String fieldTitle) {
  if (value == null || value.trim().isEmpty) {
    return 'validation_field_required'.tr(args: [fieldTitle]);
  }
  return null;
}

/// فرمت‌کننده اعداد و قیمت‌ها (سه‌رقم سه‌رقم)
String formatPrice(dynamic value) {
  if (value == null) return '0';
  final num? parsed = num.tryParse(value.toString());
  if (parsed == null) return value.toString();
  
  final formatter = NumberFormat("#,##0", "en_US");
  return formatter.format(parsed);
}

/// فرمت‌کننده زمان
String formattedTime(int? microsecondsSinceEpoch) {
  if (microsecondsSinceEpoch == null) return '';
  final date = DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
  return DateFormat.yMMMd().format(date);
}

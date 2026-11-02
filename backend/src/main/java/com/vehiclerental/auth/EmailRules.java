package com.vehiclerental.auth;

/** Quy tắc định dạng email dùng chung. Đuôi tên miền phải nằm trong danh sách phổ biến (thêm đuôi mới vào cuối danh sách). */
public final class EmailRules {

    public static final String REGEX =
            "(?i)^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.(com|net|org|edu|gov|info|biz|io|co|me|dev|app|xyz|vn|us|uk|jp|kr|cn|fr|de|au|ca|sg|th|tw|hk|in|ru)$";

    private EmailRules() {
    }
}

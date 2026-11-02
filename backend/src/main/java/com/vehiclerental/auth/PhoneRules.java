package com.vehiclerental.auth;

/** Số điện thoại di động Việt Nam: 10 số, đầu số 03, 05, 07, 08 hoặc 09. */
public final class PhoneRules {

    public static final String REGEX = "^(03|05|07|08|09)\\d{8}$";

    private PhoneRules() {
    }
}

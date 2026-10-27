-- Vehicle Rental System - schema generated from the supplied DBML / dbdiagram (21 tables)
-- PostgreSQL 13+ (gen_random_uuid is built in)

CREATE TABLE roles (
  id bigserial PRIMARY KEY,
  name varchar(30) NOT NULL UNIQUE,
  description varchar(255),
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id bigint NOT NULL REFERENCES roles(id),
  full_name varchar(150) NOT NULL,
  email varchar(150) NOT NULL UNIQUE,
  phone varchar(20),
  password_hash varchar(100) NOT NULL,
  status varchar(20) NOT NULL,
  email_verified boolean NOT NULL DEFAULT FALSE,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE refresh_tokens (
  id bigserial PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token varchar(500) NOT NULL UNIQUE,
  expires_at timestamp NOT NULL,
  revoked boolean NOT NULL DEFAULT FALSE,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE user_profiles (
  id bigserial PRIMARY KEY,
  user_id uuid NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  avatar_url varchar(500),
  date_of_birth date,
  gender varchar(10),
  id_card_number varchar(30),
  driver_license_number varchar(30),
  bio varchar(1000),
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE addresses (
  id bigserial PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  label varchar(50) NOT NULL,
  address_line varchar(255) NOT NULL,
  ward varchar(100),
  district varchar(100),
  city varchar(100) NOT NULL,
  country varchar(100) NOT NULL,
  postal_code varchar(20),
  is_default boolean NOT NULL DEFAULT FALSE,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE brands (
  id bigserial PRIMARY KEY,
  name varchar(100) NOT NULL UNIQUE,
  logo_url varchar(500),
  country varchar(100),
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE categories (
  id bigserial PRIMARY KEY,
  name varchar(100) NOT NULL UNIQUE,
  description varchar(255),
  icon_url varchar(500),
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES users(id),
  brand_id bigint NOT NULL REFERENCES brands(id),
  category_id bigint NOT NULL REFERENCES categories(id),
  model varchar(100) NOT NULL,
  license_plate varchar(20) NOT NULL UNIQUE,
  color varchar(30),
  transmission varchar(20) NOT NULL,
  fuel_type varchar(20) NOT NULL,
  seats smallint NOT NULL,
  year smallint NOT NULL,
  mileage integer NOT NULL,
  price_per_day numeric(12,2) NOT NULL,
  security_deposit numeric(12,2) NOT NULL,
  description varchar(2000),
  status varchar(20) NOT NULL,
  average_rating numeric(3,2) NOT NULL DEFAULT 0,
  total_reviews integer NOT NULL DEFAULT 0,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE vehicle_images (
  id bigserial PRIMARY KEY,
  vehicle_id uuid NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  image_url varchar(500) NOT NULL,
  is_primary boolean NOT NULL DEFAULT FALSE,
  display_order smallint NOT NULL DEFAULT 0,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE vehicle_features (
  id bigserial PRIMARY KEY,
  vehicle_id uuid NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  feature_name varchar(100) NOT NULL,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE vehicle_locations (
  id bigserial PRIMARY KEY,
  vehicle_id uuid NOT NULL UNIQUE REFERENCES vehicles(id) ON DELETE CASCADE,
  latitude numeric(10,7) NOT NULL,
  longitude numeric(10,7) NOT NULL,
  speed numeric(6,2) NOT NULL,
  heading numeric(5,2) NOT NULL,
  accuracy numeric(6,2) NOT NULL,
  last_updated timestamp NOT NULL DEFAULT now()
);

CREATE TABLE maintenance_records (
  id bigserial PRIMARY KEY,
  vehicle_id uuid NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  maintenance_type varchar(100) NOT NULL,
  description varchar(1000),
  cost numeric(12,2) NOT NULL,
  performed_at timestamp NOT NULL,
  next_due_at timestamp,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE coupons (
  id bigserial PRIMARY KEY,
  code varchar(30) NOT NULL UNIQUE,
  description varchar(255),
  discount_type varchar(20) NOT NULL,
  discount_value numeric(12,2) NOT NULL,
  max_discount numeric(12,2),
  min_order_amount numeric(12,2) NOT NULL,
  usage_limit integer NOT NULL,
  used_count integer NOT NULL DEFAULT 0,
  valid_from timestamp NOT NULL,
  valid_to timestamp NOT NULL,
  is_active boolean NOT NULL DEFAULT TRUE,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES users(id),
  vehicle_id uuid NOT NULL REFERENCES vehicles(id),
  coupon_id bigint REFERENCES coupons(id),
  pickup_datetime timestamp NOT NULL,
  return_datetime timestamp NOT NULL,
  pickup_location varchar(255) NOT NULL,
  return_location varchar(255) NOT NULL,
  total_days integer NOT NULL,
  subtotal numeric(12,2) NOT NULL,
  discount numeric(12,2) NOT NULL DEFAULT 0,
  tax numeric(12,2) NOT NULL DEFAULT 0,
  total_amount numeric(12,2) NOT NULL,
  status varchar(20) NOT NULL,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE booking_status_history (
  id bigserial PRIMARY KEY,
  booking_id uuid NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  status varchar(20) NOT NULL,
  changed_by uuid REFERENCES users(id) ON DELETE SET NULL,
  note varchar(500),
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE payment_methods (
  id bigserial PRIMARY KEY,
  code varchar(30) NOT NULL UNIQUE,
  name varchar(50) NOT NULL,
  is_active boolean NOT NULL DEFAULT TRUE
);

CREATE TABLE payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES bookings(id),
  payment_method_id bigint NOT NULL REFERENCES payment_methods(id),
  amount numeric(12,2) NOT NULL,
  status varchar(20) NOT NULL,
  transaction_ref varchar(100) UNIQUE,
  paid_at timestamp,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL UNIQUE REFERENCES bookings(id),
  customer_id uuid NOT NULL REFERENCES users(id),
  vehicle_id uuid NOT NULL REFERENCES vehicles(id),
  rating smallint NOT NULL,
  comment varchar(1000),
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE favorites (
  id bigserial PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vehicle_id uuid NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE notifications (
  id bigserial PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title varchar(150) NOT NULL,
  message varchar(1000) NOT NULL,
  type varchar(30) NOT NULL,
  is_read boolean NOT NULL DEFAULT FALSE,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE audit_logs (
  id bigserial PRIMARY KEY,
  user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  action varchar(50) NOT NULL,
  entity_type varchar(50) NOT NULL,
  entity_id varchar(100),
  old_data jsonb,
  new_data jsonb,
  ip_address varchar(45),
  created_at timestamp NOT NULL DEFAULT now()
);


-- Extra constraints / indexes (not drawn in the diagram, recommended for the application)
ALTER TABLE favorites ADD CONSTRAINT uq_favorites_user_vehicle UNIQUE (user_id, vehicle_id);
ALTER TABLE vehicle_features ADD CONSTRAINT uq_vehicle_feature UNIQUE (vehicle_id, feature_name);
ALTER TABLE reviews ADD CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5);
ALTER TABLE bookings ADD CONSTRAINT chk_bookings_period CHECK (return_datetime > pickup_datetime);
ALTER TABLE vehicles ADD CONSTRAINT chk_vehicles_price CHECK (price_per_day >= 0);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_vehicles_owner ON vehicles(owner_id);
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_vehicles_brand ON vehicles(brand_id);
CREATE INDEX idx_vehicles_category ON vehicles(category_id);
CREATE INDEX idx_vehicle_images_vehicle ON vehicle_images(vehicle_id);
CREATE INDEX idx_bookings_customer ON bookings(customer_id);
CREATE INDEX idx_bookings_vehicle_period ON bookings(vehicle_id, pickup_datetime, return_datetime);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_payments_booking ON payments(booking_id);
CREATE INDEX idx_reviews_vehicle ON reviews(vehicle_id);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);

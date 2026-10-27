-- Reference data
INSERT INTO roles(name, description) VALUES ('CUSTOMER','Registered customer. Can rent vehicles and also list own vehicles (owner capability).'),('ADMIN','System administrator.');
INSERT INTO brands(name, country) VALUES ('Toyota','Japan'),('Honda','Japan'),('Mazda','Japan'),('Hyundai','South Korea'),('Kia','South Korea'),('VinFast','Vietnam'),('Ford','USA'),('Mercedes-Benz','Germany'),('BMW','Germany'),('Tesla','USA'),('Yamaha','Japan'),('Suzuki','Japan');
INSERT INTO categories(name, description) VALUES ('Sedan','Comfortable 4-5 seat city and highway cars'),('SUV','Spacious vehicles for family trips'),('Hatchback','Compact cars for the city'),('MPV','7-seat family vehicles'),('Pickup','Pickup trucks'),('Luxury','Premium vehicles'),('Electric','Battery electric vehicles'),('Motorbike','Motorbikes and scooters');
INSERT INTO payment_methods(code, name, is_active) VALUES ('CASH','Cash on pickup',TRUE),('BANK_TRANSFER','Bank transfer',TRUE),('CREDIT_CARD','Credit / debit card (demo)',TRUE),('MOMO','MoMo e-wallet (demo)',TRUE),('VNPAY','VNPay (demo)',TRUE);
INSERT INTO coupons(code, description, discount_type, discount_value, max_discount, min_order_amount, usage_limit, used_count, valid_from, valid_to, is_active) VALUES
 ('WELCOME10','10% off your first rental','PERCENT',10,200000,500000,1000,0, now() - interval '1 day', now() + interval '365 days', TRUE),
 ('SUMMER20','20% off, up to 500,000 VND','PERCENT',20,500000,1500000,500,0, now() - interval '1 day', now() + interval '180 days', TRUE),
 ('SAVE100K','100,000 VND off any booking','FIXED',100000,NULL,800000,300,0, now() - interval '1 day', now() + interval '90 days', TRUE);

CREATE DATABASE The_Nest;
USE The_Nest;

-- Table for Community
CREATE TABLE Community
(
    c_id INTEGER PRIMARY KEY,
    c_name VARCHAR(255) NOT NULL UNIQUE, -- Added UNIQUE constraint for foreign key reference
    c_address VARCHAR(255),
    c_zip INTEGER NOT NULL,
    c_city VARCHAR(255),
    c_description VARCHAR(1000),
    c_units INTEGER
);

-- Table for Admins
CREATE TABLE Admins
(
    admin_id INTEGER PRIMARY KEY,
    admin_name VARCHAR(255) NOT NULL,
    admin_email VARCHAR(255) NOT NULL UNIQUE,
    admin_role VARCHAR(255) NOT NULL
);

-- Table for Tenants
CREATE TABLE Tenants 
( 
    u_phone VARCHAR(10) NOT NULL, 
    u_name VARCHAR(255) NOT NULL, 
    u_email VARCHAR(255) NOT NULL UNIQUE -- Ensures u_email is valid for foreign key reference
);

-- Table for Property
CREATE TABLE Property
(
    p_id INTEGER PRIMARY KEY,
    p_type VARCHAR(12) NOT NULL,
    p_rent INTEGER NOT NULL,
    p_availability VARCHAR(12) NOT NULL,
    p_furnish_status VARCHAR(20),
    p_description VARCHAR(350),
    c_id INTEGER NOT NULL,  -- Added NOT NULL for proper referencing
    admin_id INTEGER NOT NULL,  -- Added NOT NULL for proper referencing
    FOREIGN KEY (c_id) REFERENCES Community(c_id), 
    FOREIGN KEY (admin_id) REFERENCES Admins(admin_id)
);

-- Table for Rating
CREATE TABLE Rating
(
    r_id INTEGER PRIMARY KEY,
    the_nest_rating TINYINT CHECK (the_nest_rating BETWEEN 1 AND 10),
    google_rating TINYINT CHECK (google_rating BETWEEN 1 AND 10),
    social_media_rating TINYINT CHECK (social_media_rating BETWEEN 1 AND 10),
    c_id INTEGER NOT NULL,  -- Added NOT NULL to ensure proper referencing
    FOREIGN KEY (c_id) REFERENCES Community(c_id)
);

-- Table for Maps
CREATE TABLE Map
(
    m_id INTEGER PRIMARY KEY,
    m_name VARCHAR(255) NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL
);

-- Table for Feedbacks
CREATE TABLE Feedbacks 
( 
    f_message VARCHAR(600) NOT NULL,
    u_email VARCHAR(255) NOT NULL,
    c_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (u_email) REFERENCES Tenants(u_email),
    FOREIGN KEY (c_name) REFERENCES Community(c_name)
);
-- Insert data into the Map table
INSERT INTO Map (m_id, m_name, latitude, longitude)
VALUES
    (1, 'The Nest Drey', 32.857699, -96.763837),
    (2, 'The Nest Bend', 32.855158, -96.763762),
    (3, 'The Nest Park', 32.852811, -96.765509),
    (4, 'The Nest Gate', 32.859177, -96.765629),
    (5, 'The Nest Green', 32.852768, -96.762848),
    (6, 'CVS Pharmacy', 32.858431, -96.752905),
    (7, 'Central Market', 32.850507, -96.768847),
    (8, 'Tom Thumb', 32.852418, -96.767075),
    (9, 'Target', 32.856560, -96.752694),
    (10, 'Walmart', 32.863297, -96.753460),
    (11, 'Kohl''s', 32.857201, -96.754228),
    (12, '7-Eleven', 32.857363, -96.755751),
    (13, 'McDonald''s', 32.857845, -96.768168),
    (14, 'The Oasis Café', 32.858247, -96.768796),
    (15, 'Wells Fargo Bank', 32.852125, -96.767317),
    (16, 'Chase Bank', 32.861755, -96.768069),
    (17, 'Amesbury @ Southwestern - N - NS', 32.857086, -96.765645),
    (18, 'White Rock', 32.83007269213602, -96.72399730780973),
    (19, 'Southern Methodist University', 32.841686506523786, -96.78449604685292),
    (20, 'Recreational Activity Near Drey Hotel', 32.85973561474833, -96.76250434685201),
    (21, 'The Nest Gym', 32.860571887321335, -96.76297515055684),
    (22, 'The Nest Lakes', 32.859451272391006, -96.76110083067827),
    (23, 'The Dallas Arboretum', 32.82383475509026, -96.71659141801776),
    (24, 'SMU Mockingbird', 32.838064988941696, -96.77489347116263);

-- Insert data into the Community table
INSERT INTO Community (c_id, c_name, c_address, c_zip, c_city, c_description, c_units)
VALUES
    (1001, 'The Nest Bend', 'The Nest Bend Dr', 75206, 'Dallas', 'Close to hiking trail and dog park', 5),
    (1002, 'The Nest Park', 'Amesbury Dr', 75206, 'Dallas', 'Eco-friendly community near parks', 5),
    (1003, 'The Nest Gate', 'Southwestern Blvd', 75206, 'Dallas', 'Road front community close to recreational activities', 5),
    (1004, 'The Nest Green', 'The Nest Glen Dr', 75206, 'Dallas', 'Quiet residential area', 5),
    (1005, 'The Nest Drey', 'Southwestern Blvd', 75206, 'Dallas', 'Waterfront community with trails', 5);


INSERT INTO Admins (admin_id, admin_name, admin_email, admin_role)
VALUES
(1111, 'Lubaina', 'Lubaina@gmail.com', 'Property Manager'),
(2222, 'Amith', 'Amith@gmail.com', 'Customer Support Manager'),
(3333, 'Aishwarya', 'Aishwarya@gmail.com', 'Operations Manager'),
(4444, 'Sharvari', 'Sharvari@gmail.com', 'Maintenance Manager');


INSERT INTO Property (p_id, p_type, p_rent, p_availability, p_furnish_status, p_description, c_id, admin_id)
VALUES
(101, '2BHK', 1500, 'Occupied', 'Furnished', 'This modern 2BHK offers 800-1200 sq. ft. of space, including two roomy bedrooms, a sleek kitchen, and a comfortable living area. Ideal for families or roommates, with premium features in a convenient location.', 1001, 1111),
(102, '1BHK', 1000, 'Available', 'Furnished', 'This stylish 1BHK spans 500-700 sq. ft., featuring a spacious bedroom, a modern kitchen, and a cozy living area. Perfect for comfortable living with great amenities in a prime location.', 1001, 2222),
(103, '3BHK', 2000, 'Available', 'Furnished', 'This luxurious 3BHK covers 1300-1800 sq. ft., with large bedrooms, a stylish kitchen, and a welcoming living area. Perfect for families seeking comfort, space, and premium amenities in a prime area.', 1001, 3333),
(104, '1BHK', 800, 'Available', 'Furnished', 'This compact yet stylish Studio 1BHK spans 300-500 sq. ft., featuring an open layout with a combined living, dining, and sleeping area, plus a modern kitchenette. Perfect for singles or young professionals, it offers efficient use of space, contemporary finishes, and a convenient location.', 1001, 4444),
(105, '2BHK', 1200, 'Available', 'Furnished', 'Experience luxury in this spacious 2BHK, spanning 1200-1500 sq. ft. It features two generously sized bedrooms, a modern kitchen, and an expansive living area perfect for families or professionals. With ample storage, premium finishes, and top-notch amenities, this apartment offers elevated comfort in a prime location.', 1001, 1111),
(201, '2BHK', 1500, 'Occupied', 'Unfurnished', 'This modern 2BHK offers 800-1200 sq. ft. of space, including two roomy bedrooms, a sleek kitchen, and a comfortable living area. Ideal for families or roommates, with premium features in a convenient location.', 1002, 1111),
(202, '1BHK', 1000, 'Available', 'Unfurnished', 'This stylish 1BHK spans 500-700 sq. ft., featuring a spacious bedroom, a modern kitchen, and a cozy living area. Perfect for comfortable living with great amenities in a prime location.', 1002, 2222),
(203, '3BHK', 2000, 'Occupied', 'Furnished', 'This luxurious 3BHK covers 1300-1800 sq. ft., with large bedrooms, a stylish kitchen, and a welcoming living area. Perfect for families seeking comfort, space, and premium amenities in a prime area.', 1002, 3333),
(204, '1BHK', 800, 'Available', 'Furnished', 'This compact yet stylish Studio 1BHK spans 300-500 sq. ft., featuring an open layout with a combined living, dining, and sleeping area, plus a modern kitchenette. Perfect for singles or young professionals, it offers efficient use of space, contemporary finishes, and a convenient location.', 1002, 4444),
(205, '2BHK', 1200, 'Available', 'Unfurnished', 'Experience luxury in this spacious 2BHK, spanning 1200-1500 sq. ft. It features two generously sized bedrooms, a modern kitchen, and an expansive living area perfect for families or professionals. With ample storage, premium finishes, and top-notch amenities, this apartment offers elevated comfort in a prime location.', 1002, 1111),
(301, '2BHK', 1500, 'Occupied', 'Furnished', 'This modern 2BHK offers 800-1200 sq. ft. of space, including two roomy bedrooms, a sleek kitchen, and a comfortable living area. Ideal for families or roommates, with premium features in a convenient location.', 1003, 1111),
(302, '1BHK', 1000, 'Available', 'Furnished', 'This stylish 1BHK spans 500-700 sq. ft., featuring a spacious bedroom, a modern kitchen, and a cozy living area. Perfect for comfortable living with great amenities in a prime location.', 1003, 2222),
(303, '3BHK', 2000, 'Available', 'Furnished', 'This luxurious 3BHK covers 1300-1800 sq. ft., with large bedrooms, a stylish kitchen, and a welcoming living area. Perfect for families seeking comfort, space, and premium amenities in a prime area.', 1003, 3333),
(304, '1BHK', 800, 'Available', 'Unfurnished', 'This compact yet stylish Studio 1BHK spans 300-500 sq. ft., featuring an open layout with a combined living, dining, and sleeping area, plus a modern kitchenette. Perfect for singles or young professionals, it offers efficient use of space, contemporary finishes, and a convenient location.', 1003, 4444),
(305, '2BHK', 1200, 'Available', 'Unfurnished', 'Experience luxury in this spacious 2BHK, spanning 1200-1500 sq. ft. It features two generously sized bedrooms, a modern kitchen, and an expansive living area perfect for families or professionals. With ample storage, premium finishes, and top-notch amenities, this apartment offers elevated comfort in a prime location.', 1003, 1111),
(401, '2BHK', 1500, 'Available', 'Furnished', 'This modern 2BHK offers 800-1200 sq. ft. of space, including two roomy bedrooms, a sleek kitchen, and a comfortable living area. Ideal for families or roommates, with premium features in a convenient location.', 1004, 1111),
(402, '1BHK', 1000, 'Available', 'Furnished', 'This stylish 1BHK spans 500-700 sq. ft., featuring a spacious bedroom, a modern kitchen, and a cozy living area. Perfect for comfortable living with great amenities in a prime location.', 1004, 2222),
(403, '3BHK', 2000, 'Available', 'Furnished', 'This luxurious 3BHK covers 1300-1800 sq. ft., with large bedrooms, a stylish kitchen, and a welcoming living area. Perfect for families seeking comfort, space, and premium amenities in a prime area.', 1004, 3333),
(404, '1BHK', 800, 'Available', 'Unfurnished', 'This compact yet stylish Studio 1BHK spans 300-500 sq. ft., featuring an open layout with a combined living, dining, and sleeping area, plus a modern kitchenette. Perfect for singles or young professionals, it offers efficient use of space, contemporary finishes, and a convenient location.', 1004, 4444),
(405, '2BHK', 1200, 'Available', 'Furnished', 'Experience luxury in this spacious 2BHK, spanning 1200-1500 sq. ft. It features two generously sized bedrooms, a modern kitchen, and an expansive living area perfect for families or professionals. With ample storage, premium finishes, and top-notch amenities, this apartment offers elevated comfort in a prime location.', 1004, 1111),
(501, '2BHK', 1500, 'Occupied', 'Furnished', 'This modern 2BHK offers 800-1200 sq. ft. of space, including two roomy bedrooms, a sleek kitchen, and a comfortable living area. Ideal for families or roommates, with premium features in a convenient location.', 1005, 1111),
(502, '1BHK', 1000, 'Available', 'Unfurnished', 'This stylish 1BHK spans 500-700 sq. ft., featuring a spacious bedroom, a modern kitchen, and a cozy living area. Perfect for comfortable living with great amenities in a prime location.', 1005, 2222),
(503, '3BHK', 2000, 'Available', 'Unfurnished', 'This luxurious 3BHK covers 1300-1800 sq. ft., with large bedrooms, a stylish kitchen, and a welcoming living area. Perfect for families seeking comfort, space, and premium amenities in a prime area.', 1005, 3333),
(504, '1BHK', 800, 'Available', 'Furnished', 'This compact yet stylish Studio 1BHK spans 300-500 sq. ft., featuring an open layout with a combined living, dining, and sleeping area, plus a modern kitchenette. Perfect for singles or young professionals, it offers efficient use of space, contemporary finishes, and a convenient location.', 1005, 4444),
(505, '2BHK', 1200, 'Available', 'Unfurnished', 'Experience luxury in this spacious 2BHK, spanning 1200-1500 sq. ft. It features two generously sized bedrooms, a modern kitchen, and an expansive living area perfect for families or professionals. With ample storage, premium finishes, and top-notch amenities, this apartment offers elevated comfort in a prime location.', 1005, 1111);

-- Insert data into the Rating table
INSERT INTO Rating (r_id, the_nest_rating, google_rating, social_media_rating, c_id)
VALUES
    (2001, 10, 8, 9, 1001),
    (2002, 9, 8, 9, 1002),
    (2003, 10, 9, 8, 1003),
    (2004, 9, 8, 10, 1004),
    (2005, 9, 9, 8, 1005);
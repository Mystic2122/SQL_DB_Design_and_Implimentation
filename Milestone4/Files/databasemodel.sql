DROP DATABASE IF EXISTS hotelDB;
CREATE DATABASE hotelDB;
USE hotelDB;

DROP TABLE IF EXISTS Guest;
CREATE TABLE Guest(
	guest_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birth_date DATE,
    phone_number VARCHAR(15)
);

DROP TABLE IF EXISTS Guest_Address;
CREATE TABLE Guest_Address(
	address_id INT PRIMARY KEY,
    guest_id INT,
    CONSTRAINT FK_guest_id_Address FOREIGN KEY (guest_id) REFERENCES Guest(guest_id) ON DELETE SET NULL,
    street_address VARCHAR(50) NOT NULL,
	city VARCHAR(30),
    state VARCHAR(2),
    zip_code VARCHAR(5)
);

DROP TABLE IF EXISTS Hotel_Branch;
CREATE TABLE Hotel_Branch(
	hotel_branch_id INT PRIMARY KEY,
	branch_name VARCHAR(50),
    phone_number VARCHAR(15)
);

DROP TABLE IF EXISTS Hotel_Branch_Address;
CREATE TABLE Hotel_Branch_Address(
	address_id INT PRIMARY KEY,
    hotel_branch_id INT,
    CONSTRAINT FK_hotel_branch_id_Address FOREIGN KEY (hotel_branch_id) REFERENCES Hotel_Branch(hotel_branch_id) ON DELETE SET NULL,
    street_address VARCHAR(50) NOT NULL,
	city VARCHAR(30),
    state VARCHAR(2),
    zip_code VARCHAR(5)
);

DROP TABLE IF EXISTS Reservation;
CREATE TABLE Reservation(
	reservation_id INT PRIMARY KEY,
    guest_id INT,
	check_in_time DATETIME,
    check_out_time DATETIME,
    hotel_branch_id INT,
	CONSTRAINT FK_guest_id_Reservation FOREIGN KEY (guest_id) REFERENCES Guest(guest_id) ON DELETE CASCADE,
    CONSTRAINT FK_hotel_branch_id_Reservation FOREIGN KEY (hotel_branch_id) REFERENCES Hotel_Branch(hotel_branch_id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Review;
CREATE TABLE Review(
	review_id INT PRIMARY KEY,
    rating INT,
    review VARCHAR(140),
    datetime DATETIME,
    reservation_id INT,
    CONSTRAINT FK_reservation_id_Review FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Bill;
CREATE TABLE Bill(
	bill_id INT PRIMARY KEY,
    reservation_id INT,
    total_amount DECIMAL(10,2),
    payment_due_date DATETIME,
    CONSTRAINT FK_reservation_id_Bill FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id) ON DELETE NO ACTION
);

DROP TABLE IF EXISTS Room_Type;
CREATE TABLE Room_Type(
	room_type_id INT PRIMARY KEY,
    room_name VARCHAR(50),
    max_occupancy INT
);

DROP TABLE IF EXISTS Employee;
CREATE TABLE Employee(
	employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(50),
    salary DECIMAL (10,2),
    hotel_branch_id INT,
    supervisor_id INT,
    CONSTRAINT FK_hotel_branch_id_Employee FOREIGN KEY (hotel_branch_id) REFERENCES Hotel_Branch(hotel_branch_id),
    CONSTRAINT FK_supervisor_id_Employee FOREIGN KEY (supervisor_id) REFERENCES Employee(employee_id)
);

DROP TABLE IF EXISTS Employee_Role;
CREATE TABLE Employee_Role(
	role_id INT PRIMARY KEY,
	role_name VARCHAR(45) DEFAULT 'Other',
    -- 'Housekeeper', 'Valet', 'Maintenance', 'Other'
    minimum_salary INT NOT NULL
);

DROP TABLE IF EXISTS Employee_Employee_Role_Association;
CREATE TABLE Employee_Employee_Role_Association(
	employee_id INT,
    role_id INT,
    CONSTRAINT FK_role_id_Employee_Employee_Role_Association FOREIGN KEY (role_id) REFERENCES Employee_Role(role_id),
	CONSTRAINT FK_employee_id_Employee_Employee_Role_Association FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    PRIMARY KEY (employee_id, role_id)
);

-- 181
 DROP TABLE IF EXISTS Valet;
 CREATE TABLE Valet(
	valet_id INT PRIMARY KEY,
    valet_license_number VARCHAR(20),
    max_vehicles_handled INT,
    CONSTRAINT FK_valet_id_Valet FOREIGN KEY (valet_id) REFERENCES Employee(employee_id)
);

DROP TABLE IF EXISTS Housekeeper;
CREATE TABLE Housekeeper(
	housekeeper_id INT PRIMARY KEY,
    date_hired DATE,
    favorite_job VARCHAR(50),
    CONSTRAINT FK_housekeeper_id_Housekeeper FOREIGN KEY (housekeeper_id) REFERENCES Employee(employee_id)
);

DROP TABLE IF EXISTS Maintenance;
CREATE TABLE Maintenance(
	maintenance_id INT PRIMARY KEY,
    specialty ENUM('Electrical', 'Plumbing', 'Tech', 'Other') DEFAULT 'Other',
    date_hired DATE,
    CONSTRAINT FK_maintenance_id_Maintenance FOREIGN KEY (maintenance_id) REFERENCES Employee(employee_id)
);


DROP TABLE IF EXISTS Room;
CREATE TABLE Room(
	room_id INT PRIMARY KEY,
    -- FKs
    room_type_id INT,
    room_price DECIMAL(10,2),
    reservation_id INT,
    housekeeper_id INT DEFAULT NULL,
    hotel_branch_id INT NOT NULL,
    CONSTRAINT FK_reservation_id_Room FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id) ON DELETE SET NULL,
	CONSTRAINT FK_room_type_id_Room FOREIGN KEY (room_type_id) REFERENCES Room_Type(room_type_id) ON DELETE SET NULL,
    CONSTRAINT FK_housekeeper_id_Room FOREIGN KEY (housekeeper_id) REFERENCES Housekeeper(housekeeper_id),
    CONSTRAINT FK_hotel_branch_id_Room FOREIGN KEY (hotel_branch_id) REFERENCES Hotel_Branch(hotel_branch_id)
);

DROP TABLE IF EXISTS Room_Service;
CREATE TABLE Room_Service(
	order_id INT PRIMARY KEY,
    room_id INT NOT NULL,
    bill_id INT NOT NULL,
    order_datetime DATETIME,
    total_amount DECIMAL(10,2),
    CONSTRAINT FK_room_id_Room_Service FOREIGN KEY (room_id) REFERENCES Room(room_id),
    CONSTRAINT FK_bill_id_Room_Service FOREIGN KEY (bill_id) REFERENCES Bill(bill_id)
);




DROP TABLE IF EXISTS Parking_Lot;
CREATE TABLE Parking_Lot(
	parking_lot_id INT PRIMARY KEY,
    hotel_branch_id INT,
    CONSTRAINT FK_hotel_branch_id_Parking_Lot FOREIGN KEY (hotel_branch_id) REFERENCES Hotel_Branch(hotel_branch_id),
    number_of_spaces INT
    -- add valet
);

DROP TABLE IF EXISTS Mini_Bar;
CREATE TABLE Mini_Bar(
	mini_bar_id INT PRIMARY KEY,
    size ENUM('Small', 'Medium', 'Large'),
    room_id INT,
    CONSTRAINT FK_room_id_Mini_Bar FOREIGN KEY (room_id) REFERENCES Room(room_id)
);

-- Parent Inventory Table
DROP TABLE IF EXISTS Inventory;
CREATE TABLE Inventory(
	item_id INT PRIMARY KEY,
    item_name VARCHAR(50),
    inventory_type ENUM('Restaurant', 'Hotel', 'MiniBar') NOT NULL
    -- 'Hotel' is stuff for the rooms: toilet paper, soap, cleaning supplies, tissues, etc.
);

DROP TABLE IF EXISTS Mini_Bar_Inventory;
CREATE TABLE Mini_Bar_Inventory(
	mini_bar_id INT,
    item_id INT,
    quantity INT DEFAULT 0,
    date_checked DATE,
    unit_price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (mini_bar_id, item_id),
    CONSTRAINT FK_mini_bar_id_Mini_Bar_Inventory FOREIGN KEY (mini_bar_id) REFERENCES Mini_Bar(mini_bar_id),
    CONSTRAINT FK_item_id_Mini_Bar_Inventory FOREIGN KEY (item_id) REFERENCES Inventory(item_id)
);

DROP TABLE IF EXISTS Restaurant;
CREATE TABLE Restaurant(
	restaurant_id INT,
    hotel_branch_id INT,
    restruaunt_name VARCHAR(50),
    open_time TIME,
    close_time TIME,
    PRIMARY KEY (restaurant_id, hotel_branch_id),
    CONSTRAINT FK_hotel_branch_id_Restaurant FOREIGN KEY (hotel_branch_id) REFERENCES Hotel_Branch(hotel_branch_id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Restaurant_Inventory;
CREATE TABLE Restaurant_Inventory(
	restaurant_id INT,
    item_id INT,
    quantity INT DEFAULT 0,
    PRIMARY KEY (restaurant_id, item_id),
    CONSTRAINT FK_restaurant_id_Restaurant_Inventory FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id),
    CONSTRAINT FK_item_id_Restaurant_Inventory FOREIGN KEY (item_id) REFERENCES Inventory(item_id)
);

DROP TABLE IF EXISTS Hotel_Inventory;
CREATE TABLE Hotel_Inventory (
    item_id INT,
    hotel_branch_id INT,
    storage_room VARCHAR (50),
    quantity INT,
    PRIMARY KEY (item_id, hotel_branch_id),
    CONSTRAINT FK_item_id_Hotel_Inventory FOREIGN KEY (item_id) REFERENCES Inventory(item_id) ON DELETE CASCADE,
    CONSTRAINT FK_hotel_branch_id_Hotel_Inventory FOREIGN KEY (hotel_branch_id) REFERENCES Hotel_Branch(hotel_branch_id) ON DELETE CASCADE
);



DROP TABLE IF EXISTS Maintenance_Request;
CREATE TABLE Maintenance_Request(
	request_id INT PRIMARY KEY,
    request_type ENUM('Electrical', 'Plumbing', 'Tech', 'Other') DEFAULT 'Other',
    description VARCHAR(100),
    room_id INT,
    CONSTRAINT FK_room_id_Maintenance_Request FOREIGN KEY (room_id) REFERENCES Room(room_id)
);

DROP TABLE IF EXISTS Staff_Schedule;
CREATE TABLE Staff_schedule(
	shift_id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    shift_date DATE,
    start_time TIME,
    end_time TIME,
    role_id INT NOT NULL,
    hotel_branch_id INT,
    CONSTRAINT FK_employee_id_Staff_Schedule FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    CONSTRAINT FK_role_id_Staff_Schedule FOREIGN KEY (role_id) REFERENCES Employee_Role(role_id),
    CONSTRAINT FK_hotel_branch_id_Staff_Schedule FOREIGN KEY (hotel_branch_id) REFERENCES Hotel_Branch(hotel_branch_id)
);

DROP TABLE IF EXISTS Event;
CREATE TABLE Event(
	event_id INT PRIMARY KEY,
    event_name VARCHAR(70),
    guest_count INT,
    event_type ENUM('Wedding', 'Conference', 'Meeting', 'Other') DEFAULT 'Other',
    room_id INT,
    hotel_branch_id INT,
    CONSTRAINT FK_hotel_branch_id_Event FOREIGN KEY (hotel_branch_id) REFERENCES Hotel_Branch(hotel_branch_id) ON DELETE CASCADE,
    CONSTRAINT FK_room_id_Event FOREIGN KEY (room_id) REFERENCES Room(room_id) ON DELETE SET NULL
);
    
DROP TABLE IF EXISTS Amenity;
CREATE TABLE Amenity(
	amenity_id INT PRIMARY KEY,
    amenity_name VARCHAR(30),
    amenity_discription VARCHAR(100)
);

DROP TABLE IF EXISTS Hotel_Amenity;
CREATE TABLE Hotel_Amenity(
	hotel_branch_id INT,
    hotel_amenity_id INT,
    availability_status BOOLEAN,
    CONSTRAINT FK_hotel_branch_id_Hotel_Amenity FOREIGN KEY (hotel_branch_id) REFERENCES Hotel_Branch(hotel_branch_id),
    CONSTRAINT FK_hotel_amenity_id_Hotel_Amenity FOREIGN KEY (hotel_amenity_id) REFERENCES Amenity(amenity_id),
    PRIMARY KEY (hotel_branch_id, hotel_amenity_id)
);

DROP TABLE IF EXISTS Room_Amenity;
CREATE TABLE Room_Amenity(
	room_id INT,
    room_amenity_id INT,
    availability_status BOOLEAN,
    CONSTRAINT FK_room_id_Room_Amenity FOREIGN KEY (room_id) REFERENCES Room(room_id),
    CONSTRAINT FK_room_amenity_id_Room_Amenity FOREIGN KEY (room_amenity_id) REFERENCES Amenity(amenity_id),
    PRIMARY KEY (room_id, room_amenity_id)
);

DROP TABLE IF EXISTS Linen_Service;
CREATE TABLE Linen_Service(
	linen_service_id INT PRIMARY KEY,
    service_name VARCHAR(30),
    phone_number VARCHAR(15)
);



DROP TABLE IF EXISTS Linen_Service_Hotel_Branch_Association;
CREATE TABLE Linen_Service_Hotel_Branch_Association(
	supply_id INT PRIMARY KEY,
    linen_service_id INT,
    hotel_branch_id INT,
    date DATE,
    CONSTRAINT FK_linen_service_id_Linen_Service_Hotel_Branch_Association FOREIGN KEY (linen_service_id) REFERENCES Linen_Service(linen_service_id),
    CONSTRAINT FK_hotel_branch_id_Linen_Service_Hotel_Branch_Association FOREIGN KEY (hotel_branch_id) REFERENCES Hotel_Branch(hotel_branch_id)
);

DROP TABLE IF EXISTS Rewards_Program;
CREATE TABLE Rewards_Program(
	rewards_program_id INT PRIMARY KEY,
    program_name VARCHAR(30),
    program_price DECIMAL(10,2) DEFAULT 0.00,
    point_multiplier DECIMAL(10,2)
);

DROP TABLE IF EXISTS Guest_Rewards;
CREATE TABLE Guest_Rewards(
	guest_id INT,
    rewards_program_id INT,
    total_points INT,
    CONSTRAINT FK_guest_id_Guest_Rewards FOREIGN KEY (guest_id) REFERENCES Guest(guest_id),
    CONSTRAINT FK_rewards_program_id_Guest_Rewards FOREIGN KEY (rewards_program_id) REFERENCES Rewards_Program(rewards_program_id),
    PRIMARY KEY (guest_id, rewards_program_id)
);

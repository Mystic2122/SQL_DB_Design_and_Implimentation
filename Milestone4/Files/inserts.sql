USE hotelDB;

INSERT INTO Guest (guest_id, first_name, last_name, birth_date, phone_number) 
	VALUES 
		(1, 'Nick', 'Wendt', '2003-05-30', '4156880987'),
        (2, 'Kate', 'Kerstetter', '2003-08-04', '4155834428'),
        (3, 'John', 'Pork', '1999-01-01', '5104829194'),
        (4, 'Steve', 'Beef', '1985-09-17', '4085293080')
;

INSERT INTO Guest_Address (address_id, guest_id, street_address, city, state, zip_code)
	VALUES
		(1, 1, '100 1st St', 'San Francisco', 'CA', '94134'),
        (2, 2, '510 19 Ave', 'San Francisco', 'CA', '94115'),
        (3, 3, ' 4428 Geary Blvd', 'San Francisco', 'CA', '94124'),
        (4, 4, '300 Las Vegas Blvd', 'Las Vegas', 'NV', '84134')
;

INSERT INTO Hotel_Branch (hotel_branch_id, branch_name, phone_number)
	VALUES
		(1, 'San Francisco', '4153345691'),
        (2, 'Las Vegas', '6824356616'),
        (3, 'New York City', '7102879926')
;

INSERT INTO Hotel_Branch_Address (address_id, hotel_branch_id, street_address, city, state, zip_code)
	VALUES
		(1, 1, '500 Market St', 'San Francisco', 'CA', '94115'),
        (2, 2, '100 Las Vegas Blvd', 'Las Vegas', 'NV', '84134'),
        (3, 3, '200 52nd St', 'New York City', 'NY', '10590')
;

INSERT INTO Reservation (reservation_id, guest_id ,check_in_time ,check_out_time ,hotel_branch_id)
	VALUES
		(1, 1, '2024-12-5 15:00:00', '2024-12-10 11:00:00', 1),
        (2, 2, '2025-01-05 14:00:00', '2025-01-10 12:30:00', 1),
        (3, 3, '2024-12-29 14:00:00', '2025-01-02 11:00:00', 3),
        (4, 1, '2024-11-29 14:00:00', '2024-12-02 11:00:00', 2),
        (5, 2, '2024-10-29 14:00:00', '2024-11-02 11:30:00', 3)
;

INSERT INTO Review(review_id ,rating ,review, datetime, reservation_id)
	VALUES
		(1, 5, 'Very clean room, nice staff', CURRENT_TIMESTAMP, 4),
        (2, 3, 'Was denied late checkout but overall good service', CURRENT_TIMESTAMP, 5),
        (3, 5, 'Nice gym, friendly staff', CURRENT_TIMESTAMP, 1)
;

INSERT INTO Bill (bill_id, reservation_id, total_amount, payment_due_date)
	VALUES 
		(1, 1, 500, '2024-12-20 23:59:59'),
        (2, 2, 1000, '2025-01-20 23:59:59'),
		(3, 3, 700, '2025-01-12 23:59:59')
;

INSERT INTO Room_Type (room_type_id, room_name, max_occupancy)
	VALUES
		(1, 'Single King', 2),
        (2, 'Double Queen', 4),
        (3, 'Double King Suite', 6),
        (4, 'Conference Room', 100)
;

INSERT INTO Room (room_id, room_type_id, reservation_id, hotel_branch_id)
	VALUES 
		(1, 3, NULL, 1),
        (2, 1, 1, 2),
        (3, 2, 2, 3),
        (4, 4, NULL, 1)
;

INSERT INTO Room_Service (order_id, room_id, bill_id, order_datetime, total_amount)
	VALUES
		(1, 2, 1, '2024-12-06 20:10:10', 20.99),
        (2, 1, 2, '2025-01-07 15:06:00', 9.99),
        (3, 3, 3, '2024-12-30 22:19:55', 15.99)
;
INSERT INTO Parking_Lot (parking_lot_id, hotel_branch_id, number_of_spaces)
	VALUES
		(1, 1, 500),
        (2, 2, 100),
        (3, 3, 50)
;

INSERT INTO Mini_Bar (mini_bar_id, size, room_id)
	VALUES
		(1, 'Large', 1),
        (2, 'Medium', 2),
        (3, 'Small', 3)
;

INSERT INTO Inventory (item_id, item_name, inventory_type)
	VALUES
		(1, 'Sprite', 'MiniBar'),
        (2, 'Shampoo', 'Hotel'),
        (3, 'To-Go Boxes', 'Restaurant'),
        (4, 'M&Ms', 'MiniBar'),
        (5, 'Plastic Forks', 'Restaurant'),
        (6, 'Toilet Paper', 'Hotel'),
        (7, 'Soap Bars', 'Hotel'),
        (8, 'Coke', 'MiniBar'),
        (9, 'Napkins', 'Restaurant')
;

INSERT INTO Mini_Bar_Inventory (mini_bar_id, item_id, quantity, date_checked, unit_price)
	VALUES
		(1, 1, 10, '2024-05-30', 4.99),
		(2, 4, 5, '2024-10-30',6.99),
        (1, 8, 2, '2024-11-30',3.99)
;

INSERT INTO Restaurant (restaurant_id, hotel_branch_id, restruaunt_name, open_time, close_time)
	VALUES
		(1, 1, 'Dunkin Donuts', '06:00:00', '16:00:00'),
        (2, 2, 'Nobu', '16:00:00', '22:00:00'),
        (3, 3, 'Hard Rock Cafe', '10:00:00', '24:00:00')
;

INSERT INTO Restaurant_Inventory(restaurant_id, item_id, quantity)
	VALUES
		(1, 3, 50),
        (2, 5, 100),
        (3, 9, 10)
;

INSERT INTO Hotel_Inventory (item_id, hotel_branch_id, storage_room, quantity)
	VALUES
		(2, 1, 'Basement', 2000),
        (6, 1, 'First floor storage room', 5000),
        (7, 2, 'Basement', 10000)
;

INSERT INTO Employee(employee_id, first_name, last_name, email, salary, hotel_branch_id, supervisor_id)
	VALUES 
		(1, 'Brian', 'Quinn', 'bquinn@hoteldb.com', 75000, 1, NULL),
        (2, 'James', 'Murry', 'jmurry@hoteldb.com', 50000, 1, 1),
        (3, 'Sal', 'Vulcano', 'svulcano@hoteldb.com', 60000, 2, NULL),
        (4, 'Joe', 'Gatto', 'jgatto@hoteldb.com', 45000, 2, 3),
        (5, 'Jana', 'Barba', 'jbarba@hoteldb.com', 40100, 2, 3),
        (6, 'Aidan', 'Hope', 'ahope@hoteldb.com', 51000, 1, 1),
        (7, 'Isa', 'Cole', 'icole@hoteldb.com', 72000, 3, NULL),
        (8, 'Sarah', 'Kristoff', 'skristoff@hoteldb.com', 50200, 3, 7),
        (9, 'Benito', 'Hoe', 'bhoe@hoteldb.com', 40000, 3, 7)
;

INSERT INTO Employee_Role(role_id, role_name, minimum_salary)
	VALUES
		(1, 'Valet', 40000),
        (2, 'Housekeeper', 35000),
        (3, 'Manager', 70000),
        (4, 'Maintenance', 55000)
;

INSERT INTO Employee_Employee_Role_Association(employee_id, role_id)
	VALUES
		(1,3),
        (2,2),
        (3,4),
        (4,1),
		(1,4),
        (5,2),
        (6,1),
        (7,3),
        (8,4),
        (9,2),
        (7,1)
;

INSERT INTO Valet(valet_id, valet_license_number, max_vehicles_handled)
	VALUES
		(4, 'Y710985', 30),
        (6, 'Z358670', 35),
        (7, 'B254367', 20)
;

INSERT INTO Housekeeper(housekeeper_id, date_hired, favorite_job)
	VALUES 
		(2, '2022-09-18', 'Making beds'),
        (5, '2018-07-12', 'Restocking'),
        (9, '2010-02-23', 'Cleaning elevator')
;

INSERT INTO Maintenance(maintenance_id, specialty, date_hired)
	VALUES
		(3, 'Plumbing', '2015-08-04'),
        (1, 'Tech', '2009-12-13'),
        (8, 'Electrical', '2020-10-30')
;

INSERT INTO Maintenance_Request(request_id, request_type, description, room_id)
	VALUES
		(1, 'Electrical', 'Light is out', 1),
        (2, 'Plumbing', 'Sink won\'t drain', 1),
        (3, 'Tech', 'Wifi is not working', 3)
;

INSERT INTO Staff_Schedule(shift_id, employee_id, shift_date, start_time, end_time, role_id)
	VALUES
		(1, 1, '2024-12-05', '12:00:00', '18:00:00', 3),
        (2, 2, '2024-12-06', '15:00:00', '23:00:00', 2),
        (3, 3, '2024-12-12', '08:00:00', '14:00:00', 4)
;

INSERT INTO Event(event_id,event_name, guest_count, event_type, room_id, hotel_branch_id)
	VALUES
		(1, 'Brian\'s Wedding', 90,'Wedding', 4, 1),
        (2, 'Tech Conference', 75, 'Conference', 4, 2),
        (3, 'Mud Wrestling', 50, 'Other', 4, 3)
;

INSERT INTO Amenity(amenity_id, amenity_name, amenity_discription)
	VALUES
		(1, 'Pool', 'There is a pool'),
        (2, 'Turn Down Service', 'There is a turn down service'),
        (3, 'Wifi', 'There is free wifi'),
        (4, 'Smoking Freindly', 'This room is smoking friendly'),
        (5, 'Pet Friendly', 'This room is pet friendly'),
        (6, 'Continental Breakfast', 'There is free continental breakfast')
;

INSERT INTO Hotel_Amenity(hotel_branch_id, hotel_amenity_id, availability_status)
	VALUES
		(1, 1, TRUE),
        (2, 1, FALSE),
        (3, 6, TRUE)
;

INSERT INTO Room_Amenity(room_id, room_amenity_id, availability_status)
    VALUES
		(1,4, FALSE),
        (2, 5, TRUE),
        (3, 3, TRUE)
;

INSERT INTO Linen_Service(linen_service_id, service_name, phone_number)
	VALUES
		(1, 'Clean Linen', '5455555555'),
        (2, 'Fast Linen', '3256517745'),
        (3, 'Super Fast Linen', 2213145678)
;

INSERT INTO Linen_Service_Hotel_Branch_Association(supply_id, linen_service_id, hotel_branch_id, date)
	VALUES
		(1, 1, 1, '2024-10-12'),
        (2, 1, 2, '2024-11-15'),
        (3, 2, 3, '2024-11-29')
;
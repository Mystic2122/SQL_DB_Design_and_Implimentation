USE hotelDB;
/* 
	Business Requirement 1
    -------------------------------------------------
    Purpose: Automate Bill Updates Based on a Trigger
    
    Description: 
		Whenever an entry is inserted into the 
		Room_Service table, the associated bill_id
		increases based on the price of the room service
*/

DELIMITER $$
CREATE TRIGGER Update_Bill_On_Room_Service
AFTER INSERT ON Room_Service
FOR EACH ROW
BEGIN
    UPDATE Bill
    SET total_amount = total_amount + NEW.total_amount
    WHERE bill_id = NEW.bill_id;
END;

$$
DELIMITER ;

/* 
	Business Requirement 2
    -------------------------------------------------
    Purpose: Automate Bill Updates Based on a Trigger
    
    Description: 
		Whenever an item is removed from the minibar
        inside a room corresponding to a reservation,
        update the bill associated to the reservation
        based off the amount of items removed from the
        minibar
*/
DELIMITER $$

CREATE TRIGGER Update_Bill_On_Mini_Bar_Change
AFTER UPDATE ON Mini_Bar_Inventory
FOR EACH ROW
BEGIN
    DECLARE item_cost DECIMAL(10, 2);
    DECLARE reservation_id INT;
    DECLARE check_in DATETIME;
    DECLARE check_out DATETIME;

    -- Calculate the cost of consumed minibar items
    IF OLD.quantity > NEW.quantity THEN
        SET item_cost = (OLD.quantity - NEW.quantity) * NEW.unit_price;

        -- Get reservation details for the room containing the minibar
        SELECT r.reservation_id, res.check_in_time, res.check_out_time
        INTO reservation_id, check_in, check_out
        FROM Room r
        INNER JOIN Mini_Bar mb ON r.room_id = mb.room_id
        INNER JOIN Reservation res ON r.reservation_id = res.reservation_id
        WHERE mb.mini_bar_id = NEW.mini_bar_id;

        -- Check if the date_checked is within the reservation period or up to 1 day after check-out
        IF NEW.date_checked BETWEEN check_in AND DATE_ADD(check_out, INTERVAL 1 DAY) THEN
            -- Update the total amount in the Bill table
            UPDATE Bill
            SET total_amount = total_amount + item_cost
            WHERE reservation_id = reservation_id;
        END IF;
    END IF;
END;
$$

DELIMITER ;

-- Testing the trigger
INSERT INTO Reservation (reservation_id, guest_id, check_in_time, check_out_time, hotel_branch_id)
VALUES (1001, 1, '2024-12-08 14:00:00', '2024-12-10 11:00:00', 1);

INSERT INTO Room (room_id, room_type_id, reservation_id) VALUES (10, 1, 1001);

INSERT INTO Mini_Bar (mini_bar_id, size, room_id) VALUES (6, 'Medium', 10);

INSERT INTO Inventory (item_id, item_name) VALUES (501, 'Snack Item');

INSERT INTO Mini_Bar_Inventory (mini_bar_id, item_id, quantity, date_checked, unit_price)
VALUES (6, 501, 10, '2024-12-08', 5.00);

INSERT INTO Bill (bill_id, reservation_id, total_amount, payment_due_date)
VALUES (6, 1001, 0.00, '2024-12-15 23:59:59');

-- Make sure that the bill_id = 6 is at 0
SELECT * FROM Bill;

-- Removing $10 worth of inventory from the minibar during the reservation time
UPDATE Mini_Bar_Inventory
SET quantity = 8, date_checked = '2024-12-09'
WHERE mini_bar_id = 6 AND item_id = 501;

-- Check bill_id = 6 it should be at 10 now
SELECT * FROM Bill WHERE bill_id = 6;

-- Removing $10 more of inventory on the checkout day
UPDATE Mini_Bar_Inventory
SET quantity = 6, date_checked = '2024-12-10'
WHERE mini_bar_id = 6 AND item_id = 501;

-- Should say 20
SELECT * FROM Bill;

-- Making sure it doesn't bill after the checkout date
UPDATE Mini_Bar_Inventory
SET quantity = 5, date_checked = '2024-12-12'
WHERE mini_bar_id = 6 AND item_id = 501;

-- Should still say 20
SELECT * FROM Bill;

/*
	Note: I had to run the command SET SQL_SAFE_UPDATES = 0; in order for the update statements to work
*/


/* 
	Business Requirement 3
    -------------------------------------------------
    Purpose: Assign Housekeepers to Rooms that have Reservations
    
    Description: 
		Every room that is occupied needs to be cleaned.
        This function will automatically assign housekeepers to clean rooms that are occupied.
        It shall evenly divide up the workload between all the housekeepers on shift
*/
DROP PROCEDURE IF EXISTS Assign_Housekeepers;
DELIMITER $$

CREATE PROCEDURE Assign_Housekeepers(IN p_hotel_branch_id INT)
BEGIN
    DECLARE total_rooms INT;
    DECLARE housekeeper_count INT;
    DECLARE room_id INT;
    DECLARE housekeeper_id INT;
    DECLARE done INT DEFAULT 0;

    DECLARE room_cursor CURSOR FOR
        SELECT r.room_id
        FROM Room r
        WHERE r.reservation_id IS NOT NULL AND r.housekeeper_id IS NULL AND r.hotel_branch_id = p_hotel_branch_id
        LIMIT 100;  -- Limit to 100 rooms, adjust as needed

    DECLARE housekeeper_cursor CURSOR FOR
        SELECT e.employee_id
        FROM Employee e
        JOIN Employee_Employee_Role_Association er
            ON e.employee_id = er.employee_id
        WHERE er.role_id = 1 AND e.hotel_branch_id = p_hotel_branch_id
        LIMIT 100;  

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    SELECT COUNT(*) INTO total_rooms
    FROM Room
    WHERE reservation_id IS NOT NULL AND hotel_branch_id = p_hotel_branch_id AND housekeeper_id IS NULL;

    SELECT COUNT(*) INTO housekeeper_count
    FROM Employee e
    JOIN Employee_Employee_Role_Association er
        ON e.employee_id = er.employee_id
    WHERE er.role_id = 1 AND e.hotel_branch_id = p_hotel_branch_id;

    IF total_rooms > 0 AND housekeeper_count > 0 THEN
        OPEN room_cursor;
        OPEN housekeeper_cursor;

        read_loop: LOOP
            FETCH room_cursor INTO room_id;
            FETCH housekeeper_cursor INTO housekeeper_id;

            IF done THEN
                LEAVE read_loop;
            END IF;

            UPDATE Room r
            SET r.housekeeper_id = housekeeper_id
            WHERE r.room_id = room_id;

        END LOOP;

        CLOSE room_cursor;
        CLOSE housekeeper_cursor;
    END IF;

END $$

DELIMITER ;

-- Testing the Procedure
INSERT INTO Hotel_Branch (hotel_branch_id, branch_name, phone_number)
	VALUES
		(1, 'San Francisco', '4153345691')
;
INSERT INTO Employee (employee_id, first_name, last_name, email, salary, hotel_branch_id) VALUES
(1, 'Alice', 'Smith', 'alice.smith@hotel.com', 2000.00, 1),
(2, 'Bob', 'Johnson', 'bob.johnson@hotel.com', 2200.00, 1),
(3, 'Charlie', 'Brown', 'charlie.brown@hotel.com', 2100.00, 1),
(4, 'Charlie', 'Brown', 'charlie.brown@hotel.com', 2100.00, 1),
(5, 'Charlie', 'Brown', 'charlie.brown@hotel.com', 2100.00, 1);

INSERT INTO Employee_Role(role_id, role_name, minimum_salary)
	VALUES
        (1, 'Housekeeper', 35000)
;
INSERT INTO Employee_Employee_Role_Association (employee_id, role_id) VALUES
(1, 1),  
(2, 1),  
(3, 1),  
(4,1),
(5,1);

INSERT INTO Room_Type (room_type_id, room_name, max_occupancy)
	VALUES
		(1, 'Single King', 2)
;

INSERT INTO Guest (guest_id, first_name, last_name, birth_date, phone_number) 
	VALUES 
		(1, 'Nick', 'Wendt', '2003-05-30', '4156880987'),
        (2, 'Kate', 'Kerstetter', '2003-08-04', '4155834428')
;

INSERT INTO Reservation (reservation_id, guest_id ,check_in_time ,check_out_time ,hotel_branch_id)
	VALUES
		(1, 1, '2024-12-5 15:00:00', '2024-12-10 11:00:00', 1),
        (2, 2, '2025-01-05 14:00:00', '2025-01-10 12:30:00', 1),
        (3, 1, '2024-12-10 16:00:00', '2024-12-15 11:00:00', 1)
;

INSERT INTO Housekeeper(housekeeper_id, date_hired, favorite_job)
	VALUES 
		(1, '2022-09-18', 'Making beds'),
        (2, '2018-07-12', 'Restocking'),
        (3, '2010-02-23', 'Cleaning elevator')
;

INSERT INTO Room (room_id, room_type_id, reservation_id, housekeeper_id, hotel_branch_id) VALUES
(101, 1, 1, NULL, 1),
(102, 1, 2, NULL, 1),
(110, 1, NULL, NULL, 1),
(103, 1, 3, NULL, 1);


INSERT INTO Staff_Schedule(shift_id, employee_id, shift_date, start_time, end_time, role_id)
	VALUES
		(1, 1, '2024-12-05', '12:00:00', '18:00:00', 1),
        (2, 2, '2024-12-06', '15:00:00', '23:00:00', 1),
        (3, 3, '2024-12-12', '08:00:00', '14:00:00', 1)
;

-- No Housekeepers should be assigned yet
SELECT * FROM Room;

CALL Assign_Housekeepers(1);

-- Check to make sure that they were assigned correctly
-- It should only assign housekeepers to rooms with a reservation
SELECT * FROM Room;

/* 
	Business Requirement 4
    -------------------------------------------------
    Purpose: Adding points to the rewards program to the corresponding guest
    
    Description: 
		This procedure shall update the specified guest's rewards points total
        based on the price of their bill.
		
*/

DELIMITER $$

CREATE PROCEDURE Update_Rewards_Points(
    IN p_guest_id INT,
    IN p_bill_id INT
)
BEGIN
    DECLARE v_reservation_id INT;
    DECLARE v_rewards_program_id INT;
    DECLARE v_total_amount DECIMAL(10,2);
    DECLARE v_point_multiplier DECIMAL(10,2);
    DECLARE v_earned_points INT;

    SELECT reservation_id INTO v_reservation_id
    FROM Bill
    WHERE bill_id = p_bill_id;

    SELECT gr.rewards_program_id, rp.point_multiplier
    INTO v_rewards_program_id, v_point_multiplier
    FROM Guest_Rewards gr
    JOIN Rewards_Program rp ON gr.rewards_program_id = rp.rewards_program_id
    WHERE gr.guest_id = p_guest_id;

    SELECT total_amount INTO v_total_amount
    FROM Bill
    WHERE bill_id = p_bill_id;

    SET v_earned_points = FLOOR(v_total_amount * v_point_multiplier);

    UPDATE Guest_Rewards
    SET total_points = total_points + v_earned_points
    WHERE guest_id = p_guest_id AND rewards_program_id = v_rewards_program_id;
END$$

DELIMITER ;

-- Testing the Procedure
INSERT INTO Guest (guest_id, first_name, last_name, birth_date, phone_number)
VALUES 
    (1, 'John', 'Doe', '1990-01-01', '1234567890');

INSERT INTO Rewards_Program (rewards_program_id, program_name, program_price, point_multiplier)
VALUES 
    (1, 'Gold Program', 50.00, 2.0);

INSERT INTO Guest_Rewards (guest_id, rewards_program_id, total_points)
VALUES 
    (1, 1, 0);

INSERT INTO Hotel_Branch (hotel_branch_id, branch_name, phone_number)
	VALUES
		(1, 'San Francisco', '4153345691');

INSERT INTO Reservation (reservation_id, guest_id, check_in_time, check_out_time, hotel_branch_id)
VALUES 
    (1, 1, '2024-12-20 14:00:00', '2024-12-25 11:00:00', 1);


INSERT INTO Bill (bill_id, reservation_id, total_amount, payment_due_date)
VALUES 
    (1, 1, 200.00, '2024-12-26 15:00:00');

-- Total points should be 0
select * from guest_rewards;

CALL Update_Rewards_Points(1, 1);

-- Total points should be 400
select * from guest_rewards;

/* 
	Business Requirement 5
    -------------------------------------------------
    Purpose: 
		Update the bill based off the price of the room
    
    Description: 
		First we need to create a trigger that updates the reservation bill
        based on the price of the room. 
        Then we can create a procedure that updates the room price based on
        occupancy level.
		
*/
DROP TRIGGER IF EXISTS Update_Bill_Total_After_Reservation;
DELIMITER $$

CREATE TRIGGER Update_Bill_Total_After_Reservation
AFTER UPDATE ON Room
FOR EACH ROW
BEGIN
    UPDATE Bill
    SET total_amount = total_amount + NEW.room_price
    WHERE reservation_id = NEW.reservation_id;
END $$

DELIMITER ;

INSERT INTO Guest (guest_id, first_name, last_name, birth_date, phone_number)
VALUES 
    (1, 'John', 'Doe', '1990-01-01', '1234567890'),
    (2, 'Nick', 'Wendt', '2003-05-30', '4156880987');

INSERT INTO Hotel_Branch (hotel_branch_id, branch_name, phone_number)
	VALUES
		(1, 'San Francisco', '4153345691');

INSERT INTO Reservation (reservation_id, guest_id, check_in_time, check_out_time, hotel_branch_id)
VALUES
    (1, 1, '2024-12-15 14:00:00', '2024-12-20 12:00:00', 1),
    (2, 2, '2024-12-15 14:00:00', '2024-12-20 12:00:00', 1);

INSERT INTO Room_Type (room_type_id, room_name, max_occupancy)
	VALUES
		(1, 'Single King', 2);

INSERT INTO Room (room_id, room_type_id, room_price, reservation_id, housekeeper_id, hotel_branch_id)
VALUES
    (101, 1, 150.00, 1, NULL, 1),
    (102, 1, 200.00, 2, NULL, 1),
    (103, 1, 250.00, NULL, NULL, 1);

INSERT INTO Bill (bill_id, reservation_id, total_amount, payment_due_date)
	VALUES 
		(1, 1, 500, '2024-12-20 23:59:59'),
        (2, 2, 1000, '2024-12-20 23:59:59');

-- Check bill before update
SELECT * FROM Bill;

UPDATE Room
SET reservation_id = 1
WHERE room_id = 101;

UPDATE Room
SET reservation_id = 2
WHERE room_id = 102;

-- Bill should have add the price of the room

SELECT * FROM Bill;
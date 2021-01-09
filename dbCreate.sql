-- create the database
DROP DATABASE IF EXISTS RestaurantDB;
CREATE DATABASE RestaurantDB;

USE RestaurantDB;

CREATE TABLE restaurant
(
rid	INT	PRIMARY KEY, 
name 	VARCHAR(255)		NOT NULL, 
address	VARCHAR(255) 		NOT NULL, 
contactNo	CHAR(11) 		NOT NULL, 
status 	VARCHAR(20) 	NOT NULL, 
CHECK (status IN ('open', 'closed', 'permanently closed'))
);

CREATE TABLE staff
(
sid		INT 		PRIMARY KEY, 
firstName		VARCHAR(255) 		NOT NULL, 
lastName		VARCHAR(255)		NOT NULL, 
status			VARCHAR(20)  		NOT NULL, 
CHECK (status IN ('active', 'blocked')), 
position		VARCHAR(20)		NOT NULL, 
CHECK (position IN ('manager', 'waiter', 'chef')), 
rid	INT 	NOT NULL,
CONSTRAINT staff_restaurant_fk FOREIGN KEY (rid) REFERENCES restaurant (rid) ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE TABLE manager
(
phone CHAR(11) 		NOT NULL, 
sid  INT  	NOT NULL, 
user_id		VARCHAR(40)		PRIMARY KEY,
password		VARCHAR(20)	NOT NULL, 
CONSTRAINT manager_staff_fk FOREIGN KEY (sid) REFERENCES staff (sid) ON UPDATE RESTRICT ON DELETE RESTRICT
);



CREATE TABLE customer
(
cid	INT 	PRIMARY KEY, 
firstName		VARCHAR(255)		NOT NULL, 
lastName		VARCHAR(255)		NOT NULL, 
address		VARCHAR(255), 
phone		CHAR(11) 		NOT NULL
);



CREATE TABLE orders
(
oid	INT 	PRIMARY KEY, 
orderDate	DATE		NOT NULL, 
orderType 	VARCHAR(20)	NOT NULL, 
CHECK (orderType IN  ('Dine-in', 'Delivery')), 
cid	INT 	NOT NULL, 
sid	INT 	DEFAULT NULL, 
status VARCHAR(20) NOT NULL, 
CHECK (status IN ('completed', 'uncompleted', 'aborted')),
CONSTRAINT order_customer_fk	FOREIGN KEY (cid)	REFERENCES customer (cid) ON UPDATE RESTRICT ON DELETE RESTRICT, 
CONSTRAINT order_waiter_fk FOREIGN KEY (sid) REFERENCES staff (sid) 	ON UPDATE SET NULL ON DELETE SET NULL
);

CREATE TABLE payment
(
pid 	INT   	PRIMARY KEY, 
paymentTime	DATETIME 		NOT NULL, 
amount		DOUBLE 	NOT NULL, 	
CHECK (amount >=0), 
discount		DOUBLE, 	
CHECK (discount >=0 AND discount <=1.0), 
paymentType		VARCHAR(20) 	NOT NULL, 	
CHECK (paymentType IN ('cash', 'check', 'credit card', 'debit card')), 
cid 	INT 		NOT NULL, 
oid	INT 	NOT NULL, 
CONSTRAINT payment_customer_fk FOREIGN KEY (cid) REFERENCES customer (cid)	 ON UPDATE RESTRICT ON DELETE RESTRICT, 
CONSTRAINT payment_order_fk FOREIGN KEY (oid) REFERENCES orders (oid)	 ON UPDATE RESTRICT ON DELETE RESTRICT
);




CREATE TABLE order_prepares
(
oid 	INT 	NOT NULL, 
chef_id 	INT 	NOT NULL, 
PRIMARY KEY (oid, chef_id), 
FOREIGN KEY (oid)  REFERENCES orders (oid) ON UPDATE RESTRICT ON DELETE RESTRICT, 
FOREIGN KEY (chef_id) REFERENCES staff (sid) ON UPDATE RESTRICT ON DELETE RESTRICT 
);

CREATE TABLE item
(
item_id	INT 	PRIMARY KEY, 
name	VARCHAR(255) 	NOT NULL, 
description 	VARCHAR(255) 	DEFAULT NULL, 
price	DOUBLE NOT NULL,
status VARCHAR(20)	NOT NULL, 
CHECK (status IN ('available', 'not available')), 
rid 	INT 	NOT NULL, 
CONSTRAINT menu_fk 	FOREIGN KEY (rid) REFERENCES restaurant (rid) ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE TABLE order_item
(
oid 	INT NOT NULL, 
item_id	INT 	NOT NULL, 
quantity 	INT 	NOT NULL, 
CHECK (quantity >= 0), 
PRIMARY KEY (oid, item_id), 
FOREIGN KEY (oid)	REFERENCES orders (oid) 	ON UPDATE CASCADE ON DELETE CASCADE, 
FOREIGN KEY (item_id) REFERENCES item (item_id) ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE TABLE delivery
(
trackingNum	CHAR(40) 	PRIMARY KEY, 
address	VARCHAR(255) 	NOT NULL, 
distance	DOUBLE 	NOT NULL, 
CHECK (distance >=0), 
estimatedDelivery	DATETIME 	NOT NULL, 
deliveredTime		DATETIME , 
oid	INT 	NOT NULL, 
CONSTRAINT delivery_order_fk	FOREIGN KEY (oid) REFERENCES orders (oid) 	ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO restaurant VALUES (1, "The Capital Grill", "900 Boylston St, Boston, MA 02115", "6171234567", 'open'), (2, "Union Oyster House", "41 Union St, Boston, MA 02108", "6172345678", 'open');
INSERT INTO staff VALUES (1, "Katelyn", "Monroe", "active", "manager", 1), (5, "Alexandra", "Ashley", "active", "chef", 2), (10, "Cory", "Stokes", 
"blocked", "manager", 1), (3, "Linda", "Sandoval","active",  "waiter", 2), (8, "Bella", "York",  "blocked", "waiter", 1), (9, "Ria", "Johnston", "active", "manager", 2), (18, 
"Fatima", "Camacho", "active", "chef", 2), (35, "Amy", "Trujillo", "active", "chef", 1), (21, "Lisa", "Oconnor", "active", "chef", 1), (17, "Jerry", "Hart", "active", 
"waiter", 1), (13, "Manisha", "Love", "active", "waiter", 2), (15, "Shanta", "Hardy", "active", "waiter", 1), (30, "Ari","Lawson", "active", "waiter", 2);
INSERT INTO manager VALUES ("2522341267", 1, "katM", "kate123"), ("6178882391", 9, "John.ria", "riaj0321");
INSERT INTO customer VALUES (1, "Nabeel", "Choi", "74 Aspen Court, Boston, MA 02109", "6178992341"), (2, "Shakira", "Delacruz", "15 Tremont St
Boston, MA 02108", "6172538920"), (3, "Finley", "Clements", "154 Howard Ave
Boston,MA 02125", "6172827924"), (4, "Yosef", "Bowler", "154 W 6th St
Boston, MA 02127", "6178346814"), (5, "Giselle", "Peters", "17 Wharf St
Boston, MA 02110", "6172893019");
INSERT INTO orders VALUES (1, "2020-01-01", "Dine-in", 1, 15, 'completed'), (2, "2020-04-19", "Delivery", 3, 17, 'completed'), (3, "2020-07-28", "Dine-in", 2, 15, 'completed'), (4, "2020-07-31", "Delivery", 2, 
3, 'completed'), (5, '2020-08-01', 'Dine-in', 5, 30, 'completed'), (6, '2020-08-11', 'Dine-in', 4, 3, 'completed'), (7, '2020-08-30', 'Dine-in', 1, 13, 'completed');
INSERT INTO payment VALUES (1, '2020-01-01 13:48:00', 75.52, 0, 'cash', 1, 1), (2, '2020-04-19 18:21:23', 278.0, 0.3, 'credit card', 3, 2), (3, 
'2020-07-28 11:50:21', 15.01, 0, 'debit card', 2, 3), (4, '2020-07-31 12:21:21', 23.80, 0, 'credit card', 3, 4), (5, '2020-08-01 17:51:21', 50.02, 0, 'credit card', 5, 5), (6, 
'2020-08-12 1:10:12', 28.82, 0.1, 'cash', 4, 6), (7, '2020-08-30 19:00:01', 57.80, 0, 'credit card', 1, 7);
INSERT INTO order_prepares VALUES (1, 21), (1, 35), (2, 21), (2, 35), (3, 21), (4, 5), (5, 18), (6, 18), (7, 5);
INSERT INTO delivery VALUES ("11797027ZBPXQNW7", "156 Howard Ave, Boston, MA 02125", 2.8, '2020-04-19 19:00:00', 
'2020-04-19 18:55:40', 2), ("9374889698090457886949", "156 Howard Ave, Boston, MA 02125", 3.8, '2020-07-31 13:00:00', '2020-07-31 13:11:10', 4);
INSERT INTO item VALUES (1, "New England Clam Chowder", "A New England favorite seasoned with our own blend of spices", 12, 'Available', 1), (2,
 'Pan-Fried Calamari with Hot Cherry Peppers', 'Our signature appetizer – crisp and golden with a fiery flavor', 20, 'Available', 1), (3, 'Cloudy Bay Sauvignon Blanc', 
 NULL, 83, 'Available', 1), (4, 'Coconut Cream Pie', 'With house made caramel sauce and a hint of rum', 12, 'Available', 1), (5, 'Creamed Spinach', NULL, 
 20, 'Not Available', 1), (6, 'Chilled Shrimp Cocktail', NULL, 16.95, 'Available', 2), (7, 'Mussels', 'Basque Style. Steamed with Garlic and White Wine, 
 Garlic Bread', 15.95,  'Available', 2), (8, 'Cold Seafood Sampler', 'Shucked Oysters, Cherrystone Clams & Shrimp', 18.95, 'Available', 2), (9, 'Fish Sandwich', 
 'w/ aged cheddar cheese', 15.95, 'Available', 2), (10, 'Homemade Lump Crab Cakes', 'Ye olde recipe, with lemon aioli', 22.95, 'Available', 2);
 INSERT INTO order_item VALUES (1, 1, 2), (1, 2, 2), (2, 3, 2), (2, 2, 6), (2, 1, 6), (3,  4, 1), (4, 10, 1), (5, 5, 1), (5, 10, 1), (6, 10, 1), (7, 8, 1), (7, 9, 1), (7, 7, 1);

-- procedure to insert into restaurant
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE insert_restaurant(IN rid INT, IN name VARCHAR(255), IN address VARCHAR(255), IN contactNo CHAR(11), IN status VARCHAR(20))
BEGIN
INSERT INTO restaurant VALUES (rid, name, address, contactNo, status);
END //
DELIMITER ;



-- procedure to update the status of a restaurant
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE update_restaurant(rid_ INT, status_ VARCHAR(20))
BEGIN
UPDATE restaurant 
SET status = status_
WHERE rid = rid_;
END //
DELIMITER ;

-- once a restaurant is closed, trigger the related items to be unavailable
DELIMITER //
CREATE TRIGGER status_after_close
AFTER UPDATE ON restaurant 
FOR EACH ROW
BEGIN
IF NEW.status = 'closed' OR NEW.status = 'permanently closed' THEN
UPDATE item
SET status = 'not available' WHERE rid = NEW.rid;
END IF ;
END //
DELIMITER ;

-- once a restaurant is open, trigger the related items to be available
DELIMITER //
CREATE TRIGGER status_after_open
AFTER UPDATE ON restaurant 
FOR EACH ROW
BEGIN
IF NEW.status = 'open'  THEN
UPDATE item
SET status = 'available' WHERE rid = NEW.rid;
END IF ;
END //
DELIMITER ;

-- CALL update_restaurant(3, 'permanently closed');

-- procedure to give a list of restaurant that are currently open
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE get_open_restaurant()
BEGIN
SELECT name, address, contactNo FROM restaurant 
WHERE status = 'open';
END //
DELIMITER ;

-- procedure to insert into item


DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE insert_item(item_id INT, name VARCHAR(255), description VARCHAR(255), price DOUBLE, status VARCHAR(20), rid INT)
BEGIN
INSERT INTO item VALUES (item_id, name, description, price, status, rid);
END //
DELIMITER ;


-- procedure to change the status or price of an item
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE update_item_status (id INT, status_ VARCHAR(20))
BEGIN
UPDATE item
SET status = status_ WHERE item_id = id;
END //
DELIMITER ;


DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE update_item_price (id INT, price_ DOUBLE)
BEGIN
UPDATE item
SET price = price_ WHERE item_id = id;
END //
DELIMITER ;


-- procedure to delete an item
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE delete_item (id INT)
BEGIN
DELETE FROM item WHERE item_id = id;
END //
DELIMITER ;

-- procedure to insert into staff
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE insert_staff (sid INT, fname VARCHAR(255), lname VARCHAR(255), status VARCHAR(20), position VARCHAR(20), rid INT)
BEGIN
INSERT INTO staff VALUES (sid, fname, lname, status, position, rid);
END //
DELIMITER ;


-- procedure to get all staff information
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE get_staff()
BEGIN
SELECT * FROM staff;
END //
DELIMITER ;

-- procedure to get information of a specific staff
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE get_sid_staff(sid_ INT)
BEGIN
SELECT * FROM staff WHERE sid = sid_;
END //
DELIMITER ;

-- procedure to get all staff information of a restaurant
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE get_rid_staff(rid_ INT)
BEGIN
SELECT * FROM staff WHERE rid = rid_;
END //
DELIMITER ;

-- procedure to get all staff information of a specific position of a restaurant
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE get_position_rid_staff(position_ VARCHAR(20), rid_ INT)
BEGIN
SELECT * FROM staff WHERE rid = rid_ AND position = position_;
END //
DELIMITER ;



-- procedure to update status or position of a staff
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE update_staff_status (sid_ INT, status_ VARCHAR(20))
BEGIN
UPDATE staff 
SET status = status_ WHERE sid = sid_;
END //
DELIMITER ;

DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE update_staff_position (sid_ INT, position_ VARCHAR(20))
BEGIN
UPDATE staff 
SET position = position_ WHERE sid = sid_;
END //
DELIMITER ;

-- procedure to insert into manager
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE insert_manager (phone CHAR(11), sid INT, user_id VARCHAR(40), password VARCHAR(20))
BEGIN
INSERT INTO manager VALUES (phone, sid, user_id, password);
END //
DELIMITER ;


-- If a manager is set blocked, trigger action to delete the record in manager table so that he/she won't have access to the database
DELIMITER //
CREATE TRIGGER delete_manager_after_update 
AFTER UPDATE ON staff
FOR EACH ROW
BEGIN
IF NEW.status != OLD.status THEN
	IF NEW.position = 'manager' AND NEW.status = 'blocked' THEN
		BEGIN
		DELETE FROM manager WHERE sid = NEW.sid;
		END;
    END IF;
END IF;
END //
DELIMITER ;

-- procedure to insert customer 
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE insert_customer(cid INT, fname VARCHAR(255), lname VARCHAR(255), address VARCHAR(255), phone CHAR(11))
BEGIN
INSERT INTO customer VALUES (cid, fname, lname, address, phone);
END //
DELIMITER ;


-- procedure to update customer address
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE update_customer_address(cid_ INT, address_ VARCHAR(255))
BEGIN
UPDATE customer
SET address = address_ WHERE cid = cid_;
END //
DELIMITER ;

-- procedure to delete a customer record
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE delete_customer (cid_ INT)
BEGIN
DELETE FROM customer WHERE cid = cid_;
END //
DELIMITER ;

-- procedure to insert orders
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE insert_orders(oid INT, orderDate Date, orderType VARCHAR(20), cid INT, sid  INT)
BEGIN 
INSERT INTO orders VALUES (oid, orderDate, orderType, cid, sid, 'uncompleted');
END //
DELIMITER ;



-- procedure to take orders for a specific order
-- input would be an order id with a list of items
-- error handling: the order can only be taken if all items are in the same restaurant and available

DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE take_orders (oid_ INT, item_id_ INT, quantity_ INT)
BEGIN
DECLARE staff_take_order INT;
DECLARE restaurant_of_staff INT;

SELECT MAX(sid) INTO staff_take_order FROM orders WHERE oid = oid_;
SELECT MAX(rid) INTO restaurant_of_staff FROM staff WHERE sid = staff_take_order;
SET @check_sql = CONCAT('SELECT MAX(rid)=', restaurant_of_staff, ' AS check_restaurant,  SUM(IF(status="not available", 1, 0))=0 AS check_available INTO @check_restaurant, @check_available FROM item WHERE item_id = ', item_id_, ';');
PREPARE stmt1 FROM @check_sql;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

IF @check_restaurant !=1 THEN 
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "Some or all items aren't from the selected restaurant";
-- SELECT "Some or all items aren't from the selected restaurant" AS message;
ELSEIF @check_available!= 1  THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "Some or all  items aren't available at the current time";
-- SELECT "Some or all  items aren't available at the current time." AS message;
ELSE 
INSERT INTO order_item (oid, item_id, quantity) VALUES (oid_, item_id_, quantity_)
ON DUPLICATE KEY UPDATE quantity = quantity+quantity_;

END IF;

END //
DELIMITER ;



-- procedure to delete item from an order
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE delete_ordered_item (oid_ INT, item_id_ INT, quantity_ INT)
BEGIN
DECLARE current_quantity INT;
DECLARE item_name VARCHAR(255);
SELECT quantity INTO current_quantity FROM order_item WHERE item_id = item_id_ and oid = oid_;
SELECT name INTO item_name FROM item WHERE item_id = item_id_;
IF current_quantity < quantity_ THEN
SELECT CONCAT("You delete more ", item_name, " than that currently have on your order");
ELSEIF current_quantity = quantity_ THEN
DELETE FROM order_item WHERE item_id = item_id_ AND oid = oid_;
ELSE 
UPDATE order_item 
SET quantity = quantity - quantity_ WHERE item_id = item_id_ AND oid = oid_;
END IF;
END //
DELIMITER ;

-- if the order has already been paid, any update, insert or delete operations are not allowed
DELIMITER //
CREATE TRIGGER prevent_insert_past_order
BEFORE INSERT ON order_item
FOR EACH ROW
BEGIN
DECLARE order_paid INT;
SELECT EXISTS(SELECT * FROM payment WHERE oid = NEW.oid) INTO order_paid;
IF order_paid = 1 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "This order has been paid. Modification is not allowed";
END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER prevent_update_past_order
BEFORE UPDATE ON order_item
FOR EACH ROW
BEGIN
DECLARE order_paid INT;
SELECT EXISTS(SELECT * FROM payment WHERE oid = NEW.oid) INTO order_paid;
IF order_paid = 1 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "This order has been paid. Modification is not allowed";
END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER prevent_delete_past_order
BEFORE DELETE ON order_item
FOR EACH ROW
BEGIN
DECLARE order_paid INT;
SELECT EXISTS(SELECT * FROM payment WHERE oid = OLD.oid) INTO order_paid;
IF order_paid = 1 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "This order has been paid. Modification is not allowed";
END IF;
END //
DELIMITER ;

-- procedure to read items in an order
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE get_ordered_items(oid INT)
BEGIN
SELECT DISTINCT(i.name), oi.quantity FROM order_item oi
INNER JOIN item i ON oi.item_id = i.item_id
;
END //
DELIMITER ;


-- procedure to insert into order_propares
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE insert_order_prepares(oid INT, chef_id INT)
BEGIN
DECLARE chef_status VARCHAR(20);
DECLARE chef_restaurant INT;
DECLARE order_restaurant INT;
SELECT MAX(s.rid) INTO order_restaurant FROM orders o LEFT JOIN staff s ON o.sid = s.sid WHERE o.oid = oid;
SELECT status, rid INTO chef_status, chef_restaurant FROM staff WHERE sid = chef_id;
IF chef_status!='active' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "The destinated chef is not currently available. Find another one";
ELSEIF chef_restaurant != order_restaurant THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "The destinated chef is not from the selected restaurant. Find another one";
ELSE 
INSERT INTO order_prepares VALUES (oid, chef_id);
END IF;
END //
DELIMITER ;


-- procedure to delete from  order_propares
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE delete_order_prepares(oid INT, chef_id INT)
BEGIN
DELETE FROM order_prepares WHERE oid = oid AND chef_id = chef_id;
END //
DELIMITER ;

-- if the order has already been paid, any update, insert or delete operations are not allowed
DELIMITER //
CREATE TRIGGER prevent_insert_past_order_chef
BEFORE INSERT ON order_prepares
FOR EACH ROW
BEGIN
DECLARE order_paid INT;
SELECT EXISTS(SELECT * FROM payment WHERE oid = NEW.oid) INTO order_paid;
IF order_paid = 1 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "This order has been paid. Modification is not allowed";
END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER prevent_delete_past_order_chef
BEFORE DELETE ON order_prepares
FOR EACH ROW
BEGIN
DECLARE order_paid INT;
SELECT EXISTS(SELECT * FROM payment WHERE oid = OLD.oid) INTO order_paid;
IF order_paid = 1 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "This order has been paid. Modification is not allowed";
END IF;
END //
DELIMITER ;

-- procedure to insert into payment

DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE insert_payment(pid INT, paymentTime DATETIME, amount DOUBLE, discount DOUBLE, paymentType VARCHAR(20), cid INT, oid INT)
BEGIN
INSERT INTO payment VALUES (pid, paymentTime, amount, discount, paymentType, cid, oid);
END //
DELIMITER ;

-- procedure to cancel a payment
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE delete_payment(pid_ INT)
BEGIN
DELETE FROM payment WHERE pid = pid_;
END //
DELIMITER ;



-- if a payment is cancelled, the relevant order should be marked as uncompleted
DELIMITER //
CREATE TRIGGER uncomplete_order_payment_cancel
AFTER DELETE ON payment
FOR EACH ROW
BEGIN
UPDATE orders
SET status='uncompleted' WHERE oid = OLD.oid;
END //
DELIMITER ;

-- procedure to get payments of a specific customer
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE get_customer_payments(cid_ INT)
BEGIN
SELECT pid, paymentType, amount, discount, paymentType, oid FROM payment 
WHERE cid = cid_;
END //
DELIMITER ;

-- procedure to get payments a restaurant received 
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE get_rid_payments(rid_ INT)
BEGIN
SELECT p.pid, p.paymentType, p.amount, p.discount, p.paymentType, p.oid, p.cid FROM payment p
LEFT JOIN orders o ON o.oid = p.oid
LEFT JOIN staff s ON o.sid = s.sid
WHERE s.rid = rid_;
END //
DELIMITER ;

-- procedure to insert into delivery
DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE insert_delivery(tracking CHAR(40), address VARCHAR(255), estimated DATETIME, delivered DATETIME, oid INT)
BEGIN
INSERT INTO delevery VALUES (tracking, address, estimated, delivered, oid);
END //
 DELIMITER ;
 
 -- procedure to delete from delivery
 DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE delete_delivery (oid INT)
BEGIN
DECLARE delivered DATETIME;
SELECT MAX(deliveredTime) INTO delivered FROM delivery WHERE oid = oid;
IF delivered IS NOT NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "Delivered orders can not be deleted";
ELSE
DELETE FROM delivery WHERE oid = oid;
END IF;
END //
DELIMITER ;

 -- procedure to delete from delivery
 DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE get_delivery_info(oid_ INT)
BEGIN
DECLARE records INT;
SELECT COUNT(*) INTO records FROM delivery WHERE oid = oid_;
IF records = 0 THEN
SELECT "No tracking information found";
ELSE 
SELECT * FROM delivery WHERE oid = oid_;
END IF;
END //
DELIMITER ;
 
 
 -- mark a dine-in order as completed if payment is logged
 DELIMITER //
CREATE TRIGGER complete_order
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
UPDATE orders
SET status = 'completed' WHERE oid = NEW.oid;
END //
DELIMITER ;


-- procedure to return the list of items for a given customer for specific restaurant
 DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE return_customer_past_orders(cid_ INT, rid_ INT)
BEGIN
SELECT DISTINCT(i.name) FROM order_item oi
LEFT JOIN item i ON i.item_id = oi.item_id
LEFT JOIN orders o ON o.oid = oi.oid
LEFT JOIN staff s ON o.sid = s.sid
WHERE s.rid = rid_ AND o.cid = cid_;
END //
DELIMITER ;

-- procedure to return the top 3 items get ordered for each restaurant that is not permanently closed
 DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE return_top_ordered_item()
BEGIN
SELECT item, total_ordered, restaurant FROM (
SELECT  i.name AS item, oi.total_ordered, r.name AS restaurant, 
ROW_NUMBER() OVER (PARTITION BY r.rid ORDER BY oi.total_ordered DESC) AS rn 
FROM (SELECT item_id,SUM(quantity) AS total_ordered FROM order_item GROUP BY item_id) AS oi
LEFT JOIN item i ON oi.item_id = i.item_id
LEFT JOIN restaurant r ON i.rid = r.rid
WHERE r.status != 'permanently closed') tmp
WHERE rn <= 3
ORDER BY restaurant, rn
;
END //
DELIMITER ;



-- Function to return the number of orders in given period
DELIMITER //
CREATE FUNCTION get_num_orders(from_ DATE, to_ DATE)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
DECLARE num_orders INT;
SELECT COUNT(*) INTO num_orders FROM orders 
WHERE orderDATE BETWEEN from_ AND to_;
RETURN(num_orders);
END //
DELIMITER ;

-- FUNCTION to return the number of total orders for a customer
DELIMITER //
CREATE FUNCTION get_all_orders_customer(cid_ INT)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
DECLARE total_orders INT;
SELECT COUNT(*) INTO total_orders FROM orders
WHERE cid = cid_;
RETURN(total_orders);
END //
DELIMITER ;

-- FUNCTION to get total values of item sold by a restuarant
DELIMITER //
CREATE FUNCTION total_amount(rid_ INT)
RETURNS DOUBLE
DETERMINISTIC READS SQL DATA
BEGIN
DECLARE total DOUBLE;
SELECT SUM(oi.total_ordered*i.price) INTO total FROM 
(SELECT item_id,SUM(quantity) AS total_ordered FROM order_item GROUP BY item_id) oi
LEFT JOIN item i ON oi.item_id = i.item_id
WHERE i.rid = rid_;
RETURN(total);
END //
DELIMITER ;

-- procedure to get number of orders each month for a given restaurant 
 DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE get_monthly_num_orders(rid_ INT)
BEGIN
SELECT COUNT(*) AS num_orders, CONCAT(year, '-', month) AS time, name AS restaurant FROM 
(SELECT sid, YEAR(orderDate) AS year, MONTH(orderDate) AS month FROM orders) o
LEFT JOIN staff s ON o.sid = s.sid
LEFT JOIN restaurant r ON s.rid = r.rid
WHERE r.rid = rid_
GROUP BY o.year, o.month, r.name;


END //
DELIMITER ;

-- orders that remains uncompleted for more than 1 month is aborted
DELIMITER //
CREATE EVENT monthly_abort_unfinished_orders
ON SCHEDULE EVERY 1 MONTH
STARTS '2020-01-01'
DO BEGIN
UPDATE orders
SET status = 'aborted' 
WHERE orderDate < NOW() - INTERVAL 1 MONTH AND status = 'uncompleted';
END //
DELIMITER ;

-- Only managers who are assigned user id and password have authorization to access staff info
DELIMITER //
CREATE FUNCTION check_author(user_id_ VARCHAR(255), pwd VARCHAR(255))
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
DECLARE authorized INT;
SELECT EXISTS(SELECT * FROM manager WHERE user_id = user_id_ AND password = pwd) INTO authorized ;
RETURN (authorized);
END //
DELIMITER ;

-- Procedure to show all item of a restaurant
 DELIMITER // 
CREATE DEFINER=`root`@`localhost` PROCEDURE show_menu(rid_ INT)
BEGIN
SELECT item_id, name, description, price, status FROM item WHERE rid  = rid_;
END //
DELIMITER ;





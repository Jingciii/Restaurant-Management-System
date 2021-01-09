import numpy as np
from collections import defaultdict
from array import array
from datetime import date, datetime

import pymysql
import flask

def set_credentials():
    host = str(input("Please provide host name (enter return if using default): "))
    user = str(input("Please provide user name (enter return if using default): "))
    password = str(input("Please provide password (enter return if using default): "))
    if not host:
        host = 'localhost'
    if not user:
        user = 'root'
    if not password:
        password = 'wjc4191D'
    return host, user, password

def get_connection(host, user, password):
    try:
        cnx = pymysql.connect(host=host, user=user, password=password,
                 db='RestaurantDB',charset='utf8mb4',cursorclass=pymysql.cursors.DictCursor )
    except pymysql.err.OperationalError:
        print("Error: %d: %s" % (e.args[0], e.args[1]))
    return cnx

# def initDB():
# 	host, user, password = set_credentials()
# 	cnx = get_connection(host, user, password)

host, user, password = set_credentials()
cnx = get_connection(host, user, password)

def displayMainMenu():
    print("— — — — MENU — — — -" )
    print("1. Login/Signup")
    print("2. Take Order")
    print("3. Get Order Details")
    print("4. Place an Order")
    print("5. Cancel an Payment")
    print("6. Restaurant Management")
    print("7. Show Summary")
    print("8. Exit")
    print("— — — — — — — — — —")

def exit():
    n = int(input("Press 8 to exit: "))
    if n == 8: 
        run()
    else:
        print("-- Invalid Option --")
        exit()

###### 1. Register
def userMenu():
    print("You are a")
    print("1. Customer")
    print("2. staff")
def register_customer():
	print("Start registering new customer")
	cid = int(input('Enter customer Id: '))
	fname = str(input("Enter your first name: "))
	lname = str(input("Enter your last name: "))
	address = str(input("Enter your address: "))
	phone = str(input("Enter your contact number: "))
	try:
		cur = cnx.cursor()
		cur.callproc('insert_customer', args=(cid, fname, lname, address, phone))
		cnx.commit()
		print(' — — — SUCCESS — — — \n')
	except pymysql.Error as e:
		print("could not insert into customer error pymysql %d: %s" %(e.args[0], e.args[1]))
		pass
def update_customer_address():
	print("Start updating your address")
	cid = int(input('Enter customer Id: '))
	address = str(input("Enter your new address: "))
	try:
		cur = cnx.cursor()
		cur.callproc('update_customer_address', args=(cid, address))
		cnx.commit()
		print(' — — — SUCCESS — — — \n')
	except pymysql.Error as e:
		print("could not update customer error pymysql %d: %s" %(e.args[0], e.args[1]))
		pass
def customerManageMenu():
	print("-- Select an option --")
	print("1. Register as new customer")
	print("2. Exsiting customer. Want to update address")
def customerManage():
	n = int(input("Enter Option: "))
	if n == 1:
		register_customer()
	elif n == 2: 
		update_customer_address()
	else:
		print("-- Invalid Option --")
	exit()
def register_staff():
	print("Start registering new hired staff")
	sid = int(input("Enter staff id: "))
	fname = str(input("Enter your first name: "))
	lname = str(input("Enter your last name: "))
	position = str(input("Enter your position to be registered: "))
	rid = int(input("Enter the restaurant Id you are registering at: "))
	try:
		cur = cnx.cursor()
		cur.callproc('insert_staff', args=(sid, fname, lname, 'active', position, rid))
		cnx.commit()
		print(' — — — SUCCESS — — — \n')
	except pymysql.Error as e:
		print("could not insert into staff error pymysql %d: %s" %(e.args[0], e.args[1]))
		pass
def update_staff_position():
	print("Check Authorization")
	user_id = str(input("Enter your user_id: "))
	password = str(input("Enter your password: "))
	funcQuery = "SELECT check_author(%s, %s)"
	check_cursor = cnx.cursor()
	check_cursor.execute(funcQuery, (user_id, password))
	for result in check_cursor.fetchone().values():
		authorized = result
#	print("authro:", authorized)
	if authorized == 1: 
		print("Start updating staff position")
		sid = int(input("Enter staff id: "))
		position = str(input("Enter the position the staffing is becoming: "))
		try:
			cur = cnx.cursor()
			cur.callproc('update_staff_position', args=(sid, position))
			cnx.commit()
			print(' — — — SUCCESS — — — \n')
		except pymysql.Error as e:
			print("could not update staff error pymysql %d: %s" %(e.args[0], e.args[1]))
			pass
	else:
		print("You do not have permission to update staff position")
def update_staff_status():
	print("Check Authorization")
	user_id = str(input("Enter your user_id: "))
	password = str(input("Enter your password: "))
	funcQuery = "SELECT check_author(%s, %s)"
	check_cursor = cnx.cursor()
	check_cursor.execute(funcQuery, (user_id, password))
	for result in check_cursor.fetchone().values():
		authorized = result
#	print("authro:", authorized)
	if authorized == 1:
		print("Start updating staff status")
		sid = int(input("Enter staff id: "))
		status = str(input("Enter the status the staffing is turning into: "))
		try:
			cur = cnx.cursor()
			cur.callproc('update_staff_status', args=(sid, status))
			cnx.commit()
			print(' — — — SUCCESS — — — \n')
		except pymysql.Error as e:
			print("could not update staff error pymysql %d: %s" %(e.args[0], e.args[1]))
			pass
	else: 
		print("You do not have permission to update staff status")
def staffManageMenu():
	print("-- Select an option --")
	print("1. Register for new hired staff")
	print("2. Staff position change")
	print("3. Staff status change")
def staffManage():
	n = int(input("Enter Option: "))
	if n == 1:
		register_staff()
	elif n == 2:
		update_staff_position()
	elif n == 3:
		update_staff_status()
	else:
		print("-- Invalid Option --")
	exit()
def userManage():
	n = int(input("Enter Option: "))
	if n == 1:
		customerManageMenu()
		customerManage()
	elif n == 2:
		staffManageMenu()
		staffManage()
	else:
		print("-- Invalid Option --")
	exit()

###### 2 take order
def show_menu():
	print("Searching for the Menu")
	rid = int(input("Enter the restaurant Id you want to find Menu from: "))
	cur = cnx.cursor()
	cur.execute('CALL show_menu(%s)', (rid))
	for result in cur.fetchall():
		print(result)
	print(' — — — DONE — — — \n')
def create_order():
	print("Start creating an order")
	oid = int(input("Enter an order id: "))
	orderDate = date.today()
	orderType = str(input('Select an dining option (Dine-in or Delivery): '))
	cid = int(input("Enter your customer Id: "))
	sid = int(input("Enter the staff id who is serving this order: "))
	try:
		cur = cnx.cursor()
		cur.callproc('insert_orders', (oid, orderDate, orderType, cid, sid))
		cnx.commit()
		print(' — — — SUCCESS — — — \n')
	except pymysql.Error as e:
		print("could not insert into order error pymysql %d: %s" %(e.args[0], e.args[1]))
		pass
def add_item_to_order():
	oid = int(input("Enter an order id: "))
	item_id = int(input("Enter the item id you'd like to add: "))
	quantity = int(input("Enter the quantity of this item you want to order: "))
	cur = cnx.cursor()
	cur.callproc('take_orders', (oid, item_id, quantity))
	cnx.commit()
	print(' — — — SUCCESS — — — \n')
def delete_item_from_order():
	oid = int(input("Enter an order id: "))
	item_id = int(input("Enter the item id you'd like to delete: "))
	quantity = int(input("Enter the quantity of this item you want to delete from order: "))
	cur = cnx.cursor()
	cur.callproc('delete_ordered_item', (oid, item_id, quantity))
	cnx.commit()
	print(' — — — SUCCESS — — — \n')

def order_actions():
	print("What do you want")
	print("1. Add item")
	print("2. DELETE item")
def order_taking():
	continuing = True
	while continuing:
		order_actions()
		n = int(input("Enter Option: "))
		if n == 1:
			try:
				add_item_to_order()
			except pymysql.Error as e:
				cnx.rollback()
				print("Fail to add item -- {0}: {1}".format(e.args[0], e.args[1]))
				pass
		elif n == 2: 
			try:
				delete_item_from_order()
			except pymysql.Error as e:
				cnx.rollback()
				print("Fail to add item -- {0}: {1}".format(e.args[0], e.args[1]))
				pass
		else:
			print("-- Invalid Option --")
		finish = int(input("If finished ordering, enter 0, else 1: "))
		if finish == 0:
			continuing = False

def takeOrderMenu():
	print("-- Select an operation --")
	print("1. Show Menu")
	print("2. Create an order")
	print("3. Adjust order")
def takeOrderManage():
	n = int(input("Enter Option: "))
	if n == 1: 
		show_menu()
	elif n == 2:
		create_order()
	elif n == 3: 
		order_taking()
	else:
		print("-- Invalid Option --")
	exit()

###### 3. get order details
def show_ordered_item():
	print("Show the items currently in a giving order")
	oid = int(input('Enter the order id you want to check: '))
	cur = cnx.cursor()
	cur.execute('CALL get_ordered_items(%s)', (oid))
	for result in cur.fetchall():
		print(result)
	print(' — — — DONE — — — \n')
def show_tracking():
	print("Search for tracking information")
	oid = int(input("Enter the order id you'd like to find tracking information: "))
	cur = cnx.cursor()
	cur.execute("CALL get_delivery_info(%s)", (oid))
	for result in cur.fetchall():
		print(result)
	print(' — — — DONE — — — \n')

def orderDetailMenu():
	print("-- Select an operation --")
	print("1. Show ordered items")
	print("2. Show tracking information")
def orderDetailManage():
	n = int(input("Enter Option: "))
	if n == 1:
		show_ordered_item()
	elif n == 2:
		show_tracking()
	else:
		print("-- Invalid Option --")
	exit()

###### 4. Place an order
def place_order():
	print("Start placing your order")
	pid = int(input("Enter an payment Id: "))
	paymentTime = datetime.now()
	amount = float(input("Enter the total amount you are placing (including tips): "))
	discount = float(input("Enter the discount that applied to this order: "))
	print({'paymentType': ['cash', 'check', 'credit card', 'debit card']})
	paymentType = str(input("Select a payment type above: "))
	cid = int(input("Enter your customer Id: "))
	oid = int(input("Enter the order Id you are placing order: "))
	try:
		cur = cnx.cursor()
		cur.callproc('insert_payment', (pid, paymentTime, amount, discount, paymentType, cid, oid))
		cnx.commit()
		print(' — — — SUCCESS — — — \n')
	except pymysql.Error as e:
		print("could not insert into payment error pymysql %d: %s" %(e.args[0], e.args[1]))
		pass
	exit()

###### 5. Cancel a payment
def cancel_payment():
	print("Check Authorization")
	user_id = str(input("Enter your user_id: "))
	password = str(input("Enter your password: "))
	funcQuery = "SELECT check_author(%s, %s)"
	check_cursor = cnx.cursor()
	check_cursor.execute(funcQuery, (user_id, password))
	for result in check_cursor.fetchone().values():
		authorized = result
	check_cursor.close()
	if authorized == 1:
		print("Start canceling a payment")
		pid = int(input("Enter the payment Id you want to cancel: "))
		try:
			cur = cnx.cursor()
			cur.callproc('delete_payment', args = (pid,))
			cnx.commit()
			print(' — — — SUCCESS — — — \n')
		except pymysql.Error as e:
			print("could not delete from payment error pymysql %d: %s" %(e.args[0], e.args[1]))
			pass
	else: 
		print("You do not have permission to delete a payment")
	exit()




###### 6. Restaurant Management
def restaurantManageMenu():
	print("-- Select an operation --")
	print("1. Add new restaurant")
	print("2. Change restaurant status")
	print("3. Get staff information")
	print("4. Get MENU")
	print("5. Modify MENU")
def modifyMenu():
	print("-- Select an operation --")
	print("1. Insert an item")
	print("2. Change status of an item")
	print("3. Change price of an item")
def insert_item():
	print("Check Authorization")
	user_id = str(input("Enter your user_id: "))
	password = str(input("Enter your password: "))
	funcQuery = "SELECT check_author(%s, %s)"
	check_cursor = cnx.cursor()
	check_cursor.execute(funcQuery, (user_id, password))
	for result in check_cursor.fetchone().values():
		authorized = result
	if authorized == 1:
		item_id = int(input("Enter an item Id: "))
		name = str(input("Enter a name for the item: "))
		description = str(input("Enter a description for the item: "))
		price = float(input("Enter the price of the item: "))
		status = "available"
		rid = int(input("Enter the restaurant Id that provide this item: "))
		try:
			cur = cnx.cursor()
			cur.callproc('insert_item', (item_id, name, description, price, status, rid))
			cnx.commit()
			print(' — — — SUCCESS — — — \n')
		except pymysql.Error as e:
			print("could not insert into item error pymysql %d: %s" %(e.args[0], e.args[1]))
			pass
	else:
		print("You do not have permission to insert items")
def change_item_status():
	print("Check Authorization")
	user_id = str(input("Enter your user_id: "))
	password = str(input("Enter your password: "))
	funcQuery = "SELECT check_author(%s, %s)"
	check_cursor = cnx.cursor()
	check_cursor.execute(funcQuery, (user_id, password))
	for result in check_cursor.fetchone().values():
		authorized = result
	if authorized == 1:
		item_id = int(input("Enter an item Id: "))
		status = str(input("Enter the status the item will become: "))
		try:
			cur = cnx.cursor()
			cur.callproc('update_item_status', (item_id, status))
			cnx.commit()
			print(' — — — SUCCESS — — — \n')
		except pymysql.Error as e:
			print("could not update item error pymysql %d: %s" %(e.args[0], e.args[1]))
			pass
	else:
		print("You do not have permission to modify the item status")
def change_item_price():
	print("Check Authorization")
	user_id = str(input("Enter your user_id: "))
	password = str(input("Enter your password: "))
	funcQuery = "SELECT check_author(%s, %s)"
	check_cursor = cnx.cursor()
	check_cursor.execute(funcQuery, (user_id, password))
	for result in check_cursor.fetchone().values():
		authorized = result
	check_cursor.close()
	if authorized == 1:	
		item_id = int(input("Enter an item Id: "))
		price = float(input("Enter the new price: "))
		try:
			cur = cnx.cursor()
			cur.callproc('update_item_price', (item_id, price))
			cnx.commit()
			print(' — — — SUCCESS — — — \n')
		except pymysql.Error as e:
			print("could not update item error pymysql %d: %s" %(e.args[0], e.args[1]))
			pass
	else:
		print("You do not have permission to modify the item price")
def modifyMenuManage():
	n = int(input("Enter Option: "))
	if n == 1:
		insert_item()
	elif n == 2:
		change_item_status()
	elif n == 3:
		change_item_price()
	else:
		print("-- Invalid Option --")


def restaurantManage():
	n = int(input("Enter Option: "))
	if n == 1:
		print("Check Authorization")
		user_id = str(input("Enter your user_id: "))
		password = str(input("Enter your password: "))
		funcQuery = "SELECT check_author(%s, %s)"
		check_cursor = cnx.cursor()
		check_cursor.execute(funcQuery, (user_id, password))
		for result in check_cursor.fetchone().values():
			authorized = result
		if authorized == 1:
			print("Start inserting new restaurant")
			rid = int(input("Enter restaurant Id: "))
			name = str(input("Enter restaurant name: "))
			address = str(input("Enter restaurant address: "))
			contactNo = str(input("Enter restaurant contact Number: "))
			try:
				cur = cnx.cursor()
				cur.callproc('insert_restaurant', args=(rid, name, address, contactNo, 'open'))
				cnx.commit()
				print(' — — — SUCCESS — — — \n')
			except pymysql.Error as e:
				print("could not insert into restaurant error pymysql %d: %s" %(e.args[0], e.args[1]))
				pass
		else:
			print("You have no permission to insert into restaurant")
	elif n == 2:
		print("Check Authorization")
		user_id = str(input("Enter your user_id: "))
		password = str(input("Enter your password: "))
		funcQuery = "SELECT check_author(%s, %s)"
		check_cursor = cnx.cursor()
		check_cursor.execute(funcQuery, (user_id, password))
		for result in check_cursor.fetchone().values():
			authorized = result
		if authorized == 1:
			print("Start updating restaurant status")
			rid = int(input("Enter restaurant Id: "))
			status = str(input("Enter the current restaurant status: "))
			try:
				cur = cnx.cursor()
				cur.callproc('update_restaurant', args=(rid, status))
				cnx.commit()
				print(' — — — SUCCESS — — — \n')
			except pymysql.Error as e:
				print("could not update restaurant error pymysql %d: %s" %(e.args[0], e.args[1]))
				pass
		else:
			print('You have no permission to update restaurant')
	elif n == 3: 
		print("Check Authorization")
		user_id = str(input("Enter your user_id: "))
		password = str(input("Enter your password: "))
		funcQuery = "SELECT check_author(%s, %s)"
		check_cursor = cnx.cursor()
		check_cursor.execute(funcQuery, (user_id, password))
		for result in check_cursor.fetchone().values():
			authorized = result
		print("authro:", authorized)
		check_cursor.close()
		if authorized == 1:
			print("Find staff information")
			cur = cnx.cursor()
			rid = int(input("Enter the restaurant Id you are searching staffs from: "))
			cur.execute('CALL get_rid_staff(%s)', (rid))
			for result in cur.fetchall():
				print(result)
			print(' — — — DONE — — — \n')	
		else:
			print("You do not have permission for staff information")
	elif n == 4:
		show_menu()
	elif n == 5:
		modifyMenu()
		modifyMenuManage()
	else:
		print("-- Invalid Option --")
	exit()

###### 7. show summary
def get_top3_ordered_item():
	print("Preparing top 3 items ordered most for each restaurant that isn't permanently closed")
	cur = cnx.cursor()
	cur.execute('CALL return_top_ordered_item')
	for result in cur.fetchall():
		print(result)
	print(' — — — DONE — — — \n')	
def get_num_orders_within():
	print("Get number of orders within certain period")
	from_ = str(input("Enter a start date in yyyy-mm-dd format: "))
	to_ = str(input("Enter an end date in yyyy-mm-dd format: "))
	cur = cnx.cursor()
	query = "select get_num_orders(%s, %s) AS order_counts;"
	cur.execute(query, (from_, to_))
	for result in cur.fetchall():
		print(result)
	print(' — — — DONE — — — \n')

def get_past_orders_customer():
	print("Get all past orders for a given customer in a given restaurant")
	cid = int(input("Enter the customer Id: "))
	rid = int(input("Enter the restaurant Id you want to find out: "))
	cur = cnx.cursor()
	cur.execute("CALL return_customer_past_orders(%s, %s)", (cid, rid))
	for result in cur.fetchall():
		print(result)
	print(' — — — DONE — — — \n')

def get_monthly_report():
	print("Get a monthly report for the number of orders in a restaurant")
	rid = int(input("Enter the restaurant Id you want to find out: "))
	cur = cnx.cursor()
	cur.execute("CALL get_monthly_num_orders(%s)", (rid))
	for result in cur.fetchall():
		print(result)
	print(' — — — DONE — — — \n')

def summaryMenu():
	print("-- Select an operation --")
	print("1. Get the top 3 items ordered most for operated restaurants")
	print("2. Get the number of orders in given period")
	print("3. Get all past orders for a customer in a restaurant")
	print("4. Get monthly number of orders for a restaurant")
def summaryManage():
	n = int(input("Enter Option: "))
	if n == 1:
		get_top3_ordered_item()
	elif n == 2:
		get_num_orders_within()
	elif n == 3:
		get_past_orders_customer()
	elif n == 4: 
		get_monthly_report()
	else:
		print("-- Invalid Option --")
	exit()


def run():
    displayMainMenu()
    n = int(input("Enter Option: "))
    if n == 1:
        userMenu()
        userManage()
    elif n == 2: 
    	takeOrderMenu()
    	takeOrderManage()
    elif n == 3:
    	orderDetailMenu()
    	orderDetailManage()
    elif n == 4: 
    	place_order()
    elif n == 5:
    	cancel_payment()
    elif n == 6:
    	restaurantManageMenu()
    	restaurantManage()
    elif n == 7:
    	summaryMenu()
    	summaryManage()
    elif n == 8:
    	print("---- THANK YOU ----")
    	cnx.close()
    else:
        run()







if __name__ == '__main__':
	

	#initDB()
	run()


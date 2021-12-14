from typing import Iterable
from application import app
from db import *
from flask import render_template, url_for, flash, redirect, request, jsonify
from forms import RegistrationForm, LoginForm, ScheduleFlightForm, AddPropertyForm
from datetime import date

current_date = '1999-01-01'

username = ''
adminAccess = False
customerAccess = False
ownerAccess = False


#######################################################
# Main Pages
#######################################################
@app.route("/")
@app.route("/home")
def home():
    return render_template("home.html", homebar=0, username=username)

@app.route("/about")
def about():
    return render_template("about.html", homebar=1, username=username)

@app.route("/account")
def account():
    if username == '':
        return redirect(url_for('home'))
    q = text("SELECT * FROM accounts WHERE Email=\'{0}\'".format(username))
    userdata = connection.execute(q)
    return render_template("account.html", userdata=userdata, current_date=current_date, homebar=2, username=username, adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route("/login", methods=['GET', 'POST'])
def login():
    global username
    global adminAccess
    global ownerAccess
    global customerAccess
    form = LoginForm()
    if form.validate_on_submit():
        email = form.email.data
        password = form.password.data
        q = text("SELECT * FROM accounts WHERE Email=\'{0}\' AND Pass=\'{1}\'".format(email, password))
        result = connection.execute(q)
        if result.rowcount != 0:
            q = text("SELECT * FROM admins WHERE Email=\'{0}\'".format(email))
            result = connection.execute(q)
            adminAccess = True if result.rowcount != 0 else False
            q = text("SELECT * FROM owners WHERE Email=\'{0}\'".format(email))
            result = connection.execute(q)
            ownerAccess = True if result.rowcount != 0 else False
            q = text("SELECT * FROM customer WHERE Email=\'{0}\'".format(email))
            result = connection.execute(q)
            customerAccess = True if result.rowcount != 0 else False
            username = email
            return redirect(url_for('account'))
        else:
            flash('Login Unsuccessful. Please check username and password', 'danger')
    return render_template("login.html", homebar=-1, username=username, form=form)

@app.route("/register", methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        email = request.form['email']
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        password = request.form['password']
        phone_number = request.form['phone_number']
        card = request.form['card']
        cvv = request.form['cvv']
        exp = request.form['exp']
        location = request.form['location']
        if card and cvv and exp and location:
            type = 'Customer'
            q = text("call register_customer(\'{0}\', \'{1}\', \'{2}\', \'{3}\', \'{4}\', \'{5}\',\'{6}\',\'{7}\',\'{8}\')".format(email, first_name, last_name, password, phone_number, card, cvv, exp, location))
        else:
            type = 'Owner'
            q = text("call register_owner(\'{0}\', \'{1}\', \'{2}\', \'{3}\', \'{4}\')".format(email, first_name, last_name, password, phone_number))
        try:
            connection.execute(q)
            connection.execute("commit")
            flash(f'{type} account created for {form.email.data}!', 'success')
            return redirect(url_for('home'))
        except Exception as e:
            flash(e)
    return render_template("register.html", homebar=-1, username=username, form=form)

#######################################################
# Customer Access
#######################################################
@app.route("/my_bookings")
def my_bookings():
    q = text('SELECT * FROM book NATURAL JOIN flight WHERE Customer=\'{0}\' AND ((Flight_Date < \'{1}\') OR (Flight_Date = \'{1}\' AND Was_Cancelled = 1))'.format(username, current_date))
    past_bookings = connection.execute(q)
    q = text('SELECT * FROM book NATURAL JOIN flight WHERE Customer=\'{0}\' AND Flight_Date = \'{1}\' AND Was_Cancelled = 0'.format(username, current_date))
    today_bookings = connection.execute(q)
    q = text('SELECT * FROM book NATURAL JOIN flight WHERE Customer=\'{0}\' AND Flight_Date > \'{1}\''.format(username, current_date))
    future_bookings = connection.execute(q)
    return render_template("customer/my_bookings.html", past_bookings=past_bookings, today_bookings=today_bookings, future_bookings=future_bookings, homebar=3, username=username, pageSelect='my_bookings', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route("/my_reservations")
def my_reservations():
    q = text("SELECT * FROM customers_rate_owners AS O RIGHT OUTER JOIN reserve AS R ON R.Owner_Email = O.Owner_Email AND R.Customer = O.Customer LEFT OUTER JOIN property AS P ON R.Owner_Email = P.Owner_Email AND R.Property_Name = P.Property_Name WHERE R.Customer=\'{0}\' AND ((End_Date < \'{1}\') OR (\'{1}\' BETWEEN Start_Date AND End_Date AND Was_Cancelled = 1))".format(username, current_date))
    past_reservations = connection.execute(q)
    q = text("SELECT * FROM reserve NATURAL JOIN property WHERE Customer=\'{0}\' AND \'{1}\' BETWEEN Start_Date AND End_Date AND Was_Cancelled = 0".format(username, current_date))
    current_reservation = connection.execute(q)
    q = text("SELECT * FROM reserve NATURAL JOIN property WHERE Customer=\'{0}\' AND Start_Date > \'{1}\'".format(username, current_date))
    future_reservations = connection.execute(q)
    return render_template("customer/my_reservations.html", past_reservations=past_reservations, current_reservation=current_reservation, future_reservations=future_reservations, homebar=3, username=username, pageSelect='my_reservations', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route("/book")
def book():
    q = text("SELECT * FROM view_flight AS V JOIN flight AS F ON airline=Airline_Name AND flight_id=Flight_Num WHERE F.Flight_Date > \'{0}\'".format(current_date))
    flight_view = connection.execute(q)
    return render_template("customer/book.html", table_data=flight_view, homebar=3, username=username, pageSelect='book', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route("/reserve")
def reserve():
    q = text("SELECT * FROM view_properties")
    property_view = connection.execute(q)
    return render_template("customer/reserve.html", table_data=property_view, homebar=3, username=username, pageSelect='reserve', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

#######################################################
# Owner Access
#######################################################
@app.route("/my_properties", methods=['GET', 'POST'])
def my_properties():
    form = AddPropertyForm()
    state_names = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY', 'DC', 'AS', 'GU', 'MP', 'PR', 'UM', 'VI']
    form.state.choices = [states for states in state_names]
    if request.method == 'POST':
        if form.validate_on_submit(): 
            property_name = request.form['property_name']
            description = request.form['description']
            capacity = request.form['capacity']
            cost = request.form['cost']
            street = request.form['street']
            city = request.form['city']
            state = request.form['state']
            zipcode = request.form['zipcode']
            nearest_airport_id = request.form['nearest_airport_id']
            dist_to_airport = request.form['dist_to_airport']
            q = text("CALL add_property(\'{0}\', \'{1}\', \'{2}\', {3}, {4}, \'{5}\', \'{6}\', \'{7}\', \'{8}\', \'{9}\', {10})".format(property_name, username, description, capacity, cost, street, city, state, zipcode, nearest_airport_id, dist_to_airport))
            try:
                connection.execute(q)
                connection.execute("commit")
                return redirect(url_for('my_properties'))
            except Exception as e:
                flash(e)
    q = text("SELECT * FROM view_properties NATURAL JOIN property WHERE Owner_Email=\'{0}\'".format(username))
    properties_view = connection.execute(q)
    return render_template("owner/my_properties.html", form=form, table_data=properties_view, homebar=3, username=username, pageSelect='my_properties', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

#######################################################
# Administrative Access
#######################################################
@app.route("/view_airports")
def view_airports():
    q = text("SELECT * FROM view_airports_condensed")
    airport_view = connection.execute(q)
    return render_template("admin/view_airports.html", table_data=airport_view, homebar=3, username=username, pageSelect='view_airports', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route("/view_airlines")
def view_airlines():
    q = text("SELECT * FROM view_airlines")
    airline_view = connection.execute(q)
    return render_template("admin/view_airlines.html", table_data=airline_view, homebar=3, username=username, pageSelect='view_airlines', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route("/view_flights")
def view_flights():
    q = text("SELECT * FROM flight JOIN view_flight ON Flight_Num=flight_id AND Airline_Name=airline")
    flight_view = connection.execute(q)
    return render_template("admin/view_flights.html", table_data=flight_view, homebar=3, username=username, pageSelect='view_flights', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route("/view_customers")
def view_customers():
    q = text("SELECT * FROM view_customers")
    customer_view = connection.execute(q)
    return render_template("admin/view_customers.html", table_data=customer_view, homebar=3, username=username, pageSelect='view_customers', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)
    
@app.route("/view_owners")
def view_owners():
    q = text("SELECT * FROM view_owners")
    owner_view = connection.execute(q)
    return render_template("admin/view_owners.html", table_data=owner_view, homebar=3, username=username, pageSelect='view_owners', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route("/view_properties")
def view_properties():
    q = text("SELECT * FROM view_properties NATURAL JOIN property")
    property_view = connection.execute(q)
    return render_template("admin/view_properties.html", table_data=property_view, homebar=3, username=username, pageSelect='view_properties', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route('/schedule_flight', methods = ['GET', 'POST'])
def schedule_flight():
    print(current_date)
    q = text("SELECT airline_name FROM view_airlines")
    airline_view = connection.execute(q)
    form = ScheduleFlightForm()
    form.airline_name.choices = [airline[0] for airline in airline_view]
    form.current_date.default = current_date
    form.process()
    if request.method == 'POST': 
        flight_num = request.form['flight_num']
        airline_name = request.form['airline_name']
        from_airport = request.form['from_airport']
        to_airport = request.form['to_airport']
        departure_time = request.form['departure_time']
        arrival_time = request.form['arrival_time']
        flight_date = request.form['flight_date']
        cost = request.form['cost']
        capacity = request.form['capacity']
        q = text("call schedule_flight(\'{0}\', \'{1}\', \'{2}\', \'{3}\', \'{4}\',\'{5}\',\'{6}\',\'{7}\',\'{8}\',\'{9}\')".format(flight_num, airline_name, from_airport, to_airport, departure_time, arrival_time, flight_date, cost, capacity, current_date))
        try:
            connection.execute(q)
            connection.execute("commit")
            flash(f'Flight Scheduled Successfully!')
        except Exception as e:
            flash(e)
    return render_template("admin/schedule_flight.html", form=form, homebar=3, username=username, pageSelect='schedule_flight', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)
         

#######################################################
# Popup Boxes
#######################################################
@app.route("/flight_details", methods=['GET', 'POST'])
def flight_details():
    if request.method == 'POST':
        airline_name = request.form['airline_name']
        flight_num = request.form['flight_num']
        q = text("SELECT * FROM flight JOIN view_flight ON Flight_Num=flight_id AND Airline_Name=airline WHERE Airline_Name = \'{0}\' AND Flight_Num = {1}".format(airline_name, flight_num))
        flightDetails = connection.execute(q)
    else:
        return redirect(url_for('view_flights'))
    return jsonify({'htmlresponse': render_template('popups/flight_details.html',table_data=flightDetails, tableType=0)})

@app.route("/booking_details", methods=['GET', 'POST'])
def booking_details():
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        airline_name = request.form['airline_name']
        flight_num = request.form['flight_num']
        q = text("SELECT * FROM book NATURAL JOIN flight WHERE Customer=\'{0}\' AND Airline_Name=\'{1}\' AND Flight_Num=\'{2}\'".format(customer_id, airline_name, flight_num))
        bookingDetails = connection.execute(q)
    else:
        return redirect(url_for('my_bookings'))
    return jsonify({'htmlresponse': render_template('popups/flight_details.html', table_data=bookingDetails, tableType=1)})

@app.route("/reservation_details", methods=['GET', 'POST'])
def reservation_details():
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        property_name = request.form['property_name']
        owner_id = request.form['owner_id']
        tableType = 1 if request.form['viewType'] == '1' else 2
        q = text("SELECT * FROM review AS O RIGHT OUTER JOIN reserve AS R ON R.Customer = O.Customer AND R.Owner_Email = O.Owner_Email AND R.Property_Name = O.Property_Name JOIN property AS P ON R.Property_Name = P.Property_Name AND R.Owner_Email = P.Owner_Email WHERE R.Customer=\'{0}\' AND R.Property_Name=\'{1}\' AND R.Owner_Email=\'{2}\'".format(customer_id, property_name, owner_id))
        reservationDetails = connection.execute(q)
    else:
        return redirect(url_for('my_reservations'))
    return jsonify({'htmlresponse': render_template('popups/property_details.html', table_data=reservationDetails, tableType=tableType)})

@app.route("/property_details", methods=['GET', 'POST'])
def property_details():
    if request.method == 'POST':
        owner_id = request.form['owner_id']
        property_name = request.form['property_name']
        q = text("CALL view_individual_property_reservations(\'{0}\', \'{1}\')".format(property_name, owner_id))
        connection.execute(q)
        q = text("SELECT * FROM property NATURAL JOIN view_properties WHERE Property_Name=\'{0}\' AND Owner_Email=\'{1}\'".format(property_name, owner_id))
        propertyDetails = connection.execute(q)
        q = text("SELECT * FROM view_individual_property_reservations NATURAL JOIN reserve LEFT OUTER JOIN owners_rate_customers AS R ON customer_email = R.Customer WHERE Was_Cancelled = 0 AND End_Date < \'{0}\'".format(current_date))
        table_data_past = connection.execute(q)
        q = text("SELECT * FROM view_individual_property_reservations NATURAL JOIN reserve WHERE Was_Cancelled = 0 AND \'{0}\' BETWEEN Start_Date AND End_Date".format(current_date))
        table_data_current = connection.execute(q)
        q = text("SELECT * FROM view_individual_property_reservations NATURAL JOIN reserve WHERE Was_Cancelled = 0 AND Start_Date > \'{0}\'".format(current_date))
        table_data_future = connection.execute(q)
    else:
        return redirect(url_for('my_reservations'))
    return jsonify({'htmlresponse': render_template('popups/property_details.html', table_data=propertyDetails, table_data_past=table_data_past, table_data_current=table_data_current, table_data_future=table_data_future, tableType=0)})

#######################################################
# Function Calls
#######################################################
def getCurrentDate():
    global current_date
    current_date = date.today()
    print(current_date)
    return current_date

@app.route("/logout")
def logout():
    global username
    global adminAccess
    global ownerAccess
    global customerAccess
    username = ''
    adminAccess = False
    ownerAccess = False
    customerAccess = False
    return redirect(url_for('home'))

@app.route("/set_system_date", methods=['GET','POST'])
def set_system_date():
    global current_date
    if request.method == 'POST':
        desired_date = request.form['set_date']
        q = text("CALL process_date(\'{0}\')".format(desired_date))
        connection.execute(q)
        current_date = desired_date
    return redirect(url_for('account'))

@app.route("/remove_flight", methods=['GET', 'POST'])
def remove_flight():
    if request.method == 'POST':
        airline_name = request.form['airline_name']
        flight_num = request.form['flight_num']
        q = text("CALL remove_flight({0}, \'{1}\', \'{2}\')".format(flight_num, airline_name, current_date))
        connection.execute(q)
    return redirect(url_for('view_flights'))

@app.route("/cancel_booking", methods=['GET', 'POST'])
def cancel_booking():
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        airline_name = request.form['airline_name']
        flight_num = request.form['flight_num']
        q = text("CALL cancel_flight_booking(\'{0}\', {1}, \'{2}\', \'{3}\')".format(customer_id, flight_num, airline_name, current_date))
        connection.execute(q)
    return redirect(url_for('my_bookings'))

@app.route("/cancel_reservation", methods=['GET', 'POST'])
def cancel_reservation():
    if request.method == 'POST':
        property_name = request.form['property_name']
        owner_id = request.form['owner_id']
        customer_id = request.form['customer_id']
        q = text("CALL cancel_property_reservation(\'{0}\', \'{1}\', \'{2}\', \'{3}\')".format(property_name, owner_id, customer_id, current_date))
        connection.execute(q)
    return redirect(url_for('my_reservations'))

@app.route("/remove_property", methods=['GET', 'POST'])
def remove_property():
    if request.method == 'POST':
        property_name = request.form['property_name']
        owner_id = request.form['owner_id']
        q = text("CALL remove_property(\'{0}\', \'{1}\', \'{2}\')".format(property_name, owner_id, current_date))
        connection.execute(q)
    return redirect(url_for('my_properties'))

@app.route("/owner_rates_customer", methods=['GET', 'POST'])
def owner_rates_customer():
    if request.method == 'POST':
        owner_id = request.form['owner_id']
        customer_id = request.form['customer_id']
        rating = request.form['rating']
        q = text("CALL owner_rates_customer(\'{0}\', \'{1}\', {2}, \'{3}\')".format(owner_id, customer_id, rating, current_date))
        connection.execute(q)
    return redirect(url_for('my_properties'))

@app.route("/customer_rates_owner", methods=['GET', 'POST'])
def customer_rates_owner():
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        owner_id = request.form['owner_id']
        rating = request.form['rating']
        q = text("CALL customer_rates_owner(\'{0}\', \'{1}\', {2}, \'{3}\')".format(customer_id, owner_id, rating, current_date))
        connection.execute(q)
    return redirect(url_for('my_reservations'))

@app.route("/customer_review_property", methods=['GET', 'POST'])
def customer_review_property():
    if request.method == 'POST':
        property_name = request.form['property_name']
        owner_id = request.form['owner_id']
        customer_id = request.form['customer_id']
        content = request.form['content']
        rating = request.form['rating']
        q = text("CALL customer_review_property(\'{0}\', \'{1}\', \'{2}\', \'{3}\', {4}, \'{5}\')".format(property_name, owner_id, customer_id, content, rating, current_date))
        connection.execute(q)
    return redirect(url_for('my_reservations'))

@app.route("/remove_owner", methods=['GET', 'POST'])
def remove_owner():
    global username
    global adminAccess
    global ownerAccess
    global customerAccess
    q = text("CALL remove_owner(\'{0}\')".format(username))
    connection.execute(q)
    connection.execute('commit')
    q = text("SELECT * FROM accounts WHERE Email=\'{0}\'".format(username))
    result = connection.execute(q)
    if result.rowcount != 0:
        q = text("SELECT * FROM admins WHERE Email=\'{0}\'".format(username))
        result = connection.execute(q)
        adminAccess = True if result.rowcount != 0 else False
        q = text("SELECT * FROM owners WHERE Email=\'{0}\'".format(username))
        result = connection.execute(q)
        ownerAccess = True if result.rowcount != 0 else False
        q = text("SELECT * FROM customer WHERE Email=\'{0}\'".format(username))
        result = connection.execute(q)
        customerAccess = True if result.rowcount != 0 else False
        return redirect(url_for('account'))
    else:
        username = ''
        adminAccess = False
        ownerAccess = False
        customerAccess = False
    return redirect(url_for('home'))

#######################################################
# Testing
#######################################################
@app.route("/testing", methods=['GET', 'POST'])
def testing():
    global username
    global adminAccess
    global ownerAccess
    global customerAccess
    username = 'webadmin@gmail.com'
    adminAccess = True
    ownerAccess = True
    customerAccess = True
    return render_template('testing.html', homebar=3, username=username, adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

#######################################################
# Run App
#######################################################
getCurrentDate()

if __name__ == '__main__':
    app.run(debug=True)

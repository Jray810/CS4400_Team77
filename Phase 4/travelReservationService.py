from typing import Iterable
from application import app
from db import *
from flask import render_template, url_for, flash, redirect, request, jsonify
from forms import RegistrationForm, LoginForm
from datetime import date

current_date = '2021-10-10'

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
    return render_template("account.html", homebar=2, username=username, adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route("/login", methods=['GET', 'POST'])
def login():
    global username
    global adminAccess
    global ownerAccess
    global customerAccess
    form = LoginForm()
    if form.validate_on_submit():
        if Accounts.query.filter_by(Email = form.email.data, \
            Pass = form.password.data).first():
            adminAccess = Admins.query.filter_by(Email = form.email.data).first()
            ownerAccess = Owners.query.filter_by(Email = form.email.data).first()
            customerAccess = Customers.query.filter_by(Email = form.email.data).first()
            username = form.email.data
            return redirect(url_for('account'))
        else:
            flash('Login Unsuccessful. Please check username and password', 'danger')
    return render_template("login.html", homebar=-1, username=username, form=form)

@app.route("/register", methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        flash(f'Account created for {form.username.data}!', 'success')
        return redirect(url_for('home'))
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
    q = text("SELECT * FROM reserve NATURAL JOIN property WHERE Customer=\'{0}\' AND ((End_Date < \'{1}\') OR (\'{1}\' BETWEEN Start_Date AND End_Date AND Was_Cancelled = 1))".format(username, current_date))
    past_reservations = connection.execute(q)
    q = text("SELECT * FROM reserve NATURAL JOIN property WHERE Customer=\'{0}\' AND \'{1}\' BETWEEN Start_Date AND End_Date AND Was_Cancelled = 0".format(username, current_date))
    current_reservation = connection.execute(q)
    q = text("SELECT * FROM reserve NATURAL JOIN property WHERE Customer=\'{0}\' AND Start_Date > \'{1}\'".format(username, current_date))
    future_reservations = connection.execute(q)
    return render_template("customer/my_reservations.html", past_reservations=past_reservations, current_reservation=current_reservation, future_reservations=future_reservations, homebar=3, username=username, pageSelect='my_reservations', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route("/book")
def book():
    q = text("SELECT * FROM view_flight JOIN flight ON airline=Airline_Name AND flight_id=Flight_Num")
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
@app.route("/my_properties")
def my_properties():
    q = text("SELECT * FROM view_airports_condensed")
    airport_view = connection.execute(q)
    return render_template("owner/my_properties.html", table_data=airport_view, homebar=3, username=username, pageSelect='my_properties', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

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
        q = text("SELECT * FROM reserve NATURAL JOIN property WHERE Customer=\'{0}\' AND Property_Name=\'{1}\' AND Owner_Email=\'{2}\'".format(customer_id, property_name, owner_id))
        reservationDetails = connection.execute(q)
    else:
        return redirect(url_for('my_reservations'))
    return jsonify({'htmlresponse': render_template('popups/reservation_details.html', table_data=reservationDetails, tableType=1)})

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
# getCurrentDate()

if __name__ == '__main__':
    app.run(debug=True)
from application import app
from db import *
from flask import render_template, url_for, flash, redirect
from flask_modals import render_template_modal
from forms import RegistrationForm, LoginForm

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
    global username
    q = 'SELECT * FROM book NATURAL JOIN flight WHERE Customer=\'{0}\''.format(username)
    book_view = connection.execute(text(q))
    return render_template("customer/my_bookings.html", table_data=book_view, homebar=3, username=username, pageSelect='my_bookings', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

@app.route("/my_reservations")
def my_reservations():
    q = text("SELECT * FROM reserve NATURAL JOIN property WHERE Customer=\'{0}\'".format(username))
    reserve_view = connection.execute(q)
    return render_template("customer/my_reservations.html", table_data=reserve_view, homebar=3, username=username, pageSelect='my_reservations', adminAccess=adminAccess, customerAccess=customerAccess, ownerAccess=ownerAccess)

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
# Testing
#######################################################
@app.route("/testing", methods=['GET', 'POST'])
def testing():
    return render_template('testing.html', homebar=2, username='test', adminAccess=True, customerAccess=True, ownerAccess=True)


#######################################################
# Function Calls
#######################################################
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
    return render_template("logout.html")

#######################################################
# Run App
#######################################################
if __name__ == '__main__':
    app.run(debug=True)
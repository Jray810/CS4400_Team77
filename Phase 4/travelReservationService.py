from application import app
from db import *
from flask import render_template, url_for, flash, redirect
from forms import RegistrationForm, LoginForm

@app.route("/")
@app.route("/home")
def home():
    return render_template("home.html")

@app.route("/about")
def about():
    return render_template("about.html")

@app.route("/register", methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        flash(f'Account created for {form.username.data}!', 'success')
        return redirect(url_for('home'))
    return render_template("register.html", form=form)

@app.route("/login", methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        if accounts.query.filter_by(Email = form.email.data, \
            Pass = form.password.data).first():
            isAdmin = admins.query.filter_by(Email = form.email.data).first()
            isOwner = owners.query.filter_by(Email = form.email.data).first()
            isCustomer = customers.query.filter_by(Email = form.email.data).first()
            if isAdmin:
                return redirect(url_for('admin'))
            elif isOwner and isCustomer:
                return redirect(url_for('customerAndOwner'))
            elif isOwner:
                return redirect(url_for('owner'))
            elif isCustomer:
                return redirect(url_for('customer'))
        # if form.email.data == 'admin@blog.com' and form.password.data == 'password':
        #     flash('You have been logged in!', 'success')
        #     return redirect(url_for('home'))
        else:
            flash('Login Unsuccessful. Please check username and password', 'danger')
    return render_template("login.html", form=form)

@app.route("/customer")
def customer():
    return render_template("customer.html")

@app.route("/owner")
def owner():
    return render_template("owner.html")

@app.route("/customerAndOwner")
def customerAndOwner():
    return render_template("customerAndOwner.html")

@app.route("/admin")
def admin():
    return render_template("admin.html")

@app.route("/process_date")
def process_date():
    q = text("CALL process_date('2021-10-19')")
    connection.execute(q)
    q = text("SELECT * FROM view_customers")
    customer_view = connection.execute(q)
    return render_template("admin/process_date.html", table_data=customer_view)

@app.route("/view_airlines")
def view_airlines():
    q = text("SELECT * FROM view_airlines")
    airline_view = connection.execute(q)
    return render_template("admin/view_airlines.html", table_data=airline_view)

@app.route("/view_airports")
def view_airports():
    q = text("SELECT * FROM view_airports_condensed")
    airport_view = connection.execute(q)
    return render_template("admin/view_airports.html", table_data=airport_view)

@app.route("/view_customers")
def view_customers():
    q = text("SELECT * FROM view_customers")
    customer_view = connection.execute(q)
    return render_template("admin/view_customers.html", table_data=customer_view)
    
@app.route("/view_owners")
def view_owners():
    q = text("SELECT * FROM view_owners")
    owner_view = connection.execute(q)
    return render_template("admin/view_owners.html", table_data=owner_view)

@app.route("/testing")
def testing():
    all_accounts = Accounts.query.all()
    return render_template('testing.html', table_data=all_accounts)

if __name__ == '__main__':
    app.run(debug=True)
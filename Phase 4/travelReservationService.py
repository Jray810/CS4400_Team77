from flask import Flask, render_template, url_for, flash, redirect
from flask_sqlalchemy import SQLAlchemy
from forms import RegistrationForm, LoginForm
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import pymysql

conn = "mysql+pymysql://root:YOURPASSWORDHERE@localhost:YOURPORTNUMBERHERE/travel_reservation_service"
engine = create_engine(conn, echo=True)
connection = engine.connect()

app = Flask(__name__)
app.config['SECRET_KEY'] = 'ContinueCounterReset'
app.config['SQLALCHEMY_DATABASE_URI'] = conn
db = SQLAlchemy(app)

class accounts(db.Model):
    Email = db.Column(db.String(50), primary_key=True)
    First_Name = db.Column(db.String(50))
    Last_Name = db.Column(db.String(50))
    Pass = db.Column(db.String(50))

    def __repr__(self):
        return "id: {0} | first name: {1} | last name: {2} | pass: {3}".format(self.Email, self.First_Name, self.Last_Name, self.Pass)

class airport(db.Model):
    Airport_Id = db.Column(db.String(3), primary_key=True)
    Airport_Name = db.Column(db.String(50))
    Time_Zone = db.Column(db.String(3))
    Street = db.Column(db.String(50))
    City = db.Column(db.String(50))
    State = db.Column(db.String(2))
    Zip = db.Column(db.String(5))

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
        if form.email.data == 'admin@blog.com' and form.password.data == 'password':
            flash('You have been logged in!', 'success')
            return redirect(url_for('home'))
        else:
            flash('Login Unsuccessful. Please check username and password', 'danger')
    return render_template("login.html", form=form)

@app.route("/customer")
def customer():
    return render_template("customer.html")

@app.route("/admin")
def admin():
    return render_template("admin.html")

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
    all_accounts = accounts.query.all()
    return render_template('testing.html', table_data=all_accounts)

if __name__ == '__main__':
    app.run(debug=True)
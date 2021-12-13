from sqlalchemy.sql.schema import UniqueConstraint
from application import app
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine, MetaData, text
from sqlalchemy_utils import database_exists, create_database

conn = "mysql+pymysql://root:@localhost:/travel_reservation_service"
engine = create_engine(conn, echo=True)

metadata_obj = MetaData()

app.config['SECRET_KEY'] = 'ContinueCounterReset'
app.config['SQLALCHEMY_DATABASE_URI'] = conn
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
db = SQLAlchemy(app, metadata=metadata_obj)

#######################################################
# Table Entities
#######################################################
# Model for accounts
class Accounts(db.Model):
    __tablename__ = 'accounts'
    Email = db.Column(db.String(50), primary_key=True, nullable=False)
    First_Name = db.Column(db.String(100), nullable=False)
    Last_Name = db.Column(db.String(100), nullable=False)
    Pass = db.Column(db.String(50), nullable=False)

# Model for admins
class Admins(db.Model):
    __tablename__ = 'admins'
    Email = db.Column(db.String(50), db.ForeignKey('accounts.Email'), primary_key=True, nullable=False)

# Model for clients
class Clients(db.Model):
    __tablename__ = 'clients'
    Email = db.Column(db.String(50), db.ForeignKey('accounts.Email'), primary_key=True, nullable=False)
    Phone_Number = db.Column(db.CHAR(12), unique=True, nullable=False)

# Model for an owners
class Owners(db.Model):
    __tablename__ = 'owners'
    Email = db.Column(db.String(50), db.ForeignKey('clients.Email'), primary_key=True, nullable=False)

# Model for a customer
class Customers(db.Model):
    __tablename__ = 'customer'
    Email = db.Column(db.String(50), db.ForeignKey('clients.Email'), primary_key=True, nullable=False)
    CcNumber = db.Column(db.String(19), unique=True, nullable=False)
    Cvv = db.Column(db.CHAR(3), nullable=False)
    Exp_Date = db.Column(db.Date, nullable=False)
    Location = db.Column(db.String(50), nullable=False)

# Model for airline
class Airline(db.Model):
    __tablename__ = 'airline'
    Airline_Name = db.Column(db.String(50), primary_key=True, nullable=False)
    Rating = db.Column(db.Numeric(2,1), nullable=False)

# Model for airport
class Airport(db.Model):
    __tablename__ = 'airport'
    Airport_Id = db.Column(db.CHAR(3), primary_key=True, nullable=False)
    Airport_Name = db.Column(db.String(50), unique=True, nullable=False)
    Time_Zone = db.Column(db.CHAR(3), nullable=False)
    Street = db.Column(db.String(50), nullable=False)
    City = db.Column(db.String(50), nullable=False)
    State = db.Column(db.CHAR(2), nullable=False)
    Zip = db.Column(db.CHAR(5), nullable=False)
    __table_args__ = (UniqueConstraint('Street', 'City', 'State', 'Zip'),)

#######################################################
# Table Weak Entities
#######################################################
# Model for flight
class Flight(db.Model):
    __tablename__ = 'flight'
    Flight_Num = db.Column(db.CHAR(5), nullable=False, primary_key=True)
    Airline_Name = db.Column(db.String(50), db.ForeignKey('airline.Airline_name'), nullable=False, primary_key=True)
    From_Airport = db.Column(db.CHAR(3), db.ForeignKey('airport.Airport_id'), nullable=False)
    To_Airport = db.Column(db.CHAR(3), db.ForeignKey('airport.Airport_id'), nullable=False)
    Departure_Time = db.Column(db.Time, nullable=False)
    Arrival_Time = db.Column(db.Time, nullable=False)
    Flight_Date = db.Column(db.Date, nullable=False)
    Cost = db.Column(db.Numeric(6, 2), nullable=False)
    Capacity = db.Column(db.Integer, nullable = False)

# Model for property
class Property(db.Model):
    __tablename__ = 'property'
    Property_Name = db.Column(db.String(50), nullable=False, primary_key=True)
    Owner_Email = db.Column(db.String(50), db.ForeignKey('owners.Email'), nullable=False, primary_key=True)
    Descr = db.Column(db.String(500), nullable=False)
    Capacity = db.Column(db.Integer, nullable=False)
    Cost = db.Column(db.Numeric(6, 2), nullable=False)
    Street = db.Column(db.String(50), nullable=False)
    City = db.Column(db.String(50), nullable=False)
    State = db.Column(db.CHAR(2), nullable=False)
    Zip = db.Column(db.CHAR(5), nullable=False)
    __table_args__ = (UniqueConstraint('Street', 'City', 'State', 'Zip'),)

#######################################################
# Table Multivalued Attributes
#######################################################
# Model for amenity
class Amenity(db.Model):
    __tablename__ = 'amenity'
    Property_Name = db.Column(db.String(50), db.ForeignKey('property.Property_Name'), nullable=False, primary_key=True)
    Property_Owner = db.Column(db.String(50), db.ForeignKey('property.Owner_Email'), nullable=False, primary_key=True)
    Amenity_Name = db.Column(db.String(50), nullable=False, primary_key=True)

# Model for attraction
class Attraction(db.Model):
    __tablename__ = 'attraction'
    Airport = db.Column(db.CHAR(3), db.ForeignKey('airport.Airport_Id'), nullable=False, primary_key=True)
    Attraction_Name = db.Column(db.String(50), nullable=False, primary_key=True)

#######################################################
# Table M-N Relationships
#######################################################
# Model for review
class Review(db.Model):
    __tablename__ = 'review'
    Property_Name = db.Column(db.String(50), db.ForeignKey('property.Property_Name'), nullable=False, primary_key=True)
    Owner_Email = db.Column(db.String(50), db.ForeignKey('property.Owner_Email'), nullable=False, primary_key=True)
    Customer = db.Column(db.String(50), db.ForeignKey('customer.Email'), nullable=False, primary_key=True)
    Content = db.Column(db.String(500))
    Score = db.Column(db.Integer, nullable=False)

# Model for reserve
class Reserve(db.Model):
    __tablename__ = 'reserve'
    Property_Name = db.Column(db.String(50), db.ForeignKey('property.Property_Name'), nullable=False, primary_key=True)
    Owner_Email = db.Column(db.String(50), db.ForeignKey('property.Owner_Email'), nullable=False, primary_key=True)
    Customer = db.Column(db.String(50), db.ForeignKey('customer.Email'), nullable=False, primary_key=True)
    Start_Date = db.Column(db.Date, nullable=False)
    End_Date = db.Column(db.Date, nullable=False)
    Num_Guests = db.Column(db.Integer, nullable=False)
    Was_Cancelled = db.Column(db.Boolean, nullable=False)

# Model for is_close_to
class Is_Close_To(db.Model):
    __tablename__ = 'is_close_to'
    Property_Name = db.Column(db.String(50), db.ForeignKey('property.Property_Name'), nullable=False, primary_key=True)
    Owner_Email = db.Column(db.String(50), db.ForeignKey('property.Owner_Email'), nullable=False, primary_key=True)
    Airport = db.Column(db.CHAR(3), db.ForeignKey('airport.Airport_Id'), nullable=False, primary_key=True)
    Distance = db.Column(db.Integer, nullable=False)


# Model for book
class Book(db.Model):
    __tablename__ = 'book'
    Customer = db.Column(db.String(50), db.ForeignKey('customer.Email'), nullable=False, primary_key=True)
    Flight_Num = db.Column(db.CHAR(5), db.ForeignKey('flight.Flight_Num'), nullable=False, primary_key=True)
    Airline_Name = db.Column(db.String(50), db.ForeignKey('flight.Airline_Name'), nullable=False, primary_key=True)
    Num_Seats = db.Column(db.Integer, nullable=False)
    Was_Cancelled = db.Column(db.Boolean, nullable=False)

# Model for owners_rate_customers
class Owners_Rate_Customers(db.Model):
    __tablename__ = 'owners_rate_customers'
    Owner_Email = db.Column(db.String(50), db.ForeignKey('owners.Email'), nullable=False, primary_key=True)
    Customer = db.Column(db.String(50), db.ForeignKey('customer.Email'), nullable=False, primary_key=True)
    Score = db.Column(db.Integer, nullable=False)

# Model for customers_rate_owners
class Customers_Rate_Owners(db.Model):
    __tablename__ = 'customers_rate_owners'
    Customer = db.Column(db.String(50), db.ForeignKey('customer.Email'), nullable=False, primary_key=True)
    Owner_Email = db.Column(db.String(50), db.ForeignKey('owners.Email'), nullable=False, primary_key=True)
    Score = db.Column(db.Integer, nullable=False)

#######################################################
# Database Setup
#######################################################
def sql_script_reader(path, conn, delim):
    file = open(path,'r')
    q = ''
    for line in file:
        if not line.startswith('--') and line.strip('\n'):
            q += line.strip('\n')
            if q.endswith(delim):
                try:
                    if delim != ';':
                        q = q.strip(delim)
                    conn.execute(text(q))
                    conn.execute("commit")
                except:
                    print('Invalid Command')
                finally:
                    q = ''
    return

# Check if database already exists
dbExists = database_exists(engine.url)

# Create the database schema from scratch if it database didn't already exist
if not dbExists:
    create_database(engine.url)
    metadata_obj.create_all(engine)

# Connect to the database
connection = engine.connect()

# While the above model is incomplete, we can just read the schema from a script file
modelIncomplete = True
if not dbExists and modelIncomplete:
    sql_script_reader('schema.sql', connection, ';')

# Create the stored procedures, views, and functions if database didn't already exist
# Also populate the database with appropriate data
if not dbExists:
    sql_script_reader('stored_procedures.sql', connection, '$')
    sql_script_reader('populate_data.sql', connection, ';')

if not Accounts.query.filter_by(Email = 'webadmin@gmail.com').first():
    # Add a web administrator to the database
    q = text('INSERT INTO Accounts (Email, First_Name, Last_Name, Pass) VALUES (\'webadmin@gmail.com\', \'Web\', \'Admin\', \'ContinueCounterReset\')')
    connection.execute(q)
    connection.execute("commit")
    q = text('INSERT INTO Admins (Email) VALUES (\'webadmin@gmail.com\')')
    connection.execute(q)
    connection.execute("commit")
    q = text('CALL register_customer(\'webadmin@gmail.com\', \'Web\', \'Admin\', \'ContinueCounterReset\', \'999-999-9999\', \'9999 9999 9999 9999\', \'999\', \'2040-01-01\', \'USA\')')
    connection.execute(q)
    connection.execute("commit")
    q = text('CALL register_owner(\'webadmin@gmail.com\', \'Web\', \'Admin\', \'ContinueCounterReset\', \'999-999-9999\')')
    connection.execute(q)
    connection.execute("commit")

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
    __tablename__ = 'clients'
    Email = db.Column(db.String(50), db.ForeignKey('accounts.Email'), primary_key=True, nullable=False)
    Phone_Number = db.Column(db.CHAR(12), unique=True, nullable=False)

# Model for an owners
class owners(db.Model):
    __tablename__ = 'owners'
    Email = db.Column(db.String(50), db.ForeignKey('clients.Email'), primary_key=True, nullable=False)

# Model for a customer
class customers(db.Model):
    __tablename__ = 'customer'
    Email = db.Column(db.String(50), db.ForeignKey('clients.Email'), primary_key=True, nullable=False)
    CcNumber = db.Column(db.String(19), unique=True, nullable=False)
    Cvv = db.Column(db.CHAR(3), nullable=False)
    Exp_Date = db.Column(db.Date, nullable=False)
    Location = db.Column(db.String(50), nullable=False)

# Model for airline
# COMPLETE ME

# Model for airport
class airport(db.Model):
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
# COMPLETE ME

# Model for property
# COMPLETE ME


#######################################################
# Table Multivalued Attributes
#######################################################
# Model for amenity
# COMPLETE ME

# Model for attraction
# COMPLETE ME


#######################################################
# Table M-N Relationships
#######################################################
# Model for review
# COMPLETE ME

# Model for reserve
# COMPLETE ME

# Model for is_close_to
# COMPLETE ME

# Model for book
# COMPLETE ME

# Model for owners_rate_customers
# COMPLETE ME

# Model for customers_rate_owners
# COMPLETE ME


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
if not dbExists:
    sql_script_reader('stored_procedures.sql', connection, '$')

# Populate the database with data if we want to
dbPopulate = True
if dbPopulate:
    sql_script_reader('populate_data.sql', connection, ';')
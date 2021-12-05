#Flask imports
from flask import Flask
from flask import render_template, redirect, request
from flask.helpers import url_for

#Local Imports
import login

app = Flask(__name__)

#Login Page
@app.route('/login', methods=['POST', 'GET'])
def login():
    error = None
    if request.method == 'GET':
        render_template('login.html', error=None)
    if request.method == 'POST':
        if valid_login(request.form['email'], request.form['password']):
            return log_in(request.form['email'])
        else:
            error = 'Invalid email/password'

    return render_template('login.html', error=None)

#Admin Home Page
@app.route('/admin', methods=['POST', 'GET'])
def admin():
    return render_template('admin.html', error=None) 

#Functions to handle loging in
def valid_login(email, password):
    #Check that the account exists
    if True:
        #return account type
        return True
    else:
        return False

def log_in(email):
    #If is admin
    return redirect(url_for('admin'))
    #Else if owner 
    return redirect(url_for('owner'))
    #Else if customer
    return redirect(url_for('customer'))
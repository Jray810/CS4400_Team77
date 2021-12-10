# Install instructions
Using python version >= 3.4, create and start a python virtual environment (this prevents conflicts with system wide python packages):

*On MacOS and Linux:*
```
python -m venv venv
source venv/bin/activate
```

*On Windows:*
```
python -m venv venv
env\Scripts\activate.bat
```

Install dependencies:
```
pip install -r requirements.txt
```

# Running instructions

Open up your MySQL Workbench and start a SQL server.

If you have everything installed properly, you should be able to run it just by doing:
```python3 travelReservationService.py```

And then go to a browser and type in http://localhost:5000/ and it should take you to the website

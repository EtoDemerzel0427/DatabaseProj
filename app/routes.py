from flask import render_template, url_for, flash, redirect, request, Response
from app.forms import RegistrationForm, LoginForm, InterFerenceForm, TriplesForm
from app import app, db, bcrypt
from app.models import User
from flask_login import login_user, current_user, logout_user, login_required
import pandas as pd
import os
from werkzeug.utils import secure_filename
from app.check import *


# upload path
app.config['UPLOAD_FOLDER'] = 'uploads'

# we only allow suffices: xlsx and csv
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ['xlsx', 'csv']

# Todo:之后tables里应该是根据目前导入了哪些表来决定的，先随便搞搞
table_format = ['name', 'description', 'author', 'date']
tables = [
    {'name': 'tbCell',
     'description': 'The information of each cell',
     'author': 'Weiran Huang',
     'date': 'July 4th, 2019'},
    {'name': 'tbKPI',
     'description': "I don't know what it is either",
     'author': 'Zengrui Wang',
     'date': 'July 3rd, 2019'}
]


@app.route('/', methods=['GET', 'POST'])
@app.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('home'))
    form = RegistrationForm()
    app.logger.info('User registration...')
    if form.validate_on_submit():
        app.logger.info('Registering...: Valid input.')
        hashed_pwd = bcrypt.generate_password_hash(form.password.data).decode('utf-8')
        user = User(username=form.username.data, email=form.email.data, password=hashed_pwd)

        db.session.add(user)
        db.session.commit()
        app.logger.info(f'User id: {user.id}')
        flash('Your account has been created! You are now able to log in!', 'success')
        return redirect(url_for('login'))

    app.logger.info('Not valid input.')
    return render_template("register.html", title="Register", form=form)

@app.route('/login', methods= ['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('home'))
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data).first()
        if user is not None and bcrypt.check_password_hash(user.password, form.password.data):
            login_user(user, remember=form.remember.data)
            next_page = request.args.get('next')
            flash('You have been logged in!', 'success')
            return redirect(next_page) if next_page else redirect(url_for('home'))
        # if form.email.data == 'huangweiran1998@gmail.com' and form.password.data == '12345678':
        #     flash('You have been logged in!', 'success')
        #     return redirect(url_for('home'))
        else:
            flash('Login Unsuccessful. Please check your username and password.', 'danger')

    return render_template("login.html", title="Login", form=form)

@app.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('home'))

@app.route('/account')
@login_required
def account():
    return render_template("account.html", title="Account")

# a temporary page,
@app.route('/home')
@login_required
def home():
    return render_template("home.html", title="Home", tables=tables)

@app.route('/upload', methods=['GET', 'POST'])
def upload():
    filename = None
    thePercent = 0
    if request.method == "POST":
        if 'file' not in request.files:
            flash('No file part', 'danger')
            return redirect(request.url)

        file = request.files['file']
        table_name = request.form.get('table')
        app.logger.info(f'{request.form["table"]}')

        # if user does not select file, browser also
        # submit an empty part without filename
        if file.filename == '':
            flash('No selected file', 'danger')
            return redirect(request.url)

        # check if the file is correct
        if table_name not in file.filename:
            flash(f'{file.filename} not compatible with {table_name}', 'danger')
            return redirect(request.url)

        # check if the file format is correct
        if not allowed_file(file.filename):
            flash(f"We don't allow {file.filename.split('.')[-1]} format", 'danger')
            return redirect(url_for(request.url))
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

            batch_size = 50
            table = db.metadata.tables[table_name]

            # get filtered dataframe
            df = None
            if table_name == 'tbCell':
                df = pd.read_excel(os.path.join(app.config['UPLOAD_FOLDER'], filename))
                df = check_cell(df) # filter out all invalid lines
            elif table_name == 'tbMROData':
                df = pd.read_csv(os.path.join(app.config['UPLOAD_FOLDER'], filename))
                df = check_mro(df)
            elif table_name == 'tbKPI':
                df = pd.read_excel(os.path.join(app.config['UPLOAD_FOLDER'], filename))
                df = check_kpi(df)
            elif table_name == 'tbPRB':
                df = pd.read_excel(os.path.join(app.config['UPLOAD_FOLDER'], filename))
                # app.logger.info('Start checking...')
                df = check_prb(df)
                # app.logger.info('Check done!')


            size = df.shape[0]
            for idx in range(0, size, batch_size):
                thePercent = idx//size
                # app.logger.info(f"[UPLOADING]: PERCENT {thePercent}")

                if idx + batch_size >= size:
                    sub = df.iloc[idx:size]
                else:
                    sub = df.iloc[idx:idx+batch_size]

                if table_name == 'tbKPI':
                    # deal with NIL
                    sub = sub.to_dict('records')
                    for my_dict in sub:
                        if my_dict['_AB'] == 'NIL':
                            my_dict['_AB'] = None
                        if my_dict['_AC'] == 'NIL':
                            my_dict['_AC'] = None
                        if my_dict['_AD'] == 'NIL':
                            my_dict['_AD'] = None
                        if my_dict['_AE'] == 'NIL':
                            my_dict['_AE'] = None
                    db.engine.execute(table.insert(), sub)
                else:
                    db.engine.execute(table.insert(), sub.to_dict('records'))

            flash('Successfully uploaded file!', 'success')
            thePercent = 100

        return render_template("upload.html", title="Upload", filename=filename, thePercent=thePercent)

    return render_template("upload.html", title="Upload")

@app.route('/download')
def download():
    return render_template("download.html", title="Download")

# TODO: NOT TESTED YET.
@app.route('/interference' , methods= ['GET', 'POST'])
def interference():
    form = InterFerenceForm()
    if form.validate_on_submit():
        print("-------------------------")
        db.session.execute('exec create_C2INew '+ form.num_SI.data)
        result = db.engine.execute('select * from tbC2INew').fetchall()

        if result ==None :
            flash('You have not been interference!', 'defeat')
            return render_template("interference.html", title="Interference", form=form , result = None)
        else:
            flash('You have been interference!', 'success')
            return render_template("interference.html", title="Interference" , form =form ,result = result)
    return render_template("interference.html", title="Interference", form=form , result =None)


# TODO: NOT TESTED YET.
@app.route('/triples',methods= ['GET', 'POST'])
def triples():

    form = TriplesForm()
    if form.validate_on_submit():
        db.session.execute('exec C2I2 '+form.num_SI.data)
        result = db.engine.execute('select * from tbC2I3').fetchall()

        if result ==None :
            flash('You have not been triples!', 'defeat')
            return render_template("triples.html", title="triples", form=form , list = None)
        else:
            flash('You have been triples!', 'success')
            return render_template("triples.html", title="triples" , form =form ,list = result)
    return render_template("triples.html", title="triples", form=form , list =None)

@app.route('/tbCell' ,methods= ['GET', 'POST'])
def tbCell():
    ID_choselist = db.engine.execute('select distinct SECTOR_ID from tbCell').fetchall()
    NM_choselist = db.engine.execute('select distinct SECTOR_NAME from tbCell').fetchall()

    if request.method =='POST':
        # 未输入值
        first= request.form.get('first')
        second = request.form.get('second')
        if len(list(first)) == 0 and len(list(second)) == 0 :
            flash('Please input or choose a value', 'danger')
            return render_template("tbCell.html", title="Cell", result=None, ID_choselist=ID_choselist,
                                   NM_choselist=NM_choselist)
        else:
            # 从ID选
            if len(list(first)) > 0:
                result = db.engine.execute(
                    'select * from tbCell where SECTOR_ID = \'' + first+'\'').fetchall()
                flash('You have been selected by ID!', 'success')
                print(result)
                return render_template("tbCell.html", title="Cell", result=result,
                                       ID_choselist=ID_choselist,
                                       NM_choselist=NM_choselist)

            # 从name选
            else:
                if len(list(second)) > 0:
                    result = db.engine.execute(
                        'select * from tbCell where SECTOR_NAME = \'' + second+'\'').fetchall()
                    flash('You have been selected by Name!', 'success')
                    return render_template("tbCell.html", title="Cell", result=result,
                                           ID_choselist=ID_choselist,
                                           NM_choselist=NM_choselist)

                else:
                    flash("You should choose ID or Name at least", 'danger')
                    return render_template("tbCell.html", title="Cell", result=None,
                                           ID_choselist=ID_choselist,
                                           NM_choselist=NM_choselist)

    return render_template("tbCell.html", title="Cell", result=None, ID_choselist=ID_choselist,
                           NM_choselist=NM_choselist)


@app.route('/eNodeB', methods=['GET', 'POST'])
def eNodeB():
    ID_choselist = db.engine.execute('select distinct ENODEBID from tbCell').fetchall()
    NM_choselist = db.engine.execute('select distinct ENODEB_NAME from tbCell').fetchall()

    if request.method == 'POST':
        # 未输入值
        first = request.form.get('first')
        second = request.form.get('second')

        if len(list(first)) == 0 and len(list(second)) == 0:
            flash('Please input or choose a value', 'danger')
            return render_template("eNodeB.html", title="eNodeB", result=None, ID_choselist=ID_choselist,
                                   NM_choselist=NM_choselist)

        else:
            # 从ID选
            if len(list(first)) > 0:
                result = db.engine.execute(
                    'select * from tbCell where ENODEBID = \'' + first + '\'').fetchall()
                flash('You have been selected by ID!', 'success')
                return render_template("eNodeB.html", title="eNodeB", result=result,
                                       ID_choselist=ID_choselist,
                                       NM_choselist=NM_choselist)

                # 从name选
            else:
                if len(list(second)) > 0:
                    result = db.engine.execute('select * from tbCell where ENODEB_NAME = \'' + second + '\'').fetchall()
                    flash('You have been selected by Name!', 'success')
                    return render_template("eNodeB.html", title="eNodeB", result=result, ID_choselist=ID_choselist,
                                           NM_choselist=NM_choselist)

                else:
                    flash("You should choose ID or Name at least", 'danger')
                    return render_template("eNodeB.html", title="eNodeB", result=None,
                                           ID_choselist=ID_choselist,
                                           NM_choselist=NM_choselist)

    return render_template("eNodeB.html", title="eNodeB", result=None, ID_choselist=ID_choselist,
                           NM_choselist=NM_choselist)

@app.route('/KPI', methods=['GET', 'POST'])
def KPI():
    thePercent = 100


    return render_template("KPI.html", title="KPI", thePercent=thePercent)

@app.route('/PRB')
def PRB():
    thePercent = 100
    return render_template("PRB.html", title="PRB", thePercent=thePercent)

# TODO: TEMP TEST
import time
@app.route('/progress')
def progress():
    def generate():
        x = 0

        while x <= 100:
            yield "data:" + str(x) + "\n\n"
            x = x + 10
            time.sleep(0.5)

    return Response(generate(), mimetype='text/event-stream')
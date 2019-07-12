from flask import render_template, url_for, flash, redirect, request, Response, send_from_directory
from app.forms import RegistrationForm, LoginForm, InterFerenceForm, TriplesForm, ExportForm
from app import app, db, bcrypt
from app.models import User, tbKPI_export, Cell, tbKPI, tbCell_export, tbPRB, tbPRB_export ,tbC2INew, tbC2I3
from flask_login import login_user, current_user, logout_user, login_required
import pandas as pd
import os
from werkzeug.utils import secure_filename
from app.check import *
from sqlalchemy import text
import matplotlib.pyplot as plt
import random
import flask_excel as excel
import io, base64
import openpyxl

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


@app.route('/login', methods=['GET', 'POST'])
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
@login_required
def upload():
    filename = None

    if request.method == "POST":
        if 'file' not in request.files:
            flash('No file part', 'danger')
            return redirect(request.url)

        file = request.files['file']
        table_name = request.form.get('table')
        batch_size = request.form.get('tentacles')
        #print(f'Batch size is {batch_size}')

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

            flash('Successfully uploaded excel to server, check the progress bar below.', 'success')

        return render_template("upload.html", title="Upload", filename=filename, table_name=table_name,
                               batch_size=batch_size)

    return render_template("upload.html", title="Upload")


@app.route('/download', methods=["GET", "POST"])
@login_required
def download():
    if request.method == "POST":
        table_name = request.form.get('tables')

        if table_name == 'tbCell':
            return excel.make_response_from_a_table(db.session, Cell, file_type='csv')
        elif table_name == 'tbKPI':
            return excel.make_response_from_a_table(db.session, tbKPI, file_type='csv')
        elif table_name == 'tbPRB':
            return excel.make_response_from_a_table(db.session, tbPRB, file_type='csv')

    return render_template("download.html", title="Download")


# TODO: NOT TESTED YET.
@app.route('/interference', methods=['GET', 'POST'])
@login_required
def interference():
    form = InterFerenceForm()
    form_export = ExportForm()


    if form.validate_on_submit():
        print("-------------------------")
        db.session.execute('execute create_C2INew ' + str(form.num_SI.data))
        db.session.commit()
        result = db.engine.execute('select * from tbC2INew').fetchall()
        db.session.commit()
        print(result)
        # empty
        if not result:
            flash('You have not been interference!', 'defeat')
            return render_template("interference.html", title="Interference", form=form, form_export = form_export,result=None)
        else:
            flash('You have been interference!', 'success')
            return render_template("interference.html", title="Interference", form=form, form_export = form_export,result=result)


    elif form_export.validate_on_submit():
        flash("You have choose Export", 'success')
        # TODO : export operation

        # excel.make_response_from_array([[1,2],[3,4]], "csv")

        return excel.make_response_from_tables(db.session, [tbC2INew], 'csv')
    return render_template("interference.html", title="Interference", form=form, form_export = form_export,result=None)


# TODO: NOT TESTED YET.
@app.route('/triples', methods=['GET', 'POST'])
@login_required
def triples():
    form = TriplesForm()
    form_export = ExportForm()
    if form.validate_on_submit():
        print("=======================")
        print(form.num_SI.data)
        db.session.execute('execute C2I3 ' + str(form.num_SI.data))
        db.session.commit()
        result = db.engine.execute('select * from tbC2I3').fetchall()
        db.session.commit()
        print(result)
        if not result:
            flash('You have not been triples!', 'defeat')
            return render_template("triples.html", title="triples", form=form, form_export=form_export, result=None)
        else:
            flash('You have been triples!', 'success')
            return render_template("triples.html", title="triples", form=form, form_export=form_export, result=result)
    elif form_export.validate_on_submit():
        flash("You have choose Export", 'success')
        # TODO : export operation

        # excel.make_response_from_array([[1,2],[3,4]], "csv")

        return excel.make_response_from_tables(db.session, [tbC2I3], 'csv')
    return render_template("triples.html", title="triples", form=form,form_export=form_export,  result=None)


@app.route('/tbCell', methods=['GET', 'POST'])
@login_required
def tbCell():
    ID_choselist = db.engine.execute('select distinct SECTOR_ID from tbCell').fetchall()
    NM_choselist = db.engine.execute('select distinct SECTOR_NAME from tbCell').fetchall()

    form = ExportForm()
    if form.validate_on_submit():
        flash("You have choose Export", 'success')
        # TODO : export operation

        # excel.make_response_from_array([[1,2],[3,4]], "csv")

        return excel.make_response_from_tables(db.session, [tbCell_export], 'csv')
        return render_template('tbCell.html', title='Cell', form=form, result=None, ID_choselist=ID_choselist,
                               NM_choselist=NM_choselist)

    if request.method == 'POST':
        # 未输入值

        first = request.form.get('first')
        second = request.form.get('second')
        if not list(first) and not list(second):
            # if len(list(first)) == 0 and len(list(second)) == 0:
            flash('Please input or choose a value', 'danger')
            return render_template("tbCell.html", title="Cell", form=form, result=None, ID_choselist=ID_choselist,
                                   NM_choselist=NM_choselist)
        else:
            db.session.execute('delete from tbCell_export')
            db.session.commit()
            # 从ID选
            if len(list(first)) > 0:
                result = db.engine.execute(
                    'select * from tbCell where SECTOR_ID = \'' + first + '\'').fetchall()
                flash('You have been selected by ID!', 'success')

                print(result)
                for data in result:
                    data = str(data).replace('None', 'NULL')
                    db.session.execute('insert into tbCell_export values ' + str(data))

                db.session.commit()
                return render_template("tbCell.html", title="Cell", result=result,
                                       form=form,
                                       ID_choselist=ID_choselist,
                                       NM_choselist=NM_choselist)

            # 从name选
            else:
                if len(list(second)) > 0:
                    result = db.engine.execute(
                        'select * from tbCell where SECTOR_NAME = \'' + second + '\'').fetchall()
                    flash('You have been selected by Name!', 'success')

                    for data in result:
                        data = str(data).replace('None', 'NULL')
                        db.session.execute('insert into tbCell_export values ' + str(data))

                    db.session.commit()

                    return render_template("tbCell.html", title="Cell", result=result,
                                           form=form,
                                           ID_choselist=ID_choselist,
                                           NM_choselist=NM_choselist)

                else:
                    flash("You should choose ID or Name at least", 'danger')
                    return render_template("tbCell.html", title="Cell", result=None,
                                           form=form,
                                           ID_choselist=ID_choselist,
                                           NM_choselist=NM_choselist)

    return render_template("tbCell.html", title="Cell", form=form, result=None, ID_choselist=ID_choselist,
                           NM_choselist=NM_choselist)


@app.route('/eNodeB', methods=['GET', 'POST'])
@login_required
def eNodeB():
    form = ExportForm()
    ID_choselist = db.engine.execute('select distinct ENODEBID from tbCell').fetchall()
    NM_choselist = db.engine.execute('select distinct ENODEB_NAME from tbCell').fetchall()

    if form.validate_on_submit():
        return excel.make_response_from_tables(db.session, [tbCell_export], 'csv')
        return render_template("eNodeB.html", title="eNodeB", form=form, result=None, ID_choselist=ID_choselist,
                               NM_choselist=NM_choselist)

    if request.method == 'POST':
        # 未输入值
        first = request.form.get('first')
        second = request.form.get('second')

        if len(list(first)) == 0 and len(list(second)) == 0:
            flash('Please input or choose a value', 'danger')
            return render_template("eNodeB.html", title="eNodeB", form=form, result=None, ID_choselist=ID_choselist,
                                   NM_choselist=NM_choselist)

        else:
            # 从ID选
            db.session.execute('delete from tbCell_export')
            db.session.commit()
            if len(list(first)) > 0:
                result = db.engine.execute(
                    'select * from tbCell where ENODEBID = \'' + first + '\'').fetchall()
                flash('You have been selected by ID!', 'success')

                for data in result:
                    data = str(data).replace('None', 'NULL')
                    db.session.execute('insert into tbCell_export values ' + str(data))

                db.session.commit()
                return render_template("eNodeB.html", title="eNodeB", form=form, result=result,
                                       ID_choselist=ID_choselist,
                                       NM_choselist=NM_choselist)

                # 从name选
            else:
                if len(list(second)) > 0:
                    result = db.engine.execute('select * from tbCell where ENODEB_NAME = \'' + second + '\'').fetchall()
                    for data in result:
                        data = str(data).replace('None', 'NULL')
                        db.session.execute('insert into tbCell_export values ' + str(data))

                    db.session.commit()
                    flash('You have been selected by Name!', 'success')
                    return render_template("eNodeB.html", title="eNodeB", form=form, result=result,
                                           ID_choselist=ID_choselist,
                                           NM_choselist=NM_choselist)

                else:
                    flash("You should choose ID or Name at least", 'danger')
                    return render_template("eNodeB.html", title="eNodeB", form=form, result=None,
                                           ID_choselist=ID_choselist,
                                           NM_choselist=NM_choselist)

    return render_template("eNodeB.html", title="eNodeB", form=form, result=None, ID_choselist=ID_choselist,
                           NM_choselist=NM_choselist)


@app.route('/KPI', methods=['GET', 'POST'])
@login_required
def KPI():
    form = ExportForm()
    time = db.engine.execute('select distinct startTime from tbKPI').fetchall()
    neName = db.engine.execute('select DISTINCT neName from tbKPI').fetchall()
    index = db.metadata.tables['tbKPI'].columns.keys()
    for i in range(0, len(index)):
        index[i] = kpi_rename(index[i])

    if form.validate_on_submit():
        return excel.make_response_from_tables(db.session, [tbKPI_export], 'csv')

    if request.method == "POST":
        # 获取初始和结束时间
        db.session.execute('delete from tbKPI_export')
        db.session.commit()
        starttime = request.form.get('starttime')
        starttime = starttime + '/2016 00:00:00'
        endtime = request.form.get('endtime')
        endtime = endtime + '/2016 00:00:00'
        # 初试时间必须小于等于结束时间
        if starttime > endtime:
            flash("The starttime must be greater than endtime", 'danger')
            return render_template("KPI.html", title="KPI", form=form, neName=neName, index=index, name=None)
        # 获取网元名称
        select_neName = request.form.get('select_neName')
        if len(select_neName) == 0:
            flash("You should choose neName first", 'danger')
            return render_template("KPI.html", title="KPI", form=form, neName=neName, index=index, name=None)
        # 获取属性名称
        select_index = request.form.get('select_index')
        if len(select_index) == 0:
            flash("You should choose index first", 'danger')
            return render_template("KPI.html", title="KPI", form=form, neName=neName, index=index, name=None)
        select_index = get_kpi_keys(select_index)
        print(starttime, endtime)
        print(select_index)

        result = db.engine.execute("select * from tbKPI where startTime between '" + starttime +
                                   "' and '" + endtime + "' and neName='" + select_neName + "'").fetchall()
        if len(result) == 0:
            flash("There is no result during this period", 'danger')
            return render_template("KPI.html", title="KPI", form=form, neName=neName, index=index, name=None)
        x_label = db.engine.execute("select DISTINCT startTime from tbKPI where startTime between '" + starttime +
                                    "' and '" + endtime + "' and neName='" + select_neName + "'").fetchall()

        for data in result:
            data = str(data).replace('None', 'NULL')
            db.session.execute('insert into tbKPI_export values ' + data)

        db.session.commit()
        result = pd.DataFrame(result)
        temp = []

        # 解决中文显示问题
        plt.rcParams['font.sans-serif'] = ['KaiTi']  # 指定默认字体
        plt.rcParams['axes.unicode_minus'] = False  # 解决保存图像是负号'-'显示为方块的问题

        for i in range(0, len(result) // len(x_label)):
            for j in range(0, len(x_label)):
                temp.append(result[kpi_index(select_index[0])][i + j * (len(result) // len(x_label))])

            plt.plot(x_label, temp, label=result[4][i], color=randomcolor())
            plt.grid()
            plt.legend(bbox_to_anchor=(1.0, 1), loc=1, borderaxespad=0.)
            temp = []

        plt.savefig('app/templates/KPI_plot.png')
        plt.close()

        figfile = io.BytesIO(open('app/templates/KPI_plot.png', 'rb').read())
        img = base64.b64encode(figfile.getvalue()).decode('ascii')

        return render_template("KPI.html", title="KPI", form=form, neName=neName, index=index, name='new_plot',
                               url=img)
    return render_template("KPI.html", title="KPI", form=form, neName=neName, index=index, name=None)


@app.route('/PRB', methods=['GET', 'POST'])
@login_required
def PRB():
    form = ExportForm()
    neName = db.engine.execute('select DISTINCT neName from tbPRBNew').fetchall()
    index = db.metadata.tables['tbPRBNew'].columns.keys()
    if form.validate_on_submit():
        return excel.make_response_from_tables(db.session, [tbPRB_export], 'csv')

    if request.method == "POST":
        db.session.execute('delete from tbPRB_export')
        db.session.commit()
        startdate = request.form.get('starttime')
        starthour = request.form.get('starthour')
        starttime = startdate + '/2016 ' + str(starthour).zfill(2) + ':00:00'

        enddate = request.form.get('endtime')
        endhour = request.form.get('endhour')
        endtime = enddate + '/2016 ' + str(endhour).zfill(2) + ':00:00'

        # 初试时间必须小于等于结束时间
        if starttime > endtime:
            flash("The starttime must be greater than endtime", 'danger')
            return render_template("PRB.html", title="PRB", form=form, neName=neName, index=index, name=None)

        # 获取网元名称
        select_neName = request.form.get('select_neName')
        if len(select_neName) == 0:
            flash("You should choose neName first", 'danger')
            return render_template("PRB.html", title="PRB", form=form, neName=neName, index=index, name=None)

        # 获取属性名称
        select_index = request.form.get('select_index')
        if len(select_index) == 0:
            flash("You should choose index first", 'danger')
            return render_template("PRB.html", title="PRB", form=form, neName=neName, index=index, name=None)

        result = db.engine.execute("select * from tbPRBNew where startTime between '" + starttime +
                                   "' and '" + endtime + "' and neName='" + select_neName + "'").fetchall()
        if len(result) == 0:
            flash("There is no result during this period", 'danger')
            return render_template("PRB.html", title="PRB", form=form, neName=neName, index=index, name=None)

        x_label = db.engine.execute("select DISTINCT startTime from tbPRBNew where startTime between '" + starttime +
                                    "' and '" + endtime + "' and neName='" + select_neName + "'").fetchall()

        for data in result:
            data = str(data).replace('None', 'NULL')
            db.session.execute('insert into tbPRB_export values ' + data)
        db.session.commit()

        result = pd.DataFrame(result)
        temp = []

        # 解决中文显示问题
        plt.rcParams['font.sans-serif'] = ['KaiTi']  # 指定默认字体
        plt.rcParams['axes.unicode_minus'] = False  # 解决保存图像是负号'-'显示为方块的问题

        for i in range(0, len(result) // len(x_label)):
            for j in range(0, len(x_label)):
                temp.append(result[prb_index(select_index)][i + j * (len(result) // len(x_label))])
            plt.plot(x_label, temp, label=result[4][i], color=randomcolor())
            plt.xticks(rotation=90)
            plt.grid()
            plt.legend(bbox_to_anchor=(1.0, 1), loc=1, borderaxespad=0.)
            temp = []

        plt.savefig('app/templates/PRB_plot.png')
        plt.close()

        figfile = io.BytesIO(open('app/templates/PRB_plot.png', 'rb').read())
        img = base64.b64encode(figfile.getvalue()).decode('ascii')
        return render_template("PRB.html", title="PRB", form=form, neName=neName, index=index, name='new_plot',
                               url=img)

    return render_template("PRB.html", title="PRB", form=form, neName=neName, index=index, name=None)


@app.route('/download_kpi', methods=['GET', 'POST'])
def download_kpi():
    filename = 'KPI_plot.png'
    uploads = os.path.join('C:/Users/Memo/PycharmProjects/DatabaseProj-master/app/templates/')
    return send_from_directory(directory=uploads, filename=filename)

@app.route('/download_prb', methods=['GET', 'POST'])
def download_prb():
    filename = 'PRB_plot.png'
    uploads = os.path.join('C:/Users/Memo/PycharmProjects/DatabaseProj-master/app/templates/')
    return send_from_directory(directory=uploads, filename=filename)


@app.route('/progress/<table_name>/<filename>/<batch_size>')
def progress(table_name, filename, batch_size):
    print('table_name=', table_name)
    print('filename=', filename)
    print('batch_size=', batch_size)

    def upload_file():
        print(table_name)
        print(filename)

        batch_size = 50
        table = db.metadata.tables[table_name]

        # get filtered dataframe
        if table_name == 'tbCell' or table_name == 'tbKPI':
            df = pd.read_excel(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            if table_name == 'tbCell':
                df = check_cell(df)  # filter out all invalid lines
            else:
                df = check_kpi(df)

            size = df.shape[0]

            for idx in range(0, size, batch_size):
                thePercent = idx * 100 // size
                yield "data:" + str(thePercent) + "\n\n"
                print('thePercent is', thePercent)

                # get batch
                if idx + batch_size >= size:
                    sub = df.iloc[idx:size]
                else:
                    sub = df.iloc[idx:idx + batch_size]

                if table_name == 'tbCell':
                    db.engine.execute(table.insert(), sub.to_dict('records'))
                elif table_name == 'tbKPI':
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

        elif table_name == 'tbPRB':
            wb = openpyxl.load_workbook(os.path.join(app.config['UPLOAD_FOLDER'], filename), read_only=True)
            ws = wb[wb.sheetnames[0]]  # only one sheet

            # attribute names
            new_name = table.columns.keys()

            sub, i = [], 0
            for row in ws.rows:
                if i > 0:
                    values = [cell.value for cell in row]
                    my_dict = dict(zip(new_name, values))
                    sub.append(my_dict)
                if i and i % batch_size == 0:
                    yield "data:" + str(i*100//93024) + '\n\n'
                    #yield "data:" + f'{i*100/93024:.2f}' + '\n\n'
                    print(f'inserting {len(sub)} lines in sub')
                    db.engine.execute(table.insert(), sub)
                    sub = []  # prepare an empty list for next batch

                i += 1

            # for the last time, there remains less than 50 rows to insert in sub
            db.engine.execute(table.insert(), sub)
        elif table_name == 'tbMROData':
            i = 0
            for chunk in pd.read_csv(os.path.join(app.config['UPLOAD_FOLDER'], filename), chunksize=batch_size):
                yield "data:" + str(i * batch_size * 100 // 875604) + '\n\n'
                #yield "data:" + f'{i*100/875604:.2f}' + '\n\n'
                db.engine.execute(table.insert(), chunk.to_dict('records'))
                i += 1
        yield "data:100\n\n"

    # return Response(generate(), mimetype='text/event-stream')
    return Response(upload_file(), mimetype='text/event-stream')


def randomcolor():
    colorArr = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F']
    color = ""
    for i in range(6):
        color += colorArr[random.randint(0, 14)]
    return "#" + color


def kpi_index(select_index):
    dict1 = {
        'startTime': 0,
        'turnround': 1,
        'neName': 2,
        'cell': 3,
        'cellName': 4,
        'rrcSucTime': 5,
        'rrcReqTime': 6,
        'rrcSucRate': 7,
        'erabSucTime': 8,
        'erabReqTime': 9,
        'erabSucRate': 10,
        'enodebException': 11,
        'cellException': 12,
        'erabOfflineRate': 13,
        '_O': 14,
        '_P': 15,
        '_Q': 16,
        '_R': 17,
        '_S': 18,
        '_T': 19,
        '_U': 20,
        '_V': 21,
        '_W': 22,
        '_X': 23,
        '_Y': 24,
        '_Z': 25,
        '_AA': 26,
        '_AB': 27,
        '_AC': 28,
        '_AD': 29,
        '_AE': 30,
        '_AF': 31,
        '_AG': 32,
        '_AH': 33,
        '_AI': 34,
        '_AJ': 35,
        '_AK': 36,
        '_AL': 37,
        '_AM': 38,
        '_AN': 39,
        '_AO': 40,
        '_AP': 41
    }
    num = dict1[select_index]
    return num

def kpi_rename(select_index):
    dict1 = {
        'startTime': '起始时间',
        'turnround': '周期',
        'neName': '网元名称',
        'cell': '小区',
        'cellName': '小区名',
        'rrcSucTime': 'RRC连接建立完成次数 (无)',
        'rrcReqTime': 'RRC连接请求次数（包括重发） (无)',
        'rrcSucRate': 'RRC建立成功率qf (%)',
        'erabSucTime': 'E-RAB建立成功总次数 (无)',
        'erabReqTime': 'E-RAB建立尝试总次数 (无)',
        'erabSucRate': 'E-RAB建立成功率2 (%)',
        'enodebException': 'eNodeB触发的E-RAB异常释放总次数 (无)',
        'cellException': '小区切换出E-RAB异常释放总次数 (无)',
        'erabOfflineRate': 'E-RAB掉线率(新) (%)',
        '_O': '无线接通率ay (%)',
        '_P': 'eNodeB发起的S1 RESET导致的UE Context释放次数 (无)',
        '_Q': 'UE Context异常释放次数 (无)',
        '_R': 'UE Context建立成功总次数 (无)',
        '_S': '无线掉线率 (%)',
        '_T': 'eNodeB内异频切换出成功次数 (无)',
        '_U': 'eNodeB内异频切换出尝试次数 (无)',
        '_V': 'eNodeB内同频切换出成功次数 (无)',
        '_W': 'eNodeB内同频切换出尝试次数 (无)',
        '_X': 'eNodeB间异频切换出成功次数 (无)',
        '_Y': 'eNodeB间异频切换出尝试次数 (无)',
        '_Z': 'eNodeB间同频切换出成功次数 (无)',
        '_AA': 'eNodeB间同频切换出尝试次数 (无)',
        '_AB': 'eNB内切换成功率 (%)',
        '_AC': 'eNB间切换成功率 (%)',
        '_AD': '同频切换成功率zsp (%)',
        '_AE': '异频切换成功率zsp (%)',
        '_AF': '切换成功率 (%)',
        '_AG': '小区PDCP层所接收到的上行数据的总吞吐量 (比特)',
        '_AH': '小区PDCP层所发送的下行数据的总吞吐量 (比特)',
        '_AI': 'RRC重建请求次数 (无)',
        '_AJ': 'RRC连接重建比率 (%)',
        '_AK': '通过重建回源小区的eNodeB间同频切换出执行成功次数 (无)',
        '_AL': '通过重建回源小区的eNodeB间异频切换出执行成功次数 (无)',
        '_AM': '通过重建回源小区的eNodeB内同频切换出执行成功次数 (无)',
        '_AN': '通过重建回源小区的eNodeB内异频切换出执行成功次数 (无)',
        '_AO': 'eNB内切换出成功次数 (次)',
        '_AP': 'eNB内切换出请求次数 (次)'
    }
    name = dict1[select_index]
    return name

def prb_index(select_index):
    dict1 = {
        'startTime': 0,
        'turnround': 1,
        'neName': 2,
        'cell': 3,
        'cellName': 4
    }
    for i in range(0, 100):
        dict1['PRB' + str(i)] = i + 5

    num = dict1[select_index]
    return num

def get_kpi_keys(value):
    dict1 = {
        'startTime': '起始时间',
        'turnround': '周期',
        'neName': '网元名称',
        'cell': '小区',
        'cellName': '小区名',
        'rrcSucTime': 'RRC连接建立完成次数 (无)',
        'rrcReqTime': 'RRC连接请求次数（包括重发） (无)',
        'rrcSucRate': 'RRC建立成功率qf (%)',
        'erabSucTime': 'E-RAB建立成功总次数 (无)',
        'erabReqTime': 'E-RAB建立尝试总次数 (无)',
        'erabSucRate': 'E-RAB建立成功率2 (%)',
        'enodebException': 'eNodeB触发的E-RAB异常释放总次数 (无)',
        'cellException': '小区切换出E-RAB异常释放总次数 (无)',
        'erabOfflineRate': 'E-RAB掉线率(新) (%)',
        '_O': '无线接通率ay (%)',
        '_P': 'eNodeB发起的S1 RESET导致的UE Context释放次数 (无)',
        '_Q': 'UE Context异常释放次数 (无)',
        '_R': 'UE Context建立成功总次数 (无)',
        '_S': '无线掉线率 (%)',
        '_T': 'eNodeB内异频切换出成功次数 (无)',
        '_U': 'eNodeB内异频切换出尝试次数 (无)',
        '_V': 'eNodeB内同频切换出成功次数 (无)',
        '_W': 'eNodeB内同频切换出尝试次数 (无)',
        '_X': 'eNodeB间异频切换出成功次数 (无)',
        '_Y': 'eNodeB间异频切换出尝试次数 (无)',
        '_Z': 'eNodeB间同频切换出成功次数 (无)',
        '_AA': 'eNodeB间同频切换出尝试次数 (无)',
        '_AB': 'eNB内切换成功率 (%)',
        '_AC': 'eNB间切换成功率 (%)',
        '_AD': '同频切换成功率zsp (%)',
        '_AE': '异频切换成功率zsp (%)',
        '_AF': '切换成功率 (%)',
        '_AG': '小区PDCP层所接收到的上行数据的总吞吐量 (比特)',
        '_AH': '小区PDCP层所发送的下行数据的总吞吐量 (比特)',
        '_AI': 'RRC重建请求次数 (无)',
        '_AJ': 'RRC连接重建比率 (%)',
        '_AK': '通过重建回源小区的eNodeB间同频切换出执行成功次数 (无)',
        '_AL': '通过重建回源小区的eNodeB间异频切换出执行成功次数 (无)',
        '_AM': '通过重建回源小区的eNodeB内同频切换出执行成功次数 (无)',
        '_AN': '通过重建回源小区的eNodeB内异频切换出执行成功次数 (无)',
        '_AO': 'eNB内切换出成功次数 (次)',
        '_AP': 'eNB内切换出请求次数 (次)'
    }
    return [k for k,v in dict1.items() if v == value]
import os
from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

app = Flask(__name__)

# Security Configs
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'madarsa-secret-key-prod-2026')

# Database URL Handling (Explicit psycopg driver mapping)
db_url = os.environ.get('DATABASE_URL', '')
if db_url.startswith("postgres://"):
    db_url = db_url.replace("postgres://", "postgresql+psycopg://", 1)
elif db_url.startswith("postgresql://") and not db_url.startswith("postgresql+psycopg://"):
    db_url = db_url.replace("postgresql://", "postgresql+psycopg://", 1)

app.config['SQLALCHEMY_DATABASE_URI'] = db_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
limiter = Limiter(get_remote_address, app=app, default_limits=["200 per day", "50 per hour"])

# Models
class AdminUser(db.Model):
    __tablename__ = 'admin_users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)

class MaslaEntry(db.Model):
    __tablename__ = 'masail_entries'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(250), nullable=False)
    explanation = db.Column(db.Text, nullable=False)
    book_title = db.Column(db.String(200), nullable=False)
    volume = db.Column(db.String(50))
    page_number = db.Column(db.Integer)

# Routes
@app.route('/login', methods=['GET', 'POST'])
@limiter.limit("10 per minute")
def login():
    if request.method == 'POST':
        uname = (request.form.get('username') or '').strip()
        pword = (request.form.get('password') or '').strip()
        
        user = AdminUser.query.filter_by(username=uname).first()
        if user and bcrypt.check_password_hash(user.password_hash, pword):
            session['admin_id'] = user.id
            session['username'] = user.username
            return redirect(url_for('dashboard'))
        
        flash('Galat credentials! Koshish record ho rahi hai.', 'danger')
    return render_template('login.html')

@app.route('/')
def dashboard():
    if 'admin_id' not in session:
        return redirect(url_for('login'))
    masail = MaslaEntry.query.order_by(MaslaEntry.id.desc()).all()
    return render_template('dashboard.html', username=session['username'], masail=masail)

@app.route('/masla/add', methods=['POST'])
def add_masla():
    if 'admin_id' not in session:
        return redirect(url_for('login'))
    entry = MaslaEntry(
        title=request.form.get('title'),
        explanation=request.form.get('explanation'),
        book_title=request.form.get('book_title'),
        volume=request.form.get('volume'),
        page_number=request.form.get('page_number', type=int)
    )
    db.session.add(entry)
    db.session.commit()
    flash('Masla record mehfooz kar liya gaya hai.', 'success')
    return redirect(url_for('dashboard'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

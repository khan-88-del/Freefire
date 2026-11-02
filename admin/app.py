import os
from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

app = Flask(__name__)

# Security Configs
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'madarsa-super-secret-key-prod-2026')
database_url = os.environ.get('DATABASE_URL', 'sqlite:///madarsa.db')
if database_url.startswith("postgres://"):
    database_url = database_url.replace("postgres://", "postgresql://", 1)
app.config['SQLALCHEMY_DATABASE_URI'] = database_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Cookies Security
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
app.config['SESSION_COOKIE_SECURE'] = bool(os.environ.get('RENDER'))

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
limiter = Limiter(get_remote_address, app=app, default_limits=["200 per day", "50 per hour"])

# Models
class AdminUser(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)

class MaslaEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    explanation = db.Column(db.Text, nullable=False)
    book_title = db.Column(db.String(200), nullable=False)
    volume = db.Column(db.String(50))
    page_number = db.Column(db.Integer)

# ऑटो-क्रिएट टेबल और ऑटो-क्रिएट एडमिन
with app.app_context():
    db.create_all()
    # अगर एडमिन मौजूद नहीं है तो अपने आप बना देगा
    admin_user = AdminUser.query.filter_by(username="itsmeatifkhan").first()
    if not admin_user:
        hashed = bcrypt.generate_password_hash("atif809047").decode('utf-8')
        new_admin = AdminUser(username="itsmeatifkhan", password_hash=hashed)
        db.session.add(new_admin)
        db.session.commit()
        print(">>> Default Super Admin Created Successfully! <<<")

@app.route('/login', methods=['GET', 'POST'])
@limiter.limit("10 per minute")
def login():
    if request.method == 'POST':
        user = AdminUser.query.filter_by(username=request.form.get('username')).first()
        if user and bcrypt.check_password_hash(user.password_hash, request.form.get('password')):
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
    app.run(host='0.0.0.0', port=5000, debug=True)

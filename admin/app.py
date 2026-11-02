import os
import time
from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import cloudinary
import cloudinary.uploader
import cloudinary.api
import cloudinary.utils

app = Flask(__name__)

# Security Configs
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'madarsa-secret-key-prod-2026')

# Cloudinary Configuration
CLOUD_NAME = "zufwpc7e"
API_KEY = "388794978456266"
API_SECRET = "8PSkiOY-CtKiRECNldZz_Y6v2-A"
MADARSA_TAG = "809047"

cloudinary.config(
    cloud_name = CLOUD_NAME,
    api_key = API_KEY,
    api_secret = API_SECRET,
    secure = True
)

# Database URL
db_url = os.environ.get('DATABASE_URL', '').strip()
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

# Auto-sync admin credentials on boot
with app.app_context():
    try:
        db.create_all()
        target_user = "itsmeatifkhan"
        target_pass = "atif809047"
        existing = AdminUser.query.filter_by(username=target_user).first()
        hashed = bcrypt.generate_password_hash(target_pass).decode('utf-8')
        if existing:
            existing.password_hash = hashed
        else:
            new_admin = AdminUser(username=target_user, password_hash=hashed)
            db.session.add(new_admin)
        db.session.commit()
    except Exception as e:
        db.session.rollback()

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
    
    photos = []
    videos = []
    try:
        p_res = cloudinary.api.resources_by_tag(MADARSA_TAG, resource_type="image", max_results=50)
        photos = p_res.get('resources', [])
        
        v_res = cloudinary.api.resources_by_tag(MADARSA_TAG, resource_type="video", max_results=50)
        videos = v_res.get('resources', [])
    except Exception as e:
        print("Cloudinary fetch error:", e)

    return render_template('dashboard.html', 
                           username=session['username'], 
                           masail=masail, 
                           photos=photos, 
                           videos=videos,
                           cloud_name=CLOUD_NAME,
                           api_key=API_KEY)

# Direct Upload Signature API
@app.route('/gallery/signature', methods=['POST'])
def generate_signature():
    if 'admin_id' not in session:
        return jsonify({'error': 'Unauthorized'}), 401
    
    timestamp = int(time.time())
    folder = f"madarsa_{MADARSA_TAG}"
    tags = f"{MADARSA_TAG},madarsa_portal"
    
    params_to_sign = {
        'folder': folder,
        'tags': tags,
        'timestamp': timestamp
    }
    
    signature = cloudinary.utils.api_sign_request(params_to_sign, API_SECRET)
    
    return jsonify({
        'signature': signature,
        'timestamp': timestamp,
        'api_key': API_KEY,
        'cloud_name': CLOUD_NAME,
        'folder': folder,
        'tags': tags
    })

# Delete Media Route
@app.route('/gallery/delete', methods=['POST'])
def delete_media():
    if 'admin_id' not in session:
        return redirect(url_for('login'))
    
    public_id = request.form.get('public_id')
    resource_type = request.form.get('resource_type', 'image')
    
    if public_id:
        try:
            cloudinary.uploader.destroy(public_id, resource_type=resource_type)
            flash('File kamyabi se delete kar di gayi.', 'success')
        except Exception as e:
            flash(f'Delete nahi ho saki: {str(e)}', 'danger')
            
    return redirect(url_for('dashboard'))

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

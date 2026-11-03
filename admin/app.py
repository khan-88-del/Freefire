
import os
import time
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify, Response
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import cloudinary
import cloudinary.uploader
import cloudinary.api
import cloudinary.utils
import urllib.request

app = Flask(__name__)

@app.route('/ping')
def ping():
    return "pong", 200

app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'madarsa-secret-key-prod-2026')

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

class SyllabusClass(db.Model):
    __tablename__ = 'syllabus_classes'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    pdfs = db.relationship('SyllabusPDF', backref='syllabus_class', cascade='all, delete-orphan', lazy=True)

class SyllabusPDF(db.Model):
    __tablename__ = 'syllabus_pdfs'
    id = db.Column(db.Integer, primary_key=True)
    class_id = db.Column(db.Integer, db.ForeignKey('syllabus_classes.id'), nullable=False)
    title = db.Column(db.String(200), nullable=False)
    file_url = db.Column(db.String(500), nullable=False)
    public_id = db.Column(db.String(200), nullable=False)
    uploaded_at = db.Column(db.DateTime, default=datetime.utcnow)

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
    classes = SyllabusClass.query.order_by(SyllabusClass.id.asc()).all()

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
                           classes=classes,
                           photos=photos,
                           videos=videos,
                           cloud_name=CLOUD_NAME,
                           api_key=API_KEY)


@app.route('/gallery/upload', methods=['POST'])
def bulk_gallery_upload():
    if 'admin_id' not in session:
        return jsonify({'error': 'Unauthorized'}), 401
    
    files = request.files.getlist('files')
    if not files:
        return jsonify({'error': 'No files uploaded'}), 400

    uploaded = 0
    for f in files:
        if f and f.filename != '':
            is_video = f.mimetype.startswith('video/')
            res_type = 'video' if is_video else 'image'
            try:
                cloudinary.uploader.upload(
                    f,
                    folder=f"madarsa_{MADARSA_TAG}",
                    tags=[MADARSA_TAG, "madarsa_portal"],
                    resource_type=res_type
                )
                uploaded += 1
            except Exception as e:
                print("Upload err:", e)
                
    return jsonify({'success': True, 'count': uploaded})

@app.route('/gallery/signature', methods=['POST'])
def generate_signature():
    if 'admin_id' not in session:
        return jsonify({'error': 'Unauthorized'}), 401

    timestamp = int(time.time())
    folder = f"madarsa_{MADARSA_TAG}"
    tags = f"{MADARSA_TAG},madarsa_portal"
    params_to_sign = {'folder': folder, 'tags': tags, 'timestamp': timestamp}
    signature = cloudinary.utils.api_sign_request(params_to_sign, API_SECRET)

    return jsonify({
        'signature': signature,
        'timestamp': timestamp,
        'api_key': API_KEY,
        'cloud_name': CLOUD_NAME,
        'folder': folder,
        'tags': tags
    })

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

# PDF Upload
def upload_pdf_file(pdf_file, title):
    clean_title = "".join(c for c in title if c.isalnum() or c in (' ', '_', '-')).strip().replace(' ', '_')
    custom_public_id = f"madarsa_{MADARSA_TAG}/syllabus/{clean_title}_{int(time.time())}"
    
    res = cloudinary.uploader.upload(
        pdf_file,
        public_id=custom_public_id,
        resource_type="raw"
    )
    return res.get('secure_url'), res.get('public_id')

@app.route('/syllabus/create-class', methods=['GET', 'POST'])
def create_class():
    if 'admin_id' not in session:
        return redirect(url_for('login'))

    if request.method == 'POST':
        class_name = (request.form.get('class_name') or '').strip()
        pdf_title = (request.form.get('pdf_title') or '').strip()
        pdf_file = request.files.get('pdf_file')

        if not class_name:
            flash('Class ka naam daalna zaroori hai!', 'danger')
            return redirect(url_for('create_class'))

        existing_c = SyllabusClass.query.filter_by(name=class_name).first()
        if existing_c:
            flash('Yeh class pehle se maujood hai!', 'warning')
            return redirect(url_for('create_class'))

        new_class = SyllabusClass(name=class_name)
        db.session.add(new_class)
        db.session.commit()

        if pdf_file and pdf_file.filename != '':
            try:
                title = pdf_title if pdf_title else pdf_file.filename
                secure_url, pub_id = upload_pdf_file(pdf_file, title)
                new_pdf = SyllabusPDF(
                    class_id=new_class.id,
                    title=title,
                    file_url=secure_url,
                    public_id=pub_id
                )
                db.session.add(new_pdf)
                db.session.commit()
            except Exception as e:
                flash(f'Class ban gayi lekin PDF upload error: {str(e)}', 'warning')

        flash(f'Class "{class_name}" kamyabi se create ho gayi!', 'success')
        return redirect(url_for('view_syllabus_classes'))

    return render_template('create_class.html')

@app.route('/syllabus/classes')
def view_syllabus_classes():
    if 'admin_id' not in session:
        return redirect(url_for('login'))
    classes = SyllabusClass.query.order_by(SyllabusClass.id.asc()).all()
    return render_template('syllabus_classes.html', classes=classes)

@app.route('/syllabus/class/<int:class_id>')
def class_detail(class_id):
    if 'admin_id' not in session:
        return redirect(url_for('login'))
    s_class = SyllabusClass.query.get_or_404(class_id)
    return render_template('class_detail.html', s_class=s_class)

@app.route('/syllabus/class/<int:class_id>/add-pdf', methods=['POST'])
def add_pdf_to_class(class_id):
    if 'admin_id' not in session:
        return redirect(url_for('login'))

    s_class = SyllabusClass.query.get_or_404(class_id)
    pdf_title = (request.form.get('pdf_title') or '').strip()
    pdf_file = request.files.get('pdf_file')

    if not pdf_file or pdf_file.filename == '':
        flash('Kripya PDF file chunein!', 'warning')
        return redirect(url_for('class_detail', class_id=class_id))

    try:
        title = pdf_title if pdf_title else pdf_file.filename
        secure_url, pub_id = upload_pdf_file(pdf_file, title)
        new_pdf = SyllabusPDF(
            class_id=s_class.id,
            title=title,
            file_url=secure_url,
            public_id=pub_id
        )
        db.session.add(new_pdf)
        db.session.commit()
        flash('PDF kamyabi se add kar di gayi!', 'success')
    except Exception as e:
        flash(f'Upload fail: {str(e)}', 'danger')

    return redirect(url_for('class_detail', class_id=class_id))

# Proxy View / Download Route (Never 401 ACL error)
@app.route('/syllabus/pdf/<int:pdf_id>/view')
def view_or_download_pdf(pdf_id):
    pdf = SyllabusPDF.query.get_or_404(pdf_id)
    try:
        # Generate authenticated download URL using credentials
        auth_url = cloudinary.utils.cloudinary_url(
            pdf.public_id,
            resource_type="raw",
            type="upload",
            sign_url=True
        )[0]

        req = urllib.request.Request(auth_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            file_data = response.read()

        clean_title = "".join(c for c in pdf.title if c.isalnum() or c in (' ', '_', '-')).strip()
        filename = f"{clean_title}.pdf"

        # Check if download requested
        is_dl = request.args.get('download', '0') == '1'
        disposition = f'attachment; filename="{filename}"' if is_dl else f'inline; filename="{filename}"'

        return Response(
            file_data,
            mimetype='application/pdf',
            headers={'Content-Disposition': disposition}
        )
    except Exception as e:
        # Fallback to direct redirect
        return redirect(pdf.file_url)

@app.route('/syllabus/pdf/<int:pdf_id>/delete', methods=['POST'])
def delete_pdf(pdf_id):
    if 'admin_id' not in session:
        return redirect(url_for('login'))

    pdf = SyllabusPDF.query.get_or_404(pdf_id)
    class_id = pdf.class_id
    try:
        cloudinary.uploader.destroy(pdf.public_id, resource_type="raw")
        cloudinary.uploader.destroy(pdf.public_id, resource_type="image")
    except Exception:
        pass

    db.session.delete(pdf)
    db.session.commit()
    flash('PDF delete kar di gayi.', 'success')
    return redirect(url_for('class_detail', class_id=class_id))

# API Routes for Mobile App
@app.route('/api/syllabus/classes', methods=['GET'])
def api_syllabus_classes():
    classes = SyllabusClass.query.order_by(SyllabusClass.id.asc()).all()
    res = []
    for c in classes:
        res.append({
            'id': c.id,
            'name': c.name,
            'pdf_count': len(c.pdfs)
        })
    return jsonify({'success': True, 'classes': res})

@app.route('/api/syllabus/class/<int:class_id>/pdfs', methods=['GET'])
def api_class_pdfs(class_id):
    s_class = SyllabusClass.query.get(class_id)
    if not s_class:
        return jsonify({'success': False, 'error': 'Class not found'}), 404
    pdfs = []
    for p in s_class.pdfs:
        # Secure stream URL instead of raw Cloudinary URL
        secure_stream_url = url_for('view_or_download_pdf', pdf_id=p.id, _external=True)
        pdfs.append({
            'id': p.id,
            'title': p.title,
            'file_url': secure_stream_url,
            'uploaded_at': p.uploaded_at.strftime('%d-%b-%Y') if p.uploaded_at else ''
        })
    return jsonify({
        'success': True,
        'class_name': s_class.name,
        'pdfs': pdfs
    })

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

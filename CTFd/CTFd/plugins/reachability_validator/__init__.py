import os
import socket
from flask import Blueprint, jsonify
from CTFd.utils.decorators import admins_only

def load(app):
    # יצירת ה-Blueprint
    reachability_bp = Blueprint('reachability', __name__)

    @reachability_bp.route('/admin/validate_ec2', methods=['GET'])
    @admins_only
    def validate():
        try:
            # נתיב ישיר לקובץ ה-IP
            ip_file_path = r"C:\Users\amith\OneDrive\שולחן העבודה\CTF-mainfolder\server_ip.txt"
            
            if not os.path.exists(ip_file_path):
                return jsonify({"status": "error", "message": "File not found"}), 404

            # קריאה בינארית לניקוי תווים בעייתיים (Null Bytes)
            with open(ip_file_path, "rb") as f:
                raw_data = f.read()
                ip = raw_data.replace(b'\x00', b'').decode('utf-8', 'ignore').strip()
            
            if not ip:
                return jsonify({"status": "error", "message": "IP is empty"}), 400

            # בדיקת פורט 8000
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(3)
            result = s.connect_ex((ip, 8000))
            s.close()

            if result == 0:
                return jsonify({"status": "success", "message": f"Server {ip} is UP!"})
            else:
                return jsonify({"status": "failed", "message": f"Server {ip} is down or port 8000 is closed"}), 500
        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 500

    # רישום ה-Blueprint באפליקציה
    app.register_blueprint(reachability_bp)
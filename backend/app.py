from flask import Flask, request, jsonify
from dotenv import load_dotenv
import os
import pymongo

load_dotenv()

MONGO_URI = os.getenv('MONGO_URI')

if not MONGO_URI:
    raise RuntimeError("MONGO_URI is missing. Add it to flask-backend/.env")

client = pymongo.MongoClient(MONGO_URI)
db = client.test
collection = db['flask-tutorial']

app = Flask(__name__)


@app.route('/api/submit', methods=['POST'])
def submit():
    form_data = request.get_json(silent=True)

    if not isinstance(form_data, dict):
        return jsonify({
            'success': False,
            'error': 'Invalid form data'
        }), 400

    try:
        collection.insert_one(form_data)
        return jsonify({
            'success': True,
            'message': 'Data submitted successfully'
        }), 201

    except Exception:
        app.logger.exception("MongoDB insertion failed")
        return jsonify({
            'success': False,
            'error': 'Failed to submit data to MongoDB'
        }), 500


if __name__ == '__main__':
<<<<<<< HEAD
    app.run(debug=False, port=5000, host='0.0.0.0')
=======
    app.run(debug=False, port=5000, host='127.0.0.1')
>>>>>>> f08f857 (terraform changes)

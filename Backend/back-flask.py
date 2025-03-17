import json
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/api/validate-token', methods=['POST'])
def validate_token():
    if request.method == 'POST':
        data = request.json
        token_str = data.get("token", "")

        if token_str:
            try:
                token_data = json.loads(token_str)  # This is where the error occurred
                userId = token_data.get("userId", "")
                deviceId = token_data.get("deviceId", "")
                expiresAt = token_data.get("expiryDate", 0)

                if userId and deviceId and expiresAt:
                    return jsonify({"message": "Token received", "token": token_data}), 200
                else:
                    return jsonify({"error": "Invalid token data"}), 400
            except json.JSONDecodeError:
                return jsonify({"error": "Invalid token format"}), 400
        else:
            return jsonify({"error": "No token provided"}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5002)  # Specify the port and host here

from flask import Flask
import psycopg2

app = Flask(__name__)

@app.route('/')
def home():
    try:
        conn = psycopg2.connect(
            host="db",
            database="fusiondb",
            user="fusionpact",
            password="fusionpact123"
        )
        cursor = conn.cursor()
        cursor.execute("SELECT NOW();")
        result = cursor.fetchone()
        return f"Fusionpact DevOps App Running! DB Time: {result}"
    except Exception as e:
        return f"DB Connection Failed: {e}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

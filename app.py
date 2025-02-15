from flask import Flask, render_template, request, session, redirect, url_for,  jsonify
import cv2
import numpy as np
import os
from tensorflow.keras.models import load_model
import pickle
from tqdm import tqdm
import glob
from ocr import page, words
from functions import *


app = Flask(__name__)
app.secret_key = "your_secret_key"
UPLOAD_FOLDER = "static/uploads"
CROPPED_FOLDER = "static/cropped_letters"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(CROPPED_FOLDER, exist_ok=True)

@app.route("/", methods=["GET", "POST"])
def index():
    if "username" not in session:
        return redirect(url_for("login"))

    if request.method == "POST":
        if "image" not in request.files:
            return render_template("index.html", prediction="No file uploaded")

        file = request.files["image"]
        if file.filename == "":
            return render_template("index.html", prediction="No file selected")

        filepath = os.path.join(UPLOAD_FOLDER, file.filename)
        file.save(filepath)

        cropped_images = process_image(filepath)

        filepath2 = os.path.join(CROPPED_FOLDER, file.filename)

        test_fold = sorted(glob.glob(filepath2))
        print(test_fold)

        predictions = predict_letters(test_fold)

        return render_template("index.html", uploaded_image=filepath, cropped_images=cropped_images, predictions=predictions)

    return render_template("index.html", prediction="")

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    if username == "admin" and password == "password": 
        session["username"] = username
        return jsonify({"success": True, "message": "Login successful"})
    else:
        return jsonify({"success": False, "message": "Invalid credentials"}), 401

@app.route("/logout")
def logout():
    session.pop("username", None)
    return redirect(url_for("login"))

if __name__ == "__main__":
    app.run(debug=True)

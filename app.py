from flask import Flask, render_template, request
import cv2
import numpy as np
import os
from tensorflow.keras.models import load_model
import pickle
from tqdm import tqdm
import glob
from ocr import page, words

app = Flask(__name__)
UPLOAD_FOLDER = "static/uploads"
CROPPED_FOLDER = "static/cropped_letters"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(CROPPED_FOLDER, exist_ok=True)

model = load_model("D:/Projects/AIML/DIGILIPI/Malayalam_detection.h5")
with open("detail.pkl", 'rb') as f:
    loaded_pickle_data = pickle.load(f)

class_labels = loaded_pickle_data['class_labels']

def process_image(image_path):
    """ Detects and crops letter regions from the image """
    
    image = cv2.imread(image_path)
    image = page.detection(image) 
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    _, thresh = cv2.threshold(gray, 150, 255, cv2.THRESH_BINARY_INV)
    
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    cropped_letters = []
    padding = 10  

    for i, contour in tqdm(enumerate(contours), total=len(contours), desc="Processing Contours", unit="contour"):
        x, y, w, h = cv2.boundingRect(contour)
        
        if w > 10 and h > 10 and cv2.contourArea(contour) > 50: 
            x_pad = max(x - padding, 0)
            y_pad = max(y - padding, 0)
            w_pad = min(x + w + padding, image.shape[1]) - x_pad
            h_pad = min(y + h + padding, image.shape[0]) - y_pad
            
            # Crop the letter region (without drawing bounding boxes)
            letter = image[y_pad:y_pad+h_pad, x_pad:x_pad+w_pad]

            # Convert to grayscale
            letter_gray = cv2.cvtColor(letter, cv2.COLOR_BGR2GRAY)
            
            # Threshold to remove background (white -> transparent, black -> white)
            _, letter_thresh = cv2.threshold(letter_gray, 150, 255, cv2.THRESH_BINARY_INV)
            
            # Convert black to white and keep white transparent
            letter_alpha = cv2.merge((letter_thresh, letter_thresh, letter_thresh, letter_thresh))

            # Save as PNG with transparency
            filename = os.path.join(CROPPED_FOLDER, f'letter_{len(cropped_letters) + 1}.png')
            cv2.imwrite(filename, letter_alpha)
            
            cropped_letters.append(letter_alpha)


    return cropped_letters

def predict_letters(test_fold):
    """ Predicts letters from cropped images """
    predictions = []
    for img_path in test_fold:
        print(img_path)
        img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)
        img = cv2.resize(img, (128, 128), interpolation=cv2.INTER_LINEAR)
        img = np.reshape(img, (1, 128, 128, 1))

        prediction = model.predict(img, verbose=0)
        predicted_class = np.argmax(prediction[0])
        predictions.append(class_labels[predicted_class])
    print(predictions)
    
    

    return predictions

@app.route("/", methods=["GET", "POST"])
def index():
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

        test_fold=sorted(glob.glob(filepath2))
        print(test_fold)

        predictions = predict_letters(test_fold)

        return render_template("index.html", uploaded_image=filepath, cropped_images=cropped_images, predictions=predictions)

    return render_template("index.html", prediction="")

if __name__ == "__main__":
    app.run(debug=True)

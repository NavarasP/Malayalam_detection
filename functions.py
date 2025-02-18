from flask import Flask, render_template, request
import cv2
import numpy as np
import os
from tensorflow.keras.models import load_model
import pickle
from tqdm import tqdm
import glob
from ocr import page, words
import json


model = load_model("D:/Projects/AIML/DIGILIPI/Malayalam_detection.h5")
with open("detail.pkl", 'rb') as f:
    loaded_pickle_data = pickle.load(f)

class_labels = loaded_pickle_data['class_labels']
target_names = loaded_pickle_data['target_names']

UPLOAD_FOLDER = "static/uploads"
CROPPED_FOLDER = "static/cropped_letters"

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
            letter = image[y_pad:y_pad+h_pad, x_pad:x_pad+w_pad]
            letter_gray = cv2.cvtColor(letter, cv2.COLOR_BGR2GRAY)
            _, letter_thresh = cv2.threshold(letter_gray, 150, 255, cv2.THRESH_BINARY_INV)            
            letter_alpha = cv2.merge((letter_thresh, letter_thresh, letter_thresh, letter_thresh))
            filename = os.path.join(CROPPED_FOLDER, f'letter_{len(cropped_letters) + 1}.png')
            cv2.imwrite(filename, letter_alpha)
            
            cropped_letters.append(letter_alpha)


    return cropped_letters

def predict_letters(test_fold):
    """ Predicts letters from cropped images """

    with open("cropped_letters/bounding_boxes.json", "r") as f:
        bounding_boxes = json.load(f)
    bounding_boxes.sort(key=lambda b: (b["y"], b["x"]))

    predictions = []
    for img, box in zip(test_fold, bounding_boxes):
        i = cv2.imread(img, cv2.IMREAD_GRAYSCALE)
        i = cv2.resize(i, (128, 128), interpolation=cv2.INTER_LINEAR)
        i = np.reshape(i, (1, 128, 128, 1))

        prediction = model.predict(i, verbose=0)
        p = np.argmax(prediction[0])
        
        recognized_char = target_names[p] 
        print(recognized_char) 
        predictions.append((box["y"], box["x"], recognized_char)) 

    predictions.sort()

    recognized_text = "".join([char for _, _, char in predictions])
    with open("recognized_text.txt", "w", encoding="utf-8") as f:
        f.write(recognized_text)
    
    return predictions

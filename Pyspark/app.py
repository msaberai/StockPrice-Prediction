from flask import Flask
from flask import request,render_template, url_for
import os
import pickle


app = Flask(__name__)

IMAGES_FOLDER = os.path.join('static', 'images')

app.config['UPLOAD_FOLDER'] = IMAGES_FOLDER


@app.route('/')
def hello():
    return "Hello World!"



@app.route('/predict')
def student():
    return render_template('prediction.html')

@app.route('/result',methods = ['POST', 'GET'])
def result():
   if request.method == 'POST':
      result = request.form
      Open = request.form['Open Price']
      High = request.form['High Price']
      Low = request.form['Low Price']
      #features = [Open,high,Low]
      #return m.log_pred(features,"logistic.sav")
      pred = -0.0012528138087026146+(-0.555261962948*float(Open))+(0.82677350476*float(High))+(0.727976861395*float(Low))
      return "The Close Price Prediction is : "+ "{0:.2f}".format(pred)

if __name__ == "__main__":
    try:
        app.run(debug=True)
    except Exception as e:
        print("Error")













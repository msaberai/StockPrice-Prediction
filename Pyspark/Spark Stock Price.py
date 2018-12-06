
# coding: utf-8

# In[1]:

raw_data = sc.textFile("Apple_Dataset.csv")

raw_data.take(2)


# In[2]:

header = raw_data.first()

dataLines= raw_data.filter(lambda ln: ln not in header)

dataLines.take(2)


# In[3]:

dataLines.count(), raw_data.count()


# In[4]:

csvData=dataLines.map((lambda x: x.split(",")))


# In[5]:

csvData.take(2)


# In[6]:

import math
from pyspark.mllib.linalg import Vectors
from pyspark.mllib.regression import LabeledPoint
from numpy import array
from pyspark.sql import Row


# In[7]:

#labelPoint that MLLIB can use.All data must be numeric
def vector_data(fields):
    Adj_open = float(fields[0])
    Adj_high = float(fields[1])
    Adj_low = float(fields[2])
    Adj_close = float(fields[3])
    return Vectors.dense([Adj_open,Adj_high,Adj_low,Adj_close]) 


# In[8]:

autoVectors = csvData.map(vector_data)
autoVectors.take(2)


# In[9]:

def transformToLabelPoint (instr):
    lp = (float(instr[3]),Vectors.dense([instr[0],instr[1],instr[2]]))
    return lp


# In[10]:

from pyspark.sql import SQLContext
sqlcontext = SQLContext(sc)


# In[11]:

autoLp= autoVectors.map(transformToLabelPoint)
autoDF = sqlcontext.createDataFrame(autoLp,["label","features"])
autoDF.select("label","features").show(2)


# In[12]:

#Split into training and testing data
(trainingData, testData) = autoDF.randomSplit([0.9, 0.1],seed=0)
raw_data.count(),trainingData.count(),testData.count()


# In[13]:

testData.take(2)


# In[14]:

#Build the model on training data
from pyspark.ml.regression import LinearRegression
lr = LinearRegression(maxIter=10)
lrModel = lr.fit(trainingData)


# In[15]:

print("Coefficients:"+str(lrModel.coefficients))


# In[16]:

print("Intercept:"+str(lrModel.intercept))


# In[17]:

#Predict on test data
predictions = lrModel.transform(testData)
predictions.select("features","label","prediction").show()


# In[18]:

from pyspark.ml.evaluation import RegressionEvaluator
evaluator =  RegressionEvaluator(predictionCol="prediction",labelCol="label",metricName="r2")

evaluator.evaluate(predictions)


# In[21]:

y = -0.0012528138087026146+(-0.555261962948*0.414962396)+(0.82677350476*0.416694413)+(0.727976861395*0.414962396)
y


# In[ ]:




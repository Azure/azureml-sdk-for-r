# python wrapper. The code can be auto-generated based on InferenceConfig
import rpy2.robjects as robjects
import os
import json
from azureml.core.model import Model

def init():
    global r_run

    # install packages
    # CAUTION: If init() call failed, the inference launcher will keep retrying
    # This results in packages repeatly get installed again and again :( So
    # 1) check package existence before install
    # 2) have proper error handling in python wrapper is important
    robjects.r('''
        install.packages("caret", repos = "http://cran.us.r-project.org")
        install.packages("e1071", repos = "http://cran.us.r-project.org")
        install.packages("jsonlite", repos = "http://cran.us.r-project.org")
        ''')

    score_r_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "score.R")
    # handle path for windows os
    score_r_path = score_r_path.replace('\\', '/')
    robjects.r('''source('{}')'''.format(score_r_path))

    model_path = Model.get_model_path('model.rds')
    r_run = robjects.r['init'](model_path)


def run(input_data):
    dataR = r_run(input_data)[0]
    return json.loads(dataR)

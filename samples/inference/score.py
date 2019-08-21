# python wrapper. The code can be auto-generated based on InferenceConfig
import rpy2.robjects as robjects
import os
import json

def init():
    score_r_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "score.R")
    # handle path for windows os
    score_r_path = score_r_path.replace('\\', '/')
    robjects.r('''source('{}')'''.format(score_r_path))
    robjects.r['init']()


def run(input_data):
    dataR = robjects.r['run'](input_data)[0]
    return json.loads(dataR)

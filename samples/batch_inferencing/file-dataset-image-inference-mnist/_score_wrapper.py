# code generated python wrapper
import rpy2.robjects as robjects
import os
import json


def init():
    global r_run

    score_r_path = os.path.join(os.path.dirname(
      os.path.realpath(__file__)),
      "score.R")

    # handle path for windows os
    score_r_path = score_r_path.replace('\\', '/')
    robjects.r.source("{}".format(score_r_path))
    r_run = robjects.r['init']()

def run(mini_batch):
    dataR = r_run(mini_batch)[0]
    return json.loads(dataR)


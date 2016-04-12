#!/usr/bin/env python
import argparse
import os
import pkg_resources
import json
from mako.template import Template
# Reminders about Lens example files:
# - Files begin with a header that set defaults.
# - The header is terminated with a semi-colon.
# - Each ``trial'' can be composed of many events.
# - In this model, there are three events:
#   1. Presentation
#   2. Settling---letting the recurrent dynamics happen
#   3. Evaluation---the targets are presented, and error assessed.
# - Each event lasts two ticks, so a full trial is 6 ticks.
resource_package = 'lexdec'

resource_path_network = os.path.join('template','lexdec_in.mako')
network_template_string = pkg_resources.resource_string(resource_package, resource_path_network)
network_template = Template(network_template_string)

resource_path_examples = os.path.join('template','lexdec_ex.mako')
examples_template_string = pkg_resources.resource_string(resource_package, resource_path_examples)
examples_template = Template(examples_template_string)

p = argparse.ArgumentParser()
p.add_argument('config')
p.add_argument('-o','--output',type=str,default='train.ex')
args = p.parse_args()

PATH_TO_JSON = args.config
EX_FILENAME = args.output
IN_FILENAME = os.path.join(os.path.dirname(EX_FILENAME),'network.in')
#TRAINSCRIPT_FILENAME = os.path.join(os.path.dirname(EX_FILENAME),'trainscript.tcl')

#resource_path_trainscript = os.path.join('template',trainscript_template_filename)
#trainscript_template_string = pkg_resources.resource_string(resource_package, resource_path_trainscript)
#trainscript_template = Template(trainscript_template_string)

# Load instructions
with open(PATH_TO_JSON,'r') as f:
    CONFIG = json.load(f)

# Write Network file
network_text = network_template.render(NetInfo=CONFIG)
with open(IN_FILENAME,'w') as f:
    f.write(network_text.strip())

# Write Example file
examples_text = examples_template.render(NetInfo=CONFIG)
with open(EX_FILENAME,'w') as f:
    f.write(examples_text.strip())

# Write Trainscript
#trainscript_text = trainscript_template.render(CONFIG=CONFIG,NETINFO=NETINFO)
#with open(TRAINSCRIPT_FILENAME,'w') as f:
#    f.write(trainscript_text.strip())

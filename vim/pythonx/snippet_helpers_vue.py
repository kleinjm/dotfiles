from snippet_helpers import *
import re

def vue_component_name(path, snip):
    path = path.split('pages/')[1]
    path = path_without_extension(path)
    snip.rv = path_as_class_name(path, separator="")

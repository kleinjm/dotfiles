from snippet_helpers import *
import re

def vue_page_name(path, snip):
    path = path.split('pages/')[1]
    path = path_without_extension(path)
    snip.rv = path_as_class_name(path, separator="")

def vue_component_name(path, snip):
    path = filename_without_extension(path)
    snip.rv = path_as_class_name(path, separator="")

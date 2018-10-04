from snippet_helpers import *
import re

def rb_assign_instance_var_list(args, snip):
    handler = lambda arg: rb_assign_instance_var(arg, snip)
    count = 0
    snip.shift(1)
    for arg in args.split(","):
        regex = re.compile("[*&]*([a-zA-Z0-9_]+)")
        match = regex.match(arg.strip())
        if match:
            if count > 0: snip.rv += "\n"
            count += 1
            snip.rv += snip.mkline("@{0} = {0}".format(match.group(1)))

def rb_class_name(path, snip):
    cwd = vim.eval("getcwd()") + "/"
    path = path.split(cwd)[1]
    path = path_without_first_dir(path)
    path = path_without_extension(path)
    snip.rv = path_as_class_name(path, separator="::")

def rb_flat_class_name(path, snip):
    cwd = vim.eval("getcwd()") + "/"
    path = path.split(cwd)[1]
    path = path_without_first_dir(path)
    path = path_as_class_name(path, separator="::")
    snip.rv = path.split("::")[-1]

def rb_module_name(path, snip):
    cwd = vim.eval("getcwd()") + "/"
    path = path.split(cwd)[1]
    path = path_without_first_dir(path)
    path = path_as_class_name(path, separator="::")
    snip.rv = "::".join(path.split("::")[0:-1])

def rb_operation_name(path, snip):
    cwd = vim.eval("getcwd()") + "/"
    path = path.split(cwd)[1]
    path = path_without_first_dir(path)
    path = path_as_class_name(path, separator="::")
    snip.rv = "::".join(filter(lambda part: part != "Operation", path.split("::")))

def rb_operation_spec_class_name(path, snip):
    cwd = vim.eval("getcwd()") + "/"
    path = path.split(cwd)[1]
    path = path_without_first_dir(path)
    path = path_as_class_name(path, separator="::")
    path = "::".join(filter(lambda part: part != "Operation", path.split("::")))
    snip.rv = re.split('Spec$', path)[0]

def rb_spec_class_name(path, snip):
    cwd = vim.eval("getcwd()") + "/"
    path = path.split(cwd)[1]
    path = path_without_first_dir(path)
    path = path_without_extension(path)
    path = path_as_class_name(path, separator="::")
    snip.rv = re.split('Spec$', path)[0]

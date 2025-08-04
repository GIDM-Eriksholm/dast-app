#      Main script for using SoundMexPro with Python
#               Copyright 2023 Daniel Berg
#
# This script interfaces to the SoundMexPro libraries SoundMexProPy32 or SoundMexProPy64
# respectively. It must be located in BIN directory of SoundMexPro, the BIN directory
# must be added to the Ptyhon path e.g. using sys.path.append
#
# Required Python libraries that are not part of the standard library
#   - numpy

import os
import numpy
import ctypes
import struct

# global variables holding library handle of loaded DLL and function pointer to 
# SoundMexPro's exported command funtion
libhandle   = 0
smp         = 0

# tool function to check if value is a float
def isfloat(value):
  try:
    float(value)
    return True
  except ValueError:
    return False

# tool function to check if value is an int
def isint(value):
  try:
    int(value)
    return True
  except ValueError:
    return False

# function for parsing input arguments   
def parse_arguments_in(arguments):
   cmd = ''
   for key, value in arguments.items():
      # special handling for 'data' and 'datadest': extract dimensions and data pointer
      # of passed array
      if key == 'data' or key == 'datadest':
         # check, that it IS an numpy array!
         if type(value) != numpy.ndarray :
            raise ValueError('data and datatest values must be of type numpy.ndarray')
         if value.ndim == 1:
            channels = 1
         elif value.ndim == 2:
            channels = value.shape[1]
         else:
            raise ValueError('ndim of passed array unexpectedly > 2')
         samples = value.shape[0]
         # append data=POINTER;samples=Y;channels=X;interleaved=1
         cmd = cmd + str(key) + '=' + str(value.__array_interface__['data'][0]).strip("[]") + ';samples=' + str(samples) + ';channels=' + str(channels) + ';' # + ';interleaved=1;'
      else:      
         cmd = cmd + str(key) + '=' + str(value).strip("[]") + ';'
         
   return cmd

# function for parsing output arguments      
def parse_arguments_out(command, arguments, retvals):
   # here we parse the return string that looks like
   #  name1=value1;channels=1,2,3;other=4;....
   #  we want to convert scalars to scalars, comma-separated
   #  scalars to arrays and all other types to strings
   # print(arguments.value())
   arguments = arguments.value.decode(encoding='cp1252').split(';')
   for item in arguments:
      # any items at all?
      if len(item) > 0:
         # split key and value
         item = item.split('=')
         key = item[0]
         # split value by comma
         value = item[1].split(',')
         
         # check all subitems: are ALL int or ALL float? Special handling...
         all_values_float = True
         all_values_int   = True
         single_stringvalue_in_array = False
         
         # search them ....
         for subvalue in value:
            if isfloat(subvalue) == False:
               all_values_float = False
            if isint(subvalue) == False:
               all_values_int = False
       
         # special handling for two commands: always strings to be returned for input and output!
         if (command == 'getchannels' or command == 'getactivechannels') and (key == 'input' or key == 'output'):  
            all_values_float = False
            all_values_int = False
        
         # create value in dictionary
         if all_values_int:
            # single int? set it!
            if len(value) == 1:
               retvals[key] = int(item[1])
            # multiple ints? create matrix!
            else:
               values = []
               for subvalue in value:
                  values.append(int(subvalue))
               retvals[key] = values
         elif all_values_float:
            # single float? set it!
            if len(value) == 1:
               retvals[key] = float(item[1])
            # multiple floats? create matrix!
            else:
               values = []
               for subvalue in value:
                  values.append(float(subvalue))
               retvals[key] = values
         else:
            # all other values: set them as string as they are            
            if len(value) == 1 and command != 'getdrivers':
               retvals[key] = item[1].strip("\"\'")
            else: 
               values = []
               for subvalue in value:
                  values.append(subvalue.strip("\"\'"))
               retvals[key] = values
         
   return retvals
   
# main soundmexpro function
# \param[in] command name of SoundMexPro command
# \param[in] arguments dictionary with all arguments
# \retval dictionary with all return values. The item 'result' always holds
# success/failure of the command: 1 on success, 0 on 'busy', < 0 on other errors 
def soundmexpro(command, arguments = None):
   global libhandle
   global smp
   
   if libhandle == 0:
      # determine if we have to load 32bit or 64bit DLL
      version = struct.calcsize("P")*8
      libhandle = ctypes.cdll.LoadLibrary(os.path.dirname(__file__) + '\\SoundMexProPy' + str(version) + '.dll')
      #  32bit DLL exports functions with leading underscore, 64bit DLL doesn't
      if version == 32:
         smp = libhandle._SoundMexPro
      else:
         smp = libhandle.SoundMexPro
      # input arguments: const char* for command input, char* for return buffer, int for size of return buffer
      smp.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_int]
      smp.restype = ctypes.c_int
      
   if arguments == None:
      arguments = {}
   
   # create return value buffer
   retvals = ctypes.create_string_buffer(b"", 32768)
   
   # special for 'recgetdata': call 'recbufsize' beforehand to retrieve buffersize 
   # of channels to query 
   tmprecbuf = {}
   if command == 'recgetdata':
      tmpvalues = soundmexpro('recbufsize', arguments)
      # create matrix with double values
      # NOTE: we use first buffersize here by purpose: if different values are set for the channels
      # recgetdata was called for, then 'recgetdata' will fail within SoundDllPro, so we don't have
      # to take care here
      value = tmpvalues["value"]
      channels  = 1
      samples   = value
      if type(value) == list:
        channels = len(value)
        samples  = value[0]
      # NOTE: data within soundmexpro are non-interleaved, thus pass them correspondingly alligned 
      # to SoundMexPro!
      tmprecbuf = numpy.asfortranarray(numpy.zeros((samples, channels), dtype=numpy.float32))
      # write it as 'datadest' to dictionary
      arguments["datadest"] = tmprecbuf
   
   
   # create command to be sent 
   cmd = 'command=' + command + ';'
   if arguments != None:
      cmd = cmd + parse_arguments_in(arguments)
      
   # call dll. return value is success (1 = success, 0 = busy, < 0 = error)
   result = smp(cmd.encode(), retvals, len(retvals))
   # on failure raise an AssertioError
   # If you prefer to get the error in a key in returned dictionary instead, comment 
   # this handling. Copying to dictionary is done below
   if result != 1:
      raise AssertionError('soundmexpro returned an error from command "' + command + '"')

   # convert all return values to dictionary
   allretvals = {}
   # add 'main' return value (success flag) 
   allretvals["success"] = result
   
   allretvals = parse_arguments_out(command, retvals, allretvals)
   
   # special for 'recgetdata': remove 'channels' and 'bufsize' and
   # add recorded data as matrix
   if command == 'recgetdata':
      allretvals.pop("channels")
      allretvals.pop("bufsize")
      allretvals["data"] = tmprecbuf
   # print(allretvals)
   return allretvals
   
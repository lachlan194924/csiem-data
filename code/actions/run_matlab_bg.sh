#!/bin/bash
matlab_exec=matlab
echo "execute_import_pipeline();" > matlab_command.m
${matlab_exec} -nodisplay -nosplash -nodesktop < matlab_command.m & > 'log.txt'
rm matlab_command.m

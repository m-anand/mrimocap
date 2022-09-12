function status = generateV3DPipeline(strDir, strFNPipeline, strFNModelC3D,strFNTemplate, strFNMotionC3D, strFNMAT,~)
%generateV3DPipeline(strDir)  This function demonstrates how to generate and
%   save a Visual3D pipeline script to a user specified directory.  This
%   particular example will:
%   1.  Create a new workspace (File|New).
%   2.  Create a hybrid model (Model|Create|Hybrid Model from C3DFile).
%   3.  Apply a model template (Model|Apply Model Template).
%   4.  Insert a motion file (File|Open).
%   5.  Assign the model to the motion file (Model|Assign Model to Motion
%       files).
%   6.  Calculate the position of the left shank with respect to the left
%       thigh (Model|Compute Model Based Data).
%   7.  Export a LINK_MODEL_BASED signal as a MATLAB .mat file.
%   8.  Save the workspace (File|Save Workspace).
%
%   The resulting v3s file can then be executed using the Visual3D Pipeline
%   Processing dialog.  Alternatively, the pipeline can also be run from
%   within MATLAB using the runV3DPipeline() function.  The resulting data
%   can then be loaded into MATLAB using loadMATData().
%
%   strDir:  the directory where the standing and walking C3D and template
%       MDH files are located.  The resulting pipeline script and Visual3D
%       workspace files will also be saved in this directory.
%
%   Example:  status = generateV3DPipeline('C:\data')
%
%   Copyright (C) 2008 C-Motion, Inc.  All rights reserved.
%   For support contact support@c-motion.com.  

disp(['generateV3DPipeline() -- Generating v3s pipeline file in ' strDir '...']);

% Change these filenames as needed.
% strFNPipeline = 'example.v3s';
% strFNModelC3D = 'standing.c3d';
% strFNTemplate = 'template.mdh';
% strFNMotionC3D = 'walk1.c3d';
% strFNMAT = 'example.mat';
 strFNWorkspace = 'example.cmo';
 


% fid = fopen([strDir '\' strFNPipeline],'w');
fid = fopen(fullfile(strDir,strFNPipeline),'w');

if fid > 0
    % Create a new workspace (File|New).
    fprintf(fid,'File_New\r\n');
    fprintf(fid,';\r\n');
    fprintf(fid,'\r\n');

    % Create a hybrid model (Model|Create|Hybrid Model from C3DFile).
    fprintf(fid,'Create_Hybrid_Model\r\n');
    fprintf(fid,'/CALIBRATION_FILE=%s\r\n',fullfile(strDir,strFNModelC3D));
    fprintf(fid,'! /RANGE=ALL_FRAMES\r\n');
    fprintf(fid,';\r\n');
    fprintf(fid,'\r\n');

    % Apply a model template (Model|Apply Model Template).
    fprintf(fid,'Apply_Model_Template\r\n');
    fprintf(fid,'/MODEL_TEMPLATE=%s\r\n',strFNTemplate);
    fprintf(fid,'/CALIBRATION_FILE=%s\r\n',fullfile(strDir,strFNModelC3D));
    fprintf(fid,';\r\n');
    fprintf(fid,'\r\n');

    % Build model
    fprintf(fid,'Build_Model\r\n');
    fprintf(fid,'/CALIBRATION_FILE=%s\r\n',fullfile(strDir,strFNModelC3D));
    fprintf(fid,'! /REBUILD_ALL_MODELS=FALSE\r\n');
    fprintf(fid,';\r\n');
    fprintf(fid,'\r\n');

    % Insert a motion file (File|Open).
    fprintf(fid,'Open_File\r\n');
    fprintf(fid,'/FILE_NAME=%s\r\n',fullfile(strDir,strFNMotionC3D));
    fprintf(fid,'! /CALIBRATION_FILE=\r\n');
    fprintf(fid,';\r\n');
    fprintf(fid,'\r\n');

    % Assign the model to the motion file (Model|Assign Model to Motion
    % files).
    fprintf(fid,'Assign_Model_File\r\n');
    fprintf(fid,'/CALIBRATION_FILE=%s\r\n',fullfile(strDir,strFNModelC3D));
    fprintf(fid,'/MOTION_FILE_NAMES=%s\r\n',fullfile(strDir,strFNMotionC3D));
    fprintf(fid,';\r\n');
    fprintf(fid,'\r\n');

    % Filter the signals
    
    fprintf(fid,'Lowpass_Filter\r\n');
    fprintf(fid,'/SIGNAL_TYPES=TARGET\r\n');
    fprintf(fid,'! /SIGNAL_FOLDER=ORIGINAL\r\n');
    fprintf(fid,'! /SIGNAL_NAMES=\r\n');
    fprintf(fid,'! /RESULT_FOLDER=PROCESSED\r\n');
    fprintf(fid,'! /RESULT_SUFFIX=\r\n');
    fprintf(fid,'! /FILTER_CLASS=BUTTERWORTH\r\n');
    fprintf(fid,'/FREQUENCY_CUTOFF=12\r\n');
    fprintf(fid,'! /NUM_REFLECTED=6\r\n');
    fprintf(fid,'! /NUM_EXTRAPOLATED=0\r\n');
    fprintf(fid,'! /TOTAL_BUFFER_SIZE=6\r\n');
    fprintf(fid,'! /NUM_BIDIRECTIONAL_PASSES=1\r\n');
    fprintf(fid,';\r\n');
    fprintf(fid,'\r\n');
    
    
    % recalc
    
    fprintf(fid,'Recalc\r\n');
    fprintf(fid,';\r\n');
    fprintf(fid,'\r\n');
    
    
    
    % Calculate the position of the left shank with respect to the left
    % thigh (Model|Compute Model Based Data).
    fprintf(fid,'Compute_Model_Based_Data\r\n');
    fprintf(fid,'/RESULT_NAME=LT_KNEE_ANGLE\r\n');
    fprintf(fid,'/FUNCTION=JOINT_ANGLE\r\n');
    fprintf(fid,'/SEGMENT=%s\r\n','LSK');
    fprintf(fid,'/REFERENCE_SEGMENT=%s\r\n','LTH');
    fprintf(fid,'/RESOLUTION_COORDINATE_SYSTEM=\r\n');                
    fprintf(fid,'! /USE_CARDAN_SEQUENCE=FALSE\r\n');
    fprintf(fid,'! /NORMALIZATION=FALSE\r\n');
    fprintf(fid,'/NORMALIZATION_METHOD=TRUE\r\n');
    fprintf(fid,'! /NORMALIZATION_METRIC=\r\n');
    fprintf(fid,'! /NEGATEX=FALSE\r\n');
    fprintf(fid,'! /NEGATEY=FALSE\r\n');
    fprintf(fid,'! /NEGATEZ=FALSE\r\n');
    fprintf(fid,'! /AXIS1=X\r\n');
    fprintf(fid,'! /AXIS2=Y\r\n');
    fprintf(fid,'! /AXIS3=Z\r\n');
    fprintf(fid,';\r\n');
    fprintf(fid,'\r\n');

    
    % Calculate the position of the right shank with respect to the right
    % thigh (Model|Compute Model Based Data).
    fprintf(fid,'Compute_Model_Based_Data\r\n');
    fprintf(fid,'/RESULT_NAME=RT_KNEE_ANGLE\r\n');
    fprintf(fid,'/FUNCTION=JOINT_ANGLE\r\n');
    fprintf(fid,'/SEGMENT=%s\r\n','RSK');
    fprintf(fid,'/REFERENCE_SEGMENT=%s\r\n','RTH');
    fprintf(fid,'/RESOLUTION_COORDINATE_SYSTEM=\r\n');                
    fprintf(fid,'! /USE_CARDAN_SEQUENCE=FALSE\r\n');
    fprintf(fid,'! /NORMALIZATION=FALSE\r\n');
    fprintf(fid,'/NORMALIZATION_METHOD=TRUE\r\n');
    fprintf(fid,'! /NORMALIZATION_METRIC=\r\n');
    fprintf(fid,'! /NEGATEX=FALSE\r\n');
    fprintf(fid,'! /NEGATEY=FALSE\r\n');
    fprintf(fid,'! /NEGATEZ=FALSE\r\n');
    fprintf(fid,'! /AXIS1=X\r\n');
    fprintf(fid,'! /AXIS2=Y\r\n');
    fprintf(fid,'! /AXIS3=Z\r\n');
    fprintf(fid,';\r\n');
    fprintf(fid,'\r\n');
    
    

    
    % Export a LINK_MODEL_BASED signal as a MATLAB .mat file.
    fprintf(fid,'Export_Data_To_Matfile\r\n');
    fprintf(fid,'/FILE_NAME=%s\r\n',fullfile(strDir,strFNMAT));
    fprintf(fid,'/SIGNAL_TYPES=%s\r\n','LINK_MODEL_BASED+LINK_MODEL_BASED');
    fprintf(fid,'/SIGNAL_NAMES=%s\r\n','RT_KNEE_ANGLE+LT_KNEE_ANGLE');
    fprintf(fid,'/SIGNAL_FOLDER=%s\r\n','ORIGINAL+ORIGINAL');
    fprintf(fid,'/OUTPUT_NAMES=%s\r\n','RT_KNEE_ANGLE+LT_KNEE_ANGLE');
    fprintf(fid,'! /PARAMETER_NAMES=\r\n');
    fprintf(fid,'! /PARAMETER_GROUPS=\r\n');
    fprintf(fid,'! /OUTPUT_PARAMETER_NAMES=\r\n');
    fprintf(fid,'/USE_NAN_FOR_DATANOTFOUND=TRUE\r\n');
    fprintf(fid,';\r\n');
    fprintf(fid,'\r\n');

    fprintf(fid,'Exit_Workspace\r\n');
    fprintf(fid,';\r\n');

    status = fclose(fid);
else
    status = -1;
    disp(['Error opening pipeline file ' strDir '\' strFNPipeline]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

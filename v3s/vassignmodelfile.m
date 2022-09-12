function vassignmodelfile(fid)
% Description: Assigns a model to specified movement files.
%
% @param:	fid = Valid file identifier of Visual3D script.

fprintf(fid, '%s\n', 'Assign_Model_File');
fprintf(fid, '%s\n', '/CALIBRATION_FILE=::DATA_FOLDER&::C3D_STATIC');
fprintf(fid, '%s\n', '/MOTION_FILE_NAMES=ALL_FILES');
fprintf(fid, '%s\n\n', ';');

end

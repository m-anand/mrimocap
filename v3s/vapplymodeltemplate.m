function vapplymodeltemplate(fid, mdh)
% Description: Apply a model template file (.mdh) to a Model (Calibration)
% file.
%
% @param: 	fid = Valid file identifier of Visual3D script.
% @param:   mdh = Name of the model file to be applied.

fprintf(fid, '%s\n', 'Apply_Model_Template');
fprintf(fid, '%s\n', ['/MODEL_TEMPLATE=', mdh]);
fprintf(fid, '%s\n', '/CALIBRATION_FILE=::DATA_FOLDER&::C3D_STATIC');%&_model');
fprintf(fid, '%s\n\n', ';');

end

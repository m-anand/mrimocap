function vcreatehybridmodel(fid)
% Description: Creates a Visual3D hybrid model.
% 
% @param: 	fid = Valid file identifier of Visual3D script.

fprintf(fid, '%s\n', 'Create_Hybrid_Model');
fprintf(fid, '%s\n', '/CALIBRATION_FILE=::DATA_FOLDER&::C3D_STATIC');
fprintf(fid, '%s\n', '! /SUFFIX=_model');    % in case the static trial is exported as a dynamic trial (joint centers,  e.g.)
fprintf(fid, '%s\n\n', ';');

end

function [st, sn, sf, on] = vrknee_angle_lab(fid, st, sn, sf, on, lcs)
% Description: Compute global right knee angle using a model's segment, kinetic, 
% and kinematic data.
%
% @param:   fid = Valid file identifier of Visual3D script.
% @param:   lcs = Laboratory coordinate system, e.g., 'Y' = Y-Up.

fprintf(fid, '%s\n', 'Compute_Model_Based_Data');
fprintf(fid, '%s\n', '/RESULT_NAME=RKneeAngleLAB');
fprintf(fid, '%s\n', '/FUNCTION=JOINT_ANGLE');
fprintf(fid, '%s\n', '/SEGMENT=Right Shank LAB');
fprintf(fid, '%s\n', '/REFERENCE_SEGMENT=Right Thigh LAB');
fprintf(fid, '%s\n', '/RESOLUTION_COORDINATE_SYSTEM=');
fprintf(fid, '%s\n', '! /USE_CARDAN_SEQUENCE=FALSE');
fprintf(fid, '%s\n', '! /NORMALIZATION=FALSE');
fprintf(fid, '%s\n', '! /NORMALIZATION_METHOD=');
fprintf(fid, '%s\n', '! /NORMALIZATION_METRIC=');
enable = '';
if ( lcs == 'Z' ), enable = '! '; end
fprintf(fid, '%s\n', [enable, '/NEGATEX=TRUE']);
fprintf(fid, '%s\n', '! /NEGATEY=FALSE');
fprintf(fid, '%s\n', '! /NEGATEZ=FALSE');
fprintf(fid, '%s\n', '! /AXIS1=X');
fprintf(fid, '%s\n', '! /AXIS2=Y');
fprintf(fid, '%s\n', '! /AXIS3=Z');
fprintf(fid, '%s\n\n', ';');

st = [st, 'LINK_MODEL_BASED+'];
sn = [sn, 'RKneeAngleLAB+'];
sf = [sf, 'ORIGINAL+'];
on = [on, 'RKneeAngleLAB+'];

end

function vfileopen(fid, files)
% Description: Opens the specified file name(s).
%
% @param:	fid = Valid file identifier of Visual3D script.
% @param:	files = C3D files to be opened.

fprintf(fid, '%s\n', 'Open_File');
fprintf(fid, '%s\n', ['/FILE_NAME=', files]);
fprintf(fid, '%s\n\n', ';');

end

function vlowpass_filter(fid, targ, ftype, order, cut)
% Description: Filter the points of a signal using a digit lowpass filter.
%
% @param:	fid = Valid file identifier of Visual3D script.
% @param: 	freq = The number of points reflected at the ends of the
%           signal.
% @param:	cut = The window containing the frames to be averaged.

if ( strcmp(targ, 'Target') )
    stypes = 'TARGET';
    sfolds = 'ORIGINAL';
elseif ( strcmp(targ, 'Forces') )
    stypes = 'GRFORCE+COFP+FREEMOMENT';
    sfolds = 'ORIGINAL+ORIGINAL+ORIGINAL';    
end
fprintf(fid, '%s\n', 'Lowpass_Filter');
fprintf(fid, '%s\n', ['/SIGNAL_TYPES=',  stypes]);
fprintf(fid, '%s\n',  '! /SIGNAL_NAMES=');
fprintf(fid, '%s\n', ['/SIGNAL_FOLDER=', sfolds]);
fprintf(fid, '%s\n', ['/FILTER_CLASS=',  upper(ftype)]);
fprintf(fid, '%s\n', ['/FREQUENCY_CUTOFF=', num2str(cut), '.0']);
fprintf(fid, '%s\n', ['/NUM_REFLECTED=',    num2str(cut)]);
fprintf(fid, '%s\n',  '! /NUM_EXTRAPOLATED=0');
fprintf(fid, '%s\n',  '! /TOTAL_BUFFER_SIZE=6');
fprintf(fid, '%s\n', ['/NUM_BIDIRECTIONAL_PASSES=', num2str(order/4)]);	% 1 is 4th order, 2 is 8th order, etc.
fprintf(fid, '%s\n\n', ';');

end

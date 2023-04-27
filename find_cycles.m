% this function finds the total number of cycles in a block and the ROM per
% cycle in the entire block and returns a structure **outcomes**
function outcomes = find_cycles(S,subject, task, side, verbose)
% initialize
        loop = numel(side);
        header = {'ID', 'Cycles','ROM_sagittal','ROM_frontal','ROM_transverse',...
            'max_sagittal','max_frontal','max_transverse',...
            'min_sagittal','min_frontal','min_transverse','Cycles'};
%         outcomes = struct('Cycles',[],'rom',[], 'header', [], index = loop);
        outcomes = struct('Cycles',[],'rom',[], 'max', [], 'min', [],'std_dev',[], 'header', [], index = loop); 
        n=4;
        output = struct('Name',[],'Cycles',[],'mean_rom',[]);

        switch side
            case 'L'
                V = {S.LT_KNEE_ANGLE{1,1}};
            case 'R'
                V = {S.RT_KNEE_ANGLE{1,1}};
            case 'LR'
                V = {S.LT_KNEE_ANGLE{1,1}
                    S.RT_KNEE_ANGLE{1,1}};
                header = {
                        'ID', 'L_Cycles','L_ROM_sagittal','L_ROM_frontal','L_ROM_transverse', ...                         'L_max_sagittal','L_max_frontal','L_max_transverse',...                        'L_min_sagittal','L_min_frontal','L_min_transverse',...
                        'R_Cycles','R_ROM_sagittal','R_ROM_frontal','R_ROM_transverse'};
%                         'R_max_sagittal','R_max_frontal','R_max_transverse',...
%                         'R_min_sagittal','R_min_frontal','R_min_transverse'
%                         };
                outcomes = struct('L_Cycles',[],'L_rom',[],'L_max', [], 'L_min', [],'L_std_dev',[],...
                                    'R_Cycles',[],'R_rom',[], 'R_max', [], 'R_min', [],'R_std_dev',[],...
                                    'header', [], index = loop);
        end
    if verbose
        figure;

    end

    for k=1:loop
        k
        n
        v = V{k};
        l = 1:length(v);
        
        [lcs,pks] = peakfinder(-v(:,1),2,15,1);         % Find maximas
        [mins, mns] = peakfinder(-v(:,1),[],[],-1);     % Find minimas
        
        % find block start and stop
        v_diff = diff(v(:,1));
        

        d = diff(lcs); % Difference of subsequent peaks
        md = mean(d);   
        fd = find(d>3*md);
        bl =[lcs(1),lcs(fd(1)),lcs(fd(1)+1),lcs(fd(2)),lcs(fd(2)+1),lcs(fd(3)),lcs(fd(3)+1),lcs(end)];
        bl_in =[1,fd(1),fd(1)+1,fd(2),fd(2)+1,fd(3),fd(3)+1,length(lcs)];
        
        fns = fieldnames(outcomes);
        var_tmp=[]; % variable to hold the concatenated timeseries of the movement blocks
        for i=1:4
           for j = bl_in(2*i-1):bl_in(2*i)-1
               var = -v(lcs(j):lcs(j+1),:);
               var_tmp=[var_tmp;var];
               kk = (k-1);
               outcomes.(fns{5*kk+2}) = [outcomes.(fns{5*kk+2}); max(var)-min(var)];
               outcomes.(fns{5*kk+3}) = [outcomes.(fns{5*kk+3}); max(var)];
               outcomes.(fns{5*kk+4}) = [outcomes.(fns{5*kk+4}); min(var)];
           end   
        end
        outcomes.(fns{5*kk+1}) = length(pks);
        outcomes.(fns{5*kk+5}) = std(var_tmp);
        if verbose
               
                subplot(loop,1,k); hold on;
                title(subject+"-  -  -"+side(k)+"-  -  -"+task);
                plot(l,-v(:,1));
                plot(lcs,-v(lcs,1),'ro');            % plot all identified peaks
                plot(mins,-v(mins,1),'r*');            % plot all identified troughs
        %     plot(lcs(fd),pks(fd),'blacks')
                plot(bl,-v(bl),'blacks')            % plotthe start and end of the block
            
        end    
    end
    outcomes.header = header;
end
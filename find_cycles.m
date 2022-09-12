% this function finds the total number of cycles in a block and the ROM per
% cycle in the entire block and returns a structure **outcomes**
function outcomes = find_cycles(S,subject, task, side, verbose)
% initialize
        loop = numel(side);
        header = {'ID', 'Cycles','ROM_sagittal','ROM_frontal','ROM_transverse'};
        outcomes = struct('Cycles',[],'rom',[], 'header', [], index = loop);
        output = struct('Name',[],'Cycles',[],'mean_rom',[]);

        switch side
            case 'L'
                V = {S.LT_KNEE_ANGLE{1,1}};
            case 'R'
                V = {S.RT_KNEE_ANGLE{1,1}};
            case 'LR'
                V = {S.LT_KNEE_ANGLE{1,1}
                    S.RT_KNEE_ANGLE{1,1}};
                header = {'ID', 'L_Cycles','L_ROM_sagittal','L_ROM_frontal','L_ROM_transverse', ...
                    'R_Cycles','R_ROM_sagittal','R_ROM_frontal','R_ROM_transverse'};
                outcomes = struct('L_Cycles',[],'L_rom',[],'R_Cycles',[],'R_rom',[], 'header', [], index = loop);
        end
    if verbose
        figure;

    end

    for k=1:loop

        v = V{k};
        l = 1:length(v);
        
        [lcs,pks] = peakfinder(-v(:,1),2,15,1);
        [mins, mns] = peakfinder(-v(:,1),[],[],-1);
        
        % find block start and stop
        v_diff = diff(v(:,1));
        
        d = diff(lcs);
        md = mean(d);
        fd = find(d>3*md);
        bl =[lcs(1),lcs(fd(1)),lcs(fd(1)+1),lcs(fd(2)),lcs(fd(2)+1),lcs(fd(3)),lcs(fd(3)+1),lcs(end)];
        bl_in =[1,fd(1),fd(1)+1,fd(2),fd(2)+1,fd(3),fd(3)+1,length(lcs)];
        
        fns = fieldnames(outcomes);
        
        for i=1:4
           for j = bl_in(2*i-1):bl_in(2*i)-1
               var = -v(lcs(j):lcs(j+1),:);
               outcomes.(fns{2*k}) = [outcomes.(fns{2*k}); max(var)-min(var)];
           end   
        end
        outcomes.(fns{2*k-1}) = length(pks);
        
        if verbose
               
                subplot(loop,1,k); hold on;
                title(subject+"-  -  -"+side(k)+"-  -  -"+task);
                plot(l,-v(:,1));
                plot(lcs,-v(lcs,1),'o');
        %     plot(min,-v(min,1),'*');
        %     plot(lcs(fd),pks(fd),'blacks')
                plot(bl,-v(bl),'blacks')
            
        end    
    end
    outcomes.header = header;
end
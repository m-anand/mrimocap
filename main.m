%% Simplified motion analysis utility for fMRI biomechanics. ...
% Operates on C3D files
% Manish Anand

clc; clear;
close all;
set(0,'DefaultFigureWindowStyle','docked');
curdir = pwd;

% load the config file
fname_config = fullfile(curdir,"util","config.json");
config = read_config(fname_config);

data_folder = uigetdir(config.data, 'Select root folder containing subjects data');
%%
% load path of V3D model file (.mdh)
strFNTemplate = fullfile(curdir,config.strFNTemplate);
% load tasks
tasks_read = fileread(config.tasks_file);
tasks_name = strsplit(tasks_read);
tasks = append(tasks_name,'.c3d');

% static file name loaded as the first task in the task list
strFNModelC3D = tasks{1};

%% Get user inputs for which task and mode
task = get_task(tasks);
prompt = "Choose mode: 1: Generate v3d file | 2: Run analysis on v3d processed data : ";
mode = input(prompt); % 1: generate v3d pipeline 2: Run analysis
if mode == 1
    prompt2 = "Overwrite if v3s file already exists? y/n  :  ";
    overwrite = input(prompt2,"s");
end
task_c3d = append(task,'.c3d');
output = struct('Name',[],'Cycles',[],'mean_rom',[]);

%%
in = 1;
tab = readtable(config.subject_list_file);
for i = 1:length(tab.subjectID)
   subject = tab.subjectID{i};
   search_subject_dir = glob(fullfile(data_folder,append(subject,'*')));
   subject_dir = search_subject_dir{1};
   
    if exist(subject_dir,'dir')
       disp(sprintf('Subject :  %s',subject));
       task_path = fullfile(subject_dir,task);
       strFNMotionC3D = task;
       
       if exist(task_path)==2
           
           strFNMAT = append(task, '.mat');
           switch mode
               case 1
               % Generate v3d pipeline
                   strFNPipeline = append(task, '.v3s');
                   % don't overwrite
                   if (exist(fullfile(subject_dir, strFNPipeline)))==0 || overwrite=='y'
                        status = generateV3DPipeline(subject_dir, strFNPipeline, strFNModelC3D, strFNTemplate, strFNMotionC3D, strFNMAT);
                       % Run pipeline
                       FNPipeline = fullfile(subject_dir,strFNPipeline);
                       runV3DPipeline(FNPipeline);
                   else
                       disp('V3S generated .. ready for analysis');
                   end

                   
               case 2
               %Run analysis
               disp("Running analysis ...");
               result_file = fullfile(subject_dir,strFNMAT);
               S = load(result_file);
               switch (task)
                   case tasks{2} 
                       outcomes = find_cycles(S.LT_KNEE_ANGLE{1,1},subject,task);
                       
                   case tasks{4}
                       outcomes = find_cycles(S.LT_KNEE_ANGLE{1,1},subject,task);
%                        outcomes = find_cycles(S.RT_KNEE_ANGLE{1,1},subject,task);
                       
                   case tasks{5}
                       outcomes = find_cycles(S.LT_KNEE_ANGLE{1,1},subject,task);
%                        outcomes = find_cycles(S.RT_KNEE_ANGLE{1,1},subject,task);
                   case tasks{3}
                       outcomes = find_cycles(S.RT_KNEE_ANGLE{1,1},subject,task);
               end
               
               output.Name{in,1} = {subject};
               output.Cycles = [output.Cycles;outcomes.Cycles];
               output.mean_rom = [output.mean_rom;mean(outcomes.rom)];
               in = in+1;
               disp("Analysis complete");
               
           end
       end  
%        break; 
    end
end
outfile = fullfile(config.results_folder,append(erase(task,".c3d"),'.xlsx'));
if mode ==2
%     T = table();
%     T.id = output.Name;
%     T = table( output.Cycles, output.mean_rom(:,1), output.mean_rom(:,2), output.mean_rom(:,3), 'VariableNames', {'Cycles','ROM_sagittal','ROM_frontal','ROM_transverse'});
    T = table(output.Name, output.Cycles, output.mean_rom(:,1), output.mean_rom(:,2), output.mean_rom(:,3), 'VariableNames', {'ID', 'Cycles','ROM_sagittal','ROM_frontal','ROM_transverse'});
    writetable(T,outfile)
end
%%
function outcomes = find_cycles(v,subject, task)

    verbose = 1;
    
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
    
    outcomes = struct('Cycles',[],'rom',[]);
    
    for i=1:4
       for j = bl_in(2*i-1):bl_in(2*i)-1
           var = -v(lcs(j):lcs(j+1),:);
           outcomes.rom = [outcomes.rom; max(var)-min(var)];
       end   
    end
    
    
    if verbose
        figure; hold on;
        title(subject+"-  -  -"+task);
        plot(l,-v(:,1));
        plot(lcs,-v(lcs,1),'o');
    %     plot(min,-v(min,1),'*');
    %     plot(lcs(fd),pks(fd),'blacks')
        plot(bl,-v(bl),'blacks')
        
    end
    
    outcomes.Cycles = length(pks);

end
%%
% read the configuration .json file for the program and parse data
function config = read_config(fname_config)
    fid = fopen(fname_config);
    raw = fread(fid, inf);
    str = char (raw');
    fclose(fid);
    config = jsondecode(str);
end

%% 
% Get user input for the tasks
function task = get_task(tasks)
    disp("Task to analyze: ");
    for n =1:numel(tasks)
        fprintf("%d: %s \n",n,tasks{n});
    end
    fprintf("\n")
    x = input("Choose task number: ");
    task = tasks{x};
    fprintf("Task selected : %s \n \n ",task);
end
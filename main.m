%% Simplified motion analysis utility for fMRI biomechanics. ...
% Operates on C3D files
% Manish Anand

clc; clear;
close all;
set(0,'DefaultFigureWindowStyle','docked');
curdir = pwd;
verbose = 1;  % prints output plots
% load the config file
fname_config = fullfile(curdir,"util","config.json");
config = read_config(fname_config);

data_folder = uigetdir(config.data, 'Select root folder containing subjects data');
%%
% load path of V3D model file (.mdh)
strFNTemplate = fullfile(curdir,config.strFNTemplate);
% load tasks
tasks_read = readtable(config.tasks_file);
tasks_name = tasks_read.Task;
tasks = append(tasks_name,'.c3d');

% static file name loaded as the first task in the task list
strFNModelC3D = tasks{1};

%% Get user inputs for which task and mode
[task, x] = get_task(tasks);
prompt = "Choose mode: 1: Generate v3d file | 2: Run analysis on v3d processed data |  3. All of the above  : ";
mode = input(prompt); % 1: generate v3d pipeline 2: Run analysis
prompt2 = "Overwrite if v3s files already exists? y/n  :  ";
switch mode
    case 1
        overwrite = input(prompt2,"s");
        step_1 = 1;    step_2 = 0;

    case 2
        step_1 = 0;     step_2 = 1;
    case 3
        step_1 = 1;     step_2 = 1;
        overwrite = input(prompt2,"s");
end
task_c3d = append(task,'.c3d');
output = struct('Name',[],'Cycles',[],'mean_rom',[]);
if numel(tasks_read.Side{x}) == 2
    output = struct('Name',[],'L_Cycles',[],'L_mean_rom',[],'R_Cycles',[],'R_mean_rom',[]);


end

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

            step_1();
            strFNMAT = append(task, '.mat');

            if step_1
                % Generate v3d pipeline
                strFNPipeline = append(task, '.v3s');
                % overwrite
                if (exist(fullfile(subject_dir, strFNPipeline)))==0 || overwrite=='y'
                    status = generateV3DPipeline(subject_dir, strFNPipeline, strFNModelC3D, strFNTemplate, strFNMotionC3D, strFNMAT);
                    % Run pipeline
                    FNPipeline = fullfile(subject_dir,strFNPipeline);
                    runV3DPipeline(FNPipeline);
                else
                    disp('V3S generated .. ready for analysis');
                end
            end

            if step_2
                %Run analysis
                disp("Running analysis ...");
                result_file = fullfile(subject_dir,strFNMAT);
                S = load(result_file);
                % get measures
                outcomes = find_cycles(S,subject,task,tasks_read.Side{x}, verbose);
                % save mean measures in an array
                output.Name = [output.Name; subject];
                fns = fieldnames(outcomes);
                ind = outcomes.index;
                if ind == 2
                    output.L_Cycles = [output.L_Cycles;outcomes.L_Cycles];
                    output.R_Cycles = [output.R_Cycles;outcomes.R_Cycles];

                    output.L_mean_rom = [output.L_mean_rom;mean(outcomes.L_rom)];
                    output.R_mean_rom = [output.R_mean_rom;mean(outcomes.R_rom)];
                else
                    output.Cycles = [output.Cycles;outcomes.Cycles];
                    output.mean_rom = [output.mean_rom;mean(outcomes.rom)];
                end


            end

            in = in+1;
            disp("Analysis complete");

        end
    end
end
% end
timestamp = datestr(now, '_YYDDmm_HHMM');
outfile = fullfile(config.results_folder,append(erase(task,".c3d"),timestamp,'.xlsx'));
if mode ==2 || mode == 3
    %     T = table();
    %     T.id = output.Name;
    %     T = table( output.Cycles, output.mean_rom(:,1), output.mean_rom(:,2), output.mean_rom(:,3), 'VariableNames', {'Cycles','ROM_sagittal','ROM_frontal','ROM_transverse'});
    %     T = table(output.Name, output.Cycles, output.mean_rom(:,1), output.mean_rom(:,2), output.mean_rom(:,3), 'VariableNames', {'ID', 'Cycles','ROM_sagittal','ROM_frontal','ROM_transverse'});
    if ind == 2
        T = table(output.Name, output.L_Cycles, output.L_mean_rom(:,1), output.L_mean_rom(:,2), output.L_mean_rom(:,3), ...
            output.R_Cycles, output.R_mean_rom(:,1), output.R_mean_rom(:,2), output.R_mean_rom(:,3),...
            'VariableNames', outcomes.header);
    else
        T = table(output.Name, output.Cycles, output.mean_rom(:,1), output.mean_rom(:,2), output.mean_rom(:,3), ...
            'VariableNames', outcomes.header);
    end
        writetable(T,outfile)
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
function [task, x] = get_task(tasks)
disp("Task to analyze: ");
for n =1:numel(tasks)
    fprintf("%d: %s \n",n,tasks{n});
end
fprintf("\n")
x = input("Choose task number: ");
task = tasks{x};
fprintf("Task selected : %s \n \n ",task);
end
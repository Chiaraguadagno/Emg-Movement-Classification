% Template for the script to test the Knn performences with signals
% acquired with shifted electrodes
%
%Input:
%    channel: list of channels to extract features from
%               Nx2 matrix
%               N channels
%               first column --> channel's row
%               second column --> channel's column
%    sp_filt: specify the spatial filter
%               MONO:   monopolar
%               LSD:    longitudinal spatial filter
%               TSD:    transversal spatial filter
%               LP:     laplacian
%   flag_cycles: specify the extraction of specific cycles
%               ext_flex_cycles: extract flexo-extension cycle
%    f_cut:  cutoff frequency for envelope estimation
%    f_debug= flag that enable begug mode
%
% Example
%main_classify(channel, 'LSD', 'ext_flex_cycles', 5, 0);

%Output:
%   none%
%
%author: Marco Gazzoni
%date: 20251129
%Last update:

function main_training(channel, sp_filt, flag_cycles, fcut, f_debug)

global util_path
global result_path

%Specify the path for the protocol
currdir= cd('.\input\');
define_params
load params
cd(currdir);

currdir= cd([signal_path '\' emg_path]);
%specify the session
%obtain the sessions in the pilot
session_folders= dir();
cd(currdir);

n_sessions= length(session_folders);

currdir= cd('.\utilities\uipickfiles');
in = uipickfiles('FilterSpec', [signal_path '\' emg_path '\']);
cd(currdir)

Feat = [];
Class = [];
%Cycle on the sessions
for i_session=1:n_sessions
    if( strcmp(session_folders(i_session).name,'.') || strcmp(session_folders(i_session).name,'..'))
        continue
    end

    if(isempty(cell2mat(strfind(in, session_folders(i_session).name))))
        continue
    end

    %obtain xml filename
    session_folder= session_folders(i_session).name;   %folder that contain the nsig signals
    currdir= cd([data_path '\' session_folder]);
    mat_dir= dir('*');
    mat_dir= mat_dir(end);
    mat_filenames= dir([data_path '\' session_folder '\' mat_dir.name '\*.mat']);
    nsigs= length(mat_filenames);
    cd(currdir);

    %Cycle on the signals
    for isig = 1:nsigs
        %Load the information about the cycles and the estimated envelopes
        load([data_path '\' session_folder '\' mat_dir.name '\' mat_filenames(isig).name]);
        % Extract movement label
        label = get_movement_label(sig_comment);
        disp(['feature extraction for signal ' mat_filenames(isig).name])
     
        %%%%%%%%%%%%%%%%%%%%%%%%%
        % Iterate on the movement cycles and channels
        n_cycs = size(Cycles_norm_in_time.joint_angle,1);
        
        for i_cyc = 1:n_cycs
            % Features extraction
            feat_vals = [];
            %Add in the following the code to cycle on the channels to consider
            %and calc features that will be stored in feat_cyc;

            for i_channel = 1:height(channel)
                [feat_cyc] = calc_features(Cycles_norm_in_time, channel(i_channel,:), i_cyc);
                feat_cyc = table2array(feat_cyc);
                feat_vals = [feat_vals, feat_cyc];
            end
            % Add the estimated features to the vector Feat
            Feat = [Feat; feat_vals];
            Class = [Class; label];
        end
    end
    Class = categorical(Class);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load the trained kNN
    load('KNN_Best_Model.mat','bestModel')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Try classification and estimate performances
    predClass = predict(bestModel,Feat);
    score = sum((predClass ~= Class))/height(Class)*100;
    text = ['Error Rate on SHIFTED set = ',num2str(score),' %'];
    disp(text);
    
    figure
    CM_shift = confusionmat(Class,predClass);
    label = {'Index EXT', 'Index FLEX', 'Little EXT', 'Little FLEX', 'Wrist ABD',...
        'Wrist ADD', 'Wrist EXT', 'Wrist FLEX', 'Middle EXT', 'Middle FLEX',...
        'Ring EXT', 'Ring FLEX'};
    confusionchart(CM_shift, label);
end
end



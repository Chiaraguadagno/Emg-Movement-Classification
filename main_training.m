%Template for the script to train the Knn model with signals 
% acquired with electrodes in the correct position
%Input:
%    sp_filt: specify the spatial filter
%               MONO:   monopolar
%               LSD:    longitudinal spatial filter
%               TSD:    transversal spatial filter
%               LP:     laplacian
%    flag_cycles: specify the extraction of specific cycles
%               ext_flex_cycles: extract flexo-extension cycle
%    f_cut:  cutoff frequency for envelope estimation
%    f_debug = flag that enable degug mode
%    channel: list of channels to extract features from
%                   Nx2 matrix
%                   N channels
%                   first column --> channel's row
%                   second column --> channel's column
%
% Example
%       main_training('LSD', 'ext_flex_cycles', 5, 0, [1,2; 3,3]);

% Output:
%       Feat_trn: matrix [C_trn x 28], coantains the extracted feature for
%       2/3 of cycles for each task
%           C_trn = total cycles for training
%           28 = 7 features x 4 channels
%       Class_trn: categorical array [C_trn x 1]
%                  contains the movement type of the Feat_trn rows  
%       Feat_tst: matrix [C_tst x 28], analogue to Feat_trn and contains
%       the remaining 1/3 of cycles for each task
%       Class_tst: matrix [C_tst x 1], analaogue to Class_trn for Feat_tst
%       Results: table [M x 4]
%           M: # of models tested
%           Column 1: model
%           Column 2: #neighbors of the model
%           Column 3: cross-validation score
%           Column 4: misclassified on training set
%
% authors: Marco Gazzoni, Lorenzo Castiglione, Chiara Guadagno, Fabio
%   Galante, Michele Catena Cardillo
% date: 20251129
% Last update: 24/01/26

function [Feat_trn, Class_trn, Feat_tst, Class_tst]...
    = main_training(sp_filt, flag_cycles, fcut, f_debug, channel)

close all

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

% Cycle on the sessions
for i_session=1:n_sessions
    if( strcmp(session_folders(i_session).name,'.') || strcmp(session_folders(i_session).name,'..'))
        continue
    end

    if(isempty(cell2mat(strfind(in, session_folders(i_session).name))))
        continue
    end

    % Obtain xml filename
    session_folder = session_folders(i_session).name;   % folder that contain the nsig signals
    currdir = cd([data_path '\' session_folder]);
    mat_dir = dir('*');
    mat_dir = mat_dir(end);
    mat_filenames = dir([data_path '\' session_folder '\' mat_dir.name '\*.mat']);
    nsigs = length(mat_filenames);
    cd(currdir);

    % Initialize features and classes' tables
    Feat_trn = [];
    Feat_tst = [];
    Class_trn = [];
    Class_tst = [];

    % Cycle on the signals
    % keyboard
    for isig = 1:nsigs
        %Load the information about the cycles and the estimated envelopes
        load([data_path '\' session_folder '\' mat_dir.name '\' mat_filenames(isig).name]);
        % Extract movement label
        label = get_movement_label(sig_comment);
        disp(['feature extraction for signal ' mat_filenames(isig).name])
     
        %%%%%%%%%%%%%%%%%%%%%%%%%
        % Iterate on the movement cycles and channels
        n_cycs = size(Cycles_norm_in_time.joint_angle,1);

        n_trn = round((2*n_cycs)/3);
        
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
            % Construction Training set and Test Set
            if i_cyc <= n_trn
                Feat_trn = [Feat_trn; feat_vals];
                Class_trn = [Class_trn; label];
            else
                Feat_tst = [Feat_tst; feat_vals];
                Class_tst = [Class_tst; label];
            end
        end
    end
    Class_trn = categorical(Class_trn);
    Class_tst = categorical(Class_tst);

    % ==============================
    % Training a KNN classifier
    % ==============================
    disp('Start kNN training')
    % Trying different #neighbors ancd choose the one
    % with the best performance on cross-validation (lowest kLoss)

    i_model = 0;
    var_names = {'Neighbors', 'MisClass_trn', 'kLoss'};
    var_types = {'double', 'double', 'double'};
    Results = table('Size',[0,3],'VariableTypes',var_types,...
        'VariableNames',var_names);
    Models = {};

    for i_neigh = 3:2:15 % 1 is not tested, almost certain overfitting
        knnModel = fitcknn(Feat_trn,Class_trn,"NumNeighbors",i_neigh,...
            "Distance","cityblock","Standardize",true,"DistanceWeight","equal");
    
        % Cross-validation
        CVMdl = crossval(knnModel,'Kfold',5);
        kloss = kfoldLoss(CVMdl);
    
        % Error on training data
        pred = predict(knnModel,Feat_trn);
        score_trn = sum((pred ~= Class_trn))/height(Class_trn)*100;
        text = ['Error Rate on TRAINING set = ',num2str(score_trn),' %'];
        disp(text);
        text = ['Cross Validation score (kLoss) = ',num2str(kloss)];
        disp(text)
        
        i_model = i_model+1;
        Models{i_model,1} = knnModel;

        Results.Neighbors(i_model) = i_neigh;
        Results.MisClass_trn(i_model) = score_trn;
        Results.kLoss(i_model) = kloss*100;
    end

    % Saving the models
        save('KNN_Models.mat','Models');
        save('KNN_Performance.mat','Results');
end
end
clc
clearvars

channels = [4,1; 4,5; 4,9; 4,13];
shifted_ch = [4,3; 4,7; 4,11; 4,14];

% KNN model training
[Feat_trn,Class_trn,Feat_test,Class_test] =...
    main_training('LSD', 'ext_flex_cycles', 5, 0, channels);

% ----------------- ELECTRODES IN PLACE ------------------- %
% Prediction on TEST set
load('KNN_Models.mat','Models')
load('KNN_Performance.mat','Results')

Val = table('Size',[0 1],'VariableTypes',{'double'},...
    'VariableNames',{'MisClass_test'});
best = 100; % Worst possible score (100% misclassified)

for i_models = 1:size(Models,1)
    predVal = predict(Models{i_models}, Feat_test);
    score = sum((predVal ~= Class_test))/height(Class_test)*100;
    text = ['Error Rate on TEST set = ',num2str(score),' %'];
    disp(text);

    Val.MisClass_test(i_models) = score;

    if score < best
        bestPred = predVal;
    end
end
Results = [Results, Val];

% Result analysis and plot
    % Saving best model
    [~,idx] = max(Results.MisClass_test);
    bestModel = Models{idx};
    save('KNN_Best_Model.mat',"bestModel")
    % 
    figure
    N = [3, 5, 7, 9, 11, 13, 15];
    bar(N, Results{:,2:end});
    legend({'TRAINING set','Cross validation','TEST set'},...
        'Location','northwest');
    xlabel('Number of Neighbors');
    ylabel('Error Rate (%)')

    % Confusion matrix (for the best model)
    CM = confusionmat(Class_test,bestPred); % known, predicted
    figure
    label = {'Index EXT', 'Index FLEX', 'Little EXT', 'Little FLEX', 'Wrist ABD',...
        'Wrist ADD', 'Wrist EXT', 'Wrist FLEX', 'Middle EXT', 'Middle FLEX',...
        'Ring EXT', 'Ring FLEX'};
    confusionchart(CM, label);

% ----------------- SHIFTED ELECTRODE ------------------- %
main_classify(shifted_ch, 'LSD', 'ext_flex_cycles', 5, 0);
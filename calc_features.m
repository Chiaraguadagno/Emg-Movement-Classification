% --------------------------------------------------- %
% Function to extract the features from the dataset
% INPUT
%      data: struct which contains the emg and envelope signals
%            (Cycles_norm_in_time)
%      channel: list of channels to extract features from
%                   Nx2 matrix
%                   N channels
%                   first column --> channel's row
%                   second column --> channel's column
%      rep: repetition in exam, corresponds to a row in the emg/envelope
%           channel
% --------------------------------------------------- %

function [feat_tot] = calc_features(data,channel,rep)
    var_names = {'env_mean','env_rms','env_vmax','cyc_perc_to_peak','env_integral',...
       'env_std','slope_dyn'};
    var_types = {'double','double','double','double','double','double','double'};
    feat = table('Size',[1,7],'VariableTypes',var_types...
        ,'VariableNames',var_names);
    
    % ESTENSIONE (SOLO ISOMETRICA)
    % env_mean
    feat.env_mean = mean(data.env{channel(1),channel(2)}(rep,151:550));
    % env_rms
    feat.env_rms = rms(data.env{channel(1),channel(2)}(rep,151:550));
    % env_vpp
    [feat.env_vmax,idx] = max(data.env{channel(1),channel(2)}(rep,151:550));
    % time to peak in percentage
    feat.cyc_perc_to_peak = round((idx/...
        length(data.env{channel(1),channel(2)}(rep,151:550)))*100);
    % env_integral
    feat.env_integral = trapz(data.env{channel(1),channel(2)}(rep,151:550));
    % env_std
    feat.env_std = std(data.env{channel(1),channel(2)}(rep,151:550));
    % slope dyn
    x = linspace(1,150,150);
    p_ext = polyfit(x,data.env{channel(1),channel(2)}(rep,1:150),1);
    feat.slope_dyn = p_ext(1);

    feat_tot = feat;

    % FLESSIONE (SOLO ISOMETRICA)
    % env_mean
    feat.env_mean = mean(data.env{channel(1),channel(2)}(rep,701:1100));
    % env_rms
    feat.env_rms = rms(data.env{channel(1),channel(2)}(rep,701:1100));
    % env_vpp
    [feat.env_vmax,idx] = max(data.env{channel(1),channel(2)}(rep,701:1100));
    % time to peak in percentage
    feat.cyc_perc_to_peak = round((idx/...
        length(data.env{channel(1),channel(2)}(rep,701:1100)))*100);
    % env_integral
    feat.env_integral = trapz(data.env{channel(1),channel(2)}(rep,701:1100));
    % env_std
    feat.env_std = std(data.env{channel(1),channel(2)}(rep,701:1100));
    % slope dyn
    p_flex = polyfit(x,data.env{channel(1),channel(2)}(rep,551:700),1);
    feat.slope_dyn = p_flex(1);

    feat_tot = [feat_tot; feat];
end
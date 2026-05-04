%function to calc the EMG envelope for all movement cycles
%
%Input:
%    sp_filt: specify the spatial filter
%               MONO:   monopolar
%               LSD:    longitudinal spatial filter
%               TSD:    transversal spatial filter
%               LP:     laplacian
%    flag_cycles: specify the extraction of specific cycles
%               ext_flex_cycles: extract flexo-extension cycle
%    f_cut:  cutoff frequency for envelope estimation
%    f_debug= flag that enable degug mode
%
% Example
% main_analysis('LSD', 'ext_flex_cycles', 5, 0);

%Output:
%   none%
%
%author: Marco Gazzoni
%date: 20251130
%Last update:

function main_analysis(sp_filt, flag_cycles, fcut, f_debug)

close all

global util_path
global result_path

%Specify the path for the protocol
currdir= cd('.\input\');
define_params
load params
cd(currdir);

currdir = cd([data_path '\']);
%specify the session
%obtain the sessions in the pilot
session_folders= dir();
cd(currdir);

n_sessions= length(session_folders);

currdir= cd('.\utilities\uipickfiles');
in = uipickfiles('FilterSpec', [signal_path '\' emg_path '\']);
cd(currdir)

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
    for isig= 1:nsigs
        %Load the information about the cycles and the estimated envelopes
        load([data_path '\' session_folder '\' mat_dir.name '\' mat_filenames(isig).name]);      
        disp(['signal: ' mat_filenames(isig).name]);
        %%%%%%%%%%%%%% PLOT
        figure
        screen_size = get(0, 'ScreenSize');
        set(gcf, 'Position', [0 0 screen_size(3) screen_size(4) ] )
        colors = ['b'; 'r'; 'g'; 'k'; 'm'];

        %%%%%%%%%%%%%%%%%% plot the envelopes estimated for all movement cycles
        for i_plot=1
            if(i_plot==1)
                var_to_plot= 'env';
            else
                var_to_plot= 'emg';
            end

            screen_size = get(0, 'ScreenSize');
            set(gcf, 'Position', [0 0 screen_size(3) screen_size(4) ] )
            [n_rows,n_cols]=size(Cycles_norm_in_time.(var_to_plot));
            n_cycs= size(Cycles_norm_in_time.(var_to_plot){1, 1},1);
            for i_col= 1:n_cols
                for i_row=1:n_rows
                    subplot(n_rows+1, n_cols, (i_row-1)*n_cols+i_col);
                    hold off
                    try
                        if(i_plot==1)
                        plot((Cycles_norm_in_time.(var_to_plot){i_row, i_col}(1:end,:))'/Cycles_norm_in_time.([var_to_plot '_vpp']));
                        else
                         plot((Cycles_norm_in_time.(var_to_plot){i_row, i_col})'/Cycles_norm_in_time.([var_to_plot '_vpp']));
                        end
                    catch
                        keyboard
                    end
                    if(i_plot==1)
                        ylim([-1.1 1.1])
                    else
                        ylim([-0.10 1.1])
                    end
                    set(gca, 'XLabel', []);
                    set(gca, 'YLabel', []);  set(gca, 'XTickLabel', []);  set(gca, 'YTickLabel', []);
                    if(i_row==1 && i_col==ceil(n_cols/2-1))
                        title([mat_filenames(isig).name ':   ' sig_comment '  ' sp_filt])
                    end
                end
                subplot(n_rows+1, n_cols, (n_rows)*n_cols+i_col);
                plot(Cycles_norm_in_time.joint_angle');
                xlabel('samples');  set(gca, 'YTickLabel', []);
                if(i_col==1)
                    ylabel('joint angle');
                end
            end
        end
        pause(0.5)
    end
end



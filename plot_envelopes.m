function plot_envelopes(Cycles_norm_in_time, bad_ch_tab, title_str)

close all
figure(1)
screen_size = get(0, 'ScreenSize');
set(gcf, 'Position', [0 0 screen_size(3) screen_size(4) ] )
colors=['b'; 'r'; 'g'; 'k'; 'm'];
%plot the raw EMG corresponding to the movement cycle identified in
%c


%%%%%%%%%%%%%%%%%% plot the envelopes estimated for all movement cycles
for i_plot=2
    if(i_plot==1)
        var_to_plot= 'emg'
    else
        var_to_plot= 'env'
    end

    figure(i_plot+1)
    screen_size = get(0, 'ScreenSize');
    set(gcf, 'Position', [0 0 screen_size(3) screen_size(4) ] )
    [n_rows,n_cols]=size(Cycles_norm_in_time.(var_to_plot));

    for i_col= 1:n_cols
        for i_row=1:n_rows
            if(bad_ch_tab(i_row, i_col)==1)
                continue
            end
            subplot(n_rows+1, n_cols, (i_row-1)*n_cols+i_col);
            hold off
            try
                plot((Cycles_norm_in_time.(var_to_plot){i_row, i_col})'/Cycles_norm_in_time.([var_to_plot '_vpp']));
            catch
                keyboard
            end
            if(i_plot==1)
                ylim([-1.1 1.1])
            else
                ylim([-0.10 1.5])
            end
            set(gca, 'XLabel', []);
            set(gca, 'YLabel', []);  set(gca, 'XTickLabel', []);  set(gca, 'YTickLabel', []);
            if(i_row==1 && i_col==ceil(n_cols/2-1))
                title(title_str)
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

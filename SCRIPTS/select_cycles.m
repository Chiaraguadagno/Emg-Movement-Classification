%function [cycles, Cycles_norm_in_time]= select_cycles(cycles, Cycles_norm_in_time)
%% select the cycles
function [cycles, Cycles_norm_in_time]= select_cycles(cycles, Cycles_norm_in_time)
        n_cycs= length(cycles.i_end_iso_ext);
        n_cycs= round(0.7*n_cycs);
        cycles.i_end_iso_ext= cycles.i_end_iso_ext(1:n_cycs);
		cycles.i_start_iso_flex= cycles.i_start_iso_flex(1:n_cycs);
		cycles.i_end_iso_flex= cycles.i_end_iso_flex(1:n_cycs);
        cycles.i_start_iso_ext= cycles.i_start_iso_ext(1:n_cycs);
        Cycles_norm_in_time.joint_angle= Cycles_norm_in_time.joint_angle(1:n_cycs,:);
        Cycles_norm_in_time.ja_mean= mean(Cycles_norm_in_time.joint_angle);
        Cycles_norm_in_time.ja_std= std(Cycles_norm_in_time.joint_angle);
        [n_rows n_cols]= size(Cycles_norm_in_time.env)
        for i_r=1:n_rows
            for i_c=1:n_cols
                Cycles_norm_in_time.emg_env{i_r,i_c}= Cycles_norm_in_time.env{i_r,i_c}(1:n_cycs,:);
                Cycles_norm_in_time.emg_mean= mean(Cycles_norm_in_time.env{i_r,i_c});
                Cycles_norm_in_time.emg_std= std(Cycles_norm_in_time.env{i_r,i_c});
            end
        end
end


function label= get_movement_label(sig_comment)

tokens = regexp(sig_comment,...
    'segment:\s*(\w+).*joint:\s*(\w+).*movement:\s*(\w+).*_\s*(\w+)', 'tokens');

if ~isempty(tokens)
    segment= tokens{1}{1};
    joint_label = tokens{1}{2};
    if strcmp(tokens{1}{3}, "flex")
        movement_label = tokens{1}{4}; 
        label1 = [segment '_' joint_label '_' movement_label];
        movement_label = tokens{1}{3};
        label2 = [segment '_' joint_label '_' movement_label];
        label = {label1; label2};
    else
        movement_label = tokens{1}{3}; 
        label1 = [segment '_' joint_label '_' movement_label];
        movement_label = tokens{1}{4};
        label2 = [segment '_' joint_label '_' movement_label];
        label = {label1; label2};
    end
else
    label = 'unknown';
end
end

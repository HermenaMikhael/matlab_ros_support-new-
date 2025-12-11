function grip_result = place(strategy, label, optns)
    %----------------------------------------------------------------------
    % place - Smart bin placement based on object classification
    %
    % Blue Bin: bottles, markers, blue cubes, red cubes
    % Green Bin: cans, spam, green cubes, purple cubes
    %
    % Inputs:
    %   strategy - 'topdown' or 'direct'
    %   label    - Object label (string or char)
    %   optns    - Options dictionary
    %
    % Outputs:
    %   grip_result - Error code (0 = success)
    %----------------------------------------------------------------------
   
    % Bin configurations [x, y, z, roll, pitch, yaw]
    % These are joint configurations, not Cartesian poses
    greenBinConfig = [2.2, 0, pi/2, -pi/2, 0, 0];      % Left side
    blueBinConfig = [-2.2, 0, pi/2, -pi/2, 0, 0];      % Right side
   
    % Convert label to string for comparison
    labelStr = string(label);
   
    %% 1) Determine which bin based on object type
    % Blue Bin Objects: bottles, markers, blue/red pouches
    if contains(labelStr, ["bottle", "Bottle", "marker", "pouchB", "pouchR"])
        fprintf('Placing %s in BLUE bin...\n', labelStr);
        binConfig = blueBinConfig;
        binName = 'BLUE';
   
    % Green Bin Objects: cans, spam, green/purple pouches
    elseif contains(labelStr, ["can", "Can", "spam", "pouchG", "pouchP"])
        fprintf('Placing %s in GREEN bin...\n', labelStr);
        binConfig = greenBinConfig;
        binName = 'GREEN';
   
    % Default to green bin if uncertain
    else
        warning('Unknown object type: %s. Defaulting to GREEN bin.', labelStr);
        binConfig = greenBinConfig;
        binName = 'GREEN (default)';
    end
   
    %% 2) Execute placement strategy
    if strcmp(strategy, 'topdown')
        % Move to bin configuration
        fprintf('Moving to %s bin...\n', binName);
        result = moveToQ("Custom", optns, binConfig);
       
        if result ~= 0
            warning('Failed to reach bin position');
            grip_result = result;
            return;
        end
       
        % Small delay before releasing
        pause(1);
       
        % Release gripper
        fprintf('Releasing %s into %s bin...\n', labelStr, binName);
        [grip_result, ~] = doGrip('place', optns);
        grip_result = grip_result.ErrorCode;
       
        % Delay after release
        pause(2);
       
        if grip_result == 0
            fprintf('Successfully placed %s in %s bin\n', labelStr, binName);
        else
            warning('Place operation may have failed');
        end
       
    elseif strcmpi(strategy, 'direct')
        % Direct strategy (less common)
        result = moveToQ("Custom", optns, binConfig);
        if result == 0
            [grip_result, ~] = doGrip('place', optns);
            grip_result = grip_result.ErrorCode;
        else
            grip_result = result;
        end
    end
end
end

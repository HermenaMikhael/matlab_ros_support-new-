function grip_result = pick(strategy, objectData, optns)
    %----------------------------------------------------------------------
    % pick - Enhanced version with support for all object types
    %
    % Handles: bottles (v/h), cans (v/h), markers, spam, pouches
    %
    % Inputs:
    %   strategy    - 'topdown' or 'direct'
    %   objectData  - Either 4x4 matrix or cell array {label, pose, ptCloud}
    %   optns       - Options dictionary
    %
    % Outputs:
    %   grip_result - Error code (0 = success)
    %----------------------------------------------------------------------
     
    % Extract label and pose from objectData
    if isequal(size(objectData), [4, 4]) && isnumeric(objectData)
        mat_R_T_M = objectData;
        label = "can";  % default
    else
        label = objectData(1,1);
        label = label{1};
        mat_R_T_M = objectData(1,2);
        mat_R_T_M = mat_R_T_M{1};
    end

    %% 1) Determine z offset and grip distance based on object type
    switch string(label)
        % Vertical Bottles
        case "vBottle"
            zOffset = 0.12;
            doGripValue = 0.36;
            hoverHeight = 0.25;
       
        % Horizontal Bottles (lying down)
        case "hBottle"
            zOffset = 0.08;
            doGripValue = 0.21;
            hoverHeight = 0.20;
       
        % Vertical Cans
        case {"vCan", "can"}
            zOffset = 0.18;
            doGripValue = 0.24;
            hoverHeight = 0.25;
       
        % Horizontal Cans
        case "hCan"
            zOffset = 0.10;
            doGripValue = 0.24;
            hoverHeight = 0.20;
       
        % Markers
        case "marker"
            zOffset = 0.12;
            doGripValue = 0.30;
            hoverHeight = 0.22;
       
        % Spam
        case "spam"
            zOffset = 0.15;
            doGripValue = 0.35;
            hoverHeight = 0.25;
       
        % Pouches
        case {"pouch", "pouchR", "pouchG", "pouchB", "pouchP"}
            zOffset = 0.145;
            doGripValue = 0.62;
            hoverHeight = 0.25;
       
        % Bottle
        case "bottle"
            zOffset = 0.12;
            doGripValue = 0.36;
            hoverHeight = 0.25;
       
        % Default
        otherwise
            zOffset = 0.15;
            doGripValue = 0.30;
            hoverHeight = 0.25;
    end

    %% 2) Execute pick strategy
    if strcmp(strategy, 'topdown')
        % Step 1: Move to high hover position
        fprintf('Hovering %.2fm above %s...\n', hoverHeight, label);
        over_R_T_M_high = lift(mat_R_T_M, zOffset + hoverHeight);
        result1 = moveTo(over_R_T_M_high, optns);
       
        if result1 ~= 0
            warning('Failed to reach high hover position');
            grip_result = result1;
            return;
        end
       
        % Step 2: Move to final pick position
        fprintf('Descending to pick %s...\n', label);
        over_R_T_M = lift(mat_R_T_M, zOffset);
        result2 = moveTo(over_R_T_M, optns);
       
        if result2 ~= 0
            warning('Failed to reach pick position');
            grip_result = result2;
            return;
        end
       
        % Step 3: Close gripper
        pause(1);
       
    elseif strcmpi(strategy, 'direct')
        result = moveTo(mat_R_T_M, optns);
        if result ~= 0
            grip_result = result;
            return;
        end
    end
   
    %% 3) Execute grip
    fprintf('Gripping %s with value %.2f...\n', label, doGripValue);
    [grip_result, ~] = doGrip('pick', optns, doGripValue);
    grip_result = grip_result.ErrorCode;
   
    % Add delay for grip to stabilize
    pause(2);
   
    % Verify grip (optional - could check gripper feedback)
    if grip_result == 0
        fprintf('Successfully picked %s\n', label);
    else
        warning('Grip may have failed for %s', label);
    end
end
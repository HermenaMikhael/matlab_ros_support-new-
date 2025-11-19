function resetWorld(optns)
%-------------------------------------------------------------------------- 
% resetWorld()
% Calls Gazebo service to reset the world
% Input: (dict) optns
% Output: None
%-------------------------------------------------------------------------- 
    disp('Resetting the world...');
    
    % TODO: 01 Get robot handle
    r = optns("rHandle");
    
    % TODO: 02 Create Empty Simulation message
    reset_client = rossvcclient("/gazebo/reset_simulation", ...
                                "std_srvs/Empty", ...
                                "DataFormat", "struct");
    reset_msg = rosmessage(reset_client);
    
    % TODO: 03 Call reset service
     call(reset_client, reset_msg);
end
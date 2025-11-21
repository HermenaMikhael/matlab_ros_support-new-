function traj_goal = convert2ROSPointVec(mat_joint_traj, robot_joint_names, traj_steps, traj_duration, traj_goal, optns)
%--------------------------------------------------------------------------
% convert2ROSPointVec
% Converts all of the matlab joint trajectory values into a vector of ROS
% Trajectory Points. 
% 
% Make sure all messages have the same DataFormat (i.e. struct)
%
% Inputs:
% mat_joint_traj (n x q) - matrix of n trajectory points for q joint values
% robot_joint_names {} - cell of robot joint names
% traj_goal (FollowJointTrajectoryGoal)
% optns (dict) - traj_duration, traj_steps, ros class handle
%
% Outputs
% vector of TrajectoryPoints (1 x n)
%--------------------------------------------------------------------------
    
    % Get robot handle. Will work with r.point
    r = optns{'rHandle'};

    % Compute time step as duration over steps
    timeStep = traj_duration / traj_steps;
    
    % TODO: Set joint names. Note: must remove finger at index 2
    traj_goal.Trajectory.JointNames = robot_joint_names; 
    traj_goal.Trajectory.JointNames(2) = []; %Complete code here%
  
    %% Set Points

    % Set an array of cells (currently only using 1 pt but can be extended)
    points = cell(1,traj_steps);

    % TODO: Create Point Message
    %Complete code here%
    r.point

    % TODO: Fill r.point: extract each waypoint and set it as a 6x1 (use transpose)
    %Complete code here%    
    for i = 1:traj_steps
    
    qi = mat_joint_traj(i,:);
    r.point.TimeFromStart = rosduration(i * timeStep, DataFormat="struct");
    r.point.Positions= mat2rosJoints(qi)';
     
    % TODO: Set inside points cell
    %Complete code here%
    points{i} = r.point.Positions;
    end
    % TODO: Copy points to traj_goal.Trajectory.Points
    %Complete code here%
    traj_goal.Trajectory.Points =  r.point;
    
end
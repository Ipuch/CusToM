function [Human_model]= Scapula_Shoulder(Human_model,k,Mass,Side,AttachmentPoint)
% Addition of a thorax model
%   INPUT
%   - Human_model: osteo-articular model of an already existing
%   model (see the Documentation for the structure)
%   - k: homothety coefficient for the geometrical parameters (defined as
%   the subject size in cm divided by 180)
%   - Mass: mass of the solids
%   - AttachmentPoint: name of the attachment point of the model on the
%   already existing model (character string)
%   OUTPUT
%   - Human_model: new osteo-articular model (see the Documentation
%   for the structure) 
%________________________________________________________
%
% Licence
% Toolbox distributed under GPL 3.0 Licence
%________________________________________________________
%
% Authors : Antoine Muller, Charles Pontonnier, Pierre Puchaud and
% Georges Dumont
%________________________________________________________
%% Solid list

list_solid={'ScapuloThoracic_J1' 'ScapuloThoracic_J2' 'ScapuloThoracic_J3' 'ScapuloThoracic_J4' 'ScapuloThoracic_J5' 'Scapula' 'ThoracicEllips_J1' 'ThoracicEllips_J2' 'AcromioClavicular_J1' 'AcromioClavicular_J2' 'AcromioClavicular_J3'};

%% Choix jambe droite ou gauche
if Side == 'R'
    Mirror=[1 0 0; 0 1 0; 0 0 1];
    Sign=1;
    Cote='D';
    FullSide='Right';
else
    if Side == 'L'
        Mirror=[1 0 0; 0 1 0; 0 0 -1];
        Sign=-1;
        Cote='G';
        FullSide='Left';
    end
end

%% Solid numbering incremation

s=size(Human_model,2)+1;  %#ok<NASGU> % num�ro du premier solide
for i=1:size(list_solid,2)      % num�rotation de chaque solide : s_"nom du solide"
    if i==1
        eval(strcat('s_',list_solid{i},'=s;'))
    else
        eval(strcat('s_',list_solid{i},'=s_',list_solid{i-1},'+1;'))
    end
end

% find the number of the mother from the attachment point: 'attachment_pt'
if numel(Human_model) == 0
    s_mother=0;
    pos_attachment_pt=[0 0 0]';
else
    test=0;
    for i=1:numel(Human_model)
        for j=1:size(Human_model(i).anat_position,1)
            if strcmp(AttachmentPoint,Human_model(i).anat_position{j,1})
                s_mother=i;
                pos_attachment_pt=Human_model(i).anat_position{j,2}+Human_model(s_mother).c;
                test=1;
                break
            end
        end
        if i==numel(Human_model) && test==0
            error([AttachmentPoint ' is no existent'])
        end
    end
    if Human_model(s_mother).child == 0      % si la m�re n'a pas d'enfant
        Human_model(s_mother).child = eval(['s_' list_solid{1}]);    % l'enfant de cette m�re est ce solide
    else
        [Human_model]=sister_actualize(Human_model,Human_model(s_mother).child,eval(['s_' list_solid{1}]));   % recherche de la derni�re soeur
    end
end
%%                     Definition of anatomical landmarks

% Centre of motion location in OpenSim frame
Scapula_CoM = k*Mirror*[-0.054694 -0.035032 -0.043734]';
% landmarks location in CusToM frame
Scapula_acJointNode = k*Mirror*[-0.01357; 0.00011; -0.01523] - Scapula_CoM;
Scapula_ghJointNode = k*Mirror*[-0.00955; -0.034; 0.009] - Scapula_CoM;
Scapula_stJointNode = k*Mirror*[-0.05982; -0.03904; -0.056] - Scapula_CoM;
Scapula_acromion = k*Mirror*[-0.0142761 0.0131922 -0.00563961]' - Scapula_CoM;

%% Definition of anatomical landmarks (with respect to the center of mass of the solid)

Scapula_position_set = {...
    % Joint Nodes
    [Side '_Scapula_acJointNode'], Scapula_acJointNode;...
    ['Thorax_Shoulder' FullSide 'Node'], Scapula_ghJointNode;...
    % Markers
    [Side 'SHO'], Scapula_acromion;...
    ['AC' Cote], Scapula_acromion;
    % Muscle paths
    [Side '_scapula_DELT1_r-P3'],k*Mirror*([0.04347;-0.03252;0.00099])-Scapula_CoM;...
    [Side '_scapula_DELT2_r-P3'],k*Mirror*([5e-05;0.00294;0.02233])-Scapula_CoM;...
    [Side '_scapula_DELT2_r-P4'],k*Mirror*([-0.01078;-0.00034;0.0062])-Scapula_CoM;...
    [Side '_scapula_DELT3_r-P1'],k*Mirror*([-0.05573;0.00122;-0.02512])-Scapula_CoM;...
    [Side '_scapula_DELT3_r-P2'],k*Mirror*([-0.07247;-0.03285;0.01233])-Scapula_CoM;...
    [Side '_scapula_SUPSP_r-P2'],k*Mirror*([-0.01918;0.00127;-0.01271])-Scapula_CoM;...
    [Side '_scapula_SUPSP_r-P3'],k*Mirror*([-0.044;-0.01512;-0.05855])-Scapula_CoM;...
    [Side '_scapula_INFSP_r-P2'],k*Mirror*([-0.07382;-0.05476;-0.04781])-Scapula_CoM;...
    [Side '_scapula_SUBSC_r-P2'],k*Mirror*([-0.01831;-0.05223;-0.02457])-Scapula_CoM;...
    [Side '_scapula_SUBSC_r-P3'],k*Mirror*([-0.07246;-0.03943;-0.06475])-Scapula_CoM;...
    [Side '_scapula_TMIN_r-P2'],k*Mirror*([-0.09473;-0.07991;-0.04737])-Scapula_CoM;...
    [Side '_scapula_TMIN_r-P3'],k*Mirror*([-0.09643;-0.08121;-0.05298])-Scapula_CoM;...
    [Side '_scapula_TMAJ_r-P2'],k*Mirror*([-0.10264;-0.10319;-0.05829])-Scapula_CoM;...
    [Side '_scapula_TMAJ_r-P3'],k*Mirror*([-0.10489;-0.10895;-0.07117])-Scapula_CoM;...
    [Side '_scapula_LAT1_r-P2'],k*Mirror*([-0.07982;-0.079943;-0.02428])-Scapula_CoM;...
    [Side '_scapula_LAT1_r-P3'],k*Mirror*([-0.11118;-0.089323;-0.06022])-Scapula_CoM;...
    [Side '_scapula_LAT2_r-P2'],k*Mirror*([-0.07875;-0.097117;-0.02023])-Scapula_CoM;...
    [Side '_scapula_LAT2_r-P3'],k*Mirror*([-0.10544;-0.12896;-0.064597])-Scapula_CoM;...
    [Side '_scapula_LAT3_r-P2'],k*Mirror*([-0.06598;-0.12735;-0.024183])-Scapula_CoM;...
    [Side '_scapula_LAT3_r-P3'],k*Mirror*([-0.10059;-0.16313;-0.059077])-Scapula_CoM;...
    [Side '_scapula_CORB_r-P1'],k*Mirror*([0.0125;-0.04127;-0.02652])-Scapula_CoM;...
    [Side '_scapula_CORB_r-P2'],k*Mirror*([0.00483;-0.06958;-0.01563])-Scapula_CoM;...
    [Side '_scapula_TRIlong_r-P1'],k*Mirror*([-0.04565;-0.04073;-0.01377])-Scapula_CoM;...
    [Side '_scapula_BIClong_r-P1'],k*Mirror*([-0.03123;-0.02353;-0.01305])-Scapula_CoM;...
    [Side '_scapula_BIClong_r-P2'],k*Mirror*([-0.02094;-0.01309;-0.00461])-Scapula_CoM;...
    [Side '_scapula_BICshort_r-P1'],k*Mirror*([0.01268;-0.03931;-0.02625])-Scapula_CoM;...
    [Side '_scapula_BICshort_r-P2'],k*Mirror*([0.00093;-0.06704;-0.01593])-Scapula_CoM;...
    [Side '_scapula_trap_acr_r-P1'],k*Mirror*([-0.02;0.0004;-0.0125])-Scapula_CoM;...
    [Side '_scapula_levator_scap_r-P1'],k*Mirror*([-0.069;0.0062;-0.0938])-Scapula_CoM;...
    [Side '_scapula_trap_acr_r-P1'],k*Mirror*([-0.02;0.0004;-0.0125])-Scapula_CoM;...
    [Side '_scapula_rhomboid_min_r-P2'],k*Mirror*([-0.0798;-0.009;-0.095])-Scapula_CoM;...
    [Side '_scapula_rhomboid_maj_r-P2'],k*Mirror*([-0.1052;-0.085;-0.095])-Scapula_CoM;...
    [Side '_scapula_serr_ant_1_r-P1'],k*Mirror*([-0.1;-0.1061;-0.0852])-Scapula_CoM;...
    [Side '_scapula_serr_ant_2_r-P1'],k*Mirror*([-0.1;-0.1059;-0.0839])-Scapula_CoM;...
    [Side '_scapula_serr_ant_3_r-P1'],k*Mirror*([-0.1;-0.1038;-0.0808])-Scapula_CoM;...
    [Side '_scapula_serr_ant_4_r-P1'],k*Mirror*([-0.098;-0.1005;-0.0795])-Scapula_CoM;...
    [Side '_scapula_serr_ant_5_r-P1'],k*Mirror*([-0.088;-0.065;-0.0805])-Scapula_CoM;...
    [Side '_scapula_serr_ant_6_r-P1'],k*Mirror*([-0.08;-0.05;-0.079])-Scapula_CoM;...
    [Side '_scapula_serr_ant_7_r-P1'],k*Mirror*([-0.074;-0.03;-0.085])-Scapula_CoM;...
    [Side '_scapula_serr_ant_8_r-P1'],k*Mirror*([-0.076;-0.0295;-0.0891])-Scapula_CoM;...
    [Side '_scapula_serr_ant_9_r-P1'],k*Mirror*([-0.07;-0.0074;-0.0927])-Scapula_CoM;...
    [Side '_scapula_serr_ant10_r-P1'],k*Mirror*([-0.0594;0.0017;-0.0897])-Scapula_CoM;...
    [Side '_scapula_serr_ant11_r-P1'],k*Mirror*([-0.0513;0.0068;-0.0877])-Scapula_CoM;...
    [Side '_scapula_serr_ant12_r-P1'],k*Mirror*([-0.036;0;-0.082])-Scapula_CoM;...
    };
    

%%                     Scaling inertial parameters

Scapula_Mass_generic=0.70396;
I_scapula_generic=[0.0012429 0.0011504 0.0013651 0.0004494 Sign*0.00040922 Sign*0.0002411];
I_scapula=(k^2*Mass.Scapula_Mass/Scapula_Mass_generic)*I_scapula_generic;
Thorax_Rx=0.07;
Thorax_Ry=0.15;
Thorax_Rz=0.07;

%% "Human_model" structure generation
 
num_solid=0;
%% Scapulo-thoracic joint

% ScapuloThoracic_J1
num_solid=num_solid+1;                                      % solid number
name=list_solid{num_solid};                                 % solid name
eval(['incr_solid=s_' name ';'])                            % solid number in model tree
Human_model(incr_solid).name=[Side name];          % solid name with side
Human_model(incr_solid).sister=0;                   % Solid's sister
Human_model(incr_solid).child=s_ScapuloThoracic_J2;         % Solid's child
Human_model(incr_solid).mother=s_mother;            % Solid's mother
Human_model(incr_solid).a=[1 0 0]';                          
Human_model(incr_solid).joint=2;
Human_model(incr_solid).limit_inf=-Inf;
Human_model(incr_solid).limit_sup=Inf;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).m=0;                        % Reference mass
Human_model(incr_solid).b=pos_attachment_pt;        % Attachment point position in mother's frame
Human_model(incr_solid).I=zeros(3,3);               % Reference inertia matrix
Human_model(incr_solid).c=[0 0 0]';                 % Centre of mass position in local frame
Human_model(incr_solid).calib_k_constraint=[];
Human_model(incr_solid).u=[];                       % fixed rotation with respect to u axis of theta angle
Human_model(incr_solid).theta=[];
Human_model(incr_solid).KinematicsCut=[];           % kinematic cut
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;
% Dependancy
Human_model(incr_solid).kinematic_dependancy.active=1;
Human_model(incr_solid).kinematic_dependancy.Joint=[incr_solid+7]; % Thoracicellips
% Kinematic dependancy function
syms phi lambda % latitude longitude
f_tx = matlabFunction(Thorax_Rx*sin(lambda));
Human_model(incr_solid).kinematic_dependancy.q=f_tx;

% ScapuloThoracic_J2
num_solid=num_solid+1;                                      % solid number
name=list_solid{num_solid};                                 % solid name
eval(['incr_solid=s_' name ';'])                            % solid number in model tree
Human_model(incr_solid).name=[Side name];          % solid name with side
Human_model(incr_solid).sister=0;                   % Solid's sister
Human_model(incr_solid).child=s_ScapuloThoracic_J3;         % Solid's child
Human_model(incr_solid).mother=s_ScapuloThoracic_J1;            % Solid's mother
Human_model(incr_solid).a=[0 1 0]';                          
Human_model(incr_solid).joint=2;
Human_model(incr_solid).limit_inf=-Inf;
Human_model(incr_solid).limit_sup=Inf;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).m=0;                        % Reference mass
Human_model(incr_solid).b=[0 0 0]';        % Attachment point position in mother's frame
Human_model(incr_solid).I=zeros(3,3);               % Reference inertia matrix
Human_model(incr_solid).c=[0 0 0]';                 % Centre of mass position in local frame
Human_model(incr_solid).calib_k_constraint=[];
Human_model(incr_solid).u=[];                       % fixed rotation with respect to u axis of theta angle
Human_model(incr_solid).theta=[];
Human_model(incr_solid).KinematicsCut=[];           % kinematic cut
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;
% Dependancy
Human_model(incr_solid).kinematic_dependancy.active=1;
Human_model(incr_solid).kinematic_dependancy.Joint=[incr_solid+5; incr_solid+6]; % Thoracicellips
% Kinematic dependancy function
f_ty = matlabFunction(-Thorax_Ry*sin(phi)*cos(lambda),'vars',{phi,lambda});
Human_model(incr_solid).kinematic_dependancy.q=f_ty;

% ScapuloThoracic_J3
num_solid=num_solid+1;                                      % solid number
name=list_solid{num_solid};                                 % solid name
eval(['incr_solid=s_' name ';'])                            % solid number in model tree
Human_model(incr_solid).name=[Side name];          % solid name with side
Human_model(incr_solid).sister=s_ThoracicEllips_J1;                   % Solid's sister
Human_model(incr_solid).child=s_ScapuloThoracic_J4;         % Solid's child
Human_model(incr_solid).mother=s_ScapuloThoracic_J2;            % Solid's mother
Human_model(incr_solid).a=[0 0 1]';                          
Human_model(incr_solid).joint=2;
Human_model(incr_solid).limit_inf=-Inf;
Human_model(incr_solid).limit_sup=Inf;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).m=0;                        % Reference mass
Human_model(incr_solid).b=[0 0 0]';        % Attachment point position in mother's frame
Human_model(incr_solid).I=zeros(3,3);               % Reference inertia matrix
Human_model(incr_solid).c=[0 0 0]';                 % Centre of mass position in local frame
Human_model(incr_solid).calib_k_constraint=[];
Human_model(incr_solid).u=[];                       % fixed rotation with respect to u axis of theta angle
Human_model(incr_solid).theta=[];
Human_model(incr_solid).KinematicsCut=[];           % kinematic cut
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;
% Dependancy
Human_model(incr_solid).kinematic_dependancy.active=1;
Human_model(incr_solid).kinematic_dependancy.Joint=[incr_solid+4; incr_solid+5]; % Thoracicellips
% Kinematic dependancy function
f_tz = matlabFunction(Thorax_Rz*cos(lambda)*cos(phi),'vars',{phi,lambda});
Human_model(incr_solid).kinematic_dependancy.q=f_tz;

% ScapuloThoracic_J4
num_solid=num_solid+1;                                      % solid number
name=list_solid{num_solid};                                 % solid name
eval(['incr_solid=s_' name ';'])                            % solid number in model tree
Human_model(incr_solid).name=[Side name];          % solid name with side
Human_model(incr_solid).sister=0;                   % Solid's sister
Human_model(incr_solid).child=s_ScapuloThoracic_J5;         % Solid's child
Human_model(incr_solid).mother=s_ScapuloThoracic_J3;            % Solid's mother
Human_model(incr_solid).a=[1 0 0]';                          
Human_model(incr_solid).joint=1;
Human_model(incr_solid).limit_inf=-pi;
Human_model(incr_solid).limit_sup=pi;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).m=0;                        % Reference mass
Human_model(incr_solid).b=[0 0 0]';        % Attachment point position in mother's frame
Human_model(incr_solid).I=zeros(3,3);               % Reference inertia matrix
Human_model(incr_solid).c=[0 0 0]';                 % Centre of mass position in local frame
Human_model(incr_solid).calib_k_constraint=[];
Human_model(incr_solid).u=[];                       % fixed rotation with respect to u axis of theta angle
Human_model(incr_solid).theta=[];
Human_model(incr_solid).KinematicsCut=[];           % kinematic cut
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;

% ScapuloThoracic_J5
num_solid=num_solid+1;                                      % solid number
name=list_solid{num_solid};                                 % solid name
eval(['incr_solid=s_' name ';'])                            % solid number in model tree
Human_model(incr_solid).name=[Side name];          % solid name with side
Human_model(incr_solid).sister=0;                   % Solid's sister
Human_model(incr_solid).child=s_Scapula;         % Solid's child
Human_model(incr_solid).mother=s_ScapuloThoracic_J4;            % Solid's mother
Human_model(incr_solid).a=[0 1 0]';                          
Human_model(incr_solid).joint=1;
Human_model(incr_solid).limit_inf=-pi;
Human_model(incr_solid).limit_sup=pi;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).m=0;                        % Reference mass
Human_model(incr_solid).b=[0 0 0]';        % Attachment point position in mother's frame
Human_model(incr_solid).I=zeros(3,3);               % Reference inertia matrix
Human_model(incr_solid).c=[0 0 0]';                 % Centre of mass position in local frame
Human_model(incr_solid).calib_k_constraint=[];
Human_model(incr_solid).u=[];                       % fixed rotation with respect to u axis of theta angle
Human_model(incr_solid).theta=[];
Human_model(incr_solid).KinematicsCut=[];           % kinematic cut
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;

% Scapula
num_solid=num_solid+1;                                      % solid number
name=list_solid{num_solid};                                 % solid name
eval(['incr_solid=s_' name ';'])                            % solid number in model tree
Human_model(incr_solid).name=[Side name];          % solid name with side
Human_model(incr_solid).sister=0;                   % Solid's sister
Human_model(incr_solid).child=s_AcromioClavicular_J1;         % Solid's child
Human_model(incr_solid).mother=s_ScapuloThoracic_J5;            % Solid's mother
Human_model(incr_solid).a=[0 0 1]';                          
Human_model(incr_solid).joint=1;
Human_model(incr_solid).limit_inf=-pi;
Human_model(incr_solid).limit_sup=pi;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).m=Mass.Scapula_Mass;                        % Reference mass
Human_model(incr_solid).b=[0 0 0]';        % Attachment point position in mother's frame
Human_model(incr_solid).I=I_scapula;               % Reference inertia matrix
Human_model(incr_solid).c=-Scapula_stJointNode;                 % Centre of mass position in local frame
Human_model(incr_solid).calib_k_constraint=s_mother;
Human_model(incr_solid).u=[];                       % fixed rotation with respect to u axis of theta angle
Human_model(incr_solid).theta=[];
Human_model(incr_solid).KinematicsCut=[];           % kinematic cut
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).anat_position=Scapula_position_set;
Human_model(incr_solid).Visual=1;
Human_model(incr_solid).Visual_file=['Holzbaur/scapula_' lower(Side) '.mat'];


% ThoracicEllips_J1
num_solid=num_solid+1;                                      % solid number
name=list_solid{num_solid};                                 % solid name
eval(['incr_solid=s_' name ';'])                            % solid number in model tree
Human_model(incr_solid).name=[Side name];          % solid name with side
Human_model(incr_solid).sister=s_ThoracicEllips_J2;                   % Solid's sister
Human_model(incr_solid).child=0;         % Solid's child
Human_model(incr_solid).mother=s_ScapuloThoracic_J3;            % Solid's mother
Human_model(incr_solid).a=[1 0 0]';                          
Human_model(incr_solid).joint=1;
Human_model(incr_solid).limit_inf=-pi;
Human_model(incr_solid).limit_sup=pi;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).m=0;                        % Reference mass
Human_model(incr_solid).b=[0 0 0]';        % Attachment point position in mother's frame
Human_model(incr_solid).I=zeros(3,3);               % Reference inertia matrix
Human_model(incr_solid).c=[0 0 0]';                 % Centre of mass position in local frame
Human_model(incr_solid).calib_k_constraint=[];
Human_model(incr_solid).u=[];                       % fixed rotation with respect to u axis of theta angle
Human_model(incr_solid).theta=[];
Human_model(incr_solid).KinematicsCut=[];           % kinematic cut
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;

% ThoracicEllips_J2
num_solid=num_solid+1;                                      % solid number
name=list_solid{num_solid};                                 % solid name
eval(['incr_solid=s_' name ';'])                            % solid number in model tree
Human_model(incr_solid).name=[Side name];          % solid name with side
Human_model(incr_solid).sister=0;                   % Solid's sister
Human_model(incr_solid).child=0;         % Solid's child
Human_model(incr_solid).mother=s_ScapuloThoracic_J3;            % Solid's mother
Human_model(incr_solid).a=[0 1 0]';                          
Human_model(incr_solid).joint=1;
Human_model(incr_solid).limit_inf=-pi;
Human_model(incr_solid).limit_sup=pi;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).m=0;                        % Reference mass
Human_model(incr_solid).b=[0 0 0]';        % Attachment point position in mother's frame
Human_model(incr_solid).I=zeros(3,3);               % Reference inertia matrix
Human_model(incr_solid).c=[0 0 0]';                 % Centre of mass position in local frame
Human_model(incr_solid).calib_k_constraint=[];
Human_model(incr_solid).u=[];                       % fixed rotation with respect to u axis of theta angle
Human_model(incr_solid).theta=[];
Human_model(incr_solid).KinematicsCut=[];           % kinematic cut
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;

%% AcromioClavicular Joint

% AcromioClavicular_J1
num_solid=num_solid+1;                                      % solid number
name=list_solid{num_solid};                                 % solid name
eval(['incr_solid=s_' name ';'])                            % solid number in model tree
Human_model(incr_solid).name=[Side name];          % solid name with side
Human_model(incr_solid).sister=0;                   % Solid's sister
Human_model(incr_solid).child=s_AcromioClavicular_J2;         % Solid's child
Human_model(incr_solid).mother=s_Scapula;            % Solid's mother
Human_model(incr_solid).a=[0 1 0]';                          
Human_model(incr_solid).joint=1;
Human_model(incr_solid).limit_inf=-pi;
Human_model(incr_solid).limit_sup=pi;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).m=0;                        % Reference mass
Human_model(incr_solid).b=Scapula_acJointNode;        % Attachment point position in mother's frame
Human_model(incr_solid).I=zeros(3,3);               % Reference inertia matrix
Human_model(incr_solid).c=[0 0 0]';                 % Centre of mass position in local frame
Human_model(incr_solid).calib_k_constraint=[];
Human_model(incr_solid).u=[];                       % fixed rotation with respect to u axis of theta angle
Human_model(incr_solid).theta=[];
Human_model(incr_solid).KinematicsCut=[];           % kinematic cut
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;

% AcromioClavicular_J2
num_solid=num_solid+1;                                      % solid number
name=list_solid{num_solid};                                 % solid name
eval(['incr_solid=s_' name ';'])                            % solid number in model tree
Human_model(incr_solid).name=[Side name];          % solid name with side
Human_model(incr_solid).sister=0;                   % Solid's sister
Human_model(incr_solid).child=s_AcromioClavicular_J3;            % Solid's child
Human_model(incr_solid).mother=s_AcromioClavicular_J1;            % Solid's mother
Human_model(incr_solid).a=[1 0 0]';                          
Human_model(incr_solid).joint=1;
Human_model(incr_solid).limit_inf=-pi;
Human_model(incr_solid).limit_sup=pi;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).m=0;                        % Reference mass
Human_model(incr_solid).b=[0 0 0]';        % Attachment point position in mother's frame
Human_model(incr_solid).I=zeros(3,3);               % Reference inertia matrix
Human_model(incr_solid).c=[0 0 0]';                 % Centre of mass position in local frame
Human_model(incr_solid).calib_k_constraint=[];
Human_model(incr_solid).u=[];                       % fixed rotation with respect to u axis of theta angle
Human_model(incr_solid).theta=[];
Human_model(incr_solid).KinematicsCut=[];           % kinematic cut
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;

% AcromioClavicular_J3
num_solid=num_solid+1;                                      % solid number
name=list_solid{num_solid};                                 % solid name
eval(['incr_solid=s_' name ';'])                            % solid number in model tree
Human_model(incr_solid).name=[Side name];          % solid name with side
Human_model(incr_solid).sister=0;                   % Solid's sister
Human_model(incr_solid).child=0;         % Solid's child
Human_model(incr_solid).mother=s_AcromioClavicular_J2;            % Solid's mother
Human_model(incr_solid).a=[0 1 0]';                          
Human_model(incr_solid).joint=1;
Human_model(incr_solid).limit_inf=-pi;
Human_model(incr_solid).limit_sup=pi;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).m=0;        % Reference mass
Human_model(incr_solid).b=[0 0 0]';        % Attachment point position in mother's frame
Human_model(incr_solid).I=zeros(3,3);               % Reference inertia matrix
Human_model(incr_solid).c=[0 0 0]';                 % Centre of mass position in local frame
Human_model(incr_solid).calib_k_constraint=[];
Human_model(incr_solid).u=[];                       % fixed rotation with respect to u axis of theta angle
Human_model(incr_solid).theta=[];
Human_model(incr_solid).KinematicsCut=[];           % kinematic cut
Human_model(incr_solid).ClosedLoop=[Side '_Clavicle_acJointNode'];              % if this solid close a closed-loop chain : {number of solid i on which is attached this solid ; attachement point (local frame of solid i}
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;
end


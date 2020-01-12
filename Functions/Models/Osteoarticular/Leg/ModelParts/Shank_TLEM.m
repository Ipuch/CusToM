function [Human_model]= Shank_TLEM(Human_model,k,Signe,Mass,AttachmentPoint)
%   Based on:
%	V. Carbone et al., �TLEM 2.0 - A comprehensive musculoskeletal geometry dataset for subject-specific modeling of lower extremity,� J. Biomech., vol. 48, no. 5, pp. 734�741, 2015.
%   INPUT
%   - OsteoArticularModel: osteo-articular model of an already existing
%   model (see the Documentation for the structure)
%   - k: homothety coefficient for the geometrical parameters (defined as
%   the subject size in cm divided by 180)
%   - Signe: side of the thigh model ('R' for right side or 'L' for left side)
%   - Mass: mass of the solids
%   - AttachmentPoint: name of the attachment point of the model on the
%   already existing model (character string)
%   OUTPUT
%   - OsteoArticularModel: new osteo-articular model (see the Documentation
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


%% Variables de sortie :
% "enrichissement de la structure "Human_model""

%% Liste des solides
list_solid={'Shank'};

%% Choix jambe droite ou gauche
if Signe == 'R'
    Mirror=[1 0 0; 0 1 0; 0 0 1];
else
    if Signe == 'L'
        Mirror=[1 0 0; 0 1 0; 0 0 -1];
    end
end

% %% Incr�mentation du num�ro des groupes
% n_group=0;
% for i=1:numel(Human_model)
%     if size(Human_model(i).Group) ~= [0 0] %#ok<BDSCA>
%         n_group=max(n_group,Human_model(i).Group(1,1));
%     end
% end
% n_group=n_group+1;

%% Incr�mentation de la num�rotation des solides

s=size(Human_model,2)+1;  %#ok<NASGU> % num�ro du premier solide
for i=1:size(list_solid,2)      % num�rotation de chaque solide : s_"nom du solide"
    if i==1
        eval(strcat('s_',list_solid{i},'=s;'))
    else
        eval(strcat('s_',list_solid{i},'=s_',list_solid{i-1},'+1;'))
    end
end

% trouver le num�ro de la m�re � partir du nom du point d'attache : 'attachment_pt'
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

%%                      D�finition des noeuds (articulaires)
% TLEM 2.0 � A COMPREHENSIVE MUSCULOSKELETAL GEOMETRY DATASET FOR SUBJECT-SPECIFIC MODELING OF LOWER EXTREMITY
%
%  V. Carbonea*, R. Fluita*, P. Pellikaana, M.M. van der Krogta,b, D. Janssenc, M. Damsgaardd, L. Vignerone, T. Feilkasf, H.F.J.M. Koopmana, N. Verdonschota,c
%
%  aLaboratory of Biomechanical Engineering, MIRA Institute, University of Twente, Enschede, The Netherlands
%  bDepartment of Rehabilitation Medicine, Research Institute MOVE, VU University Medical Center, Amsterdam, The Netherlands
%  cOrthopaedic Research Laboratory, Radboud University Medical Centre, Nijmegen, The Netherlands
%  dAnyBody Technology A/S, Aalborg, Denmark
%  eMaterialise N.V., Leuven, Belgium
%  fBrainlab AG, Munich, Germany
% *The authors Carbone and Fluit contributed equally.
% Journal of Biomechanics, Available online 8 January 2015, http://dx.doi.org/10.1016/j.jbiomech.2014.12.034
%% Adjustement of k
k=k*1.2063; %to fit 50th percentile person of 1.80m height 
% --------------------------- Shank ---------------------------------------

% centre de masse dans le rep�re de r�f�rence du segment
CoM_Shank=k*Mirror*[-0.0095;	0.2076;	0.0052];

% Position des noeuds
Shank_KneeJointNode = (k*Mirror*[-0.0102 ;	0.3670	;-0.0016])  -CoM_Shank;
Shank_TalocruralJointNode = (k*Mirror*[0.0052	;-0.0147	;0])-CoM_Shank;
MedialCondyle =	k*Mirror*[0 ; 0.32146 ;-0.038646 ]              -CoM_Shank;
LateralCondyle=	k*Mirror*[0 ; 0.3194  ; 0.038646 ]              -CoM_Shank;
TibialTuberosity=	k*Mirror*[0.032171 ; 0.27476  ; 0.0097883 ] -CoM_Shank;
FibularHead=	k*Mirror*[-0.028328 ;0.31974 ;0.031814 ]        -CoM_Shank;
MedialMalleolus=	k*Mirror*[0.017065 ;0.0049672 ;-0.027608 ]  -CoM_Shank;
LateralMalleolus=	k*Mirror*[-0.017065 ;-0.0049672 ; 0.027608 ]-CoM_Shank;

ANI=	k*Mirror*[0.017065 ;0.0049672 ;-0.04 ]      -CoM_Shank;
ANE=	k*Mirror*[-0.017065 ;-0.0049672 ; 0.04 ]    -CoM_Shank;
KNI =	k*Mirror*[0 ; 0.32146 ;-0.05 ]              -CoM_Shank;

PatellarLigament2=k*Mirror*[0.0321	0.2932	0.0114]'-CoM_Shank;
%% D�finition des positions anatomiques

Shank_position_set= {...
    [Signe 'ANE'], ANE; ...
    [Signe 'ANI'], ANI; ...
    [Signe 'KNI'], KNI; ...
    [Signe 'Shank_KneeJointNode'], Shank_KneeJointNode; ...
    [Signe 'Shank_TalocruralJointNode'], Shank_TalocruralJointNode; ...
    [Signe 'LateralCondyle'], LateralCondyle; ...
    [Signe 'TibialTuberosity'], TibialTuberosity; ...
    [Signe 'FibularHead'], FibularHead; ...
    [Signe 'LateralMalleolus'], LateralMalleolus; ...
    [Signe 'MedialMalleolus'], MedialMalleolus; ...
    [Signe 'MedialCondyle'], MedialCondyle; ...
    [Signe 'PatellarLigament2'],PatellarLigament2;...
    ['BicepsFemorisCaputBreve1Insertion1' Signe 'Shank'],k*Mirror*([-0.02252;0.31306;0.03954])-CoM_Shank;...
    ['BicepsFemorisCaputBreve2Insertion1' Signe 'Shank'],k*Mirror*([-0.02252;0.31306;0.03954])-CoM_Shank;...
    ['BicepsFemorisCaputBreve3Insertion1' Signe 'Shank'],k*Mirror*([-0.02252;0.31306;0.03954])-CoM_Shank;...
    ['BicepsFemorisCaputLongum1Insertion1' Signe 'Shank'],k*Mirror*([-0.02252;0.31306;0.03954])-CoM_Shank;...
    ['ExtensorDigitorumLongus1Origin1' Signe 'Shank'],k*Mirror*([0.00565;0.30732;0.02794])-CoM_Shank;...
    ['ExtensorDigitorumLongus1Via2' Signe 'Shank'],k*Mirror*([0.01858;0.00757;0.01443])-CoM_Shank;...
    ['ExtensorDigitorumLongus1Via3' Signe 'Shank'],k*Mirror*([0.02043;0.00455;0.01356])-CoM_Shank;...
    ['ExtensorDigitorumLongus1Via4' Signe 'Shank'],k*Mirror*([0.02315;0.00072;0.01456])-CoM_Shank;...
    ['ExtensorDigitorumLongus1Via5' Signe 'Shank'],k*Mirror*([0.02675;-0.0039;0.01741])-CoM_Shank;...
    ['ExtensorDigitorumLongus2Origin1' Signe 'Shank'],k*Mirror*([-0.01721;0.21765;0.02381])-CoM_Shank;...
    ['ExtensorDigitorumLongus2Via2' Signe 'Shank'],k*Mirror*([0.01858;0.00757;0.01443])-CoM_Shank;...
    ['ExtensorDigitorumLongus2Via3' Signe 'Shank'],k*Mirror*([0.02043;0.00455;0.01356])-CoM_Shank;...
    ['ExtensorDigitorumLongus2Via4' Signe 'Shank'],k*Mirror*([0.02315;0.00072;0.01456])-CoM_Shank;...
    ['ExtensorDigitorumLongus2Via5' Signe 'Shank'],k*Mirror*([0.02675;-0.0039;0.01741])-CoM_Shank;...
    ['ExtensorDigitorumLongus3Origin1' Signe 'Shank'],k*Mirror*([-0.01402;0.097;0.02065])-CoM_Shank;...
    ['ExtensorDigitorumLongus3Via2' Signe 'Shank'],k*Mirror*([0.01858;0.00757;0.01443])-CoM_Shank;...
    ['ExtensorDigitorumLongus3Via3' Signe 'Shank'],k*Mirror*([0.02043;0.00455;0.01356])-CoM_Shank;...
    ['ExtensorDigitorumLongus3Via4' Signe 'Shank'],k*Mirror*([0.02315;0.00072;0.01456])-CoM_Shank;...
    ['ExtensorDigitorumLongus3Via5' Signe 'Shank'],k*Mirror*([0.02675;-0.0039;0.01741])-CoM_Shank;...
    ['ExtensorDigitorumLongus4Origin1' Signe 'Shank'],k*Mirror*([-0.01402;0.097;0.02065])-CoM_Shank;...
    ['ExtensorDigitorumLongus4Via2' Signe 'Shank'],k*Mirror*([0.01858;0.00757;0.01443])-CoM_Shank;...
    ['ExtensorDigitorumLongus4Via3' Signe 'Shank'],k*Mirror*([0.02043;0.00455;0.01356])-CoM_Shank;...
    ['ExtensorDigitorumLongus4Via4' Signe 'Shank'],k*Mirror*([0.02315;0.00072;0.01456])-CoM_Shank;...
    ['ExtensorDigitorumLongus4Via5' Signe 'Shank'],k*Mirror*([0.02675;-0.0039;0.01741])-CoM_Shank;...
    ['ExtensorHallucisLongus1Origin1' Signe 'Shank'],k*Mirror*([-0.0191;0.21283;0.01896])-CoM_Shank;...
    ['ExtensorHallucisLongus1Via2' Signe 'Shank'],k*Mirror*([0.0238;0.01079;0.00865])-CoM_Shank;...
    ['ExtensorHallucisLongus1Via3' Signe 'Shank'],k*Mirror*([0.02804;0.00333;0.00544])-CoM_Shank;...
    ['ExtensorHallucisLongus1Via4' Signe 'Shank'],k*Mirror*([0.03222;-0.00101;0.00544])-CoM_Shank;...
    ['ExtensorHallucisLongus2Origin1' Signe 'Shank'],k*Mirror*([-0.01373;0.13964;0.01345])-CoM_Shank;...
    ['ExtensorHallucisLongus2Via2' Signe 'Shank'],k*Mirror*([0.0238;0.01079;0.00865])-CoM_Shank;...
    ['ExtensorHallucisLongus2Via3' Signe 'Shank'],k*Mirror*([0.02804;0.00333;0.00544])-CoM_Shank;...
    ['ExtensorHallucisLongus2Via4' Signe 'Shank'],k*Mirror*([0.03222;-0.00101;0.00544])-CoM_Shank;...
    ['ExtensorHallucisLongus3Origin1' Signe 'Shank'],k*Mirror*([-0.00963;0.08052;0.01333])-CoM_Shank;...
    ['ExtensorHallucisLongus3Via2' Signe 'Shank'],k*Mirror*([0.0238;0.01079;0.00865])-CoM_Shank;...
    ['ExtensorHallucisLongus3Via3' Signe 'Shank'],k*Mirror*([0.02804;0.00333;0.00544])-CoM_Shank;...
    ['ExtensorHallucisLongus3Via4' Signe 'Shank'],k*Mirror*([0.03222;-0.00101;0.00544])-CoM_Shank;...
    ['FlexorDigitorumLongus1Origin1' Signe 'Shank'],k*Mirror*([-0.00208;0.23212;0.00137])-CoM_Shank;...
    ['FlexorDigitorumLongus1Via2' Signe 'Shank'],k*Mirror*([-0.00071;0.00933;-0.02222])-CoM_Shank;...
    ['FlexorDigitorumLongus1Via3' Signe 'Shank'],k*Mirror*([-0.00031;0.00766;-0.02322])-CoM_Shank;...
    ['FlexorDigitorumLongus1Via4' Signe 'Shank'],k*Mirror*([0.00163;0.00368;-0.02351])-CoM_Shank;...
    ['FlexorDigitorumLongus1Via5' Signe 'Shank'],k*Mirror*([0.00461;-0.00144;-0.02314])-CoM_Shank;...
    ['FlexorDigitorumLongus1Via6' Signe 'Shank'],k*Mirror*([0.00815;-0.00655;-0.02214])-CoM_Shank;...
    ['FlexorDigitorumLongus1Via7' Signe 'Shank'],k*Mirror*([0.01173;-0.01049;-0.02055])-CoM_Shank;...
    ['FlexorDigitorumLongus2Origin1' Signe 'Shank'],k*Mirror*([-9e-05;0.18162;-0.00427])-CoM_Shank;...
    ['FlexorDigitorumLongus2Via2' Signe 'Shank'],k*Mirror*([-0.00071;0.00933;-0.02222])-CoM_Shank;...
    ['FlexorDigitorumLongus2Via3' Signe 'Shank'],k*Mirror*([-0.00031;0.00766;-0.02322])-CoM_Shank;...
    ['FlexorDigitorumLongus2Via4' Signe 'Shank'],k*Mirror*([0.00163;0.00368;-0.02351])-CoM_Shank;...
    ['FlexorDigitorumLongus2Via5' Signe 'Shank'],k*Mirror*([0.00461;-0.00144;-0.02314])-CoM_Shank;...
    ['FlexorDigitorumLongus2Via6' Signe 'Shank'],k*Mirror*([0.00815;-0.00655;-0.02214])-CoM_Shank;...
    ['FlexorDigitorumLongus2Via7' Signe 'Shank'],k*Mirror*([0.01173;-0.01049;-0.02055])-CoM_Shank;...
    ['FlexorDigitorumLongus3Origin1' Signe 'Shank'],k*Mirror*([-0.0005;0.12931;-0.00108])-CoM_Shank;...
    ['FlexorDigitorumLongus3Via2' Signe 'Shank'],k*Mirror*([-0.00071;0.00933;-0.02222])-CoM_Shank;...
    ['FlexorDigitorumLongus3Via3' Signe 'Shank'],k*Mirror*([-0.00031;0.00766;-0.02322])-CoM_Shank;...
    ['FlexorDigitorumLongus3Via4' Signe 'Shank'],k*Mirror*([0.00163;0.00368;-0.02351])-CoM_Shank;...
    ['FlexorDigitorumLongus3Via5' Signe 'Shank'],k*Mirror*([0.00461;-0.00144;-0.02314])-CoM_Shank;...
    ['FlexorDigitorumLongus3Via6' Signe 'Shank'],k*Mirror*([0.00815;-0.00655;-0.02214])-CoM_Shank;...
    ['FlexorDigitorumLongus3Via7' Signe 'Shank'],k*Mirror*([0.01173;-0.01049;-0.02055])-CoM_Shank;...
    ['FlexorDigitorumLongus4Origin1' Signe 'Shank'],k*Mirror*([-0.0005;0.12931;-0.00108])-CoM_Shank;...
    ['FlexorDigitorumLongus4Via2' Signe 'Shank'],k*Mirror*([-0.00071;0.00933;-0.02222])-CoM_Shank;...
    ['FlexorDigitorumLongus4Via3' Signe 'Shank'],k*Mirror*([-0.00031;0.00766;-0.02322])-CoM_Shank;...
    ['FlexorDigitorumLongus4Via4' Signe 'Shank'],k*Mirror*([0.00163;0.00368;-0.02351])-CoM_Shank;...
    ['FlexorDigitorumLongus4Via5' Signe 'Shank'],k*Mirror*([0.00461;-0.00144;-0.02314])-CoM_Shank;...
    ['FlexorDigitorumLongus4Via6' Signe 'Shank'],k*Mirror*([0.00815;-0.00655;-0.02214])-CoM_Shank;...
    ['FlexorDigitorumLongus4Via7' Signe 'Shank'],k*Mirror*([0.01173;-0.01049;-0.02055])-CoM_Shank;...
    ['FlexorHallucisLongus1Origin1' Signe 'Shank'],k*Mirror*([-0.02731;0.20329;0.01594])-CoM_Shank;...
    ['FlexorHallucisLongus1Via2' Signe 'Shank'],k*Mirror*([-0.00514;0.00265;-0.01064])-CoM_Shank;...
    ['FlexorHallucisLongus1Via3' Signe 'Shank'],k*Mirror*([-0.00495;-0.00224;-0.01029])-CoM_Shank;...
    ['FlexorHallucisLongus1Via4' Signe 'Shank'],k*Mirror*([-0.00463;-0.0067;-0.01027])-CoM_Shank;...
    ['FlexorHallucisLongus1Via5' Signe 'Shank'],k*Mirror*([-0.00417;-0.01073;-0.01057])-CoM_Shank;...
    ['FlexorHallucisLongus1Via6' Signe 'Shank'],k*Mirror*([-0.00357;-0.01432;-0.0112])-CoM_Shank;...
    ['FlexorHallucisLongus1Via7' Signe 'Shank'],k*Mirror*([-0.00284;-0.01747;-0.01215])-CoM_Shank;...
    ['FlexorHallucisLongus2Origin1' Signe 'Shank'],k*Mirror*([-0.02034;0.12716;0.01041])-CoM_Shank;...
    ['FlexorHallucisLongus2Via2' Signe 'Shank'],k*Mirror*([-0.00514;0.00265;-0.01064])-CoM_Shank;...
    ['FlexorHallucisLongus2Via3' Signe 'Shank'],k*Mirror*([-0.00495;-0.00224;-0.01029])-CoM_Shank;...
    ['FlexorHallucisLongus2Via4' Signe 'Shank'],k*Mirror*([-0.00463;-0.0067;-0.01027])-CoM_Shank;...
    ['FlexorHallucisLongus2Via5' Signe 'Shank'],k*Mirror*([-0.00417;-0.01073;-0.01057])-CoM_Shank;...
    ['FlexorHallucisLongus2Via6' Signe 'Shank'],k*Mirror*([-0.00357;-0.01432;-0.0112])-CoM_Shank;...
    ['FlexorHallucisLongus2Via7' Signe 'Shank'],k*Mirror*([-0.00284;-0.01747;-0.01215])-CoM_Shank;...
    ['FlexorHallucisLongus3Origin1' Signe 'Shank'],k*Mirror*([-0.01039;0.05536;0.01121])-CoM_Shank;...
    ['FlexorHallucisLongus3Via2' Signe 'Shank'],k*Mirror*([-0.00514;0.00265;-0.01064])-CoM_Shank;...
    ['FlexorHallucisLongus3Via3' Signe 'Shank'],k*Mirror*([-0.00495;-0.00224;-0.01029])-CoM_Shank;...
    ['FlexorHallucisLongus3Via4' Signe 'Shank'],k*Mirror*([-0.00463;-0.0067;-0.01027])-CoM_Shank;...
    ['FlexorHallucisLongus3Via5' Signe 'Shank'],k*Mirror*([-0.00417;-0.01073;-0.01057])-CoM_Shank;...
    ['FlexorHallucisLongus3Via6' Signe 'Shank'],k*Mirror*([-0.00357;-0.01432;-0.0112])-CoM_Shank;...
    ['FlexorHallucisLongus3Via7' Signe 'Shank'],k*Mirror*([-0.00284;-0.01747;-0.01215])-CoM_Shank;...
    ['GastrocnemiusLateralis1Via1' Signe 'Shank'],k*Mirror*([-0.04748;0.15711;0.00138])-CoM_Shank;...
    ['GastrocnemiusMedialis1Via1' Signe 'Shank'],k*Mirror*([-0.0331;0.30075;-0.01802])-CoM_Shank;...
    ['GastrocnemiusMedialis1Via2' Signe 'Shank'],k*Mirror*([-0.03395;0.26145;-0.02239])-CoM_Shank;...
    ['GastrocnemiusMedialis1Via3' Signe 'Shank'],k*Mirror*([-0.03433;0.22333;-0.02427])-CoM_Shank;...
    ['GastrocnemiusMedialis1Via4' Signe 'Shank'],k*Mirror*([-0.03426;0.1864;-0.02367])-CoM_Shank;...
    ['GastrocnemiusMedialis1Via5' Signe 'Shank'],k*Mirror*([-0.03372;0.15066;-0.02059])-CoM_Shank;...
    ['GastrocnemiusMedialis1Via6' Signe 'Shank'],k*Mirror*([-0.03271;0.1161;-0.01503])-CoM_Shank;...
    ['Gracilis1Via1' Signe 'Shank'],k*Mirror*([-0.01316;0.31812;-0.03736])-CoM_Shank;...
    ['Gracilis1Via2' Signe 'Shank'],k*Mirror*([-0.01079;0.31117;-0.03469])-CoM_Shank;...
    ['Gracilis1Via3' Signe 'Shank'],k*Mirror*([-0.00621;0.30449;-0.03171])-CoM_Shank;...
    ['Gracilis1Insertion4' Signe 'Shank'],k*Mirror*([0.02047;0.28263;-0.00681])-CoM_Shank;...
    ['Gracilis2Via1' Signe 'Shank'],k*Mirror*([-0.01316;0.31812;-0.03736])-CoM_Shank;...
    ['Gracilis2Via2' Signe 'Shank'],k*Mirror*([-0.01079;0.31117;-0.03469])-CoM_Shank;...
    ['Gracilis2Via3' Signe 'Shank'],k*Mirror*([-0.00621;0.30449;-0.03171])-CoM_Shank;...
    ['Gracilis2Insertion4' Signe 'Shank'],k*Mirror*([0.02047;0.28263;-0.00681])-CoM_Shank;...
    ['PeroneusBrevis1Origin1' Signe 'Shank'],k*Mirror*([-0.0195;0.19345;0.02392])-CoM_Shank;...
    ['PeroneusBrevis1Via2' Signe 'Shank'],k*Mirror*([-0.019;-0.00216;0.02239])-CoM_Shank;...
    ['PeroneusBrevis1Via3' Signe 'Shank'],k*Mirror*([-0.01912;-0.00904;0.02248])-CoM_Shank;...
    ['PeroneusBrevis1Via4' Signe 'Shank'],k*Mirror*([-0.01481;-0.014;0.02261])-CoM_Shank;...
    ['PeroneusBrevis2Origin1' Signe 'Shank'],k*Mirror*([-0.02008;0.12226;0.01984])-CoM_Shank;...
    ['PeroneusBrevis2Via2' Signe 'Shank'],k*Mirror*([-0.019;-0.00216;0.02239])-CoM_Shank;...
    ['PeroneusBrevis2Via3' Signe 'Shank'],k*Mirror*([-0.01912;-0.00904;0.02248])-CoM_Shank;...
    ['PeroneusBrevis2Via4' Signe 'Shank'],k*Mirror*([-0.01481;-0.014;0.02261])-CoM_Shank;...
    ['PeroneusBrevis3Origin1' Signe 'Shank'],k*Mirror*([-0.01592;0.03615;0.01474])-CoM_Shank;...
    ['PeroneusBrevis3Via2' Signe 'Shank'],k*Mirror*([-0.019;-0.00216;0.02239])-CoM_Shank;...
    ['PeroneusBrevis3Via3' Signe 'Shank'],k*Mirror*([-0.01912;-0.00904;0.02248])-CoM_Shank;...
    ['PeroneusBrevis3Via4' Signe 'Shank'],k*Mirror*([-0.01481;-0.014;0.02261])-CoM_Shank;...
    ['PeroneusLongus1Origin1' Signe 'Shank'],k*Mirror*([-0.01688;0.29115;0.03256])-CoM_Shank;...
    ['PeroneusLongus1Via2' Signe 'Shank'],k*Mirror*([-0.01599;-0.01128;0.0201])-CoM_Shank;...
    ['PeroneusLongus1Via3' Signe 'Shank'],k*Mirror*([-0.01408;-0.01409;0.02033])-CoM_Shank;...
    ['PeroneusLongus1Via4' Signe 'Shank'],k*Mirror*([-0.0135;-0.01624;0.02054])-CoM_Shank;...
    ['PeroneusLongus1Via5' Signe 'Shank'],k*Mirror*([-0.01425;-0.01773;0.0207])-CoM_Shank;...
    ['PeroneusLongus2Origin1' Signe 'Shank'],k*Mirror*([-0.02396;0.23465;0.02721])-CoM_Shank;...
    ['PeroneusLongus2Via2' Signe 'Shank'],k*Mirror*([-0.01599;-0.01128;0.0201])-CoM_Shank;...
    ['PeroneusLongus2Via3' Signe 'Shank'],k*Mirror*([-0.01408;-0.01409;0.02033])-CoM_Shank;...
    ['PeroneusLongus2Via4' Signe 'Shank'],k*Mirror*([-0.0135;-0.01624;0.02054])-CoM_Shank;...
    ['PeroneusLongus2Via5' Signe 'Shank'],k*Mirror*([-0.01425;-0.01773;0.0207])-CoM_Shank;...
    ['PeroneusLongus3Origin1' Signe 'Shank'],k*Mirror*([-0.02588;0.16304;0.02012])-CoM_Shank;...
    ['PeroneusLongus3Via2' Signe 'Shank'],k*Mirror*([-0.01599;-0.01128;0.0201])-CoM_Shank;...
    ['PeroneusLongus3Via3' Signe 'Shank'],k*Mirror*([-0.01408;-0.01409;0.02033])-CoM_Shank;...
    ['PeroneusLongus3Via4' Signe 'Shank'],k*Mirror*([-0.0135;-0.01624;0.02054])-CoM_Shank;...
    ['PeroneusLongus3Via5' Signe 'Shank'],k*Mirror*([-0.01425;-0.01773;0.0207])-CoM_Shank;...
    ['Popliteus1Via1' Signe 'Shank'],k*Mirror*([-0.02066;0.32277;0.01451])-CoM_Shank;...
    ['Popliteus1Insertion2' Signe 'Shank'],k*Mirror*([-0.00475;0.28125;-0.00658])-CoM_Shank;...
    ['Popliteus2Via1' Signe 'Shank'],k*Mirror*([-0.02066;0.32277;0.01451])-CoM_Shank;...
    ['Popliteus2Insertion2' Signe 'Shank'],k*Mirror*([-0.00218;0.26089;-0.00955])-CoM_Shank;...
    ['Popliteus3Via1' Signe 'Shank'],k*Mirror*([-0.02066;0.32277;0.01451])-CoM_Shank;...
    ['Popliteus3Insertion2' Signe 'Shank'],k*Mirror*([0.00092;0.22854;-0.01291])-CoM_Shank;...
    ['Sartorius1Via1' Signe 'Shank'],k*Mirror*([-0.0066685;0.31866;-0.037093])-CoM_Shank;...
    ['Sartorius1Via2' Signe 'Shank'],k*Mirror*([-0.0036549;0.3097;-0.034996])-CoM_Shank;...
    ['Sartorius1Via3' Signe 'Shank'],k*Mirror*([-0.00042061;0.3033;-0.032114])-CoM_Shank;...
    ['Sartorius1Insertion4' Signe 'Shank'],k*Mirror*([0.01796;0.2902;-0.01085])-CoM_Shank;...
    ['Semimembranosus1Insertion1' Signe 'Shank'],k*Mirror*([-0.02054;0.31458;-0.01617])-CoM_Shank;...
    ['Semimembranosus2Insertion1' Signe 'Shank'],k*Mirror*([-0.01521;0.31218;-0.0277])-CoM_Shank;...
    ['Semimembranosus3Insertion1' Signe 'Shank'],k*Mirror*([-0.00644;0.3134;-0.03297])-CoM_Shank;...
    ['Semitendinosus1Via1' Signe 'Shank'],k*Mirror*([-0.0154;0.31325;-0.03226])-CoM_Shank;...
    ['Semitendinosus1Insertion2' Signe 'Shank'],k*Mirror*([0.01942;0.27145;-0.00743])-CoM_Shank;...
    ['SoleusLateralis1Origin1' Signe 'Shank'],k*Mirror*([-0.028;0.29987;0.02729])-CoM_Shank;...
    ['SoleusLateralis2Origin1' Signe 'Shank'],k*Mirror*([-0.02813;0.25003;0.02253])-CoM_Shank;...
    ['SoleusLateralis3Origin1' Signe 'Shank'],k*Mirror*([-0.02698;0.18321;0.01689])-CoM_Shank;...
    ['SoleusMedialis1Origin1' Signe 'Shank'],k*Mirror*([-0.0036;0.2454;-0.00375])-CoM_Shank;...
    ['SoleusMedialis2Origin1' Signe 'Shank'],k*Mirror*([0.00113;0.2205;-0.01218])-CoM_Shank;...
    ['SoleusMedialis3Origin1' Signe 'Shank'],k*Mirror*([0.00378;0.19825;-0.0131])-CoM_Shank;...
    ['TensorFasciaeLatae1Insertion1' Signe 'Shank'],k*Mirror*([0.01568;0.32738;0.03194])-CoM_Shank;...
    ['TensorFasciaeLatae2Insertion1' Signe 'Shank'],k*Mirror*([0.01568;0.32738;0.03194])-CoM_Shank;...
    ['TibialisAnterior1Origin1' Signe 'Shank'],k*Mirror*([0.01253;0.27569;0.01594])-CoM_Shank;...
    ['TibialisAnterior1Via2' Signe 'Shank'],k*Mirror*([0.03221;0.00648;-0.0005])-CoM_Shank;...
    ['TibialisAnterior2Origin1' Signe 'Shank'],k*Mirror*([0.0115;0.21214;0.00949])-CoM_Shank;...
    ['TibialisAnterior2Via2' Signe 'Shank'],k*Mirror*([0.03221;0.00648;-0.0005])-CoM_Shank;...
    ['TibialisAnterior3Origin1' Signe 'Shank'],k*Mirror*([0.00786;0.13667;0.00912])-CoM_Shank;...
    ['TibialisAnterior3Via2' Signe 'Shank'],k*Mirror*([0.03221;0.00648;-0.0005])-CoM_Shank;...
    ['TibialisPosteriorLateralis1Origin1' Signe 'Shank'],k*Mirror*([-0.02198;0.26428;0.02075])-CoM_Shank;...
    ['TibialisPosteriorLateralis1Via2' Signe 'Shank'],k*Mirror*([0.00248;0.00941;-0.02552])-CoM_Shank;...
    ['TibialisPosteriorLateralis1Via3' Signe 'Shank'],k*Mirror*([0.00704;0.00146;-0.02628])-CoM_Shank;...
    ['TibialisPosteriorLateralis1Via4' Signe 'Shank'],k*Mirror*([0.01252;-0.00636;-0.02496])-CoM_Shank;...
    ['TibialisPosteriorLateralis2Origin1' Signe 'Shank'],k*Mirror*([-0.0228;0.19286;0.01283])-CoM_Shank;...
    ['TibialisPosteriorLateralis2Via2' Signe 'Shank'],k*Mirror*([0.00248;0.00941;-0.02552])-CoM_Shank;...
    ['TibialisPosteriorLateralis2Via3' Signe 'Shank'],k*Mirror*([0.00704;0.00146;-0.02628])-CoM_Shank;...
    ['TibialisPosteriorLateralis2Via4' Signe 'Shank'],k*Mirror*([0.01252;-0.00636;-0.02496])-CoM_Shank;...
    ['TibialisPosteriorLateralis3Origin1' Signe 'Shank'],k*Mirror*([-0.01587;0.10849;0.00943])-CoM_Shank;...
    ['TibialisPosteriorLateralis3Via2' Signe 'Shank'],k*Mirror*([0.00248;0.00941;-0.02552])-CoM_Shank;...
    ['TibialisPosteriorLateralis3Via3' Signe 'Shank'],k*Mirror*([0.00704;0.00146;-0.02628])-CoM_Shank;...
    ['TibialisPosteriorLateralis3Via4' Signe 'Shank'],k*Mirror*([0.01252;-0.00636;-0.02496])-CoM_Shank;...
    ['TibialisPosteriorMedialis1Origin1' Signe 'Shank'],k*Mirror*([-0.00128;0.27674;0.01142])-CoM_Shank;...
    ['TibialisPosteriorMedialis1Via2' Signe 'Shank'],k*Mirror*([0.00248;0.00941;-0.02552])-CoM_Shank;...
    ['TibialisPosteriorMedialis1Via3' Signe 'Shank'],k*Mirror*([0.00704;0.00146;-0.02628])-CoM_Shank;...
    ['TibialisPosteriorMedialis1Via4' Signe 'Shank'],k*Mirror*([0.01252;-0.00636;-0.02496])-CoM_Shank;...
    ['TibialisPosteriorMedialis2Origin1' Signe 'Shank'],k*Mirror*([0.00258;0.20455;0.00749])-CoM_Shank;...
    ['TibialisPosteriorMedialis2Via2' Signe 'Shank'],k*Mirror*([0.00248;0.00941;-0.02552])-CoM_Shank;...
    ['TibialisPosteriorMedialis2Via3' Signe 'Shank'],k*Mirror*([0.00704;0.00146;-0.02628])-CoM_Shank;...
    ['TibialisPosteriorMedialis2Via4' Signe 'Shank'],k*Mirror*([0.01252;-0.00636;-0.02496])-CoM_Shank;...
    ['TibialisPosteriorMedialis3Origin1' Signe 'Shank'],k*Mirror*([0.00237;0.11025;0.00752])-CoM_Shank;...
    ['TibialisPosteriorMedialis3Via2' Signe 'Shank'],k*Mirror*([0.00248;0.00941;-0.02552])-CoM_Shank;...
    ['TibialisPosteriorMedialis3Via3' Signe 'Shank'],k*Mirror*([0.00704;0.00146;-0.02628])-CoM_Shank;...
    ['TibialisPosteriorMedialis3Via4' Signe 'Shank'],k*Mirror*([0.01252;-0.00636;-0.02496])-CoM_Shank;...
    
    };

%%                     Mise � l'�chelle des inerties
%% ["Adjustments to McConville et al. and Young et al. body segment inertial parameters"] R. Dumas
% --------------------------- Shank ---------------------------------------
Length_Shank=norm(Shank_TalocruralJointNode	-Shank_KneeJointNode);
[I_Shank]=rgyration2inertia([28 10 28 4*1i 2*1i 5], Mass.Shank_Mass, [0 0 0], Length_Shank, Signe);

%% Cr�ation de la structure "Human_model"

num_solid=0;
%% Shank
num_solid=num_solid+1;        % solide num�ro ...
name=list_solid{num_solid}; % nom du solide
eval(['incr_solid=s_' name ';'])  % num�ro du solide dans le mod�le
Human_model(incr_solid).name=[Signe name];
Human_model(incr_solid).sister=0;
Human_model(incr_solid).child=0;
Human_model(incr_solid).mother=s_mother;
Human_model(incr_solid).a=-[-Mirror(3,3)*0.0488	-Mirror(3,3)*0.0463	-0.9977]';
Human_model(incr_solid).joint=1;
Human_model(incr_solid).limit_inf=-pi;
Human_model(incr_solid).limit_sup=pi;
Human_model(incr_solid).ActiveJoint=1;
Human_model(incr_solid).Visual=1;
Human_model(incr_solid).Geometry='TLEM';
% Human_model(incr_solid).Group=[n_group 2];
Human_model(incr_solid).m=Mass.Shank_Mass;
Human_model(incr_solid).b=pos_attachment_pt;
Human_model(incr_solid).I=[I_Shank(1) I_Shank(4) I_Shank(5); I_Shank(4) I_Shank(2) I_Shank(6); I_Shank(5) I_Shank(6) I_Shank(3)];
Human_model(incr_solid).c=-Shank_KneeJointNode; % dans le rep�re du joint pr�c�dent
Human_model(incr_solid).anat_position=Shank_position_set;
Human_model(incr_solid).L={[Signe 'Shank_KneeJointNode'];[Signe 'Shank_TalocruralJointNode']};
%Calibration de l'axe de rotation
a1=Human_model(incr_solid).a;
[~,Ind]=max(abs(a1));
a2=zeros(3,1);
a2(Ind)=1;
R=Rodrigues_from_two_axes(a2,a1);% recherche des deux axes orthogonaux � l'axe de rotation
Human_model(incr_solid).limit_alpha= [10 , -10;...
                                        10, -10];
Human_model(incr_solid).v= [ R(:,1) , R(:,2) ];
Human_model(incr_solid).calib_a=1;

end

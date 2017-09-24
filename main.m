%****************************************************************************************************
% Author: Hao Liu and Yong Wang
% Last Edited: 9/24/2017
% Email: haoliu@csu.edu.cn; ywang@csu.edu.cn

% Reference: Y. Wang, H. Liu, H. Long, Z. Zhang and S. Yang. Differential Evolution with A New Encoding
% Mechanism for Optimizing Wind Farm Layout,
% in press, DOI: 
%****************************************************************************************************

clc;
clear;
tic;

%The defined parameters
interval = 15;                        %the angle interval
interval_num = fix(360/interval);     %the number of bins
X = 2000;                             %the length of wind farm
Y = 2000;                             %the width of wind farm
R = 40;                               %the rotor radium
H = 80;                               %the hub height 
CT = 0.8;                             %the thrust coefficient
a = 1 - sqrt(1 - CT);                 %the axial induction factor * 2
kappa = 0.01;                         %the spreading constant for land case(z=80,zo=0.54)
cut_in_speed = 3.5;                   %the value of cut-in speed 
rated_speed = 14;                     %the value of rated speed 
cut_out_speed = 25;                   %the value of cut-out speed 
minDistance = 5 * R;             %minimum distance between any two wind turbines

%Values of parameters k and c in weibull distribution and the frequency associated with each wind direction interval
k(1:interval_num) = 2;
c = [7 5 5 5 5 4 5 6 7 7 8 9.5 10 8.5 8.5 6.5 4.6 2.6 8 5 6.4 5.2 4.5 3.9];
fre = [0.0003	0.0072	0.0237	0.0242	0.0222	0.0301	0.0397	0.0268	0.0626 ...	
    0.0801	0.1025	0.1445	0.1909	0.1162	0.0793	0.0082	0.0041	0.0008 ...	
    0.0010	0.0005	0.0013	0.0031	0.0085	0.0222];

%If you want to test DEEM in wind scenario 2, please uncomment the following code
%{
k(1:interval_num) = 2;
c(1:interval_num) = 13;
fre = [0,0.01,0.01,0.01,0.01,0.2,0.6,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0];
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%population%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
populationsize=1;         %the number of individuals 
maxEvaluations = 150000;

repeatTimes = 10;%每种情况跑5次
diffN = [15,20,25,30,35,40,60,80,100];%different number of individuals 
diffSideLength = [2000,2000,2000,2200,2400,2600,3100,3600,4000];
cases = length(diffN);

for indexN = 1:cases
    N = diffN(indexN);
    X = diffSideLength(indexN);
    Y = diffSideLength(indexN);
    
for cycle = 1:repeatTimes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluate speed up,每次要重新初始化%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global thetaVeldefijMatrix;
thetaVeldefijMatrix = zeros(N,N,interval_num);
global thetaVeldefijBackup;
thetaVeldefijBackup = thetaVeldefijMatrix;
global turbineMoved;
turbineMoved(1:N) = 0;

%记录实验结果，画曲线
result = [];
evaluations = 0;

%set the random seed
[temp]=random_seed(); 
rand('seed',temp); 
tic;
%1.set the solution space of every turbines
constraint(1)=R;        %the lower constraint in X direction
constraint(2)=X-R;      %the upper constraint in X direction 
constraint(3)=R;        %the lower constraint in Y direction
constraint(4)=Y-R;      %the upper constraint in Y direction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DE%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lu=[constraint(1),constraint(3);
    constraint(2),constraint(4)];
 F = 0.9;
 CR = 0.9;
candidate = [];
%2.initialize positions of particles--presentx
coordinate(1:2*N)=0;                         %initial turbine coordinate
presentx(1:populationsize,1:2*N)=0;
presentxChildren(1:populationsize,1:2*N)=0;
for i=1:populationsize
    j=1;
    conflict=0;
    while(1)
        coordinate(2*j-1)=constraint(1)+(X-R)*rand();  % X coordinate
        coordinate(2*j)=constraint(3)+(Y-R)*rand();    % Y coordinate
        flag1=0;   %mark the conflict in the constraint one
        flag2=0;   %mark the conflict in the constraint two
        %constraint one: not too close to other turbines
        for g=1:j
            dis_gj=sqrt((coordinate(2*g-1)-coordinate(2*j-1))^2+(coordinate(2*g)-coordinate(2*j))^2);
            if((g~=j)&&(dis_gj<5*R))
                flag1=1;            
                conflict=conflict+1;
                break;
            end
        end
        %constraint two: not too close to the boundry of wind farm
        if ((coordinate(2*j-1)>constraint(2))||(coordinate(2*j)>constraint(4)))
            flag2=1;
        end
        if((flag1==1)||(flag2==1))
            j=j;
        else
            j=j+1;
        end
        if(conflict>=200)  %if conflict comes up too many time, new coordinates are produced
            j=1;
            conflict=0;
        end
        if(j==(N+1))
            break;
        end
    end
    presentx(i,:)=coordinate;
end
% figure(1);
% print_turbine2(N,X,Y,coordinate);

%计算父代总能量，只有一个个体，个体增加时再加循环
totalEnergyParent = fitness(interval_num,interval,fre,N,presentx(1,:), ...,
                   a,kappa,R,k,c,cut_in_speed,rated_speed,cut_out_speed,'o');

while(evaluations < maxEvaluations)
   
%     if(evaluations>0 && (bestSoFarEvaluation)>10000 ) %停止准则10000
%         fprintf('break: no improvement for evals=10000');                
%         break;
%     end
    presentxChildren = presentx;
    
    %产生候选子代
    if(isempty(candidate))
        candidate = localDE(presentxChildren, N, lu, 2, F, CR);
    end
    newpoint =  candidate(1:2);
    candidate(1:2) = [];
    
    presentxChildren = mutationOperatorExecuteTIE(newpoint, presentxChildren,N,...,
                       X,Y,minDistance);
   
    thetaVeldefijBackup = thetaVeldefijMatrix;
    totalEnergyChildren = fitness(interval_num,interval,fre,N,presentxChildren(1,:), ...,
                          a,kappa,R,k,c,cut_in_speed,rated_speed,cut_out_speed,'f');
           
    %Adaptive node mutation alteration                 
    if(totalEnergyParent <totalEnergyChildren)
        better = 1;
        presentx = presentxChildren;
        totalEnergyParent = totalEnergyChildren;
        resulttemp = totalEnergyChildren;
    else
        better = 0;
        thetaVeldefijMatrix = thetaVeldefijBackup;
        resulttemp = totalEnergyParent;
    end
    %记录实验结果
    result = [result resulttemp];
    
    for i=1:N
        if(turbineMoved(i))                                    
           turbineMoved(i) = 0;
        end
    end
       
    evaluations = evaluations + 1; 
    
    if(~rem(evaluations,100))
      fprintf('The N is %d\n',N);
      fprintf('The cycle  is %d\n',cycle);
      fprintf('The evaluations  is %d\n',evaluations);
      fprintf('The best energy  is %d\n',resulttemp);
    end
end
toc;

%记录单次实验结果
toc;
% print_turbine2(N,X,Y,presentx(1,:));
% plot(result);
end%实验次数循环
end%风机个数循环

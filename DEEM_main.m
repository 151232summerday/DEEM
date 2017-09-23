% coordinate_scenario1: main function
clc;
clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The adjusted parameters-the number of turbines%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=10;                               %the number of turbines

%%%%%%%%%%%%%%%%%%%%%%%%
%Other parameters setup%
%%%%%%%%%%%%%%%%%%%%%%%%

%The defined parameters
interval = 15;                      %the angle interval 
input_filename='scenario1.xlsx';    %the data input file
output_filename='data1.xlsx';       %the data output file
X=2000;                             %the length of wind farm
Y=2000;                             %the width of wind farm
R=40;                               %the rotor radium
H=80;                               %the hub height 
CT=0.8;                             %the thrust coefficient
a=1-sqrt(1-CT);                     %the axial induction factor * 2
kappa=0.01;            %the spreading constant for land case(z=80,zo=0.54)

%load the wind speed data
[typ, desc] = xlsfinfo(input_filename);       %load data into matlab
direction = xlsread(input_filename,'B2:B4134'); % wind direction data
speed = xlsread(input_filename,'C2:C4134'); % wind speed data
originalnum = size(direction,1);                        % the size of data
interval_num = fix(360/interval);             % the number of bins

%change natural wind speed into effective wind speed
cut_in_speed=3.5;              %the value of cut-in speed 
rated_speed=14;                %the value of rated speed 
cut_out_speed=25;              %the value of cut-out speed 
[dirdata,spddata,num]=effective_windspeed ...,
(direction,speed,originalnum,cut_in_speed,rated_speed,cut_out_speed);

% global k c          %values of parameters k and c in weibull distribution
k(1:interval_num)=2;
c=[7 5 5 5 5 4 5 6 7 7 8 9.5 10 8.5 8.5 6.5 4.6 2.6 8 5 6.4 5.2 4.5 3.9];

%calculate the frequency and average wind speed 
flag(1:num) = 0;                   % mark data belonging to which bin
for i = 1:num                      %divide data according to wind direction
  if(mod(dirdata(i),interval) == 0)
      flag(i) = fix(dirdata(i)/interval); 
  else 
      flag(i) = ceil(dirdata(i)/interval);
  end
end
bin(1:interval_num) = 0;
for i = 1:num
  bin(flag(i)) = bin(flag(i))+1;
end

fre(1:interval_num) = 0;
for i=1:interval_num
    fre(i) = bin(i)/num;    %frequency in every bin
end

fprintf('The interval of every bin is %d\n',interval);
fprintf('The number of bins is %d\n',interval_num);
fprintf('The frequency in every bin are\n');
fprintf('%.4f\t',fre);
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%population%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
populationsize=1;         %the number of individuals 
maxEvaluations = 150000;
minimumDistance1 = 5*R;%������������С����
repeatTimes = 10;%ÿ�������5��
diffN = [15,20,25,30,35,40,60,80,100];
diffSideLength = [2000,2000,2000,2200,2400,2600,3100,3600,4000];
cases = length(diffN);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����ʵ����%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resultRecordT = zeros(1,repeatTimes);
saveE = zeros(cases,repeatTimes);
saveStatisticalData = zeros(cases,5);
saveCurve = [];
saveLayout = cell(1,cases);

for indexN = 1:cases
    N = diffN(indexN);
    X = diffSideLength(indexN);
    Y = diffSideLength(indexN);
    
for cycle = 1:repeatTimes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluate speed up,ÿ��Ҫ���³�ʼ��%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global thetaVeldefijMatrix;
thetaVeldefijMatrix = zeros(N,N,interval_num);
global thetaVeldefijBackup;
thetaVeldefijBackup = thetaVeldefijMatrix;
global turbineMoved;
turbineMoved(1:N) = 0;

%��¼ʵ������������
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

%���㸸����������ֻ��һ�����壬��������ʱ�ټ�ѭ��
totalEnergyParent = fitness(interval_num,interval,fre,N,presentx(1,:), ...,
                   a,kappa,R,k,c,cut_in_speed,rated_speed,cut_out_speed,'o');

while(evaluations < maxEvaluations)
   
%     if(evaluations>0 && (bestSoFarEvaluation)>10000 ) %ֹͣ׼��10000
%         fprintf('break: no improvement for evals=10000');                
%         break;
%     end
    presentxChildren = presentx;
    
    %������ѡ�Ӵ�
    if(isempty(candidate))
        candidate = localDE(presentxChildren, N, lu, 2, F, CR);
    end
    newpoint =  candidate(1:2);
    candidate(1:2) = [];
    
    presentxChildren = mutationOperatorExecuteTIE(newpoint, presentxChildren,N,...,
                       X,Y,minimumDistance1);
   
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
    %��¼ʵ����
    result = [result resulttemp];
    
    for i=1:N
        if(turbineMoved(i))                                    
           turbineMoved(i) = 0;
        end
    end
       
    evaluations = evaluations + 1; 
    
    if(~rem(evaluations,100))
%     figure(1);
%     print_turbine2(N,X,Y,presentxChildren(1,:));
%     figure(2);
%     plot(result);
      fprintf('The N is %d\n',N);
      fprintf('The cycle  is %d\n',cycle);
      fprintf('The evaluations  is %d\n',evaluations);
      fprintf('The best energy  is %d\n',resulttemp);
    end
end
toc;

%��¼����ʵ����
resultRecordT(1,cycle) = toc;
saveE(indexN,cycle) = resulttemp;
saveCurve(cycle,:,indexN) = result;
saveLayout{indexN}(cycle,:) = presentx(1,:);
% print_turbine2(N,X,Y,presentx(1,:));
% plot(result);
end%ʵ�����ѭ��
[saveStatisticalData(indexN,1),saveStatisticalData(indexN,4)] = max(saveE(indexN,:));%���ֵ��������
saveStatisticalData(indexN,2) = mean(saveE(indexN,:));
saveStatisticalData(indexN,3) = std(saveE(indexN,:));
saveStatisticalData(indexN,5) = mean(resultRecordT);
save DEEMdata saveCurve saveLayout saveE saveStatisticalData;
end%�������ѭ��
%save dataFDE saveCurve saveLayout saveE saveStatisticalData;
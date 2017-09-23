%calculate the fitness function
function[all_power]=fitness(interval_num,interval,fre,N,coordinate, ...,
            a,kappa,R,k,c,cut_in_speed,rated_speed,cut_out_speed,bool)

% interval_num : the number of wind direction bins
% interval :  the value of every wind direction bin
% fre : the frequency of every wind direction bin
% N: the fixed number of wind turbines
% cooridinate : the coordinates of every wind turbines(1*2N)
% a : the axial induction factor
% kappa : the spreading constant for land case
% R : the rotor diameter
% k : parameter in weibull distribution
% c : parameter in weibull distribution
% cut_in_speed : the value of cut-in speed 
% rated_speed : the value of rated speed 
% cut_out_speed : the value of cut-out speed 
% bool : 'o'原始评价方法 'f'快速评价方法

%interval_power(1:interval_num)=0;         %the power output in every interval
all_power=0;                              %the whole power output 
for i=1:interval_num
   interval_dir=(i-0.5)*interval;
   [power_eva]=eva_power(i,interval_dir,N,coordinate, ...,
            a,kappa,R,k(i),c(i),cut_in_speed,rated_speed,cut_out_speed,bool);
    all_power=all_power+fre(i)*sum(power_eva);
%    interval_power(i)=sum(power_eva);
end

end
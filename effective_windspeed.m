% change the natural wind speed data into effective wind speed data
function [dirdata,spddata,num]=effective_windspeed(direction,speed,originalnum,cut_in_speed,rated_speed,cut_out_speed)
% direction : the original wind direction data
% speed : the original wind speed data
% originalnum : the size of original data
% cut_in_speed : the value of cut-in speed 
% rated_speed : the value of rated speed 
% cut_out_speed : the value of cut-out speed

j=1;
for i=1:originalnum
   if ((speed(i)<cut_in_speed)||(speed(i)>cut_out_speed))
       j=j;
   elseif ((speed(i)>=cut_in_speed)&&(speed(i)<rated_speed))
       dirdata(j)=direction(i);
       spddata(j)=speed(i);
       j=j+1;
   elseif ((speed(i)>=rated_speed)&&(speed(i)<=cut_out_speed))
       dirdata(j)=direction(i);
       spddata(j)=rated_speed;
       j=j+1;
   end
       
end
num = size(dirdata,2);  % the size of effective wind speed data
end
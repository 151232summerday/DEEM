
%load data;

if(max(presentx)>1960||max(presentx)<40)
   fprintf('fail');
end
for i=1:N
    for j=1:i
        if(j~=i)
            dis_ij=sqrt((presentx(2*j-1)-presentx(2*i-1))^2+(presentx(2*j)-presentx(2*i))^2);
            if(dis_ij<200)
                fprintf('fail');
            end
        end

    end
end
testresult = fitness(interval_num,interval,fre,N,presentx(1,:), ...,
                   a,kappa,R,k,c,cut_in_speed,rated_speed,cut_out_speed,'o')




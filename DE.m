function offSubpopFinal = DE(subpop, NS, lu, n, F, CR)

offSubpop = zeros(NS, n);
offSubpopFinal = [];
%¸ñÊ½×ª»»
subpoptemp = [];
for i=1:NS
    subpoptemp = [subpoptemp;subpop(2*i-1) subpop(2*i)];
end
subpop = subpoptemp;

for i = 1 : NS

    % Choose the indices for mutation
    indexSet = 1 : NS;
    indexSet(i) = [];

    % Choose the first Index
    temp = floor(rand * (NS - 1)) + 1;
    nouse(1) = indexSet(temp);
    indexSet(temp) = [];

    % Choose the second index
    temp = floor(rand * (NS - 2)) + 1;
    nouse(2) = indexSet(temp);
    indexSet(temp) = [];

    % Choose the third index
    temp = floor(rand * (NS - 3)) + 1;
    nouse(3) = indexSet(temp);

    % subpopsizetate
    V = subpop(i, : ) + F .* (subpop(nouse(2), : ) - subpop(nouse(3), : ));

    % Handle the elements of the vector which violate the boundary
    vioLow = find(V < lu(1, : ));
    if rand <1
        V(1, vioLow) = lu(1,vioLow);
%     else
%         V(1, vioLow) = 2 .* lu(1, vioLow) - V(1, vioLow);
%         vioLowUpper = find(V(1, vioLow) > lu(2, vioLow));
%         V(1, vioLow(vioLowUpper)) = lu(2, vioLow(vioLowUpper));
%     else
%         V(1, vioLow) = 0.3 .* (lu(2, vioLow) - lu(1, vioLow))+lu(1,vioLow);
     end

    vioUpper = find(V > lu(2, : ));
    if rand < 1
        V(1, vioUpper) =  lu(2, vioUpper);
%     else
% %         V(1, vioUpper) = 2 .* lu(2, vioUpper) - V(1, vioUpper);
% %         vioUpperLow = find(V(1, vioUpper) < lu(1, vioUpper));
% %         V(1, vioUpper(vioUpperLow)) = lu(1, vioUpper(vioUpperLow));
%     V(1, vioUpper) = lu(2,vioUpper)-0.2 .* (lu(2,vioUpper) - lu(1, vioUpper));
    end

    % Implement the binomial crossover
    jRand = floor(rand * n) + 1;
    t = rand(1, n) < CR;
    t(1, jRand) = 1;
    t_ = 1 - t;
    U = t .* V + t_ .* subpop(i,  : );

    offSubpopFinal = [offSubpopFinal U];

end


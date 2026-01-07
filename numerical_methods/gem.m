n=3;
m=3;
i=1;
j=1;
matrix = [1, 2, 3; 4, 5, 6; 2, 3, 7]; % Initialize a matrix of size n x m
for i = 1:n
    if matrix(i,j)> matrix(i+1,j)
        pivot=matrix(i,j);
        for x = i+1:n
            matrix(x+1,:)=matrix(i,j)-(matrix(x+1,j)/pivot)*matrix(x+1,:);
        end
        
    else
        v=matrix(x,:);
        matrix(x,:)=matrix(x+1,:);
        matrix(x+1,:)=v;
    end
    
end




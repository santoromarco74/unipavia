n=3;
m=3;
i=1;
j=1;
mat= [1, 2, 3; 4, 5, 6; 2, 3, 7]; % Initialize a matrix of size n x m
matrix=mat;
for i = 1:n-1
    if matrix(i,j)> matrix(i+1,j)
        pivot=matrix(i,j);
        for x = i+1:n
            matrix(x+1,:)=matrix(i,j)-(matrix(x+1,j)/pivot)*matrix(x+1,:);
        end
        
    else
        v=matrix(i,:);
        matrix(i,:)=matrix(i+1,:);
        matrix(i+1,:)=v;
    end
    print("La matrice di partenza é ");
    disp(mat);
    print("La matrice di arrivo é ");
        disp(matrix);

    
end




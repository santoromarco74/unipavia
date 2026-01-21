clc;
n_righe=3;
n_col=3;
% Initialize the transformation matrix
l = zeros(n_righe, n_col);
l = diag(ones(n_righe,1));

mat= [ 4, 5, 6; 1, 2, 3; 2, 3, 7]; % Initialize a matrix of size n x m
matrix=mat;
for k=1:n_col
    for i= (k+1):(n_righe)
        m=matrix(i,k)/matrix(1,k);
        for j=k:n_col
            matrix(i,j)=matrix(i,j)-m*matrix(1,j);
        end
        l(i,k)=m;
       disp("Per i ="+ i + " e k=" + k + "ed m=" + m);
       disp(matrix);
    end
end

disp("La matrice di partenza é ");
    disp(mat);
    disp("La matrice di arrivo é ");
        disp(matrix);


        % Display the transformation matrix
disp("La matrice di trasformazione é ");
disp(l);

disp ("Invece secondo Matlab:");
[L,U,P]=lu(mat);
disp (L);
disp (U);
disp (P);


% function (rsup(:),rinf(:))=scambia_righe(riga_inf(:),riga_sup(:))
%         v=riga_inf(:);
%         riga_inf(:)=riga_sup(:);
%         riga_sup(:)=v;
% 
% end
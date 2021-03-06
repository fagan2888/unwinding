function U = unwindm(A)
%UNWINDM  Matrix unwinding function.
%   UNWINDM(A) is the matrix unwinding function of the square matrix A,
%   defined as (A - logm(expm(A)))/(2*pi*i). It is computed via the Schur
%   decomposition.

%   Reference:
%   M. Aprahamian and N. J. Higham.
%   The matrix unwinding function, with an application to computing the
%   matrix exponential.  SIAM J. Matrix Anal. Appl., 35(1):88-109, 2014.

%   Mary Aprahamian and Nicholas J. Higham, 2013, 2020.

[Q,T] = schur(A,'complex');

ord = blocking(T);
[ord, ind] = swapping(ord);  % Gives the blocking.
ord = max(ord)-ord+1;        % Since ORDSCHUR puts highest index top left.
[Q,T] = ordschur(Q,T,ord);
U = Q * unwindm_tri(T) * Q';

if isreal(A) && norm(real(U),1) <= 10*length(A)*eps*norm(U,1)
   U = 1i*imag(U);
end

%%%%%%%%%%%%%%%%%%%%%%%%
function F = unwindm_tri(T)
%UNWINDM_tri   Unwinding matrix of upper triangular matrix.

n = length(T);
F = diag( unwind( diag(T) ) );

% Compute off-diagonal of F by scalar Parlett recurrence.
for j=2:n
     for i = j-1:-1:1
         if F(i,i) == F(j,j)
            F(i,j) = 0;        % We're within a diagonal block.
         else   
            s = T(i,j)*(F(i,i)-F(j,j));
            if j-i >= 2
               k = i+1:j-1;
               s = s + F(i,k)*T(k,j) - T(i,k)*F(k,j);
            end
            F(i,j) = s/(T(i,i)-T(j,j));
         end
     end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = blocking(A)
%BLOCKING  Produce blocking pattern for block Parlett recurrence in FUNM.
%   M = BLOCKING(A) accepts an upper triangular matrix
%   A and produces a blocking pattern, specified by the vector M,
%   for the block Parlett recurrence.
%   M(i) is the index of the block into which A(i,i) should be placed,
%   for i=1:LENGTH(A).
%   Elements with equal unwinding number go into the same block.

a = diag(A); n = length(a);
for i = 1:n
    u(i) = unwind(a(i));
end
m = min(u);
u = u-m+1; % Ensures min(u) = 1;

% Remove any gaps from the integer sequence in u.
uq = unique(u);  % The unique values in u.
for i = 1:length(u)
    m(i) = find( u(i) == uq );
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mm,ind] = swapping(m)
%SWAPPING  Choose confluent permutation ordered by average index.
%   [MM,IND] = SWAPPING(M) takes a vector M containing the integers
%   1:K (some repeated if K < LENGTH(M)), where M(J) is the index of
%   the block into which the element T(J,J) of a Schur form T
%   should be placed.
%   It constructs a vector MM (a permutation of M) such that T(J,J)
%   will be located in the MM(J)'th block counting from the (1,1) position.
%   The algorithm used is to order the blocks by ascending
%   average index in M, which is a heuristic for minimizing the number
%   of swaps required to achieve this confluent permutation.
%   The cell array vector IND defines the resulting block form:
%   IND{i} contains the indices of the i'th block in the permuted form.

mmax = max(m); mm = zeros(size(m));
g = zeros(1,mmax); h = zeros(1,mmax);

for i = 1:mmax
    p = find(m==i);
    h(i) = length(p);
    g(i) = sum(p)/h(i);
end

[~,y] = sort(g);
h = [0 cumsum(h(y))];

ind = cell(mmax,1);
for i = 1:mmax
    mm(m==y(i)) = i;
    ind{i} = h(i)+1:h(i+1);
end

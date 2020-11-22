%test_unwindm

disp('Errors should be of order 1e-14.')

rng(3)

A = [4 16; -4 4];
U_exact = 1i*[0 -2; 0.5 0];
U = unwindm(A);
err = norm(U_exact - U,1)/norm(U_exact,1)

n = 10;
for i = 1:3
  d = complex(linspace(-n/2,n/2,n),linspace(1,n,n));
  Z = randn(n);
  A = Z\diag(d)*Z;
  X = unwindm(A);
  Y = Z\diag(unwind(d))*Z;
  err = norm(X - Y,1)/norm(X,1)
end

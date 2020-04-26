function  [M_k,Mbar_k,Y_k,Ybar_k,Y_lm,Ybar_lm,Y_ml,Ybar_ml]=computeYmats(c)
    N = size(c.bus,1);
	L = size(c.branch,1);
%% Build admittance Y and line admittance matrix Ylm    
    Y = zeros(N);
    Ylm = zeros(N); %symmetric
    % ylm is the mutual admittance between but l and m, and yll is the
    % admittance to ground at bus l, for every (l,m) ele in line set L; note that ylm=0
    % if (l,m) is not in line set L
    
    % Set off-diagonal
    for k = 1:size(c.branch,1) % iterate through lines
        i = find(c.branch(k,1) == c.bus(:,1));
        j = find(c.branch(k,2) == c.bus(:,1));
        Y(i,j) = Y(i,j)-1/(c.branch(k,3)+1j*c.branch(k,4)); % off diag y=1/z=1/(r+j*x)
        Y(j,i) = Y(i,j);

        % l-->m matrix, sending to receiving, same as l-->m because
        % admittances dont have directionality
        Ylm(i,j) = Ylm(i,j)-1/(c.branch(k,3)+1j*c.branch(k,4)); % -ylm
        Ylm(j,i) = Ylm(i,j);
        if i==j
            Ylm(i,j)=Ylm(i,j)+1/(c.branch(k,3)+1j*c.branch(k,4)); % +ylm
        end
    end

    % Set diagonal of admittance matrix
    for k = 1:N
        Y(k,k) = -sum(Y(k,:));
    end
    Y = sparse(Y);
    clc


%% setup x,Y_k,M_k,Ybar_k,Ylm matrices
    % this allows for working with nonlin PF equations in Trace(matrix) notation
    e = sparse(eye(N)); % standard basis vector
    Y_k = {};
    Ybar_k = {};
    for k = 1:N
        y = e(:,k)*e(:,k)'*Y; % still a matrix
        Y_k{k} = 1/2*[real(y+y.') imag(y.'-y);imag(y-y.') real(y+y.')];
        M_k{k} = [e(:,k)*e(:,k)' zeros(N,N);zeros(N,N) e(:,k)*e(:,k)'];
        Mbar_k{k} = [zeros(N,N) e(:,k)*e(:,k)';e(:,k)*e(:,k)' zeros(N,N)]; % this is a guess as not defined in zero duality gap paper
        Ybar_k{k} = -1/2*[imag(y+y.') real(y-y.');real(y.'-y) imag(y+y.')]; 
    end
    % Ylm is a matrix, Y_lm is a cell array
    for l=1:N % L is number of lines, L set size is NxN
        for m=1:N
            % QQQ check this ylm line
            Ylmm=Ylm(l,m)*e(:,l)*e(:,l)'-Ylm(l,m)*e(:,l)*e(:,m)'; % matrix, selects two ele of admittance matrix and finds difference
            Ymll=Ylm(m,l)*e(:,m)*e(:,m)'-Ylm(m,l)*e(:,m)*e(:,l)'; % matrix, selects two ele of admittance matrix and finds difference

            Y_lm{l,m} = 1/2*[real(Ylmm+Ylmm.') imag(Ylmm.'-Ylmm);imag(Ylmm-Ylmm.') real(Ylmm+Ylmm.')]; % assume notation in paper has Ylm=Y typo
            Ybar_lm{l,m} = -1/2*[imag(Ylmm+Ylmm.') real(Ylmm-Ylmm.');real(Ylmm.'-Ylmm) imag(Ylmm+Ylmm.')]; 
            
            Y_ml{l,m} = 1/2*[real(Ymll+Ymll.') imag(Ymll.'-Ymll);imag(Ymll-Ymll.') real(Ymll+Ymll.')]; % assume notation in paper has Ylm=Y typo
            Ybar_ml{l,m} = -1/2*[imag(Ymll+Ymll.') real(Ymll-Ymll.');real(Ymll.'-Ymll) imag(Ymll+Ymll.')]; 


        end
    end
end
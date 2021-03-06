function E_o2d = Optimal2D()

    E = discretize_signals(); % Real PV plant only knows current power
    
    D = size(E,1);
    T = size(E,2);
    W = 3; % Window size
    
    %% Constants
    % Weghting constant (==1)
    a1 = 0.1; % Past hours of past days
    a2 = 0.7; % Past days
    a3 = 1-a1-a2; % Past hours
    if(a1+a2+a3 ~= 1)
        error('a1+a2+a3 must be 1');
    end
        
    %% Algorithm ecuations
    %% Processing values
    % Initialize first predicted day with real values
    E_o2d = zeros(D, T); % Predicted power
    
    % Fill predicted values with Algorithm output
    for d = 1:D
        for t = 1:T
            x = prevValues(d,t+1);
            y = prevDays(d,t+1);
            z = prevHours(d,t);
            E_o2d(d, t) = a1*sum(sum(x))/(W-1)^2 + a2*sum(sum(y))/W + a3*sum(sum(z))/W;
        end
    end

    
    %% Functions
    function ret = getE(d, t)
        if(d<1) d=1;end
        if(t<1) t=1;end
        ret = E(d, t);
    end
    
    % Returns last W hours
    function ret = prevHours(day, hour)
        ret = zeros(W);
        for d_j = 1:W
            ret(d_j) = getE(day, hour-d_j+1);
        end
    end

    % Returns last W days
    function ret = prevDays(day, hour)
        ret = zeros(W);
        for d_i = 1:W
            ret(d_i) = getE(day-d_i+1, min(T, hour));
        end
    end

    % Returns last (W-1)^2 days-hours
    function ret = prevValues(day, hour)
        ret = zeros(W-1,W-1);
        for d_i = 1:W-1
            for d_j = 1:W-1
                ret(d_i,d_j) = getE(day-d_i, min(T,hour-d_j) );
            end
        end
    end
    
    %% Plot results
    model_plotter(E, E_o2d);
end
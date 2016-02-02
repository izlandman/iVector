function result = cosineDistance(i_vector)
[~,columns] = size(i_vector);
result = -1*ones(columns,columns);

for i=1:columns
    for k=1:columns
        if( i == k )
            result(i,k) = 0;
        else
            result(i,k) = acos( dot(i_vector(:,i),i_vector(:,k)) / ...
                ( norm(i_vector(:,i))*norm(i_vector(:,k)) ) );
        end
    end
end
result = abs(result);
end
function result = ttestFullArray(data)

[row,column] = size(data);
result = -1*ones(2,row,column);

for i = 1 : column
    for j = 1 : column
            [result(1,i,j),result(2,i,j)] = ttest(data(:,i),data(:,j));
    end
end

end
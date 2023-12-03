mutable struct ProductionPlanning
    n::Int  # Número de períodos
    c::Vector{Float64}  # Custos de produção por período
    d::Vector{Int}  # Demanda por período
    s::Vector{Float64}  # Custos de armazenamento por período
    p::Vector{Float64}  # Multas por período
end

# Função para ler os dados do arquivo e criar a estrutura ProductionPlanning
function readData(file)
    n = 0
    c = [] 
    d = [] 
    s = [] 
    p = [] 

    for l in eachline(file)
        q = split(l, "\t")
        if q[1] == "n"
            n = parse(Int, q[2])
            c = zeros(Float64,n)
            d = [0 for i=1:n]
            s = zeros(Float64,n)
            p = zeros(Float64,n)
            
        else
            id = q[1]
            num = parse(Int, q[2])    
            if id == "c"
                valor = parse(Int, q[3])
                c[num] = valor
            elseif id == "d"
                valor = parse(Float64, q[3])
                d[num] = valor
            elseif id == "s"
                valor = parse(Float64, q[3])
                s[num] = valor
            elseif id == "p"
                valor = parse(Float64, q[3])
                p[num] = valor
            end
        end
    end

    return ProductionPlanning(n, c, d, s, p)
end

# Ler os dados do arquivo
file = open(ARGS[1], "r")
data = readData(file)

function productionDay(c::Vector{Float64}, d::Vector{Int}, s::Vector{Float64}, p::Vector{Float64}, n::Int, index::Int)
    min = 100000000000000000
    prod_day = 0
    for i in 1:n
        current = 0
        if i < index
            current = c[i]
            for j in i:(index-1)
                current += s[j]
            end
        end
        if i == index
            current = c[i]
        end
        if i > index
            current = c[i]
            for j in index:(i-1)
                current += p[j]
            end
        end
        if current < min
            min = current
            prod_day = i
        end
    end
    return prod_day, min
end

function calculateCost(c::Vector{Float64}, d::Vector{Int}, s::Vector{Float64}, p::Vector{Float64}, n::Int)
    production = zeros(Int,n)
    solution = 0
    for i in 1:n
        prod_day, cost = productionDay(c, d, s, p, n, i)
        production[prod_day] = d[i]
        solution += cost*d[i]
    end
    return production, solution
end

production, solution = calculateCost(data.c, data.d, data.s, data.p, data.n)

println("TP1 2021031629 = ", solution)
for i in 1:data.n
    println(production[i], "\t")
end




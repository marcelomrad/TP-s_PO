mutable struct Graph
    n::Int
    edges::Vector{Tuple{Int, Int}}
end

function readGraph(file)
    n = 0
    edges = []
    for l in eachline(file)
        q = split(l, "\t")
        if q[1] == "n"
            n = parse(Int64, q[2])
        elseif q[1] == "e"
            v = parse(Int64, q[2])
            u = parse(Int64, q[3])
            push!(edges, (v, u))
        end
    end
    return Graph(n, edges)
end

function colorGraph(graph::Graph)
    cores = zeros(Int, graph.n)
    
    # Ordenar vértices por grau (do maior para o menor)
    vertices_ordem = sort(1:graph.n, by=v -> -count(e -> v in e, graph.edges))

    # Dicionário para armazenar cores possíveis para cada vértice
    cores_possiveis = Dict(i => Set(1:graph.n) for i in 1:graph.n)

    for vertice in vertices_ordem
        for aresta in graph.edges
            v, u = aresta
            if v == vertice && cores[u] != 0
                delete!(cores_possiveis[vertice], cores[u])
            elseif u == vertice && cores[v] != 0
                delete!(cores_possiveis[vertice], cores[v])
            end
        end
        cores[vertice] = minimum(cores_possiveis[vertice])
    end
    
    return cores
end

function printColoring(cores)
    num_cores = maximum(cores)
    println("TP2 matricula = ", num_cores)
    for cor in 1:num_cores
        vertices_cor = findall(x -> x == cor, cores)
        println(join(vertices_cor, '\t'))
    end
end

file = open(ARGS[1], "r")
graph = readGraph(file)
close(file)

cores = colorGraph(graph)
printColoring(cores)

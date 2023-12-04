using Random

# Função para ler os dados do arquivo de entrada
function ler_dados(nome_arquivo)
    arquivo = open(nome_arquivo, "r")
    n = parse(Int, split(readline(arquivo), '\t')[2])
    arestas = Dict{Int, Set{Int}}()
    for i in 1:n
        arestas[i] = Set{Int}()
    end
    while !eof(arquivo)
        linha = readline(arquivo)
        v, u = parse.(Int, split(linha, '\t')[2:3])
        push!(arestas[v], u)
        push!(arestas[u], v)
    end
    close(arquivo)
    return n, arestas
end

# Função para ordenar os vértices pelo grau
function ordenar_vertices_por_grau(arestas)
    return sort(collect(keys(arestas)), by = v -> length(arestas[v]))
end

# Verificar se um vértice é adjacente a algum vértice em um conjunto
function é_adjacente(v, conjunto, arestas)
    for adj in arestas[v]
        if adj in conjunto
            return true
        end
    end
    return false
end

# Heurística de conjunto independente
function heuristica_conjunto_independente(vertices, arestas)
    conjunto_independente = Set{Int}()
    for v in vertices
        if !é_adjacente(v, conjunto_independente, arestas)
            push!(conjunto_independente, v)
        end
    end
    return conjunto_independente
end

# Usar as tentativas para se aproximar do melhor conjunto independente
function resolver_conjunto_independente(nome_arquivo, tentativas=10)
    n, arestas = ler_dados(nome_arquivo)
    melhores_vertices = Set{Int}()
    melhor_tamanho = 0

    for i in 1:tentativas
        vertices = ordenar_vertices_por_grau(arestas)
        shuffle!(vertices)
        conjunto_independente = heuristica_conjunto_independente(vertices, arestas)
        
        if length(conjunto_independente) > melhor_tamanho
            melhores_vertices = conjunto_independente
            melhor_tamanho = length(conjunto_independente)
        end
    end

    println("TP2 MATRICULA : ", melhor_tamanho)
    println(join(sort(collect(melhores_vertices)), "\t"))
end

if length(ARGS) > 0
    resolver_conjunto_independente(ARGS[1], 100) 
else
    println("Por favor, forneça o nome do arquivo como argumento.")
end

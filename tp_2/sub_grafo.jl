# Função para abrir o arquivo
function abrir_arquivo(nome_arquivo)
    open(nome_arquivo, "r")
end

# Função para ler os dados do arquivo
function ler_dados_subgrafo(nome_arquivo)
    arquivo = abrir_arquivo(nome_arquivo)
    num_vertices = parse(Int, split(readline(arquivo), '\t')[2])
    matriz_arestas = zeros(Int8, (num_vertices, num_vertices))
    matriz_pesos = zeros(Int16, (num_vertices, num_vertices))
    arestas_pesos = []

    while !eof(arquivo)
        s = split(readline(arquivo), '\t')
        u, v, w = parse(Int, s[2]), parse(Int, s[3]), parse(Int16, s[4])
        matriz_pesos[u, v], matriz_pesos[v, u] = w, w
        matriz_arestas[u, v], matriz_arestas[v, u] = 1, 1
        push!(arestas_pesos, (u, v, w))
    end
    close(arquivo)
    num_vertices, matriz_arestas, matriz_pesos, arestas_pesos
end

# Função para atualizar as heurísticas
function atualizar_heuristicas(heuristica_vertices, matriz_arestas, matriz_pesos, solucao, min_indx)
    for i in eachindex(heuristica_vertices)
        if matriz_arestas[min_indx, i] == 1 && solucao[i] == 1
            heuristica_vertices[i] -= matriz_pesos[min_indx, i]
        end
    end
    heuristica_vertices[min_indx] = 0 
    solucao[min_indx] = 0
    heuristica_vertices
end


# Função para resolver o problema do maior subgrafo induzido
function resolver_subgrafo(nome_arquivo)
    num_vertices, matriz_arestas, matriz_pesos, arestas_pesos = ler_dados_subgrafo(nome_arquivo)

    heuristica_vertices = zeros(Int16, num_vertices)
    for (u, v, w) in arestas_pesos
        heuristica_vertices[u] += w
        heuristica_vertices[v] += w
    end

    solucao = ones(Int8, num_vertices)
    min_indx = argmin(heuristica_vertices)

    while heuristica_vertices[min_indx] < 0
        heuristica_vertices = atualizar_heuristicas(heuristica_vertices, matriz_arestas, matriz_pesos, solucao, min_indx)
        min_indx = argmin(heuristica_vertices)
    end

    calcular_total(arestas_pesos, solucao)
end

# Função para calcular e imprimir o total
function calcular_total(arestas_pesos, solucao)
    total = sum(w for (u, v, w) in arestas_pesos if solucao[u] == 1 && solucao[v] == 1)

    println("TP_2 2021031548 = ", total)
    println("VÉRTICES:")
    for (i, val) in enumerate(solucao)
        if val == 1
            println(i)
        end
    end
end

# Execução do programa
if length(ARGS) > 0
    resolver_subgrafo(ARGS[1])
else
    println("Por favor, forneça o nome do arquivo como argumento.")
end

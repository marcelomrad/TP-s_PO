# Função para ler os dados do arquivo
function ler_dados_subgrafo(nome_arquivo)
    arquivo = open(nome_arquivo, "r")
    n = parse(Int, split(readline(arquivo), '\t')[2])
    arestas_pesos = Tuple{Int, Int, Float64}[]
    for linha in eachline(arquivo)
        tokens = split(linha, '\t')
        push!(arestas_pesos, (parse(Int, tokens[2]), parse(Int, tokens[3]), parse(Float64, tokens[4])))
    end
    close(arquivo)
    return n, arestas_pesos
end

# Função para calcular o peso do subgrafo
function calcular_peso(solucao, arestas_pesos)
    peso = 0.0
    for (v, u, w) in arestas_pesos
        if v in solucao && u in solucao
            peso += w
        end
    end
    return peso
end

using Random

# Função para criar uma solução aleatória
function criar_solucao_aleatoria(n)
    solucao = rand(1:n, rand(1:n))
    return Set(solucao)
end

# Função para criar a população inicial
function criar_populacao_inicial(tamanho_populacao, n)
    return [criar_solucao_aleatoria(n) for _ in 1:tamanho_populacao]
end

# Função de seleção - torneio, sem usar 'sample'
function selecionar_para_reproducao(populacao, arestas_pesos, tamanho_torneio)
    selecionados = []
    for _ in 1:length(populacao)
        candidatos = [populacao[rand(1:end)] for _ in 1:tamanho_torneio]
        melhor = findmax([calcular_peso(s, arestas_pesos) for s in candidatos])[2]
        push!(selecionados, candidatos[melhor])
    end
    return selecionados
end


# Função de crossover - ponto único, sem usar 'take'
function crossover(solucao1, solucao2)
    solucao1_list = collect(solucao1)
    solucao2_list = collect(solucao2)

    ponto = rand(1:min(length(solucao1_list), length(solucao2_list)))
    filho1 = Set(solucao1_list[1:ponto])
    filho2 = Set(solucao2_list[1:ponto])

    filho1 = union(filho1, Set(solucao2_list[ponto+1:end]))
    filho2 = union(filho2, Set(solucao1_list[ponto+1:end]))

    return filho1, filho2
end

# Função de mutação - adicionar ou remover um vértice
function mutacao(solucao, n)
    if rand() < 0.5
        push!(solucao, rand(1:n))
    else
        solucao = setdiff(solucao, Set([rand(collect(solucao))]))
    end
    return solucao
end

# Algoritmo genético principal
function resolver_subgrafo(nome_arquivo, tamanho_populacao, geracoes, tamanho_torneio)
    n, arestas_pesos = ler_dados_subgrafo(nome_arquivo)
    populacao = criar_populacao_inicial(tamanho_populacao, n)

    for _ in 1:geracoes
        populacao = selecionar_para_reproducao(populacao, arestas_pesos, tamanho_torneio)
        nova_populacao = []
        for i in 1:2:length(populacao)-1
            filho1, filho2 = crossover(populacao[i], populacao[i+1])
            push!(nova_populacao, mutacao(filho1, n))
            push!(nova_populacao, mutacao(filho2, n))
        end
        populacao = nova_populacao
    end

    melhor_solucao = findmax([calcular_peso(s, arestas_pesos) for s in populacao])[2]
    println("VALOR = ", calcular_peso(populacao[melhor_solucao], arestas_pesos))
    println("VERTICES:")
    for vertice in sort(collect(populacao[melhor_solucao]))
        println(vertice)
    end
end

if length(ARGS) > 0
    resolver_subgrafo(ARGS[1], 100, 120 ,7)
else
    println("Por favor, forneça o nome do arquivo como argumento.")
end


# Ler os dados de entrada
function ler_dados(nome_arquivo)
    arquivo = open(nome_arquivo, "r")
    n = parse(Int, split(readline(arquivo), '\t')[2])
    objetos = [parse(Float64, split(readline(arquivo), '\t')[3]) for i in 1:n]
    close(arquivo)
    return n, objetos
end


#Heurística de empacotamento
function resolver_empacotamento(nome_arquivo)
    n, pesos = ler_dados(nome_arquivo)
    objetos = [(i, peso) for (i, peso) in enumerate(pesos)]
    sort!(objetos, by=x->x[2], rev=true) # Ordena os objetos por peso em ordem decrescente

    caixas = []
    for (indice_objeto, peso_objeto) in objetos
        colocou = false
        for caixa in caixas
            if sum(map(x -> x[2], caixa)) + peso_objeto <= 20.0 # Verifica se o objeto cabe na caixa
                push!(caixa, (indice_objeto, peso_objeto))
                colocou = true
                break
            end
        end
        if !colocou
            push!(caixas, [(indice_objeto, peso_objeto)]) # Cria uma nova caixa se o objeto não couber em nenhuma caixa existente
        end
    end

    # Imprimir a solução
    println("TP2 MATRICULA: ", length(caixas))
    for caixa in caixas
        indices_objetos = [string(indice) for (indice, _) in caixa]
        println(join(indices_objetos, '\t'))
    end
end



if length(ARGS) > 0
    resolver_empacotamento(ARGS[1])
else
    println("Por favor, forneça o nome do arquivo como argumento.")
end

function lerDados()
    if length(ARGS) < 2
        error("Número de argumentos inválido")
    end
    
    filePath = ARGS[1]
    file = open(filePath, "r")

    number_objs = readline(file)
    number_objs = match(r"n\s+(\d+)", number_objs)
    number_objs = parse(Int, number_objs.captures[1])
    obj = Tuple{Int, Float64}[]
    
    for i in 1:number_objs
        line = readline(file)
        match_result = match(r"o\s+(\d+)\s+([0-9.]+)", line)
        
        if match_result === nothing
            error("Formato da linha $i incorreto")
        end
        
        id = parse(Int, match_result.captures[1])
        peso = parse(Float64, match_result.captures[2])
        push!(obj, (id, peso))
    end

    close(file)
    return obj
end

objetos = lerDados()
limite_peso = 20

objetos = sort(objetos, by = x -> x[2], rev = true)

limite_peso = 20
caixas = []

for obj in objetos
    caixa = nothing
    
    for c in caixas
        if sum(map(x -> x[2], c)) + obj[2] <= limite_peso
            caixa = c
            break
        end
    end
    
    if caixa === nothing
        caixa = [obj]
        push!(caixas, caixa)
    else
        push!(caixa, obj)
    end
end

# Ordena as caixas por quantidade de itens em ordem decrescente
sort!(caixas, by = c -> length(c), rev = true)

println("TP2 2021031688 = ", length(caixas))

# Imprime os IDs dos objetos em cada linha
for (i, caixa) in enumerate(caixas)
    for obj in caixa
        print("\t$(obj[1])")
    end
    println()
end

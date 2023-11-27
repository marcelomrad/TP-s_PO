function ler_instancia(nome_arquivo)
    arquivo = open(nome_arquivo, "r")
    n = parse(Int, split(readline(arquivo), '\t')[2])
    c = zeros(n)
    d = zeros(n)
    s = zeros(n)
    p = zeros(n)
    for linha in eachline(arquivo)
        id, num, valor = split(linha, '\t')
        num = parse(Int, num)
        valor = parse(Float32, valor)
        if id == "c"
            c[num] = valor
        elseif id == "d"
            d[num] = valor
        elseif id == "s"
            s[num] = valor
        elseif id == "p"
            p[num] = valor
        end
    end
    close(arquivo)
    return n, c, d, s, p
end

#Heurística de lotes com backlog

if length(ARGS) > 0
    main(ARGS[1])
else
    println("Por favor, forneça o nome do arquivo como argumento.")
end





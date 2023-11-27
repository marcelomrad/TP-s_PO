import numpy as np
import sys 

def zeroRound(value):
    if (abs(value) < 1e-4):
        value = 0.0
    return value


def custom_identity(n):
    identity_matrix = np.zeros((n, n))
    for i in range(n):
        identity_matrix[i, i] = 1
    return identity_matrix

def custom_concatenate(tuples, axis=0):
    if axis == 0: 
        return custom_vstack(tuples)
    else:  
        total_cols = sum(array.shape[1] for array in tuples)
        max_rows = max(array.shape[0] for array in tuples)
        concatenate_matrix = np.zeros((max_rows, total_cols))

        current_col = 0
        for array in tuples:
            rows, cols = array.shape
            concatenate_matrix[:rows, current_col:current_col + cols] = array
            current_col += cols

        return concatenate_matrix

def custom_vstack(tuples):
    # Garantir que todos os arrays sejam 2D
    tuples = [np.atleast_2d(array) for array in tuples]

    # Encontrar o número máximo de colunas
    max_cols = max(array.shape[1] for array in tuples)

    # Padronizar o número de colunas em todos os arrays
    tuples = [np.pad(array, ((0, 0), (0, max_cols - array.shape[1])), mode='constant') for array in tuples]

    # Calcular o número total de linhas após o empilhamento
    total_rows = sum(array.shape[0] for array in tuples)
    vstack_matrix = np.zeros((total_rows, max_cols))

    # Empilhar os arrays
    current_row = 0
    for array in tuples:
        rows = array.shape[0]
        vstack_matrix[current_row:current_row + rows, :] = array
        current_row += rows

    return vstack_matrix

def custom_column_stack(tuples):
    # Determinar o número máximo de linhas entre todos os arrays
    max_rows = max(array.shape[0] for array in tuples)

    # Determinar o número total de colunas após o empilhamento
    total_cols = sum(array.shape[1] if array.ndim > 1 else 1 for array in tuples)

    column_stack_matrix = np.zeros((max_rows, total_cols))

    current_col = 0
    for array in tuples:
        rows = array.shape[0]
        cols = array.shape[1] if array.ndim > 1 else 1
        if array.ndim > 1:
            column_stack_matrix[:rows, current_col:current_col + cols] = array
        else:
            column_stack_matrix[:rows, current_col] = array

        current_col += cols

    return column_stack_matrix


def getVeroTable(restrictions, variables, lines):
    vero = np.zeros((restrictions + 1, variables + 1))

    obj_func = lines[0].split()

    for i in range(len(obj_func)):
        vero[0][i] = int(obj_func[i]) * -1

    for i in range(1, len(vero)):
        row = lines[i].split()
        vero[i] = np.array(row, dtype=float)

    zero_column = np.zeros(restrictions)
    idt_matrix = custom_identity(restrictions)
    res = custom_vstack((zero_column, idt_matrix))

    obj_func = vero[:, -1]

    # Inserindo variáveis de folga
    vero = custom_concatenate((vero[:, :-1], res), axis=1)

    # Colocando o vetor 'b' das restrições na última coluna
    vero = custom_column_stack((vero, obj_func))

    # Colocando colunas que registram as operações
    vero = custom_concatenate((res, vero), axis=1)

    for i in range(len(vero[:, -1])):
        if vero[i, -1] < 0:
            vero[i] *= -1
    
    return vero

def getAuxVeroTable(restrictions, vero):
    one_row = np.ones(restrictions)
    idt_matrix = custom_identity(restrictions)
    res = custom_vstack((one_row[:restrictions], idt_matrix))

    auxVero = vero.copy()
    auxVero[0,:] = 0
    # Inserindo variáveis de folga
    auxVero = custom_concatenate((auxVero[:, :-1], res), axis = 1)

    # Colocando o vetor 'b' das restrições na última coluna
    auxVero = custom_column_stack((auxVero, vero[:,-1]))
    
    #gerando base viável
    for i in range(restrictions):
        auxVero[0, :] += -auxVero[(i +1),:]

    return auxVero

def isNegative(vero, restrictions):
        negativeElements = list(filter(lambda x: x < 0 , vero[0,(restrictions) : -1]))
        return True if len(negativeElements) > 0 else False

def getExitLine(pivotIndex, vero):
        results = {}

        for line in range(len(vero)):
            if line > 0:
                if vero[line][pivotIndex] > 0:
                    div_result = vero[line][-1] / vero[line][pivotIndex]
                    results[line] = div_result 
        exitLineIndex = min(results, key = results.get)

        return exitLineIndex

vfunc = np.vectorize(zeroRound)

def calculateNewPivotLine(pivotIndex, exitLineIndex, vero):
    line = vero[exitLineIndex]
    pivot = line[pivotIndex]

    newPivotLine = [value / pivot for value in line]
    newPivotLine = vfunc(newPivotLine)

    return newPivotLine

def calculateNewLine(line, pivotIndex, newPivotLine):
    pivot = line[pivotIndex] * -1
    newLine = []

    resultLine = [value * pivot for value in newPivotLine]

    for i in range(len(resultLine)):
        sum_value = resultLine[i] + line[i]
        newLine.append(sum_value)

    newLine = vfunc(newLine)

    return newLine

def show_table(vero):
        for i in range(len(vero)):
            for j in range(len(vero[0])):
                print(f'{vero[i][j]} \t', end ='')
            print()
   
def simplex(restrictions, vero, variables):    
    unbounded = False
    certificado_unbounded = np.zeros(variables)
    solucao_ilimitada = np.zeros(variables)

    while isNegative(vero, restrictions):
        pivotIndex = np.argmin(vero[0, (restrictions) : -1])
        pivotIndex += restrictions

        if np.all(vero[1:, pivotIndex] <= 0):
            unbounded = True
            # Define o certificado de ilimitação
            certificado_unbounded = -vero[0, restrictions:variables + restrictions]

            # Calcula a solução ilimitada
            for i in range(variables):
                coluna_variavel = vero[:, restrictions + i]
                if np.count_nonzero(coluna_variavel) == 1 and coluna_variavel[0] == 0:
                    linha_basica = np.where(coluna_variavel == 1)[0][0]
                    solucao_ilimitada[i] = vero[linha_basica, -1]

            return vero, unbounded, certificado_unbounded, solucao_ilimitada

        if(not unbounded):
            exitLineIndex = getExitLine(pivotIndex, vero)
            newPivotLine = calculateNewPivotLine(pivotIndex, exitLineIndex, vero)

            vero[exitLineIndex] = newPivotLine
            # Mantendo a tabela original
            table_copy = vero.copy()

            for index in range(len(vero)):
                if index != exitLineIndex:
                    line = table_copy[index]
                    new_line = calculateNewLine(line, pivotIndex, newPivotLine)
                    vero[index] = new_line

    show_table(vero)
    return vero, unbounded, certificado_unbounded, solucao_ilimitada

    
def main():
    if len(sys.argv) > 1: 
        with open(sys.argv[1], 'r') as file:
            lines = file.read().strip().split('\n') 
    else:  
        print("Enter your input (end with an empty line):")
        lines = []
        while True:
            line = input()
            if line == "":
                break
            lines.append(line)

    restrictions, variables = map(int, lines[0].split())
    vero = getVeroTable(restrictions, variables, lines[1:])
    auxVero = getAuxVeroTable(restrictions, vero)

    solution, unbounded, certificado_ilimitado, solucao_ilimitada = simplex(restrictions, auxVero, variables)

    if solution[0][-1] < 0:                    
        print('inviavel')

        # certificado
        for i in solution[0,:restrictions]:
            print('{0:.7f}'.format(i), end = ' ')
        print()
        exit()

    else:
        solution, unbounded, certificado_ilimitado, solucao_ilimitada = simplex(restrictions, vero, variables)

        if unbounded:
            print('ilimitada')

            # Imprimir solução ilimitada
            for valor in solucao_ilimitada:
                print(f'{valor:.7f}', end=' ')
            print()

            # Imprimir certificado de ilimitação
            for valor in certificado_ilimitado:
                print(f'{valor:.7f}', end=' ')
            print()

        else:
            print('otima')
            print('{0:.7f}'.format(vero[0,-1]))
                    
            # solução
            last_c = vero[:,-1]
            arr = vero[0, (restrictions):(variables + restrictions)]

            for i in range(len(arr)):
                index = np.nonzero(vero[:,[restrictions + i]] == 1)[0]
                if arr[i] == 0 and np.size(index) > 0:
                    print('{0:.7f}'.format(last_c[index[0]]), end = ' ')
                else:
                    print('{0:.7f}'.format(0), end = ' ')
            print()

            # certificado
            for i in vero[0,:restrictions]:
                print('{0:.7f}'.format(i), end = ' ')
            print()

if __name__ == "__main__":
    main()
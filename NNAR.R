############################################
## Script desenvolvido por Ícaro Agostino ##
##### Email: icaroagostino@gmail.com #######
############################################

#Julho/2018

rm(list=ls()) #Limpando a memoria

########################
# chamando bibliotecas #
########################

# caso não tenha instalado as bibliotecas abaixo use o comando:
# install.packages('nome da biblioteca')

library(tseries) #Manipular ST (Trapletti and Hornik, 2017)
library(TSA) #Manipular ST (Chan and Ripley, 2012)
library(lmtest) #Test. Hip. mod. lin. (Zeileis and Hothorn, 2002)
library(forecast) #Modelos de previsão (Hyndman and Khandakar, 2008)
library(ggplot2) #Elegant Graphics (Wickham, 2009)
#library(ggfortify) #Manipular graf. (ST) (Horikoshi and Tang, 2016)

# Obs.: a biblioteca 'ggfortify' é opcional, ela permite
# manipular melhor 'autoplot' para dados tipo ST.

########################
### Importando dados ###
########################

# para este exemplo vamos importar um banco direto da internet
# que está hospedado em https://github.com/icaroagostino/ARIMA
# são dados mensais do saldo de emprego do estado do Maranhão

dados <- read.table("https://raw.githubusercontent.com/icaroagostino/ARIMA/master/dados/MA.txt", header=T) #lendo banco
attach(dados) #tranformando em objeto

# precisamos tranformar os dados em ST utilizando o comando 'ts'
# o primeiro argumento da função é o nome da variável no banco

MA <- ts(MA, start = 2007, frequency = 12) #tranformando em ST

# start = data da primeira observação
# frequency = 1  (anual)
# frequency = 4  (trimestral)
# frequency = 12 (mensal)
# frequency = 52 (semanal)

# caso queira importar direto do pc você precisa definir o 
# diretório onde estão os dados, uma forma simples é usar
# o atalho "Ctrl + Shift + H" ou através do comando abaixo

# setwd(choose.dir())

# a formato mais simples para importar dados é o txt,
# substitua o nome do arquivo no comando read.table 
# mantendo a extenção ".txt"

############################
## Etapa 1: Identificação ##
############################

# Inspeção visual

autoplot(MA) + xlab("Anos") + ylab("Saldo de emprego - MA")

# verificação da autocorrelaçao (acf)
# e aucorrelaçao parical (pacf)

ggtsdisplay(MA) #ST + acf + pacf
ggAcf(MA) #função de autocorrelação
ggPacf(MA) #função de autocorrelação parcial

########################
## Etapa 2: Estimação ##
########################

# para a estimação dos parametros e ajuste do modelo
# será utilizado a função nnetar(), que utiliza o algoritimo
# baseado na função nnet() desenvolvido e publicado por
# Venables e Ripley (2002). Está abordagem somente considera
# a arquitertura feed-forward networks com uma camada
# intermediária usando a notação NNAR(p,k) para séries sem
# sazonalidade e NNAR(p,P,k)[m] para séries com sazonalidade
# sendo que 'p' representa o número de lags na camada de 
# entrada, 'k' o número de nós na camada intermediária da
# rede, P ó número de lags sazonais e [m] a ordem sazonal

NNAR_fit <- nnetar(MA)
NNAR_fit #sai o modelo ajustado

# Estimação manual NNAR(p,P,k)[m]

# NNAR_fit_manual <- nnetar(MA, p = 1, P = 1, size = 1)

# Obs: informe os parâmetros a serem estimados, o primeiro 
# argumento é a TS, seguido do número de p lags defasados,
# o número P lags sazonais, o número de k nós na camada
# intermadiária, também é possível definir o número de
# repetições para o ajuste do modelo adicionando o argumento
# 'repeats = 20', o que acarretará em um provavél aumento 
# da acurácia, mas também exigira maior tempo para o ajuste 
# da rede caso repeats > 20

###################################################
## Etapa 3: Validação (Verificação dos residuos) ##
###################################################

# Verificar se os residuos são independentes (MA)

checkresiduals(forecast(NNAR_fit))

# Verificar os residuos padronizados (MA)

Std_res <- (resid(NNAR_fit) - mean(resid(NNAR_fit), na.rm = T)) / sd(resid(NNAR_fit), na.rm = T)

autoplot(Std_res) +
  geom_hline(yintercept = 2, lty=3) +
  geom_hline(yintercept = -2, lty=3) +
  geom_hline(yintercept = 3, lty=2, col="4") +
  geom_hline(yintercept = -3, lty=2, col="4")

#######################
## Etapa 4: previsão ##
#######################

# Nessa etapa é definido o horizonte de previsão (h)

print(forecast(NNAR_fit, h = 12, PI = T))
autoplot(forecast(NNAR_fit, h = 12, PI = T))
accuracy(forecast(NNAR_fit)) #periodo de treino

# Obs.: a inclusão do intervalo de confiança aumenta
# consideravelmente o tempo de processamento, caso queira
# retirar basta mudar o argumento para 'PI = F'

# Como referência para maiores detalhes sobre diversos 
# aspesctos relacionados a previsão fica como sugestão
# o livro 'Forecast principles and practice' (Hyndman e 
# Athanasopoulos, 2018) o primeiro autor do livro é 
# também criador do pacote 'forecast' utilizado neste
# script e o livro pode ser lido online gratuitamente
# em: https://otexts.org/fpp2/index.html

# Para maiores detalhes sobre aplicações de RNA em 
# linguagem R consulte a biblioteca 'nnet', desenvolvida
# por Venables e Ripley (2002), com a ultima versão 7.3
# de 2016 e para aplicações mais avançadas o pacote
# 'RSNNS', desenvolvida por Bergmeir e Benitez (2012),
# com a ultima versão 0.4 de 2017

# para referenciar as bibliotecas use o comando:
# citation('nome da biblioteca')
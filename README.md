# **Neural Networks Autoregressive**

Aplicações em R para previsão de séries temporais utilizando modelagem Neural Network Autoregressive (feed-forward) a partir do pacote [**forecast**](https://pkg.robjhyndman.com/forecast/).

## Aplicação

As bibliotecas [**forecast**](https://cran.r-project.org/web/packages/forecast/) e [**ggplot2**](https://cran.r-project.org/web/packages/ggplot2/) são necessárias, utilize os comandos `install.packages('nome da biblioteca')` e `library(nome da biblioteca)` para instalar e carregar as bibliotecas.

```s
library(forecast) #Modelos de previsão (Hyndman and Khandakar, 2008)
library(ggplot2) #Elegant Graphics (Wickham, 2009)
```

Para este exemplo vamos importar um banco direto da internet que está hospedado [aqui](https://github.com/icaroagostino/ARIMA/tree/master/dados), são dados mensais do saldo de emprego do estado do Maranhão.

```{r dados}
dados <- read.table("https://raw.githubusercontent.com/icaroagostino/ARIMA/master/dados/MA.txt", header=T)
attach(dados) #tranformando em objeto
MA <- ts(MA, start = 2007, frequency = 12) #tranformando em Séries Temporal
```
### Visualização

```{r graf}
ggtsdisplay(MA, main="Saldo de emprego - MA")
```

<img src="img/Exemplo MA/graf.png" align="center"/>

A série possui caracteristicas de sazonalidade aditiva com tendência moderada negativa, além disso a análise ACF permite evidenciar a presença de autocorrelação temporal entre as observações.

## Ajuste do modelo

Para a estimação dos parametros e ajuste do modelo será utilizado a função `nnetar()`, que utiliza o algoritimo baseado na função [nnet()](https://cran.r-project.org/web/packages/nnet/) desenvolvido e publicado por Venables e Ripley (2002). Está abordagem somente considera a arquitertura feed-forward networks com uma camada intermediária usando a notação NNAR(p,k) para séries sem sazonalidade e NNAR(p,P,k)[m] para séries com sazonalidade sendo que 'p' representa o número de lags na camada de entrada, 'k' o número de nós na camada intermediária da rede, P ó número de lags sazonais e [m] a ordem sazonal.

```{r ajuste}
NNAR_fit <- nnetar(MA)
NNAR_fit #sai o modelo ajustado
```

```{r model}
## Series: MA 
## Model:  NNAR(2,1,2)[12] 
## Call:   nnetar(y = MA)
## 
## Average of 20 networks, each of which is
## a 3-2-1 network with 11 weights
## options were - linear output units 
## 
## sigma^2 estimated as 3022826
```

O modelo ajustado automaticamente considerou 2 lags na camada de entrada, 1 lag sazonal de ordem 12 (ano) e 2 nós na camada intermediária, tais parametross podem e devem ser alterados a fim de buscar um melhor ajuste do modelo a partir do comando `nnetar(MA, p = 1, P = 1, size = 1)`, também é possível definir o número de repetições para o ajuste do modelo adicionando o argumento `repeats = 20`, o que acarretará em um provavél aumento da acurácia, mas também exigira maior tempo para o ajuste da rede caso repeats > 20.

## Verificação dos résiduos

```{r res}
checkresiduals(forecast(NNAR_fit))
```

<img src="img/Exemplo MA/res.png" align="center"/>

Os resíduos gerados pelo modelo apresentaram caracteristicas de ruído branco.

## Previsão

```{r Prev}
autoplot(forecast(NNAR_fit, h = 12, PI = T))
```

<img src="img/Exemplo MA/prev.png" align="center"/>

## Obs.

Os dados utilizados nesse exemplo são públicos, para mais detalhes baixe o script NNAR.R que está [nesse](https://github.com/icaroagostino/ANN/) repositório.

contato: icaroagostino@gmail.com

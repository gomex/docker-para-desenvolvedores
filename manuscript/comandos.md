# Comandos básicos

Para utilização do Docker é necessário conhecer alguns comandos e entender de forma clara e direta para que servem, assim como alguns exemplos de uso.

Não abordaremos os comandos de criação de imagem e tratamento de problemas (troubleshooting) no Docker, pois têm capítulos específicos para o detalhamento.

## Executando um contêiner

Para iniciar um contêiner é necessário saber a partir de qual imagem será executado. Para listar as imagens que seu **Docker host** tem localmente, execute o comando abaixo:

```
docker image list
```

As imagens retornadas estão presentes no seu **Docker host** e não demandam qualquer download da [nuvem pública do Docker](https://hub.docker.com), a menos que deseje atualizá-la. Para atualizar a imagem basta executar o comando abaixo:

```
docker image pull python
```

Usamos a imagem chamada **python** como exemplo, mas caso deseje atualizar qualquer outra imagem, basta colocar seu nome no lugar de **python**.

Caso deseje inspecionar a imagem que acabou de atualizar, basta usar o comando abaixo:

```
docker image inspect python
```
O comando [inspect](https://docs.docker.com/engine/reference/commandline/inspect/) é responsável por informar todos os dados referentes à imagem.

Agora que temos a imagem atualizada e inspecionada, podemos iniciar o contêiner. Mas antes de simplesmente copiar e colar o comando, vamos entender como ele realmente funciona.

```
docker container run <parâmetros> <imagem> <CMD> <argumentos>
```

Os parâmetros mais utilizados na execução do contêiner são:

|Parâmetro   | Explicação                                                                   |
|------------|------------------------------------------------------------------------------|
|-d          | Execução do contêiner em background                                          |
|-i          | Modo interativo. Mantém o STDIN aberto mesmo sem console anexado             |
|-t          | Aloca uma pseudo TTY                                                         |
|--rm        | Automaticamente remove o contêiner após finalização (**Não funciona com -d**) |
|--name      | Nomear o contêiner                                                           |
|-v          | Mapeamento de volume                                                         |
|-p          | Mapeamento de porta                                                           |
|-m          | Limitar o uso de memória RAM                                                 |
|-c          | Balancear o uso de CPU                                                       |

Segue um exemplo simples no seguinte comando:

```
docker container run -it --rm --name meu_python python bash
```
De acordo com o comando acima, será iniciado um contêiner com o nome **meu_python**, criado a partir da imagem **python** e o processo executado nesse contêiner será o **bash**.

Vale lembrar que, caso o **CMD** não seja especificado no comando **docker container run**, é utilizado o valor padrão definido no **Dockerfile** da imagem utilizada. No nosso caso é **python** e seu comando padrão executa o binário **python**, ou seja, se não fosse especificado o **bash**, no final do comando de exemplo acima, ao invés de um shell bash do GNU/Linux, seria exibido um shell do **python**.

### Mapeamento de volumes

Para realizar mapeamento de volume basta especificar qual origem do dado no host e onde deve ser montado dentro do contêiner.

```
docker container run -it --rm -v "<host>:<container>" python
```
O uso de armazenamento é melhor explicado em capítulos futuros, por isso não detalharemos o uso desse parâmetro.

### Mapeamento de portas

Para realizar o mapeamento de portas basta saber qual porta será mapeada no host e qual deve receber essa conexão dentro do contêiner.

```
docker container run -it --rm -p "<host>:<container>" python
```
Um exemplo com a porta 80 do host para uma porta 8080 dentro do contêiner tem o seguinte comando:

```
docker container run -it --rm -p 80:8080 python
```

Com o comando acima temos a porta **80** acessível no **Docker host** que repassa todas as conexões para a porta **8080** dentro do **contêiner**. Ou seja, não é possível acessar a porta **8080** no endereço IP do **Docker host**, pois essa porta está acessível apenas dentro do **contêiner** que é isolada a nível de rede, como já dito anteriormente.

### Gerenciamento dos recursos

Na inicialização dos contêineres é possível especificar alguns limites de utilização dos recursos. Trataremos aqui apenas de memória RAM e CPU, os mais utilizados.

Para limitar o uso de memória RAM que pode ser utilizada por esse contêiner, basta executar o comando abaixo:

```
docker container run -it --rm -m 512M python
```

Com o comando acima estamos limitando esse contêiner a utilizar somente 512 MB de RAM.

Para balancear o uso da CPU pelos contêineres, utilizamos especificação de pesos para cada contêiner, quanto menor o peso, menor sua prioridade no uso. Os pesos podem oscilar de **1** a **1024**.

Caso não seja especificado o peso do contêiner, ele usará o maior peso possível, nesse caso **1024**.

Usaremos como exemplo o peso **512**:

```
docker container run -it --rm -c 512 python
```

Para entendimento, vamos imaginar que três contêineres foram colocados em execução. Um deles tem o peso padrão **1024** e dois têm o peso **512**. Caso os três processos demandem toda CPU o tempo de uso deles será dividido da seguinte maneira:

* O processo com peso **1024** usará 50% do tempo de processamento
* Os dois processos com peso **512** usarão 25% do tempo de processamento, cada.

## Verificando a lista de contêineres

Para visualizar a lista de contêineres de um determinado **Docker host** utilizamos o comando [docker container ls](https://docs.docker.com/engine/reference/commandline/container_ls/).

Esse comando é responsável por mostrar todos os contêineres, mesmo aqueles não mais em execução.

```
docker container ls <parâmetros>
```

Os parâmetros mais utilizados na execução do contêiner são:

|Parâmetro   | Explicação|  
|-----------|------------|
|-a | Lista todos os contêineres, inclusive os desligados|
|-l | Lista os últimos contêineres, inclusive os desligados|
|-n | Lista os últimos N contêineres,  inclusive os desligados|
|-q | Lista apenas os ids dos contêineres, ótimo para utilização em scripts|

## Gerenciamento de contêineres

Uma vez iniciado o contêiner a partir de uma imagem é possível gerenciar a utilização com novos comandos.

Caso deseje desligar o contêiner basta utilizar o comando [docker stop](https://docs.docker.com/engine/reference/commandline/stop/). Ele recebe como argumento o **ID** ou **nome** do contêiner. Ambos os dados podem ser obtidos com o **docker ps**, explicado no tópico anterior.

Um exemplo de uso:

```
docker container stop meu_python
```

No comando acima, caso houvesse um contêiner chamado **meu_python** em execução, ele receberia um sinal **SIGTERM** e, caso não fosse desligado, receberia um **SIGKILL** depois de 10 segundos.

Caso deseje reiniciar o contêiner que foi desligado e não iniciar um novo, basta executar o comando [docker start](https://docs.docker.com/engine/reference/commandline/start/):

```
docker container start meu_python
```

> Vale ressaltar que a ideia dos contêineres é a de serem descartáveis. Caso você use o **mesmo** contêiner por muito tempo sem descartá-lo, provavelmente está usando o Docker incorretamente.
> O Docker **não** é uma máquina, é um processo em execução. E, como todo processo, deve ser descartado para que outro possa tomar seu lugar na reinicialização do mesmo.

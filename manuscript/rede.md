# Entendendo a rede no Docker

O que o docker chama de rede, na verdade é uma abstração criada para facilitar o gerenciamento da comunicação de dados entre containers e os nós externos ao ambiente docker.

Não confunda a rede do docker com a já conhecida rede utilizada para agrupar os endereços IP (ex 192.168.10.0/24), dessa forma sempre que eu precisar mencionar esse segundo tipo de rede, citarei sempre como “rede IP“.

### Redes padrões do Docker

O docker é disponibilizado com três redes por padrão. Essas redes oferecem configurações específicas para gerenciamento do tráfego de dados. Para visualizar essas interfaces, basta utilizar o comando abaixo:

docker network ls

O retorno será:

![](images/resultado_rede.png)

#### Bridge

Cada container iniciado no docker é associado a uma rede especifica, e essa é a rede padrão para qualquer container que não foi explicitamente especificado.

Ela confere ao container uma interface que faz bridge com a interface docker0 do docker host. Essa interface receberá automaticamente o próximo endereço disponível na rede IP 172.17.0.0/16.

Todos os containers que estão nessa rede poderão se comunicar via protocolo TCP/IP, ou seja, caso você saiba qual endereço IP do container que se deseja conectar, é possível enviar tráfego pra ele, pois afinal de contas estão todos na mesma rede IP (172.17.0.0/16).

Um detalhe a se observar é que como os IPs são cedidos automaticamente, não é uma tarefa trivial descobrir qual IP do container de destino. Para ajudar com essa localização, o docker disponibiliza na inicialização de um container a opção “–link“.

> Vale ressaltar que “–link” é uma opção já defasada e seu uso é desaconselhado, explicarei esta funcionalidade apenas pra efeito de entendimento do legado. Essa função foi substituída por um DNS embutido do docker, que não funciona para redes padrões do docker, apenas disponível para redes criadas pelo usuário.

A opção “–link” é responsável por associar o IP do container de destino ao seu nome, ou seja, caso você inicie um container a partir da imagem docker do mysql com nome “bd” e em seguida inicie um com nome “app” a partir da imagem tutum/apache-php, você deseja que esse último container possa conectar no mysql usando o nome do container “bd”, basta iniciar da seguinte forma ambos containers:

```
docker run -d --name bd -e MYSQL_ROOT_PASSWORD=minhasenha mysql

docker run -d -p 80:80 --name app --link db tutum/apache-php
```

Após executar os comandos, o container que tem o nome “app” poderia conectar no container do mysql usando o nome “bd”, ou seja, toda vez que ele tentar acessar o nome “bd” ele será automaticamente resolvido para o IP da rede IP 172.17.0.0/16 que o container do mysql obteve na sua inicialização.

Pra testar utilizaremos a funcionalidade exec para rodar um comando dentro de um container já existente. Para tal usaremos o nome do container como parâmetro do comando abaixo:

```
docker exec -it app ping db
```
O comando acima será responsável por executar o comando “ping db” dentro do container “app”, ou seja, o container “app” enviará pacotes icmp, que é normalmente usado para testar conectividade entre dois hosts, para o endereço “db”. Esse nome “db” é traduzido para o IP que o container iniciado a partir da imagem do mysql obteve ao iniciar.

**Exemplo:** O container “db” iniciou primeiro e obteve o IP 172.17.0.2. O container “app” iniciou em seguida e pegou o IP 172.17.0.3. Quando o container “app” executar o comando “ping db” na verdade ele enviará pacotes icmp para o endereço 172.17.0.2.

> Atenção: O nome da opção “–link” causa uma certa confusão, pois ela não cria link de rede IP entre os containers, uma vez que a comunicação entre eles já é possível, mesmo sem a opção link ser configurada. Como foi informado no parágrafo anterior, ele apenas facilita a tradução de nomes para o IP dinâmico obtido na inicialização.

Os containers configurados para essa rede terão a possibilidade de trafego externo, utilizando as rotas das redes IP definidas no docker host, ou seja, caso o docker host tenha acesso a internet, automaticamente os containers em questão também terão.

Nessa rede é possível expor portas dos containers para todos os ativos que conseguem acessar o docker host.

#### None

Essa rede tem como objetivo isolar o container para comunicações externas, ou seja, ela não receberá nenhuma interface para comunicação externa. A sua única interface de rede IP será a localhost.

Essa rede normalmente é utilizada para containers que manipulam apenas arquivos, sem a necessidade de enviá-los via rede para outro local. (Ex. container de backup que utiliza os volumes de container de banco de dados para realizar o dump, que será usado no processo de retenção dos dados).

![Exemplo de uso da rede none](images/rede_none.png)

Em caso de duvida sobre utilização de volumes no docker. Visite [esse artigo](http://techfree.com.br/2015/12/entendendo-armazenamentos-de-dados-no-docker/) e entenda um pouco mais sobre armazenamento do docker.

#### Host

Essa rede tem como objetivo entregar para o container todas as interfaces existentes no docker host. De certa forma isso pode agilizar a entrega dos pacotes, uma vez que não há bridge no caminho das mensagens, mas normalmente esse overhead é mínimo e o uso de uma brigde pode ser importante para segurança e gerencia do seu tráfego.

### Redes definidas pelo usuário

O docker possibilita que sejam criadas redes pelo usuário, essas redes são associadas ao que docker chama de driver de rede.

Cada rede criada por usuário deve estar associado a um determinado driver, e caso você não crie seu próprio driver, você deve escolher entre os drivers disponibilizados pelo docker:

#### Bridge

Essa é o driver de rede mais simples de utilizar, pois não demanda muita configuração. A rede criada por usuário utilizando o driver bridge se assemelha bastante a rede padrão do docker com o nome “bridge”.

> Novamente um ponto que merece atenção. O docker tem uma rede padrão chamada “bridge” que utiliza um driver também chamado de “bridge“. Talvez por conta disso a confusão só aumente, mas é importante deixar claro que são coisas distintas.

As redes criadas pelo usuário com o driver bridge tem todas as funcionalidades descritas na rede padrão, chamada bridge, porém com algumas funcionalidades adicionais.

Uma dessas funcionalidades é que essa rede criada pelo usuário não precisará mais utilizar a opção legada “–link”, pois toda rede criada pelo usuário com o driver bridge poderá utilizar o DNS interno do Docker, que associará automaticamente todos os nomes de container dessa rede para seus respectivos IPs da rede IP correspondente.

Pra deixar mais claro, todos os containers que estiverem utilizando a rede padrão chamada bridge não poderão usufruir da funcionalidade de DNS interno do Docker. Caso utilize essa rede precisará especificar a opção legada “–link” para tradução dos nomes em endereços IPs dinamicamente alocados no docker.

Para exemplificar a utilização de uma rede criada por usuário, primeiro vamos criar a rede chamada isolated_nw com o driver bridge:

```
docker network create --driver bridge isolated_nw
```
Agora vamos verificar a rede que acabamos de criar:

```
docker network ls
```
O resultado será:

![](images/resultado_rede2.png)

Agora vamos iniciar um container na rede, chamada isolated_nw, que acabamos de criar:

```
docker run -itd --net isolated_nw alpine sh
```

![Rede isolada](images/bridge_network.png)

Vale salientar que um container que está em uma determinada rede não acessará um que está em outra, mesmo que você conheça o IP de destino. Para que ele acesse um outro container de outra rede, é necessário que a origem esteja nas duas redes que deseja alcançar.

Os containers que estão na rede isolated_nw poderão expor suas portas no docker host normalmente e essas portas poderão ser acessadas tanto por containers externos a rede, chamada isolated_nw, como máquinas externas com acesso ao docker host.

![Rede isolada publicando portas](images/network_access.png)

Para descobrir quais containers estão associados a uma determinada rede, execute o comando abaixo:

```
docker network inspect isolated_nw
```

O resultado será:

![](images/resultado_rede3.png)

Dentro da sessão “Containers” será possível verificar quais containers fazem parte dessa rede, ou seja, todos os containers que estiverem na mesma rede poderão se comunicar tranquilamente utilizando apenas os seus respectivos nomes. Como podemos ver no exemplo acima, caso um container novo acesse a rede isolated_nw, ele poderá acessar o container amazing_noyce utilizando apenas seu nome.

#### Overlay

Esse driver permite comunicação entre hosts docker, ou seja, com sua utilização os containers de um determinado host docker poderão acessar nativamente containers de um outro ambiente docker.

Esse driver demanda uma configuração mais complexa, sendo assim tratarei do seu detalhamento em uma outra oportunidade.

### Utilizando redes no docker compose

Esse assunto merece um artigo inteiro pra isso, sendo assim, no momento, vou apenas informar [um link interessante](https://docs.docker.com/compose/networking/) de referência sobre esse assunto.

### Conclusão

Podemos perceber que a utilização de redes definidas por usuário torna obsoleta a utilização da opção “–link”, assim como viabiliza um novo serviço de DNS interno do docker, que facilita a vida de quem se propõe a manter uma infraestrutura docker grande e complexa, assim como viabilizar o isolamento de rede dos seus serviços.

Conhecer e utilizar bem as tecnologias novas é uma boa prática, que evita problemas futuros e facilita a construção e manutenção de projetos grandes e complexos.

[Capítulo anterior: Entendendo armazenamento no Docker](armazenamento.md) | [Próximo capítulo: Utilizando Docker em múltiplos ambiente](machine.md)
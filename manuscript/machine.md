# Utilizando docker em múltiplos ambientes

Docker host é o nome do ativo responsável por gerenciar ambientes Docker, nesse capítulo mostraremos como é possível criar e gerenciá-los em infraestruturas distintas, tal como máquina virtual, nuvem e até mesmo máquina física.

![](images/machine1.png)

[Docker machine](https://docs.docker.com/machine/) é a ferramenta usada para essa gerência distribuída, que lhe permite a instalação e gerência de docker hosts de forma fácil e direta.

Essa ferramenta é muito usada por usuários de sistema operacional “não linux”, como será demonstrada ainda nesse livro, mas sua função não se limita esse fim, pois ela também é bastante usada para provisionar e gerenciar infraestrutura Docker na nuvem, tal como AWS, Digital Ocean e Openstack.

![](images/machine2.png)

### Como funciona

Antes de explicar como utilizar o docker machine, precisamos reforçar o conhecimento sobre a arquitetura do Docker.

![](images/machine3.png)

Como podemos ver na imagem acima, a utilização do Docker se divide em dois serviços, o que roda em modo daemon, em background, que é chamado de **Docker Host**, esse serviço é responsável pela viabilização dos containers no kernel Linux. Temos também o cliente, que chamaremos de **Docker client**, esse serviço é responsável por receber comandos do usuário e traduzir em gerência do **Docker Host**.

Cada **Docker client** é configurado para se conectar a um determinado **Docker host** e nesse momento o **Docker machine** entra em ação, pois ele viabiliza a automatização da escolha de configuração de acesso do Docker client a distintos **Docker host**.

O **Docker machine** possibilita que você utilize diversos ambientes distintos apenas modificando a configuração de seu cliente para o **Docker host** desejado, que é basicamente modificar algumas variáveis de ambiente. Segue abaixo um exemplo:

```
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/Users/gomex/.docker/machine/machines/default"
export DOCKER_MACHINE_NAME="default"
```
Modificando essas quatro variáveis o seu Docker client poderá utilizar um ambiente diferente rapidamente e sem precisar reiniciar nenhum serviço.

### Criando ambiente

O Docker machine serve principalmente para criar ambientes, que serão futuramente geridos por ele em sua troca automatizada de contexto de configuração, através da mudança de variáveis de ambiente, como foi explicada anteriormente.

Para criar o ambiente é necessário verificar se a infraestrutura que deseja criar tem algum driver com suporte a esse processo. Segue a [lista de drivers disponíveis](https://docs.docker.com/machine/drivers/).

#### Máquina virtual

Para esse exemplo usaremos o driver mais utilizado, que é o do [virtualbox](https://docs.docker.com/machine/drivers/virtualbox/), ou seja, precisamos de um [virtualbox](https://www.virtualbox.org/) instalado na nossa estação para que esse driver funcione adequadamente.

Antes de criar o ambiente vamos entender como funciona o comando de criação do docker machine:

docker-machine create --driver=<nome do driver>  <nome do ambiente>

Para o driver **virtualbox** temos alguns parâmetros que podem ser utilizadas:

|Parâmetro   | Explicação |
|-----------|------------|
|--virtualbox-memory  | Especifica a quantidade de memória RAM que esse ambiente poderá utilizar. O valor padrão é 1024MB. (Sempre em MB) |
|--virtualbox-cpu-count | Especifica a quantidade de núcleos de CPU que esse ambiente poderá utilizar. O valor padrão é 1 |
|--virtualbox-disk-size | Especifica o tamanho do disco que esse ambiente poderá utilizar. O valor padrão é 20000MB (Sempre em MB) |

Como teste vamos utilizar o seguinte comando:

```
docker-machine create --driver=virtualbox --virtualbox-disk-size 30000 teste-virtualbox
```

O resultado desse comando é a criação de uma máquina virtual no virtualbox, essa máquina terá 30GB de espaço em disco, 1 núcleo e 1GB de memória RAM.

Para validar que todo processo aconteceu tranquilamente, basta utilizar o seguinte comando:

```
docker-machine ls
```
O comando acima é responsável por listar todos os ambiente que podem ser usados a partir de sua estação cliente.

Pra mudar de cliente basta utilizar o comando abaixo:

```
eval $(docker-machine env teste-virtualbox)
```
Executando o comando **ls** será possível verificar qual ambiente está ativo:

```
docker-machine ls
```

Inicie um container de teste pra testar o novo ambiente

```
docker run hello-world
```

Caso deseje mudar pra outro ambiente basta digitar o comando abaixo usando o nome do ambiente desejado:

```
eval $(docker-machine env <ambiente>)
```
Caso deseje desligar seu ambiente, utilize o comando abaixo:

```
docker-machine stop teste-virtualbox
```
Caso deseje iniciar seu ambiente, utilize o comando abaixo:

```
docker-machine start teste-virtualbox
```
Caso deseje remover seu ambiente, utilize o comando abaixo:

```
docker-machine rm teste-virtualbox
```
Tratamento de problema conhecido: Caso esteja utilizando docker-machine no MacOS e por algum motivo sua estação hiberne quando o ambiente virtualbox esteja iniciado, é possível que no retorno da hibernação esse Docker host apresente problemas em sua comunicação com a internet. Dessa forma oriento a sempre que passar problemas de conectividade no seu Docker host com driver virtualbox, desligue seu ambiente e reinicie como medida de contorno.

#### Nuvem

Para esse exemplo usaremos o driver da nuvem mais utilizada, que é [AWS](http://aws.amazon.com/), ou seja, precisamos de uma conta na AWS para que [esse driver](https://docs.docker.com/machine/drivers/aws/) funcione adequadamente.

É necessário que suas credenciais estejam no arquivo ~/.aws/credentials da seguinte forma:

```
[default]
aws_access_key_id = AKID1234567890
aws_secret_access_key = MY-SECRET-KEY
```

Caso não deseje colocar essas informações em arquivo, você pode especificar via variáveis de ambiente:

```
export AWS_ACCESS_KEY_ID=AKID1234567890
export AWS_SECRET_ACCESS_KEY=MY-SECRET-KEY
```
Você pode encontrar mais informações sobre credencial AWS [nesse artigo](http://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs).

Quando criado um ambiente utilizando o comando **docker-machine create**, isso é traduzido para AWS na criação uma [instância EC2](https://aws.amazon.com/ec2/) e em seguida é instalado todos os softwares necessários automaticamente nesse novo ambiente.

Os parâmetros mais utilizados na criação desse ambiente são:

|Parâmetro   | Explicação |
|-----------|------------|
|--amazonec2-region | Informa qual região da AWS será utilizada para hospedar seu ambiente. O valor padrão é us-east-1. |
|--amazonec2-zone | É a letra que representa a zona utilizada. O valor padrão é "a" |
|--amazonec2-subnet-id | Informa qual a sub-rede utilizada nessa instância EC2. Ela precisa ter sido criada previamente. |
|--amazonec2-security-group | Informa qual o security group será utilizado nessa instância EC2. Ele precisa ter sido criado previamente |
|--amazonec2-use-private-address | Será criado uma interface com IP privado, pois por default ele só especifica uma com IP público |
|--amazonec2-vpc-id | Informa qual o ID do VPC desejado para essa instância EC2. Ela precisa ter sido criado previamente. |

Como exemplo, usarei o seguinte comando de criação do ambiente:

```
docker-machine create --driver amazonec2 --amazonec2-zone a --amazonec2-subnet-id subnet-5d3dc191 --amazonec2-security-group docker-host --amazonec2-use-private-address --amazonec2-vpc-id vpc-c1d33dc7 teste-aws
```
Após executar o comando, basta esperar finalizar, pois demora um pouco.

Para testar o sucesso do comando, execute o comando abaixo:

```
docker-machine ls
```
Verifique se o ambiente chamado teste-aws existe em sua lista, caso positivo utiliza o comando abaixo para mudar o ambiente:

```
eval $(docker-machine env teste-aws)
```
Inicie um container de teste pra testar o novo ambiente

```
docker run hello-world
```
Caso deseje desligar seu ambiente, utilize o comando abaixo:

```
docker-machine stop teste-aws
```
Caso deseje iniciar seu ambiente, utilize o comando abaixo:

```
docker-machine start teste-aws
```
Caso deseje remover seu ambiente, utilize o comando abaixo:

```
docker-machine rm teste-aws
```
Após removido localmente, ele automaticamente removerá a instância EC2 que foi provisionada na AWS.

[Capítulo anterior: Entendendo a rede no Docker](rede.md) | [Próximo capítulo: Gerenciando múltiplos containers Docker com Docker Compose](compose.md)
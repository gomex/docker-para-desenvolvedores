# Instalação

O Docker há algum tempo já deixou de ser apenas um software para virar um conjunto deles. Um ecosistema.

Nesse ecosistema temos os seguintes softwares:

* **Docker Engine:** É o software base de toda solução. É tanto o daemon responsável pelos containers como também é o cliente usado para enviar comandos pro daemon.
* **Docker Compose:** É a ferramenta responsável pela definição e execução de múltiplos containers com base em arquivo de definição.
* **Docker Machine:** é a ferramenta que possibilita criar e manter ambientes docker em máquinas virtuais, ambientes de nuvem e até mesmo em máquina física.

Não vamos citar o [Swarm](https://docs.docker.com/swarm/overview/) e outras ferramentas por não estarem alinhados com o objetivo desse livro, que é ser introdutório para os desenvolvedores.

## Instalando no GNU/Linux

Será explicado a instalação da forma mais genérica possível, ou seja, dessa forma você poderá instalar as ferramentas em qualquer distribuição GNU/Linux que esteja usando.

### Docker engine no GNU/Linux

Para instalar o docker engine é muito simples. Acesse o seu terminal preferido do GNU/Linux e se torne usuário root:

```
su - root
```
ou no caso da utilização de sudo

```
sudo su - root
```

Agora execute o comando abaixo:

```
wget -qO- https://get.docker.com/ | sh
```
Aconselho fortemente que leia o script que está sendo executado no seu sistema operacional. Acesse [esse link](https://get.docker.com/) e analise o código assim que tiver tempo para fazê-lo.

Esse procedimento demorará um pouco. Após terminar teste executando o comando abaixo:

```
docker run hello-world
```

#### Tratamento de possíveis problemas

Se o acesso a internet da sua máquina passar por um controle de tráfego (aquele que bloqueia o acesso a determinadas páginas) você poderá encontrar problemas no passo do **apt-key**, sendo assim caso passe por esse problema, execute o comando abaixo:

```
wget -qO- https://get.docker.com/gpg | sudo apt-key add -
```

### Docker compose no GNU/Linux

Acesse o seu terminal preferido do GNU/Linux e se torne usuário root:

```
su - root
```
ou no caso da utilização de sudo

```
sudo su - root
```

Agora execute o comando abaixo:

```
curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```
Para testar execute o comando abaixo:

```
docker-compose version
```

#### Instalando Docker compose com pip

O [pip](https://en.wikipedia.org/wiki/Pip_(package_manager)) é um gerenciador de pacotes Python, e como o docker-compose é escrito nessa linguagem, é possível instalá-lo desse jeito:

```
pip install docker-compose
```

### Docker machine no GNU/Linux

Para instalar o docker machine é muito simples. Acesse o seu terminal preferido do GNU/Linux e se torne usuário root:

```
su - root
```
ou no caso da utilização de sudo

```
sudo su - root
```

Agora execute o comando abaixo:

```
$ curl -L https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
chmod +x /usr/local/bin/docker-machine
```
Para testar execute o comando abaixo:

```
docker-machine version
```

Obs.: O exemplo anterior utiliza a versão mais recente no momento desta publicação. Verifique se há alguma versão mais atualizada consultando a [documentação oficial](https://docs.docker.com/machine/install-machine/).

## Instalando no MacOS

A instalação das ferramentas do Ecosistema Docker no MacOS será realizada através de um único grande pacote, que se chama **Docker Toolbox**.

Você pode instalar via brew cask com o comando abaixo:

```
brew cask install docker-toolbox
```

Você pode instalar manualmente acessando [a página de download](https://www.docker.com/products/docker-toolbox) do **Docker toolbox** e baixando o instalador correspondente ao MacOS.

Após duplo clique no instalador, verá essa tela:

![](images/mac1.png)

Apenas clique em **Continue**.

![](images/mac2.png)

Marque todas as opções e clique **Install**.

Será solicitado seu usuário e senha para liberar a instalação dos softwares. Preencha e continue o processo.

Na próxima tela será apenas apresentado as ferramentas que podem ser usadas para facilitar sua utilização do Docker no MacOS.

![](images/mac3.png)

Apenas clique em **Continue**.

Essa é ultima janela que verá nesse processo de instalação.

![](images/mac4.png)

Apenas clique em **Close** e finalize a instalação.

Para testar, procure e execute o software **Docker Quickstart Terminal**, pois ele fará todo processo necessário para começar a utilizar o Docker.

Nesse novo terminal execute o seguinte comando para teste:

```
docker run hello-world
```

## Instalando no Windows

A instalação das ferramentas do Ecosistema Docker no Windows será realizada através de um único grande pacote, que se chama **Docker Toolbox**.

O **Docker Toolbox** funcionará apenas em [versões 64bit](https://support.microsoft.com/en-us/kb/827218) do Windows e apenas as versões superiores ao Windows 7.

É importante atentar também que é necessário que o suporte a virtualização esteja habilitado. Na versão 8 do Windows é possível verificar através do **Task Manager**, na aba **Performance**, clicando em **CPU** é possível visualizar a janela abaixo:

![](images/windows1.png)

Para verificar o suporte a virtualização do Windows 7, utilize esse [link](http://www.microsoft.com/en-us/download/details.aspx?id=592) para maiores informações.

### Instalando o Docker Toolbox

Acesse [a página de download](https://www.docker.com/products/docker-toolbox) do **Docker toolbox** e baixe o instalador correspondente ao Windows.

Após duplo clique no instalador, verá essa tela:

![](images/windows2.png)

Apenas clique em **Next**.

![](images/windows3.png)

Por fim clique em **Finish**.

Para testar, procure e execute o software **Docker Quickstart Terminal**, pois ele fará todo processo necessário para começar a utilizar o Docker.

Nesse novo terminal execute o seguinte comando para teste:

```
docker run hello-world
```

[Capítulo anterior: O que é Docker](oquee.md) | [Próximo capítulo: Comandos básicos](comandos.md)
